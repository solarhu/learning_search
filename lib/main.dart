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
import 'dart:html' if (dart.library.io) 'api/stub_html.dart' as html;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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

enum AppMode { search, learning }

class _HomePageState extends State<HomePage> {
  AppMode _currentMode = AppMode.search;
  final TextEditingController _questionController = TextEditingController();

  late ApiClient _apiClient;
  late SearchService _searchService;

  bool _isLoading = false;
  bool _isInitializing = true;
  bool _isMockMode = true;
  String? _currentAnswer;
  List<String> _currentKeywords = [];
  Map<String, String> _explanations = {};
  String? _documentMarkdown;
  String? _documentMindmap;
  String? _configuredApiUrl;
  String? _expandedKeyword;

  @override
  void initState() {
    super.initState();
    _initializeApiClient();
  }

  Future<void> _initializeApiClient() async {
    _apiClient = await ApiClient.create();
    _searchService = SearchService(apiClient: _apiClient);
    _isMockMode = _apiClient.isMockMode();
    if (!_isMockMode) _configuredApiUrl = await ApiConfig.getBaseUrl();
    setState(() => _isInitializing = false);
  }

  Future<void> _doSearch() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _explanations.clear();
      _expandedKeyword = null;
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
    if (!_explanations.containsKey(keyword)) {
      setState(() => _isLoading = true);
      try {
        final explanation =
            await _searchService.explainKeyword(Keyword(text: keyword));
        setState(() {
          _explanations[keyword] = explanation;
          _expandedKeyword = keyword;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取解释失败: $e')),
        );
      }
    } else {
      setState(() {
        _expandedKeyword = _expandedKeyword == keyword ? null : keyword;
      });
    }
  }

  String _getBriefExplanation(String explanation) {
    final lines = explanation.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
        return trimmed.length > 80
            ? '${trimmed.substring(0, 80)}...'
            : trimmed;
      }
    }
    return '点击查看详情';
  }

  void _addSelectedKeyword() {
    if (!kIsWeb) {
      _showAddKeywordDialog();
      return;
    }

    try {
      final selection = html.window.getSelection();
      if (selection != null && selection.toString().trim().length > 0) {
        final selectedText = selection.toString().trim();
        setState(() {
          if (!_currentKeywords.contains(selectedText)) {
            _currentKeywords.add(selectedText);
          }
        });
        _onKeywordTap(selectedText);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在答案中划选词语')),
        );
      }
    } catch (e) {
      _showAddKeywordDialog();
    }
  }

  void _showAddKeywordDialog() {
    final TextEditingController keywordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加关键词'),
        content: TextField(
          controller: keywordController,
          decoration: const InputDecoration(
            hintText: '输入关键词',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final keyword = keywordController.text.trim();
              if (keyword.isNotEmpty) {
                Navigator.pop(context);
                setState(() {
                  if (!_currentKeywords.contains(keyword)) {
                    _currentKeywords.add(keyword);
                  }
                });
                _onKeywordTap(keyword);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateDocument() async {
    if (_searchService.currentQuestion == null) return;
    setState(() => _isLoading = true);

    try {
      final result = await _searchService.generateDocument();
      setState(() {
        _documentMarkdown = result.markdown;
        _documentMindmap = result.mindmap;
        _currentMode = AppMode.learning;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成文档失败: $e')),
      );
    }
  }

  void _resetSearch() {
    setState(() {
      _currentAnswer = null;
      _currentKeywords.clear();
      _explanations.clear();
      _documentMarkdown = null;
      _documentMindmap = null;
      _currentMode = AppMode.search;
      _expandedKeyword = null;
    });
    _questionController.clear();
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
          children: [
            Text('当前模式: ${_isMockMode ? "Mock" : "真实API"}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '后端 API 地址',
                hintText: 'http://your-server:8081',
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
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('递进式学习',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
            if (_isMockMode)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('演示', style: TextStyle(fontSize: 12, color: Colors.orange[700])),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: _showSettingsDialog,
          ),
          if (_currentMode == AppMode.learning)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black54),
              onPressed: _resetSearch,
            ),
        ],
      ),
      body: _currentMode == AppMode.search
          ? _buildSearchMode()
          : _buildLearningMode(),
    );
  }

  Widget _buildSearchMode() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 初始界面：搜索框居中显示
    if (_currentAnswer == null) {
      return _buildWelcomeView();
    }

    // 搜索后：左右布局 + 底部搜索框
    return Column(
      children: [
        Expanded(child: _buildResultView()),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories, size: 56, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                '递进式学习搜索',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text(
                '输入问题，逐层深入理解',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              if (_isMockMode)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '演示模式 · 输入 "openclaw是什么"',
                    style: TextStyle(fontSize: 13, color: Colors.blue[600]),
                  ),
                ),
              const SizedBox(height: 32),
              // 居中搜索框
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _questionController,
                        enableInteractiveSelection: true,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '输入你想学习的问题...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _doSearch(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: _isLoading ? null : _doSearch,
                          child: _isLoading
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('搜索', style: TextStyle(fontSize: 13)),
                        ),
                      ],
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

  Widget _buildResultView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 65, child: _buildAnswerPanel()),
          Expanded(flex: 35, child: _buildKeywordPanel()),
        ],
      );
    }

    return Column(
      children: [
        Expanded(flex: 6, child: _buildAnswerPanel()),
        Expanded(flex: 4, child: _buildKeywordPanel()),
      ],
    );
  }

  Widget _buildAnswerPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Text('核心答案', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: Icon(Icons.add, size: 18, color: Colors.blue[600]),
                label: Text('添加选中词', style: TextStyle(color: Colors.blue[600])),
                onPressed: _addSelectedKeyword,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SingleChildScrollView(
                child: KeywordText(
                  text: _currentAnswer!,
                  keywords: _currentKeywords,
                  onKeywordTap: _onKeywordTap,
                  onCustomSelection: (text) {
                    setState(() {
                      if (!_currentKeywords.contains(text)) _currentKeywords.add(text);
                    });
                    _onKeywordTap(text);
                  },
                ),
              ),
            ),
          ),
          if (_explanations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.description),
                  label: const Text('生成学习文档'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isLoading ? null : _generateDocument,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeywordPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text('关键词 (${_currentKeywords.length})',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green[700])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _currentKeywords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.label_outline, size: 32, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('暂无关键词', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _currentKeywords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final keyword = _currentKeywords[index];
                      final isExpanded = _expandedKeyword == keyword;
                      final hasExplanation = _explanations.containsKey(keyword);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isExpanded ? Colors.blue[50] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpanded ? Colors.blue[200]! : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              leading: Icon(
                                hasExplanation ? Icons.check_circle : Icons.panorama_fish_eye,
                                size: 20,
                                color: hasExplanation ? Colors.green[600] : Colors.grey[400],
                              ),
                              title: Text(keyword,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  )),
                              subtitle: hasExplanation
                                  ? Text(_getBriefExplanation(_explanations[keyword]!),
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  : Text('点击获取解释',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              trailing: Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              onTap: () => _onKeywordTap(keyword),
                            ),
                            if (isExpanded && hasExplanation)
                              Container(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: MarkdownBody(
                                    data: _explanations[keyword]!,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(fontSize: 13),
                                      h2: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.35,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _questionController,
                    enableInteractiveSelection: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '继续探索...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    maxLines: 2,
                    minLines: 1,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _isLoading ? null : _doSearch,
                child: _isLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_forward, size: 18),
              ),
              if (_currentAnswer != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: _resetSearch,
                    child: Text('清空', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
      return const Center(child: Text('请先搜索并生成文档'));
    }
    return DocumentView(
      markdown: _documentMarkdown!,
      mindmap: _documentMindmap!,
      apiClient: _apiClient,
      onCustomSelection: (text) {
        setState(() {
          if (!_currentKeywords.contains(text)) _currentKeywords.add(text);
        });
        _onKeywordTap(text);
      },
    );
  }
}