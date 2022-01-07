import 'dart:convert';
import 'package:kitchenowl/models/recipe.dart';
import 'package:kitchenowl/models/tag.dart';
import 'package:kitchenowl/services/api/api_service.dart';

extension TagApi on ApiService {
  Future<Set<Tag>> getAllTags() async {
    final res = await get('/tag');
    if (res.statusCode != 200) return null;

    final body = List.from(jsonDecode(res.body));
    return body.map((e) => Tag.fromJson(e)).toSet();
  }

  Future<bool> addTag(Tag tag) async {
    final res = await post('/tag', json.encode(tag.toJson()));
    return res.statusCode == 200;
  }

  Future<Tag> getTag(Tag tag) async {
    final res = await get('/tag/${tag.id}');
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    return Tag.fromJson(body);
  }

  Future<List<Recipe>> getTagRecipes(Tag tag) async {
    final res = await get('/tag/${tag.id}/recipes');
    if (res.statusCode != 200) return null;

    final body = List.from(jsonDecode(res.body));
    return body.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<Set<Tag>> searchTags(String query) async {
    final res = await get('/tag/search?query=$query');
    if (res.statusCode != 200) return null;

    final body = List.from(jsonDecode(res.body));
    return body.map((e) => Tag.fromJson(e)).toSet();
  }

  Future<bool> deleteTag(Tag tag) async {
    final res = await delete('/tag/${tag.id}');
    return res.statusCode == 200;
  }
}