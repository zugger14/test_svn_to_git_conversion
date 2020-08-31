<?php
/**
 *  @brief AdihaTab
 *  
 *  @par Description
 *  This class is used to create a tabbar
 *  
 *  @copyright Pioneer Solutions
 */
class AdihaTab {

    public $tab_name;
    public $name_space;

    /**
     * Initialize the tabbar.
     * @param  String $tab_name tab name
     * @return String html.
     */
    public function init_tab($tab_name) {
        $this->tab_name = $tab_name;
        $html_str = '';

        $html_str .= '<script type="text/javascript">';
        $html_str.=$this->tab_name . '= new dhtmlXTabBar("' . $this->tab_name . '");';
        return $html_str;
    }

    /**
     * Initialize the tabbar by attaching component
     * @param  String $tab_name Tab name.
     * @param  String $namespace Namespace
     * @return String html.
     */
    public function init_by_attach($tab_name, $namespace) {
        $this->name_space = $namespace;
        $this->tab_name = $namespace . "." . $tab_name;
    }

    /**
     * Adds any user-defined handler to available events.
     * @param String $event_id Variable name to store event
     * @param String $event_name Name of the event. Available event: http://docs.dhtmlx.com/api__link__dhtmlxtabbar_attachevent.html
     * @param String $event_function User defined function name, which will be called on particular event. This function can be defined in main page itself.
     * @return String html.
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
     * Enable Tab Close button.
     * @return String html.
     */
    public function enable_tab_close() {
        $html_str = $this->tab_name . ".enableTabCloseButton(true);" . "\n" ;
        return $html_str;
    }

    /**
     *  Attach Tab close event.
     *  @return String html.
     */
    function attach_close_tab_event() {
        $return_string  = $this->tab_name . '.attachEvent("onTabClose", function(id) {' . "\n";
        $return_string .= '     delete ' . $this->name_space . '.pages[id];'. "\n";
        $return_string .= '     return true;'. "\n";
        $return_string .= '});' . "\n";

        return $return_string;
    }

    /**
     * Adding tab to a tab.
     * @param String     $tab_name Name of the tab
     * @param String    $tab_id   Id of the tab
     * @param String     $tab_json json of the tab
     * @return String html.
     */
    public function attach_tab($tab_name, $tab_id, $tab_json) {
        $html_str = $tab_name . ' = ' . $this->tab_name . '.tabs(' . $tab_id . ').attachTabbar({tabs:get_tab_json_locale(' . $tab_json . ')})';
        return $html_str;
    }

    /**
     * close_tab close the initialize of the tabbar.
     * @return String Script close
     */
    public function close_tab() {
        $html_str = '</script>';
        return $html_str;
    }

    /**
     * Adds a new tab to Tabbar
     * @param String   $tab_id    Tab id
     * @param String    $text      Text
     * @param Integer   $width     Tab width, default null, if not int - will be adjusted automatically(Optional)
     * @param Integer   $position  Tab position, default null (last tab),(Optional)
     * @param Boolean   $active    Set to true to select tab after add, default false(Optional)
     * @param Boolean   $close     Set to true to render close button, default false, overrides enableTabCloseButton(Optional)
     * @return  String html.
     */
    public function add_tab($tab_id, $text, $width = 'null', $position = 'null', $active = 'false', $close = 'false') {
        return $this->tab_name . '.addTab("' . $tab_id . '", get_locale_value("' . $text . '"), ' . $width . ',' . $position . ',' . $active . ',' . $close . ');' . "\n";
    }

    /**
     * Add object to a tab.
     * @param  String $tab_id     Tab id
     * @param  Object  $tab_object Tab object to be attached
     * @return String html.
     */
    public function attach_object($tab_id, $tab_object) {
        $html_str = $this->tab_name . '.tabs("' . $tab_id . '").attachObject("' . $tab_object . '");' . "\n";
        return $html_str;
    }
  
    /**
     * Add HTML string to a tab.
     * @param  String  $tab_id     Tab id
     * @param  String  $tab_string HTML sring to be attached
     * @return String html
     */
    public function attach_HTMLstring($tab_id, $tab_string) {
        $html_str = $this->tab_name . '.tabs("' . $tab_id . '").attachHTMLString("' . $tab_string . '");' . "\n";
        return $html_str;
    }

    /**
     * Add layout to a tab.
     * @param  String $layout_name  Name of layout
     * @param  String $tab_id       Tab id
     * @param  String $pattern      Layout pattern to be attached
     * @return String html.
     */
    public function attach_layout($layout_name, $tab_id, $pattern) {
        $html_str = $this->name_space . '.' . $layout_name . '= ' . $this->tab_name . '.tabs("' . $tab_id . '").attachLayout("' . $pattern . '");';
        return $html_str;
    }

    /**
     * Attaches dhtmlxlayout to  particular tab id in layout.
     * @param  String $name_space   Name space
     * @param  String $layout_name  Layout name
     * @param  String $tab_name     Tab name where layout needed to attach
     * @param  String $tab_id       Tab id
     * @param  String $pattern      Layout pattern to be attached
     * @param  String $cell_json    json for the cell of the layout.
     * @return String html. 
     */
    function attach_layout_cell($name_space, $layout_name, $tab_name, $tab_id, $pattern, $cell_json) {
        $html_string = $name_space . "." . $layout_name . " = " . $tab_name . ".tabs('" . $tab_id . "').attachLayout({
                pattern:\"" . $pattern . "\"" . "\n" .
                ",cells: " . $cell_json . "\n" .
                "});" . "\n";
        return $html_string;
    }

    /**
     * Add grid to tab.
     * @param  String  $grid_name   Name of the grid
     * @param  String  $tab_id      Tab id
     * @return String html.
     */
    public function attach_grid($grid_name, $tab_id) {
        $html_str = 'grid_' . $grid_name . '= tab_' . $this->tab_name . '.tabs("' . $tab_id . '").attachGrid()';
        return $html_str;
    }

    /**
     * attach_tree Add tree to a tab.
     * @param String  $tree_name  Name of the tree
     * @param String  $tab_id     Id of the tab
     * @return String html.
     */
    public function attach_tree($tree_name, $tab_id) {
        $html_str = 'tree_' . $tree_name . '= tab_' . $this->tab_name . '.tabs("' . $tab_id . '").attachTree()';
        return $html_str;
    }

    /**
     * Attach Form to tab cell
     * @param  String  $form_name Form Name
     * @param  String  $cell_id   Tab cell id
     * @return String html. 
     */
    public function attach_form_cell($form_name, $cell_id) {
        $html_str = $this->name_space . '.'. $form_name . '= ' . $this->tab_name . '.tabs("' . $cell_id . '").attachForm();' . "\n";
        return $html_str;
    }

    /**
     * Attaches dhtmlxMenu to the tab cell.
     * @param  String $menu_name Name of the menu
     * @param  String $cell cell id
     * @return Html String. 
     */
    public function attach_menu_cell($menu_name, $cell) {
        $html_string = $this->name_space . '.' . $menu_name . ' = ' . $this->tab_name . ".tabs('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }

    /**
     * Add form to a tab.
     * @param String  $form_name Name of the form
     * @param Integer $tab_id    Id of the tab
     * @param String  $form_json json of the form
     * @return string Html String.
     */
    public function attach_form($form_name, $tab_id, $form_json = '') {
        $html_str = $this->name_space . '.' . $form_name . '= ' . $this->tab_name . '.tabs("' . $tab_id . '").attachForm(); ';
        if ($form_json) {
            $html_str .= $this->name_space .'.'.$form_name .'.loadStruct(get_form_json_locale('.$form_json.'));';
        }
        return $html_str;
    }
    /**
     * Add new form in tab.
     * @param String  $tab_name         Name of the tab
     * @param String  $form_name        Name of the form in given tab
     * @param Integer $tab_id           Attach form tab id
     * @param String  $form_json        json of the form
     * @param String  $layout_namespace Attach form layout namespace
     * @param String  $dependent_combo   Variable name to store dependent_combo
     * @return String JS to add form in new tab
     */
    public function attach_form_new($tab_name, $form_name, $tab_id, $form_json, $layout_namespace, $dependent_combo = '') {
        $html_str = $layout_namespace.'.'.$form_name . '= ' . $layout_namespace . '.' . $tab_name . '.tabs("' . $tab_id . '").attachForm(); ';        
        $call_back_func = '';
        if ($dependent_combo != '') {
            $call_back_func = '), function() { ';
            $call_back_func .=      'var form_obj = ' . $layout_namespace . '.' . $form_name . '.getForm();';
            $call_back_func .=      'load_dependent_combo("' . $dependent_combo . '"  , 0 , form_obj);';     
            $call_back_func .= '}';
        } else {
            $call_back_func .= ')';
        }
        

        if ($form_json) {
            $html_str .= $layout_namespace.'.'.$form_name .'.loadStruct(get_form_json_locale('.$form_json. $call_back_func .');';
        }
        
        return $html_str;
    }
    
    /**
     * Attaches form inside layout cell under tab.
     * @param String $form_name Name of form
     * @param String $layout_name layout name
     * @param String $layout_cell layout cell
     * @param String $form_json json of the form in {} in format 
     * @return String html.
     */ 
    public function attach_form_layout_cell($form_name, $layout_cell, $layout_name, $form_json) {
        $html_str = $this->name_space . '.' . $form_name. ' = ' . $this->name_space . '.' . $layout_name . '.cells("' . $layout_cell . '").attachForm();';
        if ($form_json) {
            $html_str .= $this->name_space . '.' . $form_name . '.loadStruct(get_form_json_locale(' . $form_json . '));';
        }
        return $html_str;
    }
    /**
     * attach_event - adds tab to a form where tab json and form json is provided.
     * @param String $tab_json json of the tab in {} format
     * @param String $form_json json of the form in {} in format 
     * @param String $form_name name of the form
     * @param String $tab_name  name of the tab
     * @return String html tab and form attached.
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
                    $html_string.= '.attachForm(get_form_json_locale(' . $form_json . '));';
                else
                    $html_string.= '.attachObject("' . $value[1] . '");';
            }
            $i++;
        }
        return $html_string;
    }

    /**
     * Sets the tab with provided id as active.
     * @param Integer $id Id of the tab
     * @return  String html.
     */
    function set_active_tab($id) {
        $html_str = '';
        $html_str .= $this->tab_name . '.tabs("' . $id . '").setActive();' . "\n";
        return $html_str;
    }
    
    /**
     * Sets the tab mode.
     * @param   String  $mode   Mode of the tab
     * @return String html.
     */
    function set_tab_mode($mode) {
        $html_str = '';
        $html_str .= $this->tab_name . '.setTabsMode("' . $mode . '");';
        return $html_str;
    }

    /**
     * Attach URL to Tab cell.
     * @param  String $cell     Cell id
     * @param  String $url_path Path of the URL
     * @param  String $params   Set empty by default
     * @return String html.
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
     * Attach grid component on tab cell.
     * @param String $grid_name       Name of the grid to be attached
     * @param String $cell            Id of tab cell where grid is to be attached
     * @return String html. 
     */
    function attach_grid_cell($grid_name, $cell) {
        $html_string = $this->name_space . "." . $grid_name . "=" . $this->tab_name . ".tabs('" . $cell. "').attachGrid();" . "\n";
        return $html_string;
    }

    /**
     * Add dataview to a tab.
     * @param  Integer $tab_id         Tab id
     * @param  String $data_view_name  Name of the data view
     * @return String html.
     */
    public function attach_data_view($tab_id, $data_view_name) {
        $html_string = $this->name_space . '.' . $data_view_name . ' = ' . $this->tab_name . ".tabs('" . $tab_id . "').attachDataView();". "\n";
        return $html_string;
    }

    /**
     * Add Status Bar.
     * @param  Integer $tab_id          Tab id
     * @param  String  $is_paging       ID or container which will be used for showing paging
     * @param  String  $status_bar_text Text in the status bar.
     * @return String html.
     */
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

    /**
     * Sets User Data to tab cell
     *
     * @param   String  $cell_id  Id of the cell
     * @param   String  $name     Name of the user data
     * @param   String  $value    Value of the user data
     *
     * @return  String            JS String to set user data
     */
    function set_user_data($cell_id, $name, $value) {
        return $this->tab_name . "._setUserData('" . $cell_id . "', '" . $name . "', '" . $value . "');";        
    }

    /**
     * Gets User Data from tab cell
     *
     * @param   String  $cell_id  Id of the cell
     * @param   String  $name     Name of the user data
     *
     * @return  String            JS String to get user data
     */
    function get_user_data($cell_id, $name) {
        return $this->tab_name . "._getUserData('" . $cell_id . "', '" . $name . "');";        
    }
}

?>