<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
include '../../../adiha.php.scripts/components/include.file.v3.php';

$deal_ref_ids = (isset($_POST["deal_ref_ids"]) && $_POST["deal_ref_ids"] != '') ? get_sanitized_value($_POST["deal_ref_ids"]) : 'NULL';
$detail_ids = (isset($_POST["detail_ids"]) && $_POST["detail_ids"] != '') ? get_sanitized_value($_POST["detail_ids"]) : 'NULL';
$term_start = (isset($_REQUEST["term_start"]) && $_REQUEST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : 'NULL';
$term_end = (isset($_REQUEST["term_end"]) && $_REQUEST["term_end"] != '') ? get_sanitized_value($_POST["term_end"]) : 'NULL';
$shaped_yes_no = (isset($_POST["profile_type"]) && $_POST["profile_type"] != '') ? get_sanitized_value($_POST["profile_type"]) : 'NULL';
$header_detail = (isset($_REQUEST["header_detail"]) && $_REQUEST["header_detail"] != '') ? get_sanitized_value($_REQUEST["header_detail"]) : 'h';

if ($shaped_yes_no == 17302) { // for shaped deals
    include_once("shaped.deals.php");
} else {
    include_once('update.demand.volume.php');
}
?>

</html>