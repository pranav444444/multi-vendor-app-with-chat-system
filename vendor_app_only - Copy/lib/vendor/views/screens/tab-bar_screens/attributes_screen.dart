import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_only/vendor/provider/product_provider.dart';  // Update this import path

class AttributesScreen extends StatefulWidget {
  @override
  State<AttributesScreen> createState() => _AttributesScreenState();
}

class _AttributesScreenState extends State<AttributesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _sizeController = TextEditingController();
  bool _entered = false;
  List<String> _sizeList = [];
  bool _isSave = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Change this line
    final productProvider = Provider.of<ProductProvider>(context, listen: true);
    
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // Update provider references
          TextFormField(
            onChanged: (value) {
              productProvider.getFormData(brandName: value);
            },
            decoration: InputDecoration(
              labelText: 'Brand',
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Container(
                  width: 100,
                  child: TextFormField(
                    controller: _sizeController,
                    onChanged: (value) {
                      setState(() {
                        _entered = true;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Size',
                    ),
                  ),
                ),
              ),
              _entered == true
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade900,
                      ),
                      onPressed: () {
                        setState(() {
                          _sizeList.add(_sizeController.text);
                          _sizeController.clear();
                        });

                        print(_sizeList);
                      },
                      child: Text(
                        'Add',
                      ),
                    )
                  : Text(''),
            ],
          ),
          if (_sizeList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sizeList.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _sizeList.removeAt(index);
                            productProvider.getFormData(sizeList: _sizeList);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.yellow.shade800,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _sizeList[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          if (_sizeList.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                productProvider.getFormData(sizeList: _sizeList);
                setState(() {
                  _isSave = true;
                });
              },
              child: Text(
                _isSave ? 'Saved' : 'save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}