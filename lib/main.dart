import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudoku/app_localizations.dart';
import 'package:sudoku/cell.dart';
import 'package:sudoku/sudoku_node.dart';
import 'package:sudoku/sudoku_nodes.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale.fromSubtags(languageCode: 'zh'),
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<SudokuNode>> sudokuNodes = [];
  List<SudokuNode> rowNodes = [];
  List<SudokuNode> groupNodes = [];
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    for (int i = 0; i < 9; i++) {
      sudokuNodes.add([]);
      for (int k = 0; k < 9; k++) {
        SudokuNode sudokuNode = SudokuNode(
          x: k,
          y: i,
        );
        sudokuNodes[i].add(sudokuNode);
      }
    }

    for (int i = 0; i < 9; i++) {
      List<SudokuNode> colNodes = [];
      for (int k = 0; k < 9; k++) {
        colNodes.add(sudokuNodes[i][k]);
        sudokuNodes[i][k].colNodes = colNodes;
      }
    }

    for (int i = 0; i < 9; i++) {
      List<SudokuNode> rowNodes = [];
      for (int k = 0; k < 9; k++) {
        rowNodes.add(sudokuNodes[k][i]);
        sudokuNodes[k][i].rowNodes = rowNodes;
      }
    }

    for (int i = 0; i <= 2; i++) {
      for (int k = 0; k <= 2; k++) {
        List<SudokuNode> groupNodes = [];
        int middleX = 3 * i + 1;
        int middleY = 3 * k + 1;
        for (int j = -1; j <= 1; j++) {
          for (int l = -1; l <= 1; l++) {
            groupNodes.add(sudokuNodes[middleX + j][middleY + l]);
            sudokuNodes[middleX + j][middleY + l].groupNodes = groupNodes;
          }
        }
      }
    }

    doActionInSudokuNodes((node) {
      if (node.x > 2 && node.x <= 5 && !(node.y > 2 && node.y <= 5)) {
        node.backgroundColor = Colors.grey.withAlpha(128);
      }
      if (node.y > 2 && node.y <= 5 && !(node.x > 2 && node.x <= 5)) {
        node.backgroundColor = Colors.grey.withAlpha(128);
      }
    });

    setState(() {});
  }

  void doActionInSudokuNodes(
    void Function(SudokuNode node) action,
  ) {
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {
        action(sudokuNodes[i][k]);
      }
    }
  }

  bool hasConflict() {
    bool error = false;
    doActionInSudokuNodes((node) {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          AppLocalizations.of(context)?.title ?? '',
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
              padding: const EdgeInsets.all(8),
              children: sudokuNodes
                  .map(
                    (colNodes) => GridView.count(
                      crossAxisCount: 9,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      children: colNodes
                          .map(
                            (e) => Cell(
                              backgroundColor: e.backgroundColor,
                              hasConflict: e.hasConflict,
                              isFixed: e.isFixed,
                              isInputMode: e.isInputMode,
                              onInput: (v) {
                                doActionInSudokuNodes((node) {
                                  node.illegalNum = [];
                                  if (node.isFixed != true) {
                                    node.value = null;
                                  }
                                });
                                e.value = int.tryParse(v);
                                e.isFixed = v.isNotEmpty;
                                setState(() {});
                              },
                              onTap: () {
                                doActionInSudokuNodes((node) {
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
            const SizedBox(
              height: 16,
            ),
            Builder(
              builder: (context) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        doActionInSudokuNodes((node) {
                          node.isInputMode = false;
                          node.isFixed = false;
                          node.value = null;
                        });
                        setState(() {});
                      },
                      child: Text(AppLocalizations.of(context)?.clear ?? ''),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    FilledButton(
                      onPressed: hasConflict()
                          ? null
                          : () {
                              doActionInSudokuNodes((node) {
                                node.illegalNum = [];
                                node.isInputMode = false;
                              });
                              SudokuNodes nodes = SudokuNodes(sudokuNodes);
                              int tryCnt = 0;
                              bool noAnswer = false;
                              while (true) {
                                tryCnt++;
                                SudokuNode? node = nodes.getNextNullNode();
                                if (node != null && node.availableNum != null) {
                                  node.value = node.availableNum;
                                } else {
                                  if (node != null) {
                                    SudokuNode? prevNode =
                                        nodes.getPrevNodeFrom(node);
                                    if (prevNode != null) {
                                      prevNode.illegalNum.add(prevNode.value!);
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

                              Timer(
                                const Duration(milliseconds: 400),
                                () {
                                  ScaffoldMessenger.of(context)
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${AppLocalizations.of(context)?.getAnsTips(tryCnt)}${noAnswer ? AppLocalizations.of(context)?.noAns : AppLocalizations.of(context)?.tellRes}',
                                        ),
                                      ),
                                    );
                                },
                              );
                            },
                      child: Text(
                        AppLocalizations.of(context)?.calculate ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                AppLocalizations.of(context)?.tips ?? '',
                style: const TextStyle(
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
