import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/indicator.dart';
import 'package:frappe_app/widgets/custom_form.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:frappe_app/widgets/timeline.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

import '../main.dart';
import '../config/palette.dart';

import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../widgets/like_doc.dart';

import '../screens/view_docinfo.dart';
import '../screens/email_form.dart';
import '../screens/comment_input.dart';

class FormView extends StatefulWidget {
  final String doctype;
  final String name;
  final Map meta;

  FormView({
    @required this.doctype,
    @required this.name,
    this.meta,
  });

  @override
  _FormViewState createState() => _FormViewState();
}

class _FormViewState extends State<FormView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Future futureIssueDetail;
  bool editMode = false;
  final user = localStorage.getString('user');
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
    futureIssueDetail = backendService.getdoc(
      widget.doctype,
      widget.name,
    );
  }

  void _refresh() {
    setState(() {
      futureIssueDetail = backendService.getdoc(widget.doctype, widget.name);
      editMode = false;
    });
  }

  List<Widget> _generateAssignees(List l) {
    const int size = 2;
    List<Widget> w = [];

    if (l.length == 0) {
      return [
        CircleAvatar(
          backgroundColor: Palette.bgColor,
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ];
    }

    for (int i = 0; i < l.length; i++) {
      if (i < size) {
        w.add(
          UserAvatar(uid: l[i]["owner"]),
        );
      } else {
        w.add(UserAvatar.renderShape(txt: "+ ${l.length - size}"));
        break;
      }
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureIssueDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docs = snapshot.data["docs"];
            var docInfo = snapshot.data["docinfo"];
            var builderContext;
            var likedBy = docs[0]['_liked_by'] != null
                ? json.decode(docs[0]['_liked_by'])
                : [];
            var isLikedByUser = likedBy.contains(user);

            return Scaffold(
                backgroundColor: Palette.bgColor,
                bottomNavigationBar: Container(
                  height: editMode ? 0 : 60,
                  child: BottomAppBar(
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        FrappeRaisedButton(
                          minWidth: 120,
                          title: 'Comment',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CommentInput(
                                    doctype: widget.doctype,
                                    name: widget.name,
                                    authorEmail: localStorage.getString('user'),
                                    callback: _refresh,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FrappeRaisedButton(
                          minWidth: 120,
                          title: 'New Email',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EmailForm(
                                    callback: _refresh,
                                    subjectField: docs[0][
                                        widget.meta["subject_field"] ??
                                            widget.meta["title_field"]],
                                    senderField: docs[0]
                                        [widget.meta["sender_field"]],
                                    doctype: widget.doctype,
                                    doc: widget.name,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    builderContext = context;
                    return DefaultTabController(
                      length: 2,
                      child: NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverAppBar(
                              elevation: 0,
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  padding: EdgeInsets.only(
                                    top: 90,
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewDocInfo(
                                              meta: widget.meta,
                                              doc: docs[0],
                                              docInfo: docInfo,
                                              doctype: widget.doctype,
                                              name: widget.name,
                                              callback: _refresh,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            docs[0][widget
                                                    .meta["title_field"]] ??
                                                docs[0]["name"],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Indicator.buildStatusButton(
                                                widget.doctype,
                                                docs[0]['status']),
                                            Spacer(),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ViewDocInfo(
                                                        doc: docs[0],
                                                        meta: widget.meta,
                                                        docInfo: docInfo,
                                                        doctype: widget.doctype,
                                                        name: widget.name,
                                                        callback: _refresh,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: _generateAssignees(
                                                    docInfo["assignments"]),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                // if (!editMode)
                                //   LikeDoc(
                                //     doctype: widget.doctype,
                                //     name: widget.name,
                                //     isFav: isLikedByUser,
                                //   ),
                                if (editMode)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 4,
                                    ),
                                    child: FrappeFlatButton(
                                      buttonType: ButtonType.secondary,
                                      title: 'Cancel',
                                      onPressed: () {
                                        _fbKey.currentState.reset();
                                        _refresh();
                                      },
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 4,
                                  ),
                                  child: FrappeFlatButton(
                                    buttonType: ButtonType.primary,
                                    title: editMode ? 'Save' : 'Edit',
                                    onPressed: editMode
                                        ? () async {
                                            if (_fbKey.currentState
                                                .saveAndValidate()) {
                                              var formValue =
                                                  _fbKey.currentState.value;
                                              await backendService.updateDoc(
                                                widget.doctype,
                                                widget.name,
                                                formValue,
                                              );
                                              showSnackBar(
                                                'Changes Saved',
                                                builderContext,
                                              );
                                              _refresh();
                                            }
                                          }
                                        : () {
                                            setState(() {
                                              editMode = true;
                                            });
                                          },
                                  ),
                                )
                              ],
                              expandedHeight: editMode ? 0.0 : 180.0,
                              floating: true,
                              pinned: true,
                            ),
                            SliverPersistentHeader(
                              delegate: _SliverAppBarDelegate(
                                TabBar(
                                  labelColor: Colors.black87,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(
                                      child: Text('Detail'),
                                    ),
                                    Tab(
                                      child: Text('Activity'),
                                    ),
                                  ],
                                ),
                              ),
                              pinned: true,
                            ),
                          ];
                        },
                        body: TabBarView(children: [
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  color: Palette.bgColor,
                                  height: 10,
                                ),
                                CustomForm(
                                  fields: widget.meta["fields"],
                                  formKey: _fbKey,
                                  doc: docs[0],
                                  viewType: ViewType.form,
                                  editMode: editMode,
                                ),
                              ],
                            ),
                          ),
                          Timeline([
                            ...docInfo['comments'],
                            ...docInfo["communications"],
                            ...docInfo["versions"],
                            // ...docInfo["views"],TODO
                          ], () {
                            _refresh();
                          }),
                        ]),
                      ),
                    );
                  },
                ));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
