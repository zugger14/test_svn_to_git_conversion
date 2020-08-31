<?php
include_once 'ssrs_charts/chart.factory.php';
include_once "ssrs_gauge/gauge.factory.php";
?>

<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/jquery-ui/jquery-ui.min.js"></script> 
<link rel="stylesheet" type="text/css" href="<?php echo $app_php_script_loc; ?>components/lib/jquery-ui/jquery-ui.css">
<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/pivot/dist/jquery.csv-0.71.min.js"></script>
<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/pivot/dist/pivot.js"></script>         
<link rel="stylesheet" type="text/css" href="<?php echo $app_php_script_loc; ?>components/lib/pivot/dist/pivot.css">
<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/lib/pivot/dist/gchart_renderers.js"></script>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>