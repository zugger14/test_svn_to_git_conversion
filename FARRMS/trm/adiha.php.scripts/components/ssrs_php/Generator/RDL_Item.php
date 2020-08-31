<?php
/**
 *  @brief RDL Item class
 *
 *  @par Description
 *  Base RDL item class that holds generic property shared by most of the report types
 *  @copyright Pioneer Solutions
 */
class RDL_Item {

    public $name;
    public $alias;
    public $type;
    public $top;
    public $left;
    public $width;
    public $height;
    public $dataset_name;
    public $display_type;
    public $ssrs_config;
    public $dataset_fields = array();
    public $language_dict ;
    public $rdl_type = 'rdl_final';
    public $process_id = '';

    /**
     * Class constructor
     *
     * @param   array   $ssrs_config     Configuration for SQL Server Reporting Service
     * @param   array   $languange_dict  Language dictionary
     * @param   string  $rdl_type        RDL type. Values: null | 'rdl_final' | 'rdl_preview'
     * @param   string  $process_id      Process ID
     */
    public function __construct($ssrs_config = null,$language_dict = null, $rdl_type = null, $process_id = null) {
        $this->ssrs_config = $ssrs_config;
        $this->language_dict = $language_dict;
        $this->rdl_type = $rdl_type;
        $this->process_id = $process_id;
    }
    
    /**
     * Localizer
     */
    public function _($text){//return $text;
        $key = convert_special_character(strtolower($text));
        $data_lang = array();
        if(is_array($this->language_dict) && sizeof($this->language_dict)> 0){
            foreach($this->language_dict as $culture => $lang){
                if(isset($lang[$key]) && !is_array($lang[$key])){
                    array_push($data_lang,array($lang[$key],$culture));
                }else if(isset($lang[$key]) && is_array($lang[$key])){
                    array_push($data_lang,array($lang[$key][0],$culture));
                }
            }
        }
		/*
        if(sizeof($data_lang)>0){
            $exp = '=Switch(';
            foreach ($data_lang as $lang){
                $exp .= 'LCase(Parameters!report_region.Value) = LCase("'.$lang[1].'"), "'.$lang[0].'", ';
            }
            return $exp .= ' True, "'.$text.'")';
        }else{
            return $text;
        }
		*/
		$exp = '';
		if(trim($text) != '') {
			$exp = '=First(Fields!'.preg_replace('/[^\w]/','_',$text).'.Value, "Dataset_header")';
		}
		return $exp;
    }

    /**
     * Initialize class
     *
     * @param   string  $name            Item name
     * @param   string  $top             Top position
     * @param   string  $left            Left position
     * @param   string  $width           Width
     * @param   string  $height          Height
     * @param   string  $dataset_name    Dataset name
     * @param   string  $type            Item type
     * @param   string  $alias           Item alias
     * @param   string  $dimension_unit  Dimension Unit. Default: 'in' - Inch
     */
    public function init($name, $top, $left, $width, $height, $dataset_name = NULL, $type = NULL, $alias = NULL, $dimension_unit = 'in') {
        $this->name = preg_replace('/[^\w]/', '_', $name);
        $this->dataset_name = $dataset_name;
        $this->top = ((strlen($top) > 0) ? $top : '0') . $dimension_unit;
        $this->left = ((strlen($left) > 0) ? $left : '0') . $dimension_unit;
        $this->width = ((strlen($width) > 0) ? $width : '0') . $dimension_unit;
        $this->height = ((strlen($height) > 0) ? $height : '0') . $dimension_unit;
        $this->type = $type;
        $this->alias = preg_replace('/[^\w]/', '_', $alias);
        $this->dataset_fields = array();
    }

    /**
     * Adds dataset field
     *
     * @param   string  $column_variable  Column variable
     * @param   string  $column_alias     Column alias
     * @param   string  $column_datatype  Column datatype
     */
    public function push_dataset_field($column_variable, $column_alias, $column_datatype) {
        $this->dataset_fields[$column_variable] = array($column_variable, $column_alias, $column_datatype);
    }

    /**
     * Sets dataset
     *
     * @return  array  Return dataset
     */
    public function set_dataset() {
        //$dataset_cmd_text = '="EXEC spa_rfx_run_sql " & Parameters!paramset_id.Value & ", " & Parameters!ITEM_' . $this->alias . '.Value & ", " & Parameters!report_filter.Value & ", NULL,' . "'" . $this->display_type . "', NULL,NULL," . '"' . ' & Parameters!runtime_user.Value';
        
        if($this->rdl_type == 'rdl_preview') {
            $dataset_cmd_text = '="EXEC spa_rfx_run_sql_dhx @process_id=\'' . $this->process_id . '\', @paramset_id=" & Parameters!paramset_id.Value & ", @component_id=" & Parameters!ITEM_' . $this->alias . '.Value & ", @criteria=" & Parameters!report_filter.Value & ", @display_type=' . "'" . $this->display_type . "', @runtime_user='\" & Parameters!runtime_user.Value & \"', @is_html='\" & Parameters!is_html.Value & \"' , @is_refresh=\" & Parameters!is_refresh.Value & \"" . '"';
        } else {
            $dataset_cmd_text = '="EXEC spa_rfx_run_sql " & Parameters!paramset_id.Value & ", " & Parameters!ITEM_' . $this->alias . '.Value & ", " & Parameters!report_filter.Value & ", NULL,' . "'" . $this->display_type . "','\" & Parameters!runtime_user.Value & \"', '\" & Parameters!is_html.Value & \"' , \" & Parameters!is_refresh.Value & \" , NULL" . '"';    
        }
        $dataset_fields = array();
        foreach ($this->dataset_fields as $field) {
            array_push($dataset_fields, array(
                'DataField' => $field[1],
                'rd:TypeName' => ($field[2] == '1') ? 'System.Int32' : 'System.String',
                '@attributes' => array('Name' => $field[0])
            ));
        }

        return array(
            'Fields' => array('Field' => $dataset_fields),
            'Query' => array(
                'DataSourceName' => $this->ssrs_config['DATA_SOURCE'],
                'CommandText' => $dataset_cmd_text,
                'rd:UseGenericDesigner' => 'true'
            ),
            '@attributes' => array('Name' => $this->dataset_name)
        );
    }

    /**
     * Sets value to a path specified in a Multidimensional array
     * @param array $arr Reference to array which needs value update
     * @param string $path Key stack which contains the path seperated by '/' like directory path. No trailing / at start and end.
     * @param array/string/int $value Value to be assigned
     */
    function setval_from_path(&$arr, $path, $value, $push_mode = FALSE) {
        $dest = &$arr;
        $path = explode('/', $path);
        $finalKey = array_pop($path);
        foreach ($path as $key) {
            if($key != '')
                $dest = &$dest[$key];
        }
        if($push_mode){
            if(!is_array($dest[$finalKey])){
                $dest[$finalKey] = array();
            }
            array_push($dest[$finalKey], $value);
        }else
            $dest[$finalKey] = $value;
    }

    /**
     * Remove character from string
     *
     * @param   string  &$str  String of which characters are to be removed from last index
     * @param   int     $subs  Number of characters to be removed from last index   
     *
     * @return  string         Return modified string
     */
    function remove_last_char(&$str, $subs = 1) {
        $str = substr($str, 0, (strlen($str) - $subs));
    }
    
    /**
     * Print_r with <pre>; had to be added as too many debugging lines requires
     * @param type $data
     */
    public function dump($data){
        echo "<pre>";
        print_r($data);
        echo "</pre>";
    }

}