import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de logs visible en la UI (para debugging sin consola)
class UILogger {
  static final UILogger _instance = UILogger._internal();
  factory UILogger() => _instance;
  UILogger._internal();

  final List<LogEntry> _logs = [];
  final int maxLogs = 200;

  void log(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
    );

    _logs.insert(0, entry);
    if (_logs.length > maxLogs) {
      _logs.removeLast();
    }
  }

  void info(String message) => log(message, level: LogLevel.info);
  void success(String message) => log(message, level: LogLevel.success);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message) => log(message, level: LogLevel.error);

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void clear() => _logs.clear();
}

enum LogLevel { info, success, warning, error }

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });

  String get emoji {
    switch (level) {
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.success:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  Color get color {
    switch (level) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.success:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }
}

/// Pantalla para ver logs en la UI
class UILogViewerScreen extends StatefulWidget {
  const UILogViewerScreen({super.key});

  @override
  State<UILogViewerScreen> createState() => _UILogViewerScreenState();
}

class _UILogViewerScreenState extends State<UILogViewerScreen> {
  final _logger = UILogger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Logs de la App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyAllLogs,
            tooltip: 'Copiar todos los logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _logger.clear();
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logs limpiados')));
            },
            tooltip: 'Limpiar logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _logger.logs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay logs todavía',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Usa la app y los logs aparecerán aquí',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _logger.logs.length,
              itemBuilder: (context, index) {
                final log = _logger.logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    leading: Text(
                      log.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      log.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: log.color,
                        fontFamily: 'monospace',
                      ),
                    ),
                    subtitle: Text(
                      _formatTime(log.timestamp),
                      style: const TextStyle(fontSize: 10),
                    ),
                    onTap: () => _showLogDetail(log),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  void _copyAllLogs() {
    final allLogs = _logger.logs
        .map(
          (log) => '${_formatTime(log.timestamp)} ${log.emoji} ${log.message}',
        )
        .join('\n');

    Clipboard.setData(ClipboardData(text: allLogs));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_logger.logs.length} logs copiados al portapapeles'),
      ),
    );
  }

  void _showLogDetail(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(log.emoji),
            const SizedBox(width: 8),
            Text(
              log.level.toString().split('.').last.toUpperCase(),
              style: TextStyle(color: log.color),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tiempo:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(_formatTime(log.timestamp)),
              const SizedBox(height: 16),
              Text(
                'Mensaje:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SelectableText(
                log.message,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: log.message));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Log copiado')));
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
