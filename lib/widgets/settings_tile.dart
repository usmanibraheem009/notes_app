import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.value,
    this.trailingIcon,
    this.topCard = false,
    this.bottomCard = false,
    this.onTap,
  });

  final String title;
  final String? value;
  final IconData? trailingIcon;
  final bool? topCard;
  final bool? bottomCard;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: topCard == true
              ? BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))
              : bottomCard == true
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))
                  : BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: scheme.onPrimary),
                ),
                if (value != null && value!.isNotEmpty)
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSecondary,
                    ),
                  ),
              ],
            ),
            Icon(
              trailingIcon,
              color: scheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
