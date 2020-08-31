<?php
/**
* Incident log screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
	global $app_adiha_loc;
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
	$category_id = get_sanitized_value($_REQUEST['category_id'] ?? '');
	$incident_log_id = get_sanitized_value($_REQUEST['incident_log_id'] ?? '');
	$sub_category_id = get_sanitized_value($_REQUEST['sub_category_id'] ?? '');
	$notes_object_id = get_sanitized_value($_REQUEST['notes_object_id'] ?? '');
	$parent_object_id = get_sanitized_value($_REQUEST['parent_object_id'] ?? '');
	
	$param = '?call_from=manage_document&category_id=' . $category_id;
	$param_detail = '&call_from=manage_document&category_id=' . $category_id;
	
    $json = '[
                {
                    id:             "a",
                    text:           "Incident",
                    header:         true,
                    collapse:       false,
					height:			200
				}, 
                {
                    id:             "b",
                    text:           "Outcomes",
                    header:         true,
                    collapse:       false,
                    height:          270
                },
                {
                    id:             "c",
                    text:           "Document",
                    header:         true,
                    collapse:       false,
                    width:          500,
					height:			200
                },
                {
                    id:             "d",
                    text:           "Updates",
                    header:         true,
                    collapse:       false,
                    width:          500
                }
            ]';

    $namespace = 'incident_log';



    $save_enable_disable = 'true';
    if ($category_id == 'NULL'){
    	$save_enable_disable = 'false';
    }

    $incident_log_layout_obj = new AdihaLayout();
    echo $incident_log_layout_obj->init_layout('incident_log_layout', '', '4U', $json, $namespace);

	$toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text: "Save", enabled: '.$save_enable_disable.', title: "Save"}]';
	echo $incident_log_layout_obj->attach_toolbar('incident_log_toolbar');
    $incident_log_toolbar_obj = new AdihaToolbar();
    echo $incident_log_toolbar_obj->init_by_attach('incident_log_toolbar', $namespace);
    echo $incident_log_toolbar_obj->load_toolbar($toolbar_json);
    echo $incident_log_toolbar_obj->attach_event('', 'onClick', 'incident_log_toolbar_onclick');	

    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10102912', @template_name='incident log', @parse_xml='<Root><PSRecordset incident_log_id=\"$incident_log_id\"></PSRecordset></Root>'";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
	$form_json1 = $form_arr[1]['form_json'];

    echo $incident_log_layout_obj->attach_form('incident_log_form', 'a');
    $incident_log_form_obj = new AdihaForm();
    echo $incident_log_form_obj->init_by_attach('incident_log_form', $namespace);
    echo $incident_log_form_obj->load_form($form_json); 
	
	echo $incident_log_layout_obj->attach_form('incident_outcome_form', 'b');
    $incident_outcome_form_obj = new AdihaForm();
    echo $incident_outcome_form_obj->init_by_attach('incident_outcome_form', $namespace);
    echo $incident_outcome_form_obj->load_form($form_json1);
    
	$menu_json = '[ 
        {id:"refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", disabled:0},
        {id:"edit", img:"edit.gif", text:"Edit", items:[
        	{id:"add", img:"new.gif", img_disabled:"new_dis.gif", text:"Add", title:"Add", disabled:false},
            {id:"delete", img:"delete.gif", img_disabled:"delete_dis.gif", text:"Delete", title:"Delete", disabled:true}
        ]}
    ]';
	
    echo $incident_log_layout_obj->attach_menu_layout_cell('incident_log_detail_menu', 'd', $menu_json, 'incident_log_detail_menu_click');
    
    echo $incident_log_layout_obj->attach_grid_cell('incident_log_detail_grid', 'd');
    $incident_log_detail_grid_obj = new GridTable('incident_log_detail');
    echo $incident_log_detail_grid_obj->init_grid_table('incident_log_detail_grid', $namespace, 'n');
    echo $incident_log_detail_grid_obj->return_init();
    echo $incident_log_detail_grid_obj->enable_multi_select(true);
	echo $incident_log_detail_grid_obj->attach_event('','onRowSelect','incident_log_detail_rowselect');
	echo $incident_log_detail_grid_obj->attach_event('','onRowDblClicked','incident_log_detail_dbclick');
    echo $incident_log_detail_grid_obj->load_grid_functions();
    
	
	$upload_json = "[	
						{type: 'settings',position:'label-top', offsetLeft: 10},
						{type: 'block', blockOffset:0, list: [
							{type: 'fieldset', inputWidth:450, label: 'File Attachment', list:[
								{type: 'upload', name: 'upload', inputWidth:400, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php" . $param . "', autoStart:true}
							]},
							{type: 'newcolumn'},
							{type: 'hidden', value:'', name:'file_attachment'},									
						]},
						{type: 'block', blockOffset:0, list: [
							{type: 'label', inputWidth:580, label: 'Current Attached File(s): current_attached_file', hidden: true, offsetTop: 0, className: 'current_attached'}
						]}
					]";
    
    if($incident_log_id != '') {
        $xml_url = "EXEC spa_incident_log @flag='f',@incident_log_id=" . $incident_log_id;
        $result_set = readXMLURL2($xml_url);
        
        $download_url = $app_adiha_loc . 'adiha.html.forms/_setup/manage_documents/force_download.php';
        $attached_file_link = '<a href="' . $download_url . '?path=' . $result_set[0]['notes_attachment'] . '" download>' . $result_set[0]['attachment_file_name'] . '</a>';
        $upload_json = str_replace("current_attached_file', hidden: true", $attached_file_link."', hidden: false", $upload_json);
    }
    
	echo $incident_log_layout_obj->attach_form('upload_form', 'c');
    $upload_form_obj = new AdihaForm();
    echo $upload_form_obj->init_by_attach('upload_form', $namespace);
    echo $upload_form_obj->load_form($upload_json);
	echo $upload_form_obj->attach_event('', 'onUploadFile', 'upload_doc');
	echo $upload_form_obj->attach_event('', 'onFileRemove', 'remove_doc');
	
    echo $incident_log_layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">  
    	var combo_names = '<?php echo  $form_arr[1]['dependent_combo']; ?>';
    	var category_id = '<?php echo $category_id; ?>';
		if (category_id == 'NULL') category_id = '';
		var sub_category_id = '<?php echo $sub_category_id; ?>';
		if (sub_category_id == 'NULL') sub_category_id = '';
		var notes_object_id = '<?php echo $notes_object_id; ?>';
		if (notes_object_id == 'NULL') notes_object_id = '';
		var parent_object_id = '<?php echo $parent_object_id; ?>';
		if (parent_object_id == 'NULL') parent_object_id = '';
		
		var incident_log_id_manage = '<?php echo $incident_log_id; ?>';
 
		$(function(){
            incident_log.incident_log_detail_grid.setColumnMinWidth(150,3);
			incident_log.incident_log_detail_grid.setColWidth(3,"*");			

            var form_obj = incident_log.incident_log_layout.cells("b").getAttachedObject();
                
            if (form_obj instanceof dhtmlXForm) {
                load_dependent_combo(combo_names, 0, form_obj);
            }
            			
			refresh_incident_detail_grid();

   //          var form_obj_save = incident_log.incident_log_layout.getAttachedObject();
   //          if(category_id == ''){		
			// 	form_obj_save.setItemDisabled('save');
			// }
			
		});
        
		/*
		 * [Incident Menu click function]
		 */
		incident_log_toolbar_onclick = function(name, value) {
			if (name == 'save') {
				save_invoice_log();
			}
		}
		
		/*
		 * [Save Function]
		 */
		save_invoice_log = function() {
			var status = validate_form(incident_log.incident_log_form);
			if (status == false) {
				return;
			}
			
			var file_attachment = incident_log.upload_form.getItemValue('file_attachment');
			if(file_attachment.indexOf(',') >= 0) {
				dhtmlx.alert({
					title:"Error!",
					type:"alert-error",
					text:'Please upload only 1 file.'
				});
				return;
			}
			
			var is_organic_set = 'n';
		

			//Invoice Header
			var incident_log_id = incident_log.incident_log_form.getItemValue('incident_log_id');
			var incident_type = incident_log.incident_log_form.getItemValue('incident_type');
			var incident_description = incident_log.incident_log_form.getItemValue('incident_description');
			var incident_status = incident_log.incident_log_form.getItemValue('incident_status');
			var buyer_from = incident_log.incident_log_form.getItemValue('buyer_from');
			var seller_to = incident_log.incident_log_form.getItemValue('seller_to');
			//var counterparty = incident_log.incident_log_form.getItemValue('counterparty');
			var internal_counterparty = incident_log.incident_log_form.getItemValue('internal_counterparty');
			var contract = incident_log.incident_log_form.getItemValue('contract');
			var location = incident_log.incident_log_form.getItemValue('location');
			var date_initiated = incident_log.incident_log_form.getItemValue('date_initiated',true);
			var date_closed = incident_log.incident_log_form.getItemValue('date_closed',true);
			var trader = incident_log.incident_log_form.getItemValue('trader');
			var logistics = incident_log.incident_log_form.getItemValue('logistics');
			var ref_incident_id = incident_log.incident_log_form.getItemValue('ref_incident_id'); 
			
			//Outcome Form
			var initial_assesment = incident_log.incident_outcome_form.getItemValue('initial_assesment');
			var outcome_acceptable = incident_log.incident_outcome_form.getItemValue('outcome_acceptable');
			var resolved_satisfactory = incident_log.incident_outcome_form.getItemValue('resolved_satisfactory');
			var non_confirming_delivered = incident_log.incident_outcome_form.getItemValue('non_confirming_delivered');
			var root_cause = incident_log.incident_outcome_form.getItemValue('root_cause');
			var corrective_action = incident_log.incident_outcome_form.getItemValue('corrective_action');
			var preventive_action = incident_log.incident_outcome_form.getItemValue('preventive_action');
			var claim_amount = incident_log.incident_outcome_form.getItemValue('claim_amount');
			var claim_amount_currency = incident_log.incident_outcome_form.getItemValue('claim_amount_currency');
			var settle_amount = incident_log.incident_outcome_form.getItemValue('settle_amount');
			var settle_amount_currency = incident_log.incident_outcome_form.getItemValue('settle_amount_currency');
			
			var incident_log_xml = '<IncientLog ';
			incident_log_xml += ' incident_log_id="' + incident_log_id + '"';
			incident_log_xml += ' incident_type="' + incident_type + '"';
			incident_log_xml += ' incident_description="' + incident_description + '"';
			incident_log_xml += ' incident_status="' + incident_status + '"';
			incident_log_xml += ' buyer_from="' + buyer_from + '"';
			incident_log_xml += ' seller_to="' + seller_to + '"';
			//incident_log_xml += ' counterparty="' + counterparty + '"';
			incident_log_xml += ' internal_counterparty="' + internal_counterparty + '"';
			incident_log_xml += ' contract="' + contract + '"';
			incident_log_xml += ' location="' + location + '"'
			incident_log_xml += ' date_initiated="' + date_initiated + '"';
			incident_log_xml += ' date_closed="' + date_closed + '"';
			incident_log_xml += ' trader="' + trader + '"';
			incident_log_xml += ' logistics="' + logistics + '"';
			incident_log_xml += ' ref_incident_id="' + ref_incident_id + '"'; 
			
			incident_log_xml += ' initial_assesment="' + initial_assesment + '"';
			incident_log_xml += ' outcome_acceptable="' + outcome_acceptable + '"';
			incident_log_xml += ' resolved_satisfactory="' + resolved_satisfactory + '"';
			incident_log_xml += ' non_confirming_delivered="' + non_confirming_delivered + '"';
			incident_log_xml += ' root_cause="' + root_cause + '"';
			incident_log_xml += ' corrective_action="' + corrective_action + '"';
			incident_log_xml += ' preventive_action="' + preventive_action + '"';
			incident_log_xml += ' claim_amount="' + claim_amount + '"';
			incident_log_xml += ' claim_amount_currency="' + claim_amount_currency + '"';
			incident_log_xml += ' settle_amount="' + settle_amount + '"';
			incident_log_xml += ' settle_amount_currency="' + settle_amount_currency + '"';
			incident_log_xml += ' />';

			
			var application_notes_xml = '<ApplicationNotes '
			application_notes_xml += ' category_id ="' + category_id + '"'
			application_notes_xml += ' sub_category_id ="' + sub_category_id + '"'
			application_notes_xml += ' notes_object_id ="' + notes_object_id + '"'
			application_notes_xml += ' parent_object_id ="' + parent_object_id + '"'
			application_notes_xml += ' notes_subject ="' + incident_description + '"'
			application_notes_xml += ' file_attachment ="' + file_attachment + '"'
			application_notes_xml += ' />'
			
			var final_xml = '<Root>' + incident_log_xml + application_notes_xml + '</Root>';
			
			var data = {
                                "action": "spa_incident_log",
                                "flag": "i",
                                "xml_data":final_xml
                              }

            adiha_post_data('return_json', data, '', '', 'save_invoice_log_callback', '', '');
		}
		
		
		/*
		 * [Save Callback Function]
		 */
		function save_invoice_log_callback(result) {
			var return_data = JSON.parse(result);
			var new_id = return_data[0].recommendation;
			 if (return_data[0].errorcode == 'Success'){
			  	incident_log.incident_log_toolbar.disableItem('save');
			 }
			incident_log.incident_log_form.setItemValue('incident_log_id',new_id);
			
			dhtmlx.message({
				text:return_data[0].message,
				expire:500
			});
			
			parent.fx_refresh_incident_grid();
			after_save();
			}
        
        function after_save(){
        	incident_log.incident_log_toolbar.enableItem('save');
        }
		
		/*
		 * [Incident Detail Grid Menu click function]
		 */
		incident_log_detail_menu_click = function(name, value) {
			switch(name) {
				case 'add':
					open_incident_log_detail_window('');
					break;
				case 'delete':
					delete_incident_detail();
					break;
				case 'refresh':
					refresh_incident_detail_grid();
					break;
			}
		}
		
		
		/*
		 * [Enable Disable button in row select]
		 */
		incident_log_detail_rowselect = function(id,ind) {
			incident_log.incident_log_detail_menu.setItemEnabled('delete');
		}
		
		/*
		 * [Update on double click]
		 */
		incident_log_detail_dbclick = function(id,ind) {
			var incident_log_detail_id = incident_log.incident_log_detail_grid.cells(id, 0).getValue();
			open_incident_log_detail_window(incident_log_detail_id);
		}
		
		
		/*
		 * [Open Incident Detail Window]
		 */
		open_incident_log_detail_window = function(incident_log_detail_id) {
			var incident_log_id = incident_log.incident_log_form.getItemValue('incident_log_id');
			
			if (incident_log_id == '') {
				show_messagebox('Please save the incident first.');
				return;
			}
			
			incident_log_detail_window = new dhtmlXWindows();
        
			var param_detail = '<?php echo $param_detail; ?>';
			var src = js_php_path + '../adiha.html.forms/_setup/manage_documents/incident.log.detail.php?incident_log_id=' + incident_log_id + '&incident_log_detail_id=' + incident_log_detail_id + param_detail; 
			incident_detail_win_obj = incident_log_detail_window.createWindow('w1', 0, 0, 500, 400);
			incident_detail_win_obj.setText("Incident Detail");
			
			incident_detail_win_obj.centerOnScreen();
			incident_detail_win_obj.setModal(true);
			incident_detail_win_obj.attachURL(src, false, true);
			
			incident_detail_win_obj.attachEvent("onClose", function(win){
				refresh_incident_detail_grid();
				parent.fx_refresh_incident_grid();
				return true;
			});
		}
		
		
		/*
		 * [Delete Incident log detail]
		 */
		delete_incident_detail = function() {
			var selected_id = incident_log.incident_log_detail_grid.getSelectedId();
			if(selected_id == null) {
				show_messagebox('Please select the data you want to delete.');
				return;
			}
			
			var selected_id_array = new Array();
			selected_id_array = selected_id.split(",");
			var incident_detail_array = new Array();
			
			for (count = 0; count < selected_id_array.length; count++) {
				temp_id = incident_log.incident_log_detail_grid.cells(selected_id_array[count], 0).getValue();
				incident_detail_array.push(temp_id);
			}
			
			var incident_log_detail_id = incident_detail_array.toString();
			var data = {
						"action": "spa_incident_log",
						"flag": "r",
						"incident_log_detail_id": incident_log_detail_id
					};

			var confirm_msg = 'Are you sure you want to delete?';

			dhtmlx.message({
				type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
				text: confirm_msg,
				callback: function(result) {
					if (result)
						adiha_post_data('alert', data, '', '', 'refresh_incident_detail_grid', '');
				}
			});
		}

		/*
		 * [Callback from Incident Detail windiw]
		 */
		incident_log_detail_callback = function(incident_status,incident_log_id) { 
			var data = {
                                "action": "spa_incident_log",
                                "flag": "t",
                                "incident_log_id":incident_log_id,
                                "incident_status":incident_status
                              }

            adiha_post_data('return_json', data, '', '', '', '', '');
			incident_log.incident_log_form.setItemValue('incident_status',incident_status); 
		}
		
		
		/*
		 * [Refresh Incident Detail Grid]
		 */
		refresh_incident_detail_grid = function() {
			var incident_log_id = incident_log.incident_log_form.getItemValue('incident_log_id');
			
			if (incident_log_id != '') {
				var sql_param = {
					"flag": "s",
					"action":"spa_incident_log",
					"grid_type":"g",
					"incident_log_id": incident_log_id
				};
				sql_param = $.param(sql_param);
				var sql_url = js_data_collector_url + "&" + sql_param;
				incident_log.incident_log_detail_grid.clearAll();
				incident_log.incident_log_detail_grid.load(sql_url); 
				incident_log.incident_log_detail_menu.setItemDisabled('delete');
			}
		}
		
		upload_doc = function(realName,serverName) {
			var get_pre_name = incident_log.upload_form.getItemValue('file_attachment');

			if (get_pre_name == '') {
				final_name = serverName;
			} else {
				final_name = get_pre_name + ', ' + serverName;
			}
			
			incident_log.upload_form.setItemValue('file_attachment', final_name);
		}

		/**
		 * [remove_doc Remove document]
		 * @param  {[type]} realName   [description]
		 * @param  {[type]} serverName [description]
		 */
		remove_doc = function(realName,serverName){
			var file_name_list = incident_log.upload_form.getItemValue('file_attachment');
			file_name_list = remove_file_name(file_name_list, realName);
			incident_log.upload_form.setItemValue('file_attachment', file_name_list);
		}
		
		/**
		 * [remove_file_name Remove file name from list]
		 * @param  {[type]} list  [list]
		 * @param  {[type]} value [matching value]
		 */
		remove_file_name = function(list, value) {
			var elements = list.split(", ");
			var remove_index = elements.indexOf(value);

			elements.splice(remove_index,1);
			var result = elements.join(", ");
			return result;
		}
        
    </script>