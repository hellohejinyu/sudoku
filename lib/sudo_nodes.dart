import 'package:sudoku/sudo_node.dart';

class SudoNodes {
  List<List<SudoNode>> nodes;
  SudoNodes(this.nodes);

  @override
  String toString() {
    nodes.asMap().forEach((key, node) {
      if (key % 3 == 0) {
        print('——————————————————————————————————');
      }
      print(node.map((e) => e.value ?? '0').toList().join((' | ')));
    });
    return '';
  }

  SudoNode getNextNullNode() {
    for (int i = 0; i < 9; i++) {
      for (int k = 0; k < 9; k++) {
        if (nodes[i][k].value == null) {
          return nodes[i][k];
        }
      }
    }
    return null;
  }

  SudoNode getPrevNodeFrom(SudoNode node) {
    SudoNode tmpNode;
    bool canInsert = true;
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        SudoNode currentNode = nodes[y][x];
        if (identical(currentNode, node)) {
          canInsert = false;
        }
        if (!currentNode.isFixed && canInsert) {
          tmpNode = currentNode;
        }
      }
    }
    return tmpNode;
  }

  void clearAfterNodeFrom(SudoNode node) {
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

  bool getNextNodeAndCheck() {
    SudoNode lastNullNode = getNextNullNode();
    if (lastNullNode == null) {
      return true;
    }

    return false;
  }
}
