import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/models/diagnosis_history_entry.dart';

/// Repository for persisting and loading diagnosis history locally.
class DiagnosisHistoryRepository {
  final Directory? _baseDirectory;
  static const int _maxEntries = 20;
  static const String _indexFileName = 'history.json';

  DiagnosisHistoryRepository({Directory? baseDirectory}) : _baseDirectory = baseDirectory;

  Future<Directory> _getDirectory() async {
    final Directory dir;
    if (_baseDirectory != null) {
      dir = _baseDirectory;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      dir = Directory('${appDocDir.path}/diagnosis_history');
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Loads recent diagnosis history entries up to the specified [limit],
  /// sorted newest-first.
  Future<List<DiagnosisHistoryEntry>> loadRecent({int limit = 10}) async {
    try {
      final dir = await _getDirectory();
      final parsedItems = await _readAndParseIndex(dir);

      final entries = <DiagnosisHistoryEntry>[];
      for (final item in parsedItems) {
        final pngFile = File('${dir.path}/${item.id}.png');
        if (await pngFile.exists()) {
          final imageBytes = await pngFile.readAsBytes();
          entries.add(DiagnosisHistoryEntry.fromJson(item.json, imageBytes));
        }
      }

      // Sort newest first
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit
      return entries.take(limit).toList();
    } catch (_) {
      // In case of parsing error or corruption, return empty list
      return [];
    }
  }

  /// Records a new diagnosis result along with its processed PNG image.
  /// Enforces a maximum retained history size of 20 entries.
  Future<void> recordDiagnosis({
    required DiagnosisResult result,
    required Uint8List imageBytes,
  }) async {
    final dir = await _getDirectory();

    // Generate a unique stable ID
    final id = 'diag_${DateTime.now().microsecondsSinceEpoch}_${_randomString(5)}';

    // Save image to PNG file
    final pngFile = File('${dir.path}/$id.png');
    await pngFile.writeAsBytes(imageBytes);

    // Create new entry
    final newEntry = DiagnosisHistoryEntry(
      id: id,
      createdAt: DateTime.now(),
      result: result,
      imageBytes: imageBytes,
    );

    // Load existing index items
    var parsedIndexItems = await _readAndParseIndex(dir);

    // Add new item
    parsedIndexItems.add(_IndexItem(
      id: newEntry.id,
      createdAt: newEntry.createdAt,
      json: newEntry.toJson(),
    ));

    // Sort and prune entries
    parsedIndexItems = await _sortAndPrune(parsedIndexItems, dir);

    // Convert kept items back to JSON list and write back index file
    final newJsonList = parsedIndexItems.map((item) => item.json).toList();
    final indexFile = File('${dir.path}/$_indexFileName');
    await indexFile.writeAsString(json.encode(newJsonList));
  }

  Future<List<_IndexItem>> _readAndParseIndex(Directory dir) async {
    final indexFile = File('${dir.path}/$_indexFileName');
    if (!await indexFile.exists()) {
      return [];
    }

    try {
      final contents = await indexFile.readAsString();
      final List<dynamic> jsonList = json.decode(contents);

      final parsedIndexItems = <_IndexItem>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final itemId = item['id'] as String?;
          final itemCreatedAtStr = item['createdAt'] as String?;
          if (itemId != null && itemCreatedAtStr != null) {
            parsedIndexItems.add(_IndexItem(
              id: itemId,
              createdAt: DateTime.parse(itemCreatedAtStr),
              json: item,
            ));
          }
        }
      }
      return parsedIndexItems;
    } catch (_) {
      return [];
    }
  }

  Future<List<_IndexItem>> _sortAndPrune(
    List<_IndexItem> items,
    Directory dir,
  ) async {
    // Sort newest-first
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Prune entries exceeding max limit
    if (items.length > _maxEntries) {
      final itemsToPrune = items.sublist(_maxEntries);
      for (final item in itemsToPrune) {
        final file = File('${dir.path}/${item.id}.png');
        if (await file.exists()) {
          await file.delete();
        }
      }
      items.removeRange(_maxEntries, items.length);
    }
    return items;
  }

  static String _randomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
  }
}

class _IndexItem {
  final String id;
  final DateTime createdAt;
  final Map<String, dynamic> json;

  _IndexItem({
    required this.id,
    required this.createdAt,
    required this.json,
  });
}
