import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart';
import 'api/client.dart';
import 'api/api_config.dart';
import 'api/config_loader.dart';
import 'domain/search_service.dart';
import 'models/keyword.dart';
import 'widgets/keyword_text.dart';
import 'widgets/document_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.getBaseUrl();
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
  search,
  learning,
}

class _HomePageState extends State<HomePage> {
  AppMode _currentMode = AppMode.search;
  final TextEditingController _questionController = TextEditingController();

  late ApiClient _apiClient;
  late SearchService _searchService;

  bool _isLoading = false;
  bool _isMockMode = true;
  String? _currentAnswer;
  List<String> _currentKeywords = [];
  Map<String, String> _explanations = {};
  String? _documentMarkdown;
  String? _documentMindmap;
  String? _configuredApiUrl;

  @override
  void initState() {
    super.initState();
    _initializeApiClient();
  }

  Future<void> _initializeApiClient() async {
    _apiClient = await ApiClient.create();
    _searchService = SearchService(apiClient: _apiClient);
    _isMockMode = _apiClient.isMockMode();

    if (!_isMockMode) {
      _configuredApiUrl = await ApiConfig.getBaseUrl();
    }

    setState(() {});
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
      _showExplanationDialog(keyword, _explanations[keyword]!);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final explanation =
          await _searchService.explainKeyword(Keyword(text: keyword));
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

  Future<void> _onCustomSelection(String keyword) async {
    final TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义标注说明'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: '标注说明（可选）',
            hintText: '比如："我想了解它在工程实践中的应用"',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _doExplainCustom(keyword, noteController.text.trim());
            },
            child: const Text('获取解释'),
          ),
        ],
      ),
    );
  }

  Future<void> _doExplainCustom(String keyword, String userNote) async {
    if (_explanations.containsKey(keyword)) {
      _showExplanationDialog(keyword, _explanations[keyword]!);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final explanation =
          await _searchService.explainCustomKeyword(keyword, userNote);
      setState(() {
        _explanations[keyword] = explanation;
        _currentKeywords = _searchService.explainedKeywords
            .where((k) => k.explanation == null)
            .map((k) => k.text)
            .toList();
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

  void _showSettingsDialog() {
    final TextEditingController urlController = TextEditingController(
      text: _configuredApiUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API 配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前模式: ${_isMockMode ? "Mock 模拟" : "真实 API"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '后端 API 地址',
                hintText: 'http://your-server:8081',
              ),
            ),
            if (!kIsWeb)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '配置将保存到 api_config.json 文件',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              Navigator.pop(context);

              if (!kIsWeb && newUrl.isNotEmpty) {
                await ConfigLoader.saveApiUrl(newUrl);
              }

              ApiConfig.setUiConfiguredUrl(newUrl);
              await _initializeApiClient();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          newUrl.isEmpty ? '已切换到 Mock 模式' : 'API 地址已更新')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
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
        title: Row(
          children: [
            const Text('递进式学习搜索'),
            if (_isMockMode)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Mock', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API 配置',
            onPressed: _showSettingsDialog,
          ),
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
              const Text(
                '递进式学习搜索',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (_isMockMode)
                const Text(
                  '演示模式 · 输入 "openclaw是什么" 查看完整示例',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 40),
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
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
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
                      child:
                          const Text('清空', style: TextStyle(fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              if (_currentAnswer != null)
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
                        onCustomSelection: _onCustomSelection,
                      ),
                      if (_explanations.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _isLoading ? null : _generateDocument,
                              child: const Text('生成完整学习文档'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
      onCustomSelection: _onCustomSelection,
    );
  }
}