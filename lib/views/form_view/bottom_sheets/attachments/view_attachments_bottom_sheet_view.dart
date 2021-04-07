import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/constants.dart';
import 'package:frappe_app/utils/enums.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:open_file/open_file.dart';

import 'add_attachments_bottom_sheet_view.dart';

class ViewAttachmentsBottomSheetView extends StatelessWidget {
  final List<Attachments> attachments;

  const ViewAttachmentsBottomSheetView({
    Key key,
    @required this.attachments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3 - 80;
    final double itemWidth = size.width / 2;

    return BaseView<ViewAttachmenetsBottomSheetViewModel>(
      onModelClose: (model) {},
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.9,
        child: FrappeBottomSheet(
          title: 'Attachments',
          onActionButtonPress: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddAttachmentsBottomSheetView(),
            );
          },
          trailing: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_add,
                color: FrappePalette.blue[500],
                size: 16,
              ),
              Text(
                'Attach File',
                style: TextStyle(
                  color: FrappePalette.blue[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 10,
              elevation: 0,
              title: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        model.changeTab(AttachmentsFilter.all);
                      },
                      child: Tab(
                        title: 'All',
                        selected: model.selectedFilter == AttachmentsFilter.all,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        model.changeTab(AttachmentsFilter.files);
                      },
                      child: Tab(
                        title: 'Files',
                        selected:
                            model.selectedFilter == AttachmentsFilter.files,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        model.changeTab(AttachmentsFilter.links);
                      },
                      child: Tab(
                        title: 'Links',
                        selected:
                            model.selectedFilter == AttachmentsFilter.links,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: model.selectedFilter == AttachmentsFilter.all
                ? AttachmentsGrid(
                    itemWidth: itemWidth,
                    itemHeight: itemHeight,
                    attachments: attachments,
                  )
                : AttachmentsList(
                    attachmentsFilter: model.selectedFilter,
                    attachments: attachments,
                  ),
          ),
        ),
      ),
    );
  }
}

class AttachmentsList extends StatelessWidget {
  final AttachmentsFilter attachmentsFilter;
  final List<Attachments> attachments;

  const AttachmentsList({
    Key key,
    @required this.attachmentsFilter,
    @required this.attachments,
  }) : super(key: key);

  bool isFile(Attachments attachment) {
    var ext = attachment.fileName.split('.').last;
    return Constants.imageExtensions.indexOf(ext) == -1 && !isLink(attachment);
  }

  bool isLink(Attachments attachment) {
    var scheme = Uri.parse(attachment.fileUrl).scheme;
    return attachment.fileName == '' && (scheme == 'http' || scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    List filteredAttachments;
    if (attachmentsFilter == AttachmentsFilter.files) {
      filteredAttachments = attachments.where((attachment) {
        return isFile(attachment);
      }).toList();
    } else {
      filteredAttachments = attachments.where((attachment) {
        return isLink(attachment);
      }).toList();
    }
    return ListView.builder(
      itemCount: filteredAttachments.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () async {
            var attachment = filteredAttachments[index];
            var downloadPath = await getDownloadPath();
            var fileUrlName = attachment["file_url"].split('/').last;

            var filePath = "$downloadPath$fileUrlName";

            var fileExists = await io.File(filePath).exists();

            if (fileExists) {
              OpenFile.open(filePath);
            } else {
              downloadFile(attachment["file_url"], downloadPath);
            }
          },
          title: Text(filteredAttachments[index]["file_name"]),
          subtitle: Text('15 Sep, 2020'),
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: FrappePalette.grey[100],
            ),
            child: Center(
              child: Text(
                filteredAttachments[index]["file_name"].split('.').last,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttachmentsGrid extends StatelessWidget {
  const AttachmentsGrid({
    Key key,
    @required this.itemWidth,
    @required this.itemHeight,
    @required this.attachments,
  }) : super(key: key);

  final double itemWidth;
  final double itemHeight;
  final List<Attachments> attachments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: (itemWidth / itemHeight),
      ),
      itemCount: attachments.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var ext = attachments[index].fileName.split('.').last;
        var isImage = Constants.imageExtensions.indexOf(ext) != -1;

        return GestureDetector(
          onTap: () async {
            var attachment = attachments[index];
            var downloadPath = await getDownloadPath();
            var fileUrlName = attachment.fileUrl.split('/').last;

            var filePath = "$downloadPath$fileUrlName";

            try {
              var fileExists = await io.File(filePath).exists();
              if (fileExists) {
                OpenFile.open(filePath);
              } else {
                downloadFile(attachment.fileUrl, downloadPath);
              }
            } catch (e) {
              print(e);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  color: FrappePalette.grey[200],
                  height: itemHeight - 55,
                  width: itemWidth,
                  child: Center(
                    child: Text(
                      ext != '' ? ext.toUpperCase() : 'LINK',
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    FrappeIcon(
                      isImage ? FrappeIcons.image_add : FrappeIcons.small_file,
                      size: 12,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      attachments[index].fileName != ''
                          ? attachments[index].fileName
                          : attachments[index].fileUrl,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Tab extends StatelessWidget {
  final String title;
  final bool selected;

  const Tab({
    Key key,
    @required this.title,
    @required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: selected ? FrappePalette.grey[600] : FrappePalette.grey[100],
        borderRadius: BorderRadius.circular(
          6,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: selected ? Colors.white : FrappePalette.grey[800],
          ),
        ),
      ),
    );
  }
}