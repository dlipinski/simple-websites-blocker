import 'package:process_run/shell.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

Future<String> writeToTempFile(content) async {
  final directory = await getTemporaryDirectory();
  final path = directory.path;
  final filePath = '$path/tempContent.txt';
  final tempFile = io.File(filePath);
  await tempFile.writeAsString(content);
  return filePath;
}

bool validateUrl(text) {
  final urlRegex =
      RegExp(r'(https|http)?:?(\/\/)?(www\.)?[a-zA-Z0-1]+\.[a-z]+.*');
  return urlRegex.hasMatch(text);
}

List<String> generateVariants(String domain) {
  return [
    domain,
    'www.$domain',
    'http://$domain',
    'https://$domain',
    'http://www.$domain',
    'https://www.$domain',
  ];
}

Future<void> setEtcHosts(newContent) async {
  var tempFilePath = await writeToTempFile(newContent);
  var command = """
    #!/bin/bash
    /usr/bin/osascript -e 'do shell script "sudo cat $tempFilePath > /etc/hosts" with administrator privileges'
    """;
  var shell = Shell();
  await shell.run(command);
}

Future<String> getEtcHosts() async {
  var path = '/etc/hosts';
  return await io.File(path).readAsString();
}

Future<void> removePageFromBlocked(String webpage) async {
  var domain = extractDomain(webpage);
  var variants = generateVariants(domain);
  var content = await getEtcHosts();
  var lines = content.split('\n');
  for (var i = 0; i < variants.length; i++) {
    String variant = variants[i];
    lines =
        lines.where((x) => !x.contains('127.0.0.1       $variant')).toList();
  }
  var newContent = lines.join('\n');
  await setEtcHosts(newContent);
}

Future<void> addPageToBlocked(String webpage) async {
  var domain = extractDomain(webpage);
  var variants = generateVariants(domain);
  var content = await getEtcHosts();
  var newLines =
      variants.map((variant) => '127.0.0.1       $variant').join('\n');
  var newContent = content.replaceFirst(
      "# SimpleWebsitesBlockerEnd", "$newLines\n# SimpleWebsitesBlockerEnd");
  await setEtcHosts(newContent);
}

Future<void> _initFile() async {
  var content = await getEtcHosts();
  var newContent =
      '$content\n\n# SimpleWebsitesBlockerStart\n# SimpleWebsitesBlockerEnd';
  setEtcHosts(newContent);
}

String extractDomain(String url) {
  var domain = url
      .replaceAll('http://', '')
      .replaceAll('https://', '')
      .replaceAll('www.', '');
  var firstSlash = domain.indexOf('/');
  if (firstSlash != -1) {
    domain = domain.substring(0, firstSlash);
  }
  return domain;
}

List<dynamic> readLines(String content) {
  const start = '# SimpleWebsitesBlockerStart';
  const end = '# SimpleWebsitesBlockerEnd';
  final startIndex = content.indexOf(start);
  if (startIndex == -1) {
    _initFile();
    return [];
  }
  final endIndex = content.indexOf(end);
  var appContent =
      content.substring(startIndex + start.length, endIndex).trim();
  if (appContent.length == 0) return [];
  List<String> lines = appContent.split('\n');
  var domains = [];
  for (var i = 0; i < lines.length; i++) {
    String url = lines[i].replaceAll('127.0.0.1       ', '');
    String domain = extractDomain(url);
    if (!domains.contains(domain)) {
      domains.add(domain);
    }
  }
  domains.sort();
  return domains;
}
