import 'package:flutter/material.dart';
import 'api_servic.dart';
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
  // final Api apiService = Api();
  dynamic selectedUser; // To keep track of the selected user

  @override
  void initState() {
    super.initState();
    _fetchUsers();
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

  void _showEditDialog( userId, String username) {
    usernameController.text = username;
    _showAddUserDialog();  // Open the same dialog for editing
  }

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

  return Scaffold(
    backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white, // Фон для Scaffold
    appBar: AppBar(
      title: Text('Users'),
      backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : const Color.fromARGB(255, 255, 255, 255),  // Фон AppBar
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),  // Цвет иконок в AppBar
    ),
    body: GestureDetector(
      onTap: () {
        setState(() {
          selectedUser = null; // Reset selection if clicked outside
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
                      // Toggle selection
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
                      borderRadius: BorderRadius.circular(20), // Added rounded corners
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
                          color: isDarkMode ? Colors.white : Colors.black, // Цвет текста
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
        // "Add" button always visible
        FloatingActionButton(
          heroTag: 'addButton',
          backgroundColor: Color.fromARGB(255, 141, 118, 244),
          onPressed: _showAddUserDialog,
          child: Icon(Icons.add),
        ),
        SizedBox(height: 10),
        // "Edit" button visible if a user is selected
        if (selectedUser != null)
          FloatingActionButton(
            heroTag: 'editButton',
            backgroundColor: Color.fromARGB(255, 153, 150, 236),
            onPressed: () {
              if (selectedUser != null) {
                _showEditDialog(selectedUser['id'], selectedUser['username']);
              }
            },
            child: Icon(Icons.edit),
          ),
        SizedBox(height: 10),
        // "Delete" button visible if a user is selected
        if (selectedUser != null)
          FloatingActionButton(
            heroTag: 'deleteButton',
            backgroundColor: Colors.red,
            onPressed: () {
              if (selectedUser != null) {
                _deleteUser(selectedUser['id']);
                setState(() {
                  selectedUser = null; // Reset selected user
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