import 'dart:convert';

import 'package:yapi_to_model/model/jsonPropertyInfo.dart';

class ModelBuilder {
  String fileHeader = "import 'package:safemap/safemap.dart';\n\n";

  /// 解析JsonClassInfo，并生成类内容
  static String oneInterfaceContentFromClass(
    String className,
    Set<JsonPropertyInfo> props,
  ) {
    return oneInterfaceContentBuilder(
      className: className.firstToUp,
      property: props.map(
        (p) {
          return '\n  /** ${p.remark ?? p.propertyName} */ \n   ${p.propertyName} :${p.jsClassName},';
        },
      ).join('\n  '),
    );
  }

  /// 解析JsonClassInfo，并生成interface内容
  static String oneClassContentFromClass(
    String className,
    Set<JsonPropertyInfo> props,
  ) {
    // TODO:
    return oneClassContentBuilder(
      className: className.firstToUp,
      property: props.map(
        (p) {
          return '\n  /// ${p.remark ?? p.propertyName} \n  final ${p.className}? ${p.propertyName};';
        },
      ).join('\n  '),
      init: props.map(
        (p) {
          return 'this.${p.propertyName},';
        },
      ).join('\n    '),
      safeMapBuild: props.map(
        (p) {
          return "${p.propertyName}: safeMap['${p.jsonKey}'].${p.safeMapType},";
        },
      ).join('\n          '),
      jsonContent: props.map(
        (p) {
          return "'${p.jsonKey}': ${p.propertyName},";
        },
      ).join('\n        '),
    );
  }

  /// 生成类内容(TypeScript)
  static String oneInterfaceContentBuilder({
    String? className,
    String? property,
  }) =>
      """
interface $className {
  $property
}
""";

  /// 生成类内容
  static String oneClassContentBuilder({
    String? className,
    String? property,
    String? init,
    String? safeMapBuild,
    String? jsonContent,
  }) =>
      """
class $className {
  $property

  $className({
    $init
  });

  $className.fromJson(Map<String, dynamic> json) : this.fromSafeMap(SafeMap(json));

  $className.fromSafeMap(SafeMap safeMap)
      : this(
          $safeMapBuild
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        $jsonContent
      };

  @override
  String toString() {
    return json.encode(this);
  }
}
""";
}
