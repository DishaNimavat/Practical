import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_practical_aveosoft/model/image_list_model_response.dart';
import 'package:flutter_practical_aveosoft/screens/download_screen.dart';
import 'package:flutter_practical_aveosoft/utils/api_controller.dart';
import 'package:flutter_practical_aveosoft/utils/app_color.dart';
import 'package:flutter_practical_aveosoft/utils/constants.dart';
import 'package:flutter_practical_aveosoft/utils/custom/network_utility.dart';
import 'package:flutter_practical_aveosoft/utils/service_locator.dart';
import 'package:flutter_practical_aveosoft/utils/style/fonts.dart';
import 'package:provider/provider.dart';
import 'package:device_info/device_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget with WidgetsBindingObserver {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<_TaskInfo>? _tasks=[];
  late List<_ItemHolder> _items=[];
  late bool _isLoading;
  late bool _permissionReady;
  late String _localPath;
  final ReceivePort _port = ReceivePort();
  List<ImageListDataModelResponse> lstImageData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    _permissionReady = false;

    getImageList();
  }

  void getImageList()async {
    if(await getIt<NetworkUtility>().getConnectivity()) {
      APIController.fetchDataFromServerUsingGetMethod().then((value) {
        for (int a = 0; a <= 10; a++) {
          lstImageData.add(value[a]);
        }
        _prepare();
      }).catchError((onError) {});
    }else{
     setState(() {
       _isLoading = false;
     });
      SnackBar snackBar = const SnackBar(content:Text("Please check internet") );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.appGreyBackground,
            title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Images",
                  style: Fonts.dashboardTitleStyle,
                )),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const DownloadScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(
                    IMAGE_ASSETS_PATH + "img_download.png",
                    fit: BoxFit.contain,
                  ),
                ),
              )
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _permissionReady
                  ? _buildDownloadList()
                  : _buildNoPermissionWarning());
    });
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
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (_tasks != null && _tasks!.isNotEmpty) {
        final task = _tasks!.firstWhere((task) => task.taskId == id);
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
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    int count = 0;
    _tasks = [];
    _items = [];
    for (int a = 0; a < lstImageData.length; a++) {
      _TaskInfo _taskInfo = _TaskInfo(
          name: lstImageData[a].author, link: lstImageData[a].download_url);

      _tasks!.add(_taskInfo);
      print(_tasks![a].name);
    }

    for (int i = count; i < _tasks!.length; i++) {
      _items.add(_ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }

    tasks!.forEach((task) {
      for (_TaskInfo info in _tasks!) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  Future<bool> _checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid == TargetPlatform.android &&
        androidInfo.version.sdkInt <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
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

  Widget _buildDownloadList() => GridView.builder(
        itemCount: _items.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          return _items.isEmpty
              ? _buildListSection(_items[index].name!)
              : DownloadItem(
                  data: _items[index],
                  onItemClick: (task) {
                    _openDownloadedFile(task).then((success) {
                      if (!success) {
                        SnackBar snackBar = const SnackBar(content:Text("Cannot open this file") );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                  },
                  onActionClick: (task) {
                    if (task.status == DownloadTaskStatus.undefined) {
                      _requestDownload(task);
                    } else if (task.status == DownloadTaskStatus.running) {
                      _pauseDownload(task);
                    } else if (task.status == DownloadTaskStatus.paused) {
                      _resumeDownload(task);
                    } else if (task.status == DownloadTaskStatus.complete) {
                      _delete(task);
                    } else if (task.status == DownloadTaskStatus.failed) {
                      _retryDownload(task);
                    }
                  },
                );
        },
      );

  Widget _buildListSection(String title) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
        ),
      );

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              MaterialButton(
                  onPressed: () {
                    _retryRequestPermission();
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();

    if (hasGranted) {
      await _prepareSaveDir();
    }

    setState(() {
      _permissionReady = hasGranted;
    });
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
      url: task.link!,
      headers: {"auth": "test_for_sql_encoding"},
      savedDir: _localPath,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    print("DOWNLOAD_TASK::::" + task.taskId.toString());
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId!);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(_TaskInfo task) async {
    print("RESUME_TASK::::" + task.taskId.toString());
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    print("RETRY_TASK::::" + task.taskId.toString());
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
    print("RETRYnewTaskId_TASK::::" + newTaskId.toString());
  }

  Future<bool> _openDownloadedFile(_TaskInfo? task) {
    if (task != null) {
      return FlutterDownloader.open(taskId: task.taskId!);
    } else {
      return Future.value(false);
    }
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder? data;
  final Function(_TaskInfo?)? onItemClick;
  final Function(_TaskInfo)? onActionClick;

  DownloadItem({this.data, this.onItemClick, this.onActionClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: InkWell(
        onTap: data!.task!.status == DownloadTaskStatus.complete
            ? () {
                onItemClick!(data!.task);
              }
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: data!.task!.link!,
                    fit: BoxFit.cover,
                    height: 90,
                    width: 90,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                )),
            data!.task!.status == DownloadTaskStatus.running ||
                    data!.task!.status == DownloadTaskStatus.paused
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: data!.task!.progress! / 100,
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildActionForTask(data!.task!),
            ),
          ].toList(),
        ),
      ),
    );
  }

  Widget? _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return Align(
        alignment: Alignment.center,
        child: RawMaterialButton(
          onPressed: () {
            onActionClick!(task);
          },
          child: Icon(
            Icons.file_download,
            color: AppColor.appWhite,
          ),
          shape: const CircleBorder(),
          constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
        ),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick!(task);
        },
        child: const Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: const CircleBorder(),
        constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick!(task);
        },
        child: const Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: const CircleBorder(),
        constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: new BoxDecoration(
              color: AppColor.applightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.file_download_done,
              color: AppColor.appGreen,
            ),
          ),
          GestureDetector(
            onTap: (){
              onActionClick!(task);
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(top: 18, right: 5),
                child: Icon(
                  Icons.delete_forever,
                  color: AppColor.appRedColor,
                ),
              ),
            ),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return const Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: const TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              onActionClick!(task);
            },
            child: Icon(
              Icons.refresh,
              color: AppColor.appGreen,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return const Text('Pending', style: TextStyle(color: Colors.orange));
    } else {
      return null;
    }
  }
}

class _TaskInfo {
  final String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String? name;
  final _TaskInfo? task;

  _ItemHolder({this.name, this.task});
}
