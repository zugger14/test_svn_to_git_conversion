<!DOCTYPE html>
<html>
	<head>
	    <meta charset="UTF-8" />
	    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
	    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" /> 
	</head>  
	<body>
		<?php 
			require('../../../adiha.php.scripts/components/include.file.v3.php');

			$source_deal_header_id = (isset($_REQUEST["source_deal_header_id"]) && $_REQUEST["source_deal_header_id"] != '') ? get_sanitized_value($_REQUEST["source_deal_header_id"]) : 'NULL';
			$form_dropdown_sql = "EXEC spa_eligibility_mapping @flag='s'";
			$form_dropdown_data = adiha_form_dropdown($form_dropdown_sql, 0, 1, false, '', 2);
			
			$layout_json = '
				[
	                {
	                    id: "a",
	                    text: "Eligibility Mapping Template Details",
	                    width: 500,
	                    height: 500,
	                    header: true,
	                    collapse: false,
	                    fix_size: [false,null]
	                }
	            ]
			';
			 
			$menu_json = '[{id: "ok", img: "tick.gif", imgdis:"tick_dis.gif", enabled: "true", text: "OK"}]';

			$form_json = '
				[
				    {type: "settings", position: "label-top"},
				    {type: "block", blockOffset: 0, list:[
				        {type: "combo", offsetLeft: 15 , name: "eligibility_mapping", label: "<a href=\'javascript:void(0);\' onclick=\"call_TRMWinHyperlink(20010600, \'eligibility_mapping\');\">Eligibility Mapping Template</a>", labelWidth:"auto", inputWidth: 230,options:'. $form_dropdown_data .', disabled: 0  }
				    ]}
				]
			';

			$form_namespace = 'eligibility_mapping_template_details';
			$layout_obj = new AdihaLayout();

			echo $layout_obj->init_layout('eligibility_mapping_template_details_layout', '', '1C', $layout_json, $form_namespace);
	                    
			//Attach Menu
			$menu_object = new AdihaMenu();
			echo $layout_obj->attach_menu_cell("details_menu", "a"); 
			echo $menu_object->init_by_attach("details_menu", $form_namespace);
			echo $menu_object->load_menu($menu_json);
			echo $menu_object->attach_event('', 'onClick', $form_namespace . '.template_details_menu_click');

			//Attach From
			$form_name = 'details_form';
			echo $layout_obj->attach_form($form_name, "a");
			$form_obj = new AdihaForm();
			echo $form_obj->init_by_attach($form_name, $form_namespace);
			echo $form_obj->load_form($form_json, $form_namespace . '.form_load_callback');

			echo $layout_obj->close_layout();  
		 ?>

		 <script type="text/javascript">
			$(function() {
				var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
			});

 			eligibility_mapping_template_details.template_details_menu_click = function() {
 				var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
 				var dhxCombo_obj = eligibility_mapping_template_details.details_form.getCombo('eligibility_mapping');
 				var template_id = dhxCombo_obj.getSelectedValue();
 				var win_obj = window.parent.dhxWins.getTopmostWindow();
 				parent.product_info.grd_product_refresh(template_id);
 				win_obj.close();
 			}
		 </script>
	</body>
</html>