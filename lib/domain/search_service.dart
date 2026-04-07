import '../api/client.dart';
import '../models/keyword.dart';

class SearchService {
  final ApiClient apiClient;
  String? currentQuestion;
  String? currentAnswer;
  List<Keyword> explainedKeywords = [];

  SearchService({required this.apiClient});

  /// 搜索问题，返回带标注的答案
  Future<String> searchQuestion(String question) async {
    currentQuestion = question;
    explainedKeywords.clear();
    final response = await apiClient.search(question);
    currentAnswer = response.answer;
    // 预添加关键词到列表，explanation 为空
    for (final keyword in response.keywords) {
      explainedKeywords.add(Keyword(text: keyword));
    }
    return response.answer;
  }

  /// 解释关键词
  Future<String> explainKeyword(Keyword keyword) async {
    final explanation = await apiClient.explain(keyword.text);
    final index = explainedKeywords.indexWhere((k) => k.text == keyword.text);
    if (index >= 0) {
      explainedKeywords[index] = explainedKeywords[index].copyWith(explanation: explanation);
    } else {
      explainedKeywords.add(Keyword(text: keyword.text, explanation: explanation, isCustom: keyword.isCustom));
    }
    return explanation;
  }

  /// 解释用户自定义关键词，支持用户添加标注说明
  Future<String> explainCustomKeyword(String text, String userNote) async {
    final explanation = await apiClient.explainCustom(text, userNote);
    final keyword = Keyword(text: text, explanation: explanation, isCustom: true);
    explainedKeywords.add(keyword);
    return explanation;
  }

  /// 生成学习文档
  Future<GenerateDocumentResult> generateDocument() async {
    if (currentQuestion == null) {
      throw Exception('No current question');
    }
    final result = await apiClient.generateDocument(
      currentQuestion!,
      explainedKeywords.where((k) => k.explanation != null).toList(),
    );
    return GenerateDocumentResult(
      markdown: result.markdown,
      mindmap: result.mindmap,
    );
  }

  // 导出功能现在在DocumentView直接处理，不需要这个方法
  // Future<String?> exportDocument(String documentId, String format) async {
  //   final result = await apiClient.exportDocument(documentId, format);
  //   return result.downloadUrl ?? result.content;
  // }
}

class GenerateDocumentResult {
  final String markdown;
  final String mindmap;

  GenerateDocumentResult({
    required this.markdown,
    required this.mindmap,
  });
}
