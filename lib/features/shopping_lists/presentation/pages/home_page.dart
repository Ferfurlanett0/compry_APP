/// Compry — Premium Home Page
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../domain/entities/shopping_list_entity.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/list_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loaders.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: currentUser.isAdmin
          ? _AdminHome(user: currentUser)
          : _EmployeeHome(user: currentUser),
    );
  }
}

// ─── Employee Home ────────────────────────────────────────────────────────────

class _EmployeeHome extends ConsumerStatefulWidget {
  final UserEntity user;
  const _EmployeeHome({required this.user});

  @override
  ConsumerState<_EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends ConsumerState<_EmployeeHome> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _PremiumAppBar(user: widget.user, isScrolled: _isScrolled),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.spaceMD,
                AppDimensions.pagePadding,
                AppDimensions.spaceLG,
              ),
              child: _PremiumNewListButton(),
            ).animate(key: const ValueKey('home-new-list')).fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
              child: _PremiumSearchBar(ref: ref),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceXL)),
          
          _buildListContent(context, homeState, isAdmin: false),
          
          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceXXXL)),
        ],
      ),
    );
  }
}

// ─── Admin Home ───────────────────────────────────────────────────────────────

class _AdminHome extends ConsumerStatefulWidget {
  final UserEntity user;
  const _AdminHome({required this.user});

  @override
  ConsumerState<_AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends ConsumerState<_AdminHome> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _PremiumAppBar(user: widget.user, isScrolled: _isScrolled),
          
          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceLG)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
              child: _PremiumSearchBar(ref: ref),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceLG)),

          SliverToBoxAdapter(
            child: _PremiumStatusFilterChips(ref: ref)
                .animate()
                .fadeIn(delay: 100.ms, duration: 500.ms),
          ),

          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceLG)),
          
          _buildListContent(context, homeState, isAdmin: true),
          
          const SliverToBoxAdapter(child: Gap(AppDimensions.spaceXXXL)),
        ],
      ),
    );
  }
}

// ─── Shared Components ────────────────────────────────────────────────────────

class _PremiumAppBar extends StatelessWidget {
  final UserEntity user;
  final bool isScrolled;

  const _PremiumAppBar({required this.user, required this.isScrolled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final greeting = _greeting();
    final emoji = _greetingEmoji();

    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: isScrolled ? 2 : 0,
      shadowColor: cs.shadow,
      backgroundColor: isScrolled ? cs.surface : cs.surface,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 140,
      collapsedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppDimensions.pagePadding,
          right: AppDimensions.pagePadding,
          bottom: AppDimensions.spaceMD,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset('assets/icons/icone_compry.png', width: 32, height: 32),
            const Gap(AppDimensions.spaceMD),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$greeting $emoji',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    user.name.isNotEmpty 
                        ? user.name.split(' ').first 
                        : (user.isAdmin ? 'Administrador' : 'Funcionário'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Premium Avatar
            Container(
              width: AppDimensions.avatarMD,
              height: AppDimensions.avatarMD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.15),
                    cs.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  user.isAdmin ? 'assets/images/administrador.png' : 'assets/images/funcionario.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: cs.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        color: cs.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _greetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 18) return '☀️';
    return '🌙';
  }
}

class _PremiumNewListButton extends StatefulWidget {
  @override
  State<_PremiumNewListButton> createState() => _PremiumNewListButtonState();
}

class _PremiumNewListButtonState extends State<_PremiumNewListButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          context.push(AppRoutes.createList);
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.4 : 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24),
              const Gap(AppDimensions.spaceSM),
              Text(
                'Criar Nova Lista',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumSearchBar extends StatefulWidget {
  final WidgetRef ref;
  const _PremiumSearchBar({required this.ref});

  @override
  State<_PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<_PremiumSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: _isFocused ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: TextField(
        focusNode: _focusNode,
        onChanged: (value) => widget.ref.read(homeViewModelProvider.notifier).search(value),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Pesquisar listas...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD, vertical: AppDimensions.spaceMD),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }
}

class _PremiumStatusFilterChips extends StatelessWidget {
  final WidgetRef ref;
  const _PremiumStatusFilterChips({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final currentFilter = state is HomeLoaded ? state.statusFilter : null;
    final cs = Theme.of(context).colorScheme;

    final filters = [
      (null, 'Todas'),
      (ListStatus.pending, ListStatus.pending.label),
      (ListStatus.inProgress, ListStatus.inProgress.label),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const Gap(AppDimensions.spaceSM),
        itemBuilder: (context, index) {
          final (status, label) = filters[index];
          final isSelected = currentFilter == status;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => ref.read(homeViewModelProvider.notifier).filterByStatus(status),
              showCheckmark: false,
              backgroundColor: cs.surface,
              selectedColor: cs.primary,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : cs.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD, vertical: 8),
              elevation: isSelected ? 4 : 0,
              shadowColor: cs.primary.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildListContent(BuildContext context, HomeState state, {required bool isAdmin}) {
  return switch (state) {
    HomeLoading() || HomeInitial() => SliverToBoxAdapter(
        child: const ListCardSkeletonList(),
      ),
    HomeError(message: final msg) => SliverFillRemaining(
        child: ErrorState(
          message: msg,
          onRetry: null,
        ),
      ),
    HomeLoaded(filteredLists: final lists) => lists.isEmpty
        ? SliverFillRemaining(
            child: NoListsEmptyState(
              onCreateList: isAdmin
                  ? null
                  : () => context.push(AppRoutes.createList),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final list = lists[index];
                
                return Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.read(currentUserProvider);
                    final isAdmin = currentUser?.isAdmin ?? false;
                    
                    // Admin can always delete. Employee can delete if list is draft.
                    final canDelete = isAdmin || list.status.isDraft;

                    final card = Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXXS),
                      child: ListCard(
                        list: list,
                        index: index,
                        onTap: () => context.push(
                          AppRoutes.listDetailPath(list.id),
                        ),
                      ),
                    );

                    if (!canDelete) return card;

                    return Dismissible(
                      key: ValueKey(list.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
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
                        );
                      },
                      onDismissed: (_) async {
                        try {
                          final repository = ref.read(shoppingListRepositoryProvider);
                          await DeleteListUseCase(repository).call(
                            DeleteListParams(listId: list.id, isAdmin: isAdmin),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🗑️ Lista excluída com sucesso!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $e')),
                          );
                        }
                      },
                      child: card,
                    );
                  }
                );
              },
              childCount: lists.length,
            ),
          ),
  };
}
