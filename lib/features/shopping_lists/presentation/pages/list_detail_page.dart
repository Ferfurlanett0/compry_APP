/// Compry — Premium List Detail Page
library;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/config/providers.dart';
import '../../../../core/extensions/priority_extensions.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/shopping_item_entity.dart';
import '../../domain/entities/shopping_list_entity.dart';
import '../../domain/usecases/shopping_list_usecases.dart';
import '../../../../shared/widgets/skeleton_loaders.dart';
import '../../../../shared/widgets/empty_state.dart';

final watchListProvider = StreamProvider.autoDispose.family<ShoppingListEntity, String>((ref, listId) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return WatchListUseCase(repository).call(listId);
});

final watchItemsProvider = StreamProvider.autoDispose.family<List<ShoppingItemEntity>, String>((ref, listId) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return WatchItemsUseCase(repository).call(listId);
});

class ListDetailPage extends ConsumerWidget {
  final String listId;
  const ListDetailPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(watchListProvider(listId));
    final itemsAsync = ref.watch(watchItemsProvider(listId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: listAsync.when(
        loading: () => _LoadingBody(),
        error: (err, _) => ErrorState(message: err.toString()),
        data: (list) => _ListBody(list: list, itemsAsync: itemsAsync, currentUser: currentUser),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          leading: const BackButton(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ItemTileSkeleton(),
            childCount: 8,
          ),
        ),
      ],
    );
  }
}

class _ListBody extends ConsumerStatefulWidget {
  final ShoppingListEntity list;
  final AsyncValue<List<ShoppingItemEntity>> itemsAsync;
  final dynamic currentUser;

  const _ListBody({required this.list, required this.itemsAsync, required this.currentUser});

  @override
  ConsumerState<_ListBody> createState() => _ListBodyState();
}

class _ListBodyState extends ConsumerState<_ListBody> {
  bool _isFinalizing = false;
  bool _isSending = false;

  Future<void> _finalizeList() async {
    final confirmed = await _showFinalizeDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isFinalizing = true);
    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      await FinalizeListUseCase(repository).call(FinalizeListParams(
        listId: widget.list.id,
        adminId: widget.currentUser!.id,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Compra finalizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
      if (mounted) setState(() => _isFinalizing = false);
    }
  }

  Future<void> _sendList() async {
    setState(() => _isSending = true);
    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      await SendListUseCase(repository).call(widget.list.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📤 Lista enviada para o administrador!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<bool> _showFinalizeDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Finalizar Compra'),
            content: const Text('Confirmar finalização? Após isso, nenhum item poderá ser alterado.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Finalizar')),
            ],
          ),
        ) ??
        false;
  }

  bool _isDeleting = false;

  Future<void> _deleteList() async {
    final confirmed = await _showDeleteDialog();
    if (!confirmed || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isDeleting = true);
    
    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      final isAdmin = widget.currentUser?.isAdmin ?? false;
      
      // Voltar para a tela anterior imediatamente para evitar erro de "Lista não encontrada" 
      // quando o provider for atualizado pela exclusão.
      navigator.pop();
      
      await DeleteListUseCase(repository).call(DeleteListParams(
        listId: widget.list.id,
        isAdmin: isAdmin,
      ));
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('🗑️ Lista excluída com sucesso!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir Lista'),
            content: const Text('Tem certeza que deseja excluir esta lista? Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true), 
                style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = widget.currentUser?.isAdmin ?? false;
    final priorityColor = isDark ? list.priority.colorDark() : list.priority.colorLight();
    
    // Modo compra: Se a lista está pendente ou em progresso e o usuário for admin, exibe checkboxes maiores
    final isShoppingMode = isAdmin && (list.status == ListStatus.inProgress || list.status == ListStatus.pending);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: cs.surface.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                  color: cs.onSurface,
                ),
              ),
            ),
            actions: [
              if (isAdmin || list.status.isDraft)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: _isDeleting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.delete_outline_rounded),
                    color: cs.error,
                    onPressed: _isDeleting ? null : _deleteList,
                  ),
                ),
              if (!isAdmin && list.status.isDraft)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilledButton.icon(
                    onPressed: _isSending ? null : _sendList,
                    icon: _isSending 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Enviar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: AppDimensions.pagePadding, bottom: AppDimensions.spaceMD, right: AppDimensions.pagePadding),
              title: Text(
                list.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          priorityColor.withValues(alpha: isDark ? 0.2 : 0.1),
                          cs.surface,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: priorityColor.withValues(alpha: 0.15),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Progress Bar Premium ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, AppDimensions.spaceMD, AppDimensions.pagePadding, AppDimensions.spaceXL),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Progresso da Compra',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: list.progress == 1.0 ? cs.primary : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          '${list.progressText} (${list.progressPercent})',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: list.progress == 1.0 ? cs.onPrimary : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppDimensions.spaceMD),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: list.progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, _) => Stack(
                        children: [
                          Container(
                            height: AppDimensions.progressBarHeight + 4,
                            color: cs.surfaceContainerHighest,
                          ),
                          FractionallySizedBox(
                            widthFactor: value.clamp(0.0, 1.0),
                            child: Container(
                              height: AppDimensions.progressBarHeight + 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                gradient: LinearGradient(
                                  colors: [
                                    (list.progress == 1.0 ? cs.primary : priorityColor).withValues(alpha: 0.7),
                                    (list.progress == 1.0 ? cs.primary : priorityColor),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (list.progress == 1.0 ? cs.primary : priorityColor).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            ),
          ),

          // ─── Info Chips ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
              child: Wrap(
                spacing: AppDimensions.spaceSM,
                runSpacing: AppDimensions.spaceSM,
                children: [
                  _PremiumInfoChip(icon: list.status.icon, label: list.status.label, color: isDark ? list.status.colorDark() : list.status.colorLight()),
                  _PremiumInfoChip(icon: list.priority.icon, label: list.priority.label, color: priorityColor),
                  if (list.category != null) _PremiumInfoChip(icon: Icons.category_rounded, label: list.category!, color: cs.secondary),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ),

          if (list.notes != null || list.description != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, AppDimensions.spaceLG, AppDimensions.pagePadding, 0),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (list.description != null) ...[
                        Text(list.description!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                        if (list.notes != null) const Gap(AppDimensions.spaceSM),
                      ],
                      if (list.notes != null)
                        Text(list.notes!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
            ),

          // ─── Items Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, AppDimensions.spaceXL, AppDimensions.pagePadding, AppDimensions.spaceMD),
              child: Row(
                children: [
                  Text('Itens da Lista', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  if (!isAdmin && list.status.isDraft)
                    FilledButton.tonalIcon(
                      onPressed: () => context.push(AppRoutes.addItemPath(list.id)),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Adicionar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Items List ───────────────────────────────────────────────────────
          widget.itemsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate((_, __) => const ItemTileSkeleton(), childCount: 5),
            ),
            error: (err, _) => SliverToBoxAdapter(child: ErrorState(message: err.toString())),
            data: (items) => items.isEmpty
                ? SliverFillRemaining(
                    child: NoItemsEmptyState(
                      onAddItem: (!isAdmin && list.status.isDraft) ? () => context.push(AppRoutes.addItemPath(list.id)) : null,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
                          child: _PremiumItemTile(
                            item: items[index],
                            listId: list.id,
                            isAdmin: isAdmin,
                            isListActive: list.canBeChecked,
                            isListFinished: list.status.isFinished,
                            isShoppingMode: isShoppingMode,
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: Gap(100)),
        ],
      ),
      floatingActionButton: (isAdmin && list.canBeFinalized)
          ? _FinalizeButton(
              isFinalizing: _isFinalizing,
              onPressed: _finalizeList,
              isAllChecked: list.progress == 1.0,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _PremiumItemTile extends ConsumerStatefulWidget {
  final ShoppingItemEntity item;
  final String listId;
  final bool isAdmin;
  final bool isListActive;
  final bool isListFinished;
  final bool isShoppingMode;

  const _PremiumItemTile({
    required this.item,
    required this.listId,
    required this.isAdmin,
    required this.isListActive,
    required this.isListFinished,
    required this.isShoppingMode,
  });

  @override
  ConsumerState<_PremiumItemTile> createState() => _PremiumItemTileState();
}

class _PremiumItemTileState extends ConsumerState<_PremiumItemTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCheck() async {
    if (!widget.isListActive || _isUpdating) return;
    if (!widget.isAdmin) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    HapticFeedback.lightImpact();

    await _controller.forward();
    await _controller.reverse();

    setState(() => _isUpdating = true);

    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      if (widget.item.checked) {
        await UncheckItemUseCase(repository).call(UncheckItemParams(listId: widget.listId, itemId: widget.item.id));
      } else {
        await CheckItemUseCase(repository).call(CheckItemParams(listId: widget.listId, itemId: widget.item.id, checkedBy: user.id));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isChecked = widget.item.checked;
    final checkboxSize = widget.isShoppingMode ? AppDimensions.checkboxSizeLarge : AppDimensions.checkboxSize;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
        decoration: BoxDecoration(
          color: isChecked ? cs.surfaceContainerHighest.withValues(alpha: 0.3) : cs.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isChecked ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.4),
            width: isChecked ? 1.5 : 1,
          ),
          boxShadow: isChecked ? [] : [
            BoxShadow(
              color: cs.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isAdmin ? _toggleCheck : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isShoppingMode ? AppDimensions.spaceLG : AppDimensions.spaceMD,
                vertical: widget.isShoppingMode ? AppDimensions.spaceMD : AppDimensions.spaceSM,
              ),
              child: Row(
                children: [
                  // Animated Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: checkboxSize,
                    height: checkboxSize,
                    decoration: BoxDecoration(
                      color: isChecked ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(widget.isShoppingMode ? 12 : 8),
                      border: Border.all(
                        color: isChecked ? cs.primary : cs.outline,
                        width: 2,
                      ),
                      boxShadow: isChecked ? [
                        BoxShadow(color: cs.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))
                      ] : [],
                    ),
                    child: isChecked 
                        ? Icon(Icons.check_rounded, color: Colors.white, size: widget.isShoppingMode ? 24 : 16)
                            .animate().scale(duration: 200.ms, curve: Curves.easeOutBack)
                        : null,
                  ),

                  const Gap(AppDimensions.spaceMD),

                  // Item Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked ? cs.onSurfaceVariant : cs.onSurface,
                            fontWeight: isChecked ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                        const Gap(2),
                        Row(
                          children: [
                            Text(
                              widget.item.quantityDisplay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isChecked ? cs.onSurfaceVariant.withValues(alpha: 0.7) : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.item.brand != null) ...[
                              Text(' • ', style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5))),
                              Text(
                                widget.item.brand!,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_isUpdating)
                    Padding(
                      padding: const EdgeInsets.only(left: AppDimensions.spaceMD),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PremiumInfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap(6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

class _FinalizeButton extends StatelessWidget {
  final bool isFinalizing;
  final VoidCallback onPressed;
  final bool isAllChecked;

  const _FinalizeButton({required this.isFinalizing, required this.onPressed, required this.isAllChecked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget btn = FloatingActionButton.extended(
      onPressed: isFinalizing ? null : onPressed,
      backgroundColor: isAllChecked ? cs.primary : cs.surface,
      foregroundColor: isAllChecked ? cs.onPrimary : cs.onSurface,
      elevation: isAllChecked ? 8 : 4,
      icon: isFinalizing
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: isAllChecked ? cs.onPrimary : cs.primary))
          : Icon(Icons.check_circle_rounded, color: isAllChecked ? cs.onPrimary : cs.primary),
      label: Text(
        'Finalizar Compra',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isAllChecked ? cs.onPrimary : cs.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (isAllChecked) {
      btn = btn.animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.02, 1.02));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: btn,
      ),
    );
  }
}
