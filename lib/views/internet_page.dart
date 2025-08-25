import 'package:flutter/material.dart';
import 'internet/backup_screen.dart';
import 'internet/ptr_screen.dart';
import 'internet/netspeed_screen.dart';
import 'internet/dns_screen.dart';
import 'internet/thumbnail_screen.dart';
import 'internet/image_screen.dart';

// 定义一个数据类来承载每个功能项的信息
class _FunctionItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination; // 要跳转的目标页面

  _FunctionItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}

class InternetPage extends StatelessWidget {
  const InternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. 将功能项定义为数据列表
    final List<_FunctionItemData> functionItems = [
      _FunctionItemData(
        icon: Icons.image_search_rounded,
        title: '以图搜图',
        subtitle: '寻找图片的出处',
        destination: const ImageSearchScreen(),
      ),
      _FunctionItemData(
        icon: Icons.video_library_rounded,
        title: '视频封面搜图',
        subtitle: 'B站视频封面溯源',
        destination: const ThumbnailSearchScreen(),
      ),
      _FunctionItemData(
        icon: Icons.download_for_offline_rounded,
        title: '视频备份',
        subtitle: 'B站视频离线备份',
        destination: const BackupScreen(),
      ),
      _FunctionItemData(
        icon: Icons.speed_rounded,
        title: '网速测试',
        subtitle: '网络下载速度测试',
        destination: const SpeedTestScreen(),
      ),
      _FunctionItemData(
        icon: Icons.dns_rounded,
        title: 'DNS 查询',
        subtitle: '加密DNS查询测试',
        destination: const DNSScreen(),
      ),
      _FunctionItemData(
        icon: Icons.public_rounded,
        title: 'IP反查域名',
        subtitle: 'DoH PTR查询测试',
        destination: const PTRScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('在线工具', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.colorScheme.surfaceVariant,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '需要联网', Icons.wifi_rounded),
            const SizedBox(height: 20),
            // 2. 使用 GridView.builder 构建网格布局
            GridView.builder(
              shrinkWrap: true, // 重要：在SingleChildScrollView中需要
              physics: const NeverScrollableScrollPhysics(), // 禁用GridView自身的滚动
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 每行显示两个
                crossAxisSpacing: 16, // 水平间距
                mainAxisSpacing: 16, // 垂直间距
                childAspectRatio: 1.1, // 卡片的宽高比
              ),
              itemCount: functionItems.length,
              itemBuilder: (context, index) {
                final item = functionItems[index];
                return _buildGridItem(
                  context,
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item.destination),
                    );
                  },
                );
              },
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

  // 3. 为网格布局重新设计的卡片样式
  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // 确保InkWell的水波纹效果在圆角内
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 36, color: theme.colorScheme.primary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}