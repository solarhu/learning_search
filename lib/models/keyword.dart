/// 关键词模型
class Keyword {
  final String text;
  final String? explanation;
  final bool isCustom; // 是否用户自定义标注
  final DateTime explainedAt;

  Keyword({
    required this.text,
    this.explanation,
    this.isCustom = false,
    DateTime? explainedAt,
  }) : explainedAt = explainedAt ?? DateTime.now();

  Keyword copyWith({
    String? text,
    String? explanation,
    bool? isCustom,
  }) {
    return Keyword(
      text: text ?? this.text,
      explanation: explanation ?? this.explanation,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': text,
      'explanation': explanation,
      'is_custom': isCustom,
    };
  }
}
