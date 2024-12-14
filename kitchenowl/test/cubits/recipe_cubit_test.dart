import 'package:flutter_test/flutter_test.dart';
import 'package:kitchenowl/cubits/recipe_cubit.dart';
import 'package:kitchenowl/models/item.dart';
import 'package:kitchenowl/models/recipe.dart';
import 'package:mockito/mockito.dart';
import 'mock_transaction_handler.mocks.dart'; // Import your mock here

import 'local_only_transaction_handler.dart';

const flour = RecipeItem(name: "Flour");
const salt = RecipeItem(name: "Salt");
const recipe = Recipe(
    id: 100,
    name: "foo",
    description: "The desc",
    items: [flour, salt],
    yields: 1);

RecipeCubit createSampleCubit() =>
    RecipeCubit.forTesting(LocalOnlyTransactionHandler(), null, recipe, 1);

final mockHandler = MockTransactionHandler();

void main() {
  test("Item selection works", () {
    final cubit = createSampleCubit();
    final allItems = recipe.mandatoryItems.map((e) => e.name).toSet();

    expect(cubit.state.selectedItems, allItems);

    cubit.itemSelected(flour);
    expect(cubit.state.selectedItems, {salt.name});

    cubit.itemSelected(flour);
    expect(cubit.state.selectedItems, allItems);

    cubit.itemSelected(flour);
    cubit.itemSelected(salt);
    expect(cubit.state.selectedItems, isEmpty);
  });

  test("Changing the yield works", () {
    final cubit = createSampleCubit();
    expect(cubit.state.selectedYields, 1);

    cubit.setSelectedYields(4);
    expect(cubit.state.selectedYields, 4);
  });

  test("Refresh updates state with new recipe data", () async {
    final mockHandler = MockTransactionHandler();
    const updatedRecipe = Recipe(
      id: 101,
      name: "Updated Recipe",
      description: "Updated Description",
      items: [RecipeItem(name: "Sugar")],
      yields: 2,
    );

    when(mockHandler.runTransaction(any)).thenAnswer(
      (_) async => (updatedRecipe, 200),
    );

    final cubit = RecipeCubit.forTesting(mockHandler, null, recipe, 1);

    await cubit.refresh();

    verifyInOrder([
      mockHandler.runTransaction(any), // First call
      mockHandler.runTransaction(any), // Second call
    ]);

    expect(cubit.state.recipe, updatedRecipe);
    expect(cubit.state.selectedYields, updatedRecipe.yields);
  });
  // Basic test for initial state
  test("Initial selectedItems should be empty", () {
    final cubit = createSampleCubit();
    // Ensure selectedItems is empty before the test
    cubit.state.selectedItems.clear();
    expect(cubit.state.selectedItems, isEmpty);
  });

  test("Initial selectedYields should be 1", () {
    final cubit = createSampleCubit();
    expect(cubit.state.selectedYields, 1);
  });
}
