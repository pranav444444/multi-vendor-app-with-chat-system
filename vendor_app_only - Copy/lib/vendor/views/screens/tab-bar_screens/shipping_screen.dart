import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_only/vendor/provider/product_provider.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({Key? key}) : super(key: key);

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool? _chargeShipping = false;
  final TextEditingController _shippingCostController = TextEditingController();

  @override
  void dispose() {
    _shippingCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ProductProvider _productProvider = Provider.of<ProductProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Card(
            child: CheckboxListTile(
              title: const Text(
                'Charge Shipping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              value: _chargeShipping,
              onChanged: (value) {
                setState(() {
                  _chargeShipping = value;
                  if (_chargeShipping == false) {
                    _shippingCostController.clear();
                  }
                  _productProvider.getFormData(
                    chargeShipping: _chargeShipping,
                    shippingCharge: _chargeShipping == true ? 
                      double.tryParse(_shippingCostController.text) ?? 0.0 : 
                      0.0,
                  );
                });
              },
            ),
          ),
          if (_chargeShipping == true)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _shippingCostController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Shipping Charge',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                  suffixText: '\$',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Shipping Charge';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  double? shippingCharge = double.tryParse(value);
                  if (shippingCharge != null) {
                    _productProvider.getFormData(
                      chargeShipping: _chargeShipping,
                      shippingCharge: shippingCharge,  // Pass the double value directly
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
