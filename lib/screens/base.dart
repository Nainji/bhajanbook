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
  List<dynamic> books=[];
  List<dynamic> chapters=[];
  @override
  void dispose() {
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  String getBookName(id) {
    final b = books.where((element) => element['book_id'] == id);

    return "${b.first['title_hindi']} ";
  }

  Future<void> search(String query) async {


if(chapters.length==0){
  getBooks();
}

    if (chapters != null) {

      List<dynamic> results = chapters
          .where((chapter) => chapter['title'].toLowerCase().contains(query.toLowerCase())||chapter['title-hindi'].toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {

        searchResults = results;
      });

      _updateOverlay();
    }

  }


  getBooks()async{
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('books');

    if(value!=null){
      setState(() {
        books=value;
        chapters = box.get('chapters');
      });
    }
  }
  void _onSuggestionSelected(dynamic suggestion) async {


    if (books != null) {
      var type = "image";

      for (int i = 0; i < books.length; i++) {
        if (books[i]['book_id'] == suggestion['book-id']) {
          type = books[i]['content_type_name'];
          break;
        }

      }
      setState(() {
        _isSearching = false;
        _searchController.clear();  // Clear the search query
        searchResults.clear();  // Clear the results
        _overlayEntry?.remove();
      });
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
        width: MediaQuery.of(context).size.width, // Same width as the search field
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-70.0, 55.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              color: Colors.yellow[700],
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9, // Limit height for scrollability
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final suggestion = searchResults[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 1.0,        // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
                    ),
                    child: ListTile(
                      textColor: Colors.black,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              suggestion['title-hindi'],
                              overflow: TextOverflow.ellipsis, // Truncate overflowing text with ellipsis
                              maxLines: 1, // Ensure single-line display
                              softWrap: false,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              suggestion['from-page-number'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(getBookName(suggestion['book-id'])),
                      subtitleTextStyle: const TextStyle(
                        fontSize: 11,
                      ),
                      onTap: () {
                        _onSuggestionSelected(suggestion); // Handle suggestion selection
                      },
                    ),
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getBooks();
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
      onDrawerChanged: (isOpen) {
        if (isOpen) {
          setState(() {
            _isSearching = false;
            _searchController.clear();  // Clear the search query
            searchResults.clear();  // Clear the results
            _overlayEntry?.remove();
          });
        }
      },
      body: widget.child,  // The body will be the content of the specific page
    );
  }
}
