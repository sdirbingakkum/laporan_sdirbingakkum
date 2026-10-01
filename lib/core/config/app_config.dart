class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  factory AppConfig.fromEnvironment() {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://ybepaqmrrgsaeqnqrsrf.supabase.co',
    );
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    return const AppConfig(
      supabaseUrl: url,
      supabasePublishableKey: key,
    );
  }

  final String? supabaseUrl;
  final String? supabasePublishableKey;

  bool get isConfigured =>
      supabaseUrl != null &&
      supabaseUrl!.trim().isNotEmpty &&
      supabasePublishableKey != null &&
      supabasePublishableKey!.trim().isNotEmpty;
}
