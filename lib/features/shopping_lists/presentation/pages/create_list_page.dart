/// Compry — Premium Create List Page
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/extensions/priority_extensions.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/shopping_list_entity.dart';
import '../../domain/usecases/shopping_list_usecases.dart';
import '../../../../core/config/providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CreateListPage extends ConsumerStatefulWidget {
  const CreateListPage({super.key});

  @override
  ConsumerState<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends ConsumerState<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  ListPriority _priority = ListPriority.medium;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      final useCase = CreateListUseCase(repository);

      final list = await useCase.call(CreateListParams(
        title: _titleController.text,
        description: null,
        notes: null,
        priority: _priority,
        category: null,
        createdBy: user.id,
      ));

      if (!mounted) return;

      context.pushReplacement(AppRoutes.listDetailPath(list.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar lista: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Nova Lista',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: AppDimensions.spaceXL,
            ),
            children: [
              // Title Field
              AppTextField(
                id: 'list-title',
                controller: _titleController,
                label: 'Título da Compra',
                hint: 'Ex: Compras do Mês',
                prefixIcon: Icons.shopping_bag_outlined,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const Gap(AppDimensions.spaceXXL),

              // Priority Selector
              _PremiumPrioritySelector(
                value: _priority,
                onChanged: (p) => setState(() => _priority = p),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),

              const Gap(AppDimensions.spaceXXXL),

              // Create Button
              AppButton(
                id: 'btn-create-list',
                label: 'Criar e Adicionar Itens',
                onPressed: _isLoading ? null : () => _createList(),
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Premium Priority Selector ────────────────────────────────────────────────

class _PremiumPrioritySelector extends StatefulWidget {
  final ListPriority value;
  final ValueChanged<ListPriority> onChanged;

  const _PremiumPrioritySelector({required this.value, required this.onChanged});

  @override
  State<_PremiumPrioritySelector> createState() => _PremiumPrioritySelectorState();
}

class _PremiumPrioritySelectorState extends State<_PremiumPrioritySelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qual a prioridade desta compra?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const Gap(AppDimensions.spaceMD),
        Row(
          children: ListPriority.values.map((priority) {
            final isSelected = widget.value == priority;
            final color = isDark ? priority.colorDark() : priority.colorLight();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => widget.onChanged(priority),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: isDark ? 0.2 : 0.1) : cs.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(
                        color: isSelected ? color : cs.outlineVariant.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [BoxShadow(color: cs.shadow, blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: Column(
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            priority.icon,
                            color: isSelected ? color : cs.onSurfaceVariant.withValues(alpha: 0.6),
                            size: 24,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          priority.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? color : cs.onSurfaceVariant.withValues(alpha: 0.7),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
