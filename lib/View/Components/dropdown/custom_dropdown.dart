// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  List<String> items;

  CustomDropDown({required this.items, super.key});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String selectedCat = "";

  @override
  void initState() {
    getInitState();
    super.initState();
  }

  getInitState() {
    selectedCat = widget.items[0];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        isExpanded: true,
        value: selectedCat,
        items: widget.items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: (val) {
          selectedCat = val.toString();
          setState(() {});
        });
  }
}
