import 'package:flora_mobile_app/layouts/constants.dart';
import 'dart:developer' as developer;

class ImageHelper {
  /// Returns a proper full URL for an image
  /// Handles cases where the image URL:
  /// - already starts with http (external URL)
  /// - starts with / (relative path from API base)
  /// - is just a path (relative path from API base without leading slash)
  static String getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      developer.log('Empty image URL provided');
      return 'https://placehold.co/400x200?text=No+Image';
    }

    // Ako već imamo direktan URL na Azure Blob Storage,
    // zadržavamo ga kako je došao iz API-ja
    if (imageUrl.contains('florablobstorage.blob.core.windows.net')) {
      developer.log('Using direct blob storage URL: $imageUrl');
      return imageUrl;
    }

    // Za lokalne putanje
    if (imageUrl.startsWith('file://')) {
      developer.log('File URLs not supported in mobile apps: $imageUrl');
      return 'https://placehold.co/400x200?text=Local+File+Not+Supported';
    }

    // Za relativne URL-ove u odnosu na API
    String fullUrl;
    if (imageUrl.startsWith('http')) {
      // Već je puni URL, zadržavamo ga
      fullUrl = imageUrl;
    } else if (imageUrl.startsWith('/')) {
      // Počinje s /, pa samo dodamo baseUrl bez dodatnog /
      fullUrl = '$baseUrl$imageUrl';
    } else {
      // Inače dodajemo / između baseUrl i imageUrl
      fullUrl = '$baseUrl/$imageUrl';
    }

    developer.log('Original image URL: $imageUrl');
    developer.log('Full image URL: $fullUrl');

    return fullUrl;
  }

  // Helper method like the one in desktop BlogProvider
  static String? getValidImageUrl(List<String> urls) {
    // Filter empty URLs and take the first valid URL
    final validUrls = urls.where((url) => url.isNotEmpty).toList();
    if (validUrls.isEmpty) return null;

    // Use helper method to form full URL
    return getFullImageUrl(validUrls.first);
  }
}
