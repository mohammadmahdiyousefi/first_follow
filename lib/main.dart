import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'First & Follow'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, List<String>> gramer = {};
  Map<String, Set<String>> first = {};
  Map<String, Set<String>> follow = {};
  TextEditingController con = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              padding: EdgeInsets.symmetric(horizontal: 10),
              icon: Icon(Icons.refresh),
              hoverColor: Colors.blue[400],
              tooltip: 'Refresh Converter',
              onPressed: () {
                Phoenix.rebirth(context);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await addDiolog(context);
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12)),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: gramer.length,
                  itemBuilder: (context, index) {
                    return Text(
                      "${gramer.keys.toList()[index]} -> ${gramer.values.toList()[index]}",
                      style: const TextStyle(fontSize: 22),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(260, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    var firstCalculator = FirstCalculator();
                    for (var nonTerminal in gramer.keys) {
                      var firstSet =
                          firstCalculator.calculateFirst(nonTerminal, gramer);
                      var a = firstSet;
                      a.removeWhere((element) => element == "");
                      first.addAll({nonTerminal: a});
                      print('First($nonTerminal): ${a}');
                    }
                    setState(() {});
                  },
                  child: const Text("first")),
              const SizedBox(
                height: 16,
              ),
              Text("Enter startingSymbol"),
              SizedBox(
                height: 50,
                width: 50,
                child: TextField(
                  controller: con,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(260, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (first.isEmpty) {
                    } else {
                      if (con.text.isEmpty) {
                      } else {
                        var startingSymbol = con.text;
                        var followCalculator =
                            FollowCalculator(gramer, startingSymbol, first);
                        followCalculator.calculateFirstSets();
                        followCalculator.calculateAllFollowSets();
                        followCalculator.printFollowSets();
                        follow = followCalculator.printFollowSets();
                        setState(() {});
                      }
                    }
                  },
                  child: const Text("follow")),
              first.isEmpty
                  ? Container()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: first.length,
                        itemBuilder: (context, index) {
                          return Text(
                            "First(${first.keys.toList()[index]}) = ${first.values.toList()[index]}",
                            style: const TextStyle(fontSize: 22),
                          );
                        },
                      ),
                    ),
              follow.isEmpty
                  ? Container()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: follow.length,
                        itemBuilder: (context, index) {
                          return Text(
                            "Follow(${follow.keys.toList()[index]}) = ${follow.values.toList()[index]}",
                            style: const TextStyle(fontSize: 22),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ));
  }

  Future addDiolog(BuildContext context) {
    TextEditingController nonterminal = TextEditingController();
    TextEditingController terminal = TextEditingController();
    List<String> listterminal = [];
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  listterminal.clear();
                  if (terminal.text.contains("|")) {
                    listterminal = terminal.text.split("|");
                  } else {
                    listterminal.add(terminal.text);
                  }
                  if (gramer.containsKey(nonterminal.text)) {
                    gramer.update(nonterminal.text, (value) {
                      var list = value;
                      list.add(terminal.text);
                      return list;
                    });
                  } else {
                    gramer.addAll({nonterminal.text: listterminal});
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Text("Accept"))
          ],
          content: Container(
              height: 100,
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                      width: 30,
                      child: TextField(
                        controller: nonterminal,
                      )),
                  Text(
                    "  ->  ",
                    style: TextStyle(fontSize: 35),
                  ),
                  Expanded(
                      child: TextField(
                    controller: terminal,
                  ))
                ],
              )),
        );
      },
    );
  }
}

class FirstCalculator {
  Set<String> calculateFirst(
      String symbol, Map<String, List<String>> productions) {
    Set<String> firstSet = Set();

    if (productions.containsKey(symbol)) {
      for (var alternative in productions[symbol]!) {
        var firstSymbol = alternative[0];

        if (productions.containsKey(firstSymbol)) {
          var firstSymbolFirstSet = calculateFirst(firstSymbol, productions);
          firstSet.addAll(firstSymbolFirstSet);

          if (firstSymbolFirstSet.contains('@')) {
            var restOfAlternative = alternative.substring(1);
            var restFirstSet = calculateFirst(restOfAlternative, productions);
            firstSet.addAll(restFirstSet.where((s) => s != '@'));
          }
        } else if (firstSymbol == '@' ||
            !productions.containsKey(firstSymbol)) {
          firstSet.add(firstSymbol);
        }
      }
    } else if (!productions.containsKey(symbol) && symbol != '@') {
      firstSet.add(symbol);
    }

    return firstSet;
  }
}

class FollowCalculator {
  final Map<String, List<String>> productions;
  final String startSymbol;
  Map<String, Set<String>> firstSets;
  Map<String, Set<String>> followSets;

  FollowCalculator(this.productions, this.startSymbol, this.firstSets)
      : followSets = {};
  Set<String> calculateFirst(String symbols) {
    var firstSet = <String>{};
    var symbolList = symbols.split(' ');

    for (var i = 0; i < symbolList.length; i++) {
      var symbol = symbolList[i];

      if (!productions.containsKey(symbol) || symbol == '@') {
        // اگر نماد ترمینال یا نان ترمینال باشد
        firstSet.add(symbol);
        break;
      } else {
        // اگر نماد نان ترمینال نباشد
        firstSet.addAll(firstSets[symbol]!);
        if (!firstSet.contains('@')) {
          break;
        }
      }
    }

    return firstSet;
  }

  Map<String, Set<String>> calculateFirstSets() {
    var firstSets = <String, Set<String>>{};
    for (var nonTerminal in productions.keys) {
      firstSets[nonTerminal] = calculateFirstSet(nonTerminal);
    }
    return firstSets;
  }

  Set<String> calculateFirstSet(String nonTerminal) {
    var firstSet = <String>{};

    for (var production in productions[nonTerminal]!) {
      var symbols = production.split(' ');
      var index = 0;
      while (index < symbols.length) {
        var symbol = symbols[index];
        if (!productions.containsKey(symbol) || symbol == '@') {
          firstSet.add(symbol);
          break;
        } else {
          firstSet.addAll(firstSets[symbol]!);
          if (!firstSet.contains('@')) {
            break;
          }
        }
        index++;
      }

      if (index == symbols.length) {
        firstSet.add('@');
      }
    }

    return firstSet;
  }

  Set<String> calculateFollowSet(String nonTerminal) {
    if (followSets.containsKey(nonTerminal)) {
      return followSets[nonTerminal]!;
    }

    var followSet = <String>{};
    if (nonTerminal == startSymbol) {
      followSet.add('\$');
    } else {
      for (var entry in productions.entries) {
        var leftHandSide = entry.key;
        var rightHandSides = entry.value;

        for (var rightHandSide in rightHandSides) {
          var symbols = rightHandSide;
          if (symbols.contains(nonTerminal)) {
            int i = symbols.indexOf(nonTerminal);
            if (i != -1) {
              if (i == symbols.length - 1) {
                print(leftHandSide);
                if (leftHandSide != symbols[i]) {
                  followSet.addAll(calculateFollowSet(leftHandSide));
                }
              } else {
                var rest = symbols.substring(i + 1);
                var firstOfRest = calculateFirst(rest);
                print(rest);
                if (firstOfRest.contains('@')) {
                  followSet.addAll(calculateFollowSet(leftHandSide));
                  followSet.addAll(firstOfRest.difference({'@'}));
                } else {
                  followSet.addAll(firstOfRest);
                }
              }
            }
          }
        }
      }
    }
    followSets[nonTerminal] = followSet;
    return followSet;
  }

  void calculateAllFollowSets() {
    for (var nonTerminal in productions.keys) {
      calculateFollowSet(nonTerminal);
    }
  }

  Map<String, Set<String>> printFollowSets() {
    return followSets;
  }
}
