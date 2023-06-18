import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Nothing is here add something'),
    );

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
