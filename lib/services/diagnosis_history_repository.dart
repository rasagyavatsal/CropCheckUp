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
    final dir = await _getDirectory();
    final indexFile = File('${dir.path}/$_indexFileName');
    if (!await indexFile.exists()) {
      return [];
    }

    try {
      final contents = await indexFile.readAsString();
      final List<dynamic> jsonList = json.decode(contents);

      final entries = <DiagnosisHistoryEntry>[];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as String?;
          if (id == null) continue;

          final pngFile = File('${dir.path}/$id.png');
          if (await pngFile.exists()) {
            final imageBytes = await pngFile.readAsBytes();
            entries.add(DiagnosisHistoryEntry.fromJson(item, imageBytes));
          }
        }
      }

      // Sort newest first
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit
      return entries.take(limit).toList();
    } catch (e) {
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
    final indexFile = File('${dir.path}/$_indexFileName');
    List<dynamic> jsonList = [];
    if (await indexFile.exists()) {
      try {
        final contents = await indexFile.readAsString();
        jsonList = json.decode(contents);
      } catch (_) {
        // Ignore corrupt index file and start fresh
      }
    }

    // Reconstruct parsed items to perform sorting and pruning
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

    // Add new item
    parsedIndexItems.add(_IndexItem(
      id: newEntry.id,
      createdAt: newEntry.createdAt,
      json: newEntry.toJson(),
    ));

    // Sort newest-first
    parsedIndexItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Prune entries exceeding max limit
    if (parsedIndexItems.length > _maxEntries) {
      final itemsToPrune = parsedIndexItems.sublist(_maxEntries);
      for (final item in itemsToPrune) {
        final file = File('${dir.path}/${item.id}.png');
        if (await file.exists()) {
          await file.delete();
        }
      }
      parsedIndexItems.removeRange(_maxEntries, parsedIndexItems.length);
    }

    // Convert kept items back to JSON list
    final newJsonList = parsedIndexItems.map((item) => item.json).toList();

    // Write back index file
    await indexFile.writeAsString(json.encode(newJsonList));
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
