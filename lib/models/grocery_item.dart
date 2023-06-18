import 'package:shopping_list/models/category.dart';

class GroceryItem {
 const  GroceryItem(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.category});

  final String id;
  final String name;
  final int quantity;
  final Category category;     //we are defining category here because categories.fruit is passing to category dart file via categories dart file to category class
}
