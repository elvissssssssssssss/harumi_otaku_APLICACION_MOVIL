// lib/widgets/quantity_selector.dart
import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int stock;
  final int maxQuantity;
  final Function(int) onQuantityChanged;

  const QuantitySelector({
    Key? key,
    required this.stock,
    required this.maxQuantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final max = widget.stock < widget.maxQuantity
        ? widget.stock
        : widget.maxQuantity;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 1
              ? () {
                  setState(() {
                    quantity--;
                    widget.onQuantityChanged(quantity);
                  });
                }
              : null,
        ),
        Text('$quantity', style: const TextStyle(fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: quantity < max
              ? () {
                  setState(() {
                    quantity++;
                    widget.onQuantityChanged(quantity);
                  });
                }
              : null,
        ),
        const SizedBox(width: 8),
        Text('(Stock: ${widget.stock})'),
      ],
    );
  }
}
