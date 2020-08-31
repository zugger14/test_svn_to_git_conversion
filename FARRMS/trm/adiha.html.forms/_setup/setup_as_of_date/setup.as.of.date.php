<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>    
	<body>
		<?php
			$form_namespace = 'setup_as_of_date';
			$function_id = 10107000;
			$form_obj = new AdihaStandardForm($form_namespace, 10107000);
			$form_obj->define_grid("SetupAsOfDate");		
			$form_obj->define_layout_width(375);
			$form_obj->define_custom_functions('', 'load_form', '');			
			//$form_obj->define_apply_filters(true, '10107200', 'FilterApplicantDetail', 'General');		
			echo $form_obj->init_form( 'Setup As of Date');
			echo $form_obj->close_form();
		?>
	</body>
	<script type="text/javascript">
		var template_name = "SetupAsOfDate";
		var function_id = <?php echo $function_id;?>;		
		setup_as_of_date.load_form = function(win, tab_id) {
			win.progressOff();			
			var is_new = win.getText();			
			var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
		
			if (is_new == 'New') {
				id = '';
			} else {
				id = tab_id;
			}
			
			var xml = '<Root><PSRecordset setup_as_of_date_id="' + id + '"></PSRecordset></Root>';			
			data = {
				  "action": "spa_create_application_ui_json",
				  "flag": "j",
				  "application_function_id": function_id,
				  "template_name": template_name,
				  "parse_xml": xml
			};			
			adiha_post_data('return_array', data, '', '', 'setup_as_of_date.load_form_data', false);			
		}

		setup_as_of_date.load_form_data = function(result) { 
			var active_tab_id = setup_as_of_date.tabbar.getActiveTab();
			var as_of_date_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;			
			var win = setup_as_of_date.tabbar.cells(active_tab_id);
			
			var result_length = result.length;	
			var tab_json = result[0][1];
			var form_json = '';		

			tab_json = '{tabs: [' + tab_json + ']}';

			setup_as_of_date["tabs_" + as_of_date_id] = win.tabbar[as_of_date_id] = win.attachTabbar();
			setup_as_of_date["tabs_" + as_of_date_id].loadStruct(tab_json);
			setup_as_of_date["tabs_" + as_of_date_id].setTabsMode("bottom");
			tabbar_obj = setup_as_of_date["tabs_" + as_of_date_id];

			var layout_json = [
				{
					id: "a",  
					text: "Setup As of Date",                        
					height: 100,
					header: false,
					collapse: false
				},
			];

			form_json = form_json + (result[0][2]);

			var i = 0;        
			var inner_tab_id = get_tab_id(0);

			setup_as_of_date["layout_detail" + as_of_date_id] = setup_as_of_date["tabs_" + as_of_date_id].tabs(inner_tab_id).attachLayout({pattern: "1C", cells:layout_json});			
			
			setup_as_of_date["form_" + as_of_date_id] = setup_as_of_date["layout_detail" + as_of_date_id].cells('a').attachForm();
			setup_as_of_date['form_' + as_of_date_id].loadStruct(form_json);
			setup_as_of_date['form_' + as_of_date_id].disableItem('screen_id');

			// // To load the dependent combo for selec
			// var sp_string =  "select module_id,screen_id from setup_as_of_date where setup_as_of_date_id = " + as_of_date_id; 
   //      	var data_for_post = {"sp_string": sp_string};          
   //      	var return_json = adiha_post_data('return_json', data_for_post, '', '', 'load_screen_combo'); 
			// /***********/            	

			// var sp_string = "EXEC spa_as_of_date @flag = 's', @setup_as_of_date_id = " + as_of_date_id;				
			// var data_for_post = {"sp_string": sp_string};          
   //       	var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_screen_combo'); 

			setup_as_of_date['form_' + as_of_date_id].attachEvent("onChange", function(name,value) {
				var date = new Date();	

				if (name == 'as_of_date') {		
					setup_as_of_date['form_' + as_of_date_id].setItemValue('no_of_days', '');
					var date_type = setup_as_of_date['form_' + as_of_date_id].getItemValue('as_of_date');
					setup_as_of_date['form_' + as_of_date_id].disableItem('no_of_days');
					if (date_type == 1) {	
						setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date', date); 
					} else if (date_type == 2) {
						var first_day = new Date(date.getFullYear(), date.getMonth(), 1);		
						setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date', first_day); 
					} else if (date_type == 3) {
						var last_day = new Date(date.getFullYear(), date.getMonth() + 1, 0);									
						setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date', last_day); 
					} else if (date_type == 4) {
						var day_before_run = new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1);
						setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date', day_before_run); 
					} else if (date_type == 5) {
						setup_as_of_date['form_' + as_of_date_id].enableItem('no_of_days');	
						setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date','');							
					} else if (date_type == 6) {	
						var first_day_next_mth = new Date(date.getFullYear(), date.getMonth() + 1, 1);						
						first_day_next_mth = dates.convert_to_sql(first_day_next_mth);
				        data = {
									"action": "spa_get_business_day", 
				                    "flag": "p",
									"date": first_day_next_mth 
								}
				        return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
					} else if (date_type == 7) {
						var last_day_prev_mth = new Date(date.getFullYear(), date.getMonth(), 0);	
						last_day_prev_mth = dates.convert_to_sql(last_day_prev_mth);										
						data = {
									"action": "spa_get_business_day", 
				                    "flag": "n",
									"date": last_day_prev_mth 
								}
				        return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 						
					} else if (date_type == 8) {
						/*	last day of the current month = new Date(y, m + 1, 0); so 
						last day of the previous month = new Date(y, m + 1 -1, 0); */
						var first_day_of_mth = new Date(date.getFullYear(), date.getMonth(), 1);	
						first_day_of_mth = dates.convert_to_sql(first_day_of_mth);						
						data = {
									"action": "spa_get_business_day", 
				                    "flag": "p",
									"date": first_day_of_mth 
								}
				        return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
					} 
				} else if (name == 'module_id') {
					setup_as_of_date['form_' + as_of_date_id].enableItem('screen_id');
					setup_as_of_date['form_' + as_of_date_id].setItemValue('screen_id','');
					var cm_param = {
	                    "action": "spa_as_of_date", 
	                    "flag": "c",
						"module_id": value
                 	};

		            cm_param = $.param(cm_param);
		            var url = js_dropdown_connector_url + '&' + cm_param;

		            var combo_obj_uom = setup_as_of_date['form_' + as_of_date_id].getCombo('screen_id');
            		combo_obj_uom.load(url);
				} else if (name == 'no_of_days') { 
					var no_of_days = setup_as_of_date['form_' + as_of_date_id].getItemValue('no_of_days');				
					var custom_as_of_date = new Date();
					var calculated_date = custom_as_of_date.setDate(custom_as_of_date.getDate() - parseInt(no_of_days));				

					calculated_date = new Date(calculated_date).toUTCString();
					calculated_date = new Date(calculated_date)					
					setup_as_of_date['form_' + as_of_date_id].setItemValue('custom_as_of_date', calculated_date);
				}					
			});			
		}	

	
		//***************************//
		function get_tab_id(j) {
			var tab_id = [];
			var i = 0;
			var inner_tab_obj = get_inner_tab_obj();
			inner_tab_obj.forEachTab(function(tab) {
				tab_id[i] = tab.getId();
				i++;
			});	
			return tab_id[j];
		}
		
		//*********************//
		function get_inner_tab_obj() {
			var active_tab_id = setup_as_of_date.tabbar.getActiveTab();
			var detail_tabs, att_tabbar_obj;
			setup_as_of_date.tabbar.forEachTab(function(tab) {
				if (tab.getId() == active_tab_id) {
					att_lay_obj = tab.getAttachedObject();					
				}
			});
			return att_lay_obj;
		}
		
		function load_business_day(return_json) { 
			var return_json = JSON.parse(return_json);
			var business_day = return_json[0].business_day;				
			var active_tab_id = setup_as_of_date.tabbar.getActiveTab();
			var as_of_date_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;	
			tabbar_obj = setup_as_of_date["tabs_" + as_of_date_id];				
			tabbar_obj.forEachTab(function(tab) {
				var tab_text = tab.getText();				 
            	if (tab_text == 'General') {
            		attached_obj = tab.getAttachedObject();
                	attached_obj.forEachItem(function(cell) {
                		cell_attached_obj = cell.getAttachedObject();
                		if (cell_attached_obj instanceof dhtmlXForm) {
                			cell_attached_obj.setItemValue('custom_as_of_date', business_day); 
                		}
                	})
                }
            }) 
		}

		function load_screen_combo(return_json) {		
			return_json = JSON.parse(return_json);        
        	var module_id = return_json[0].module_id;
        	var screen_id = return_json[0].screen_id;

			var cm_param = {
                "action": "spa_as_of_date", 
                "flag": "c",
				"module_id": module_id
         	};

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;

			var active_tab_id = setup_as_of_date.tabbar.getActiveTab();
			var as_of_date_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;	
			tabbar_obj = setup_as_of_date["tabs_" + as_of_date_id];				
			tabbar_obj.forEachTab(function(tab) {
				var tab_text = tab.getText();				 
            	if (tab_text == 'General') {
            		attached_obj = tab.getAttachedObject();
                	attached_obj.forEachItem(function(cell) {
                		cell_attached_obj = cell.getAttachedObject();
                		if (cell_attached_obj instanceof dhtmlXForm) {                			
				            var combo_obj_menu = cell_attached_obj.getCombo('screen_id');
		            		combo_obj_menu.load(url);
		            		// combo_obj_menu.setComboValue(screen_id);
		            		// var a = combo_obj_menu.getIndexByValue(screen_id);
		            		// alert(a);
		            		// combo_obj_menu.selectOption(a,true,false);
		            		// combo_obj_menu.setFocus()
	                    }
                	})
            	}
            })
		}

		// function set_screen_combo(return_json) { 
		// 	return_json = JSON.parse(return_json);  
		// 	menu = return_json[0].screen;
		// 	var active_tab_id = setup_as_of_date.tabbar.getActiveTab();
		// 	var as_of_date_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;	
		// 	tabbar_obj = setup_as_of_date["tabs_" + as_of_date_id];				
		// 	tabbar_obj.forEachTab(function(tab) {
		// 		var tab_text = tab.getText();				 
  //           	if (tab_text == 'General') {
  //           		attached_obj = tab.getAttachedObject();
  //               	attached_obj.forEachItem(function(cell) {
  //               		cell_attached_obj = cell.getAttachedObject();
  //               		if (cell_attached_obj instanceof dhtmlXForm) {                			                			
		// 		            var combo_obj_menu = cell_attached_obj.getCombo('screen_id');
		// 		            var a = combo_obj_menu.getIndexByValue(menu);
		// 		            var a = combo_obj_menu.getIndexByValue(menu);					            
		//             		combo_obj_menu.selectOption(a,true, true);		
		// 		            //var a =combo_obj_menu.getComboText();
		// 		            //var a =combo_obj_menu.getOption(a);				            
		//             		// combo_obj_menu.clearAll();
		//             		// // combo_obj_menu.setComboValue(menu);
		            		            				            		
	 //                    }
  //               	})
  //           	}
  //           })
		// }

	</script>>
</html>