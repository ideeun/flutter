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
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white, // Белый фон для светлой темы
        title: Text(
          'Add New User',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(usernameController, 'Username'),
            _buildTextField(emailController, 'Email'),
            _buildTextField(passwordController, 'Password', obscureText: true),
          ],
        ),
        actions: <Widget>[
          _buildDialogButton('Add', () {
            _addUser(
              usernameController.text,
              emailController.text,
              passwordController.text,
            );
            usernameController.clear();
            emailController.clear();
            passwordController.clear();
            Navigator.of(context).pop();
          }),
          _buildDialogButton('Cancel', () {
            Navigator.of(context).pop();
          }),
        ],
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.5)
                : Color.fromARGB(7, 97, 112, 211),
          ),
        ),
        // Цвет границы, когда поле не в фокусе
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode ? const Color.fromARGB(255, 168, 167, 168).withOpacity(0.5) : Colors.grey.withOpacity(0.3), // фиолетовый или серый
          ),
        ),
        // Цвет границы, когда поле в фокусе
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode ? const Color.fromARGB(255, 105, 114, 232) : const Color.fromARGB(255, 78, 103, 185), // фиолетовый или синий
          ),
        ),
      ),
    ),
  );
}


Widget _buildDialogButton(String label, Function() onPressed) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextButton(
    onPressed: onPressed,
    child: Text(
      label,
      style: TextStyle(
        color: isDarkMode ? const Color.fromARGB(255, 98, 107, 240) : Color.fromARGB(255, 97, 123, 254), // Сиреневый для светлой темы
      ),
    ),
  );
}


  void _showEditUserDialog(dynamic user) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Предзаполнение полей данными выбранного пользователя
  usernameController.text = user['username'];
  emailController.text = user['email'];
  passwordController.clear(); // Поле для нового пароля
  oldPasswordController.clear(); // Поле для ввода старого пароля

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
      backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white,
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(usernameController, 'Username'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(oldPasswordController, 'Old Password (if changing password)', obscureText: true),
              _buildTextField(passwordController, 'New Password (optional)', obscureText: true),
            ],
          ),
        ),
        actions: <Widget>[
          _buildDialogButton('Save', () async {
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
          }),
          _buildDialogButton('Cancel', () {
            Navigator.of(context).pop();
          }),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
    theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
  home: Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Color.fromARGB(255, 4, 13, 36), // Темный верх
                    // Color.fromARGB(255, 46, 58, 109),
                    Color.fromARGB(255, 54, 68, 103), // Темный низ
 // Темный низ
                  ]
                : [
                    Color.fromARGB(255, 65, 91, 185),
                    Color.fromARGB(255, 72, 82, 128), // Светлый верх
 // Светлый верх
                    Color.fromARGB(255, 234, 246, 255), // Светлый низ
                  ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Text(
    'Users',
    style: TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,  // Цвет текста в зависимости от темы
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.chevron_left,
     color: isDarkMode ? Colors.white : Colors.black),
     iconSize: 30,  // Иконка кнопки назад
    onPressed: () {
      Navigator.pop(context);  // Возвращаем пользователя на предыдущий экран
    },
  ),
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
                            ? const Color.fromARGB(255, 116, 141, 245)
                            : (isDarkMode
                                ? Color.fromARGB(255, 120, 120, 120).withOpacity(0.15)
                                : const Color.fromARGB(255, 186, 184, 184).withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 148, 115, 255).withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 7),
                                ),
                              ]
                            : null,
                      ),
                      margin: EdgeInsets.all(7),
                      child: ListTile(
                        title: Text(
                          user['username'] ?? 'Username not provided',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
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
              backgroundColor: const Color.fromARGB(255, 116, 137, 243),
              onPressed: _showAddUserDialog,
              child: Icon(Icons.add),
            ),
          SizedBox(height: 10),
          if (selectedUser != null && (_isSuperUser || selectedUser['username'] == currentUser))
            FloatingActionButton(
              heroTag: 'editButton',
              backgroundColor: const Color.fromARGB(255, 151, 169, 228),
              onPressed: () {
                _showEditUserDialog(selectedUser);
              },
              child: Icon(Icons.edit),
            ),
          SizedBox(height: 10),
          if (selectedUser != null && _isSuperUser)
            FloatingActionButton(
              heroTag: 'deleteButton',
              backgroundColor: const Color.fromARGB(255, 226, 94, 84),
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
    ),
      ),
  ),
    );
  }
}