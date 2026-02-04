import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WebViewPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.title});
  final String title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;
  final TextEditingController _textEditingController =
      TextEditingController(text: 'ReplaceWithAngularApplicationURL');

  final String _defaultUrl = 'ReplaceWithAngularApplicationURL';

  @override 
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _textEditingController.text = url,
          onPageFinished: (url) => _textEditingController.text = url,
        ),
      )
      ..loadRequest(Uri.parse(_defaultUrl));

    // Platform-specific setup
    if (Platform.isAndroid) {
      final androidController =
          _webViewController.platform as AndroidWebViewController;

      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Enable WebView debugging in debug mode
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }

      // Optional: clear cookies
      WebViewCookieManager().clearCookies();
    }
  }

  void _loadUrl(String url) {
    if (!url.startsWith('http')) url = 'https://$url';
    _webViewController.loadRequest(Uri.parse(url));
  }

  Future<void> _handleRefresh() async {
    _textEditingController.text = _defaultUrl;
    _webViewController.loadRequest(Uri.parse(_defaultUrl));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Handle Android back button
  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false; // prevent app from closing
    }
    return true; // allow app to close
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // intercept back button
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textEditingController,
                  textInputAction: TextInputAction.go,
                  onFieldSubmitted: (_) => _loadUrl(_textEditingController.text),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter URL',
                  ),
                ),
              ),
              IconButton(onPressed: _handleRefresh, icon:Icon(Icons.home))
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: WebViewWidget(controller: _webViewController),
        ),
      ),
    );
  }
}
