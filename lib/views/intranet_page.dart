import 'package:flutter/material.dart';
// import 'internet/url_decode.dart'; // 已不再需要，可以删除此行
import 'intranet/avbv.dart';
// import 'intranet/base64.dart'; // 已不再需要，可以删除此行
import 'intranet/garbled_screen.dart';
import 'intranet/ocr_screen.dart';
import 'intranet/qrcode.dart';
import 'intranet/address_screen.dart';

// 定义一个数据类来承载每个功能项的信息
class _FunctionItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  _FunctionItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}

class IntranetPage extends StatelessWidget {
  const IntranetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 将所有功能项定义为一个数据列表，方便管理
    final List<_FunctionItemData> functionItems = [
      // === 下面两项已被删除 ===
      // _FunctionItemData(
      //   icon: Icons.transform_rounded,
      //   title: 'URL 解码',
      //   subtitle: 'URL 编码与解码',
      //   destination: const URLDecode(),
      // ),
      // _FunctionItemData(
      //   icon: Icons.code_rounded,
      //   title: 'Base64 编解码',
      //   subtitle: 'Base64 编码与解码',
      //   destination: const EncodeDecode(),
      // ),
      // === 删除结束 ===
      _FunctionItemData(
        icon: Icons.qr_code_scanner_rounded,
        title: '图片扫码',
        subtitle: '识别图片中的二维码',
        destination: const QRCodeScan(),
      ),
      _FunctionItemData(
        icon: Icons.psychology_alt_rounded,
        title: '乱码恢复',
        subtitle: '恢复错误的文本编码',
        destination: const GarbledRecovery(),
      ),
      _FunctionItemData(
        icon: Icons.swap_horiz_rounded,
        title: 'AV/BV 互转',
        subtitle: 'B站视频号转换',
        destination: const AVBV(),
      ),
      _FunctionItemData(
        icon: Icons.lan_rounded,
        title: '局域网扫描',
        subtitle: '扫描局域网内的设备',
        destination: const AddressScreen(),
      ),
      _FunctionItemData(
        icon: Icons.document_scanner_rounded,
        title: '离线 OCR',
        subtitle: '从图片中提取文字',
        destination: const OfflineOCRScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('离线工具', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.colorScheme.surfaceVariant,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '无需联网', Icons.cloud_off_rounded),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
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

  // ... _buildSectionTitle 和 _buildGridItem 方法保持不变 ...

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

  // 为网格布局设计的卡片样式
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
      clipBehavior: Clip.antiAlias,
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