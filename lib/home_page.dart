import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/snake_head.dart';
import 'package:snake_game/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //zmienne okreslajace rozmiar siatki do gry:
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  //wynik
  int currentScore = 0;

  //gdzie jest wąż?
  List<int> snakePosition = [0, 1, 2];

  //na poczatku gry ruch weza odbywa sie w prawa strone:
  var currentDirection = snake_Direction.RIGHT;

  //gdzie jest ofiara?
  int foodPosition = 55;

  //tryb turbo
  bool turbo = false;
  //po starcie gry nie mozna juz zmieniac trybu z turbo na zwykly:
  bool gameOn = false;

  //metoda rozpoczynająca zabawę
  void startGame() {
    //sprawdz czy jestesmy w trybie turbo
    setState(() {
      gameOn = true;
    });
    Timer.periodic(Duration(milliseconds: turbo ? 100 : 200), (timer) {
      setState(() {
        //wąż się porusza
        moveSnake();

        //sprawdz czy wąż nie wjechał w samego siebie:
        if (gameOver()) {
          timer.cancel();
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("KONIEC GRY"),
                  content: Text('Twój wynik to: ' + currentScore.toString()),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        newGame();
                      },
                      child: const Text("Zamknij"),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void newGame() {
    setState(() {
      snakePosition = [0, 1, 2];
      foodPosition = 55;
      currentDirection = snake_Direction.RIGHT;
      currentScore = 0;
      gameOn = false;
      turbo = false;
    });
  }

  void runTurbo() {
    setState(() {
      turbo = !turbo;
    });
  }

  void eatFood() {
    //zdobyles punkt, gratulacje
    currentScore++;
    //sprawdzamy czy waz nie znajduje sie w miejscu ofiary i generujemy jej nowa lokalizacje
    while (snakePosition.contains(foodPosition)) {
      setState(() {
        foodPosition = Random().nextInt(totalNumberOfSquares);
      });
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //jezeli waz dotarl do sciany po prawej:
          if (snakePosition.last % rowSize == 9) {
            //nowa głowa
            snakePosition.add(snakePosition.last + 1 - rowSize);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          //odrzuć ogon
          // snakePosition.removeAt(0);
        }
        break;
      case snake_Direction.LEFT:
        {
          if (snakePosition.last % rowSize == 0) {
            snakePosition.add(snakePosition.last - 1 + rowSize);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          // snakePosition.removeAt(0);
        }
        break;
      case snake_Direction.UP:
        {
          if (snakePosition.last < rowSize) {
            snakePosition
                .add(totalNumberOfSquares - (rowSize - snakePosition.last));
          } else {
            snakePosition.add(snakePosition.last - rowSize);
          }

          // snakePosition.removeAt(0);
        }
        break;
      case snake_Direction.DOWN:
        {
          if (snakePosition.last >= (totalNumberOfSquares - rowSize)) {
            snakePosition
                .add(snakePosition.last - totalNumberOfSquares + rowSize);
          } else {
            snakePosition.add(snakePosition.last + rowSize);
          }

          // snakePosition.removeAt(0);
        }
        break;
    }

    //czy wąż zjada ofiarę?
    if (snakePosition.last == foodPosition) {
      eatFood();
    } else {
      //odrzuć ogon
      snakePosition.removeAt(0);
    }
  }

  //GAME OVER
  bool gameOver() {
    //tworzymy nową listę zawierającą wszystkie segmenty wężą oprócz głowy. jezeli w tej tablicy znajdzie sie pozycja glowy oznacza to koniec gry
    List<int> bodySnake = snakePosition.sublist(0, snakePosition.length - 1);
    if (bodySnake.contains(snakePosition.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        //obslugujemy klawiature
        body: RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (event) {
              if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
                  currentDirection != snake_Direction.UP) {
                setState(() {
                  currentDirection = snake_Direction.DOWN;
                });
              }
              if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
                  currentDirection != snake_Direction.DOWN) {
                setState(() {
                  currentDirection = snake_Direction.UP;
                });
              }
              if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
                  currentDirection != snake_Direction.RIGHT) {
                setState(() {
                  currentDirection = snake_Direction.LEFT;
                });
              }

              if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
                  currentDirection != snake_Direction.LEFT) {
                setState(() {
                  currentDirection = snake_Direction.RIGHT;
                });
              }
            },
            child: Column(
              children: [
                //wyniki gry
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //wynik
                        Text(
                          currentScore.toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                        //tryb turbo
                        ElevatedButton(
                          onPressed: gameOn ? null : runTurbo,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: gameOn
                                  ? Colors.black
                                  : (turbo ? Colors.red : Colors.grey[400])),
                          child: Wrap(
                            children: <Widget>[
                              const Icon(
                                Icons.speed,
                                color: Colors.black,
                                size: 24.0,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(turbo ? "TURBO ON" : "TURBO OFF",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ),
                        //highscores
                      ]),
                )),

                //miejsce na weza
                Expanded(
                    flex: 3,
                    //obslugujemy gesty
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        //w dół wężu!
                        if (details.delta.dy > 0 &&
                            currentDirection != snake_Direction.UP) {
                          setState(() {
                            currentDirection = snake_Direction.DOWN;
                          });
                        }
                        //teraz w górę!
                        if (details.delta.dy < 0 &&
                            currentDirection != snake_Direction.DOWN) {
                          setState(() {
                            currentDirection = snake_Direction.UP;
                          });
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        //w prawo
                        if (details.delta.dx > 0 &&
                            currentDirection != snake_Direction.LEFT) {
                          setState(() {
                            currentDirection = snake_Direction.RIGHT;
                          });
                        }
                        //w lewo
                        if (details.delta.dx < 0 &&
                            currentDirection != snake_Direction.RIGHT) {
                          setState(() {
                            currentDirection = snake_Direction.LEFT;
                          });
                        }
                      },
                      child: GridView.builder(
                        itemCount: totalNumberOfSquares,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: rowSize),
                        itemBuilder: (context, index) {
                          return snakePosition.contains(index)
                              ? (snakePosition[snakePosition.length - 1] ==
                                      index
                                  ? SnakeHead(
                                      eyesPosition: (currentDirection ==
                                                  snake_Direction.DOWN ||
                                              currentDirection ==
                                                  snake_Direction.UP)
                                          ? "horizontal"
                                          : "vertical")
                                  : const SnakePixel())
                              : (foodPosition == index
                                  ? const FoodPixel()
                                  : const BlankPixel());
                        },
                      ),
                    )),
                //guzik "start"
                Expanded(
                    child: Center(
                        child: MaterialButton(
                            color: Colors.green[800],
                            onPressed: gameOn ? null : startGame,
                            child: const Text("GRAMY"))))
              ],
            )));
  }
}
