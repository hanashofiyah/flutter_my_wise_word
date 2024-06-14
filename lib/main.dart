// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Katla",
        theme: ThemeData(
          useMaterial3: true, 
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 219, 245, 148))),
        home: MyHomePage(),
      ), // MaterialApp
    ); // ChangeNotifierProvider
  }
}

class MyAppState extends ChangeNotifier{
  var current = WordPair.random();

  var favorites = <WordPair>[];
  
  var history =  <WordPair>[];

  void getNext(){
    history.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  void toogleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }
    else{
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair wp){
    favorites.remove(wp);
    notifyListeners();
  }

  void clearHistory(){
    history.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;                         // selectedIndex di sini merupakan variable

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {                     // selectedIndex di sini merupakan variable
      case 0:
        page = const GeneratorPage();
      case 1:
        page = const FavoritePage();
      case 2:
        page = const HistoryPage();
      default:
        page = const Placeholder();
    }
    return Scaffold(
      //background app
      backgroundColor: Color.fromARGB(255, 219, 245, 148),

      //Bar Navigasi Bagian Bawah Android
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value){
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,           // selectedIndex di sini merupakan property
        destinations: const [
          NavigationDestination(                // navigasi/tab (home) ini berada dalam index ke-0
            selectedIcon: Icon(Icons.home), 
            icon: Icon(Icons.home_outlined),
            label: 'Beranda'),
          NavigationDestination(                // navigasi/tab (favorite) ini berada dalam index ke-1
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border_outlined), 
            label: 'Favorite'),
          NavigationDestination(                // navigasi/tab (favorite) ini berada dalam index ke-1
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined), 
            label: 'History'),
        ],
      ),

      //view app
      body: Container(
        child: page),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if(appState.favorites.contains(pair)){
      icon = Icons.favorite;
    }
    else{
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Tebak Kata:"),
          BigCard(pair: pair),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toogleFavorite();

                  //Snackbar
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("Kata yang kamu pilih adalah '${appState.current}' "),
                      ),
                    );
                }, 
                icon: Icon(icon),
                label: const Text("Favorite"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                }, 
                child: const Text("Next"),
              ),
            ],
          ),
        ], 
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // <- Add this
    final pairTextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 30.0,
    );

    return Card(
      color: Color.fromARGB(255, 186, 250, 11),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          pair.asLowerCase,
          style: pairTextStyle,
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
  
  get color => null;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    int counter = 0;

    return Container(
      child: ListView(
        children: [
          Text("Kamu telah menambahkan ${appState.favorites.length} kata favorit hari ini", 
          style: Theme.of(context).textTheme.titleLarge,),
          //Text("000000"),
          ...appState.favorites.map(
            (wp) => ListTile(
              onTap: (){
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("Kata ini adalah ${wp.asCamelCase}"),
                    )
                  );
              },
              leading: Text(
                "${++counter}",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              title: Text(wp.asCamelCase),
              trailing: IconButton(
                onPressed: (){
                  appState.removeFavorite(wp);
                },  
              icon: const Icon(Icons.delete),
              ),
            ),
          ),
          Text("Kata telah menambahkan kata favorit"),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var historyState = context.watch<MyAppState>();

    int counter = 0;

    return Scaffold(
      body: ListView(
        children: [
          Center(
            child: Text(
              "Kamu telah melihat ${historyState.history.length} kata hari ini",
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...historyState.history.map(
            (wp) => ListTile(
              onTap: (){
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("${wp.asCamelCase}"),
                    )
                  );
              },
              leading: Text(
                "${++counter}",
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              title: Text(wp.asCamelCase),
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
          historyState.clearHistory();
      }, child: const Icon(Icons.delete),
      ),
    );
  }
}