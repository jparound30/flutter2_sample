class EnvVars {
  static const apiKey=String.fromEnvironment('APIKEY', defaultValue: 'api_key');
  static const spaceName=String.fromEnvironment('SPACE', defaultValue: 'spacename');
}