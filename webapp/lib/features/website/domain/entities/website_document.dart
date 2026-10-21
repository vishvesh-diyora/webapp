import 'package:equatable/equatable.dart';
import 'package:webapp/features/cloudflare/domain/entities/website_deployment_info.dart';

/// Unified website JSON model used by editor, preview, generator, and local storage.
class WebsiteDocument extends Equatable {
  const WebsiteDocument({
    required this.type,
    required this.templateType,
    required this.name,
    required this.subname,
    required this.description,
    this.logo = '',
    required this.data,
    this.id,
    this.userId,
    this.updatedAt,
    this.deployment,
  });

  final String? id;
  final String? userId;
  final int type;
  final int templateType;
  final String name;
  final String subname;
  final String description;
  final String logo;
  final List<WebsiteContentBlock> data;
  final DateTime? updatedAt;
  final WebsiteDeploymentInfo? deployment;

  factory WebsiteDocument.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return WebsiteDocument(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      type: (json['type'] as num?)?.toInt() ?? 0,
      templateType: (json['templateType'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      subname: json['subname'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(WebsiteContentBlock.fromJson)
              .toList()
          : const [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      deployment: json['deployment'] != null
          ? WebsiteDeploymentInfo.fromJson(
              Map<String, dynamic>.from(json['deployment'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'userId': userId,
        'type': type,
        'templateType': templateType,
        'name': name,
        'subname': subname,
        'description': description,
        'logo': logo,
        'data': data.map((block) => block.toJson()).toList(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        if (deployment != null) 'deployment': deployment!.toJson(),
      };

  /// JSON written to published `content.json` (no auth metadata).
  Map<String, dynamic> toPublishedJson() => {
        'type': type,
        'templateType': templateType,
        'name': name,
        'subname': subname,
        'description': description,
        'logo': logo,
        'data': data.map((block) => block.toJson()).toList(),
      };

  WebsiteDocument copyWith({
    String? id,
    String? userId,
    int? type,
    int? templateType,
    String? name,
    String? subname,
    String? description,
    String? logo,
    List<WebsiteContentBlock>? data,
    DateTime? updatedAt,
    WebsiteDeploymentInfo? deployment,
  }) {
    return WebsiteDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      templateType: templateType ?? this.templateType,
      name: name ?? this.name,
      subname: subname ?? this.subname,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      deployment: deployment ?? this.deployment,
    );
  }

  WebsiteContentBlock? blockByContentType(int contentType) {
    for (final block in data) {
      if (block.contentType == contentType) return block;
    }
    return null;
  }

  WebsiteDocument updateBlockContent(int contentType, Map<String, dynamic> contentData) {
    final updated = data.map((block) {
      if (block.contentType == contentType) {
        return block.copyWith(contentData: contentData);
      }
      return block;
    }).toList();
    return copyWith(data: updated);
  }

  WebsiteDocument updateBlockField(int contentType, String field, dynamic value) {
    final block = blockByContentType(contentType);
    if (block == null) return this;
    final next = Map<String, dynamic>.from(block.contentData)..[field] = value;
    return updateBlockContent(contentType, next);
  }

  WebsiteDocument updateListItem({
    required int contentType,
    required String listKey,
    required int index,
    required Map<String, dynamic> item,
  }) {
    final block = blockByContentType(contentType);
    if (block == null) return this;
    final list = List<Map<String, dynamic>>.from(
      (block.contentData[listKey] as List?)?.whereType<Map<String, dynamic>>() ?? const [],
    );
    if (index < 0 || index >= list.length) return this;
    list[index] = item;
    return updateBlockField(contentType, listKey, list);
  }

  WebsiteDocument addListItem({
    required int contentType,
    required String listKey,
    required Map<String, dynamic> item,
  }) {
    final block = blockByContentType(contentType);
    if (block == null) return this;
    final list = List<Map<String, dynamic>>.from(
      (block.contentData[listKey] as List?)?.whereType<Map<String, dynamic>>() ?? const [],
    )..add(item);
    return updateBlockField(contentType, listKey, list);
  }

  WebsiteDocument removeListItem({
    required int contentType,
    required String listKey,
    required int index,
  }) {
    final block = blockByContentType(contentType);
    if (block == null) return this;
    final list = List<Map<String, dynamic>>.from(
      (block.contentData[listKey] as List?)?.whereType<Map<String, dynamic>>() ?? const [],
    );
    if (index < 0 || index >= list.length) return this;
    list.removeAt(index);
    return updateBlockField(contentType, listKey, list);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        templateType,
        name,
        subname,
        description,
        logo,
        data,
        updatedAt,
        deployment,
      ];
}

class WebsiteContentBlock extends Equatable {
  const WebsiteContentBlock({
    required this.seqId,
    required this.contentType,
    required this.contentData,
  });

  final int seqId;
  final int contentType;
  final Map<String, dynamic> contentData;

  factory WebsiteContentBlock.fromJson(Map<String, dynamic> json) {
    return WebsiteContentBlock(
      seqId: (json['seqId'] as num?)?.toInt() ?? 0,
      contentType: (json['contentType'] as num?)?.toInt() ?? 0,
      contentData: Map<String, dynamic>.from(
        json['contentData'] as Map? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'seqId': seqId,
        'contentType': contentType,
        'contentData': contentData,
      };

  WebsiteContentBlock copyWith({
    int? seqId,
    int? contentType,
    Map<String, dynamic>? contentData,
  }) {
    return WebsiteContentBlock(
      seqId: seqId ?? this.seqId,
      contentType: contentType ?? this.contentType,
      contentData: contentData ?? this.contentData,
    );
  }

  @override
  List<Object?> get props => [seqId, contentType, contentData];
}
