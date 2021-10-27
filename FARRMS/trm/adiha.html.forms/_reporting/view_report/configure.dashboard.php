<?php
/**
* Configure dashboard screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../adiha.php.scripts/components/include.file.v3.php'); 
        require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>
</head>
<body>
	<?php 
		$dashboard_id = get_sanitized_value($_GET['dashboard_id'] ?? '');
		$dashboard_id = ($dashboard_id != '') ? $dashboard_id : 'NULL';

		$form_namespace = 'configureDashboard';
		global $image_path;

		$layout_obj = new AdihaLayout();
    	$layout_json = '[{id: "a", header:false, text:"View", height:150}, {id: "b", header:true, text:"Layout"}]';
        echo $layout_obj->init_layout('pivot_template', '', '2E', $layout_json, $form_namespace);

        $page_toolbar_json = '[
	    	{id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", enabled:true, text:"Save", title: "Save"}
	    ]';

	    $sp_db = "EXEC spa_pivot_report_dashboard @flag='s', @dashboard_id=" . $dashboard_id;
	    $db_data = readXMLURL2($sp_db);
	    $layout_pattern = ($db_data[0]['layout_format'] ?? '');
	    $dashboard_name = ($db_data[0]['dashboard_name'] ?? '');
	    $mins = ($db_data[0]['mins'] ?? '');
	    $secs = ($db_data[0]['secs'] ?? '');
	    $category_id = ($db_data[0]['category'] ?? '');
	    $is_public = ($db_data[0]['is_public'] ?? '');

	    if ($is_public == '') {
	    	$is_public = 'false';
	    }
	    
	    $pattern_data = array();
	    if (is_array($db_data) && sizeof($db_data) > 0) {
	        foreach ($db_data as $data) {           
	            if ($data['cell_id']) {
	                if (!isset($pattern_data[$data['cell_id']]))
	                    $pattern_data[$data['cell_id']] = array();

	                array_push($pattern_data[$data['cell_id']], $data['report_id'], $data['width'], $data['height']);
	            }
	        }
	    }
	    $pattern_data_json = json_encode($pattern_data);

	    $page_toolbar = new AdihaToolbar();
	    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
	    echo $page_toolbar->init_by_attach('toolbar', $form_namespace);
	    echo $page_toolbar->load_toolbar($page_toolbar_json);
	    echo $page_toolbar->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

        $dashboard_form = new AdihaForm();

        $dashboard_form_name = 'form';
    	echo $layout_obj->attach_form($dashboard_form_name, 'a');

    	$time_value = range(0, 59);
    	$time_data = $dashboard_form->create_static_combo_box($time_value, $time_value, '', '', true);

    	$sp_url_category = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 104700";
		$category = $dashboard_form->adiha_form_dropdown($sp_url_category, 0, 1, true, $category_id);

	    $form_json = '[ 
	                    {"type": "settings", "position": "label-top"},
	                    {type:"block", "offsetLeft":0, list:[
		                    {type: "input", "offsetTop":10, inputWidth:'.$ui_settings['field_size'].', "userdata":{"validation_message":"Required Field"}, "name":"name", label: "Name", required:true, disabled:"false", value:"' . $dashboard_name . '"},
		                    {type: "checkbox", position: "label-right", "labelWidht":'.$ui_settings['field_size'].', "inputWidth":'.$ui_settings['field_size'].', "name":"is_public", label: "Public", checked:' . $is_public . '},
		                    {"type":"newcolumn"},
		                    {type:"combo", "offsetTop":10, "labelWidth":'.$ui_settings['field_size'].', comboType:"image", "inputWidth":'.$ui_settings['field_size'].', "offsetLeft":'.$ui_settings['offset_left'].', name: "pattern", label:"Layout Pattern", "userdata":{"validation_message":"Required Field"},  required:true, filtering:true,  options: [
								{value: "1c", img: "' .  $image_path . 'dhxcombo_web/1c.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "1C"},
								{value: "2e", img: "' .  $image_path . 'dhxcombo_web/2e.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/2e.bmp", text: "2E"},
								{value: "2u", img: "' .  $image_path . 'dhxcombo_web/2u.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/2u.bmp", text: "2U"},
								{value: "3e", img: "' .  $image_path . 'dhxcombo_web/3e.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3e.bmp", text: "3E"},
								{value: "3j", img: "' .  $image_path . 'dhxcombo_web/3j.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3j.bmp", text: "3J"},
								{value: "3l", img: "' .  $image_path . 'dhxcombo_web/3l.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3l.bmp", text: "3L"},
								{value: "3t", img: "' .  $image_path . 'dhxcombo_web/3t.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3t.bmp", text: "3T"},
								{value: "3u", img: "' .  $image_path . 'dhxcombo_web/3u.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3u.bmp", text: "3U"},
								{value: "3w", img: "' .  $image_path . 'dhxcombo_web/3w.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/3w.bmp", text: "3W"},
								{value: "4a", img: "' .  $image_path . 'dhxcombo_web/4a.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4a.bmp", text: "4A"},
								{value: "4c", img: "' .  $image_path . 'dhxcombo_web/4c.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4c.bmp", text: "4C"},
								{value: "4e", img: "' .  $image_path . 'dhxcombo_web/4e.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4e.bmp", text: "4E"},
								{value: "4f", img: "' .  $image_path . 'dhxcombo_web/4f.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4f.bmp", text: "4F"},
								{value: "4g", img: "' .  $image_path . 'dhxcombo_web/4g.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4g.bmp", text: "4G"},
								{value: "4h", img: "' .  $image_path . 'dhxcombo_web/4h.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4h.bmp", text: "4H"},
								{value: "4i", img: "' .  $image_path . 'dhxcombo_web/4i.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4i.bmp", text: "4I"},
								{value: "4j", img: "' .  $image_path . 'dhxcombo_web/4j.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4j.bmp", text: "4J"},
								{value: "4l", img: "' .  $image_path . 'dhxcombo_web/4l.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4l.bmp", text: "4L"},
								{value: "4t", img: "' .  $image_path . 'dhxcombo_web/4t.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4t.bmp", text: "4T"},
								{value: "4u", img: "' .  $image_path . 'dhxcombo_web/4u.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/4u.bmp", text: "4U"},
								// These layouts are not supported/tested, hence hide them.
								// {value: "5h", img: "' .  $image_path . 'dhxcombo_web/5h.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5H"},
								// {value: "5i", img: "' .  $image_path . 'dhxcombo_web/5i.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5I"},
								 {value: "5u", img: "' .  $image_path . 'dhxcombo_web/5u.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5U"},
								// {value: "5e", img: "' .  $image_path . 'dhxcombo_web/5e.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5E"},
								// {value: "5w", img: "' .  $image_path . 'dhxcombo_web/5w.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5W"},
								// {value: "5k", img: "' .  $image_path . 'dhxcombo_web/5k.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5K"},
								// {value: "5s", img: "' .  $image_path . 'dhxcombo_web/5s.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5S"},
								// {value: "5g", img: "' .  $image_path . 'dhxcombo_web/5g.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5G"},
								// {value: "5c", img: "' .  $image_path . 'dhxcombo_web/5c.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "5C"},
								// {value: "6h", img: "' .  $image_path . 'dhxcombo_web/6h.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6H"},
								// {value: "6i", img: "' .  $image_path . 'dhxcombo_web/6i.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6I"},
								// {value: "6a", img: "' .  $image_path . 'dhxcombo_web/6a.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6A"},
								// {value: "6c", img: "' .  $image_path . 'dhxcombo_web/6c.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6C"},
								// {value: "6j", img: "' .  $image_path . 'dhxcombo_web/6j.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6J"},
								// {value: "6e", img: "' .  $image_path . 'dhxcombo_web/6e.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6E"},
								// {value: "6w", img: "' .  $image_path . 'dhxcombo_web/6w.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "6W"},
								// {value: "7h", img: "' .  $image_path . 'dhxcombo_web/7h.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "7H"},
								// {value: "7i", img: "' .  $image_path . 'dhxcombo_web/7i.bmp", img_dis: "' .  $image_path . 'dhxcombo_web/1c.bmp", text: "7I"}
							]},
							{"type":"newcolumn"},
							{type:"combo", "offsetTop":10, "labelWidth":'.$ui_settings['field_size'].', "inputWidth":'.$ui_settings['field_size'].', "offsetLeft":'.$ui_settings['offset_left'].', name: "category", label:"Category", filtering:true, "options": ' . $category . '},
							{"type":"newcolumn"},
	                    	{type: "fieldset", label: "Auto Refresh", "offsetLeft":'.$ui_settings['offset_left'].', "offsetTop":0, inputWidth: 175, "inputLeft ": "10", "inputTop": "0", list:[
								{type:"combo", "labelWidth":"auto", "inputWidth":50,"offsetLeft":5, name: "mins", position:"label-right", label:"min", filtering:true, "options":' . $time_data . '},
								{"type":"newcolumn"},
								{type:"combo", "labelWidth":"auto", "inputWidth":50, "offsetLeft":5, name: "secs", position:"label-right", label:"sec",  filtering:true, "options":' . $time_data . '}
							]}

	                    ]}
	                ]';

	    $dashboard_form->init_by_attach($dashboard_form_name, $form_namespace);
	    echo $dashboard_form->load_form($form_json);    
	    echo $dashboard_form->attach_event('', 'onChange', $form_namespace . '.form_change');


	    $tab_obj = new AdihaTab();
	    $tab_json = '[
	    	{id:"design", text:"Design", active:true},
	    	{id:"params", text:"Parameters"}
	    ]';

	    echo $layout_obj->attach_tab_cell('dbtab', 'b', $tab_json);
	    echo $tab_obj->init_by_attach('dbtab', $form_namespace);
	    echo $tab_obj->set_tab_mode('bottom');

	    $sp_url = "EXEC spa_pivot_report_view @flag = 'v', @report_type = 1";
    	$report_dropdown_json = $dashboard_form->adiha_form_dropdown($sp_url, 0, 1, true);

	    $report_form_json = '[
			{"type": "settings", "position": "label-top", "offsetLeft": 10},
			{type:"block", "blockOffset":0, list:[
				{type:"combo", "labelWidth":200, "inputWidth":200, name: "report", label:"Pivot Report", "userdata":{"validation_message":"Required Field"},  required:true, filtering:true, options:' . $report_dropdown_json . '},
				{"type":"newcolumn"},
				{"type": "input", "labelWidth":200, disabled:true, "inputWidth":200, "name":"width", "validate":"ValidPercentage", label: "Width %"},
				{"type":"newcolumn"},
                {"type": "input", "labelWidth":200, disabled:true, "inputWidth":200, "name":"height", "validate":"ValidPercentage", label:"Height %"}
			]}
		]';

		echo $tab_obj->attach_form_cell('param_form', 'params');

		/*
	    $param_grid = new GridTable('dashboard_params');
	    $param_grid->enable_connector();
	    echo $param_grid->init_grid_table('grid', $form_namespace, 'n');
	    echo $param_grid->return_init();
	    echo $param_grid->attach_event('', 'onEditCell', $form_namespace . '.grid_edit');
		*/
	
	    //echo $tab_obj->attach_event('', 'onTabClick', $form_namespace . '.load_paramset');

        echo $layout_obj->close_layout();
	?>
</body>
<textarea style="display:none" name="txt_save_status" id="txt_save_status">cancel</textarea>
<textarea style="display:none" name="txt_new_id" id="txt_new_id"></textarea>

<script type="text/javascript">
	var image_path = '<?php echo $image_path;?>';
	var last_selected_pattern = '';
	var previous_data = new Array();
	var first_load = true;
	var layout_json = {};
	var dashboard_id = '<?php echo $dashboard_id;?>';

	configureDashboard.db_layout;
	configureDashboard.form_obj = {};

	function ValidPercentage(data) {
        return (data<=100);
    }

	$(function() {
		var layout_pattern = '<?php echo $layout_pattern;?>';
		var mins = '<?php echo $mins;?>';
		var secs = '<?php echo $secs;?>';

		configureDashboard.form.setItemValue('mins', mins);
		configureDashboard.form.setItemValue('secs', secs);


		if (layout_pattern != '' && layout_pattern != null) {	
			configureDashboard.form.setItemValue('pattern', layout_pattern);
			configureDashboard.form_change('pattern', layout_pattern);
			last_selected_pattern = layout_pattern;
		} else {
			configureDashboard.form_change('pattern', '1c');
			last_selected_pattern = '1c';
		}
	})

	configureDashboard.toolbar_click = function(id) {
		if (id == 'save') {
			if (configureDashboard.db_layout) {		
				var status = validate_form(configureDashboard.form);
				
				if (!status) return;
				
				var error_message = false;
				var layout_pattern = configureDashboard.form.getItemValue('pattern');
				var dashboard_name = configureDashboard.form.getItemValue('name');
				var category = configureDashboard.form.getItemValue('category');
				var mins = configureDashboard.form.getItemValue('mins');
				var secs = configureDashboard.form.getItemValue('secs');
				var is_public = configureDashboard.form.getItemValue("is_public");

				mins = (mins == '') ? "NULL": mins;
				secs = (secs == '') ? "NULL": secs;
				
				var xml = '<Root>';

				configureDashboard.db_layout.forEachItem(function(cell){
				    cell.hideHeader();
				    var id = cell.getId();
				    var report = 'NULL';
				    var width = '100';
				    var height = '100';

				    if (configureDashboard.form_obj[id]) {
						var status = validate_form(configureDashboard.form_obj[id]);
						if (!status) error_message = true;
				    	report = configureDashboard.form_obj[id].getItemValue('report');
				    	width = configureDashboard.form_obj[id].getItemValue('width');
		    			height = configureDashboard.form_obj[id].getItemValue('height');
				    }
				    if (report != '')
				    	xml += '<FormXML cell_id="' + id + '" report="' + report + '" width="' + width + '" height="' + height + '"></FormXML>';
			    })

			    xml += '</Root>';
				if (error_message) return;
			    if (xml == '<Root></Root>') return;

			    var param_xml = 'NULL';

			    if (configureDashboard.param_form) {
			    	var form_data = configureDashboard.param_form.getFormData();
			    	param_xml = '<Root>';
			    	for (var a in form_data) {
						var value = form_data[a];
						var name = a;
						if (configureDashboard.param_form.getItemType(a) == 'calendar') {
							value = configureDashboard.param_form.getItemValue(a, true);
						} else {
							value = (value == null || value == 'null') ? '' : value;
						}
						param_xml += '<FormXML param_name="' + name + '" param_value="' + value + '"></FormXML>'
					}
					param_xml += '</Root>';

					param_xml = (param_xml == '<Root></Root>') ? 'NULL' : param_xml;
			    }
                param_xml = param_xml.replace("subbook_id", "sub_book_id");
			    data = {
			    	"action":"spa_pivot_report_dashboard",
	                "flag":"i",
	                "layout_format":layout_pattern,
	                "xml":xml,
	                "dashboard_id":dashboard_id,
	                "dashboard_name":dashboard_name,
	                "param_xml":param_xml,
	                "mins":mins,
	                "secs":secs,
	                "category":category,
	                "is_public":is_public
			    }
			    adiha_post_data("alert", data, '', '', 'configureDashboard.save_callback');
			}
		}
	}

	configureDashboard.save_callback = function(return_val) {
		if (return_val[0].errorcode == "Success") {
			document.getElementById("txt_save_status").value = 'save';
			if (return_val[0].recommendation != null) document.getElementById("txt_new_id").value = return_val[0].recommendation;
		}
	}

	configureDashboard.form_change = function(name, value) {
		if (name == 'pattern') {
			var patt_combo = configureDashboard.form.getCombo('pattern');
			var pattern_name = patt_combo.getComboText();
			configureDashboard.load_layout(pattern_name);
		}
	}

	configureDashboard.load_layout = function(layout_pattern) {
		configureDashboard.toolbar.disableItem('save');
		if (last_selected_pattern == layout_pattern) return;
		else last_selected_pattern = layout_pattern;

		if (configureDashboard.db_layout != null) {
			previous_data = {};
			
			configureDashboard.db_layout.forEachItem(function(cell){
				var cell_id = cell.getId();
				var form_obj = cell.getAttachedObject();

				var report_name = form_obj.getItemValue('report');
				var height = form_obj.getItemValue('height');
				var width = form_obj.getItemValue('width');
				previous_data[cell_id] = new Array(report_name, height, width);
			});

			configureDashboard.db_layout.unload();
			configureDashboard.db_layout = null;
		}

		if (first_load) {
			var pattern_data_json = '<?php echo $pattern_data_json; ?>';

		    if (pattern_data_json != '' && pattern_data_json.length != '[]') {
		        pattern_data_json = JSON.parse(pattern_data_json);

		        jQuery.each(pattern_data_json, function(i, val) {
				  	previous_data[i] = val;
				});
		    }
		}

		var form_json = <?php echo $report_form_json;?>;
		var cell_b_width = configureDashboard.pivot_template.cells('b').getWidth();
		var cell_b_height = configureDashboard.pivot_template.cells('b').getHeight();

		configureDashboard.db_layout = configureDashboard.dbtab.tabs('design').attachLayout(layout_pattern);
		configureDashboard.form_obj = {};

		configureDashboard.db_layout.forEachItem(function(cell){
		    cell.hideHeader();
		    var id = cell.getId();

		    var cell_width = Number((cell.getWidth()/cell_b_width)*100).toFixed(0);
		    var cell_height = Number((cell.getHeight()/cell_b_height)*100).toFixed(0);

		    configureDashboard.form_obj[id] = cell.attachForm(get_form_json_locale(form_json));

		    configureDashboard.form_obj[id].attachEvent('onChange', configureDashboard.detail_form_change);

		    configureDashboard.form_obj[id].setUserData("height", "cell_id", id);

		    if (previous_data[id]) {
		    	configureDashboard.form_obj[id].setItemValue('report', previous_data[id][0]);
		    }

		    if (first_load && previous_data[id]) {		    	
			    configureDashboard.form_obj[id].setItemValue('width', previous_data[id][1]);
			    configureDashboard.form_obj[id].setItemValue('height', previous_data[id][2]);
		    } else {
		    	configureDashboard.form_obj[id].setItemValue('width', cell_width);
			    configureDashboard.form_obj[id].setItemValue('height', cell_height);
		    }		    
		});

		if (first_load) {			
		    configureDashboard.resize_cells();
		    first_load = false;
		    configureDashboard.load_paramset();
		} else {
			configureDashboard.toolbar.enableItem('save');
		}

		configureDashboard.db_layout.attachEvent('onPanelResizeFinish', function(cells) {
			configureDashboard.db_layout.forEachItem(function(cell){
			    var cell_width = Number((cell.getWidth()/cell_b_width)*100).toFixed(0);
			    var cell_height = Number((cell.getHeight()/cell_b_height)*100).toFixed(0);

			    var form_obj = cell.getAttachedObject();

			    form_obj.setItemValue('width', cell_width);
			    form_obj.setItemValue('height', cell_height);
			});
	    })
		 
	}

	configureDashboard.resize_cells = function() {
		var cell_b_width = configureDashboard.pivot_template.cells('b').getWidth();
		var cell_b_height = configureDashboard.pivot_template.cells('b').getHeight();

		configureDashboard.db_layout.forEachItem(function(cell){
			var form_obj = cell.getAttachedObject();
			var height = form_obj.getItemValue('height');
			var width = form_obj.getItemValue('width');

		    var cell_width = Number((width/100)*cell_b_width).toFixed(2);
		    var cell_height = Number((height/100)*cell_b_height).toFixed(2);

		    cell.setHeight(cell_height);
		    cell.setWidth(cell_width);
		});
	}

	configureDashboard.detail_form_change = function(name, value) {
		if (name == 'report') {
			configureDashboard.load_paramset();
		}
	}


	/**
	 * [load_paramset Load Paramsets]
	 */
	configureDashboard.load_paramset = function() {
		var report_string = '';
		
		configureDashboard.db_layout.forEachItem(function(cell){
			var form_obj = cell.getAttachedObject();
			var report = form_obj.getItemValue('report');
			report_string = (report_string == '') ? report : report_string + ',' + report;
		});
		
		var data = {
	    	"action":"spa_pivot_report_dashboard",
            "flag":"z",
            "report_string":report_string,
            "dashboard_id":dashboard_id,
			"call_from": "dashboard_config"
	    }
	    adiha_post_data("return", data, '', '', 'configureDashboard.load_paramset_callback');
	}

	/**
	 * [load_paramset_callback CallBack for paramset loading]
	 */
	configureDashboard.load_paramset_callback = function(result) {
		var form_json = JSON.parse(result[0].form_json);
		var form_data = configureDashboard.param_form.getFormData();

		for (var a in form_data) {
			configureDashboard.param_form.removeItem(a);
		} 

		if (form_json && form_json != '' && form_json != null) configureDashboard.param_form.loadStruct(form_json);
		attach_browse_event('configureDashboard.param_form',-10201625); //allowed all book str to be loaded on dashboard filters as on sql based reports.

		if (form_data) {
			for (var a in form_data) {
				var value = form_data[a];
				var name = a;
				var is_present = configureDashboard.param_form.isItem(name);

				if (is_present) {
					var type = configureDashboard.param_form.getItemType(name);
					var form_obj = configureDashboard.param_form;
					var default_format = form_obj.getUserData(name,'default_format');

					if (type == 'combo' && (default_format == 'm' || default_format == 'c')) {
			            var combo_obj = form_obj.getCombo(name);
			            var value_arr = new Array();			     
			            value_arr = value.split(',');

			            var combo_count = combo_obj.getOptionsCount();

			            var checked_value = '';
			            checked_value = combo_obj.getChecked();

			            if (checked_value != '' ) {
			                
			                $.each(checked_value, function(index, value) {        
			                    combo_obj.setChecked(combo_obj.getIndexByValue(value), false); 
			                });
			            }

			            for (var j = 0, fcnt = value_arr.length; j < fcnt; j++) {
			                if (value_arr[j] != '')
			                    combo_obj.setChecked(combo_obj.getIndexByValue(value_arr[j]), true);
			            }
			            
			            var final_combo_text = new Array();
			            var checked_loc_arr = combo_obj.getChecked();

			            $.each(checked_loc_arr, function(i) {
			                var opt_obj = combo_obj.getOption(checked_loc_arr[i]);                   
			                
			                if (opt_obj.text != '')
			                    final_combo_text.push(opt_obj.text);
			            });
			            
			            combo_obj.setComboText(final_combo_text.join(','));
			        } else if (type == 'checkbox' && value == 'y') {
			            form_obj.checkItem(name);
			            is_checked = true;
			        } else if (type == 'checkbox' && value == 'n') {
			            form_obj.uncheckItem(name);
			            is_checked = false;
			        } else {
			            form_obj.setItemValue(name, value);
			        }
				}
			}
		}
		configureDashboard.toolbar.enableItem('save');
	}
</script>