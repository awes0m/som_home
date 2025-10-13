class UrlValidator {
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String ensureHttps(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  static String? getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  static String getFaviconUrl(String url) {
    final domain = getDomain(url);
    if (domain != null) {
      return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
    }
    return '';
  }
}