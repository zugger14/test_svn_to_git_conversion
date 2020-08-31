<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $rule_id = get_sanitized_value($_GET['rules_id']);
    $process_id = get_sanitized_value($_GET['process_id']);
	$data_source = get_sanitized_value($_GET['data_source']);
	
	$email_filter_clicked = $_GET['email_filter_clicked'] ?? 0;

    $json = '[
                
                {
                    id:             "a",
                    text:           "Filter Group",
                    header:         false,
                    collapse:       false,
					width:			300
                },
				{
                    id:             "b",
                    text:           "Filter List",
                    header:         false,
                    collapse:       false
                }
            ]';
    
    $namespace = 'import_filters';
    $import_filters_layout_obj = new AdihaLayout();
    echo $import_filters_layout_obj->init_layout('import_filters_layout', '', '2U', $json, $namespace);
    
	$xml_file = "EXEC spa_ixp_import_filter @flag = 'filter_json', @data_source_type = " . $data_source;
    $return_value = readXMLURL($xml_file);
	$filter_item_json = $return_value[0][0];
    
	echo $import_filters_layout_obj->attach_form('import_filter_form', 'b');
    $import_filter_form = new AdihaForm();
    echo $import_filter_form->init_by_attach('import_filter_form', $namespace);
    echo $import_filter_form->load_form($filter_item_json);

	$toolbar_json = '[
                        { id: "ok", type: "button", img: "tick.png", text: "OK", title: "OK", enabled: 0}
                     ]';
	echo $import_filters_layout_obj->attach_toolbar_cell('import_filters_toolbar', 'b');
    $import_filters_toolbar = new AdihaToolbar();
    echo $import_filters_toolbar->init_by_attach('import_filters_toolbar', $namespace);
    echo $import_filters_toolbar->load_toolbar($toolbar_json);
    echo $import_filters_toolbar->attach_event('', 'onClick', 'import_filters_toolbar_onclick');

	$menu_name = 'import_filter_menu';
	$menu_json = '[
					{id:"edit", text:"Edit", img:"edit.gif", items:[
						{id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif.gif" },
						{id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled :0}
					]},
					{id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
					{id:"help", text:"Help", img:"help.gif", imgdis:"help_dis.gif"}
				  ]';

	echo $import_filters_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.import_menu_click');

	$tree_name = 'import_filter_tree';
	echo $import_filters_layout_obj->attach_tree_cell($tree_name, 'a');
	$tree_obj = new AdihaTree();
	echo $tree_obj->init_by_attach($tree_name, $namespace);
	echo $tree_obj->attach_event('', 'onXLE', 'import_filter_tree_onload');
	echo $tree_obj->attach_event('', 'onSelect', 'import_filter_tree_onselect');
	echo $tree_obj->attach_event('', 'onEdit', 'import_filter_tree_onedit');
	
	echo $tree_obj->load_tree_functions();

    echo $import_filters_layout_obj->close_layout();
    ?> 
</body>
    
<script>
    var rules_id = '<?php echo $rule_id; ?>';
    var process_id = '<?php echo $process_id; ?>';
    var data_source = '<?php echo $data_source; ?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
	var tree_expand_flag = 1;
	var sel_filter_group_id = '';
	var email_filter_clicked = <?php echo $email_filter_clicked ?>;
    
    $(function() {
		import_filters.import_filter_form.attachEvent("onChange", function (name, value, state){
			if (state == true) {
				import_filters.import_filter_form.showItem('Input_' + name);
			} else if (state == false) {
				import_filters.import_filter_form.hideItem('Input_' + name);
			}
		});
		
		refresh_tree();
		import_filters.import_filter_tree.enableItemEditor(true);
		
		var help_list = [
			'At least one rule must be checked to save a filter.',
			'Rules checked under a criterion/filter work when all the checked rules match in the email.',
			'Rules checked under different criterion/filters work when any of the checked rules match perfectly in the email.',
			'Double click on the folder icon to rename any filter criterion.',
		]
		if (email_filter_clicked == 1) {
			help_list.push('To add multiple email address in any rule, insert semicolon (;) between email addresses.')
		}
		import_filters.create_help_popup(help_list);
	})

	import_filters.create_help_popup = function(help_list){
		import_filters.help_popup = new dhtmlXPopup({
			mode: 'top'
		});

		import_filters.help_popup.attachHTML(import_filters.get_help_list_html(help_list));
		import_filters.help_popup.p.querySelector('table').width = 400;
		import_filters.help_popup.hide();

		$(document).on('click', function(e){
			if($(import_filters.help_popup.p).has(e.target).length == 0) {
				import_filters.help_popup.hide()
			}
		})
	}

	import_filters.get_help_list_html = function(help_list) {
		var popup_html = document.createElement('ul');

		help_list.forEach(function(item) {
			var list_item = document.createElement('li');
			list_item.appendChild(document.createTextNode(item));
			popup_html.appendChild(list_item);
		});

		return popup_html.outerHTML;
	}
	
	import_filters_toolbar_onclick = function(name) {
        if (name == 'ok') {	
			import_filters.import_filter_tree.stopEdit();
			var xml = '<Root>';
            import_filters.import_filter_form.forEachItem(function(name){
				var item_type = import_filters.import_filter_form.getItemType(name);
				if (item_type == 'checkbox') {
					var is_checked = import_filters.import_filter_form.isItemChecked(name);
					if (is_checked == true) {
						var input_value = import_filters.import_filter_form.getItemValue('Input_' + name);
						xml += '<Import_Filter filter_id ="' + name + '" filter_value="' + input_value + '" />';
					}
				}
			});
			xml += '</Root>';
			var filter_group = import_filters.import_filter_tree.getItemText(sel_filter_group_id);
			
			
			data = {
						"action": "spa_ixp_import_filter",
                        "flag": "save_filter",
                        "rules_id": rules_id,
						"filter_group": filter_group,
						"data_source_type": data_source,
						"xml_data": xml,
						"process_id": process_id
                    };
			adiha_post_data('alert', data, '', '', 'refresh_tree', '', '');
			
        } 
    }
	
	refresh_tree = function() {
		var param = 'flag=filter_list&rules_id=' + rules_id + '&data_source_type=' + data_source + '&process_id=' + process_id;
		import_filters.refresh_tree('spa_ixp_import_filter', 'c_id:c_value', 'f_id:f_value', param);
		disable_detail_section();
	}
	
	import_filters.import_menu_click = function(id, zoneId, cas) {
		if (id == 'expand_collapse') {
			if (tree_expand_flag == 0) {
				import_filters.tree_expand_all();
            	tree_expand_flag = 1;
			} else {
				import_filters.tree_collapse_all();
				tree_expand_flag = 0;
			}
		} else if (id == 'add') {
			import_filters.import_filter_tree.insertNewChild("0","-1","New..");
		} else if (id == 'delete') {
			var selected_id = import_filters.import_filter_tree.getSelectedItemId();
			import_filters.remove_filter_data(selected_id);
		} else if (id == 'help'){
			import_filters.help_popup.show(165, 20,100,10);
		}
	}
	
	import_filter_tree_onload = function() {
		import_filters.tree_expand_all();
		tree_expand_flag = 1;
		
		var cnt = import_filters.import_filter_tree.hasChildren(0);
		if (cnt == 0) {
			import_filters.import_filter_tree.insertNewChild("0","-1","New..");
		}
	}
	
	
	import_filter_tree_onselect = function(id){
		var tree_level = import_filters.import_filter_tree.getLevel(id);
		if (tree_level == 1) {
			import_filters.import_filter_menu.setItemEnabled('delete');
			
			import_filters.get_filter_data(id);
		} else {
			import_filters.import_filter_menu.setItemDisabled('delete');
		}
	}
	
	enable_detail_section = function() {
		import_filters.import_filters_toolbar.enableItem('ok');
		
		import_filters.import_filter_form.forEachItem(function(name){
			var item_type = import_filters.import_filter_form.getItemType(name);
			if (item_type == 'checkbox') {
				import_filters.import_filter_form.enableItem(name);
				import_filters.import_filter_form.uncheckItem(name);
			} else if (item_type == 'input') {
				import_filters.import_filter_form.setItemValue(name,'');
				import_filters.import_filter_form.hideItem(name);
			}
		});
	}
	
	disable_detail_section = function() {
		import_filters.import_filters_toolbar.disableItem('ok');
		
		import_filters.import_filter_form.forEachItem(function(name){
			var item_type = import_filters.import_filter_form.getItemType(name);
			if (item_type == 'checkbox') {
				import_filters.import_filter_form.disableItem(name);
				import_filters.import_filter_form.uncheckItem(name);
			} else if (item_type == 'input') {
				import_filters.import_filter_form.setItemValue(name,'');
				import_filters.import_filter_form.hideItem(name);
			}
		});
	}
	
	import_filters.get_filter_data = function(id) {
		sel_filter_group_id = id;
		enable_detail_section();
		if (id == -1) {
			var filter_group = '';
		} else {
			var filter_group = import_filters.import_filter_tree.getItemText(id);
		}
		
		data = {
					"action": "spa_ixp_import_filter",
					"flag": "filter_data",
					"rules_id": rules_id,
					"filter_group": filter_group,
					"data_source_type": data_source,
					"process_id": process_id
				};
		adiha_post_data('return_array', data, '', '', 'import_filters.load_filter_data', '', '');
	}
	
	import_filters.load_filter_data = function(result) {
		for (cnt = 0; cnt < result.length; cnt++) {
			import_filters.import_filter_form.showItem('Input_' + result[cnt][2]);
			import_filters.import_filter_form.checkItem(result[cnt][2]);
			import_filters.import_filter_form.setItemValue('Input_' + result[cnt][2], result[cnt][3]);
		}
	}
	
	import_filters.remove_filter_data = function(selected_id) {
		var filter_group = import_filters.import_filter_tree.getItemText(selected_id);
		
		data = {
					"action": "spa_ixp_import_filter",
					"flag": "delete_filter_group",
					"rules_id": rules_id,
					"filter_group": filter_group,
					"data_source_type": data_source,
					"process_id": process_id
				};
		adiha_post_data('alert', data, '', '', 'refresh_tree', '', '');
	} 
	
	var pre_filter_group;
	import_filter_tree_onedit = function(state, id, tree, value) {
		var tree_level = import_filters.import_filter_tree.getLevel(id);
		if (tree_level > 1) {
			return false;
		}
		if (state == 0) {
			pre_filter_group = import_filters.import_filter_tree.getItemText(id);
		}
		
		if (state == 3 && id != -1) {
			var filter_group = import_filters.import_filter_tree.getItemText(id);
			var data = {
				"action": "spa_ixp_import_filter",
				"flag": "rename_filter_group",
				"rules_id": rules_id,
				"filter_group": filter_group,
				"data_source_type": data_source,
				"process_id": process_id,
				"pre_filter_group": pre_filter_group
			};
			adiha_post_data('alert', data, '', '', '', '', '');
		}
		return true;
	}


</script>
