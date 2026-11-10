/// True only for absolute `http` / `https` URIs; guards external launches.
bool isHttpOrHttpsUrl(Uri? uri) {
  if (uri == null) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}
