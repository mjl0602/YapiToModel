import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:safemap/safemap.dart';
import 'package:tapped/tapped.dart';
import 'package:yapi_to_model/model/jsonPropertyInfo.dart';
import 'package:yapi_to_model/style/color.dart';
import 'package:yapi_to_model/style/size.dart';
import 'package:yapi_to_model/style/text.dart';
import 'package:yapi_to_model/style/theme.dart';
import 'package:yapi_to_model/utils/builder.dart';
import 'package:yapi_to_model/views/input.dart';

enum GenerateMode {
  dart,
  ts,
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      radius: 4,
      dismissOtherOnShow: true,
      backgroundColor: ColorPlate.black.withOpacity(0.6),
      child: MaterialApp(
        title: 'ToModel',
        theme: MyTheme.standard,
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<JsonPropertyInfo> list = [
    JsonPropertyInfo.type('id', JsonValueType.integer, '用户ID'),
    JsonPropertyInfo.type('name', JsonValueType.string, '用户姓名'),
    JsonPropertyInfo.type('age', JsonValueType.integer, '用户年龄'),
    JsonPropertyInfo.type('city', JsonValueType.string, '城市'),
    JsonPropertyInfo.type('isAdmin', JsonValueType.boolean, '是否是管理员'),
    JsonPropertyInfo.type('article', JsonValueType.list, '文章'),
  ];

  InputHelper classNameInput = InputHelper();

  bool get isSmallScreen => MediaQuery.of(context).size.width <= 550;

  GenerateMode _mode = GenerateMode.dart;

  GenerateMode get mode => _mode;

  set mode(GenerateMode mode) {
    window.localStorage['mode'] = mode.index.toString();
    _mode = mode;
  }

  @override
  void initState() {
    super.initState();
    mode = GenerateMode
        .values[int.tryParse(window.localStorage['mode'] ?? '') ?? 0];
  }

  @override
  Widget build(BuildContext context) {
    var actions = Row(
      children: [
        StButton(
          color: ColorPlate.mainBlue,
          icon: Icons.assignment_returned,
          title: 'Import',
          onTap: () async {
            var text = InputHelper();
            var res = await showDialog(
              context: context,
              builder: (ctx) {
                return SimpleDialog(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 800,
                      ),
                      child: StTextField(
                        helper: text,
                        hintText:
                            'Copy text from Yapi web table and paste here',
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: StButton(
                          color: ColorPlate.mainBlue,
                          icon: Icons.assignment_returned,
                          title: 'Import',
                          onTap: () async {
                            Navigator.of(ctx).pop(text.text);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            if (res == null || res is! String) {
              return;
            }

            var newStr = res
                .replaceAll('\n必须', r'#')
                .replaceAll('\n非必须', r'#')
                .split(RegExp(r'[\t\n]'));
            var infoStr = <List<String>>[];
            var count = 0;
            var cacheList = <String>[];
            for (var item in newStr.reversed) {
              if (item == '#') {
                count = 3;
              }
              if (count > 0) {
                count--;
              }
              cacheList.add(item);
              if (count == 0) {
                infoStr.add(List.from(cacheList.reversed));
                cacheList.clear();
                count = 9999999;
              }
            }
            print(
              infoStr,
            );
            var l = <JsonPropertyInfo>[];
            for (var line in infoStr.reversed) {
              var data = SafeMap(line);
              if (data[0].string?.isEmpty != false) {
                print('未找到key: $data');
                continue;
              }
              l.add(
                JsonPropertyInfo.type(
                  data[0].string!,
                  JsonValueTypeBuilder.fromYapiName(data[1].string ?? 'string'),
                  data[3].string ?? '',
                ),
              );
            }
            setState(() {
              list = l;
            });
          },
        ),
        StButton(
          primary: true,
          color: ColorPlate.mainBlue,
          icon: Icons.free_breakfast_rounded,
          title: 'Generate',
          onTap: () async {
            if (classNameInput.text.isEmpty) {
              var res = await showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: StText.medium('Need Class Name'),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      decoration: BoxDecoration(
                        color: ColorPlate.lightGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: StInput.helper(
                        helper: classNameInput,
                        hintText: 'Input Class Name Here',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: StButton(
                          color: ColorPlate.mainBlue,
                          icon: Icons.check,
                          title: 'Continue',
                          onTap: () {
                            Navigator.of(context).pop(classNameInput.text);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (res == null) {
                classNameInput.text = "";
                return;
              }
            }
            String? res;
            if (mode == GenerateMode.ts) {
              res = ModelBuilder.oneInterfaceContentFromClass(
                classNameInput.text,
                list.toSet(),
              );
            } else {
              res = ModelBuilder.oneClassContentFromClass(
                classNameInput.text,
                list.toSet(),
              );
            }
            print(res);
            await showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: Row(
                  children: [
                    Expanded(
                      child: StText.medium({
                            GenerateMode.dart: 'Dart Model',
                            GenerateMode.ts: 'Ts Interface',
                          }[mode] ??
                          'WTF??'),
                    ),
                    StButton(
                      color: ColorPlate.mainBlue,
                      icon: Icons.copy,
                      title: 'Copy To Clipboard',
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: res),
                        );
                        showToast('Copy Success');
                      },
                    )
                  ],
                ),
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 800,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPlate.lightGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(12),
                    child: StText.normal(
                      res,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                      maxLines: 9999,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: ColorPlate.white,
          constraints: BoxConstraints(
            maxWidth: 890,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: FlutterLogo(size: 32),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: StText.big(
                      {
                            GenerateMode.dart: 'YapiToDart',
                            GenerateMode.ts: 'YapiToTsInterface',
                          }[mode] ??
                          'WTF??',
                      style: TextStyle(
                        fontSize: SysSize.huge,
                      ),
                    ),
                  ),
                  Tapped(
                    onTap: () async {
                      var newMode = await showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: StText.medium('Select Mode'),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 22),
                          children: [
                            StButton(
                              color: ColorPlate.mainBlue,
                              icon: Icons.code,
                              title: 'Dart Model',
                              onTap: () =>
                                  Navigator.of(ctx).pop(GenerateMode.dart),
                            ),
                            StButton(
                              color: ColorPlate.mainBlue,
                              icon: Icons.code,
                              title: 'TS Interface',
                              onTap: () =>
                                  Navigator.of(ctx).pop(GenerateMode.ts),
                            ),
                          ],
                        ),
                      );
                      if (newMode != null) {
                        setState(() {
                          mode = newMode;
                        });
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Icon(
                        Icons.settings,
                        size: 32,
                        color: ColorPlate.mainBlue,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSmallScreen)
                Container(
                  padding: EdgeInsets.only(bottom: 12),
                  child: actions,
                ),
              Row(
                children: [
                  StText.medium('Class Name:'),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        width: 220,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          color: ColorPlate.lightGray,
                        ),
                        child: StInput.helper(
                          helper: classNameInput,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          hintText: 'Input class name here',
                        ),
                      ),
                    ),
                  ),
                  if (!isSmallScreen) actions,
                ],
              ),
              Container(
                width: double.infinity,
                height: 2,
                color: ColorPlate.lightGray,
                margin: EdgeInsets.symmetric(vertical: 12),
              ),
              _TableHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  padding: EdgeInsets.only(bottom: 60),
                  itemBuilder: (ctx, index) {
                    var data = list[index];
                    return Container(
                      color: index % 2 == 1
                          ? ColorPlate.white
                          : ColorPlate.lightGray,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: StText.medium(data.key),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: StText.normal(data.className),
                          ),
                          Expanded(
                            flex: 1,
                            child: StText.normal(data.remark),
                          ),
                          // Spacer(),
                          Expanded(
                            flex: 1,
                            child: Wrap(
                              children: [
                                // StButton(
                                //   color: ColorPlate.mainBlue,
                                //   icon: Icons.edit,
                                //   onTap: () {},
                                // ),
                                StButton(
                                  color: ColorPlate.red,
                                  icon: Icons.delete_forever,
                                  onTap: () {
                                    setState(() {
                                      list.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StText.normal(
                'Property',
                style: TextStyle(
                  color: ColorPlate.gray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StText.normal(
              'Type',
              style: TextStyle(
                color: ColorPlate.gray,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StText.normal(
              'Desc',
              style: TextStyle(
                color: ColorPlate.gray,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StText.normal(
              'Action',
              style: TextStyle(
                color: ColorPlate.gray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StButton extends StatelessWidget {
  final String? title;
  final Function? onTap;
  final IconData? icon;
  final Color color;
  final bool primary;

  Color get tColor => !primary ? color : ColorPlate.white;
  Color get bgColor => primary ? color : color.withOpacity(.1);

  bool get hasTitle => title?.isNotEmpty == true;

  const StButton({
    Key? key,
    this.title,
    this.onTap,
    required this.color,
    this.primary: false,
    this.icon,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tapped(
      onTap: onTap ?? () => showToast('TODO'),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding:
            hasTitle ? EdgeInsets.fromLTRB(10, 8, 14, 6) : EdgeInsets.all(6),
        margin: EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: Icon(
                icon ?? Icons.bluetooth,
                color: tColor,
                size: 16,
              ),
            ),
            Visibility(
              visible: title?.isNotEmpty == true,
              child: Container(
                padding: EdgeInsets.only(left: 4),
                child: StText.normal(
                  title ?? '',
                  style: TextStyle(
                    height: 1,
                    fontSize: 16,
                    color: tColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
