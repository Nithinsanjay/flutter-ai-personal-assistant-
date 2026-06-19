// Copyright 2025 Google LLC
// Flutter adaptation of Config.kt

enum ConfigEditorType {
  label,
  numberSlider,
  booleanSwitch,
  segmentedButton,
  bottomSheetSelector,
}

enum ValueType { intType, floatType, doubleType, stringType, booleanType }

class ConfigKey {
  final String id;
  final String label;
  const ConfigKey(this.id, this.label);
}

class Config {
  final ConfigEditorType type;
  final ConfigKey key;
  final dynamic defaultValue;
  final ValueType valueType;
  final bool needReinitialization;

  const Config({
    required this.type,
    required this.key,
    required this.defaultValue,
    required this.valueType,
    this.needReinitialization = true,
  });
}

class LabelConfig extends Config {
  LabelConfig(ConfigKey key, [String defaultValue = ''])
    : super(
        type: ConfigEditorType.label,
        key: key,
        defaultValue: defaultValue,
        valueType: ValueType.stringType,
      );
}

class NumberSliderConfig extends Config {
  final double sliderMin;
  final double sliderMax;

  NumberSliderConfig({
    required super.key,
    required this.sliderMin,
    required this.sliderMax,
    required super.defaultValue,
    required super.valueType,
    super.needReinitialization = true,
  }) : super(
         type: ConfigEditorType.numberSlider,
       );
}

class BooleanSwitchConfig extends Config {
  BooleanSwitchConfig({
    required super.key,
    required super.defaultValue,
    super.needReinitialization = true,
  }) : super(
         type: ConfigEditorType.booleanSwitch,
         valueType: ValueType.booleanType,
       );
}

class SegmentedButtonConfig extends Config {
  final List<String> options;
  final bool allowMultiple;

  SegmentedButtonConfig({
    required super.key,
    required super.defaultValue,
    required this.options,
    this.allowMultiple = false,
  }) : super(
         type: ConfigEditorType.segmentedButton,
         valueType: ValueType.stringType,
       );
}
