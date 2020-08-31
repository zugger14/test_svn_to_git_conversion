<?php
if(empty($_POST['data'])) {
	exit;
}

$filename = "data.ics";

header("Cache-Control: ");
header("Content-type: text/plain");
header('Content-Disposition: attachment; filename="'.$filename.'"');

echo get_sanitized_value($_POST['data']);

?>