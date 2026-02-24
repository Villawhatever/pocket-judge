import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:pocket_judge/widgets/app_wrapper.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => SearchViewState();
}
class User {
  final String name;
  final int id;

  User({required this.name, required this.id});

  @override
  String toString() {
    return 'User(name: $name, id: $id)';
  }
}

class SearchViewState extends State<SearchView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var items = [
      DropdownItem(label: 'Nepal', value: User(name: 'Nepal', id: 1)),
      DropdownItem(label: 'Australia', value: User(name: 'Australia', id: 6)),
      DropdownItem(label: 'India', value: User(name: 'India', id: 2)),
      DropdownItem(label: 'China', value: User(name: 'China', id: 3)),
      DropdownItem(label: 'USA', value: User(name: 'USA', id: 4)),
      DropdownItem(label: 'UK', value: User(name: 'UK', id: 5)),
      DropdownItem(label: 'Germany', value: User(name: 'Germany', id: 7)),
      DropdownItem(label: 'France', value: User(name: 'France', id: 8)),
    ];

    return AppWrapper(
      title: const Text('Card Search'),
      body: Form(
        key: _formKey,
        child: MultiDropdown<User>(
          items: items,
          enabled: true,
          searchEnabled: true,
          chipDecoration: const ChipDecoration(
            backgroundColor: Colors.yellow,
            wrap: true,
            runSpacing: 2,
            spacing: 10,
          ),
          fieldDecoration: FieldDecoration(
            hintText: 'Domain(s)',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.black87,
              ),
            ),
          ),
          dropdownDecoration: const DropdownDecoration(
            marginTop: 2,
            maxHeight: 500,
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Select countries from the list',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon:
            const Icon(Icons.check_box, color: Colors.green),
            disabledIcon:
            Icon(Icons.lock, color: Colors.grey.shade300),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
          onSelectionChange: (selectedItems) {
            debugPrint("OnSelectionChange: $selectedItems");
          },
        ),
        // child: Column(
        //
        //   children: [
        //     TextFormField(
        //       decoration: const InputDecoration(
        //           labelText: 'Card Name'
        //       ),
        //     ),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         Column(
        //           children: [
        //             Text('bit 1 column a'),
        //
        //           ]
        //         ),
        //         Column(
        //             children: [
        //               Text('bit 1 column b')
        //             ]
        //         )
        //       ]
        //     )
        //   ]
        // )
      ),
    );
  }
}
