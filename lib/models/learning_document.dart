/// 学习文档模型
class LearningDocument {
  final String id;
  final String question;
  final String markdown;
  final String mindmap; // Mermaid 代码
  final List<Keyword> keywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningDocument({
    required this.id,
    required this.question,
    required this.markdown,
    required this.mindmap,
    required this.keywords,
    required this.createdAt,
    required this.updatedAt,
  });

  LearningDocument copyWith({
    String? id,
    String? question,
    String? markdown,
    String? mindmap,
    List<Keyword>? keywords,
    DateTime? updatedAt,
  }) {
    return LearningDocument(
      id: id ?? this.id,
      question: question ?? this.question,
      markdown: markdown ?? this.markdown,
      mindmap: mindmap ?? this.mindmap,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
