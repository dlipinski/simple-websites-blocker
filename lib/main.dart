import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:simple_websites_blocker/global.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(400, 600),
    maximumSize: Size(400, 2000),
    minimumSize: Size(400, 400),
    titleBarStyle: TitleBarStyle.hidden,
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: const Color(0xCC222222),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Websites Blocker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Simple Websites Blocker'),
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
  final textFieldController = TextEditingController();
  var lines = [];
  var errorMessage = '';

  Future<void> _refreshLines() async {
    var content = await getEtcHosts();
    lines = readLines(content);
    setState(() {});
  }

  void _blockPage() async {
    var webpage = textFieldController.text;
    if (webpage.isEmpty) {
      return;
    }
    if (!validateUrl(webpage)) {
      errorMessage = 'Invalid website address';
      setState(() {});
      return;
    }
    errorMessage = '';
    setState(() {});
    await addPageToBlocked(webpage);
    await _refreshLines();
    textFieldController.clear();
  }

  void _unblockPage(webpage) async {
    await removePageFromBlocked(webpage);
    await _refreshLines();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 56),
          child: Column(children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              style: const TextStyle(fontSize: 14),
              controller: textFieldController,
              decoration: InputDecoration(
                fillColor: Colors.black54,
                filled: true,
                errorText: errorMessage.isEmpty ? null : errorMessage,
                contentPadding: const EdgeInsets.only(
                    left: 12, top: 0, bottom: 0, right: 0),
                border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 0, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(6)),
                hintText: 'e.g. funwebsite.com',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FilledButton(
                    onPressed: _blockPage,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: const Text('Block'),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ), //here we se
                  color: Colors.black54,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Blocked websites',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemCount: lines.length,
                        itemBuilder: (context, index) {
                          final item = lines[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.all(2.0),
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            title: Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                            ),
                            trailing: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              onPressed: () {
                                _unblockPage(item);
                              },
                              child: const Text('Unblock'),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ));
  }
}
