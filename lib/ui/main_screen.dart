import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colors.dart';
import 'myrecipes/my_recipes_list.dart';
import 'recipes/recipe_list.dart';
import 'shopping/shopping_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> pageList = <Widget>[];
  // Add index key
  static const String prefSelectedIndexKey = 'selectedIndex';

  @override
  void initState() {
    super.initState();
    pageList.add(const RecipeList());
    pageList.add(const MyRecipesList());
    pageList.add(const ShoppingList());
    // Call getCurrentIndex
    // Eso recuperará el índice seleccionado actualmente cuando se cargue la
    // página.
    getCurrentIndex();
  }

  // saveCurrentIndex
  void saveCurrentIndex() async {
    // 1. Utilice la palabra clave await para esperar una instancia del paquete
    // SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // 2. Guarde el índice seleccionado como un número entero.
    prefs.setInt(prefSelectedIndexKey, _selectedIndex);
  }

  // Add getCurrentIndex
  void getCurrentIndex() async {
    // 1. Utilice la palabra clave await para esperar una instancia de
    // sharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // 2. Compruebe si ya existe una preferencia por su índice actual.
    if (prefs.containsKey(prefSelectedIndexKey)) {
      // 3. Obtenga el índice actual y actualice el estado en consecuencia.
      setState(() {
        final index = prefs.getInt(prefSelectedIndexKey);
        if (index != null) {
          _selectedIndex = index;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Call saveCurrentIndex
    // Esto guarda el índice actual cada vez que el usuario selecciona una
    // pestaña diferente.
    saveCurrentIndex();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = 'Recipes';
        break;
      case 1:
        title = 'Bookmarks';
        break;
      case 2:
        title = 'Groceries';
        break;
      default:
        title = 'Recipes';
        break;
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icon_recipe.svg',
                  color: _selectedIndex == 0 ? green : Colors.grey,
                  semanticsLabel: 'Recipes'),
              label: 'Recipes'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icon_bookmarks.svg',
                  color: _selectedIndex == 1 ? green : Colors.grey,
                  semanticsLabel: 'Bookmarks'),
              label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/images/icon_shopping_list.svg',
                  color: _selectedIndex == 2 ? green : Colors.grey,
                  semanticsLabel: 'Groceries'),
              label: 'Groceries'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: green,
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.white,
          //Navigation bar divider color
          systemNavigationBarIconBrightness:
              Brightness.light, //navigation bar icon
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pageList,
      ),
    );
  }
}

// SIGUE LA PAGINA 362 - SAVING THE SELECTED TAB
