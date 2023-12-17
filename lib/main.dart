import 'package:process_run/shell.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'dart:io' as io;

Future<String> _writeToTempFile(content) async {
  final directory = await getTemporaryDirectory();
  final path = directory.path;
  final filePath = '$path/tempContent.txt';
  final tempFile = io.File(filePath);
  await tempFile.writeAsString(content);
  return filePath;
}

Future<void> _removePageFromBlocked(content, webpage) async {
  var lines = content.split('\n');
  var newList = lines.where((x) => !x.contains('127.0.0.1       $webpage'));
  var newContent = newList.join('\n');
  var tempFilePath = await _writeToTempFile(newContent);
  var command = """
    #!/bin/bash
    /usr/bin/osascript -e 'do shell script "sudo cat $tempFilePath > /etc/hosts" with administrator privileges'
    """;
  var shell = Shell();
  await shell.run(command);
}

Future<void> _addPageToBlocked(content, webpage) async {
  var newLine = '127.0.0.1       $webpage';
  var newContent = content.replaceFirst(
      "# DeadSimpleBlockerEnd", "$newLine\n# DeadSimpleBlockerEnd");
  var tempFilePath = await _writeToTempFile(newContent);
  var command = """
    #!/bin/bash
    /usr/bin/osascript -e 'do shell script "sudo cat $tempFilePath > /etc/hosts" with administrator privileges'
    """;
  var shell = Shell();
  await shell.run(command);
}

Future<String> _getContent() async {
  var path = '/etc/hosts';
  return await io.File(path).readAsString();
}

Future<void> _initFile(content) async {
  var newContent =
      content + '\n\n# DeadSimpleBlockerStart\n# DeadSimpleBlockerEnd';
  var tempFilePath = await _writeToTempFile(newContent);
  var command = """
    #!/bin/bash
    /usr/bin/osascript -e 'do shell script "sudo cat $tempFilePath > /etc/hosts" with administrator privileges'
    """;
  var shell = Shell();
  await shell.run(command);
}

List<dynamic> _readLines(content) {
  const start = '# DeadSimpleBlockerStart';
  const end = '# DeadSimpleBlockerEnd';
  final startIndex = content.indexOf(start);
  if (startIndex != -1) {
    final endIndex = content.indexOf(end);
    var appContent =
        content.substring(startIndex + start.length, endIndex).trim();
    if (appContent.length == 0) return [];
    return appContent
        .split('\n')
        .map((line) => line.replaceAll('127.0.0.1       ', ''))
        .toList();
  } else {
    _initFile(content);
    return [];
  }
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          // ···
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

  void _blockPage() async {
    var webpage = textFieldController.text;
    var content = await _getContent();
    await _addPageToBlocked(content, webpage);
    content = await _getContent();
    lines = _readLines(content);
    setState(() {});
  }

  void _unblockPage(webpage) async {
    var content = await _getContent();
    await _removePageFromBlocked(content, webpage);
    content = await _getContent();
    lines = _readLines(content);
    setState(() {});
  }

  void f() async {
    var content = await _getContent();
    lines = _readLines(content);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      f();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: textFieldController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter a webpage',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: ElevatedButton(
                    onPressed: _blockPage,
                    child: const Text('Block'),
                  ),
                ),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: lines.length,
            itemBuilder: (context, index) {
              final item = lines[index];
              return ListTile(
                title: Text(item),
                trailing: ElevatedButton(
                  onPressed: () {
                    _unblockPage(item);
                  },
                  child: const Text('Unblock'),
                ),
              );
            },
          ),
        ]));
  }
}
