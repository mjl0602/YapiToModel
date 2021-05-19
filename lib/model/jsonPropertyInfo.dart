enum JsonValueType {
  any,
  string,
  integer,
  boolean,
  float,
  list,
  map,
}

extension JsonValueTypeBuilder on JsonValueType {
  static fromValue(dynamic value) {
    if (value == null) return JsonValueType.any;
    if (value is bool) return JsonValueType.boolean;
    if (value is String) return JsonValueType.string;
    if (value is int) return JsonValueType.integer;
    if (value is double) return JsonValueType.float;
    if (value is List) return JsonValueType.list;
    if (value is Map) return JsonValueType.map;
  }

  static fromYapiName(String value) {
    if (value.contains('[]')) return JsonValueType.list;
    if (value == "boolean") return JsonValueType.boolean;
    if (value == "string") return JsonValueType.string;
    if (value == "integer") return JsonValueType.integer;
    if (value == "number") return JsonValueType.float;
    if (value == "object") return JsonValueType.map;
    return JsonValueType.any;
  }

  String get name {
    switch (this) {
      case JsonValueType.any:
        return 'dynamic';
      case JsonValueType.string:
        return 'String';
      case JsonValueType.integer:
        return 'int';
      case JsonValueType.float:
        return 'double';
      case JsonValueType.list:
        return 'List';
      case JsonValueType.map:
        return 'Map';
      case JsonValueType.boolean:
        return 'bool';
    }
  }

  String get safeMapGetterType {
    switch (this) {
      case JsonValueType.any:
        return 'value';
      case JsonValueType.string:
        return 'string';
      case JsonValueType.integer:
        return 'intValue';
      case JsonValueType.float:
        return 'doubleValue';
      case JsonValueType.list:
        return 'list';
      case JsonValueType.map:
        return 'map';
      case JsonValueType.boolean:
        return 'boolean';
    }
  }
}

/// 第一个转大写
extension FirstToUp on String {
  String get firstToUp => this.replaceRange(
        0,
        1,
        this.split('').first.toUpperCase(),
      );
}

/// js的单个属性
class JsonPropertyInfo {
  /// 属性的名称，不应当直接用于生成
  final String key;

  /// 属性的注释
  final String? remark;

  /// Json值的类型
  final JsonValueType valueType;

  // /// 范型T，不应当直接用于生成
  // String childT;

  bool get isMap => valueType == JsonValueType.map;
  bool get isList => valueType == JsonValueType.list;

  // 用于build的属性
  String get propertyName => key;
  String get jsonKey => key;

  String get safeMapType => valueType.safeMapGetterType;

  /// 开头大写的类名
  String get className {
    var name = valueType.name;
    if (isMap) {
      return key.firstToUp;
    }
    return name;
  }

  /// 开头大写的类名
  String get jsClassName {
    var name = valueType.name;
    if (name == 'int' || name == 'double') {
      return 'number';
    }
    return name.toLowerCase();
  }

  JsonPropertyInfo.type(this.key, this.valueType, this.remark);

  JsonPropertyInfo(
    this.key,
    dynamic value,
    this.remark,
  ) : valueType = JsonValueTypeBuilder.fromValue(value);

  @override
  String toString() {
    if (isMap) {
      return '<键:$key 类型:$key>';
    }
    return '<键:$key 类型:$valueType>';
  }

  @override
  int get hashCode => '$key:$valueType'.hashCode;

  operator ==(dynamic other) {
    return (other is JsonPropertyInfo) ? other.hashCode == hashCode : false;
  }
}
