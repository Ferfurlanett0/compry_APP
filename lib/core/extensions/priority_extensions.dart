/// Compry — Priority Badge Widget
/// Shared component for priority display
library;

import 'package:flutter/material.dart';
import '../../features/shopping_lists/domain/entities/shopping_list_entity.dart';
import '../theme/app_colors.dart';

extension ListPriorityColor on ListPriority {
  Color colorLight() => switch (this) {
        ListPriority.low => AppColorsLight.priorityLow,
        ListPriority.medium => AppColorsLight.priorityMedium,
        ListPriority.high => AppColorsLight.priorityHigh,
        ListPriority.urgent => AppColorsLight.priorityUrgent,
      };

  Color colorDark() => switch (this) {
        ListPriority.low => AppColorsDark.priorityLow,
        ListPriority.medium => AppColorsDark.priorityMedium,
        ListPriority.high => AppColorsDark.priorityHigh,
        ListPriority.urgent => AppColorsDark.priorityUrgent,
      };

  IconData get icon => switch (this) {
        ListPriority.low => Icons.keyboard_arrow_down_rounded,
        ListPriority.medium => Icons.remove_rounded,
        ListPriority.high => Icons.keyboard_arrow_up_rounded,
        ListPriority.urgent => Icons.priority_high_rounded,
      };
}

extension ListStatusColor on ListStatus {
  Color colorLight() => switch (this) {
        ListStatus.draft => AppColorsLight.statusDraft,
        ListStatus.pending => AppColorsLight.statusPending,
        ListStatus.inProgress => AppColorsLight.statusInProgress,
        ListStatus.finished => AppColorsLight.statusFinished,
        ListStatus.cancelled => AppColorsLight.statusCancelled,
      };

  Color colorDark() => switch (this) {
        ListStatus.draft => AppColorsDark.statusDraft,
        ListStatus.pending => AppColorsDark.statusPending,
        ListStatus.inProgress => AppColorsDark.statusInProgress,
        ListStatus.finished => AppColorsDark.statusFinished,
        ListStatus.cancelled => AppColorsDark.statusCancelled,
      };

  IconData get icon => switch (this) {
        ListStatus.draft => Icons.edit_note_rounded,
        ListStatus.pending => Icons.schedule_rounded,
        ListStatus.inProgress => Icons.shopping_cart_rounded,
        ListStatus.finished => Icons.check_circle_rounded,
        ListStatus.cancelled => Icons.cancel_rounded,
      };
}
