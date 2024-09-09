
// ignore_for_file: file_names, non_constant_identifier_names, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';


var db = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {

  
@override
  Widget build(BuildContext context) {
    return  MaterialApp(home: LoginPage());
  }
  
}


class Home extends StatefulWidget {
  //const Home({super.key});

  final String uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  

  @override
  State<Home> createState() => _HomeState();
}

//String goal = '';

class _HomeState extends State<Home> {

  final expense_name = TextEditingController();
  final expense_value = TextEditingController();
  final income_name = TextEditingController();
  final income_value = TextEditingController();
  final index = TextEditingController();
  final index2 = TextEditingController();
  final goal_alter = TextEditingController();

  bool goal_value = false;
  bool exp_name = false;
  bool exp_value = false;
  bool epx_index = false;
  bool inc_name = false;
  bool inc_value = false;
  bool inc_index = false;

  
  Future change_goal() async {

  bool num = true;

 try {
  double integerValue = double.parse(goal_alter.text);
  // The value is a double, and integerValue contains the parsed double.
  print('Parsed double value: $integerValue');
    num = true; // Use a different variable name
    goal_value = false; // Reset the flag for successful parsing
} catch (e) {
  // An exception occurred, indicating that the value is not a double.
  print('Error: $e');
  setState(() {
    goal_value = true; // Set the flag for unsuccessful parsing
    num = false; // Reset the flag for unsuccessful parsing
  });
}
    
    if (goal_alter.text.isNotEmpty && num == true){
    double value = double.parse(goal_alter.text);
    String roundedValue = value.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    double parsedvalue = NumberFormat.decimalPattern("en_US").parse(roundedValue).toDouble();

    try{

      await
      FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .update({'goal(current)':parsedvalue});
    
    goal_value = false;
    setState(() {
        
      });

    goal_alter.clear();

    }catch (e) {
      print('Error adding expense: $e');
      goal_value = true;
      setState(() {});
    }
    
    }else{
      goal_value = true;
      goal_alter.clear();
      print("incorrect input");
      setState(() {});
    }
  }

  Future addExpense() async{

  bool numFlag = false;
  bool stringFlag = true;

  try {
  double integerValue = double.parse(expense_value.text);
  // The value is a double, and integerValue contains the parsed double.
  print('Parsed double value: $integerValue');
    numFlag = true;
    exp_value = false;
  
} catch (e) {
  // An exception occurred, indicating that the value is not a double.
  print('Error: $e');
    exp_value = true;
    numFlag = false;
}

try {
  int integerValue = int.parse(expense_name.text);
  // The value is an integer, and integerValue contains the parsed integer.
  print('Parsed integer value: $integerValue');
    stringFlag = false;
    exp_name = true;
} catch (e) {
  // An exception occurred, indicating that the value is not an integer.
  print('Error: $e');
    exp_name = false;
    stringFlag = true;
}


    
    if (expense_name.text.isNotEmpty && expense_value.text.isNotEmpty && numFlag == true && stringFlag == true){
    var value = double.parse(expense_value.text);
    String roundedValue = value.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    double parsedValue = NumberFormat.decimalPattern("en_US").parse(roundedValue).toDouble();
    try {
  
      await 
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'Expense': FieldValue.arrayUnion([expense_name.text.toString()]),
      
      });
      
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'expense(value)': FieldValue.arrayUnion([parsedValue]),
      });

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    List<dynamic> currentArray = userSnapshot['Expense'];
    int length = currentArray.length;

     await
     FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'expense(index)': FieldValue.arrayUnion([length]),
      });


      print('Expense added successfully');
      exp_name = false;
      exp_value = false;
      setState(() {
        
      });

      expense_name.clear();
      expense_value.clear();
      
      
    } catch (e) {
      print('Error adding expense: $e');
      exp_name = true;
      exp_value = true;
      setState(() {});
    }
  } else {
    
    print('Incorrect input');
    setState(() {
    exp_name = true;
    exp_value = true;
    expense_name.clear();
    expense_value.clear();
    });
  }
}

Future<void> deleteExpenseAtIndex() async {
  bool test = false;
  try {
  double integerValue = double.parse(index.text);
  // The value is a double, and integerValue contains the parsed double.
  print('Parsed double value: $integerValue');
    test = true; // Use a different variable name
    epx_index = false; // Reset the flag for successful parsing
} catch (e) {
  // An exception occurred, indicating that the value is not a double.
  print('Error: $e');
  setState(() {
    epx_index = true; // Set the flag for unsuccessful parsing
    test = false; // Reset the flag for unsuccessful parsing
  });
}

if (test == true) {
  var value = int.parse(index.text)-1;
  try {
    // Retrieve the current array from Firebase
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    List<dynamic> currentArray = userSnapshot['Expense'];
    List<dynamic> number = userSnapshot['expense(value)'];
    List<dynamic> indexList = userSnapshot['expense(index)'];
    
    int length = currentArray.length;
    

    // Check if the index is valid
    if (value >= 0 && value < currentArray.length) {
      // Remove the element at the specified index
      currentArray.removeAt(value);
      number.removeAt(value);
      indexList.removeAt(length-1);

      // Update the array in Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'Expense': currentArray});
        
        FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'expense(value)': number});
        
        FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'expense(index)': indexList});

      print('Expense at index $index deleted successfully');

      epx_index = false;
      index.clear();

      setState(() {
        
      });
    } else {
      epx_index = true;
      index.clear();
      print('Invalid index');
      setState(() {
        
      });      
    }
  } catch (e) {
    epx_index = true;
    index.clear();
    print('Error deleting expense: $e');
    setState(() {
        
      });
  }
}
else {setState(() {
        epx_index = true;
        index.clear();
      });}
}

Future addIncome() async{

    
  bool numFlag = false;
  bool stringFlag = true;

  try {
  double integerValue = double.parse(income_value.text);
  // The value is a double, and integerValue contains the parsed double.
  print('Parsed double value: $integerValue');
    numFlag = true;
    exp_value = false;
  
} catch (e) {
  // An exception occurred, indicating that the value is not a double.
  print('Error: $e');
    exp_value = true;
    numFlag = false;
}

try {
  int integerValue = int.parse(income_name.text);
  // The value is an integer, and integerValue contains the parsed integer.
  print('Parsed integer value: $integerValue');
    stringFlag = false;
    exp_name = true;
} catch (e) {
  // An exception occurred, indicating that the value is not an integer.
  print('Error: $e');
    exp_name = false;
    stringFlag = true;
}
    
    if (income_name.text.isNotEmpty && income_value.text.isNotEmpty && numFlag == true && stringFlag == true){
    var value = double.parse(income_value.text);
    String roundedValue = value.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    double parsedValue = NumberFormat.decimalPattern("en_US").parse(roundedValue).toDouble();
    try {
  
      await 
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'Income': FieldValue.arrayUnion([income_name.text.toString()]),
      
      });
      
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'Income(Value)': FieldValue.arrayUnion([parsedValue]),
      });

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    List<dynamic> currentArray = userSnapshot['Income'];
    int length = currentArray.length;

     await
     FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
          'Income(index)': FieldValue.arrayUnion([length]),
      });


      print('Expense added successfully');
      setState(() {
      inc_name = false;
      inc_value = false;
      });

      income_name.clear();
      income_value.clear();
      
    } catch (e) {
      print('Error adding expense: $e');
      setState(() {
        
      inc_value = true;
      inc_name = true;
      income_name.clear();
      income_value.clear();
      
      });
    }
  } else {
    print('Incorrect input');
    setState(() {
      income_name.clear();
      income_value.clear();
      
      inc_value = true;
      inc_name = true;
      });
  }
}

Future<void> deleteIncomeAtIndex() async {

  bool test = false;
  try {
  double integerValue = double.parse(index2.text);
  // The value is a double, and integerValue contains the parsed double.
  print('Parsed double value: $integerValue');
    test = true; // Use a different variable name
    inc_index = false; // Reset the flag for successful parsing
} catch (e) {
  // An exception occurred, indicating that the value is not a double.
  print('Error: $e');
  setState(() {
    inc_index = true; // Set the flag for unsuccessful parsing
    test = false; // Reset the flag for unsuccessful parsing
  });
}

  if (test == true) {
  var value = int.parse(index2.text)-1;
  try {
    // Retrieve the current array from Firebase
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    List<dynamic> currentArray = userSnapshot['Income'];
    List<dynamic> number = userSnapshot['Income(Value)'];
    List<dynamic> indexList = userSnapshot['Income(index)'];
    
    int length = currentArray.length;
    

    // Check if the index is valid
    if (value >= 0 && value < currentArray.length) {
      // Remove the element at the specified index
      currentArray.removeAt(value);
      number.removeAt(value);
      indexList.removeAt(length-1);

      // Update the array in Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'Income': currentArray});
        
        FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'Income(Value)': number});
        
        FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'Income(index)': indexList});

      print('Expense at index $index deleted successfully');

      index2.clear();

      setState(() {
        
      });
    }else {
      inc_index = true;
      index2.clear();
      print('Invalid index');
      setState(() {
        
      });      
    }
  } catch (e) {
    inc_index = true;
    index2.clear();
    print('Error deleting expense: $e');
    setState(() {
        
      });
  }
}
else {setState(() {
        inc_index = true;
        index2.clear();
      });}
}

  Future<String> gatherdata() async{
    try{
    var doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(widget.uid)
    .get();
    return doc['goal(current)'].toString();
    
  }
  catch (e) {
    print("error: $e");
    return '';
  }
  }

  Future <List<dynamic>> gatherList() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['Expense'];

    }
    catch (e){
      print('error $e');
      return [];
    }
  }

  Future <List<dynamic>> Gatherexpense() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['expense(value)'];

    }
    catch (e){
      print('error $e');
      return [];
    }
  }

  Future <List<dynamic>> GatherIncome() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['Income'];
    }
    catch (e){
      print('error $e');
      return [];
    }
  }
  
  Future <List<dynamic>> GatherIncValue() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['Income(Value)'];

    }
    catch (e){
      print('error $e');
      return [];
    }
  }

  Future <List<dynamic>> Gatherindex() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['expense(index)'];

    }
    catch (e){
      print('error $e');
      return [];
    }
  }

  Future <List<dynamic>> Gatherindex2() async {
    try {
      var list = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
      return list['Income(index)'];

    }
    catch (e){
      print('error $e');
      return [];
    }
  }

void signOutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
    print("User signed out");
  } catch (e) {
    print("Error signing out: $e");
  }
}




  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait ([
        gatherdata(), 
        gatherList(),
        Gatherexpense(),
        GatherIncome(),
        GatherIncValue(),
        Gatherindex(),
        Gatherindex2(),
      // add more functions where where necissary
      ]),
      builder: (context, snapshot) {
       if (snapshot.hasError) {
          return Text('Error lol: ${snapshot.error}');
        } else {
          String goal = snapshot.data?[0] != null ? (snapshot.data?[0] as String).toString(): ''; // Assign the value if available
          List<String> itemList = snapshot.data?[1] != null? (snapshot.data?[1] as List<dynamic>).cast<String>(): [];
          List<double> itemno = snapshot.data?[2] != null? (snapshot.data?[2] as List<dynamic>).cast<double>(): [];
          List<String> iteminc = snapshot.data?[3] != null? (snapshot.data?[3] as List<dynamic>).cast<String>(): [];
          List<double> itemincvalue = snapshot.data?[4] != null? (snapshot.data?[4] as List<dynamic>).cast<double>(): [];
          List<int> itemIndex = snapshot.data?[5] != null? (snapshot.data?[5] as List<dynamic>).cast<int>(): [];
          List<int> itemIndex2 = snapshot.data?[6] != null? (snapshot.data?[6] as List<dynamic>).cast<int>(): [];
          // use [0], [1] and so on to determne which function u are taking the data from
   
    print ("this is: $goal");
    print ("this is: $itemList");
    print (iteminc);
    print(itemno);

    
    double expense_total = 0;

    for (int i = 0; i < itemno.length; i++) {
      expense_total = expense_total+ itemno[i];
    } 

    double income_total = 0;

    for (int i = 0; i < iteminc.length; i++) {
      income_total = income_total+ itemincvalue[i];
    }

    double total = income_total - expense_total;
    
    print (goal);
double valueIndicator = 0.0;

if (goal.isNotEmpty) {
  // Check if goal is a valid numeric string
  bool isValidNumericString = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(goal);

  if (isValidNumericString) {
    try {
      valueIndicator = total / double.parse(goal);
    } catch (e) {
      print("Error parsing goal: $e");
    }
  } else {
    print("Invalid numeric string for goal: $goal");
  }
}
    total = total.isNaN ? 0.0 : double.parse(total.toStringAsFixed(2));
    String percent = (valueIndicator*100).toStringAsFixed(0);


    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber[800],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: 'Income',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.remove_circle),
            icon: Icon(Icons.remove_circle_outline),
            label: 'Expense',
          ),
        ],
      ),
      body: <Widget>[
        
        
        //index 1
        Container(
          color:  Colors.black,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [

           Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
              Align(
              alignment: const Alignment(-0.0, -0.8),
              child:Text(
                  '£$total / £$goal',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 34,
                    fontFamily: 'helvetica',
                    color: Color(0xffffffff),
                  ),
                ),
        ),

              SizedBox(height:MediaQuery.of(context).size.height * 0.05),
             
               // ignore: sized_box_for_whitespace
               
                Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      value: valueIndicator,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 43, 164, 47)),
                      strokeWidth: 10,
                    ),
                  ),
                  Positioned(
                    child: Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 28,
                        fontFamily: 'Helvetica',
                      ),
                    ),
                  ),
                ],
              ),

                SizedBox(height:MediaQuery.of(context).size.height * 0.1),

                 const Text(
                  'Alter goal:',
                  style:  TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 34,
                    fontFamily: 'Helvetica',
                  ),
                
              ),

                  SizedBox(height:MediaQuery.of(context).size.height * 0.05 ),
                            
                  SizedBox(
                  height:MediaQuery.of(context).size.height * 0.05,
                  width:MediaQuery.of(context).size.width * 0.2,
                  child: TextField(
                    controller: goal_alter,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Input new goal',
                    fillColor: Colors.white,
                    errorText: goal_value ? 'Enter a value up to 2 D.P' : null,                   
                    ),
                  ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  
                  ElevatedButton(
                    onPressed: change_goal,     
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0), // Adjust the padding to make the button bigger
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                  ),
                ),
            
                    child: const Text('Submit'),
            ),

            SizedBox(height:MediaQuery.of(context).size.height * 0.2),

              ]
           ),      
                       
          
          const Align(
              alignment: Alignment(-0.5, -0.3),
              child: FittedBox(
              child: Text(
                  'Income',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.clip,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                    color: Colors.green,
                  ),
                ),
          ),
          ),
          
          Align(
            alignment: const Alignment(-0.5, 0.4),
            child: SizedBox(  
              width: 200,
              height: 300, 
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: iteminc.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                  title: Text(
                    '${iteminc[index]}: £${itemincvalue[index]}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'helvetica',
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  )
                  );
                }
              )
            ),
          ),
            
          const Align(
              alignment: Alignment(0.5, -0.3),
              child: Text(
                  'Expense',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.clip,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                    color: Colors.red,
                  ),
                ),
          ),

           Align(
            alignment: const Alignment(0.6, 0.4),
            child: SizedBox(  
              width: 200,
              height: 300, 
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int value) {
                  return ListTile(
                  title: Text(
                    '${itemList[value]}: £${itemno[value]}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'helvetica',
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  )
                  );
                }
              )
            ),
          ),
          Positioned(
        left: 16.0,
        top: 16.0,
        child: ElevatedButton(
          onPressed: () {
            signOutUser();
          },
          child: Text('Logout'),
          style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16.0),
          ),
        ),
      ),
            ]
          )
        ),
        
            
        
        
        //index 2
        Container(

          color: const Color.fromARGB(255, 0, 0, 0),
          alignment: Alignment.center,
          child:  Stack(
            alignment: Alignment.topLeft,
            children: [
              
             Align(
              alignment: const Alignment(-0.6, -0.5),
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              // ignore: sized_box_for_whitespace
              child: Container(

                width: MediaQuery.of(context).size.width * 0.35,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height:MediaQuery.of(context).size.height * 0.05),

                  const Text(
                  'Add Income below:',
                  style:  TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 34,
                    fontFamily: 'Helvetica',
                  ),

                
              ),

                  SizedBox(height:MediaQuery.of(context).size.height * 0.05 ),
            
                  TextField(
                    controller: income_name,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder( 
                    borderSide: BorderSide(
                      color: Colors.white,
                      )
                      ),
                    filled: true,
                    labelText: 'Income name',
                    errorText: inc_name ? 'enter a name using only letters' : null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  TextField(
                    controller: income_value,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Income value',
                    errorText: inc_value ? 'enter a number up to two D.P' : null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  
                  ElevatedButton(
                    onPressed: addIncome,     
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0), // Adjust the padding to make the button bigger
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                  ),
                ),
            
                    child: const Text('Submit'),
            ),
                  
                  SizedBox(height:MediaQuery.of(context).size.height * 0.075),

                  const Text(
                  'Delete an income below: ',
                  style:  TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                  ),

                
              ),

                  SizedBox(height:MediaQuery.of(context).size.height * 0.025 ),
            
                  TextField(
                    controller: index2,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Enter the Index',
                    errorText: inc_index ? 'Enter an index that appeares in the table' : null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  ElevatedButton(
                    onPressed: deleteIncomeAtIndex, 

                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0), // Adjust the padding to make the button bigger
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                  ),
                ),                

                    child: const Text('Submit'),
            ),




                ],
          ),
              ),
        ),
             ),
       
        const Align(
              alignment: Alignment(0.7, -0.85),
              child: FittedBox(
              child: Text(
                  'Income (scroll):',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                    color: Colors.green,
                  ),
                ),
          ),
          ),
        
        Container(
          alignment: Alignment.centerRight,
          
          child: Align(
            alignment: const Alignment(0.8, -0.5),
            child: SizedBox(  
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.375,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(right: 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black)
              ),
              
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: iteminc.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                  title: Text(
                    '${itemIndex2[index]} - ${iteminc[index]}: £${itemincvalue[index]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(   
                      fontFamily: 'helvetica',                   
                      fontSize: 20,
                      
                    ),
                  )
                  );
                }
              )
              ),
            ),
          ),
        ),
            
           Align(
              alignment: const Alignment(0.7, 0.5),
              child: FittedBox(
              child: Text(
                  'Income (total): £$income_total',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style:  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 32,
                    color: Colors.green,
                  ),
                ),
          ),
          ),
          Positioned(
        left: 16.0,
        top: 16.0,
        child: ElevatedButton(
          onPressed: () {
            signOutUser();
          },
          child: Text('Logout'),
          style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16.0),
          ),
        ),
      ),
        ]
          )
        ),
        
        
        //index 3
        Container(

          color: Colors.black,
          alignment: Alignment.center,
          child:  Stack(
            alignment: Alignment.topLeft,
            children: [
              
             Align(
              alignment: const Alignment(-0.6, -0.5),
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              // ignore: sized_box_for_whitespace
              child: Container(

                width: MediaQuery.of(context).size.width * 0.35,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height:MediaQuery.of(context).size.height * 0.05),

                  const Text(
                  'Add expense below:',
                  style:  TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                  ),

                
              ),

                  SizedBox(height:MediaQuery.of(context).size.height * 0.05 ),
            
                  TextField(
                    controller: expense_name,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Expense name',
                    errorText: exp_name ? 'enter a name using only letters' : null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  TextField(
                    controller: expense_value,
                    decoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Expense value',
                    errorText: exp_value ? 'enter a number up to two D.P' : null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  ElevatedButton(
                    onPressed: addExpense,                 
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0), // Adjust the padding to make the button bigger
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                  ),
                ),
                    child: const Text('Submit'),
            ),
                  
                  SizedBox(height:MediaQuery.of(context).size.height * 0.075),

                  const Text(
                  'Delete an expense below: ',
                  style:  TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'helvetica',
                    fontSize: 34,
                  ),

                
              ),

                  SizedBox(height:MediaQuery.of(context).size.height * 0.025 ),
            
                  TextField(
                    controller: index,
                    decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'Enter the Index',
                    errorText: epx_index ? 'Enter an index that appears in the table': null,
                    fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.025),
                  ElevatedButton(
                    onPressed: deleteExpenseAtIndex,                 
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0), // Adjust the padding to make the button bigger
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
                  ),
                ),
                    child: const Text('Submit'),
            ),




                ],
          ),
              ),
        ),
             ),
       
        const Align(
              alignment: Alignment(0.7, -0.85),
              child: FittedBox(
              child: Text(
                  'Expenses (scroll):',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 34,
                    color: Colors.red,
                  ),
                ),
          ),
          ),
        
        Container(
          alignment: Alignment.centerRight,
          
          child: Align(
            alignment: const Alignment(0.8, -0.5),
            child: SizedBox(  
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.375,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(right: 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black)
              ),
              
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: itemList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                  title: Text(
                    '${itemIndex[index]} - ${itemList[index]}: £${itemno[index]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(     
                      fontFamily: 'helvetica',                 
                      fontSize: 20,
                    ),
                  )
                  );
                }
              )
              ),
            ),
          ),
        ),
            
           Align(
              alignment: const Alignment(0.7, 0.5),
              child: FittedBox(
              child: Text(
                  'Expenses (total): £$expense_total',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style:  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontSize: 32,
                    color: Colors.red,
                  ),
                ),
          ),
          ),
          Positioned(
        left: 16.0,
        top: 16.0,
        child: ElevatedButton(
          onPressed: () {
            signOutUser();
          },
          child: Text('Logout'),
          style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16.0),
          ),
        ),
      ),
        ]
          )
        ),
      ][currentPageIndex],
    );
  }
    },
  );
}
}

  