import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'Mydrawer.dart'; // Import your drawer widget

class BaseLayout extends StatefulWidget {
  final Widget child;
  final Widget title;

  BaseLayout({required this.child, required this.title});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  bool _isSearching = false;  // Flag to toggle search mode
  TextEditingController _searchController = TextEditingController();

  List<dynamic> searchResults = [];  // Store search results
  OverlayEntry? _overlayEntry;  // Overlay to display suggestions
  LayerLink _layerLink = LayerLink();  // LayerLink to position the dropdown correctly

  @override
  void dispose() {
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> search(String query) async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic>? chapters = box.get('chapters'); // Get data from Hive

    if (chapters != null) {

      List<dynamic> results = chapters
          .where((chapter) => chapter['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        searchResults = results;
      });

      _updateOverlay();
    }
  }

  void _onSuggestionSelected(dynamic suggestion) async {
    print('Selected: ${suggestion}');
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('books');

    if (value != null) {
      var type = "image";

      for (int i = 0; i < value.length; i++) {
        if (value[i]['book_id'] == suggestion['book-id']) {
          type = value[i]['content_type_name'];
          break;
        }

      }
      Navigator.pushNamed(
          context, '/file', arguments: {"type": type, "data": suggestion});
    }
  }

  void _updateOverlay() {

    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }


    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }


  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.7,  // Same width as the search field
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, 60.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              color: Colors.yellow[700],
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final suggestion = searchResults[index];
                  return ListTile(
                    textColor: Colors.black,

                    title: Text(suggestion['title']),
                    onTap: () {
                      _onSuggestionSelected(suggestion);  // Handle suggestion selection
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF2C2),
      appBar: AppBar(
        title: _isSearching
            ? CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: Colors.black),
            onChanged: (query) {
              search(query);  // Call the search function when typing
            },
          ),
        )
            : widget.title,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  // Exit search mode
                  _isSearching = false;
                  _searchController.clear();  // Clear the search query
                  searchResults.clear();  // Clear the results
                  _overlayEntry?.remove();  // Remove the overlay if present
                } else {
                  // Enter search mode
                  _isSearching = true;
                }
              });
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
      ),
      drawer: MyDrawer(),
      body: widget.child,  // The body will be the content of the specific page
    );
  }
}
