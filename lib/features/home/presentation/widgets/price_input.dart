import 'package:flutter/material.dart';
import 'package:grocerai/features/home/domain/grocery.dart';

class PriceInput extends StatefulWidget {
  final GroceryItem item;
  final VoidCallback onTotalChanged;

  const PriceInput({super.key, required this.item, required this.onTotalChanged});

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.price > 0 ? widget.item.price.toString() : "",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.price != oldWidget.item.price) {
      setState(() {
        _controller.text = widget.item.price > 0 ? widget.item.price.toString() : "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: 60,
        child: TextFormField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: "0.00",
            isDense: true,
            border: InputBorder.none,
          ),
          onChanged: (val) {
            // This makes sure the total updates AS you type or scan
            widget.item.price = double.tryParse(val) ?? 0.0;
            widget.onTotalChanged();
          },
        ),
      ),
    );
  }
}