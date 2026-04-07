import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'api/client.dart';
import 'domain/search_service.dart';
import 'models/keyword.dart';
import 'widgets/keyword_text.dart';
import 'widgets/document_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '递进式学习搜索',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum AppMode {
  search, // 搜索模式
  learning, // 学习模式
}

class _HomePageState extends State<HomePage> {
  AppMode _currentMode = AppMode.search;
  final TextEditingController _questionController = TextEditingController();

  // API 配置 - 开发环境默认本地
  final ApiClient _apiClient = ApiClient(baseUrl: 'http://localhost:8081');
  late final SearchService _searchService;

  bool _isLoading = false;
  String? _currentAnswer;
  List<String> _currentKeywords = [];
  Map<String, String> _explanations = {};
  String? _documentMarkdown;
  String? _documentMindmap;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService(apiClient: _apiClient);
  }

  Future<void> _doSearch() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _explanations.clear();
    });

    try {
      final answer = await _searchService.searchQuestion(question);
      setState(() {
        _currentAnswer = answer;
        _currentKeywords = _searchService.explainedKeywords
            .where((k) => k.explanation == null)
            .map((k) => k.text)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentAnswer = '搜索出错: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onKeywordTap(String keyword) async {
    if (_explanations.containsKey(keyword)) {
      // 已经解释过了，显示弹窗
      _showExplanationDialog(keyword, _explanations[keyword]!);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final explanation = await _searchService
          .explainKeyword(Keyword(text: keyword));
      setState(() {
        _explanations[keyword] = explanation;
        _isLoading = false;
      });
      _showExplanationDialog(keyword, explanation);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取解释失败: $e')),
        );
      }
    }
  }

  void _showExplanationDialog(String keyword, String explanation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(keyword),
        content: SingleChildScrollView(
          child: MarkdownBody(data: explanation),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateDocument() async {
    if (_searchService.currentQuestion == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _searchService.generateDocument();
      setState(() {
        _documentMarkdown = result.markdown;
        _documentMindmap = result.mindmap;
        _currentMode = AppMode.learning;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成文档失败: $e')),
        );
      }
    }
  }

  void _switchMode(AppMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  void _resetSearch() {
    setState(() {
      _currentAnswer = null;
      _currentKeywords.clear();
      _explanations.clear();
      _documentMarkdown = null;
      _documentMindmap = null;
      _currentMode = AppMode.search;
    });
    _questionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('递进式学习搜索'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentMode == AppMode.learning)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '重新搜索',
              onPressed: _resetSearch,
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentMode == AppMode.search ? 0 : 1,
        onDestinationSelected: (index) {
          _switchMode(index == 0 ? AppMode.search : AppMode.learning);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: '学习',
          ),
        ],
      ),
      body: _currentMode == AppMode.search
          ? _buildSearchMode()
          : _buildLearningMode(),
    );
  }

  Widget _buildSearchMode() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Title - Google style
              const Text(
                '递进式学习搜索',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              // Search box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    hintText: '输入你想学习的问题...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _doSearch(),
                ),
              ),
              const SizedBox(height: 32),
              // Search button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _doSearch,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('搜索', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  if (_currentAnswer != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _resetSearch,
                      child: const Text('清空', style: TextStyle(fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              // Search results
              if (_currentAnswer != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '核心答案',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      KeywordText(
                        text: _currentAnswer!,
                        keywords: _currentKeywords,
                        onKeywordTap: _onKeywordTap,
                      ),
                      if (_explanations.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading ? null : _generateDocument,
                            child: const Text('生成完整学习文档'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningMode() {
    if (_documentMarkdown == null || _documentMindmap == null) {
      return const Center(
        child: Text('请先在搜索模式搜索并生成文档'),
      );
    }
    return DocumentView(
      markdown: _documentMarkdown!,
      mindmap: _documentMindmap!,
      apiClient: _apiClient,
    );
  }
}
