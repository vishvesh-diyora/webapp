import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/export_admin/export_admin_media_field.dart';
import 'package:webapp/features/export_admin/export_admin_reel_slot.dart';
import 'package:webapp/features/export_admin/export_admin_ui.dart';
import 'package:webapp/features/export_admin/export_github_service.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class _AdminSection {
  const _AdminSection(this.id, this.title, this.icon, this.subtitle);
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
}

class ExportAdminEditorScreen extends StatefulWidget {
  const ExportAdminEditorScreen({
    super.key,
    required this.config,
    required this.initialDocument,
    required this.onSaved,
  });

  final ExportRuntimeConfig config;
  final WebsiteDocument initialDocument;
  final ValueChanged<WebsiteDocument> onSaved;

  @override
  State<ExportAdminEditorScreen> createState() => _ExportAdminEditorScreenState();
}

class _ExportAdminEditorScreenState extends State<ExportAdminEditorScreen> {
  late WebsiteDocument _doc;
  bool _saving = false;
  String? _sectionId;
  int? _editIndex;
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  static const _defaultSocial = [
    {'platform': 'Instagram', 'url': '', 'icon': 'instagram'},
    {'platform': 'Facebook', 'url': '', 'icon': 'facebook'},
    {'platform': 'Twitter', 'url': '', 'icon': 'twitter'},
    {'platform': 'LinkedIn', 'url': '', 'icon': 'linkedin'},
    {'platform': 'YouTube', 'url': '', 'icon': 'youtube'},
  ];

  @override
  void initState() {
    super.initState();
    _doc = widget.initialDocument;
    final links = _list(1, 'socialLinks');
    if (links.isEmpty) {
      final data = _block(1);
      data['socialLinks'] = _defaultSocial.map((e) => Map<String, dynamic>.from(e)).toList();
      _doc = _doc.updateBlockContent(1, data);
    }
  }

  bool get _isCatalog =>
      _doc.type == CategoryType.ecommerce || _doc.type == CategoryType.restaurantMenu;

  String get _titleKey {
    if (_doc.type == CategoryType.restaurantMenu) return 'restaurantName';
    if (_doc.type == CategoryType.businessProfile) return 'businessName';
    if (_doc.type == CategoryType.portfolio) return 'name';
    return 'storeName';
  }

  String get _itemsKey => _doc.type == CategoryType.restaurantMenu ? 'menuItems' : 'products';

  Map<String, dynamic> _block(int type) =>
      Map<String, dynamic>.from(_doc.blockByContentType(type)?.contentData ?? {});

  void _setBlock(int type, Map<String, dynamic> data) {
    setState(() => _doc = _doc.updateBlockContent(type, data));
  }

  List<Map<String, dynamic>> _list(int block, String key) => List<Map<String, dynamic>>.from(
        (_block(block)[key] as List?)?.whereType<Map<String, dynamic>>() ?? [],
      );

  void _writeList(int block, String key, List<Map<String, dynamic>> items) {
    final data = _block(block);
    data[key] = items;
    _setBlock(block, data);
  }

  List<_AdminSection> get _sections {
    final sections = <_AdminSection>[
      const _AdminSection('profile', 'Profile', Icons.storefront_outlined, 'Logo, name, contact'),
      const _AdminSection('social', 'Social links', Icons.share_outlined, 'Instagram, Facebook, and more'),
    ];
    if (_isCatalog) {
      sections.addAll(const [
        _AdminSection('banners', 'Banners', Icons.view_carousel_outlined, 'Hero slides'),
        _AdminSection('categories', 'Categories', Icons.grid_view_rounded, 'Shop categories'),
        _AdminSection('items', 'Products', Icons.shopping_bag_outlined, 'Menu & catalog items'),
      ]);
      return sections;
    }
    for (final type in [1, 2, 3]) {
      final data = _block(type);
      for (final entry in data.entries) {
        final value = entry.value;
        if (value is! List || value.isEmpty) continue;
        if (value.first is! Map) continue;
        if (entry.key == 'socialLinks' || entry.key == 'theme') continue;
        sections.add(
          _AdminSection(
            '$type:${entry.key}',
            _label(entry.key),
            Icons.list_alt_outlined,
            '${value.length} items',
          ),
        );
      }
    }
    return sections;
  }

  String _label(String key) {
    final spaced = key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}');
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  Future<void> _pickAndUploadImage(void Function(String url) onUrl) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final github = widget.config.github;
    if (github == null || !github.isConfigured) {
      _showSnack('Set up GitHub in Firebase Remote Config to upload photos.');
      return;
    }
    final name = '${_uuid.v4()}.${file.name.split('.').last}';
    final url = await ExportGithubService(github).uploadBytes(bytes: bytes, fileName: name);
    onUrl(url);
    _showSnack('Photo updated');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final github = widget.config.github;
      if (github != null && github.isConfigured) {
        await ExportGithubService(github).publishSiteJson(_doc.toJson());
        _showSnack('Saved — live site will update shortly.');
      } else {
        _showSnack('GitHub not configured — publish when Remote Config is ready.');
      }
      widget.onSaved(_doc);
    } catch (e) {
      _showSnack('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openSection(String id) {
    setState(() {
      _sectionId = id;
      _editIndex = null;
    });
  }

  void _back() {
    setState(() {
      if (_editIndex != null && MediaQuery.sizeOf(context).width < 900) {
        _editIndex = null;
        return;
      }
      _sectionId = null;
      _editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Theme(
      data: theme.copyWith(
        listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          leading: _sectionId == null
              ? null
              : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
          title: Text(_sectionId == null ? 'Admin' : _sectionTitle(_sectionId!)),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
          ],
        ),
        body: _sectionId == null
            ? _home()
            : _sectionBody(wide),
      ),
    );
  }

  String _sectionTitle(String id) {
    for (final s in _sections) {
      if (s.id == id) return s.title;
    }
    return 'Edit';
  }

  Widget _home() {
    final sections = _sections;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _doc.name.isEmpty ? 'Website' : _doc.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          CategoryType.label(_doc.type),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        for (final section in sections)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(section.icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(section.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(section.id),
            ),
          ),
      ],
    );
  }

  Widget _sectionBody(bool wide) {
    if (_sectionId == 'profile') return _profileForm();
    final list = _sectionList();
    final editor = _editIndex == null
        ? _emptyEditor()
        : _editorFor(_sectionId!, _editIndex!);
    if (!wide) {
      if (_editIndex != null) return editor;
      return list;
    }
    return Row(
      children: [
        SizedBox(width: 360, child: list),
        const VerticalDivider(width: 1),
        Expanded(child: editor),
      ],
    );
  }

  Widget _emptyEditor() {
    return const Center(child: Text('Select an item to edit'));
  }

  Widget _sectionList() {
    final id = _sectionId!;
    if (id == 'social') return _socialList();
    if (id == 'banners') return _bannerList();
    if (id == 'categories') return _categoryList();
    if (id == 'items') return _itemList();
    final parts = id.split(':');
    return _genericList(int.parse(parts[0]), parts[1]);
  }

  Widget _editorFor(String id, int index) {
    if (id == 'social') return _socialEditor(index);
    if (id == 'banners') return _bannerEditor(index);
    if (id == 'categories') return _categoryEditor(index);
    if (id == 'items') return _itemEditor(index);
    final parts = id.split(':');
    return _genericEditor(int.parse(parts[0]), parts[1], index);
  }

  Widget _rowTile({
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    Widget? leading,
    bool selected = false,
  }) {
    return ListTile(
      selected: selected,
      leading: leading,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
        ],
      ),
      onTap: onEdit,
    );
  }

  Widget _socialList() {
    final links = _list(1, 'socialLinks');
    return _listScaffold(
      onAdd: () {
        links.add({'platform': 'Link', 'url': '', 'icon': 'link'});
        _writeList(1, 'socialLinks', links);
        setState(() => _editIndex = links.length - 1);
      },
      addLabel: 'Add social link',
      children: [
        for (var i = 0; i < links.length; i++)
          _rowTile(
            title: links[i]['platform'] as String? ?? 'Link',
            subtitle: (links[i]['url'] as String? ?? '').isEmpty ? 'No URL yet' : links[i]['url'] as String,
            selected: _editIndex == i,
            onEdit: () => setState(() => _editIndex = i),
            onDelete: () {
              links.removeAt(i);
              _writeList(1, 'socialLinks', links);
              setState(() => _editIndex = null);
            },
          ),
      ],
    );
  }

  Widget _socialEditor(int index) {
    final links = _list(1, 'socialLinks');
    if (index >= links.length) return _emptyEditor();
    final item = links[index];
    return _formPad(
      children: [
        TextField(
          decoration: exportAdminInputDecoration(context, 'Platform'),
          controller: TextEditingController(text: item['platform'] as String? ?? ''),
          onChanged: (v) {
            item['platform'] = v;
            item['icon'] = v.toLowerCase();
            links[index] = item;
            _writeList(1, 'socialLinks', links);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'URL'),
          controller: TextEditingController(text: item['url'] as String? ?? ''),
          onChanged: (v) {
            item['url'] = v;
            links[index] = item;
            _writeList(1, 'socialLinks', links);
          },
        ),
      ],
    );
  }

  Widget _bannerList() {
    final banners = _list(1, 'banners');
    return _listScaffold(
      onAdd: () {
        banners.add({'image': ''});
        _writeList(1, 'banners', banners);
        setState(() => _editIndex = banners.length - 1);
      },
      addLabel: 'Add banner',
      children: [
        for (var i = 0; i < banners.length; i++)
          _rowTile(
            title: 'Banner ${i + 1}',
            subtitle: (banners[i]['image'] as String? ?? '').isEmpty ? 'No image' : 'Image set',
            selected: _editIndex == i,
            leading: ExportAdminCompactImageButton(
              imageUrl: banners[i]['image'] as String?,
              size: 44,
              shape: BoxShape.rectangle,
              onTap: () => setState(() => _editIndex = i),
            ),
            onEdit: () => setState(() => _editIndex = i),
            onDelete: () {
              banners.removeAt(i);
              _writeList(1, 'banners', banners);
              setState(() => _editIndex = null);
            },
          ),
      ],
    );
  }

  Widget _bannerEditor(int index) {
    final banners = _list(1, 'banners');
    if (index >= banners.length) return _emptyEditor();
    return _formPad(
      children: [
        ExportAdminEditableImage(
          imageUrl: banners[index]['image'] as String?,
          height: 140,
          onChange: () => _pickAndUploadImage((url) {
            banners[index]['image'] = url;
            _writeList(1, 'banners', banners);
          }),
        ),
      ],
    );
  }

  Widget _categoryList() {
    final cats = _list(2, 'categories');
    return _listScaffold(
      onAdd: () {
        cats.add({'name': 'New category', 'image': ''});
        _writeList(2, 'categories', cats);
        setState(() => _editIndex = cats.length - 1);
      },
      addLabel: 'Add category',
      children: [
        for (var i = 0; i < cats.length; i++)
          _rowTile(
            title: cats[i]['name'] as String? ?? 'Category',
            subtitle: (cats[i]['image'] as String? ?? '').isEmpty ? 'No photo' : 'Photo set',
            selected: _editIndex == i,
            leading: ExportAdminCompactImageButton(
              imageUrl: cats[i]['image'] as String?,
              size: 44,
              shape: BoxShape.rectangle,
              onTap: () => setState(() => _editIndex = i),
            ),
            onEdit: () => setState(() => _editIndex = i),
            onDelete: () {
              cats.removeAt(i);
              _writeList(2, 'categories', cats);
              setState(() => _editIndex = null);
            },
          ),
      ],
    );
  }

  Widget _categoryEditor(int index) {
    final cats = _list(2, 'categories');
    if (index >= cats.length) return _emptyEditor();
    return _formPad(
      children: [
        ExportAdminEditableImage(
          imageUrl: cats[index]['image'] as String?,
          height: 120,
          width: 160,
          onChange: () => _pickAndUploadImage((url) {
            cats[index]['image'] = url;
            _writeList(2, 'categories', cats);
          }),
        ),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Name'),
          controller: TextEditingController(text: cats[index]['name'] as String? ?? ''),
          onChanged: (v) {
            cats[index]['name'] = v;
            _writeList(2, 'categories', cats);
          },
        ),
      ],
    );
  }

  Widget _itemList() {
    final items = _list(3, _itemsKey);
    return _listScaffold(
      onAdd: () {
        final cats = _list(2, 'categories');
        if (cats.isEmpty) {
          _showSnack('Add a category first.');
          return;
        }
        items.add({
          'name': 'New item',
          'category': cats.first['name'],
          'price': 0,
          'discount': 0,
          'description': '',
          'image': '',
          'images': <String>[],
        });
        _writeList(3, _itemsKey, items);
        setState(() => _editIndex = items.length - 1);
      },
      addLabel: 'Add item',
      children: [
        for (var i = 0; i < items.length; i++)
          _rowTile(
            title: items[i]['name'] as String? ?? 'Item',
            subtitle: items[i]['category'] as String? ?? '',
            selected: _editIndex == i,
            leading: ExportAdminCompactImageButton(
              imageUrl: items[i]['image'] as String?,
              size: 44,
              shape: BoxShape.rectangle,
              onTap: () => setState(() => _editIndex = i),
            ),
            onEdit: () => setState(() => _editIndex = i),
            onDelete: () {
              items.removeAt(i);
              _writeList(3, _itemsKey, items);
              setState(() => _editIndex = null);
            },
          ),
      ],
    );
  }

  Widget _itemEditor(int index) {
    final items = _list(3, _itemsKey);
    if (index >= items.length) return _emptyEditor();
    final item = Map<String, dynamic>.from(items[index]);
    final categories = _list(2, 'categories')
        .map((c) => c['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    final images = <String>[];
    final extra = item['images'];
    if (extra is List) {
      for (final e in extra) {
        if (e is String && e.isNotEmpty) images.add(e);
      }
    }
    final primary = item['image'] as String?;
    if (primary != null && primary.isNotEmpty && !images.contains(primary)) {
      images.insert(0, primary);
    }
    void commit() {
      items[index] = item;
      _writeList(3, _itemsKey, items);
    }

    return _formPad(
      children: [
        TextField(
          decoration: exportAdminInputDecoration(context, 'Name'),
          controller: TextEditingController(text: item['name'] as String? ?? ''),
          onChanged: (v) {
            item['name'] = v;
            commit();
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: categories.contains(item['category']) ? item['category'] as String : (categories.isEmpty ? null : categories.first),
          decoration: exportAdminInputDecoration(context, 'Category'),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) {
            if (v == null) return;
            item['category'] = v;
            commit();
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < images.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ExportAdminImageThumb(
                    url: images[i],
                    size: 72,
                    onTap: () => _pickAndUploadImage((url) {
                      images[i] = url;
                      item['images'] = images;
                      item['image'] = images.first;
                      commit();
                    }),
                    onRemove: () {
                      images.removeAt(i);
                      item['images'] = images;
                      item['image'] = images.isEmpty ? '' : images.first;
                      commit();
                    },
                  ),
                ),
              if (images.length < 5)
                ExportAdminAddTile(
                  label: 'Photo',
                  width: 64,
                  height: 64,
                  onTap: () => _pickAndUploadImage((url) {
                    images.add(url);
                    item['images'] = images;
                    item['image'] = images.first;
                    commit();
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ExportAdminReelSlot(
          videoUrl: item['videoUrl'] as String?,
          onUrlChanged: (v) {
            item['videoUrl'] = v;
            commit();
          },
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Price'),
          controller: TextEditingController(text: '${item['price'] ?? ''}'),
          onChanged: (v) {
            item['price'] = num.tryParse(v) ?? v;
            commit();
          },
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Description'),
          maxLines: 2,
          controller: TextEditingController(text: item['description'] as String? ?? ''),
          onChanged: (v) {
            item['description'] = v;
            commit();
          },
        ),
      ],
    );
  }

  Widget _genericList(int block, String key) {
    final items = _list(block, key);
    return _listScaffold(
      onAdd: () {
        items.add(_blankLikeExisting(items));
        _writeList(block, key, items);
        setState(() => _editIndex = items.length - 1);
      },
      addLabel: 'Add',
      children: [
        for (var i = 0; i < items.length; i++)
          _rowTile(
            title: _itemTitle(items[i]),
            subtitle: _itemSubtitle(items[i]),
            selected: _editIndex == i,
            onEdit: () => setState(() => _editIndex = i),
            onDelete: () {
              items.removeAt(i);
              _writeList(block, key, items);
              setState(() => _editIndex = null);
            },
          ),
      ],
    );
  }

  Map<String, dynamic> _blankLikeExisting(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return {'title': 'New'};
    final keys = <String>{};
    for (final item in items) {
      keys.addAll(item.keys);
    }
    keys.remove('theme');
    final sample = items.first;
    final blank = <String, dynamic>{};
    for (final key in keys) {
      final value = sample[key] ?? items.map((e) => e[key]).firstWhere((v) => v != null, orElse: () => '');
      if (value is int) {
        blank[key] = 0;
      } else if (value is double) {
        blank[key] = 0.0;
      } else if (value is num) {
        blank[key] = 0;
      } else if (value is bool) {
        blank[key] = false;
      } else if (value is List) {
        blank[key] = <dynamic>[];
      } else if (value is Map) {
        blank[key] = <String, dynamic>{};
      } else if (key == 'name' || key == 'title') {
        blank[key] = 'New';
      } else {
        blank[key] = '';
      }
    }
    return blank;
  }

  String _itemTitle(Map<String, dynamic> item) {
    for (final k in ['name', 'title', 'platform', 'degree', 'quote']) {
      final v = item[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return 'Item';
  }

  String _itemSubtitle(Map<String, dynamic> item) {
    for (final k in ['category', 'role', 'description', 'url', 'address']) {
      final v = item[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  Widget _genericEditor(int block, String key, int index) {
    final items = _list(block, key);
    if (index >= items.length) return _emptyEditor();
    final item = Map<String, dynamic>.from(items[index]);
    final fields = <String>{};
    for (final row in items) {
      fields.addAll(row.keys);
    }
    fields.remove('theme');
    return _formPad(
      children: [
        for (final field in fields) ...[
          if (_fieldIsImage(items, field))
            ExportAdminEditableImage(
              imageUrl: item[field] as String? ?? '',
              height: 150,
              onChange: () => _pickAndUploadImage((url) {
                item[field] = url;
                items[index] = item;
                _writeList(block, key, items);
              }),
            )
          else if (_fieldIsText(items, field))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                decoration: exportAdminInputDecoration(context, _label(field)),
                controller: TextEditingController(text: '${item[field] ?? ''}'),
                onChanged: (v) {
                  final sample = items.map((e) => e[field]).firstWhere((value) => value != null, orElse: () => '');
                  item[field] = sample is num ? (num.tryParse(v) ?? v) : v;
                  items[index] = item;
                  _writeList(block, key, items);
                },
              ),
            ),
        ],
      ],
    );
  }

  bool _fieldIsImage(List<Map<String, dynamic>> items, String field) {
    final key = field.toLowerCase();
    if (key.contains('image') || key == 'logo' || key == 'photo') return true;
    for (final row in items) {
      final value = row[field];
      if (value is String && (value.startsWith('http') || value.startsWith('assets/'))) {
        return key.contains('image') || key == 'logo' || key == 'photo';
      }
    }
    return false;
  }

  bool _fieldIsText(List<Map<String, dynamic>> items, String field) {
    if (_fieldIsImage(items, field)) return false;
    for (final row in items) {
      final value = row[field];
      if (value is String || value is num) return true;
    }
    return false;
  }

  Widget _profileForm() {
    final p = _block(1);
    final name = p[_titleKey] as String? ?? _doc.name;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            ExportAdminEditableImage(
              imageUrl: _doc.logo.isEmpty ? p['logo'] as String? : _doc.logo,
              width: 72,
              height: 72,
              onChange: () => _pickAndUploadImage((url) {
                setState(() => _doc = _doc.copyWith(logo: url));
                final next = _block(1);
                next['logo'] = url;
                _setBlock(1, next);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: exportAdminInputDecoration(context, 'Name'),
                controller: TextEditingController(text: name),
                onChanged: (v) {
                  final next = _block(1);
                  next[_titleKey] = v;
                  _setBlock(1, next);
                  setState(() => _doc = _doc.copyWith(name: v));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Tagline'),
          controller: TextEditingController(text: p['tagline'] as String? ?? ''),
          onChanged: (v) {
            final next = _block(1);
            next['tagline'] = v;
            _setBlock(1, next);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Phone'),
          controller: TextEditingController(text: p['phone'] as String? ?? ''),
          onChanged: (v) {
            final next = _block(1);
            next['phone'] = v;
            _setBlock(1, next);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Email'),
          controller: TextEditingController(text: p['email'] as String? ?? ''),
          onChanged: (v) {
            final next = _block(1);
            next['email'] = v;
            _setBlock(1, next);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'Address'),
          controller: TextEditingController(text: p['address'] as String? ?? ''),
          onChanged: (v) {
            final next = _block(1);
            next['address'] = v;
            _setBlock(1, next);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: exportAdminInputDecoration(context, 'WhatsApp'),
          controller: TextEditingController(text: p['whatsapp'] as String? ?? ''),
          onChanged: (v) {
            final next = _block(1);
            next['whatsapp'] = v;
            _setBlock(1, next);
          },
        ),
      ],
    );
  }

  Widget _listScaffold({
    required VoidCallback onAdd,
    required String addLabel,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Expanded(child: ListView(children: children)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(addLabel)),
          ),
        ),
      ],
    );
  }

  Widget _formPad({required List<Widget> children}) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: children,
    );
  }
}
