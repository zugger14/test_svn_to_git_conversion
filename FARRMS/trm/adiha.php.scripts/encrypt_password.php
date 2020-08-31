<?php
$user_pass = crypt(md5($_POST['user_pwd']), strtolower($_POST['user_login_id']));
echo json_encode($user_pass);
?>