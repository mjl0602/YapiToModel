import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:tapped/tapped.dart';
import 'package:yapi_to_model/model/jsonPropertyInfo.dart';
import 'package:yapi_to_model/style/color.dart';
import 'package:yapi_to_model/style/size.dart';
import 'package:yapi_to_model/style/text.dart';
import 'package:yapi_to_model/style/theme.dart';
import 'package:yapi_to_model/utils/builder.dart';
import 'package:yapi_to_model/views/input.dart';

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
  ];

  InputHelper classNameInput = InputHelper();

  @override
  Widget build(BuildContext context) {
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
                      'YapiToDart',
                      style: TextStyle(
                        fontSize: SysSize.huge,
                      ),
                    ),
                  ),
                  // Tapped(
                  //   child: Container(
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  //     child: Icon(
                  //       Icons.settings,
                  //       size: 32,
                  //       color: ColorPlate.mainBlue,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Row(
                children: [
                  StText.normal('Class Name'),
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
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: 'Input class name here',
                        ),
                      ),
                    ),
                  ),
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
                              StTextField(
                                helper: text,
                                hintText:
                                    'Copy text from Yapi web table and paste here',
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
                      // print(
                      //   res
                      //       .split('\n')
                      //       .map((line) => line.split('\t').join('\\t'))
                      //       .toList()
                      //       .join('\n----\n-----\n'),
                      // );
                      print(
                        res
                            .replaceAll('\n非必须\n', r'非必须')
                            .replaceAll('\t', r' ')
                            .replaceAll('\n', r'\n'),
                      );
                      res = res.replaceAll('\n非必须\n', r'非必须');
                      var l = <JsonPropertyInfo>[];
                      for (var line in res.split('\n')) {
                        var data = line.split('\t');
                        if (data.length < 3) {
                          continue;
                        }
                        l.add(
                          JsonPropertyInfo.type(
                            data[0],
                            JsonValueTypeBuilder.fromYapiName(data[1]),
                            data[2],
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
                        showToast('Must Input Class Name');
                        return;
                      }
                      var res = ModelBuilder.oneClassContentFromClass(
                        classNameInput.text,
                        list.toSet(),
                      );
                      print(res);
                      await showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: Row(
                            children: [
                              Expanded(child: StText.medium('Dart Code')),
                              StButton(
                                color: ColorPlate.mainBlue,
                                icon: Icons.copy,
                                title: 'Copy To ClipBoard',
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
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: StText.normal(data.key),
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
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                StButton(
                                  color: ColorPlate.mainBlue,
                                  icon: Icons.edit,
                                  onTap: () {},
                                ),
                                StButton(
                                  color: ColorPlate.red,
                                  icon: Icons.delete_forever,
                                  onTap: () {},
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
              'Remark',
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
