<?php
ob_start();
require_once '../../../adiha.php.scripts/components/include.file.v3.php';

unset($_SESSION['client_date_format']); 
$_SESSION['client_date_format'] = "";

ob_end_clean();

$data['status'] = true;
echo json_encode($data);
?>

