import 'package:flutter/material.dart';
import 'package:my_shop/providers/models/product.dart';
import 'package:my_shop/providers/products_provider.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({key}) : super(key: key);

  static const routeName = '/edit-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //1- to manage focus of keyboard wehn user presses the next button on keyboard
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formGlobalKey = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;

  Product _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<ProductsProvider>(context).getProductById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(() {
      _updateImageUrl();
    });
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveFrom() async {
    final isValid = _formGlobalKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formGlobalKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error'),
                  content: Text('something went wrong!'),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Ok'),
                    ),
                  ],
                ));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(); //to close the current page and go back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add/Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              _saveFrom();
            },
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formGlobalKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a name.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                                _priceFocusNode); //3- to move the cursor of keyboard to the especific textfield after clicking on next botton on keyboard
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: value,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(
                            labelText: 'Price',
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a price.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price.';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter a price greather than zero.';
                            }
                            return null;
                          },
                          focusNode:
                              _priceFocusNode, //2-connecting focus variable to  focus parameter of textField
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                                _descriptionFocusNode); //3- to move the cursor of keyboard to the especific textfield after clicking on next botton on keyboard
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(value),
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            // FocusScope.of(context).requestFocus(
                            //     _priceFocusNode); //3- to move the cursor of keyboard to the especific textfield after clicking on next botton on keyboard
                          },
                          focusNode: _descriptionFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter description.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: value,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // initialValue: _initValues['imageUrl'],
                                decoration: InputDecoration(
                                  labelText: 'Image URL',
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                focusNode: _imageUrlFocusNode,
                                controller: _imageUrlController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an image URL1.';
                                  }
                                  // if (!value.startsWith('http') ||
                                  //     !value.startsWith('https') ||
                                  //     !value.startsWith('HTTP') ||
                                  //     !value.startsWith('HTTPS')) {
                                  //   return 'Please enter a valid image URL2.';
                                  // }
                                  // if (!value.endsWith('.png') ||
                                  //     !value.endsWith('.jpg') ||
                                  //     !value.endsWith('.jpeg')) {
                                  //   return 'Please enter a valid image URL3.';
                                  // }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  _saveFrom();
                                },
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                onSaved: (value) {
                                  _editedProduct = Product(
                                    id: _editedProduct.id,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value,
                                    isFavorite: _editedProduct.isFavorite,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
    );
  }
}
