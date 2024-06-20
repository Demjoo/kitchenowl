import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kitchenowl/app.dart';
import 'package:kitchenowl/cubits/auth_cubit.dart';
import 'package:kitchenowl/cubits/expense_list_cubit.dart';
import 'package:kitchenowl/cubits/household_cubit.dart';
import 'package:kitchenowl/cubits/planner_cubit.dart';
import 'package:kitchenowl/cubits/recipe_list_cubit.dart';
import 'package:kitchenowl/cubits/shoppinglist_cubit.dart';
import 'package:kitchenowl/enums/views_enum.dart';
import 'package:kitchenowl/models/household.dart';
import 'package:kitchenowl/pages/household_page/household_drawer.dart';
import 'package:kitchenowl/pages/household_page/household_navigation_rail.dart';
import 'package:kitchenowl/pages/page_not_found.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HouseholdPage extends StatefulWidget {
  final Household household;
  final Widget child;
  const HouseholdPage({
    super.key,
    required this.household,
    required this.child,
  });

  @override
  _HouseholdPageState createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late final HouseholdCubit householdCubit;
  late final ShoppinglistCubit shoppingListCubit;
  late final RecipeListCubit recipeListCubit;
  late final PlannerCubit plannerCubit;
  late final ExpenseListCubit expenseListCubit;

  @override
  void initState() {
    super.initState();
    householdCubit = HouseholdCubit(widget.household);
    shoppingListCubit = ShoppinglistCubit(
      widget.household,
      () => App.settings.recentItemsCount,
    );
    recipeListCubit = RecipeListCubit(widget.household);
    plannerCubit = PlannerCubit(widget.household);
    expenseListCubit = ExpenseListCubit(widget.household);
  }

  @override
  void dispose() {
    householdCubit.close();
    shoppingListCubit.close();
    recipeListCubit.close();
    plannerCubit.close();
    expenseListCubit.close();
    super.dispose();
  }

  void _onItemTapped(
    BuildContext context,
    ViewsEnum tapped,
    ViewsEnum current,
  ) {
    householdCubit.refresh();
    switch (tapped) {
      case ViewsEnum.items:
        if (tapped == current) {
          shoppingListCubit.refresh(query: '');
        } else {
          shoppingListCubit.refresh();
        }
        break;
      case ViewsEnum.recipes:
        if (tapped == current) {
          recipeListCubit.refresh("");
        } else {
          recipeListCubit.refresh();
        }
        break;
      case ViewsEnum.planner:
        plannerCubit.refresh();
        break;
      case ViewsEnum.balances:
        expenseListCubit.refresh();
        break;
      default:
        break;
    }
    context.go("/household/${widget.household.id}/${tapped.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: householdCubit),
        BlocProvider.value(value: shoppingListCubit),
        BlocProvider.value(value: recipeListCubit),
        BlocProvider.value(value: plannerCubit),
        BlocProvider.value(value: expenseListCubit),
      ],
      child: BlocConsumer<HouseholdCubit, HouseholdState>(
        listener: (context, state) {
          if (state is NotFoundHouseholdState && mounted) {
            return context.go("/household");
          }
          List<ViewsEnum> pages =
              (state.household.viewOrdering ?? ViewsEnum.values)
                  .where((e) => e.isViewActive(state.household))
                  .toList();

          int _selectedIndex = pages.indexWhere(
            (e) => GoRouterState.of(context).uri.path.contains(e.toString()),
          );

          if (_selectedIndex < 0 && mounted) {
            context.go(
              "/household/${state.household.id}/${state.household.viewOrdering?.firstOrNull.toString() ?? "items"}",
            );
          }
        },
        builder: (context, state) {
          List<ViewsEnum> pages =
              (state.household.viewOrdering ?? ViewsEnum.values)
                  .where((e) => e.isViewActive(state.household))
                  .toList();

          int _selectedIndex = pages.indexWhere(
            (e) => GoRouterState.of(context).uri.path.contains(e.toString()),
          );

          if (_selectedIndex < 0 || state is NotFoundHouseholdState) {
            return const PageNotFound();
          }

          final bool useBottomNavigationBar = getValueForScreenType<bool>(
            context: context,
            mobile: true,
            tablet: false,
            desktop: false,
          );

          Widget body = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(width: 1600),
              child: widget.child,
            ),
          );

          if (!useBottomNavigationBar) {
            final bool extendedRail = getValueForScreenType<bool>(
              context: context,
              mobile: false,
              tablet: false,
              desktop: true,
            );
            body = Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => HouseholdNavigationRail(
                      extendedRail: extendedRail,
                      pages: pages,
                      onPageSelected: _onItemTapped,
                      openDrawer: scaffoldKey.currentState!.openDrawer,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                ),
                Expanded(child: body),
              ],
            );
          }

          return Scaffold(
            key: scaffoldKey,
            body: body,
            floatingActionButton:
                pages[_selectedIndex].floatingActionButton(context),
            drawer: HouseholdDrawer(
              onPageSelected: _onItemTapped,
              pages: pages,
              selectedIndex: _selectedIndex,
              popOnSelection: true,
            ),
            drawerEnableOpenDragGesture: false,
            bottomNavigationBar: useBottomNavigationBar
                ? BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => NavigationBar(
                      labelBehavior:
                          NavigationDestinationLabelBehavior.onlyShowSelected,
                      destinations: pages
                          .map((e) => NavigationDestination(
                                icon: Icon(e.toIcon(context)),
                                label: e.toLocalizedShortString(context),
                                tooltip: e.toLocalizedString(context),
                              ))
                          .toList(),
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (i) => _onItemTapped(
                        context,
                        pages[i],
                        pages[_selectedIndex],
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
