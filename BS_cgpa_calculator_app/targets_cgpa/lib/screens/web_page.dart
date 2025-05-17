import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package

class WebPage extends StatefulWidget {
  final String url;
  WebPage(this.url);

  @override
  State<WebPage> createState() => _WebPage();
}

class _WebPage extends State<WebPage> {
  late final WebViewController _controller;
  late String finalUrl;
  bool isLoading = true; // Track loading state
  bool isError = false; // Track error state
  bool isOffline = false; // Track if the device is offline

  @override
  void initState() {
    super.initState();
    finalUrl = widget.url.startsWith("http://")
        ? widget.url.replaceFirst("http://", "https://")
        : widget.url;

    // Check initial connectivity
    checkConnectivity();

    // Initialize the WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true; // Start loading
              isError = false; // Reset error state
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false; // Stop loading
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false; // Stop loading
              isError = true; // Show error message
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(finalUrl));
  }

  // Function to check connectivity
  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOffline = true; // Device is offline
        isLoading = false; // Hide loading
      });
    } else {
      setState(() {
        isOffline = false; // Device is online
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30),
        child: AppBar(
          title: Text("Web Page"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // WebView to load the URL
          WebViewWidget(controller: _controller),

          // Show loading indicator while WebView is loading
          if (isLoading && !isOffline)
            AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Show error message if webpage is not available
          // if (isError && !isOffline)
          //   AnimatedOpacity(
          //     opacity: isError ? 1.0 : 0.0,
          //     duration: Duration(milliseconds: 300),
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             "Webpage not available",
          //             style: TextStyle(
          //               fontSize: 18,
          //               color: Colors.red,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           SizedBox(height: 10),
          //           ElevatedButton(
          //             onPressed: () {
          //               setState(() {
          //                 isLoading = true;
          //                 isError = false;
          //               });
          //               _controller.loadRequest(Uri.parse(finalUrl)); // Retry loading
          //             },
          //             child: Text("Retry"),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),

          // Show offline message if the device is offline
          if (isOffline)
            AnimatedOpacity(
              opacity: isOffline ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No Internet Connection",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await checkConnectivity(); // Recheck connectivity
                        if (!isOffline) {
                          setState(() {
                            isLoading = true;
                            isError = false;
                          });
                          _controller.loadRequest(Uri.parse(finalUrl)); // Retry loading
                        }
                      },
                      child: Text("Retry"),
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