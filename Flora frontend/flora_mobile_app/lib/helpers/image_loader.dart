import 'package:flutter/material.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';

class ImageLoader {
  /// Univerzalna metoda za učitavanje slika koja radi i za Azure Blob Storage i za API
  static Widget loadImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    // Direktno vrati widget za prazne URL-ove
    if (url.isEmpty) {
      return _buildErrorWidget(width, height, errorWidget);
    }

    // Direktno vrati widget za nevalidne URL-ove (one koji ne počinju s http/https)
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return _buildErrorWidget(width, height, errorWidget);
    }

    // Provjeri je li Azure Blob Storage URL
    final bool isAzureBlobStorage = url.contains(
      'florablobstorage.blob.core.windows.net',
    );

    // Headeri za autentifikaciju - samo za API, ne za Azure Blob Storage
    final Map<String, String>? headers = isAzureBlobStorage
        ? null
        : AuthProvider.getHeaders();

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      headers: headers,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingWidget(width, height, loadingProgress, placeholder);
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image from URL: $url');
        print('Error details: $error');
        return _buildErrorWidget(width, height, errorWidget);
      },
    );
  }

  static Widget _buildLoadingWidget(
    double? width,
    double? height,
    ImageChunkEvent loadingProgress,
    Widget? placeholder,
  ) {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFFE91E63),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
  }

  static Widget _buildErrorWidget(
    double? width,
    double? height,
    Widget? errorWidget,
  ) {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            size: 30,
            color: Colors.grey,
          ),
        );
  }
}
