class EnvVars {
  static const apiKey=String.fromEnvironment('APIKEY', defaultValue: '');
  static const spaceName=String.fromEnvironment('SPACE', defaultValue: '');
}