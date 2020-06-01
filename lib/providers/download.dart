import 'dart:io' as p;
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wildstream/models/search.dart';

const debug = true;

class DownloadNotifier with ChangeNotifier {
  List<TaskInfo> _tasks;
  List<Data> _items;
  bool _isLoading = true;
  bool _permissionReady = false;
  String _localPath;
  ReceivePort _port = ReceivePort();

  bool get isLoading => _isLoading;
  bool get permissionReady => _permissionReady;

  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      print("ID $id and ${status.toString()} And $progress");
      notifyListeners();

      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        task.status = status;
        task.progress = progress;
        notifyListeners();
//         setState(() {
//          task.status = status;
//          task.progress = progress;
//        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void requestDownload(TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: false);
  }

  void cancelDownload(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void resumeDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void retryDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> openDownloadedFile(TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void delete(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await prepare();

    notifyListeners();
  }

  Future<bool> checkPermission(TargetPlatform platform) async {
    if (platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> prepare({TargetPlatform platform}) async {
    _isLoading = true;
    _permissionReady = false;
    notifyListeners();

    final tasks = await FlutterDownloader.loadTasks();

    tasks?.forEach((element) {
      print("ALL TASK ${element.toString()}");
      print("ALL TASK2 ${element.savedDir}");
    });

    int count = 0;
    _tasks = [];
    _items = [];

    /*_tasks.addAll(images
        .map((image) => TaskInfo(name: image['name'], link: image['link'])));

    print('TASK ${_tasks.length}');
    _items.add(Data(name: 'Images'));
    for (int i = count; i < _tasks.length; i++) {
      _items.add(Data(name: _tasks[i].name, downloadTask: _tasks[i]));
      print('TASK1 ${i.toString()}');
      count++;
    }
*/
    tasks?.forEach((task) {
      for (TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
          print("ALL TASK3 ${info.taskId}");
        }
      }
    });

    _permissionReady = await checkPermission(platform);
    print("Granted? $_permissionReady");
    _isLoading = false;
    notifyListeners();

    _localPath =
        (await _findLocalPath()) + p.Platform.pathSeparator + 'Download';

    final savedDir = p.Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    _isLoading = false;
    notifyListeners();

    /*setState(() {
      _isLoading = false;
    });*/
  }

  bool hasGrantedPermission({TargetPlatform platform}) {
    checkPermission(platform).then((hasGranted) {
      _permissionReady = hasGranted;
      print("hasGrantedPermission $hasGranted");
      notifyListeners();
    });
    return _permissionReady;
  }

  Future<String> _findLocalPath({TargetPlatform platform}) async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }
}

class TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  TaskInfo({this.name, this.link});

  factory TaskInfo.fromJson(Map<String, dynamic> parsedJson) {
    return TaskInfo(
      link: parsedJson['link'],
      name: parsedJson['name'],
    );
  }
}

class Crops with ChangeNotifier {
  final String crop500;
  final String crop100;
  Crops({this.crop500, this.crop100});

  factory Crops.fromJson(Map<String, dynamic> parsedJson) {
    return Crops(
      crop100: parsedJson['100'] as String,
      crop500: parsedJson['500'] as String,
    );
  }
}

class _ItemHolder {
  final String name;
  final TaskInfo task;
  _ItemHolder({this.name, this.task});
}
