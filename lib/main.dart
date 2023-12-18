import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:simple_websites_blocker/global.dart';

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
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
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
    if (!validateIsUrl(webpage)) {
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
        backgroundColor: Colors.black,
        body: Padding(
          padding:
              const EdgeInsets.only(left: 20.0, right: 20, bottom: 20, top: 80),
          child: Column(children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              controller: textFieldController,
              decoration: InputDecoration(
                errorText: errorMessage.isEmpty ? null : errorMessage,
                contentPadding: const EdgeInsets.only(
                    left: 12, top: 0, bottom: 0, right: 0),
                border:
                    const OutlineInputBorder(borderSide: BorderSide(width: 1)),
                hintText: 'e.g. funwebsite.com',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FilledButton(
                    onPressed: _blockPage,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    child: const Text('Block'),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              child: const Text(
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
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: Text(
                      item,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
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
        ));
  }
}
