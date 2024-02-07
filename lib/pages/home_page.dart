import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final List<dynamic> _genres = [
    MovieGenre(id: 1, name: "Action"),
    MovieGenre(id: 2, name: "Animation"),
    MovieGenre(id: 3, name: "Drama"),
    MovieGenre(id: 4, name: "Horror"),
    MovieGenre(id: 5, name: "Sci-Fi"),
  ];
  final _items = _genres
      .map((genre) => MultiSelectItem<MovieGenre>(genre, genre.name))
      .toList();

  String name = "";

  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  TextEditingController titleController = TextEditingController();
  TextEditingController directorController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  // open a dialog box to add a note
  openNoteBox(
      {String? docID,
      String? title,
      String? director,
      String? summary,
      List<MovieGenre>? genres}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: docID == null
                  ? titleController = TextEditingController(text: '')
                  : titleController = TextEditingController(text: '$title'),
              decoration: const InputDecoration(
                labelText: 'Title',
                icon: Icon(Icons.near_me),
              ),
            ),
            TextField(
              controller: docID == null
                  ? directorController = TextEditingController(text: '')
                  : directorController =
                      TextEditingController(text: '$director'),
              decoration: const InputDecoration(
                labelText: 'Director',
                icon: Icon(Icons.person),
              ),
            ),
            Flexible(
              child: TextField(
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                controller: docID == null
                    ? summaryController = TextEditingController(text: '')
                    : summaryController =
                        TextEditingController(text: '$summary'),
                decoration: const InputDecoration(labelText: 'Summary'),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 100,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MultiSelectDialogField(
                items: _items,
                title: const Text("Genres"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.movie_edit,
                  color: Colors.blue,
                ),
                buttonText: Text(
                  "Select Genres",
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    _selectedGenres = results.map((e) => e.toJson());
                  });
                }),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // add a new note
              if (docID == null) {
                firestoreService.addNote(
                  titleController.text,
                  directorController.text,
                  summaryController.text,
                  _selectedGenres,
                );
              }
              // update an existing note
              else {
                firestoreService.updateNote(
                    docID,
                    titleController.text,
                    directorController.text,
                    summaryController.text,
                    _selectedGenres);
              }
              // clear the text controller
              titleController.clear();
              // close the box
              Navigator.pop(context);

              somethingChanged = true;
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // List<MovieGenre>
  Iterable<Map<String, dynamic>> _selectedGenres = [];
  List<Widget> genreWidget = [];
  bool somethingChanged = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie List"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search ....',
            ),
            onChanged: (val) {
              setState(() {
                name = val;
              });
            },
          ),
          const SizedBox(
            width: 40,
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getNotesStream(),
              builder: (context, snapshot) {
                // if we have data, get all the docs
                if (snapshot.hasData) {
                  List notesList = snapshot.data!.docs;
                  // display as a list
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        // get each individual doc
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;

                        // get note from each doc
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String noteText = data['title'];
                        String? docTitle = data['title'];
                        String? docDirector = data['director'];
                        String? docSummary = data['summary'];
                        List<dynamic> docGenres = data['genres'];

                        List<MovieGenre> editedGenres = [];

                        // to assign data whenever data is open for edit not for add

                        for (var i in docGenres) {
                          editedGenres
                              .add(MovieGenre(id: i['id'], name: i['title']));
                        }

                        // for assign docGenre data to genreWidget
                        if (genreWidget.isEmpty) {
                          if (somethingChanged == true) {
                            for (var i in docGenres) {
                              genreWidget.add(Row(
                                children: [
                                  Text(
                                    i['title'] as String,
                                  ),
                                  const SizedBox(width: 20)
                                ],
                              ));
                            }
                          }
                        }

                        somethingChanged = false;

                        // display as a list tile
                        if (name.isEmpty) {
                          return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  docTitle!,
                                ),
                                Text(docDirector!),
                                Text(docSummary!),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: genreWidget,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => openNoteBox(
                                            docID: docID,
                                            title: docTitle,
                                            director: docDirector,
                                            summary: docSummary,
                                            genres: editedGenres),
                                        icon: const Icon(Icons.settings),
                                      ),
                                      // delete button
                                      IconButton(
                                        onPressed: () =>
                                            firestoreService.deleteNote(docID),
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ]),
                              ]);
                        }
                        if (data['title']
                            .toLowerCase()
                            .contains(name.toLowerCase())) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(noteText),
                              // update button
                              IconButton(
                                onPressed: () => openNoteBox(
                                    docID: docID,
                                    title: docTitle,
                                    director: docDirector,
                                    summary: docSummary,
                                    genres: editedGenres),
                                icon: const Icon(Icons.settings),
                              ),
                              // delete button
                              IconButton(
                                onPressed: () =>
                                    firestoreService.deleteNote(docID),
                                icon: const Icon(Icons.delete),
                              )
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                  );
                }
                // if there is no data return nothing
                else {
                  return const Text("No notes..");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieGenre {
  final int id;
  final String name;

  MovieGenre({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      // 'owner': owner,
      // 'time': time,
      // 'assignedTask': assignedTask.map(a => a.toJson()).toList(),
    };
  }
}
