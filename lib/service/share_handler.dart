import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '/views/share_screen.dart'; // 导入我们重构好的 ShareReceiverPage
// 假设您的主页是 HomePage
import 'views/home_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSharingListener();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  /// 初始化分享监听器
  void _initializeSharingListener() {
    // 监听 App 在后台运行时收到的分享
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        // 当收到分享时，直接跳转到 ShareReceiverPage
        _navigateToShareScreen();
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    _intentDataStreamSubscription.onDone(() {
        ReceiveSharingIntent.getTextStream().listen((String value) {
        if (value.isNotEmpty) {
          // 当收到分享时，直接跳转到 ShareReceiverPage
          _navigateToShareScreen();
        }
      }, onError: (err) {
        print("getTextStream error: $err");
      });
    });


    // 检查 App 启动时是否有分享内容
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _navigateToShareScreen();
      }
    });
     ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null && value.isNotEmpty) {
        _navigateToShareScreen();
      }
    });
  }

  /// 跳转到分享处理页面
  void _navigateToShareScreen() {
    // 使用全局的 navigatorKey 或者在当前 context 可用的情况下跳转
    // 这里我们假设 MaterialApp 使用了一个全局 key
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const ShareReceiverPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 设置一个全局key以便在任何地方跳转
      title: 'atoolbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), // 您的App主页
    );
  }
}

// 在文件顶部或一个单独的文件中定义全局的 navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();