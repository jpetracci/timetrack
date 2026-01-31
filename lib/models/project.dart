class Project {
  const Project({
    required this.id,
    required this.name,
    required this.tags,
    required this.createdAt,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final List<String> tags;
  final DateTime createdAt;
  final bool isArchived;

  Project copyWith({
    String? id,
    String? name,
    List<String>? tags,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
