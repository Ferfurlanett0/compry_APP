/// Compry — Premium App Button (Shared Widget)
library;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_dimensions.dart';

class AppButton extends StatefulWidget {
  final String id;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;
  final bool danger;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.id,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
    this.danger = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg =
        widget.danger ? cs.error : (widget.backgroundColor ?? cs.primary);
    final effectiveFg =
        widget.danger ? cs.onError : (widget.foregroundColor ?? cs.onPrimary);

    final isDisabled = widget.isLoading || widget.onPressed == null;

    final content = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.outlined ? effectiveBg : effectiveFg,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: AppDimensions.iconMD),
                const Gap(AppDimensions.spaceXS),
              ],
              Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: widget.outlined ? effectiveBg : effectiveFg,
                ),
              ),
            ],
          );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isDisabled ? null : (_) => _controller.forward(),
        onTap: isDisabled
            ? null
            : () {
                _controller.reverse();
                widget.onPressed!();
              },
        onTapCancel: isDisabled ? null : () => _controller.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : (isDisabled ? cs.surfaceContainerHighest : effectiveBg),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: widget.outlined
                ? Border.all(
                    color: isDisabled ? cs.outline : effectiveBg, width: 2)
                : null,
            boxShadow: (!widget.outlined && !isDisabled)
                ? [
                    BoxShadow(
                      color: effectiveBg.withValues(alpha: isDark ? 0.4 : 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: null, // Tap is handled by GestureDetector for scaling
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              child: Center(
                child: Opacity(
                  opacity: isDisabled ? (widget.isLoading ? 1.0 : 0.5) : 1.0,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppFab extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AppFab({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      key: Key(id),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
      ),
    );
  }
}
