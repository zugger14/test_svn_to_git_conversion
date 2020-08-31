<?php
/**
* Setup profile screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>

    </head>
    <?php
        $form_namespace = 'setup_profile';
        $form_obj = new AdihaStandardForm($form_namespace, 10102800);
        $form_obj->define_grid("setup_profile");
        $form_obj->define_layout_width(350);
        echo $form_obj->init_form('Profile', 'Profile Details', '');
        echo $form_obj->close_form();
    ?>
	<script type="text/javascript">
setup_profile.post_callback = function(result) {

	var tab_id = setup_profile.tabbar.getActiveTab(); 
	setup_profile.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');   
	if (result[0].errorcode == "Success") {
		setup_profile.clear_delete_xml();
		var col_type = setup_profile.grid.getColType(0);
		if (col_type == "tree") {
			setup_profile.grid.saveOpenStates();
		}
		if (result[0].recommendation != null) {
			 var tab_id = setup_profile.tabbar.getActiveTab();
			 var previous_text = setup_profile.tabbar.tabs(tab_id).getText();
			 if (previous_text == get_locale_value("New")) {
				var tab_text = new Array();
				if (result[0].recommendation.indexOf(",") != -1) {
					tab_text = result[0].recommendation.split(",") 
				} else {
					tab_text.push(0, result[0].recommendation);
				}
				setup_profile.tabbar.tabs(tab_id).setText(tab_text[1]);
				setup_profile.refresh_grid("", setup_profile.open_tab);
				tab_text1 = tab_text[1];

			 } else {
				setup_profile.refresh_grid("", setup_profile.refresh_tab_properties);
				tab_text1 = result[0].recommendation;
			 }
			 
		}
		setup_profile.menu.setItemDisabled("delete");
		var data = {
			"action" : "spa_forecast_profile",
			"flag" : "post_insert",
			"profile_id" : tab_text1
		}
		adiha_post_data('return_array', data, '', '', '');  
	}
};
</script>
<body>

</body>
</html>