<?php
header("Access-Control-Allow-Origin: *");
include 'db.php';

$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];

// 🔥 สร้างชื่อไฟล์ใหม่
$imageName = time() . "_" . basename($_FILES['image']['name']);
$tmp = $_FILES['image']['tmp_name'];

// 🔥 path จริงในเครื่อง
$uploadPath = "images/" . $imageName;

// 🔥 เช็ค upload สำเร็จไหม
if (move_uploaded_file($tmp, $uploadPath)) {

    // ✅ เก็บแค่ชื่อไฟล์
    $conn->query("INSERT INTO users (name, email, phone, image)
    VALUES ('$name', '$email', '$phone', '$imageName')");

    echo json_encode(["status" => "success"]);

} else {
    echo json_encode(["status" => "error", "msg" => "upload failed"]);
}
?>