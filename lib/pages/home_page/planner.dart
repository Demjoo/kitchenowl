import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchenowl/cubits/auth_cubit.dart';
import 'package:kitchenowl/cubits/planner_cubit.dart';
import 'package:kitchenowl/enums/update_enum.dart';
import 'package:kitchenowl/kitchenowl.dart';
import 'package:kitchenowl/pages/recipe_page.dart';
import 'package:kitchenowl/services/api/api_service.dart';
import 'package:kitchenowl/widgets/selectable_button_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PlannerPage extends StatefulWidget {
  PlannerPage({Key key}) : super(key: key);

  @override
  _PlannerPageState createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<PlannerCubit>(context);
    final int crossAxisCount = getValueForScreenType<int>(
      context: context,
      mobile: 3,
      tablet: 6,
      desktop: 9,
    );
    final isOffline =
        BlocProvider.of<AuthCubit>(context).state is AuthenticatedOffline;
    return SafeArea(
      child: Scrollbar(
        child: RefreshIndicator(
          onRefresh: cubit.refresh,
          child: BlocBuilder<PlannerCubit, PlannerCubitState>(
              bloc: cubit,
              builder: (context, state) {
                if (isOffline) {
                  return Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context).offlineMessage),
                      const SizedBox(width: 5),
                      Icon(Icons.cloud_off_rounded)
                    ],
                  ));
                }
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          height: 80,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).plannerTitle,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                      ),
                    ),
                    if (state.plannedRecipes.length == 0)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.no_food_rounded),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context).plannerEmpty),
                            ],
                          ),
                        ),
                      ),
                    if (state.plannedRecipes.length > 0)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            childAspectRatio: 1,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => SelectableButtonCard(
                              title: state.plannedRecipes[i].name,
                              selected: true,
                              onPressed: () {
                                cubit.remove(state.plannedRecipes[i]);
                              },
                              onLongPressed: () async {
                                final recipe = await ApiService.getInstance()
                                    .getRecipe(state.plannedRecipes[i]);
                                final res = await Navigator.of(context)
                                    .push<UpdateEnum>(MaterialPageRoute(
                                        builder: (context) => RecipePage(
                                              recipe: recipe ??
                                                  state.plannedRecipes[i],
                                            )));
                                if (res == UpdateEnum.updated ||
                                    res == UpdateEnum.deleted) {
                                  cubit.refresh();
                                }
                              },
                            ),
                            childCount: state.plannedRecipes.length,
                          ),
                        ),
                      ),
                    if (state.recentRecipes.length > 0) ...[
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            AppLocalizations.of(context).recipesRecent + ':',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            childAspectRatio: 1,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => SelectableButtonCard(
                              title: state.recentRecipes[i].name,
                              onPressed: () {
                                cubit.add(state.recentRecipes[i]);
                              },
                              onLongPressed: () async {
                                final recipe = await ApiService.getInstance()
                                    .getRecipe(state.recentRecipes[i]);
                                final res = await Navigator.of(context)
                                    .push<UpdateEnum>(MaterialPageRoute(
                                        builder: (context) => RecipePage(
                                              recipe: recipe ??
                                                  state.recentRecipes[i],
                                              updateOnPlanningEdit: true,
                                            )));
                                if (res == UpdateEnum.updated ||
                                    res == UpdateEnum.deleted) {
                                  cubit.refresh();
                                }
                              },
                            ),
                            childCount: state.recentRecipes.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
        ),
      ),
    );
  }
}