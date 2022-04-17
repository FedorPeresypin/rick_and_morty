import 'dart:convert';
import 'dart:developer';

import 'package:rick_and_morty/core/errors/exception.dart';
import 'package:rick_and_morty/feature/data/models/person_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersonLocalDataSource {
  /// Gets the cached [List<PersonModel>] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.

  Future<List<PersonModel>> getLastPersonFromCache();
  Future<void> personToCache(List<PersonModel> persons);
}

const cachedPersonList = 'CACHED_PERSON_LIST';

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  final SharedPreferences sharedPreferences;

  PersonLocalDataSourceImpl({required this.sharedPreferences});
  @override
  Future<List<PersonModel>> getLastPersonFromCache() {
    final List<String>? jsonPersonList = sharedPreferences.getStringList(cachedPersonList);
    if (jsonPersonList?.isNotEmpty ?? false) {
      return Future.value(jsonPersonList!.map((person) => PersonModel.fromJson(jsonDecode(person))).toList());
    } else {
      throw CacheException;
    }
  }

  @override
  Future<List<String>> personToCache(List<PersonModel> persons) {
    final List<String> jsonPersonList = persons.map((person) => jsonEncode(person.toJson())).toList();
    sharedPreferences.setStringList(cachedPersonList, jsonPersonList);
    log('Person to write Cache: ${jsonPersonList.length}');
    return Future.value(jsonPersonList);
  }
}
