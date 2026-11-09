import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  //searching
  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  // String searchText = '';

  List<Map<String,dynamic>> contactsListAll=[];
  int? editingId;

  @override
  void initState() {
    super.initState();
    ReadContactsList(); // App open holei data load korbe
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    searchController.dispose();
    // aw karjokor kore dibe
  }

  // Database create
  Future<Database> openMyDatabase() async{
String DBPath= await getDatabasesPath();
String Path= join(DBPath,'contact.db');
return openDatabase(
  Path,
  version: 1,
  onCreate: (Database db,int version) async{
   await db.execute(
     '''
CREATE TABLE contactsList(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT ,
          phone INTEGER ,
          email TEXT,
          address TEXT
          )     '''
   );
  }
);
  }

  //add  AddContactsList
  Future<void> AddContactsList() async{
    Database DB= await openMyDatabase();
    await DB.insert('contactsList', {
      'name': nameController.text,
      'phone': int.parse(phoneController.text),
      'email' : emailController.text,
      'address' : addressController.text

    });
    clearBoxes();
    ReadContactsList();
  }

  //read
  Future<void> ReadContactsList() async{
    Database DB= await openMyDatabase();
    List<Map<String,dynamic>> ContactsListRows = await DB.query('contactsList');
    setState(() {
      contactsListAll=ContactsListRows;
    });
  }

  //delete
  Future<void> DeleteContacts(int id) async{
    Database DB= await openMyDatabase();
    await DB.delete('contactsList',
        where: 'id=?',
        whereArgs: [id]
    );
    clearBoxes();
    ReadContactsList();
  }

//update
  Future<void> UpdateContactslist() async{
    Database DB= await openMyDatabase();
    await DB.update('contactsList', {
      'name': nameController.text,
      'phone': phoneController.text,
      'email' : emailController.text,
      'address' : addressController.text
    },
        where: 'id=?',
        whereArgs: [editingId]
    );
    clearBoxes();
    ReadContactsList();
  }
  //search
  Future<void> SearchContacts(String name) async {
    Database DB = await openMyDatabase();

    List<Map<String, dynamic>> searchResults = await DB.query(
      'contactsList',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    setState(() {
      contactsListAll = searchResults;
    });
  }


  //তোমার এই Function-এর কাজ হলো: যে Student-এর ওপর ক্লিক করবে,
  // সেই Student-এর তথ্যগুলো Edit করার জন্য TextField-এ নিয়ে আসবে।

  void startEditingUpdate(Map<String, dynamic> singleContacts) {
    // aitar kaj holo jai contact ar upor tip dibo oita r sob ui te show korbe
    setState(() {
      editingId = singleContacts['id'];
      nameController.text = singleContacts['name'];
      phoneController.text = singleContacts['phone'].toString();
      emailController.text= singleContacts['email'];
      addressController.text= singleContacts['address'];
    });
  }



void ButtonControlerSave(){
 if(nameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty || addressController.text.isEmpty){
  return;
  }else if(editingId==null) {
   AddContactsList();
 } else UpdateContactslist();
}

  void clearBoxes() {
    setState(() {
      editingId = null;
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      addressController.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
    title: isSearching
    ? TextField(
    controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by name...',
        border: InputBorder.none,
      ),
      onChanged: (value) {
        SearchContacts(value);
      },
    )
        : Text(
    'Contact',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),

    actions: [
    IconButton(
    onPressed: () {
    setState(() {
    isSearching = !isSearching;

    if (!isSearching) {
      //jodi search na kore thaki
    searchController.clear();
    ReadContactsList();
    }
    });
    },
    icon: Icon(
    isSearching ? Icons.close : Icons.search,
    size: 25,
    ),
    ),
    ],

    backgroundColor: Colors.deepOrange,
    ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 10,
          children: [
            // SizedBox(height: 10,),

            TextField(
              controller:nameController ,
              decoration: InputDecoration(
                labelText: 'Enter your Name',
                hintText: 'Your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
            TextField(
              controller:phoneController ,
              decoration: InputDecoration(
                labelText: 'Enter your Number',
                hintText: 'Your Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
            TextField(
              controller:emailController ,
              decoration: InputDecoration(
                labelText: 'Enter your Email',
                hintText: 'Your Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
            TextField(
              controller:addressController ,
              decoration: InputDecoration(
                labelText: 'Enter your Address',
                hintText: 'Your Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                onPressed: ButtonControlerSave,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                child:  Text (editingId==null? 'ADD': 'Update'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: contactsListAll.length,
                  itemBuilder: (context,index){
                    // contactsListAll=[] aitaar bitor joto gulo map ba object ache ta single single kore index man niya oi index ar
                    // data SingleContact ar bitor rekhe listTile ar maddome dekhano hoy
                    // itemBuilder: (context,index) index =1
                    // contactsListAll[index]=1
                    // index 1 ar data show koro
                   Map<String,dynamic> SingleContact= contactsListAll[index];
                    return ListTile(
                      leading: Container(
                        // padding: EdgeInsets.all(10),
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(50),
                              color: Colors.blue

                          ),
                          child: Center(child: Text('${SingleContact['id']}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                      title: Text(' ${SingleContact['name']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(child: Text(' ${SingleContact['phone']}')),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(Icons.email, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(child: Text('${SingleContact['email']}')),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(' ${SingleContact['address']}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: (){
                        startEditingUpdate(SingleContact);
                      },
                      trailing: IconButton(onPressed: (){
                        DeleteContacts(SingleContact['id']);
                      }, icon: Icon(Icons.delete,color: Colors.red,)),
                    );
                  }),
            ),
          ],
        ),
      ),

    );
  }
}
