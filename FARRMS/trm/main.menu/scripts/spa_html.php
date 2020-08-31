<!-- created to redirect to orginal spa_html.php page -->
<?php
require "../../adiha.php.scripts/components/include.file.v3.php";
$full_url = $_SERVER['REQUEST_URI'];

$full_url_spilt = explode('?', $full_url);
$args = $full_url_spilt[1];
//echo $args;
//echo $app_php_script_loc;
header('location: ' .$app_php_script_loc.'dev/spa_html.php?'. $args); 
?>
<script type="text/javascript">

//$("#conash3D0").remove();

</script>