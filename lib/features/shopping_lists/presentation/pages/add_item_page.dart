/// Compry — Premium Add Item Page
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../../domain/usecases/shopping_list_usecases.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class AddItemPage extends ConsumerStatefulWidget {
  final String listId;

  const AddItemPage({super.key, required this.listId});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  ItemUnit _unit = ItemUnit.unidade;
  String? _category;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addItem({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      final useCase = AddItemUseCase(repository);

      final quantityText = _quantityController.text.replaceAll(',', '.');
      final quantity = double.tryParse(quantityText) ?? 1.0;

      await useCase.call(AddItemParams(
        listId: widget.listId,
        name: _nameController.text,
        quantity: quantity,
        unit: _unit,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        category: _category,
        expectedPrice: null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        position: DateTime.now().millisecondsSinceEpoch,
      ));

      if (!mounted) return;

      if (addAnother) {
        _nameController.clear();
        _brandController.clear();
        _notesController.clear();
        _quantityController.text = '1';
        setState(() {
          _unit = ItemUnit.unidade;
          _category = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Item adicionado!')),
        );
      } else {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
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
          'Adicionar Item',
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
              // Name Section
              _SectionTitle(title: 'O que você precisa?', icon: Icons.shopping_basket_rounded)
                  .animate().fadeIn(duration: 400.ms),
              const Gap(AppDimensions.spaceMD),
              AppTextField(
                id: 'item-name',
                controller: _nameController,
                label: 'Nome do Produto *',
                hint: 'Ex: Arroz, Leite, Café...',
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Obrigatório';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const Gap(AppDimensions.spaceXXL),

              // Quantity and Unit Section
              _SectionTitle(title: 'Quantidade', icon: Icons.straighten_rounded)
                  .animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const Gap(AppDimensions.spaceMD),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: AppTextField(
                      id: 'item-quantity',
                      controller: _quantityController,
                      label: 'Qtd *',
                      hint: '1',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Obrigatório';
                        final q = double.tryParse(value.replaceAll(',', '.'));
                        if (q == null || q <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const Gap(AppDimensions.spaceMD),
                  Expanded(
                    flex: 2,
                    child: _PremiumUnitSelector(
                      value: _unit,
                      onChanged: (u) => setState(() => _unit = u),
                    ),
                  ),
                ].animate(interval: 50.ms).fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
              ),

              const Gap(AppDimensions.spaceXXL),

              // Details Section
              _SectionTitle(title: 'Detalhes Adicionais', icon: Icons.tune_rounded)
                  .animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const Gap(AppDimensions.spaceMD),

              AppTextField(
                id: 'item-brand',
                controller: _brandController,
                label: 'Marca (opcional)',
                hint: 'Ex: Nestlé, Qualitá...',
                prefixIcon: Icons.store_mall_directory_outlined,
                textInputAction: TextInputAction.next,
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.1),
              const Gap(AppDimensions.spaceMD),

              _PremiumCategorySelector(
                value: _category,
                onChanged: (c) => setState(() => _category = c),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
              const Gap(AppDimensions.spaceMD),

              AppTextArea(
                id: 'item-notes',
                controller: _notesController,
                label: 'Observações (opcional)',
                hint: 'Ex: Sem lactose, Integral...',
                minLines: 2,
                maxLines: 4,
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1),

              const Gap(AppDimensions.spaceXXXL),

              // Action Buttons
              AppButton(
                id: 'btn-add-another',
                label: 'Adicionar e Continuar',
                onPressed: _isLoading ? null : () => _addItem(addAnother: true),
                outlined: true,
                icon: Icons.add_circle_outline_rounded,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

              const Gap(AppDimensions.spaceSM),

              AppButton(
                id: 'btn-add-item',
                label: 'Concluir',
                onPressed: _isLoading ? null : () => _addItem(),
                isLoading: _isLoading,
                icon: Icons.check_circle_rounded,
              ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Components ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const Gap(8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PremiumUnitSelector extends StatelessWidget {
  final ItemUnit value;
  final ValueChanged<ItemUnit> onChanged;

  const _PremiumUnitSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, // Same height as text field
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ItemUnit.values.length,
        separatorBuilder: (_, __) => const Gap(AppDimensions.spaceXS),
        itemBuilder: (context, index) {
          final unit = ItemUnit.values[index];
          final isSelected = value == unit;
          final cs = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () => onChanged(unit),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                unit.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumCategorySelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _PremiumCategorySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final options = [null, ...AppCategories.defaults];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceMD),
            child: Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
          ),
          hint: Padding(
            padding: const EdgeInsets.only(left: AppDimensions.spaceMD),
            child: Text(
              'Categoria',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          items: options.map((cat) {
            return DropdownMenuItem<String?>(
              value: cat,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.spaceMD),
                child: Text(
                  cat ?? 'Sem Categoria',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: cat == value ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: cs.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }
}
