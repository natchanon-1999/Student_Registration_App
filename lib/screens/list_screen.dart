import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'register_screen.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final String baseUrl =
      "http://192.168.1.3:8080/Student_Registration_App/student_api";

  List<User> allUsers = [];
  List<User> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_users.php"));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          allUsers = data.map<User>((e) => User.fromJson(e)).toList();
          filteredUsers = List.from(
            allUsers,
          ); // สร้าง List ใหม่ป้องกันการอ้างอิงตำแหน่งเดิม
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(allUsers);
      } else {
        filteredUsers = allUsers
            .where(
              (user) =>
                  (user.name ?? "").toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (user.email ?? "").toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users List"),
        // ✅ ช่องค้นหาด้านบน (ตามภาพตัวอย่างที่คุณต้องการ)
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (value) => _filterUsers(value),
              decoration: InputDecoration(
                hintText: "Search user...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterScreen()),
          ).then((_) => fetchUsers());
        },
        child: Icon(Icons.add),
      ),
      // ✅ ใช้เงื่อนไขเช็คข้อมูลก่อนแสดงผลเพื่อป้องกัน Error สีแดง
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredUsers.isEmpty
          ? Center(child: Text("ไม่พบข้อมูล"))
          : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, i) {
                final u = filteredUsers[i];
                String imageName = u.image ?? "";
                final imageUrl = imageName.isNotEmpty
                    ? "$baseUrl/images/$imageName"
                    : "";

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 1,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, size: 50),
                            )
                          : Icon(Icons.person, size: 50),
                    ),
                    title: Text(u.name ?? "No Name"),
                    subtitle: Text("${u.email ?? ""}\n${u.phone ?? ""}"),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
