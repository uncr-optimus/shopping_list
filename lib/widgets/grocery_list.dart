import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItem();
  }

  Future<List<GroceryItem>> _loadItem() async {
    final url = Uri.https(
        'flutter-prep-710e6-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery item. Please try again later');
    }

    if (response.body == null) {
      //if list is empty then we have to stop loading icon and return from there  //also firebase return null if list is empty other database might return empty string or any other thing  //we can check it through status or response.body
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response
        .body); //it will always show loading screen if list were empty cuz we are trying to decode the response body which is null
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return loadedItems;
  }

  @override
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-710e6-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //Optional show error message
      throw Exception('Failled to fetch grocery Items. Please try agin later');
    }
  }

  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Nothing is here add something'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No idem add yet'),
            );
          }
          return ListView.builder(
            //we can have dozen or hundred of dummy data in future so its preferable to use listview instead of coulum since it also give option to scroll
            itemCount: snapshot.data!
                .length, //prev itemCount: groceryItems.length, from here substitute all the groceryItems with _groceryItems since we are creating new list here previously we are using dummy data
            itemBuilder: (context, index) => Dismissible(
              child: ListTile(
                //we can us erow widget here but ListTile come with some built in list optimized styling , alsogive some inbuilt feature
                title: Text(snapshot.data![index].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
              key: ValueKey(snapshot.data![index].id),
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
            ),
          );
        },
      ),
    );
  }
}
