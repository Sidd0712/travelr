import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AddressAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(dynamic value) onLocationSelected;

  const AddressAutocomplete({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onLocationSelected,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  var uuid = Uuid();
  String sessionToken = "";
  List<dynamic> listOfLocation = [];

  bool isLoading = false;
  Timer? _debounce;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    sessionToken = uuid.v4();
    widget.controller.addListener(_onChange);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
        _insertOverlay();
      } else {
        // Delay removal to let onTap register
        Future.delayed(Duration(milliseconds: 100), () {
          if (!_focusNode.hasFocus) {
            _removeOverlay();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onChange() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.controller.text.isNotEmpty) {
        placeSuggestion(widget.controller.text);
        _insertOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _insertOverlay() {
    _overlayEntry?.remove(); // remove old one if any
    _overlayEntry = _createOverlayEntry();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      if (_overlayEntry != null) {
        overlay.insert(_overlayEntry!);
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        left: offset.dx,
        top: offset.dy + size.height + 4,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0.0, size.height + 4),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : listOfLocation.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No results found"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: min(listOfLocation.length, 3),
                        itemBuilder: (context, index) {
                          final desc = listOfLocation[index]["description"];
                          return ListTile(
                            title: Text(desc),
                            onTap: () {
                              print("Tapped");
                              final selectedPlace = listOfLocation[index];
                              final desc = selectedPlace["description"];
                              final placeId = selectedPlace["place_id"];

                              widget.onLocationSelected(placeId);

                              widget.controller.removeListener(_onChange);

                              setState(() {
                                widget.controller.text = desc;
                                listOfLocation.clear();
                              });

                              _removeOverlay();
                              _focusNode.unfocus();

                              widget.controller.addListener(_onChange);
                            },
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  void placeSuggestion(String input) async {
    if (input.isEmpty) {
      setState(() {
        listOfLocation.clear();
      });
      _removeOverlay();
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String baseUrl = "https://travelr-ml.onrender.com/autocomplete";
      String request = '$baseUrl?input=$input';

      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = json.decode(response.body)['suggestions'];
        });
      } else {
        throw Exception("Failed to load suggestions");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
      _insertOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.all(15),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: const BorderSide(),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }
}
