import 'dart:io';

import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;       // from name_en
  final String? nameAr;    // from name_ar
  final String? description;    // from description_en
  final String? descriptionAr;  // from description_ar
  final String? imageUrl;  // from image.file_url
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // image is an object: { file_url: "...", ... }
    final imageObj = json['image'];
    String? imageUrl;
    if (imageObj is Map<String, dynamic>) {
      imageUrl = imageObj['file_url']?.toString();
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name_en']?.toString() ?? json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      description: json['description_en']?.toString() ??
          json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      imageUrl: imageUrl,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      productCount: 0, // not returned by list endpoint
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Request model for creating a new category.
class CreateCategoryRequest {
  final String name;
  final String? description;
  final File? image;

  const CreateCategoryRequest({
    required this.name,
    this.description,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_en': name,
      if (description != null && description!.isNotEmpty)
        'description_en': description,
    };
  }
}

/// Response model for paginated category list.
/// API shape: { success, message, data: [...], meta: { total, page, page_size } }
class CategoryListResponse {
  final List<CategoryModel> categories;
  final int total;
  final int page;
  final int pageSize;

  const CategoryListResponse({
    required this.categories,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return CategoryListResponse(
      categories: data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? data.length,
      page: meta['page'] as int? ?? 1,
      pageSize: meta['page_size'] as int? ?? 10,
    );
  }
}
