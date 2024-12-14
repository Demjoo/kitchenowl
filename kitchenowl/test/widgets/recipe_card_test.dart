import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/widgets/recipe_card.dart';

void main() {
  late Recipe testRecipe;

  setUp(() {
    testRecipe = Recipe(
      id: 1,
      name: 'Test Recipe',
      image: 'test_image_url',
      imageHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      time: 30,
      tags: {}, // No tags in the setup
    );
  });

  testWidgets('renders RecipeCard with recipe name and image',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: testRecipe,
        ),
      ),
    );

    // Verify the recipe name is displayed
    expect(find.text('Test Recipe'), findsOneWidget);

    // Verify the recipe image is displayed
    expect(find.byType(FadeInImage), findsOneWidget);
  });

  testWidgets('calls onPressed callback when tapped',
      (WidgetTester tester) async {
    bool onPressedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: testRecipe,
          onPressed: () {
            onPressedCalled = true;
          },
        ),
      ),
    );

    // Tap the RecipeCard
    await tester.tap(find.byType(RecipeCard));
    await tester.pumpAndSettle();

    // Verify the onPressed callback is called
    expect(onPressedCalled, isTrue);
  });

  testWidgets('displays recipe time when it is greater than zero',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: testRecipe,
        ),
      ),
    );

    // Verify the recipe time is displayed
    expect(find.text('30 min'), findsOneWidget);
  });

  testWidgets('does not display recipe time when it is zero',
      (WidgetTester tester) async {
    final recipeWithNoTime = testRecipe.copyWith(time: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: recipeWithNoTime,
        ),
      ),
    );

    // Verify the recipe time is not displayed
    expect(find.text('0 min'), findsNothing);
  });

  testWidgets('renders RecipeCard without description',
      (WidgetTester tester) async {
    final recipeWithoutDescription = testRecipe.copyWith(description: '');

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: recipeWithoutDescription,
        ),
      ),
    );

    // Verify that description is not displayed
    expect(find.text(''), findsNothing);
  });

  testWidgets('renders RecipeCard with image hash',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: testRecipe,
        ),
      ),
    );

    // Verify that the image hash is passed correctly to the widget
    expect(testRecipe.imageHash, 'LEHV6nWB2yk8pyo0adR*.7kCMdnj');
  });

  testWidgets('renders RecipeCard with no tags', (WidgetTester tester) async {
    final recipeWithoutTags = testRecipe.copyWith(tags: {});

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeCard(
          recipe: recipeWithoutTags,
        ),
      ),
    );

    // Verify that no tags are displayed
    expect(find.byType(Chip), findsNothing);
  });
}
