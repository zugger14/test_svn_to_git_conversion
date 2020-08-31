<?php
/**
 * Included all the library js files.
 * @copyright Pioneer Solutions
 */

$theme = $default_theme;
$theme = str_replace("-", "_", str_replace("theme-", "", $theme));
$dhtmlx_theme = 'dhtmlx_' . $theme;
$patch_css = $app_php_script_loc . "components/lib/adiha_dhtmlx/themes/" . $dhtmlx_theme . "/patch.css";
$css_file = $app_php_script_loc . "components/lib/adiha_dhtmlx/themes/" . $dhtmlx_theme . "/dhtmlx.css";
  $js_file = $app_php_script_loc . "components/lib/adiha_dhtmlx/themes/common/js/awesome.js";
$image_path = $app_php_script_loc . "components/lib/adiha_dhtmlx/themes/" . $dhtmlx_theme . "/imgs/";

?>
<link rel="stylesheet" type="text/css" href="<?php echo $css_file; ?>" />
<link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>../main.menu/font-awesome-4.2.0/css/font-awesome.min.css">
<!-- <script type="text/javascript" src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js'></script> -->
<!--<script type="text/javascript" src="<?php echo $js_file; ?>"></script> -->
<link rel="stylesheet" type="text/css" href="<?php echo $patch_css; ?>" />
<link href="<?php echo $app_php_script_loc; ?>../css/timepicker.css" rel="stylesheet" />

<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/phone-format.min.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/dhtmlx.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/adiha.dhtmlx.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/adiha_grid_3.0.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/underscore.min.js"></script>

<?php if (isset($check_cloud_mode_login) == 1) return; ?>

<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/patch.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery.number.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-dateFormat.min.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/bootstrap-timepicker.min.js"></script>
<link rel="stylesheet" type="text/css" href="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/adiha_dhtmlx.css" />

<!-- downloaded files 
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/cdn_jsdelivr_net/moment.min.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/cdn_jsdelivr_net/daterangepicker.js"></script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/cdn_jsdelivr_net/daterangepicker.css"></script> -->

<script type="text/javascript">
    js_php_path= '<?php echo $app_php_script_loc; ?>';
    show_meridian = Boolean(<?php echo $TIME_FORMAT_24HR ?? 0; ?>) ? false : true;
    var debugMode = <?php echo $DEBUG_MODE; ?>;
    var js_php_base_path = '<?php echo $app_adiha_loc; ?>';
    var js_image_path = '<?php echo $image_path; ?>';
    app_form_path = '<?php echo $app_form_path; ?>';
    var product_id = '<?php echo $farrms_product_id; ?>';
    var __global_number_format__ = '<?php echo $GLOBAL_NUMBER_FORMAT; ?>';
    var __global_price_format__ = '<?php echo $GLOBAL_PRICE_FORMAT; ?>';
    var __global_volume_format__ = '<?php echo $GLOBAL_VOLUME_FORMAT; ?>';
    var __global_amount_format__ = '<?php echo $GLOBAL_AMOUNT_FORMAT; ?>';
    var __country__ = '<?php echo $COUNTRY;?>';
    var __phone_format__ = '<?php echo $PHONE_FORMAT; ?>';
	var user_mode = '<?php echo $is_win_auth_login; ?>';
	var js_theme = '<?php echo $theme; ?>';
	var js_dhtmlx_theme = '<?php echo $dhtmlx_theme; ?>';
    var global_decimal_separator = '<?php echo $global_decimal_separator; ?>';
    var global_group_separator = '<?php echo $global_group_separator; ?>';
    var global_number_rounding = '<?php echo $global_number_rounding; ?>';
    var global_price_rounding = '<?php echo $global_price_rounding; ?>';
    var global_amount_rounding = '<?php echo $global_amount_rounding; ?>';
    var global_volume_rounding = '<?php echo $global_volume_rounding; ?>';
	    
    if (debugMode == 0) {
        window.onerror = function myErrorHandler(errorMsg, url, lineNumber) {
            return true;
        }
        
        console.log = function() {};
        document.addEventListener("contextmenu", function(e){
            e.preventDefault();
        }, false);
    }
    
    function getAppUserName() {
        html_str = '__user_name__=' + js_user_name;
        return html_str;
    }
</script>