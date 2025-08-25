import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/service/internet/video_download.dart';
import '/service/intranet/qrcode.dart';
import '/service/internet/image_search.dart';
import '/service/intranet/ocr.dart';
import '/widgets/popup_infinity.dart';
import 'intranet/ocr_screen.dart'; // 假设这个导入是正确的
import '/service/internet/thumbnail_search.dart';
import '/widgets/popup_links.dart';
import '/widgets/popup_text.dart';

class ShareReceiverPage extends StatefulWidget {
  final SharedMedia media;

  const ShareReceiverPage({super.key, required this.media});

  @override
  State<ShareReceiverPage> createState() => _ShareReceiverPageState();
}

class _ShareReceiverPageState extends State<ShareReceiverPage> {
  late TextEditingController _workerUrlController;
  String _workerUrl = 'https://image.4evergr8.workers.dev'; // 默认 Worker URL

  @override
  void initState() {
    super.initState();
    _workerUrlController = TextEditingController(text: _workerUrl);
  }

  @override
  void dispose() {
    _workerUrlController.dispose();
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
        child: widget.media.content != null
            ? _buildTextSharedView(context)
            : _buildImageSharedView(context),
      ),
    );
  }

  // 构建接收到文本时的视图
  Widget _buildTextSharedView(BuildContext context) {
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
                  widget.media.content!,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, '可用操作', Icons.settings_rounded),
        const SizedBox(height: 12),
        _buildTextActionButtons(context),
      ],
    );
  }

  // 构建文本操作按钮
  Widget _buildTextActionButtons(BuildContext context) {
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
                if (widget.media.content != null) {
                  final links = await extractAndSearchUrls(widget.media.content!);
                  showLinkButtonsPopup(context, links);
                }
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('视频备份'),
              subtitle: const Text('提取B站视频并进行备份'),
              onTap: () async {
                if (widget.media.content != null) {
                  DialogUtils.showLoadingDialog(
                    context: context,
                    title: '下载中...',
                    content: '请稍候，正在备份视频...',
                  );
                  try {
                    String BV = await extractBvId(widget.media.content!);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final ua = prefs.getString('ua') ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
                    await fetchAndSaveVideo(context, ua, BV);
                  } finally {
                     if (mounted) Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// 构建接收到图片时的视图
Widget _buildImageSharedView(BuildContext context) {
  final attachment = widget.media.attachments?.firstWhere(
          (att) => att?.type == SharedAttachmentType.image,
      orElse: () => null);

  if (attachment == null || attachment.path == null) {
    return const Center(child: Text("未找到分享的图片。"));
  }

  final path = attachment.path;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // 图片预览
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          height: 250,
        ),
      ),
      const SizedBox(height: 24),

      // Worker URL 设置
      _buildSettingCard(
        context: context, // <--- 这里已经修正
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
      _buildImageActionList(context, path),
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