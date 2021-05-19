// 输入框
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tapped/tapped.dart';
import 'package:flutter/material.dart';
import 'package:yapi_to_model/style/color.dart';
import 'package:yapi_to_model/style/size.dart';

/// 封装了取值，焦点，控制器方法
class InputHelper {
  final String? defaultText;

  InputHelper({this.defaultText})
      : controller = TextEditingController(text: defaultText);

  final TextEditingController controller;

  String get text => controller.value.text;

  set text(String? t) {
    controller.value = TextEditingValue(text: t ?? '');
  }

  final FocusNode focusNode = FocusNode();
}

class StInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final bool isPassword;
  final bool onlyNumber;
  final int maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? inputType;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final EdgeInsets? contentPadding;
  final bool? clearable;
  final bool? autofocus;

  const StInput({
    Key? key,
    this.controller,
    this.hintText,
    this.enabled: true,
    this.isPassword: false,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.inputType,
    this.maxLength: 20,
    this.textAlign: TextAlign.start,
    this.onlyNumber: false,
    this.contentPadding,
    this.clearable,
    this.autofocus,
  }) : super(key: key);

  StInput.helper({
    Key? key,
    InputHelper? helper,
    this.hintText,
    this.enabled: true,
    this.isPassword: false,
    this.textInputAction,
    this.onSubmitted,
    this.inputType,
    this.maxLength: 20,
    this.textAlign: TextAlign.start,
    this.onlyNumber: false,
    this.contentPadding,
    this.clearable,
    this.autofocus,
  })  : this.controller = helper?.controller,
        this.focusNode = helper?.focusNode,
        super(key: key);

  @override
  _StInputState createState() => _StInputState();
}

class _StInputState extends State<StInput> {
  bool get hasClearBtn =>
      widget.controller?.text.isNotEmpty == true &&
      widget.focusNode!.hasFocus &&
      (widget.clearable ?? false);

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(update);
  }

  void update() => setState(() {});

  @override
  void dispose() {
    widget.controller?.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: widget.isPassword,
      keyboardType: widget.inputType,
      autofocus: widget.autofocus ?? false,
      keyboardAppearance: Brightness.light,
      textInputAction: widget.textInputAction,
      textAlign: widget.textAlign,
      inputFormatters: <TextInputFormatter>[
            widget.maxLength == 0
                ? LengthLimitingTextInputFormatter(999)
                : LengthLimitingTextInputFormatter(widget.maxLength), //限制长度
          ] +
          (widget.onlyNumber
              ? [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ]
              : []),
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText ?? '##Hint Text##',
        contentPadding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
        // border: enabled == false ? InputBorder.none : null,
        suffixIconConstraints: BoxConstraints(
          minHeight: 26,
        ),
        suffixIcon: hasClearBtn == true
            ? Tapped(
                onTap: () {
                  if (widget.controller != null) {
                    widget.controller!.text = '';
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 2),
                  color: ColorPlate.clear,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Icon(
                    Icons.cancel,
                    color: ColorPlate.gray,
                    size: 20,
                  ),
                ),
              )
            : null,
        border: InputBorder.none,

        hintStyle: TextStyle(
          height: 1.3,
          fontSize: SysSize.normal,
          color: ColorPlate.gray,
        ),
      ),
    );
  }
}

class StPwInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final int maxLength;
  final bool onlyNumAndEn;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType? inputType;

  const StPwInput({
    Key? key,
    this.controller,
    this.hintText,
    this.enabled: true,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.inputType,
    this.onlyNumAndEn: false,
    this.maxLength: 20,
  }) : super(key: key);

  @override
  _StPwInputState createState() => _StPwInputState();
}

class _StPwInputState extends State<StPwInput> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: !showPassword,
          keyboardAppearance: Brightness.light,
          keyboardType: widget.inputType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          inputFormatters: <TextInputFormatter>[
                // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
                widget.maxLength == 0
                    ? LengthLimitingTextInputFormatter(999)
                    : LengthLimitingTextInputFormatter(widget.maxLength), //限制长度
              ] +
              (widget.onlyNumAndEn
                  ? [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                    ]
                  : []),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText ?? '##Hint Text##',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 6,
            ),
            border: widget.enabled == false ? InputBorder.none : null,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ColorPlate.gray,
            ),
          ),
        ),
        Tapped(
          onTap: () {
            setState(() => showPassword = !showPassword);
          },
          child: Container(
            height: 40,
            width: 40,
            color: ColorPlate.clear,
            child: Center(
              child: Icon(
                Icons.remove_red_eye,
                color: showPassword
                    ? ColorPlate.mainBlue
                    : ColorPlate.gray.withOpacity(0.5),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class StTextField extends StatelessWidget {
  final InputHelper? helper;
  final String? hintText;
  final EdgeInsets? margin;
  const StTextField({
    Key? key,
    this.helper,
    this.hintText,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: ColorPlate.lightGray,
          child: TextField(
            focusNode: helper?.focusNode,
            controller: helper?.controller,
            minLines: 5,
            maxLines: 20,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText ?? '请填写内容',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(
                height: 1.3,
                fontSize: SysSize.small,
                color: ColorPlate.gray,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
