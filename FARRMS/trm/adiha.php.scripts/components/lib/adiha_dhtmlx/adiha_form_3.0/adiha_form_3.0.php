<?php
/**
 *  @brief AdihaForm
 *  @note From now on, on this document AdihaForm will refers to this class  
 *  
 *  @par Description
 *  This class is used to create form according to DHTMLX standard.
 *  This also contains function to attach events, attatch components, post data etc.
 *  @par Usage:
 *  <pre> 
 *  {@code 
 *  $form_obj = new AdihaForm()
 *  echo $form_obj->init_form(<HTML_OBJECT>, <FORM_JSON>);
 *  echo $form_obj->close_form();
 *  }
 *  </pre>
 * @author: Laxmi Hari Nepal <lnepal@pioneersolutionsglobal.com>, Achyut Khadka <akhadka@pioneersolutionsglobal.com>
 * @version: 3.0
 * @date: Created on 2014-12-22
 * @copyright: Pioneer Solutions.
 */
class AdihaForm {

    public $form_name = false;
    public $name_space = false;

    /**
     * [initializes script resources required to form]
     * @param [string] $form_name [is name of form]
     * @return [string] $html_str [return js resource for form element]
     */
    private function init_script() {
        global $app_php_script_loc, $app_adiha_loc;

        $html_string = '';
        $html_string .= "<script type='text/javascript'>";
        return $html_string;
    }

    /**
     * [initializes form.]
     * @param [string] $form_container [div id which contains form]
     * @param [string] $form_structure [is the json form structure]
     * @param [string] $form_name [is the name of the form]
     * @return [string] $html_string [creates and return DHTMLX form object]
     */
    function init_form($form_container, $form_structure, $form_name, $namespace) {
        $this->name_space = $namespace;
        $this->form_name = $this->name_space . '.' . $form_name;
        $html_string = $this->init_script();
        $html_string .= "var " . $this->form_name . " = new dhtmlXForm('" . $form_container . "', $form_structure);";
        $html_string .= $this->close_form();

        return $html_string;
    }

    /**
     * Close script tag]
     */
    function close_form() {
        $html_string = "</script>";
        return $html_string;
    }

    /**
     * [sets the form name]
     * @param [string] $form_name  [form name to be attached]
     */
    function init_by_attach($form_name, $namespace) {
        $this->name_space = $namespace;
        $this->form_name = $this->name_space . '.' . $form_name;
        return;
    }

    /**
     * [returns the value of an input field]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @return [string] $html_string      [create and return DHTMLX form input value get function]
     */
    function get_input_value($dhtmlx_form_obj, $input_name) {
        $html_string = $dhtmlx_form_obj . '.' . "getItemValue('$input_name');";
        return $html_string;
    }
    
    /**
     * [sets the value of an input field]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @param [string] $input_value [is the value of input field]
     * @return [string] $html_string      [create and return DHTMLX form input value set function]
     */
    function set_input_value($dhtmlx_form_obj, $input_name, $input_value) {
        $html_string = $dhtmlx_form_obj . '.' . "setItemValue('$input_name', '$input_value');";
        return $html_string;
    }
    
    /**
     * [sets the calendar date format]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @param [date] $date_format [is the format of date]
     * @param [date] $server_date_format [is the format of date]
     * @return [string] $html_string      [create and return DHTMLX form set calendar format function]
     */
    function set_calendar_date_format($dhtmlx_form_obj, $input_name, $date_format, $server_date_format) {
        $html_string = $dhtmlx_form_obj . '.' . "setCalendarDateFormat('$input_name', '$date_format', '$server_date_format');";
        return $html_string;
    }
    
    /**
     * [returns the dhtmlx function to get combo value]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @return [string] $html_string      [create and return DHTMLX form combo value get function]
     */
    function get_combo_value($dhtmlx_form_obj, $combo_name) {
        $html_string = $dhtmlx_form_obj . '.' . "getCombo('$combo_name');";

        return $html_string;
    }

    /**
     * [returns select/multiselect value]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @return [string] $html_string      [DHTMLX form combo value get function]
     */
    function get_select_value($dhtmlx_form_obj, $select_name) {
        $html_string = $dhtmlx_form_obj . '.' . "getOptions('$select_name');";

        return $html_string;
    }

    /**
     * [returns the dhtmlx function to get checkbox value]
     * @param [string] $dhtmlx_form_obj [is the dhtmlx form object]
     * @param [string] $input_name [is the name of input field]
     * @return [string] $html_string      [create and return DHTMLX form checkbox value get function]
     */
    function get_checkbox_value($dhtmlx_form_obj, $checkbox_name) {
        $html_string = $dhtmlx_form_obj . '.' . "getCheckedValue('$checkbox_name');";

        return $html_string;
    }

    /**
     * [attach_form Attach form to a cell in layout]
     * @param  [type] $form_name [Form Name]
     * @param  [type] $cell      [Cell id]
     */
    function attach_form($layout_name, $cell) {
        $html_string = $this->form_name . " = " . $this->name_space . "." . $layout_name . ".cells('" . $cell . "').attachForm();" . "\n";
        return $html_string;
    }
    /**
     * [Loads form]
     * @param [string] $form_json [JSON form structure]
     */
    function load_form($form_json, $callback_function = '') {
        $dhtmlx_date_format = get_dhtmlx_date_format();
        
        if (isset($dhtmlx_date_format)) {
            //set dateFormat and serverDate,
            $dhtmlx_date_formatted = "{type: 'calendar', dateFormat: '" . $dhtmlx_date_format . "', serverDateFormat: '%Y-%m-%d',";
            $dt_form_json = str_replace("{type: 'calendar',", $dhtmlx_date_formatted, $form_json);
        } else {
            $dt_form_json = $form_json;
        }

        $call_back_func = '';
        if ($callback_function != '') {
            $call_back_func = ', function() { ';
            $call_back_func .=      $callback_function;
            $call_back_func .= '}';
        }
        
        $html_string .= $this->form_name . ".load(" . $dt_form_json . $call_back_func . "); "  . "\n";
        
        //$html_string .= $this->set_filter_dependent_combos();       
        
        return $html_string;
    }
    
    private function set_filter_dependent_combos() {
         $html_string .= " dependent_combos = {}; " . $this->form_name . "
            .forEachItem(function(name){                
                if (". $this->form_name . ".getUserData(name, 'is_dependent') == 1) {                   
                    dependent_combos[name] = ". $this->form_name . ".getCombo(name);
                    dependent_combos[name].attachEvent('onXLE', function(){
                        var field_value = ". $this->form_name . ".getUserData(name, 'filter_values');                        
                        if (field_value != '') {
                            if (". $this->form_name . ".getUserData(name, 'default_format') == 'm') {       
                                var selected_values = field_value.split(',');                  
                                selected_values.forEach(                               
                                    function(value) {                                          
                                        if (value != '') {                                            
                                            dependent_combos[name].setChecked(dependent_combos[name].getIndexByValue(value), true);                                            
                                        }
                                    }
                                );
                            } else {
                                dependent_combos[name].setComboValue(field_value);
                            }
                        }
                        
                        ". $this->form_name . ".setUserData(name, 'filter_values', '');                        
                    });
                }" . 
            "});" . "\n";            
            return $html_string;
    }
  
    
    /**
     * [sets skin]
     * @param [string] $skin_name [Name of a skin]
     */
    function set_skin($skin_name) {
        $html_string = $this->form_name . ".setSkin('" . $skin_name . "');" . "\n";
        return $html_string;
    }

    /**
     * [enables the specified item]
     * @param [string] $item_id [id of an item to enable]
     */
    function enable_item($item_id) {
        $html_string = $this->form_name . ".enableItem('" . $item_id . "');" . "\n";
        return $html_string;
    }

    /**
     * [disables the specified item]
     * @param [string] $item_id [id of an item to disable]
     */
    function disable_item($item_id) {
        $html_string = $this->form_name . ".disableItem('" . $item_id . "');" . "\n";
        return $html_string;
    }

    /**
     * [hides the specified item]
     * @param [string] $item_id [id of an item to hide]
     */
    function hide_item($item_id) {
        $html_string = $this->form_name . ".hideItem('" . $item_id . "');" . "\n";
        return $html_string;
    }

    /**
     * [adds any user-defined handler to available events]
     * @param [string] $event_id [variable name to store event]
     * @param [string] $event_name [name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxtoolbar_events.html]
     * @param [string] $event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
     */
    function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
            $html_string = $this->form_name . ".attachEvent('" . $event_name . "', $event_function);" . "\n";
        } else {
            $html_string = "var " . $event_id . "=" . $this->form_name . ".attachEvent('" . $event_name . "', $event_function);" . "\n";
        }
        return $html_string;
    }

    /**
     * [destructor, unloads toolbar]
     * @param [string] $form_name [dhtmlx form object]
     */
    function unload($form_name) {
        $html_string = $form_name . ".unload();" . "\n";
        $html_string .= $form_name . " = null;";
        return $html_string;
    }

    /**
     * [detach event]
     * @param [string] $event_id [event id]
     */
    function detach_event($event_id) {
        $html_string = $this->form_name . ".detachEvent('" . $event_id . "');" . "\n";
        return $html_string;
    }

    /**
     * [validates form]
     * @param [string] $form_name [dhtmlx form object
     */
    function form_validate($form_name) {
        $html_string = $form_name . ".validate();" . "\n";
        return $html_string;
    }

    /**
     * [set input validation rule]
     * @param [string] $form_name [dhtmlx form object]
     * @param [string] $input_name [name of the input field]
     * @param [string] $rule [validation rule i.e. ValidInteger, text etc.]
     */
    function set_validate_rule($form_name, $input_name, $rule) {
        $html_string = $form_name . ".setValidation(" . $input_name . ", '" . $rule . "' );" . "\n";
        return $html_string;
    }

    /**
     * [returns a hash of data values]
     * @param [string] $form_name [dhtmlx form object]
     */
    function get_hash_form_data($form_name) {
        $html_string = $form_name . ".getFormData();" . "\n";
        return $html_string;
    }

    /**
     * [returns dhtmlxForm instance]
     * @param [string] $form_name [dhtmlx form object]
     */
    function get_form_instance($form_name) {
        $html_string = $form_name . ".getForm();" . "\n";
        return $html_string;
    }

    /**
     * [locks the form (disables all the items)]
     * @param [string] $form_name [dhtmlx form object]
     */
    function form_lock($form_name) {
        $html_string = $form_name . ".lock();" . "\n";
        return $html_string;
    }

    /**
     * [unlocks the form (disables all the items)]
     * @param [string] $form_name [dhtmlx form object]
     */
    function form_unlock($form_name) {
        $html_string = $form_name . ".unlock();" . "\n";
        return $html_string;
    }

    /**
     * [resets the items of the form saved by means of the load or save methods to their initial states]
     * @param [string] $form_name [dhtmlx form object]
     */
    function form_reset($form_name) {
        $html_string = $form_name . ".reset();" . "\n";
        return $html_string;
    }

    /**
     * [sets the keyboard focus on the specified item]
     * @param [string] $form_name [dhtmlx form object]
     * @param [string] $input_name [input field name]
     */
    function set_item_focus($form_name, $input_name) {
        $html_string = $form_name . ".setItemFocus(" . $input_name . ");" . "\n";
        return $html_string;
    }

    /**
     * [adds the note block under the specified input]
     * @param [string] $form_name [dhtmlx form object]
     * @param [string] $input_name [input field name]
     */
    function set_item_note($form_name, $input_name, $note_text, $width = 300) {
        $html_string = $form_name . ".setNote(" . $input_name . ",
						{
							text: '" . $note_text . "',
							width: " . $width . "
						});" . "\n";

        return $html_string;
    }

    /**
     * [ method to Bind the Form to the Grid]
     * @param [string] $form_name [dhtmlx form object]
     * @param [string] $grid_row [rows of grid to bind data on form]
     */
    function data_bind_to_form($form_name, $grid_row) {
        $html_string = $form_name . ".bind(" . $grid_row . ");" . "\n";
        return $html_string;
    }

    /**
	 * [ Filling the form with custom data feed]
	 * @param [string] $form_name [dhtmlx form object]
	 * @param [string] $xml_data [xml data to load in form]
	 */
	function form_custom_data_feed($form_name, $xml_data) {
		$html_string = $form_name . ".load('" . $xml_data . "');" . "\n";
		return $html_string;
	}

    /** 
	 * [Creates and returns json to be used for form dynamic combo.]
	 * @param [string] $sp_url [URL to be executed]
	 * @param [integer] $value_index [Index of the value]
	 * @param [integer] $text_index   [Index of the text]
	 * @return dropdown options with value in object format to be used in combo attached to grid.
	 */
	function adiha_form_dropdown($sp_url, $value_index = 0, $text_index = 1, $first_blank = false, $selected_value = '', $state_index = '') {
	    $arr = readXMLURL($sp_url);
	    $_dropdown = array();
	    $option = '';
        
        if ($first_blank) {
            $option .= '{text:"", value:"", state:""}';
            array_push($_dropdown, $option);
        }
                    
	    for ($i = 0; $i < sizeof($arr); $i++) {
            if ($selected_value != '' && $arr[$i][$value_index] == $selected_value) {
                $selected = ' ,"selected":"true"';
            } else {
                $selected = '';
            }
	        $option ='{text:"' . addslashes($arr[$i][$text_index]) . '",value:"' . addslashes($arr[$i][$value_index]) . '"' . $selected . '';
            if ($state_index != '')
                $option .= ', state:"' . addslashes($arr[$i][$state_index]) . '"';
            $option .= '}';
            array_push($_dropdown, $option);
	    }

	    $_dropdown_string = "[" . implode(',', $_dropdown) . "]";
	    return ($_dropdown_string);
	}

    /**
     * [Creates static dropdown boxes.]
     * @param [string] $name Name of input element.
     * @param [string] $combo_label is the label for combo input element.
     * @param [string] $value_array option value array.
     * @param [string] $label_array option text array.
     * @param [mix] $default_value Default value for combo.
     * @param [int] $count Number of options.
     * @param [string] $on_change_event Function name for option change.
     * @param [string] $first_blank_value.
     * @param [bool] $is_enabled is flag for enable/disable combo box.
     * @param [string] $excluded_values excluded values in dropdown option.
     * @return [string] $html_str [html for dropdown]
     */

    function create_static_combo_box($value_array, $label_array, $default_value = '', $no_of_item = '', $first_blank = false) {        
        $option = array();
        if ($no_of_item == '') $no_of_item = count($value_array);

        if ($first_blank) {
            $text = '{text:"", value:""}';
            array_push($option, $text);
        }
		
        for ($i = 0; $i < $no_of_item; $i++) { 
            $text = "{value: '".$value_array[$i]."', text: '".$label_array[$i]."'";
            
            if($default_value === $value_array[$i]) {
                $text .= " , selected: true";    
            }
            
            $text .= "}";
            array_push($option, $text);
        }

        $html_str = "[" . implode(',', $option) . "]";
        
        return $html_str;
    }

    /**
     * [posts form data] along with validation.
     * @param [string] $button_name [name of button]
     * @param [string] $sp_name [name of stored procedure]
     * @return [string] $html_string [returns dhtmlx form send scripts]
     */
    function post_form_data($button_name, $sp_name, $form_name, $flag) {
        global $app_php_script_loc;

        $html_string = "var status=" . $form_name . ".validate(); var phpScriptLoc = '" . $app_php_script_loc . "'; " . "\n ";
        $html_string .= $form_name . ".send( phpScriptLoc + 'form_process.php?action=$sp_name&flag=$flag', 'post', function(loader, response){show_messagebox(response);});";
        $html_string .= "" . "\n";
        return $html_string;
    }

    /*
     * [sets the mode when validation is invoked just after an input goes out of focus]
     */
    function set_live_validation(){
        $html_string='';
        $html_string.=$this->form_name.'.enableLiveValidation(true)';
        return $html_string;
    }

    function attach_dependent_combos($parent_column, $dep_column, $callback_function = '', $has_blank_option = 'n') {
        global $app_php_script_loc;
        $html_string = ' dhx' . $parent_column . ' = ' . $this->form_name . '.getCombo("' . $parent_column . '"); '. "\n"; 
        $html_string .= 'dhx' . $dep_column . ' = ' . $this->form_name . '.getCombo("' . $dep_column . '"); '. "\n"; 
        
        $html_string .= '  default_format = ' . $this->form_name . '.getUserData("' . $parent_column . '", "default_format");' ."\n";
        $html_string .= ' if (default_format == "") {'. "\n";        
        $html_string .= '   dhx' . $parent_column . '.attachEvent("onChange", function(value){'. "\n";
        
        $html_string .= '   dhx' . $dep_column .'.clearAll();' . "\n";
        
        $html_string .= '   application_field_id = ' . $this->form_name . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
        $html_string .= '   url = "' . $app_php_script_loc . 'dropdown.connector.php?has_blank_option='.$has_blank_option.'&call_from=dependent&value="+value+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
        $html_string .= '   dhx' . $dep_column .'.load(url, function(){' . "\n";
        
        if ($callback_function != '') {
            $html_string .=         $callback_function . '("' . $parent_column . '", "' . $dep_column . '");' . "\n";
        } else {
            $html_string .= '   dhx' . $dep_column .'.setComboValue(null);' . "\n";
            $html_string .= '   dhx' . $dep_column .'.setComboText(null);' . "\n";
        }
        
        $html_string .= '    });' . "\n";
        $html_string .= '});'. "\n";
        $html_string .= '} else if(default_format == "m") {'. "\n";
        $html_string .= '   dhx' . $parent_column . '.attachEvent("onChange", function(){'. "\n";
        $html_string .= '   parent_value_ids = dhx' . $parent_column .'.getChecked().join(",");' . "\n";
        $html_string .= '   parent_value_ids = parent_value_ids.indexOf(",") == 0 ? parent_value_ids.substring(1, parent_value_ids.length) : parent_value_ids ' . "\n";
        $html_string .= '   dhx' . $dep_column .'.clearAll();' . "\n";
        $html_string .= '   dhx' . $dep_column .'.setComboValue(null);' . "\n";
        $html_string .= '   dhx' . $dep_column .'.setComboText(null);' . "\n";
        $html_string .= '   application_field_id = ' . $this->form_name . '.getUserData("' . $dep_column . '", "application_field_id");' ."\n";
        $html_string .= '   url = "' . $app_php_script_loc . 'dropdown.connector.php?has_blank_option='.$has_blank_option.'&call_from=dependent&value="+parent_value_ids+"&application_field_id="+application_field_id+"&parent_column=' . $parent_column . '";' ."\n";
        $html_string .= '   dhx' . $dep_column .'.load(url);' . "\n";
        $html_string .= '});'. "\n";
        $html_string .= '};'. "\n";
        return $html_string;
    }
    
    function create_multi_select_box($form_name, $sp_url_from, $input_from_name, $input_from_label = 'From', $sp_url_to, 
                                    $input_to_name, $input_to_label = 'To', $container_name, $labelWidth = 160, $inputWidth = 160, $labelHeight = 20, $size = 8) {
        $sp_url_from = adiha_form_dropdown($sp_url_from, 0, 1);
        
        //$sp_url_to = adiha_form_dropdown($sp_url_from, 0, 1);
                
        $html_string = " <script>
                        var $form_name;
                        var formData = [
            			{type: 'settings', position: 'label-top', labelWidth: $labelWidth, inputWidth: $inputWidth, labelHeight: $labelHeight},
            			{type: 'multiselect', label: '$input_from_label', name: '$input_from_name', size: $size, options:
            				$sp_url_from
            			},
            			{type: 'newcolumn'},
            			{type: 'block', list:[
            				{type: 'button', name: 'add', value: '>>', offsetLeft: 25, offsetTop: 60},
            				{type: 'button', name: 'remove', value: '<<', offsetLeft: 25}
            			]},
            			{type: 'newcolumn'},
            			{type: 'multiselect', label: '$input_to_label', name: '$input_to_name', size: $size, options:
				            []
            			}
            		];
                    
                    $form_name = new dhtmlXForm('$container_name', formData);
            		
                    $form_name.attachEvent('onButtonClick', function(name){
                        if (name == 'add' || name == 'remove') {
    		   				   changeContactState(name=='add', '$input_from_name', '$input_to_name', '$form_name');
            			};
            		});
                    
                    $('#$container_name').dblclick(function() {
                        //var clickedElement = this;
                        //alert(this.id);
                         //  changeContactState('add', '$input_from_name', '$input_to_name', '$form_name');
                	});
                    
                    
              </script>
        ";
        return $html_string;
    }
    
    function json_multi_select_box($sp_url_from, $input_from_name, $input_from_label = 'From', $sp_url_to, 
                                    $input_to_name, $input_to_label = 'To', $container_name, $labelWidth = 160, $inputWidth = 160, $labelHeight = 20, $size = 8) {
        $sp_url_from = adiha_form_dropdown($sp_url_from, 0, 1);
        
        $sp_url_to = adiha_form_dropdown($sp_url_from, 0, 1);
                
        $html_string = " {type: 'settings', position: 'label-top', labelWidth: $labelWidth, inputWidth: $inputWidth, labelHeight: $labelHeight},
            			{type: 'multiselect', label: '$input_from_label', name: '$input_from_name', size: $size, options:$sp_url_from},
            			{type: 'newcolumn'},
            			{type: 'block', list:[
            				{type: 'button', name: 'add', value: '>>', offsetLeft: 25, offsetTop: 60},
            				{type: 'button', name: 'remove', value: '<<', offsetLeft: 25}
            			]},
            			{type: 'newcolumn'},
            			{type: 'multiselect', label: '$input_to_label', name: '$input_to_name', size: $size, options:$sp_url_to}
            		
                    
              </script>
        ";
        return $html_string;
    }
    
    function swap_multi_box_entity() {
        $html_string = " <script>
        function changeContactState(block, from, to, form_name) {
            
                var form_name = form_name;
                var ida = (block ? from : to);
                var idb = (block ? to : from);
        		var sa = eval(form_name + '.getSelect(ida)');
                var sb = eval(form_name + '.getSelect(idb)');
                var t = eval(form_name + '.getItemValue(ida)');
        		
                if (t.length == 0) return;
        		eval('var k={'+t.join(':true,')+':true};');
        		
        		var w = 0;
        		var ind = -1;
        		while (w < sa.options.length) {
        			if (k[sa.options[w].value]) {
        				sb.options.add(new Option(sa.options[w].text,sa.options[w].value));
        				sa.options.remove(w);
        				ind = w;
        			} else {
        				w++;
        			}
        		}
        		
        		if (sa.options.length > 0 && ind >= 0) {
        			if (sa.options.length > 0) sa.options[t.length>1?0:Math.min(ind,sa.options.length-1)].selected = true;
        		}
        	}
         </script>
         ";
         return $html_string;  
    }
    
    
    function load_form_filter($form_namespace, $form_name, $layout_name, $cell, $function_id, $report_type) {
       $html_string = " 
                        var apply_filter_obj = " . $form_namespace ."." . $form_name.".getForm();
                        var layout_cell_obj = " . $form_namespace ."." . $layout_name. ".cells('$cell');                         
                        load_form_filter(apply_filter_obj, layout_cell_obj, $function_id, $report_type);
                           
                        ";
        
        
        return $html_string;  
    } 
}
?>