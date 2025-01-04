import 'package:flutter/material.dart';
import 'api_service.dart';
import 'tema.dart'; 
import 'package:provider/provider.dart';
import 'current_user.dart';

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
  String currentUser = UserManager().currentUser;


  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _checkSuperUserStatus();
    // _checkSuperUserStatus();
  }

  void _checkSuperUserStatus() async {
    String username = currentUser;  // Имя пользователя, которое вы хотите проверить
  bool isSuperuser = await Api.checkIfSuperUser(username);
  
    setState(() {
      _isSuperUser = isSuperuser;
    });
    if (isSuperuser) {
    print('$username is a superuser.');
  } else {
    print('$username is not a superuser.');
  }
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

  void _showEditUserDialog(dynamic user) {
  // Предзаполнение полей данными выбранного пользователя
  usernameController.text = user['username'];
  emailController.text = user['email'];
  passwordController.clear(); // Поле для нового пароля
  oldPasswordController.clear(); // Поле для ввода старого пароля

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Old Password (if changing password)'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password (optional)'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final username = usernameController.text;
              final email = emailController.text;
              final oldPassword = oldPasswordController.text;
              final newPassword = passwordController.text;

              if (username.isEmpty || email.isEmpty) {
                _showSnackbar('Username and email cannot be empty.');
                return;
              }

              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
                _showSnackbar('Please enter a valid email address.');
                return;
              }

              // Проверяем старый пароль через API, если пользователь хочет сменить пароль
              if (newPassword.isNotEmpty) {
                try {
                  final response = await Api.checkPassword(
                    username: user['username'],
                    oldPassword: oldPassword,
                  );

                  if (!response['is_valid']) {
                    _showSnackbar('Old password is incorrect.');
                    return;
                  }
                } catch (e) {
                  _showSnackbar('Error verifying old password: $e');
                  return;
                }
              }

              try {
                // Обновляем данные пользователя
                await Api.updateUser(
                  user['id'],
                  username: username,
                  email: email,
                  newPassword: newPassword.isNotEmpty ? newPassword : null,
                );

                _fetchUsers(); // Обновляем список пользователей
                _showSnackbar('User updated successfully!');
                Navigator.of(context).pop();
              } catch (e) {
                _showSnackbar('Error: $e');
              }
            },
            child: Text('Save'),
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
    if (selectedUser != null && (_isSuperUser || selectedUser['username'] == currentUser) )
      FloatingActionButton(
        heroTag: 'editButton',
        backgroundColor: Colors.blue,
        onPressed: () {
          _showEditUserDialog(selectedUser);
        },
        child: Icon(Icons.edit),
      ),
    SizedBox(height: 10),
    if (selectedUser != null && _isSuperUser)
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
