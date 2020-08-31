<?php

/**
 *  @brief GridTable.
 *  
 *  @par Description
 *  This class is used to generate grid according to the template defined in templateTables.
 *  Basic definition required to create a grid should be present in templateTables prior to the use of this class.
 *  This class is inherited from AdihaGrid, so all functionality that are supported in AdihaGrid is automatically supported for the object of this class.
 *  
 *  @copyright Pioneer Solutions
 */
class GridTable extends AdihaGrid {
    private $grid_id;
    private $table_name;
    public $grid_columns;
    public $grid_col_labels;
    private $grid_col_types;
    private $combo_fields = array();
    private $grid_obj_name;
    private $sql_string;
    private $grid_type;
    private $grouping_column;
    private $set_visibility;
    private $column_width;
    private $sorting_preference;
    private $edit_permission;
    private $delete_permission;
    private $split_at;
	private $validation_rule;
	private $user_date_format;
	private $server_date_format;
    private $column_alignment;
    public $numeric_fields;
    public $date_fields;
    public $dummy_grid;
    private $browser_fields;
    
    /**
     * Construct GridTable constructor - returns the definitions for grid as defined in templateTables.
     * @param String $table_name  Table name for which grid is being constructed
     * @param String $dummy_grid  If true only grid structure are constructed without data (e.g Form Builder)
     */
    function __construct($table_name = "", $dummy_grid = false, $audit_id = "") {
        $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'" . ($audit_id != "" ? ",@audit_id=" . $audit_id : "") . ($dummy_grid ? ",@lang_translate=0" : "");
        $def = readXMLURL2($grid_def);

        $this->grid_id = $def[0]['grid_id'];
        $this->table_name = $def[0]['grid_name'];
        $this->grid_columns = $def[0]['column_name_list'];
        $this->grid_col_labels = $def[0]['column_label_list'];
        $this->grid_col_types = $def[0]['column_type_list'];
        $this->sql_string = $def[0]['sql_stmt'];
        $this->grid_label = $def[0]['grid_name'];
        $this->grid_type = ($def[0]['grid_type'] == 't') ? 'tg' : 'g';
        $this->grouping_column = $def[0]['grouping_column'];
        $this->set_visibility = $def[0]['set_visibility'];
        $this->column_width = $def[0]['column_width'];
        $this->sorting_preference = $def[0]['sorting_preference'];
        $this->edit_permission = $def[0]['edit_permission'];
        $this->delete_permission = $def[0]['delete_permission'];
        $this->split_at = $def[0]['split_at'];
		$this->validation_rule = $def[0]['validation_rule'];
		$this->user_date_format = $def[0]['user_date_format'];
		$this->server_date_format = $def[0]['server_date_format'];
        $this->column_alignment = $def[0]['column_alignment'];
        $this->numeric_fields = $def[0]['numeric_fields'];
        $this->date_fields = $def[0]['date_fields'];
        $this->dummy_grid = $dummy_grid;
        $this->rounding_values = $def[0]['rounding_values'];
        
        if ($def[0]['dropdown_columns'] != 'NULL' && $def[0]['dropdown_columns'] != '')
            $this->combo_fields = explode(",", $def[0]['dropdown_columns']);

        if ($def[0]['browser_columns'] != 'NULL' && $def[0]['browser_columns'] != '')
            $this->browser_fields = explode(",", $def[0]['browser_columns']);
    }

    /**
     * Initialize the grid, with definition as defined in templateTables.
     * @param  String $grid_obj_name Grid Object Name
     */
    /**
     * Initialize the grid, with definition as defined in templateTables.
     * @param  String   $grid_obj_name    Grid object name
     * @param  String   $namespace        Namespace
     * @param  Boolean  $split            Set the default value as y
     * @return String                     JS to init grid table
     */
    public function init_grid_table($grid_obj_name, $namespace, $split = 'y') {
        global $SPLIT_AFTER_COLUMNS;
        $this->grid_obj_name = $grid_obj_name;
        $return_string = $this->init_by_attach($this->grid_obj_name, $namespace);
        $return_string .= $this->set_header($this->grid_col_labels, $this->column_alignment, false);
        $return_string .= $this->set_columns_ids($this->grid_columns);
        $return_string .= $this->set_column_types($this->grid_col_types);
        $return_string .= $this->set_widths($this->column_width);
        
        if (!$this->dummy_grid)
            $return_string .= $this->enable_column_move('', 'y');

        if ($split == 'y') {
            $column_array = explode(',', $this->grid_columns);
            $no_of_col = sizeof($column_array);
            $visibility_array = array();
            $visibility_array = explode(",", $this->set_visibility);
            $col_split_at = $this->split_at;
            
            $split_at = ($col_split_at == '' || $col_split_at == NULL) ? 2 : $col_split_at;
           
            if ($this->grid_type == 'tg') {
                if ($visibility_array[0] == 'true' && $visibility_array[1] == 'true' && $visibility_array[2] == 'true' || $col_split_at == '0') {
                    $should_split = 'n';
                } else if ($col_split_at != '') {
                    $should_split = 'y';
                } else{
                    $should_split = ($no_of_col >= $SPLIT_AFTER_COLUMNS) ? 'y' : 'n';
                }
            } else {
                if ($visibility_array[0] == 'true' && $visibility_array[1] == 'true' || $col_split_at == '0') {
                    $should_split = 'n';
                } else if ($col_split_at != '') {
                    $should_split = 'y';
                } else {
                    $should_split = ($no_of_col >= $SPLIT_AFTER_COLUMNS) ? 'y' : 'n';
                }
            }
 
            if ($should_split == 'y') {
                $return_string .= $this->split_grid($split_at);
            }
        }
        
        if (!$this->dummy_grid) {
            $return_string .= $this->set_sorting_preference($this->sorting_preference);
    		$return_string .= $this->set_validation_rule($this->validation_rule);
    		$return_string .= $this->set_date_format($this->user_date_format,$this->server_date_format);
        }
        
        return $return_string;
    }

    /**
     * Returns the init string and load all combos defined for particular grid in templateTables.
     * @param  String $visibility_string  Enables visibility
     * @param  String $enable_header_menu Enable menu
     * @return String                     JS to initialize grid table
     */
    public function return_init($visibility_string = '', $enable_header_menu = '', $dummy_grid = false) {
        if ($visibility_string != '') $this->set_visibility = $visibility_string;

        $return_string = parent::return_init($this->set_visibility, $enable_header_menu, $this->dummy_grid);  

        if (is_array($this->combo_fields) && sizeof($this->combo_fields) > 0 && (!$this->dummy_grid)) {
            $return_string .= $this->load_grid_combos();
        }

        if (is_array($this->browser_fields) && sizeof($this->browser_fields) > 0) {
            $return_string .= $this->load_grid_browsers();
        }

        if ($this->rounding_values) {
            $return_string .= AdihaGrid::enable_rounding($this->rounding_values);
        }

        return $return_string;
    }

    /**
     * Private functions to load grid combos - calls parent load_combo functions for all combos.
     * @return String JS to load grid combos
     */
    private function load_grid_combos() {
        $return_string = '';

        foreach ($this->combo_fields as $combo_column) {
            $column_def = "EXEC spa_adiha_grid @flag='t', @grid_name = '" . $this->table_name . "', @column_name='" . $combo_column . "'";
            $column_data = readXMLURL2($column_def);
            $return_string .= $this->load_combo($combo_column, $column_data[0]['json_string']);
        }

        return $return_string;
    }

    /**
     * Load grid data.
     * @note
     * $sp_grid is an optional parameter, if not supplied. Process will create a select statement automatically. 
     * To use this automation feature of select statement we need to define the and table name and column name in templateTables exactly same as column name and table name from original table.
     * This feature should only be used for simple gird. No customization on column data can be performed, if used this feature.
     * @param  String  $sp_grid              
     * @param  String  $id                   ID
     * @param  Boolean $auto_adjust          Auto adjust set the default value false
     * @param  String  $callback_funtion     Call back the grid data
     * @param  String  $farrms_product_id    Set farrms Product id default value
     * @param  String  $application_field_id Set application field id while loading grid
     * @param  String  $key_prefix           Prefix used to cache grid Sp result set
     * @param  String  $key_suffix           Suffix used to cache grid Sp result set
     * @return String                        JS to load grid data
     */
    public function load_grid_data($sp_grid = '', $id = '', $auto_adjust = false, $callback_funtion = '', $farrms_product_id = '10000000',$application_field_id = '', $key_prefix = '', $key_suffix = '') {
        if ($sp_grid != '' && $sp_grid != 'NULL') {
            $this->sql_string = $sp_grid;
            return AdihaGrid::load_grid_data($sp_grid, $this->grid_type, $this->grouping_column, $auto_adjust, $callback_funtion,$key_prefix,$key_suffix);
        } else { 
            $sql_string = ($id != '') ? str_replace('<ID>', $id, $this->sql_string) : $this->sql_string; 
            $sql_string = str_replace("<FARRMS_PRODUCT_ID>", $farrms_product_id, $sql_string);    
			$sql_string =  str_replace("<application_field_id>", $application_field_id, $sql_string); 
            return AdihaGrid::load_grid_data(($this->dummy_grid ? '' : $sql_string), $this->grid_type, $this->grouping_column, $auto_adjust, $callback_funtion);
        }
    }

   /**
    * Return permission Array.
    * @return Array Permission array, true or false for edit and delete.
    */
    public function return_permission() {
        $permission_array = array();
        $permission_array['edit'] = ($this->edit_permission == 'y') ? true : false;
        $permission_array['delete'] = ($this->delete_permission == 'y') ? true : false;
        
        return $permission_array;           
    }

    /**
     * Load all browsers in grid column.
     * @return String JS to load grid browsers
     */
    private function load_grid_browsers() {
        $return_string = '';
        foreach ($this->browser_fields as $browser_column) {
            $browser_column_data = explode("->", $browser_column);
            $return_string .= $this->load_browser($browser_column_data[0], $browser_column_data[1] . '->' . $browser_column_data[2]);
        }

        return $return_string;
    }

    /**
     * Get grid data loading sql string
     *
     * @return  String  Grid data loading SQL String
     */
    public function get_grid_load_sql() {
        return $this->sql_string;
    }
}

?>