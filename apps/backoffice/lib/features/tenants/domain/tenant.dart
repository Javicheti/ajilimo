enum TenantEnvironment { dev, prod }

extension TenantEnvironmentX on TenantEnvironment {
  String get label => switch (this) {
        TenantEnvironment.dev => 'Dev',
        TenantEnvironment.prod => 'Prod',
      };
}

class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.environment,
  });

  final String id;
  final String name;
  final String slug;
  final TenantEnvironment environment;

  String get secretNamespace => 'tenants/$slug';
}

const Map<String, String> _accentMap = <String, String>{
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
  'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u', 'Ü': 'u', 'Ñ': 'n',
};

/// Normaliza un nombre a slug estable (ids y namespace de secretos).
String slugify(String name) {
  final StringBuffer buffer = StringBuffer();
  for (final String char in name.split('')) {
    buffer.write(_accentMap[char] ?? char);
  }
  return buffer
      .toString()
      .toLowerCase()
      .trim()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
