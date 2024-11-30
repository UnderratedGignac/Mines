import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _bombController = TextEditingController(text: '1');
  TextEditingController _moneyController = TextEditingController();
  double _wallet = 1000.0;
  String _errorMessage = '';

  double _calculateMultiplier(int numBombs, double initialMoney) {
    return 1.0 + numBombs * 0.5;
  }

  void _incrementBombs() {
    int currentValue = int.tryParse(_bombController.text) ?? 1;
    if (currentValue < 35) {
      setState(() {
        currentValue++;
        _bombController.text = currentValue.toString();
      });
    }
  }

  void _decrementBombs() {
    int currentValue = int.tryParse(_bombController.text) ?? 1;
    if (currentValue > 1) {
      setState(() {
        currentValue--;
        _bombController.text = currentValue.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose the number of bombs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wallet Balance: \$${_wallet.toStringAsFixed(2)}' , style: TextStyle(fontSize: 27,),), //money of the user
            SizedBox(height: 10),
            Text('Number of Bombs', style: TextStyle( fontSize: 27, color: Colors.red,),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrementBombs,// generate less bombs
                ),
                SizedBox(
                  width: 50,
                  child: TextFormField(//number of bombs textfield
                    controller: _bombController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _incrementBombs, // generate more bombs
                ),
              ],
            ),
            SizedBox(height: 20 ,width: 10,),
            SizedBox(width:300, child:
            TextField(
              controller: _moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount of Money", // let the user enter how much money he wants to play with
              ),
            ),),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double money = double.tryParse(_moneyController.text) ?? 0.0;
                if (money <= _wallet && money > 0) {
                  setState(() {
                    _wallet -= money; // Remove the money from wallet
                    _errorMessage = ''; // Clear any existing error message
                  });
                  int numBombs = int.tryParse(_bombController.text) ?? 1;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatrixPage(numBombs: numBombs, initialMoney: money, walletCallback: _updateWallet),// oepn the matix page
                    ),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Not enough money in the wallet!'; // if the user doesn t have enough money in his wallet
                  });
                }
              },
              child: Text('Play'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateWallet(double amount) {
    setState(() {
      _wallet += amount; // if the user returns to the initial page without pressing on a bomb
    });
  }
}

class MatrixPage extends StatefulWidget {
  int numBombs;
  double initialMoney;
  final Function(double) walletCallback;

  MatrixPage({required this.numBombs, required this.initialMoney, required this.walletCallback});

  @override
  _MatrixPageState createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  List<List<int>> _matrix = List.generate(6, (_) => List.generate(6, (_) => 0)); // lists to display bombs / crystals
  List<List<bool>> _buttonVisibility = List.generate(6, (_) => List.generate(6, (_) => true)); // lists to display the buttons
  final _random = Random();
  double _currentMoney = 0.0;
  int _collectedDiamonds = 0;

  @override
  void initState() {
    super.initState();
    _generateMatrixWithBombs(widget.numBombs);
  }

  void _generateMatrixWithBombs(int numBombs) {// function to put the number of bombs chosen on the first page in the crystal matrix
    setState(() {
      _matrix = List.generate(6, (_) => List.generate(6, (_) => 0));
      _buttonVisibility = List.generate(6, (_) => List.generate(6, (_) => true));
      _collectedDiamonds = 0;

      int bombsPlaced = 0;
      while (bombsPlaced < numBombs) {
        int i = _random.nextInt(6);
        int j = _random.nextInt(6);
        if (_matrix[i][j] == 0) {
          _matrix[i][j] = 1;
          bombsPlaced++;
        }
      }
    });
  }

  void _toggleMatrixButton(int i, int j) {// if the button chosen has a bomb inside of it
    if (_matrix[i][j] == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game Over"),
            content: Text("You hit a bomb and lost all your money!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() { // if the chosen button has a diamond inside it
        _buttonVisibility[i][j] = false;
        _currentMoney += widget.initialMoney * (0.07 * widget.numBombs) ; // how much the user earns
        _collectedDiamonds++;
        if (_collectedDiamonds == 36 - widget.numBombs) {
          _currentMoney *= 300.0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center( child: Text('Game Page'),
        ),automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Money: \$${_currentMoney.toStringAsFixed(2)}', // money that the user earns during the game
              style: TextStyle(fontSize: 28 ,color:  Colors.greenAccent),
            ),
            SizedBox(height: 10),
            for (int i = 0; i < 6; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 6; j++)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _matrix[i][j] == 1 ? Icons.warning : Icons.diamond,
                            size: 20,
                            color: _matrix[i][j] == 1 ? Colors.red : Colors.blue,
                          ),
                        ),
                        Visibility(
                          visible: _buttonVisibility[i][j],
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _toggleMatrixButton(i, j),
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.walletCallback(_currentMoney);
                Navigator.of(context).pop();
              },
              child: Text('Stop the game'),
            ),
          ],
        ),
      ),
    );
  }
}
