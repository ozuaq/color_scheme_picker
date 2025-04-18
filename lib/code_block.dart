import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard を使うために必要
// import 'package:google_fonts/google_fonts.dart'; // Google Fonts を使う場合

class CodeBlockWithCopyButton extends StatefulWidget {
  final String code;
  final Color backgroundColor;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final BorderRadius borderRadius;

  const CodeBlockWithCopyButton({
    super.key,
    required this.code,
    this.backgroundColor = const Color(0xFFF4F4F4), // Web例に近い背景色
    this.padding = const EdgeInsets.all(16.0),
    this.textStyle = const TextStyle(
      fontFamily: 'monospace', // Monospace フォントを指定
      fontSize: 14.0,
      color: Color(0xFF333333),
      height: 1.4, // 行間
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  @override
  State<CodeBlockWithCopyButton> createState() =>
      _CodeBlockWithCopyButtonState();
}

class _CodeBlockWithCopyButtonState extends State<CodeBlockWithCopyButton> {
  bool _isCopied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _isCopied = true;
    });

    // ScaffoldMessengerを使ってSnackBarを表示
    // このウィジェットがScaffoldの子孫であることを確認してください
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コードをクリップボードにコピーしました'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 2秒後にアイコンを元に戻す
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // 遅延後もウィジェットが存在するか確認
      setState(() {
        _isCopied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.textStyle.color?.withAlpha((0.7 * 255).round()) ?? Colors.grey;
    final hoverColor =
        widget.textStyle.color?.withAlpha((0.9 * 255).round()) ?? Colors.black;

    return Stack(
      children: [
        // コード表示部分
        Container(
          width: double.infinity, // 横幅いっぱいに広げる
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            border: Border.all(color: Colors.grey.shade300), // 枠線 (任意)
          ),
          child: SingleChildScrollView(
            // 長いコードがはみ出ないようにスクロール可能にする
            scrollDirection: Axis.horizontal, // 横スクロール
            child: SelectableText(
              // テキスト選択可能にする
              widget.code,
              style: widget.textStyle,
            ),
          ),
        ),
        // コピーボタン
        Positioned(
          top: 8.0,
          right: 8.0,
          child: IconButton(
            icon: Icon(
              _isCopied ? Icons.check : Icons.copy_rounded, // 状態に応じてアイコンを変更
              size: 18.0,
              color: _isCopied ? Colors.green : iconColor,
            ),
            tooltip: _isCopied ? 'コピーしました' : 'コードをコピー',
            splashRadius: 20.0, // ボタン押下時の波紋効果の半径
            hoverColor: hoverColor.withAlpha(
              (0.1 * 255).round(),
            ), // ホバー時の色 (デスクトップ/Web)
            onPressed: _isCopied ? null : _copyToClipboard, // コピー後は一時的に無効化
          ),
        ),
      ],
    );
  }
}
