import 'package:flutter/material.dart';
import 'api_service.dart';
import 'tema.dart'; 
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> users = [];
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();  // Для старого пароля
  dynamic selectedUser; 
  bool _isSuperUser = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _checkSuperUserStatus();
  }

  void _checkSuperUserStatus() async {
    String username = 'admin';  // Имя пользователя, которое вы хотите проверить
  bool isSuperuser = await Api.checkIfSuperUser(username);
  
    setState(() {
      _isSuperUser = isSuperuser;
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await Api.fetchUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _addUser(String username, String email, String password) async {
    try {
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        _showSnackbar('All fields must be filled.');
        return;
      }

      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
        _showSnackbar('Please enter a valid email address.');
        return;
      }

      await Api.addUser(username, email, password);
      _fetchUsers();
      _showSnackbar('User added successfully!');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await Api.deleteUser(userId);
      _fetchUsers();
      _showSnackbar('User deleted successfully!');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(hintText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _addUser(
                  usernameController.text,
                  emailController.text,
                  passwordController.text,
                );
                usernameController.clear();
                emailController.clear();
                passwordController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white, 
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : const Color.fromARGB(255, 255, 255, 255),  
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            selectedUser = null; 
          });
        },
        child: users.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  bool isSelected = selectedUser == user;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedUser == user) {
                          selectedUser = null;
                        } else {
                          selectedUser = user;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color.fromARGB(255, 136, 138, 246)
                            : (isDarkMode
                                ? Color.fromARGB(255, 120, 120, 120).withOpacity(0.3)
                                : Colors.grey.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 103, 13, 237).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          user['username'] ?? 'Username not provided',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, 
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSuperUser) 
          FloatingActionButton(
            heroTag: 'addButton',
            backgroundColor: Color.fromARGB(255, 141, 118, 244),
            onPressed: _showAddUserDialog,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          if (selectedUser != null)
            FloatingActionButton(
              heroTag: 'deleteButton',
              backgroundColor: Colors.red,
              onPressed: () {
                if (selectedUser != null) {
                  _deleteUser(selectedUser['id']);
                  setState(() {
                    selectedUser = null; 
                  });
                }
              },
              child: Icon(Icons.delete),
            ),
        ],
      ),
    );
  }
}
