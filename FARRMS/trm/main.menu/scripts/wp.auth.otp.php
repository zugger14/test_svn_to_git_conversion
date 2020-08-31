<?php
    require('../../adiha.php.scripts/components/include.file.v3.php');
    include('../../adiha.php.scripts/components/security.ini.php');

    $home_url = isset($_POST['home_url']) ? $_POST['home_url'] : '';
    $app_dir = isset($_POST['app_dir']) ? $_POST['app_dir'] : '';
    $otp_code = isset($_POST['otp']) ? $_POST['otp'] : '';
    $secret_key = isset($_POST['secret_key']) ? $_POST['secret_key'] : '';
    $url = $home_url . '/' . $app_dir . '/api/index.php?route=otp/verify';

    function curl_func($url, $headers, $fields, $is_post) {
        // Open connection
        $ch = curl_init();

        // Set the URL, number of POST vars, POST data
        curl_setopt( $ch, CURLOPT_URL, $url);
        if ($is_post)
            curl_setopt( $ch, CURLOPT_POST, true);
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true);
        if ($is_post)
            curl_setopt( $ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
         if ($is_post)
            curl_setopt($ch, CURLOPT_POST, true);
         curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // Execute post
        $result = curl_exec($ch);

        // Close connection
        curl_close($ch);
        return json_decode($result);

    }

    $headers = array(
                'Content-Type: application/json'
            );
    $fields_len = '{"secret":"' . $secret_key . '","otp":"' .  $otp_code . '"}';
    $results = curl_func($url, $headers, $fields_len, true);
    $otp_status = $results->otp_status;
    
    if ($otp_status) {
        $_SESSION['otp_verified'] = "true";
    } else {
        $_SESSION['otp_verified'] = "false";
    }

    $return_data['status'] = $_SESSION['otp_verified'];
    ob_clean();
    echo json_encode($return_data);
?>