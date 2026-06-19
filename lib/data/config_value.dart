// Flutter adaptation of ConfigValue.kt

sealed class ConfigValue {
  const ConfigValue();
}

class IntValue extends ConfigValue {
  final int value;
  const IntValue(this.value);
}

class FloatValue extends ConfigValue {
  final double value;
  const FloatValue(this.value);
}

class StringValue extends ConfigValue {
  final String value;
  const StringValue(this.value);
}

// Helper functions
int getIntConfigValue(ConfigValue? configValue, int defaultValue) {
  if (configValue == null) return defaultValue;
  if (configValue is IntValue) return configValue.value;
  if (configValue is FloatValue) return configValue.value.toInt();
  return defaultValue;
}

double getFloatConfigValue(ConfigValue? configValue, double defaultValue) {
  if (configValue == null) return defaultValue;
  if (configValue is IntValue) return configValue.value.toDouble();
  if (configValue is FloatValue) return configValue.value;
  return defaultValue;
}

String getStringConfigValue(ConfigValue? configValue, String defaultValue) {
  if (configValue == null) return defaultValue;
  if (configValue is IntValue) return configValue.value.toString();
  if (configValue is FloatValue) return configValue.value.toString();
  if (configValue is StringValue) return configValue.value;
  return defaultValue;
}
