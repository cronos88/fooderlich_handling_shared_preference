import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  // searches array
  List<String> previousSearches = <String>[];
  // TODO: Add _currentRecipes1

  @override
  void initState() {
    super.initState();
    // TODO: Call loadRecipes()

    // getPreviousSearches
    getPreviousSearches();
    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  // TODO: Add loadRecipes

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  // savePreviousSearches
  void savePreviousSearches() async {
    // 1. Utiliza la palabra clave await para esperar una instancia de
    // SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // 2. Guarda la lista de búsquedas anteriores utilizando la tecla
    // prefSearchKey.
    prefs.setStringList(prefSearchKey, previousSearches);
  }

  // Add getPreviousSearches
  void getPreviousSearches() async {
    // 1. Utilice la palabra clave await para esperar una instancia de
    // SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // 2. Compruebe si ya existe una preferencia para su lista guardada.
    if (prefs.containsKey(prefSearchKey)) {
      // 3. Obtener la lista de búsquedas anteriores.
      final searches = prefs.getStringList(prefSearchKey);
      // 4. Si la lista no es nula, establezca las búsquedas anteriores, de lo
      // contrario, inicialice una lista vacía.
      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // Replace
            const Icon(Icons.search),
            const SizedBox(
              width: 6.0,
            ),
            // *** Start Replace
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
                      controller: searchTextController,
                      onChanged: (query) => {
                        if (query.length >= 3)
                          {
                            // Rebuild list
                            setState(
                              () {
                                currentSearchList.clear();
                                currentCount = 0;
                                currentEndPosition = pageCount;
                                currentStartPosition = 0;
                              },
                            )
                          }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // *** End Replace
          ],
        ),
      ),
    );
  }

  // TODO: Add startSearch

  // TODO: Replace method
  Widget _buildRecipeLoader(BuildContext context) {
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // Show a loading indicator while waiting for the movies
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // TODO: Add _buildRecipeCard
}
