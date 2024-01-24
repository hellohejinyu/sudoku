import 'package:flutter/material.dart';
import 'package:sudoku/sudoku_node.dart';

class SudokuNodes {
  List<List<SudokuNode>> nodes;
  SudokuNodes(this.nodes);

  @override
  String toString() {
    nodes.asMap().forEach((key, node) {
      if (key % 3 == 0) {
        debugPrint('——————————————————————————————————');
      }
      debugPrint(node.map((e) => e.value ?? '0').toList().join((' | ')));
    });
    return '';
  }

  SudokuNode? getNextNullNode() {
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {
        if (nodes[i][k].value == null) {
          return nodes[i][k];
        }
      }
    }
    return null;
  }

  SudokuNode? getPrevNodeFrom(SudokuNode node) {
    SudokuNode? tmpNode;
    bool canInsert = true;
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        SudokuNode currentNode = nodes[y][x];
        if (identical(currentNode, node)) {
          canInsert = false;
        }
        if (currentNode.isFixed != true && canInsert) {
          tmpNode = currentNode;
        }
      }
    }
    return tmpNode;
  }

  void clearAfterNodeFrom(SudokuNode node) {
    bool clear = false;
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {
        if (clear) {
          nodes[i][k].illegalNum = [];
        }
        if (identical(nodes[i][k], node)) {
          clear = true;
        }
      }
    }
  }
}
