import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/features/home/domain/grocery.dart';
import 'package:grocerai/features/home/presentation/bloc/list_bloc/list_bloc.dart';

class PriceInput extends StatefulWidget {
  final GroceryItem item;

  const PriceInput({super.key, required this.item});

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.price > 0 ? widget.item.price.toStringAsFixed(2) : "",
    );
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _formatPrice();
      }
    });
  }

  @override
  void didUpdateWidget(PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.price.toString() != _controller.text && !_controller.selection.isValid) {
      _controller.text = widget.item.price > 0 ? widget.item.price.toStringAsFixed(2) : "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _formatPrice() {
    final double currentPrice = double.tryParse(_controller.text) ?? 0.0;
    if (currentPrice > 0) {
      setState(() {
        _controller.text = currentPrice.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          prefixText: '\$',
          hintText: "0.00",
          isDense: true,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          final double newPrice = double.tryParse(val) ?? 0.0;
          context.read<ListBloc>().add(UpdatePrice(widget.item, newPrice));
        },
        onFieldSubmitted: (_) => _formatPrice(),
      ),
    );
  }
}