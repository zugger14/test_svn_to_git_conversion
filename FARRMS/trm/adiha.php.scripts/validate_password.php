<?php
    ob_start();
    require_once('components/include.file.v3.php');
    $crypt_pwd = crypt(md5($_POST['password']), $_POST['salt']);
    $sql_query = "EXEC spa_connection_string @flag = 'v', @password = '$crypt_pwd'";
    $query_result = readXMLURL2($sql_query);
    $is_valid = $query_result[0]['is_valid'];
    ob_clean();
    echo json_encode($is_valid);
?>