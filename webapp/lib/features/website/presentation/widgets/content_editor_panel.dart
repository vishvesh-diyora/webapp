import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webapp/core/domain/category_type.dart';
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';
import 'package:webapp/features/website/presentation/bloc/website_editor_bloc.dart';

/// Category-aware JSON editor — all fields write to the same [WebsiteDocument].
class ContentEditorPanel extends StatelessWidget {
  const ContentEditorPanel({super.key, required this.document});

  final WebsiteDocument document;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('${document.type}-${document.templateType}-${document.updatedAt?.millisecondsSinceEpoch ?? 0}'),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(context, 'Site'),
        _textField(context, label: 'Name', value: document.name, onChanged: (v) {
          context.read<WebsiteEditorBloc>().add(WebsiteEditorMetaChanged(name: v));
        }),
        _textField(context, label: 'Subtitle', value: document.subname, onChanged: (v) {
          context.read<WebsiteEditorBloc>().add(WebsiteEditorMetaChanged(subname: v));
        }),
        _textField(context, label: 'Description', value: document.description, maxLines: 3, onChanged: (v) {
          context.read<WebsiteEditorBloc>().add(WebsiteEditorMetaChanged(description: v));
        }),
        _imageField(context, label: 'Logo', path: document.logo, onPick: () {
          context.read<WebsiteEditorBloc>().add(const WebsiteEditorImagePicked(
                contentType: ContentType.primary,
                field: 'logo',
              ));
        }),
        const SizedBox(height: 16),
        ...switch (document.type) {
          CategoryType.portfolio => _portfolioEditors(context, document),
          CategoryType.businessProfile => _businessEditors(context, document),
          CategoryType.giftReveal => _giftEditors(context, document),
          CategoryType.restaurantMenu => _restaurantEditors(context, document),
          CategoryType.ecommerce => _ecommerceEditors(context, document),
          _ => const <Widget>[],
        },
      ],
    );
  }

  static List<Widget> _portfolioEditors(BuildContext context, WebsiteDocument doc) {
    final p = doc.blockByContentType(1)?.contentData ?? {};
    final s = doc.blockByContentType(2)?.contentData ?? {};
    return [
      _sectionTitle(context, 'Profile'),
      _textField(context, label: 'Name', value: p['name'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'name', value: v));
      }),
      _textField(context, label: 'Subtitle', value: p['subtitle'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'subtitle', value: v));
      }),
      _textField(context, label: 'Bio', value: p['bio'] as String? ?? '', maxLines: 4, onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'bio', value: v));
      }),
      _textField(context, label: 'Location', value: p['location'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'location', value: v));
      }),
      _imageField(context, label: 'Profile photo', path: p['profileImage'] as String?, onPick: () {
        context.read<WebsiteEditorBloc>().add(const WebsiteEditorImagePicked(contentType: 1, field: 'profileImage'));
      }),
      _textField(context, label: 'Resume URL', value: p['resumeUrl'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'resumeUrl', value: v));
      }),
      _listEditor(context, doc, contentType: 1, listKey: 'socialLinks', title: 'Social links', fields: const [
        _FieldDef('platform', 'Platform'),
        _FieldDef('url', 'URL'),
      ], emptyItem: const {'platform': 'Link', 'url': 'https://', 'icon': 'link'}),
      _listEditor(context, doc, contentType: 1, listKey: 'buttons', title: 'Buttons', fields: const [
        _FieldDef('label', 'Label'),
        _FieldDef('url', 'URL'),
      ], emptyItem: const {'label': 'Button', 'url': '#', 'style': 'primary'}),
      _sectionTitle(context, 'About & Experience'),
      _textField(context, label: 'About', value: s['about'] as String? ?? '', maxLines: 4, onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 2, field: 'about', value: v));
      }),
      _listEditor(context, doc, contentType: 2, listKey: 'experience', title: 'Experience', fields: const [
        _FieldDef('role', 'Role'),
        _FieldDef('company', 'Company'),
        _FieldDef('period', 'Period'),
      ], emptyItem: const {'role': '', 'company': '', 'period': '', 'description': ''}),
      _listEditor(context, doc, contentType: 2, listKey: 'skills', title: 'Skills', fields: const [
        _FieldDef('', 'Skill'),
      ], emptyItem: '', isStringList: true),
      _listEditor(context, doc, contentType: 2, listKey: 'education', title: 'Education', fields: const [
        _FieldDef('degree', 'Degree'),
        _FieldDef('school', 'School'),
        _FieldDef('year', 'Year'),
      ], emptyItem: const {'degree': '', 'school': '', 'year': ''}),
      _listEditor(context, doc, contentType: 2, listKey: 'testimonials', title: 'Testimonials', fields: const [
        _FieldDef('quote', 'Quote'),
        _FieldDef('author', 'Author'),
        _FieldDef('role', 'Role'),
      ], emptyItem: const {'quote': '', 'author': '', 'role': '', 'rating': 5}),
      _sectionTitle(context, 'Projects & Gallery'),
      _listEditor(context, doc, contentType: 3, listKey: 'projects', title: 'Projects', fields: const [
        _FieldDef('title', 'Title'),
        _FieldDef('category', 'Category'),
        _FieldDef('year', 'Year'),
      ], emptyItem: const {'title': '', 'category': '', 'year': '', 'image': 'assets/images/project-1.jpg'}, imageField: 'image'),
      _listEditor(context, doc, contentType: 3, listKey: 'gallery', title: 'Gallery', fields: const [
        _FieldDef('caption', 'Caption'),
      ], emptyItem: const {'image': 'assets/images/gallery-1.jpg', 'caption': ''}, imageField: 'image'),
      _themeEditor(context, doc),
    ];
  }

  static List<Widget> _businessEditors(BuildContext context, WebsiteDocument doc) {
    final p = doc.blockByContentType(1)?.contentData ?? {};
    final s = doc.blockByContentType(2)?.contentData ?? {};
    return [
      _sectionTitle(context, 'Business intro'),
      _textField(context, label: 'Business name', value: p['businessName'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'businessName', value: v));
      }),
      _textField(context, label: 'Tagline', value: p['tagline'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'tagline', value: v));
      }),
      _textField(context, label: 'Address', value: p['address'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'address', value: v));
      }),
      _textField(context, label: 'Phone', value: p['phone'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'phone', value: v));
      }),
      _textField(context, label: 'WhatsApp', value: p['whatsapp'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'whatsapp', value: v));
      }),
      _textField(context, label: 'Email', value: p['email'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'email', value: v));
      }),
      _listEditor(context, doc, contentType: 1, listKey: 'socialLinks', title: 'Social links', fields: const [
        _FieldDef('platform', 'Platform'),
        _FieldDef('url', 'URL'),
      ], emptyItem: const {'platform': 'Instagram', 'url': 'https://', 'icon': 'instagram'}),
      _textField(context, label: 'Map embed URL', value: p['mapEmbed'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'mapEmbed', value: v));
      }),
      _imageField(context, label: 'Logo', path: p['logo'] as String?, onPick: () {
        context.read<WebsiteEditorBloc>().add(const WebsiteEditorImagePicked(contentType: 1, field: 'logo'));
      }),
      _sectionTitle(context, 'Services & team'),
      _textField(context, label: 'About', value: s['about'] as String? ?? '', maxLines: 4, onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 2, field: 'about', value: v));
      }),
      _listEditor(context, doc, contentType: 2, listKey: 'services', title: 'Services', fields: const [
        _FieldDef('title', 'Title'),
        _FieldDef('description', 'Description'),
      ], emptyItem: const {'title': '', 'description': ''}),
      _listEditor(context, doc, contentType: 2, listKey: 'achievements', title: 'Achievements', fields: const [
        _FieldDef('title', 'Title'),
        _FieldDef('value', 'Value'),
      ], emptyItem: const {'title': '', 'value': ''}),
      _listEditor(context, doc, contentType: 2, listKey: 'team', title: 'Team', fields: const [
        _FieldDef('name', 'Name'),
        _FieldDef('role', 'Role'),
      ], emptyItem: const {'name': '', 'role': '', 'image': 'assets/images/team-1.jpg'}, imageField: 'image'),
      _listEditor(context, doc, contentType: 2, listKey: 'testimonials', title: 'Testimonials', fields: const [
        _FieldDef('quote', 'Quote'),
        _FieldDef('author', 'Author'),
      ], emptyItem: const {'quote': '', 'author': '', 'role': ''}),
      _listEditor(context, doc, contentType: 3, listKey: 'branches', title: 'Branches', fields: const [
        _FieldDef('name', 'Name'),
        _FieldDef('address', 'Address'),
        _FieldDef('phone', 'Phone'),
      ], emptyItem: const {'name': '', 'address': '', 'phone': ''}),
      _listEditor(context, doc, contentType: 3, listKey: 'gallery', title: 'Gallery', fields: const [
        _FieldDef('title', 'Title'),
      ], emptyItem: const {'image': 'assets/images/gallery-1.jpg', 'title': ''}, imageField: 'image'),
      _themeEditor(context, doc),
    ];
  }

  static List<Widget> _giftEditors(BuildContext context, WebsiteDocument doc) {
    final p = doc.blockByContentType(1)?.contentData ?? {};
    final s = doc.blockByContentType(2)?.contentData ?? {};
    final t = doc.blockByContentType(3)?.contentData ?? {};
    return [
      _sectionTitle(context, 'Reveal'),
      _textField(context, label: 'Title', value: p['title'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'title', value: v));
      }),
      _imageField(context, label: 'Cover image', path: p['coverImage'] as String?, onPick: () {
        context.read<WebsiteEditorBloc>().add(const WebsiteEditorImagePicked(contentType: 1, field: 'coverImage'));
      }),
      _sectionTitle(context, 'Messages & countdown'),
      _textField(context, label: 'Countdown (seconds)', value: '${s['countdownSeconds'] ?? 10}', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(
              contentType: 2,
              field: 'countdownSeconds',
              value: int.tryParse(v) ?? 10,
            ));
      }),
      _textField(context, label: 'Music URL', value: s['musicUrl'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 2, field: 'musicUrl', value: v));
      }),
      _textField(context, label: 'Animation', value: s['animation'] as String? ?? 'confetti', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 2, field: 'animation', value: v));
      }),
      _listEditor(context, doc, contentType: 2, listKey: 'messages', title: 'Messages', fields: const [
        _FieldDef('text', 'Message'),
      ], emptyItem: const {'text': '', 'delayMs': 0}),
      _listEditor(context, doc, contentType: 1, listKey: 'revealImages', title: 'Reveal images', fields: const [
        _FieldDef('', 'Caption'),
      ], emptyItem: 'assets/images/reveal-1.jpg', isStringList: true),
      _sectionTitle(context, 'Finale'),
      _textField(context, label: 'Final message', value: t['finalMessage'] as String? ?? '', maxLines: 3, onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 3, field: 'finalMessage', value: v));
      }),
      _textField(context, label: 'CTA label', value: t['ctaLabel'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 3, field: 'ctaLabel', value: v));
      }),
      _themeEditor(context, doc),
    ];
  }

  static List<Widget> _restaurantEditors(BuildContext context, WebsiteDocument doc) {
    final p = doc.blockByContentType(1)?.contentData ?? {};
    return [
      _sectionTitle(context, 'Restaurant'),
      _textField(context, label: 'Name', value: p['restaurantName'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'restaurantName', value: v));
      }),
      _textField(context, label: 'Tagline', value: p['tagline'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'tagline', value: v));
      }),
      _textField(context, label: 'WhatsApp', value: p['whatsapp'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'whatsapp', value: v));
      }),
      _listEditor(context, doc, contentType: 1, listKey: 'banners', title: 'Banners', fields: const [
        _FieldDef('title', 'Title'),
        _FieldDef('subtitle', 'Subtitle'),
      ], emptyItem: const {'title': '', 'subtitle': '', 'image': 'assets/images/banner-1.jpg'}, imageField: 'image'),
      _listEditor(context, doc, contentType: 1, listKey: 'offers', title: 'Offers', fields: const [
        _FieldDef('label', 'Label'),
        _FieldDef('code', 'Code'),
      ], emptyItem: const {'label': '', 'code': ''}),
      _listEditor(context, doc, contentType: 2, listKey: 'categories', title: 'Categories', fields: const [
        _FieldDef('name', 'Name'),
      ], emptyItem: const {'name': '', 'icon': 'starters'}),
      _listEditor(context, doc, contentType: 3, listKey: 'menuItems', title: 'Menu items', fields: const [
        _FieldDef('name', 'Name'),
        _FieldDef('category', 'Category'),
        _FieldDef('price', 'Price'),
        _FieldDef('discount', 'Discount %'),
        _FieldDef('description', 'Description'),
      ], emptyItem: const {
        'name': '',
        'category': '',
        'price': 0,
        'discount': 0,
        'description': '',
        'image': 'assets/images/menu-1.jpg',
      }, imageField: 'image'),
      _themeEditor(context, doc),
    ];
  }

  static List<Widget> _ecommerceEditors(BuildContext context, WebsiteDocument doc) {
    final p = doc.blockByContentType(1)?.contentData ?? {};
    return [
      _sectionTitle(context, 'Store'),
      _textField(context, label: 'Store name', value: p['storeName'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'storeName', value: v));
      }),
      _textField(context, label: 'Tagline', value: p['tagline'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'tagline', value: v));
      }),
      _textField(context, label: 'WhatsApp', value: p['whatsapp'] as String? ?? '', onChanged: (v) {
        context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'whatsapp', value: v));
      }),
      _listEditor(context, doc, contentType: 2, listKey: 'categories', title: 'Categories', fields: const [
        _FieldDef('name', 'Name'),
      ], emptyItem: const {'name': '', 'image': 'assets/images/cat-1.jpg'}, imageField: 'image'),
      _listEditor(context, doc, contentType: 3, listKey: 'products', title: 'Products', fields: const [
        _FieldDef('name', 'Name'),
        _FieldDef('category', 'Category'),
        _FieldDef('price', 'Price'),
        _FieldDef('discount', 'Discount %'),
        _FieldDef('description', 'Description'),
      ], emptyItem: const {
        'name': '',
        'category': '',
        'price': 0,
        'discount': 0,
        'description': '',
        'image': 'assets/images/product-1.jpg',
      }, imageField: 'image'),
      _themeEditor(context, doc),
    ];
  }

  static Widget _themeEditor(BuildContext context, WebsiteDocument doc) {
    final theme = doc.blockByContentType(1)?.contentData['theme'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Theme colors'),
        _textField(context, label: 'Primary', value: theme['primary'] as String? ?? '#6366F1', onChanged: (v) {
          _updateTheme(context, doc, 'primary', v);
        }),
        _textField(context, label: 'Secondary', value: theme['secondary'] as String? ?? '#0F172A', onChanged: (v) {
          _updateTheme(context, doc, 'secondary', v);
        }),
        _textField(context, label: 'Accent', value: theme['accent'] as String? ?? '#8B5CF6', onChanged: (v) {
          _updateTheme(context, doc, 'accent', v);
        }),
        _textField(context, label: 'Background', value: theme['background'] as String? ?? '#FFFFFF', onChanged: (v) {
          _updateTheme(context, doc, 'background', v);
        }),
      ],
    );
  }

  static void _updateTheme(BuildContext context, WebsiteDocument doc, String key, String value) {
    final block = doc.blockByContentType(1);
    if (block == null) return;
    final theme = Map<String, dynamic>.from(block.contentData['theme'] as Map? ?? {})..[key] = value;
    context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(contentType: 1, field: 'theme', value: theme));
  }

  static Widget _listEditor(
    BuildContext context,
    WebsiteDocument doc, {
    required int contentType,
    required String listKey,
    required String title,
    required List<_FieldDef> fields,
    required dynamic emptyItem,
    bool isStringList = false,
    String? imageField,
  }) {
    final block = doc.blockByContentType(contentType);
    final raw = block?.contentData[listKey];
    final items = isStringList
        ? (raw as List?)?.map((e) => e.toString()).toList() ?? <String>[]
        : (raw as List?)?.whereType<Map<String, dynamic>>().toList() ?? <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            TextButton.icon(
              onPressed: () {
                if (isStringList) {
                  final strings = List<String>.from(items);
                  strings.add('New skill');
                  context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(
                        contentType: contentType,
                        field: listKey,
                        value: strings,
                      ));
                } else {
                  context.read<WebsiteEditorBloc>().add(WebsiteEditorListItemAdded(
                        contentType: contentType,
                        listKey: listKey,
                        item: Map<String, dynamic>.from(emptyItem as Map),
                      ));
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        for (var i = 0; i < items.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (isStringList)
                    _textField(context, label: 'Item', value: items[i] as String, onChanged: (v) {
                      final strings = List<String>.from(items);
                      strings[i] = v;
                      context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(
                            contentType: contentType,
                            field: listKey,
                            value: strings,
                          ));
                    })
                  else ...[
                    for (final field in fields)
                      if (field.key.isNotEmpty)
                        _textField(
                          context,
                          label: field.label,
                          value: (items[i] as Map<String, dynamic>)[field.key]?.toString() ?? '',
                          onChanged: (v) {
                            final item = Map<String, dynamic>.from(items[i] as Map);
                            item[field.key] = field.key == 'price' || field.key == 'discount'
                                ? num.tryParse(v) ?? 0
                                : v;
                            context.read<WebsiteEditorBloc>().add(WebsiteEditorListItemChanged(
                                  contentType: contentType,
                                  listKey: listKey,
                                  index: i,
                                  item: item,
                                ));
                          },
                        ),
                    if (imageField != null)
                      _imageField(
                        context,
                        label: 'Image',
                        path: (items[i] as Map<String, dynamic>)[imageField] as String?,
                        onPick: () {
                          context.read<WebsiteEditorBloc>().add(WebsiteEditorImagePicked(
                                contentType: contentType,
                                field: imageField,
                                listKey: listKey,
                                listIndex: i,
                                listField: imageField,
                              ));
                        },
                      ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        if (isStringList) {
                          final strings = List<String>.from(items)..removeAt(i);
                          context.read<WebsiteEditorBloc>().add(WebsiteEditorFieldChanged(
                                contentType: contentType,
                                field: listKey,
                                value: strings,
                              ));
                        } else {
                          context.read<WebsiteEditorBloc>().add(WebsiteEditorListItemRemoved(
                                contentType: contentType,
                                listKey: listKey,
                                index: i,
                              ));
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  static Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  static Widget _textField(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
      ),
    );
  }

  static Widget _imageField(
    BuildContext context, {
    required String label,
    required String? path,
    required VoidCallback onPick,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ImageAssetService.buildImage(path: path, width: 56, height: 56, borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 12),
          Expanded(child: Text(path ?? 'No image', maxLines: 2, overflow: TextOverflow.ellipsis)),
          OutlinedButton(onPressed: onPick, child: Text(label)),
        ],
      ),
    );
  }
}

class _FieldDef {
  const _FieldDef(this.key, this.label);
  final String key;
  final String label;
}
