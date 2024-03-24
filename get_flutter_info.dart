import 'dart:io' show Process, ProcessResult;
import 'dart:convert' show json;


//////////////////////////////////////
//RUN:  dart get_flutter_info.dart > lib/flutter_info.dart
////////////////////////////
void main() {
  Process.run('flutter', ['--version', '--machine']).then(
        (ProcessResult results) {
      final result = Map<String, Object>.from(
        json.decode(results.stdout.toString()) as Map,
      );
      print(constantDeclarationsFromMap(result, 'tFlutter'));
    },
  );
}

String constantDeclarationsFromMap(Map<String, Object> map,
    [String prefix = 't']) {
  String _capitalize(String text) =>
      text.isEmpty ? text : "${text[0].toUpperCase()}${text.substring(1)}";

  String _constantName(String name, String prefix) =>
      prefix.isEmpty ? name : prefix + _capitalize(name);

  return map.entries
      .map((e) =>
  'const ${_constantName(e.key, prefix)} = ${json.encode(e.value)};')
      .join('\n');
}