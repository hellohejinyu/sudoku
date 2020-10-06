import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudoku/app_localizations.dart';
import 'package:sudoku/cell.dart';
import 'package:sudoku/sudo_node.dart';
import 'package:sudoku/sudo_nodes.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudo',
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale.fromSubtags(languageCode: 'zh'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<SudoNode>> sudoNodes = [];
  List<SudoNode> rowNodes = [];
  List<SudoNode> groupNodes = [];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    for (int i = 0; i < 9; i++) {
      sudoNodes.add([]);
      for (int k = 0; k < 9; k++) {
        SudoNode sudoNode = SudoNode(x: k, y: i);
        sudoNodes[i].add(sudoNode);
      }
    }

    for (int i = 0; i < 9; i++) {
      List<SudoNode> colNodes = [];
      for (int k = 0; k < 9; k++) {
        colNodes.add(sudoNodes[i][k]);
        sudoNodes[i][k].colNodes = colNodes;
      }
    }

    for (int i = 0; i < 9; i++) {
      List<SudoNode> rowNodes = [];
      for (int k = 0; k < 9; k++) {
        rowNodes.add(sudoNodes[k][i]);
        sudoNodes[k][i].rowNodes = rowNodes;
      }
    }

    for (int i = 0; i <= 2; i++) {
      for (int k = 0; k <= 2; k++) {
        List<SudoNode> groupNodes = [];
        int middleX = 3 * i + 1;
        int middleY = 3 * k + 1;
        for (int j = -1; j <= 1; j++) {
          for (int l = -1; l <= 1; l++) {
            groupNodes.add(sudoNodes[middleX + j][middleY + l]);
            sudoNodes[middleX + j][middleY + l].groupNodes = groupNodes;
          }
        }
      }
    }

    doActionInSudoNodes((node) {
      if (node.x > 2 && node.x <= 5 && !(node.y > 2 && node.y <= 5)) {
        node.backgroundColor = Colors.grey.withAlpha(100);
      }
      if (node.y > 2 && node.y <= 5 && !(node.x > 2 && node.x <= 5)) {
        node.backgroundColor = Colors.grey.withAlpha(100);
      }
    });

    setState(() {});
  }

  void doActionInSudoNodes(
    void Function(SudoNode node) action,
  ) {
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {
        action(sudoNodes[i][k]);
      }
    }
  }

  bool hasConflict() {
    bool error = false;
    doActionInSudoNodes((node) {
      if (node.hasConflict) {
        error = true;
      }
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              childAspectRatio: 9,
              padding: EdgeInsets.all(8),
              children: sudoNodes
                  .map(
                    (colNodes) => GridView.count(
                      crossAxisCount: 9,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      children: colNodes
                          .map(
                            (e) => Cell(
                              backgroundColor: e.backgroundColor ??
                                  Colors.grey.withAlpha(48),
                              hasConflict: e.hasConflict,
                              isFixed: e.isFixed,
                              isInputMode: e.isInputMode,
                              onInput: (v) {
                                doActionInSudoNodes((node) {
                                  node.illegalNum = [];
                                  if (!node.isFixed) {
                                    node.value = null;
                                  }
                                });
                                e.value = int.tryParse(v);
                                e.isFixed = v.length > 0;
                                setState(() {});
                              },
                              onTap: () {
                                doActionInSudoNodes((node) {
                                  node.isInputMode = false;
                                });
                                e.isInputMode = true;
                                setState(() {});
                              },
                              value: e.value,
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(
              height: 16,
            ),
            Builder(
              builder: (context) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    RaisedButton(
                      onPressed: () {
                        doActionInSudoNodes((node) {
                          node.isInputMode = false;
                          node.isFixed = false;
                          node.value = null;
                        });
                        setState(() {});
                      },
                      child: Text(AppLocalizations.of(context).clear),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: hasConflict()
                          ? null
                          : () {
                              doActionInSudoNodes((node) {
                                node.illegalNum = [];
                                node.isInputMode = false;
                              });
                              SudoNodes nodes = SudoNodes(sudoNodes);
                              int tryCnt = 0;
                              bool noAnswer = false;
                              while (true) {
                                tryCnt++;
                                SudoNode node = nodes.getNextNullNode();
                                if (node != null && node.availableNum != null) {
                                  node.value = node.availableNum;
                                } else {
                                  if (node != null) {
                                    SudoNode prevNode =
                                        nodes.getPrevNodeFrom(node);
                                    if (prevNode != null) {
                                      prevNode.illegalNum.add(prevNode.value);
                                      prevNode.value = null;
                                      nodes.clearAfterNodeFrom(prevNode);
                                      continue;
                                    } else {
                                      noAnswer = true;
                                    }
                                  }
                                  break;
                                }
                              }
                              setState(() {});

                              Timer(Duration(milliseconds: 400), () {
                                Scaffold.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${AppLocalizations.of(context).getAnsTips(tryCnt)}${noAnswer ? AppLocalizations.of(context).noAns : AppLocalizations.of(context).tellRes}',
                                      ),
                                    ),
                                  );
                              });
                            },
                      child: Text(
                        AppLocalizations.of(context).calculate,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                AppLocalizations.of(context).tips,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
