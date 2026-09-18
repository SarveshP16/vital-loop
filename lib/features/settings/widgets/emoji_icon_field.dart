import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A single large tappable field for the activity's icon glyph. Deliberately
/// just a styled [TextField] rather than a custom preset grid — tapping it
/// opens the device's own keyboard, whose emoji key gives access to the
/// full on-device emoji list (the user's actual keyboard/emoji picker,
/// not a hand-picked subset baked into this app).
class EmojiIconField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const EmojiIconField({super.key, required this.value, required this.onChanged});

  @override
  State<EmojiIconField> createState() => _EmojiIconFieldState();
}

class _EmojiIconFieldState extends State<EmojiIconField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EmojiIconField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26),
            decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
            maxLength: 8,
            onChanged: (text) {
              if (text.trim().isNotEmpty) widget.onChanged(text.trim());
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Tap and use your keyboard\'s emoji key to pick an icon.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtleText),
          ),
        ),
      ],
    );
  }
}
