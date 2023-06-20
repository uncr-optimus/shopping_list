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
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'flutter-prep-710e6-default-rtdb.firebaseio.com', 'shopping-list.json');

    try{
      final response = await http.get(url);

          if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data please try again later';
      });
    }

    if(response.body == null){        //if list is empty then we have to stop loading icon and return from there  //also firebase return null if list is empty other database might return empty string or any other thing  //we can check it through status or response.body
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);    //it will always show loading screen if list were empty cuz we are trying to decode the response body which is null
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
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
    }catch(error){
      setState(() {
        _error = 'Something went wrong. please try again later';
      });
    }
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

  void _removeItem(GroceryItem item)async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-710e6-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
   final response = await http.delete(url);
    if(response.statusCode >= 400){
      //Optional show error message
      setState(() {
        _groceryItems.insert(index, item);  //use insert instead of add cuz insert also want index and value
      });
    }
  }

  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Nothing is here add something'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        //we can have dozen or hundred of dummy data in future so its preferable to use listview instead of coulum since it also give option to scroll
        itemCount: _groceryItems
            .length, //prev itemCount: groceryItems.length, from here substitute all the groceryItems with _groceryItems since we are creating new list here previously we are using dummy data
        itemBuilder: (context, index) => Dismissible(
          child: ListTile(
            //we can us erow widget here but ListTile come with some built in list optimized styling , alsogive some inbuilt feature
            title: Text(_groceryItems[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

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
      body: content,
    );
  }
}
