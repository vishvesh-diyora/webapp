import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/features/export_admin/export_github_service.dart';
import 'package:webapp/features/export_admin/export_runtime_config.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

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
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _doc = widget.initialDocument;
  }

  bool get _isCatalog =>
      _doc.type == CategoryType.ecommerce || _doc.type == CategoryType.restaurantMenu;

  String get _titleKey =>
      _doc.type == CategoryType.restaurantMenu ? 'restaurantName' : 'storeName';

  String get _itemsKey => _doc.type == CategoryType.restaurantMenu ? 'menuItems' : 'products';

  Map<String, dynamic> _block(int type) =>
      Map<String, dynamic>.from(_doc.blockByContentType(type)?.contentData ?? {});

  void _setBlock(int type, Map<String, dynamic> data) {
    setState(() => _doc = _doc.updateBlockContent(type, data));
  }

  Future<void> _pickAndUploadImage(void Function(String url) onUrl) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final github = widget.config.github;
    if (github == null || !github.isConfigured) {
      _showSnack('Configure GitHub in Firebase Remote Config to upload images.');
      return;
    }
    final name = '${_uuid.v4()}.${file.name.split('.').last}';
    final service = ExportGithubService(github);
    final url = await service.uploadBytes(bytes: bytes, fileName: name);
    onUrl(url);
    _showSnack('Image uploaded');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final payload = _doc.toJson();
      final github = widget.config.github;
      if (github != null && github.isConfigured) {
        await ExportGithubService(github).publishSiteJson(payload);
        _showSnack('Saved to GitHub — visitors will see updates shortly.');
      } else {
        _showSnack('GitHub not configured in Remote Config — changes are not published.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit website'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('Business info'),
          _textField('Name', _block(1)[_titleKey] as String? ?? _doc.name, (v) {
            final p = _block(1);
            p[_titleKey] = v;
            _setBlock(1, p);
          }),
          _textField('Tagline', _block(1)['tagline'] as String? ?? '', (v) {
            final p = _block(1);
            p['tagline'] = v;
            _setBlock(1, p);
          }),
          _textField('Description', _doc.description, (v) {
            setState(() => _doc = _doc.copyWith(description: v));
          }),
          _textField('Logo image URL', _doc.logo, (v) {
            setState(() => _doc = _doc.copyWith(logo: v));
          }),
          TextButton.icon(
            onPressed: () => _pickAndUploadImage((url) {
              setState(() => _doc = _doc.copyWith(logo: url));
            }),
            icon: const Icon(Icons.upload),
            label: const Text('Upload logo to GitHub'),
          ),
          _textField('Phone', _block(1)['phone'] as String? ?? '', (v) {
            final p = _block(1);
            p['phone'] = v;
            _setBlock(1, p);
          }),
          _textField('Email', _block(1)['email'] as String? ?? '', (v) {
            final p = _block(1);
            p['email'] = v;
            _setBlock(1, p);
          }),
          _textField('Address / location', _block(1)['address'] as String? ?? '', (v) {
            final p = _block(1);
            p['address'] = v;
            _setBlock(1, p);
          }),
          _textField('WhatsApp', _block(1)['whatsapp'] as String? ?? '', (v) {
            final p = _block(1);
            p['whatsapp'] = v;
            _setBlock(1, p);
          }),
          _textField('Latitude', (_block(1)['latitude'] ?? '').toString(), (v) {
            final p = _block(1);
            p['latitude'] = double.tryParse(v) ?? v;
            _setBlock(1, p);
          }),
          _textField('Longitude', (_block(1)['longitude'] ?? '').toString(), (v) {
            final p = _block(1);
            p['longitude'] = double.tryParse(v) ?? v;
            _setBlock(1, p);
          }),
          _socialLinksEditor(),
          if (_isCatalog) ...[
            _sectionTitle('Banners'),
            _bannersEditor(),
            _sectionTitle('Categories'),
            _categoriesEditor(),
            _sectionTitle('Products / menu'),
            _productsEditor(),
          ] else
            _sectionTitle('Template blocks'),
          if (!_isCatalog)
            Text(
              'Open runtime-config.json and edit site.json on GitHub for full ${CategoryType.label(_doc.type)} content, or extend admin in app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      );

  Widget _textField(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        onChanged: onChanged,
      ),
    );
  }

  Widget _socialLinksEditor() {
    final p = _block(1);
    final links = List<Map<String, dynamic>>.from(
      (p['socialLinks'] as List?)?.whereType<Map<String, dynamic>>() ?? [],
    );
    if (links.isEmpty) {
      links.addAll([
        {'platform': 'Instagram', 'url': '', 'icon': 'instagram'},
        {'platform': 'Facebook', 'url': '', 'icon': 'facebook'},
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Social links', style: TextStyle(fontWeight: FontWeight.w600)),
        for (var i = 0; i < links.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: links[i]['platform'] as String? ?? 'Platform',
                      border: const OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: links[i]['platform'] as String? ?? ''),
                    onChanged: (v) => links[i]['platform'] = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: links[i]['url'] as String? ?? ''),
                    onChanged: (v) => links[i]['url'] = v,
                  ),
                ),
              ],
            ),
          ),
        TextButton(
          onPressed: () {
            links.add({'platform': 'Link', 'url': '', 'icon': 'link'});
            p['socialLinks'] = links;
            _setBlock(1, p);
          },
          child: const Text('Add social link'),
        ),
        TextButton(
          onPressed: () {
            p['socialLinks'] = links;
            _setBlock(1, p);
            _showSnack('Social links updated');
          },
          child: const Text('Apply social links'),
        ),
      ],
    );
  }

  Widget _bannersEditor() {
    final p = _block(1);
    final banners = List<Map<String, dynamic>>.from(
      (p['banners'] as List?)?.whereType<Map<String, dynamic>>() ?? [],
    );
    return Column(
      children: [
        for (var i = 0; i < banners.length; i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Banner ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    controller: TextEditingController(text: banners[i]['image'] as String? ?? ''),
                    onChanged: (v) => banners[i]['image'] = v,
                  ),
                  TextButton.icon(
                    onPressed: () => _pickAndUploadImage((url) {
                      banners[i]['image'] = url;
                      p['banners'] = banners;
                      _setBlock(1, p);
                    }),
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload banner image'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        banners.removeAt(i);
                        p['banners'] = banners;
                        _setBlock(1, p);
                      },
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            banners.add({'image': ''});
            p['banners'] = banners;
            _setBlock(1, p);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add banner'),
        ),
        TextButton(
          onPressed: () {
            p['banners'] = banners;
            _setBlock(1, p);
          },
          child: const Text('Apply banners'),
        ),
      ],
    );
  }

  Widget _categoriesEditor() {
    final s = _block(2);
    final categories = List<Map<String, dynamic>>.from(
      (s['categories'] as List?)?.whereType<Map<String, dynamic>>() ?? [],
    );
    return Column(
      children: [
        for (var i = 0; i < categories.length; i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Category name'),
                    controller: TextEditingController(text: categories[i]['name'] as String? ?? ''),
                    onChanged: (v) => categories[i]['name'] = v,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    controller: TextEditingController(text: categories[i]['image'] as String? ?? ''),
                    onChanged: (v) => categories[i]['image'] = v,
                  ),
                  TextButton.icon(
                    onPressed: () => _pickAndUploadImage((url) {
                      categories[i]['image'] = url;
                      s['categories'] = categories;
                      _setBlock(2, s);
                    }),
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload category photo'),
                  ),
                  TextButton(
                    onPressed: () {
                      categories.removeAt(i);
                      s['categories'] = categories;
                      _setBlock(2, s);
                    },
                    child: const Text('Remove category'),
                  ),
                ],
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            categories.add({'name': 'New category', 'image': ''});
            s['categories'] = categories;
            _setBlock(2, s);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      ],
    );
  }

  Widget _productsEditor() {
    final t = _block(3);
    final items = List<Map<String, dynamic>>.from(
      (t[_itemsKey] as List?)?.whereType<Map<String, dynamic>>() ?? [],
    );
    final categoryNames = List<String>.from(
      ((_block(2)['categories'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((c) => c['name'] as String? ?? '')
          .where((n) => n.isNotEmpty),
    );

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _ProductEditorCard(
                item: items[i],
                categories: categoryNames,
                onChanged: (next) {
                  items[i] = next;
                  t[_itemsKey] = items;
                  _setBlock(3, t);
                },
                onRemove: () {
                  items.removeAt(i);
                  t[_itemsKey] = items;
                  _setBlock(3, t);
                },
                onUploadImage: (onUrl) => _pickAndUploadImage(onUrl),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            if (categoryNames.isEmpty) {
              _showSnack('Add at least one category first.');
              return;
            }
            items.add({
              'name': 'New item',
              'category': categoryNames.first,
              'price': 0,
              'discount': 0,
              'description': '',
              'image': '',
              'images': <String>[],
            });
            t[_itemsKey] = items;
            _setBlock(3, t);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add product / menu item'),
        ),
      ],
    );
  }
}

class _ProductEditorCard extends StatelessWidget {
  const _ProductEditorCard({
    required this.item,
    required this.categories,
    required this.onChanged,
    required this.onRemove,
    required this.onUploadImage,
  });

  final Map<String, dynamic> item;
  final List<String> categories;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onRemove;
  final Future<void> Function(void Function(String url) onUrl) onUploadImage;

  List<String> _images() {
    final list = <String>[];
    final extra = item['images'];
    if (extra is List) {
      for (final e in extra) {
        if (e is String && e.isNotEmpty) list.add(e);
      }
    }
    final primary = item['image'] as String?;
    if (primary != null && primary.isNotEmpty && !list.contains(primary)) {
      list.insert(0, primary);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final images = _images();
    final category = item['category'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Name'),
          controller: TextEditingController(text: item['name'] as String? ?? ''),
          onChanged: (v) {
            item['name'] = v;
            onChanged(Map<String, dynamic>.from(item));
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: categories.contains(category) ? category : (categories.isNotEmpty ? categories.first : null),
          decoration: const InputDecoration(labelText: 'Category (required)', border: OutlineInputBorder()),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: categories.isEmpty
              ? null
              : (v) {
                  if (v == null) return;
                  item['category'] = v;
                  onChanged(Map<String, dynamic>.from(item));
                },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Description'),
          controller: TextEditingController(text: item['description'] as String? ?? ''),
          onChanged: (v) {
            item['description'] = v;
            onChanged(Map<String, dynamic>.from(item));
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Price'),
          controller: TextEditingController(text: '${item['price'] ?? ''}'),
          onChanged: (v) {
            item['price'] = num.tryParse(v) ?? v;
            onChanged(Map<String, dynamic>.from(item));
          },
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Discount %'),
          controller: TextEditingController(text: '${item['discount'] ?? 0}'),
          onChanged: (v) {
            item['discount'] = num.tryParse(v) ?? 0;
            onChanged(Map<String, dynamic>.from(item));
          },
        ),
        const SizedBox(height: 8),
        Text('Photos (max 5)', style: Theme.of(context).textTheme.titleSmall),
        for (var i = 0; i < images.length; i++)
          ListTile(
            title: Text(images[i], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                images.removeAt(i);
                item['images'] = images;
                item['image'] = images.isNotEmpty ? images.first : '';
                onChanged(Map<String, dynamic>.from(item));
              },
            ),
          ),
        if (images.length < 5)
          TextButton.icon(
            onPressed: () => onUploadImage((url) {
              final next = [...images, url];
              item['images'] = next;
              item['image'] = next.first;
              onChanged(Map<String, dynamic>.from(item));
            }),
            icon: const Icon(Icons.upload),
            label: const Text('Upload photo'),
          ),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Video URL (optional, max 1)',
            hintText: 'Google Drive or direct MP4 link',
          ),
          controller: TextEditingController(text: item['videoUrl'] as String? ?? ''),
          onChanged: (v) {
            item['videoUrl'] = v.trim().isEmpty ? null : v.trim();
            onChanged(Map<String, dynamic>.from(item));
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: onRemove, child: const Text('Remove product')),
        ),
      ],
    );
  }
}
