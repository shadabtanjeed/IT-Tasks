import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student ID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 5, 84, 76),
        ),
      ),
      // home: const MyHomePage(title: 'Student ID'),
      home: const FormPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.unversityName,
    required this.studentName,
    required this.studentID,
    required this.program,
    required this.department,
    required this.country,
    required this.subtitle,
    this.profile_image,
    this.uni_logo,
  });

  final String title;
  final String unversityName;
  final String studentName;
  final String studentID;
  final String program;
  final String department;
  final String country;
  final String subtitle;
  final Image? profile_image;
  final Image? uni_logo;

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
                                  'assets/images/nuh.jpg',
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
                                            '210041160',
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

class FormPage extends StatefulWidget {
  const FormPage({super.key});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final unversityNameController = TextEditingController();
  final studentNameController = TextEditingController();
  final studentIDController = TextEditingController();
  final programController = TextEditingController();
  final departmentController = TextEditingController();
  final countryController = TextEditingController();
  final subtitleController = TextEditingController();

  Image? profile_image;
  Image? uni_logo;

  Future<void> pickImage() async {
    try {
      Image? fromPicker = await ImagePickerWeb.getImageAsWidget();
      if (fromPicker != null) {
        setState(() {
          profile_image = fromPicker;
        });

        print('Image selected successfully');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void generateIDCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: 'Student ID Card',
          unversityName: unversityNameController.text,
          studentName: studentNameController.text,
          studentID: studentIDController.text,
          program: programController.text,
          department: departmentController.text,
          country: countryController.text,
          subtitle: subtitleController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please provide your information'),

            const Text('Choose your profile picture'),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pick Profile Picture'),
            ),

            if (selectedImage != null)
              SizedBox(height: 150, width: 150, child: selectedImage!),

            TextFormField(
              decoration: const InputDecoration(labelText: 'University Name'),
              controller: unversityNameController,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Student Name'),
              controller: studentNameController,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Student ID'),
              controller: studentIDController,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Program'),
              controller: programController,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Department'),
              controller: departmentController,
            ),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Country'),
              controller: countryController,
            ),

            ElevatedButton(
              onPressed: generateIDCard,
              child: const Text('Generate ID Card'),
            ),
          ],
        ),
      ),
    );
  }
}
