<?php

/**
 *  @brief AdihaMenu
 *  
 *  @par Description
 *  This class is used to generate menu according to the JSON loaded.
 *  
 *  @copyright Pioneer Solutions
 */

Class AdihaMenu {
    public $menu_name;
    public $name_space;
    
    /**
     * Initialize Menu when it is not attached to other object.
     * @param  String $menu_name    Menu Name, string without space
     * @param  String $namespace    Namespace,Same name to be used in all components in a form
     * @return String JS to initialize menu
     */
    public function init_menu($menu_name, $name_space) {
        $this->name_space = $name_space;
        $this->menu_name = $this->name_space . "." . $menu_name;
        
        $html_string = $this->menu_name . ' = new dhtmlXMenuObject({'. "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }
    
    /**
     * Initialize Menu when it is attached to other object.
     * @param  String $menu_name    Menu Name, string without space
     * @param  String $namespace    Same name to be used in all components in a form
     */   
    public function init_by_attach($menu_name, $name_space) {
        $this->name_space = $name_space;
        $this->menu_name = $this->name_space . "." . $menu_name;
    }
    
    /**
     * Load the JSON structure of menu and create menu.
     * @param  String $menu_json    JSON to build menu
     * @return String JS to load menu data
     */   
    public function load_menu($menu_json) {
        return $this->menu_name . ".loadStruct(" . $menu_json .");" . "\n";
    }

    /**
     * Disable menu item
     *
     * @param   String  $menu_item_id  Id of menu item
     *
     * @return  String                 JS String to disable menu item
     */
    public function disable_item($menu_item_id) {
        return $this->menu_name . ".setItemDisabled('" . $menu_item_id . "');" . "\n";
    }

    /**
     * Enable menu item
     *
     * @param   String  $menu_item_id  Id of menu item
     *
     * @return  String                 JS String to enable menu item
     */
    public function enable_item($menu_item_id) {
        return $this->menu_name . ".setItemEnabled('" . $menu_item_id . "');" . "\n";
    }

    /**
     * Render the menu as context menu.
     * @return String JS to rener context menu
     */   
    public function render_as_context_menu() {
        return $this->menu_name . ".renderAsContextMenu();" . "\n";
    }
    
    /**
     * Adds any user-defined handler to available events.
     * @param String $event_id          Variable name to store event
     * @param String $event_name        Name of the event. Available event: http://http://docs.dhtmlx.com/api__refs__dhtmlxmenu_events.html
     * @param String $event_function    User defined function name, which will be called on particular event. This function can be defined in main page itself.
     * @return String JS to attach event
     */
    public function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
                $html_string = $this->menu_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        } else  {
                $html_string = "var " . $event_id . "=" . $this->menu_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        }
        return $html_string;
    }

    /**
     * Attach menu in layout header.     
     * @param String $namespace           Same name to be used in all components in a form 
     * @param String $layout_name         Layout Name where the menu needs to be added
     * @param String $cell                Layout cell where the menu needs to be added
     * @param String $menu_name           Name of the menu
     * @param String $menu_json           JSON to load menu
     * @param String $on_click_function   Onclick fucntion for menu buttons
     * @param String $align               Set align to left by default
     * @return String JS to attach menu in layout header
     */
    public function attach_menu_layout_header($name_space, $layout_name, $cell, $menu_name, $menu_json, $on_click_function, $align = 'left', $multi_menu = 'false') {
        $this->name_space = $name_space;
        $this->layout_name = $this->name_space . "." . $layout_name;
        
        $html_string = 'var layout_cell_obj = ' . $this->layout_name . '.cells("' . $cell . '");' . "\n";
        $html_string .= $this->name_space . '.' . $menu_name . ' = layout_header_load_menu(layout_cell_obj, '.$menu_json .', ' . $on_click_function . ', "' . $align . '", ' . $multi_menu . ');  ' . "\n";

        return $html_string;
    } 
}

?>