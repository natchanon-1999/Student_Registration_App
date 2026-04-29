<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");
include 'db.php'; 

$result = $conn->query("SELECT * FROM users");
$data = [];

// ตัวอย่างที่ถูกต้องใน get_users.php
while ($row = $result->fetch_assoc()) {
    // ไม่ต้องเติม http://... ในนี้ ให้ส่งแค่ "123.jpg"
    $data[] = $row;
}
echo json_encode($data);
?>