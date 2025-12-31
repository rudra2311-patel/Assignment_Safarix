import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app map viewer for OpenStreetMap
class MapViewerScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeName;

  const MapViewerScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });

  @override
  State<MapViewerScreen> createState() => _MapViewerScreenState();
}

class _MapViewerScreenState extends State<MapViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Create WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://www.openstreetmap.org/?mlat=${widget.latitude}&mlon=${widget.longitude}#map=16/${widget.latitude}/${widget.longitude}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.placeName),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange.shade600),
                  SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        ],
      ),
      // Quick action buttons at bottom
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom in
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_in',
            backgroundColor: Colors.white,
            foregroundColor: Colors.orange.shade600,
            onPressed: () {
              _controller.runJavaScript(
                'document.querySelector(".leaflet-control-zoom-in").click();',
              );
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 8),
          // Zoom out
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_out',
            backgroundColor: Colors.white,
            foregroundColor: Colors.orange.shade600,
            onPressed: () {
              _controller.runJavaScript(
                'document.querySelector(".leaflet-control-zoom-out").click();',
              );
            },
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
