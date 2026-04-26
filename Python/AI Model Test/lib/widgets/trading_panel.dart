import 'package:flutter/material.dart';
import '../models/market.dart';

class TradingPanel extends StatefulWidget {
  final Market market;
  final Function(String) onOutcomeSelected;

  const TradingPanel({
    Key? key,
    required this.market,
    required this.onOutcomeSelected,
  }) : super(key: key);

  @override
  State<TradingPanel> createState() => _TradingPanelState();
}

class _TradingPanelState extends State<TradingPanel> {
  late String _selectedOutcome = 'YES';
  late double _selectedPrice;
  double _shares = 1.0;
  final TextEditingController _sharesController =
      TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _selectedPrice = widget.market.yesPrice;
  }

  void _updateOutcome(String outcome) {
    setState(() {
      _selectedOutcome = outcome;
      _selectedPrice =
          outcome == 'YES' ? widget.market.yesPrice : widget.market.noPrice;
      widget.onOutcomeSelected(outcome);
    });
  }

  void _updateShares(String value) {
    setState(() {
      _shares = double.tryParse(value) ?? 1.0;
    });
  }

  double get _totalCost => _shares * _selectedPrice * 100;

  void _placeTrade() {
    final confirmed = _totalCost > 0 && _shares > 0;
    if (!confirmed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order placed: $_shares shares of $_selectedOutcome at ${(_selectedPrice * 100).toStringAsFixed(2)}¢\nTotal: \$${_totalCost.toStringAsFixed(2)}',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );

    _sharesController.clear();
    setState(() {
      _shares = 1.0;
      _sharesController.text = '1.0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Your Prediction',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Outcome Selection
          Row(
            children: [
              Expanded(
                child: _buildOutcomeButton(
                  'YES',
                  widget.market.yesPrice,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOutcomeButton(
                  'NO',
                  widget.market.noPrice,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Shares Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Shares',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sharesController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _updateShares,
                decoration: InputDecoration(
                  hintText: 'Enter number of shares',
                  prefixIcon: const Icon(Icons.apps),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cost Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price per share',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(_selectedPrice * 100).toStringAsFixed(2)}¢',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number of shares',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _shares.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '\$${_totalCost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Buy Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _shares > 0 ? _placeTrade : null,
              child: Text(
                'BUY $_selectedOutcome',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeButton(String outcome, double price, Color color) {
    final isSelected = _selectedOutcome == outcome;
    return GestureDetector(
      onTap: () => _updateOutcome(outcome),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              outcome,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(price * 100).toStringAsFixed(2)}¢',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }
}
