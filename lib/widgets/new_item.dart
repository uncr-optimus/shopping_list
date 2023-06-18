import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables];

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      //to save the item it shoukd be validate first so we can't assign default value
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        GroceryItem(
            id: DateTime.now().toString(),
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory!),
      );
      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a New Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          //use to take user input validating user input ,showing on screen validation errors
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                //instead of textField() since Textformfield integrate with form widget to give additional feature
                maxLength: 20,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length >= 50) {
                    return 'Must be between 1 and 50';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must put valid number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      // we could use onSaved property here but we already storing the selected value through onChanged method
                      value:
                          _selectedCategory, //initialValue does'nt support in dropdownbutton
                      items: [
                        for (final category in categories
                            .entries) //since categories is not a simple list but it is list of map so we have to use .entries to access it
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
