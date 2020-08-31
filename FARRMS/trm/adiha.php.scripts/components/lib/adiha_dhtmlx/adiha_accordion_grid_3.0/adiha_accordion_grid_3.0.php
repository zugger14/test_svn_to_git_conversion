<?php

class AccordionGrid extends AdihaAccordion { 
    public $accordion_list_array = array();
    public $table_name;
    public $double_click_function;
    public $single_click_function;
    
    public $grid_id;
    public $grid_columns;
    public $grid_col_labels;
    public $grid_col_types;
    public $combo_fields  = array();
    public $grid_obj_name;
    public $sql_string;
    public $grouping_column;
    
    /**
     * [__construct AccordionGrid constructor - set the table name as defined in templateTables]
     * @param [string] $table_name  [table name for which grid is being constructed]
     * @param [string] $namespace   [Namespace]
     */
    function __construct($table_name) {
        $this->table_name = $table_name;
        
        $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'";
        $def = readXMLURL2($grid_def);

        $this->grid_id = $def[0][grid_id];
        $this->table_name = $def[0][grid_name];
        $this->grid_columns = $def[0][column_name_list];
        $this->grid_col_labels = $def[0][column_label_list];
        $this->grid_col_types = $def[0][column_type_list];
        $this->sql_string = $def[0][sql_stmt];
        $this->grid_type = 'a';
        $this->grouping_column = $def[0][grouping_column];

        if ($def[0][dropdown_columns] != 'NULL' && $def[0][dropdown_columns] != '')
            $this->combo_fields = explode(",", $def[0][dropdown_columns]);
    }
    
    public function init_accordion_grid($accordion_name, $namespace) {
        $return_string = parent::init_by_attach($accordion_name, $namespace);
    	$return_string .= $this->load_accordion($this->sql_string, $this->grouping_column);
        $return_string .= $this->load_accordion_grid();
    	return $return_string;
    }
    
    /**
     * [Load the data from XML and build multiple JSON for multiple grid]
     * @param [string] $grid_sp [query to return the data]
     * @param [string] $grouping_key [column name which groups the accordion]
     */
    public function load_accordion($grid_sp, $grouping_key) {
        if ($grid_sp != '') {
            $grid_array = readXMLURL2($grid_sp);
            $total_count = sizeof($grid_array);
            
            $accordion_item_array = array();
            
            foreach ($grid_array as $value) {
                $this->accordion_list_array[$value[$grouping_key]] = $value[$grouping_key];
                
                $string = $value[$grouping_key];
                if (!in_array($string, $accordion_item_array)) {
                    array_push($accordion_item_array, $string);
                } 
            }

            foreach ($this->accordion_list_array as $accordion_id) {
                $json_data = '';
                $json_data = '{"pos":"0", "data":[';
                $string_array = array();
                if (is_array($grid_array) && sizeof($grid_array) > 0) {
                    foreach ($grid_array as $js_array) {
                        if($js_array[$grouping_key] == $accordion_id) {
                            $string = '{ ';
                            $i = 0;
                            foreach ($js_array as $key => $value) {
                              if ($i == 0) {
                                $string .= '"' . $key . '":' . '"' . $value . '"';
                              } else {
                                  $string .= ',"' . $key . '":' . '"' . $value . '"';
                              }
                              $i++;
                            }
                            $string .= '}';
                            array_push($string_array, $string);
                        }
                    }
                }
                $json_data .= implode(", \n",$string_array) . ']}';
                $linked_datasource_jsoned = $json_data;
                $accordion_id = str_replace(' ', '_', $accordion_id);
                $this->accordion_list_array[$accordion_id] = $linked_datasource_jsoned;
            }
            
            $json_string = '';
            for ($i = 0; $i < count($accordion_item_array); $i++) {
                $json_string .= '{"id":"' . str_replace(' ', '_', $accordion_item_array[$i]) . '","text":"' . $accordion_item_array[$i] . '","height":"*"},';
            }
            $json_string = substr($json_string, 0, strlen($json_string)-1);
        }
        
        $accordion_json = '{items:[' . $json_string . ']}';
        $html_string = $this->accordion_name . ".loadStruct(" . $accordion_json . ");";
        return $html_string;
    }
    
    /**
     * [Initialize the multiple grid, with definition as defined in templateTables and attach it to accordion. Number of grid created = Number of accordion]
     */
    public function load_accordion_grid() {
        foreach ($this->accordion_list_array as $value) {
            $id = array_search($value, $this->accordion_list_array);
            $id = str_replace(' ', '_', $id);
            $acc_grid = new GridTable($this->table_name);
            $html_string .= $this->attach_grid_cell($id, $id);
            $html_string .= $acc_grid->init_grid_table($id, $this->name_space);
            $html_string .= $acc_grid->return_init();
            $html_string .= $acc_grid->load_grid_json($this->accordion_list_array[$id]);
            if ($this->double_click_function != '') {
                $html_string .= $this->attach_ondouble_click($id, $this->double_click_function);
            }
            if ($this->single_click_function != '') {
                $html_string .= $this->attach_onsingle_click($id, $this->single_click_function);
            }
        }
        return $html_string;
    }
    
    /**
     * Setting double click function name
     * @param [string]  $function_name  [Double click function name]
     */
    public function ondouble_click_function($function_name) {
        $this->double_click_function = $function_name;
    }
    
    /**
     * Setting single click function name
     * @param [string]  $function_name  [Single click function name]
     */
    public function onsingle_click_function($function_name) {
        $this->single_click_function = $function_name;
    }
    
    /**
     * Attach the search textbox in toolbar to filter accordion grid
     * @param [string]  $layout_name    [Layout in which search textbox is to be attached]
     * @param [string]  $layout_cell    [Layout cell in which search textbox is to be attached]
     */
    public function attach_search_textbox($layout_name, $layout_cell) {
        $search_text = 'search_toolbar';
        $search_text_json = '[
                                    {id:"search_text", type:"buttonInput", value:"Search...", title:"Search", width:"235"}
                             ]';
        $html_string = $this->filter_accordion_data();
        $html_string .= $this->name_space . "." . $search_text . " = " . $this->name_space . "." . $layout_name . ".cells('" . $layout_cell . "').attachToolbar();" . "\n";
        $html_string .= $this->name_space . "." . $search_text . ".loadStruct(". $search_text_json . ");" . "\n";
        $html_string .= 'search_obj = ' . $this->name_space . '.' . $search_text . '.getInput("search_text");' . "\n";
        
        $html_string .= 'dhtmlxEvent(search_obj, "focus", function(ev){' . "\n";
        $html_string .= '   if (search_obj.value == "Search...") {' . "\n";
        $html_string .= '       search_obj.value = "";' . "\n";
        $html_string .= '   }' . "\n";
        $html_string .= '});' . "\n";
        
        $html_string .= 'dhtmlxEvent(search_obj, "blur", function(ev){' . "\n";
        $html_string .= '   if (search_obj.value == "") {' . "\n";
        $html_string .= '       filter_data();' .  "\n";
        $html_string .= '       search_obj.value = "Search...";' . "\n";
        $html_string .= '   }' . "\n";
        $html_string .= '});' . "\n";
        
        $html_string .= 'dhtmlxEvent(search_obj, "keypress", function(ev){' . "\n";
        $html_string .= '   filter_data();' .  "\n";
        $html_string .= '});' . "\n";
        
        $html_string .= 'dhtmlxEvent(search_obj, "keyup", function(ev){' . "\n";
        $html_string .= '   filter_data();' .  "\n";
        $html_string .= '});' . "\n";   
        
        return $html_string;
    }
    
    /**
     * Function to filter the accordion 
     */
    public function filter_accordion_data() {
        $html_string = ' function filter_data() {'. "\n";
        $html_string .= '   search_obj = ' . $this->name_space . '.search_toolbar.getInput("search_text");' . "\n";
        $html_string .= '   var textbox_value = search_obj.value;'. "\n";
        
        $html_string .= '   if (textbox_value != "") {'. "\n";
        $html_string .=         $this->accordion_name . '.enableMultiMode();'. "\n";
        $html_string .= '   } else {'. "\n";
        //$html_string .=         $this->accordion_name . '.enableMultiMode();'. "\n";
        $html_string .= '   }'. "\n";
        
        $html_string .=     $this->accordion_name . '.forEachItem(function(cell){'. "\n";
        $html_string .= '       cell.show();'. "\n";
        $html_string .= '       Grid_object = cell.getAttachedObject();'. "\n";
        $html_string .= '       Grid_object.forEachRow(function(row_id) {'. "\n";
        $html_string .= '           Grid_object.setRowHidden(row_id,false);'. "\n";
        $html_string .= '       });'. "\n";
        
        $html_string .= '       if (textbox_value != "") {'. "\n";
        $html_string .= '           cell.setHeight("*"); cell.open();'. "\n";
        $html_string .= '           var value_present_in_accordion = "n";'. "\n";
        $html_string .= '           Grid_object = cell.getAttachedObject();'. "\n";
        $html_string .= '           Grid_object.forEachRow(function(row_id) {'. "\n";
        $html_string .= '               value_present_in_cell = "n";';
        $html_string .= '               for (var i=0; i< Grid_object.getColumnCount(); i++){'. "\n";
        $html_string .= '                   if (Grid_object.cells(row_id,i).getValue().toLowerCase().indexOf(textbox_value.toLowerCase()) > -1){'. "\n";
        $html_string .= '                       value_present_in_cell = "y";'. "\n";
        $html_string .= '                   }'. "\n";
        $html_string .= '               }'. "\n";
        $html_string .= '               if (value_present_in_cell != "y") {'. "\n";
        $html_string .= '                   Grid_object.setRowHidden(row_id,true);'. "\n";
        $html_string .= '               } else {'. "\n";
        $html_string .= '                   value_present_in_accordion = "y";'. "\n";
        $html_string .= '                   Grid_object.setRowHidden(row_id,false);'. "\n";
        $html_string .= '               }'. "\n";
        $html_string .= '           });'. "\n";
        $html_string .= '           if(value_present_in_accordion != "y") {'. "\n";
        $html_string .= '               cell.hide();'. "\n";
        $html_string .= '           }'. "\n";
        $html_string .= '       }'. "\n";
        $html_string .= '   });'. "\n";
        $html_string .= '}'. "\n";
        
        return $html_string;
    }
    
    /**
     * Attaching double click event for each grid in the accordion grid
     * @param [string]  $grid_name      [Grid in which event is to be attached]
     * @param [string]  $event_function [Double click function name]
     */
    public function attach_ondouble_click($grid_name, $event_function) {
        $html_string = $this->name_space . '.' . $grid_name . '.attachEvent("onRowDblClicked", function(rId,cInd){' . "\n";
        $html_string .= '   var id = ' . $this->name_space . '.' . $grid_name . '.cells(rId, 0).getValue();'. "\n";
        $html_string .= '   var name = ' . $this->name_space . '.' . $grid_name . '.cells(rId, 1).getValue();'. "\n";
        $html_string .= '   var grid_obj = ' . $this->name_space . '.' . $grid_name . "\n";
        $html_string .=     $event_function . '(id, name, grid_obj) ;'. "\n";
        $html_string .= '});' . "\n";
        return $html_string;
    }
    
    /**
     * Attaching double click event for each grid in the accordion grid
     * @param [string]  $grid_name      [Grid in which event is to be attached]
     * @param [string]  $event_function [Double click function name]
     */
    public function attach_onsingle_click($grid_name, $event_function) {
        $html_string = $this->name_space . '.' . $grid_name . '.attachEvent("onRowSelect", function(rId,cInd){' . "\n";
        $html_string .= '   var id = ' . $this->name_space . '.' . $grid_name . '.cells(rId, 0).getValue();'. "\n";
        $html_string .= '   var name = ' . $this->name_space . '.' . $grid_name . '.cells(rId, 1).getValue();'. "\n";
        $html_string .= '   var grid_obj = ' . $this->name_space . '.' . $grid_name . "\n";
        $html_string .=     $event_function . '(id, name, grid_obj) ;'. "\n";
        $html_string .= '});' . "\n";
        return $html_string;
    }
    
}
?>
