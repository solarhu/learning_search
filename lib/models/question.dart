/// 用户提问模型
class Question {
  final String content;
  final DateTime createdAt;

  Question({
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
