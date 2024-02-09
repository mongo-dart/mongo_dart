import 'package:flutter/material.dart';
import 'package:mongo_dart_web/example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mongo Dart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mongo Dart Web Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  bool isInitialized = false;

  Future<void> _initializeDB() async {
    setState(() {
      isLoading = true;
    });

    try {
      await init();
      setState(() {
        isLoading = false;
        isInitialized = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: isLoading && !isInitialized
                  ? const CircularProgressIndicator()
                  : Text(
                      'Status: $isInitialized',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initializeDB,
        tooltip: 'Init DB',
        child: const Icon(Icons.add),
      ),
    );
  }
}
