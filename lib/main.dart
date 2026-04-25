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
  String? _selectedKeyword;

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

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _doSearch() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _explanations.clear();
      _selectedKeyword = null;
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
    setState(() {
      _selectedKeyword = keyword;
    });

    if (!_explanations.containsKey(keyword)) {
      setState(() => _isLoading = true);
      try {
        final explanation =
            await _searchService.explainKeyword(Keyword(text: keyword));
        setState(() {
          _explanations[keyword] = explanation;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('获取解释失败: $e')),
          );
        }
      }
    }
  }

  String _getBriefExplanation(String explanation) {
    final lines = explanation.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
        return trimmed.length > 60
            ? '${trimmed.substring(0, 60)}...'
            : trimmed;
      }
    }
    return '点击查看详细解释';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成文档失败: $e')),
        );
      }
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
      _selectedKeyword = null;
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
      body: _currentMode == AppMode.search
          ? _buildSearchMode()
          : _buildLearningMode(),
    );
  }

  Widget _buildSearchMode() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 无搜索结果时，显示居中搜索界面
    if (_currentAnswer == null) {
      return _buildWelcomeScreen();
    }

    // 有搜索结果时，左右分栏布局
    return Column(
      children: [
        Expanded(
          child: _buildResultLayout(),
        ),
        _buildBottomSearchBar(),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '递进式学习搜索',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            if (_isMockMode)
              const Text(
                '演示模式 · 输入 "openclaw是什么" 查看示例',
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _doSearch(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _isLoading ? null : _doSearch,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('搜索'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultLayout() {
    return Row(
      children: [
        // 左侧：答案区域（70%）
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('核心答案',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('添加选中词'),
                      onPressed: _addSelectedKeyword,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 点击蓝色关键词查看解释，或划选词语后点击添加',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: SingleChildScrollView(
                      child: KeywordText(
                        text: _currentAnswer!,
                        keywords: _currentKeywords,
                        onKeywordTap: _onKeywordTap,
                        onCustomSelection: (text) {
                          setState(() {
                            if (!_currentKeywords.contains(text)) {
                              _currentKeywords.add(text);
                            }
                          });
                          _onKeywordTap(text);
                        },
                      ),
                    ),
                  ),
                ),
                if (_explanations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _generateDocument,
                      child: const Text('生成完整学习文档'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 右侧：关键词解释列表（30%）
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(left: BorderSide(color: Colors.blue[200]!, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('关键词解释',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: _currentKeywords.isEmpty
                      ? const Center(
                          child: Text('暂无关键词', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: _currentKeywords.length,
                          itemBuilder: (context, index) {
                            final keyword = _currentKeywords[index];
                            final isSelected = _selectedKeyword == keyword;
                            final hasExplanation = _explanations.containsKey(keyword);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[100] : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  keyword,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                subtitle: hasExplanation
                                    ? Text(
                                        _getBriefExplanation(_explanations[keyword]!),
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text('点击获取解释',
                                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                                trailing: hasExplanation
                                    ? const Icon(Icons.expand_more, size: 20)
                                    : const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _onKeywordTap(keyword),
                              ),
                            );
                          },
                        ),
                ),
                // 详细解释区域
                if (_selectedKeyword != null && _explanations.containsKey(_selectedKeyword!))
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_selectedKeyword!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => _selectedKeyword = null),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            child: MarkdownBody(
                              data: _explanations[_selectedKeyword!]!,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(fontSize: 13),
                                h1: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                h2: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
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
      ],
    );
  }

  Widget _buildBottomSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: '继续搜索其他问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: _isLoading ? null : _doSearch,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('搜索'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _resetSearch,
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningMode() {
    if (_documentMarkdown == null || _documentMindmap == null) {
      return const Center(child: Text('请先在搜索模式搜索并生成文档'));
    }
    return DocumentView(
      markdown: _documentMarkdown!,
      mindmap: _documentMindmap!,
      apiClient: _apiClient,
      onCustomSelection: (text) {
        setState(() {
          if (!_currentKeywords.contains(text)) {
            _currentKeywords.add(text);
          }
        });
        _onKeywordTap(text);
      },
    );
  }
}