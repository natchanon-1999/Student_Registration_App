import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();

  File? imageFile;          // 📱 สำหรับ mobile
  Uint8List? imageBytes;    // 🌐 สำหรับ web
  String? fileName;

  final picker = ImagePicker();

  // 📷 เลือกรูป
  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        imageBytes = await picked.readAsBytes();
        fileName = picked.name;
      } else {
        imageFile = File(picked.path);
      }

      setState(() {});
    }
  }

  // 🚀 ส่งข้อมูล + รูป
  Future submit() async {
    if (name.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        (imageFile == null && imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรอกข้อมูลให้ครบ + เลือกรูป")),
      );
      return;
    }

    var uri = Uri.parse(
      "http://192.168.1.3:8080/Student_Registration_App/student_api/insert_user.php",
    );

    var request = http.MultipartRequest("POST", uri);

    request.fields['name'] = name.text;
    request.fields['email'] = email.text;
    request.fields['phone'] = phone.text;

    // 🔥 แยก Web / Mobile
    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes!,
          filename: fileName ?? "upload.jpg",
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("บันทึกสำเร็จ")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phone,
              decoration: InputDecoration(labelText: "Phone"),
            ),

            SizedBox(height: 15),

            // 🖼 preview รูป (แก้แล้ว)
            if (kIsWeb && imageBytes != null)
              Image.memory(imageBytes!, height: 120)
            else if (!kIsWeb && imageFile != null)
              Image.file(imageFile!, height: 120)
            else
              Text("ยังไม่ได้เลือกรูป"),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: Text("เลือกภาพ"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: submit,
              child: Text("บันทึก"),
            ),
          ],
        ),
      ),
    );
  }
}