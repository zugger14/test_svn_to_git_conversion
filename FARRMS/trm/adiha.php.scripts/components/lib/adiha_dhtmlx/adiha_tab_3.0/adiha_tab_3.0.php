<?php

class AdihaTab {

    public $tab_name;
    public $name_space;

    /**
     * [init_tab initialize the tabbar.]
     * @param  [string] $tab_name [tab name]
     */
    public function init_tab($tab_name) {
        $this->tab_name = $tab_name;
        $html_str = '';

        global $app_php_script_loc, $app_adiha_loc;
        $html_str .= '<script type="text/javascript">';
        $html_str.=$this->tab_name . '= new dhtmlXTabBar("' . $this->tab_name . '");';
        return $html_str;
    }

    /**
     * [init_by_attach initialize the tabbar by attaching component]
     * @param  [string] $tab_name [tab name]
     */
    public function init_by_attach($tab_name, $namespace) {
        global $image_path;
        $this->name_space = $namespace;
        $this->tab_name = $namespace . "." . $tab_name;
        return $html_string;
    }

    /**
     * [attach_event - adds any user-defined handler to available events]
     * @param [string] $event_id [variable name to store event]
     * @param [string] $event_name [name of the event. Available event: http://docs.dhtmlx.com/api__link__dhtmlxtabbar_attachevent.html]
     * @param [string] $event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
     */
    function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
            $html_string = $this->tab_name . ".attachEvent('" . $event_name . "', $event_function);" . "\n";
        } else {
            $html_string = $event_id . "=" . $this->tab_name . ".attachEvent('" . $event_name . "', $event_function);" . "\n";
        }
        return $html_string;
    }

    /**
     * [enable_tab_close Enable Tab Close button]
     */
    public function enable_tab_close() {
        $html_str = $this->tab_name . ".enableTabCloseButton(true);" . "\n" ;
        return $html_str;
    }

    /**
     * [attach_close_tab_event Attach Tab close event]
     */
    function attach_close_tab_event() {
        $return_string  = $this->tab_name . '.attachEvent("onTabClose", function(id) {' . "\n";
        $return_string .= '     delete ' . $this->name_space . '.pages[id];'. "\n";
        $return_string .= '     return true;'. "\n";
        $return_string .= '});' . "\n";

        return $return_string;
    }

    /**
     * [attach_tab Add tab to a tab.]
     * @param [string] $tab_name [name of the tab]
     * @param [int] $tab_id [id of the tab]
     * @param [string] $tab_json [json of the tab]
     * @return 
     */
    public function attach_tab($tab_name, $tab_id, $tab_json) {
        $html_str = $tab_name . ' = ' . $this->tab_name . '.tabs(' . $tab_id . ').attachTabbar({tabs:' . $tab_json . '})';
        return $html_str;
    }

    /**
     * [close_tab close the initialize of the tabbar.]
     */
    public function close_tab() {
        $html_str = '</script>';
        return $html_str;
    }

    /*
     * adds a new tab to Tabbar
     * params:
     * tab_id:tab id
     * text:tab text
     * width:(optional) tab width, default null, if not int - will be adjusted automatically
     * position:(optional) tab position, default null (last tab)
     * active:(optional) set to true to select tab after add, default false
     * close:(optional) set to true to render close button, default false, overrides enableTabCloseButton
     */

    public function add_tab($tab_id, $text, $width = 'null', $position = 'null', $active = 'false', $close = 'false') {
        $html_str = $this->tab_name . '.addTab("' . $tab_id . '", "' . $text . '", ' . $width . ',' . $position . ',' . $active . ',' . $close . ');' . "\n";
        return $html_str;
    }

    /*
     * Add object to a tab
     * tab_id:tab id
     * tab_object: tab object to be attached
     */

    public function attach_object($tab_id, $tab_object) {
        $html_str = $this->tab_name . '.tabs("' . $tab_id . '").attachObject("' . $tab_object . '");' . "\n";
        return $html_str;
    }

    /*
     * Add HTML string to a tab
     * tab_id:tab id
     * tab_object: HTML sring to be attached
     */

    public function attach_HTMLstring($tab_id, $tab_string) {
        $html_str = $this->tab_name . '.tabs("' . $tab_id . '").attachHTMLString("' . $tab_string . '");' . "\n";
        return $html_str;
    }

    /*
     * Add layout to a tab
     * tab_id:tab id
     * pattern: layout pattern to be attached
     */

    public function attach_layout($layout_name, $tab_id, $pattern) {
        $html_str = $this->name_space . '.' . $layout_name . '= ' . $this->tab_name . '.tabs("' . $tab_id . '").attachLayout("' . $pattern . '");';
        return $html_str;
    }

    /**
     * [attach_layout_cell - attaches dhtmlxlayout to  particular tab id in layout]
     * @param [string] $name_space [name space]
     * @param [string] $tab_name [tab name where layout needed to attach]
     * @param  [string] $layout_name [layout name]
     * @param  [string] $tab_id [tab id]
     * @param  [string] $pattern [pattern]
     * @param  [string] $cell_json [json for the cell of the layout.]
     */
    function attach_layout_cell($name_space, $layout_name, $tab_name, $tab_id, $pattern, $cell_json) {
        $html_string .= $name_space . "." . $layout_name . " = " . $tab_name . ".tabs('" . $tab_id . "').attachLayout({
                pattern:\"" . $pattern . "\"" . "\n" .
                ",cells: " . $cell_json . "\n" .
                "});" . "\n";
        return $html_string;
    }

    /*
     * Add grid to a tab
     * grid_name: Name of the grid
     * tab_id:tab id
     */

    public function attach_grid($grid_name, $tab_id) {
        $html_str = 'grid_' . $grid_name . '= tab_' . $this->tab_name . '.tabs("' . $tab_id . '").attachGrid()';
        return $html_str;
    }

    /**
     * [attach_tree Add tree to a tab.]
     * @param [string] $tree_name [name of the tree]
     * @param [int] $tab_id [id of the tab]
     * @return 
     */
    public function attach_tree($tree_name, $tab_id) {
        $html_str = 'tree_' . $tree_name . '= tab_' . $this->tab_name . '.tabs("' . $tab_id . '").attachTree()';
        return $html_str;
    }

    /**
     * [attach_form_cell Attach Form to tab cell]
     * @param  [type] $form_name [Form Name]
     * @param  [type] $cell_id   [tab cell id]
     */
    public function attach_form_cell($form_name, $cell_id) {
        $html_str = $this->name_space . '.'. $form_name . '= ' . $this->tab_name . '.tabs("' . $cell_id . '").attachForm();' . "\n";
        return $html_str;
    }

    /**
     * [attach_menu_cell - attaches dhtmlxMenu to the tab cell]
     * @param  [string] $menu_name [menu name]
     * @param  [string] $cell [cell id]
     */
    public function attach_menu_cell($menu_name, $cell) {
        $html_string .= $this->name_space . '.' . $menu_name . ' = ' . $this->tab_name . ".tabs('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }

    /**
     * [attach_form Add form to a tab.]
     * @param [string] $form_name [name of the form]
     * @param [int] $tab_id [id of the tab]
     * @param [mixed] $form_json [json of the form]
     * @return 
     */
    public function attach_form($form_name, $tab_id, $form_json) {
        $html_str = $this->name_space .'.'.$form_name . '= ' . $this->tab_name . '.tabs("' . $tab_id . '").attachForm(); ';
        if($form_json){
            $html_str .= $this->name_space .'.'.$form_name .'.loadStruct('.$form_json.');';
        }
        return $html_str;
    }

    public function attach_form_new($tab_name, $form_name, $tab_id, $form_json, $layout_namespace, $dependent_combo = '') {
        $html_str = $layout_namespace.'.'.$form_name . '= ' . $layout_namespace . '.' . $tab_name . '.tabs("' . $tab_id . '").attachForm(); ';        
        $call_back_func = '';
        if ($dependent_combo != '') {
            $call_back_func = ', function() { ';
            $call_back_func .=      'var form_obj = ' . $layout_namespace . '.' . $form_name . '.getForm();';
            $call_back_func .=      'load_dependent_combo("' . $dependent_combo . '"  , 0 , form_obj);';     
            $call_back_func .= '}';
        }
        

        if ($form_json) {
            $html_str .= $layout_namespace.'.'.$form_name .'.loadStruct('.$form_json. $call_back_func .');';
        }
        
        return $html_str;
    }
    /**
     * [attach_form_layout_cell attaches form inside layout cell under tab.]
     * @param [string] $form_name [name of form]
     * @param [string] $name_space [name space]
     * @param [string] $layout_name [layout name]
     * @param [char] $layout_cell [layout cell]
     * @param [mixed] $form_struct [form structure in json format]
     */
    public function attach_form_layout_cell($form_name, $layout_cell, $layout_name, $form_json) {
        $html_str = $this->name_space . '.' . $form_name. ' = ' . $this->name_space . '.' . $layout_name . '.cells("' . $layout_cell . '").attachForm();';
        if ($form_json) {
            $html_str .= $this->name_space . '.' . $form_name . '.loadStruct(' . $form_json . ');';
        }
        return $html_str;
    }
    /**
     * [attach_event - adds tab to a form where tab json and form json is provided.]
     * @param [string] $tab_json [json of the tab in {} format]
     * @param [string] $form_json [json of the form in [{}] in format.] 
     * @param [string] $form_name [name of the form.]
     * @param [string] $tab_name  [name of the tab.]
     * @return [string] tab and form attached.
     */
    public function attach_form_json($tab_json, $form_json, $form_name, $tab_name) {
        $temp_array = array();
        $temp_array1 = array();
        $temp_array2 = array();
        $temp_array = (explode(",", $tab_json));
        $i = 0;
        foreach ($temp_array as $temp) {
            $temp_array1 = (explode(":", $temp));
            $j = 0;
            foreach ($temp_array1 as $temp1) {
                $temp1 = str_replace(' ', '', $temp1);
                $temp1 = str_replace("}", "", $temp1);
                $temp1 = str_replace("{", "", $temp1);
                $temp1 = str_replace('"', '', $temp1);
                $temp1 = preg_replace('/\s+/', '', $temp1);
                $temp_array2[$i][$j] = $temp1;
                $j++;
            }
            $i++;
        }

        $html_string = $form_name . ' = ';
        $i = 0;
        foreach ($temp_array2 as $value) {
            if ($value[0] == 'id')
                $html_string.= 'tab_' . $tab_name . '.cells("' . $value[1] . '")';
            else if ($value[0] == 'text') {
                if ($i == 1)
                    $html_string.= '.attachForm(' . $form_json . ');';
                else
                    $html_string.= '.attachObject("' . $value[1] . '");';
            }
            $i++;
        }
        return $html_string;
    }

    /**
     * [set_active_tab -sets the tab with provided id as active.]
     * @param [int] $id [id of the tab]
     * @return 
     */
    function set_active_tab($id) {
        $html_str = '';
        $html_str .= $this->tab_name . '.tabs("' . $id . '").setActive();' . "\n";
        return $html_str;
    }
    
    /**
     * [set_tab_mode -sets the tab mode.]
     * @param [int] $mode [mode of the tab]
     * @return 
     */
    function set_tab_mode($mode) {
        $html_str = '';
        $html_str .= $this->tab_name . '.setTabsMode("' . $mode . '");';
        return $html_str;
    }

    /**
     * [attach_url Attach URL to Tab cell]
     * @param  [type] $cell     [cell_id]
     * @param  [type] $url_path [URL Path]
     */
    function attach_url($cell, $url_path, $params = '') {
        $html_str = '';
        if ($params == '') {
            $html_str .= $this->tab_name . '.tabs("' . $cell . '").attachURL("' . $url_path . '");';
        } else {
            $html_str .= $this->tab_name . '.tabs("' . $cell . '").attachURL("' . $url_path . '", null, ' . $params . ');';
        }
        return $html_str;
    }

    /**
     * attach_grid_cell [attaches grid component on tab cell]
     * @param [string] $grid_name       [Grid to be attached]
     * @param [string] $cell  [Id of tab cell where grid is to be attached]
     */
    function attach_grid_cell($grid_name, $cell) {
        $html_string = $this->name_space . "." . $grid_name . "=" . $this->tab_name . ".tabs('" . $cell. "').attachGrid();" . "\n";
        return $html_string;
    }

    /*
     * Add dataview to a tab
     * tab_id:tab id
     * pattern: layout pattern to be attached
     */

    public function attach_data_view($tab_id, $data_view_name) {
        $html_string = $this->name_space . '.' . $data_view_name . ' = ' . $this->tab_name . ".tabs('" . $tab_id . "').attachDataView();". "\n";
        return $html_string;
    }


    function attach_status_bar($tab_id, $is_paging, $status_bar_text) {
        if ($is_paging) {
            $html_string = $this->tab_name . ".tabs('" . $tab_id . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\"pagingArea_" . $tab_id . "\"></div>'
                            });";
        } else {
            $html_string = $this->tab_name . ".tabs('" . $tab_id . "').attachStatusBar({
                                height: 31,
                                text: '" . $status_bar_text . "'
                            });";
        }

        return $html_string;
    }
}

?>