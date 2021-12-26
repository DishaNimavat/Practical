import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practical_aveosoft/utils/app_color.dart';
import 'package:flutter_practical_aveosoft/utils/constants.dart';
import 'package:flutter_practical_aveosoft/utils/style/fonts.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appGreyBackground,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColor.appBlack,
          ),
        ),
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Downloads",
              style: Fonts.dashboardTitleStyle,
            )),
      ),
      body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return listVewItem();
          }),
    );
  }

  Widget listVewItem() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColor.applightGrey,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: "https://picsum.photos/id/0/5616/3744",
                fit: BoxFit.cover,
                height: 90,
                width: 90,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Title",
                    style: Fonts.dashboardTitleStyle,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColor.appGreen,
                    ),
                    child: Text(
                      "Image Status",
                      style: Fonts.onBoardingTitleStyle
                          .copyWith(color: AppColor.appWhite, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
            const Icon(Icons.more_vert)
          ],
        ),
      ),
    );
  }
}
