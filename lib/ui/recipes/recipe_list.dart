import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import '../widgets/custom_dropdown.dart';

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
            IconButton(
              icon: const Icon(Icons.search),
              // 1. Agregue onPressed para manejar el evento de toque.
              onPressed: () {
                // 2. Use the current search text to start a search.
                startSearch(searchTextController.text);
                // 3. Oculte el teclado usando la clase FocusScope.
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            // *** Start Replace
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    // 3. Agregue un TextField para ingresar sus consultas de
                    // búsqueda.
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
                      // 4. Set the keyboard action to TextInputAction.done.
                      // This closes the keyboard when the user presses the
                      // Done button.
                      textInputAction: TextInputAction.done,
                      // 5. Inicie la búsqueda cuando el usuario termine de
                      // ingresar texto.

                      onSubmitted: (value) {
                        startSearch(searchTextController.text);
                      },
                      controller: searchTextController,
                    ),
                  ),
                  // 6. Crea un PopupMenuButton pa mostrar búsquedas anteriores.
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    // 7. Cuando el usuario selecciona un elemento de búsquedas
                    // anteriores, inicia una nueva búsqueda.
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      // 8. Crea una lista de menús desplegables personalizados
                      // (ver widgets/custom_dropdown.dart) para mostrar
                      // búsquedas anteriores.
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          value: value,
                          text: value,
                          callback: () {
                            setState(() {
                              // 9. If the X icon is pressed, remove the search
                              // from the previous searches and close the
                              // pop-up menu.
                              previousSearches.remove(value);
                              savePreviousSearches();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
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

  // Add startSearch
  void startSearch(String value) {
    // 1. Le dice al sistema que vuelva a dibujar los widgets llamando a
    // setState().
    setState(() {
      // 2. Borra la lista de búsqueda actual y restablezca las posiciones de
      // conteo, inicio y finalización.
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();

      // 3. Asegúrese de que el texto de búsqueda no se haya agregado ya a la
      // lista de búsqueda anterior.
      if (!previousSearches.contains(value)) {
        // 4. Agregue el elemento de búsqueda a la lista de búsqueda anterior.
        previousSearches.add(value);
        // 5. Guarda la nueva lista de búsquedas anteriores.
        savePreviousSearches();
      }
    });
  }

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
