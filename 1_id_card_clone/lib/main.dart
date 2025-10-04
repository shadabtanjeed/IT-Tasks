import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student ID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003433)),
      ),
      home: const MyHomePage(title: 'Student ID'),
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
  @override
  Widget build(BuildContext context) {
    const double cardWidth = 300.0;
    const double cardHeight = 480.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF003433),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/iut.png',
                                width: 70,
                                height: 70,
                              ),
                              const Text(
                                'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.21,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF003433),
                                    width: 6.5,
                                  ),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'assets/images/profile.jpeg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.key,
                                      size: 20,
                                      color: Color(0xFF003433),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Student ID',
                                      style: TextStyle(
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF003433),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.blue,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '990103180',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFF003433),
                                      radius: 9,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Student Name',
                                      style: TextStyle(
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                'SHADAB TANJEED AHMAD',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF003433),
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.school,
                                      size: 20,
                                      color: Color(0xFF003433),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Program: ',
                                      style: TextStyle(
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'B.Sc in CSE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003433),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFF003433),
                                      radius: 9,
                                      child: Icon(
                                        Icons.group,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Department: ',
                                      style: TextStyle(
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'CSE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003433),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 170,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: Color(0xFF003433),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Bangladesh',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003433),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 26,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF003433),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'A subsidiary organ of OIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
