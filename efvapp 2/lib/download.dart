import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

const debug = true;

class DownloadPage extends StatefulWidget with WidgetsBindingObserver {
  @override
  _DownloadPageState createState() => new _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();
  List<DownloadTask> tasks;
  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('下载记录'),
      ),
      body: Builder(
          builder: (context) => _isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : _permissionReady
                  ? LiquidPullToRefresh(
                      showChildOpacityTransition: false,
                      springAnimationDurationInMilliseconds: 300,
                      backgroundColor: Colors.black54,
                      color: Colors.grey[200],
                      onRefresh: _handleRefresh, // refresh callback
                      child: new ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        children: tasks
                            .take(100)
                            .map((task) => task.status == null
                                ? new Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      task.filename ?? '错误文件',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 18.0),
                                    ),
                                  )
                                : new Container(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 8.0),
                                    child: InkWell(
                                      onTap: task.status ==
                                              DownloadTaskStatus.complete
                                          ? () {
                                              _openDownloadedFile(task)
                                                  .then((success) {
                                                if (!success) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              '无法打开此文件，请尝试使用其他APP打开或直接相册中打开！')));
                                                }
                                              });
                                            }
                                          : null,
                                      child: new Stack(
                                        children: <Widget>[
                                          new Container(
                                            width: double.infinity,
                                            height: 64.0,
                                            child: new Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: new Text(
                                                    task.filename ?? '错误文件',
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                new Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child:
                                                      _buildActionForTask(task),
                                                ),
                                              ],
                                            ),
                                          ),
                                          task.status ==
                                                      DownloadTaskStatus
                                                          .running ||
                                                  task.status ==
                                                      DownloadTaskStatus.paused
                                              ? new Positioned(
                                                  left: 0.0,
                                                  right: 0.0,
                                                  bottom: 0.0,
                                                  child:
                                                      new LinearProgressIndicator(
                                                    value: task.progress / 100,
                                                  ),
                                                )
                                              : new Container()
                                        ]
                                            .where((child) => child != null)
                                            .toList(),
                                      ),
                                    ),
                                  ))
                            .toList(),
                      ),
                    )
                  : new Container(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                '请先开启APP的文件储存权限之后再重新打开APP -_-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 18.0),
                              ),
                            ),
                            SizedBox(
                              height: 32.0,
                            ),
                            FlatButton(
                                onPressed: () {
                                  _checkPermission().then((hasGranted) {
                                    setState(() {
                                      _permissionReady = hasGranted;
                                    });
                                  });
                                },
                                child: Text(
                                  '重试',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ))
                          ],
                        ),
                      ),
                    )),
    );
  }

  Widget _buildActionForTask(DownloadTask task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () {
          _requestDownload(task);
        },
        child: new Icon(Icons.file_download),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        child: new Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            '点击打开',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('取消', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('失败', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }

  void _requestDownload(DownloadTask task) async {
    await FlutterDownloader.enqueue(
        url: task.url,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(DownloadTask task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(DownloadTask task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(DownloadTask task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
  }

  void _retryDownload(DownloadTask task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
  }

  Future<bool> _openDownloadedFile(DownloadTask task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(DownloadTask task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future _handleRefresh() async {
    final thetasks = await FlutterDownloader.loadTasks();
    setState(() {
      tasks = thetasks;
    });
  }

  Future<Null> _prepare() async {
    final thetasks = await FlutterDownloader.loadTasks();
    setState(() {
      tasks = thetasks;
    });
    // tasks?.forEach((task) {
    //   for (_TaskInfo info in _tasks) {
    //     if (info.link == task.url) {
    //       info.taskId = task.taskId;
    //       info.status = task.status;
    //       info.progress = task.progress;
    //     }
    //   }
    // });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
