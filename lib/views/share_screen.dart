import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/service/internet/video_download.dart';
import '/service/intranet/qrcode.dart';
import '/service/internet/image_search.dart';
import '/service/intranet/ocr.dart';
import '/widgets/popup_infinity.dart';
import 'intranet/ocr_screen.dart';
import '/service/internet/thumbnail_search.dart';
import '/widgets/popup_links.dart';
import '/widgets/popup_text.dart';

class ShareReceiverPage extends StatefulWidget {
  const ShareReceiverPage({super.key});

  @override
  State<ShareReceiverPage> createState() => _ShareReceiverPageState();
}

class _ShareReceiverPageState extends State<ShareReceiverPage> {
  late StreamSubscription _intentDataStreamSubscription;
  late TextEditingController _workerUrlController;

  String? _sharedText;
  List<SharedMediaFile>? _sharedFiles;
  String _workerUrl = 'https://image.4evergr8.workers.dev'; // 默认 Worker URL

  @override
  void initState() {
    super.initState();
    _workerUrlController = TextEditingController(text: _workerUrl);
    _initializeSharingListener();
  }
  
  void _initializeSharingListener() {
    // 监听 App 在后台运行时收到的分享
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        _sharedText = null; // 清除文本，因为收到了文件
      });
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    _intentDataStreamSubscription.onDone(() {
      ReceiveSharingIntent.getTextStream().listen((String value) {
        setState(() {
          _sharedText = value;
          _sharedFiles = null; // 清除文件，因为收到了文本
        });
      }, onError: (err) {
        print("getTextStream error: $err");
      });
    });
    
    // 监听 App 启动时收到的分享
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFiles = value;
        });
      }
    });

    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        setState(() {
          _sharedText = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _workerUrlController.dispose();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  // 处理图片的OCR功能
  Future<void> handleImageOCR(BuildContext context, String imagePath, Language language) async {
    try {
      final recognizedText = await performOCR(File(imagePath), language);
      showTextPopup(context, recognizedText);
    } catch (e) {
      showTextPopup(context, 'OCR识别失败: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('分享内容处理', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.colorScheme.surfaceVariant,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  // 根据分享类型构建视图
  Widget _buildContent() {
    if (_sharedText != null) {
      return _buildTextSharedView(context, _sharedText!);
    } else if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
      // 我们只处理第一个分享的文件
      final firstFile = _sharedFiles!.first;
      // 检查文件类型是否为图片
      if (firstFile.type == SharedMediaType.IMAGE) {
        return _buildImageSharedView(context, firstFile.path);
      }
    }
    // 如果没有分享内容或类型不支持，显示加载或提示信息
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("等待分享内容..."),
        ],
      ),
    );
  }

  // 构建接收到文本时的视图
  Widget _buildTextSharedView(BuildContext context, String sharedText) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, '接收到的文本', Icons.text_fields_rounded),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SelectableText(
                  sharedText,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '可用操作', Icons.settings_rounded),
        const SizedBox(height: 12),
        _buildTextActionButtons(context, sharedText),
      ],
    );
  }

  // 构建文本操作按钮
  Widget _buildTextActionButtons(BuildContext context, String sharedText) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('封面搜图'),
              subtitle: const Text('提取链接并搜索封面'),
              onTap: () async {
                final links = await extractAndSearchUrls(sharedText);
                showLinkButtonsPopup(context, links);
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('视频备份'),
              subtitle: const Text('提取B站视频并进行备份'),
              onTap: () async {
                DialogUtils.showLoadingDialog(
                  context: context,
                  title: '下载中...',
                  content: '请稍候，正在备份视频...',
                );
                try {
                  String BV = await extractBvId(sharedText);
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  final ua = prefs.getString('ua') ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
                  await fetchAndSaveVideo(context, ua, BV);
                } finally {
                   if (mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 构建接收到图片时的视图
  Widget _buildImageSharedView(BuildContext context, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 图片预览
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            height: 250,
          ),
        ),
        const SizedBox(height: 24),

        // Worker URL 设置
        _buildSettingCard(
          context: context,
          icon: Icons.cloud_upload_rounded,
          title: '图片上传服务',
          child: TextField(
            controller: _workerUrlController,
            onChanged: (value) => setState(() => _workerUrl = value),
            decoration: const InputDecoration(
              labelText: 'Worker URL',
              hintText: '请输入用于上传的 Worker 地址',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle(context, '可用操作', Icons.settings_rounded),
        const SizedBox(height: 12),
        
        // 操作列表
        _buildImageActionList(context, imagePath),
      ],
    );
  }

  // 构建图片操作列表
  Widget _buildImageActionList(BuildContext context, String imagePath) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('搜索图片来源'),
              onTap: () async {
                DialogUtils.showLoadingDialog(
                  context: context,
                  title: '上传中...',
                  content: '请稍候，正在上传图片...',
                );
                try {
                  final imageUrl = await searchLocalImage(File(imagePath), _workerUrlController.text);
                   if (mounted) Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('图片上传成功，URL: $imageUrl')),
                  );
                  final result = generateReverseImageSearchUrls(imageUrl);
                  showLinkButtonsPopup(context, result);
                } catch (e) {
                   if (mounted) Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('图片上传失败: ${e.toString()}')),
                  );
                }
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded),
              title: const Text('图片扫码识别'),
              onTap: () async {
                final result = await scanQRCodeFromImage(context, imagePath);
                showTextPopup(context, result);
              },
            ),
            const Divider(indent: 16, endIndent: 16),
             ListTile(
              leading: const Icon(Icons.translate_rounded, color: Colors.blue),
              title: const Text('中文字符提取 (OCR)'),
              onTap: () => handleImageOCR(context, imagePath, Language.chinese),
            ),
             ListTile(
              leading: const Icon(Icons.abc_rounded, color: Colors.green),
              title: const Text('拉丁字符提取 (OCR)'),
              onTap: () => handleImageOCR(context, imagePath, Language.english),
            ),
             ListTile(
              leading: const Icon(Icons.language_rounded, color: Colors.red),
              title: const Text('日文字符提取 (OCR)'),
              onTap: () => handleImageOCR(context, imagePath, Language.japanese),
            ),
          ],
        ),
      ),
    );
  }

  // 统一的区域标题样式
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  // 统一的设置卡片样式
  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}