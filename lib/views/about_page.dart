import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // 辅助函数，用于安全地启动URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // 可以在这里添加一个提示，比如SnackBar
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的文本样式，方便复用
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // AppBar标题也使用项目名称
        title: const Text('关于翎雀百宝箱'),
        // 使用主题颜色，保持界面统一
        backgroundColor: colorScheme.surfaceVariant,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Section 1: 关于项目 ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关于翎雀百宝箱',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '翎雀百宝箱是一款集成了多种实用工具的移动应用，旨在为用户提供便捷、高效的解决方案。我们致力于不断打磨产品，为您带来最好的体验。',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Section 2: 技术栈 ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // 底部padding小一些以适应ListTile
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '技术实现',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '翎雀百宝箱基于 Flutter 框架开发，部分工具依赖于优秀的第三方开源库。',
                    style: textTheme.bodyLarge,
                  ),
                  const Divider(height: 20),
                  ListTile(
                    leading: Icon(Icons.description_outlined, color: colorScheme.secondary),
                    title: const Text('查看依赖清单'),
                    subtitle: const Text('完整的第三方开源库列表'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // TODO: 请将下面的URL替换成你的依赖文件在GitHub上的实际地址
                      _launchUrl('https://github.com/4evergr8/atoolbox/blob/main/pubspec.yaml');
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Section 3: 问题反馈 ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '问题反馈',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '如果您在使用过程中遇到问题或发现某些功能未按预期运行，我们非常欢迎您提出宝贵的意见。',
                    style: textTheme.bodyLarge,
                  ),
                  const Divider(height: 20),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: colorScheme.secondary),
                    title: const Text('提交问题与建议'),
                    subtitle: const Text('通过 GitHub Issues 页面反馈'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // TODO: 请将下面的URL替换成你的GitHub仓库Issues页面的实际地址
                      _launchUrl('https://github.com/4evergr8/atoolbox/issues');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}