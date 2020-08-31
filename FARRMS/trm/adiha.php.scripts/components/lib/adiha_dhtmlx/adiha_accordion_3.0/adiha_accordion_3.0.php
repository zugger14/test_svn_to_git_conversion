<?php

class AdihaAccordion {

    public $accordion_name;
    public $name_space;
    
    /**
     * init_accordion [initializes accordion]
     * @param [string] accordion_name [is name of accordion]
     * @param [string] accordion_json [accordion json structure]
     * @param [string] $namespace     [namespace]
     */
    function init_accordion($accordion_name, $accordion_json, $namespace) {
    	$this->name_space = $namespace;
        $this->accordion_name = $this->name_space . "." . $accordion_name;
        $html_string .= "var " . $this->accordion_name . " = new dhtmlXAccordion('" . $accordion_json . "')" . "\n";
        return $html_string;
    }

    /** 
     * init_by_attach  [sets the calendar name]
     * @param [string] accordion_name  [accordion name to be attached]
     * @param [string] $namespace      [namespace]
     */
    function init_by_attach($accordion_name, $namespace) {
        $this->name_space = $namespace;
        $this->accordion_name = $this->name_space . "." . $accordion_name;
    }

    /**
     * [Loads accordion]
     * @param [string] $accordion_json [JSON accordion structure]
     */
    function load_accordion($accordion_json) {        
        $html_string .= $this->accordion_name . ".loadStruct(" . $accordion_json . ");"  . "\n";
        return $html_string;
    }

    /**
     * set_skin - [sets skin]
     * @param [string] skin_name [Name of a skin]
     */
    function set_skin($skin_name) {
        $html_string = $this->accordion_name . ".setSkin('" . $skin_name . "');" . "\n";
        return $html_string;
    }
    
    /**
     * set_icon_path [sets path to icon]
     * @param [string] icon_path [path to icon]
     */
    function set_icon_path($icon_path) {
        $html_string = $this->accordion_name . ".setIconsPath('" . $icon_path. "')" . "\n";
        return $html_string;
    }

    /**
     * [attach_layout_cell - attaches dhtmlxlayout to  particular cell in layout]
     * @param  [string] $layout_name [layout name]
     * @param  [string] $accordion_cell [cell id]
     * @param  [string] $pattern [pattern]
     * @param  [string] $cell_json [json for the cell of the layout.]
     */
    function attach_layout_cell($layout_name, $accordion_cell, $pattern, $cell_json) {
        $html_string .= $this->name_space . "." . $layout_name . " = " . $this->accordion_name . ".cells('" . $accordion_cell . "').attachLayout({
            	pattern:\"" . $pattern . "\"" . "\n" .
                ",cells: " . $cell_json . "\n" .
                "});" . "\n";
        return $html_string;
    }
    
    /**
     * attach_form [attaches tree component on accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] form_json [form json structure]
     */
    function attach_form($accordion_cell, $form_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachForm(" . $form_json . ")";
        return $html_string;
    }

    /**
     * attach_tree_cell [attaches tree component on accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] tree_json [tree json structure]
     */
    function attach_tree_cell($tree_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $tree_name . " = " .$this->accordion_name . ".cells('" . $accordion_cell. "').attachTree()" . "\n";
        return $html_string;
    }
    
    /**
     * attach_grid_cell [attaches grid component on accordion]
     * @param [string] $grid_name       [Grid to be attached]
     * @param [string] $accordion_cell  [Id of accordion where grid is to be attached]
     */
    function attach_grid_cell($grid_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $grid_name . "=" . $this->accordion_name . ".cells('" . $accordion_cell. "').attachGrid();" . "\n";
        return $html_string;
    }

    /**
     * attach_tab [attaches tabbar component on accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] tab_json [tab json structure]
     */
    function attach_tab($accordion_cell, $tab_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachTabbar(" . $tab_json . ")";
        return $html_string;
    }

    /**
     * attach_data_view [attaches dataview component on accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] data_view_json [dataview json structure]
     */
    function attach_data_view($accordion_cell, $data_view_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachDataView(" . $data_view_json . ")";
        return $html_string;
    }

    /**
     * attach_toolbar_cell [attaches toolbar on accordion]
     * @param [string] $toolbar_name [toolbar name]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     */
    function attach_toolbar_cell($toolbar_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $toolbar_name . " = " . $this->accordion_name . ".cells('" . $accordion_cell . "').attachToolbar();" . "\n";
        return $html_string;
    }


    /**
     * [attach_menu_cell - attaches dhtmlxMenu to the accordion cell]
     * @param  [string] $menu_name [menu name]
     * @param  [string] $cell [cell id]
     */
    function attach_menu_cell($menu_name, $cell) {
        $html_string .= $this->name_space . '.' . $menu_name . ' = ' . $this->accordion_name . ".cells('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }

    /**
     * attach_ribbon [attaches ribbon on accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] ribbon_json [ribbon json config]
     */
    function attach_ribbon($accordion_cell, $ribbon_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachRibbon(" . $ribbon_json . ")";
        return $html_string;
    }

    /**
     * attach_status_bar [attaches status bar]
     * @param [string] status_bar_json [json configuration for status bar]
     */
    function attach_status_bar($cell, $is_paging, $status_bar_text) {
        if ($is_paging) {
            $html_string = $this->accordion_name . ".cells('" . $cell . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\"pagingArea_" . $cell . "\"></div>'
                            });";
        } else {
            $html_string = $this->accordion_name . ".cells('" . $cell . "').attachStatusBar({
                                height: 31,
                                text: '" . $status_bar_text . "'
                            });";
        }
        
        return $html_string;
    }

    /**
     * attach_url [attaches URL to accordion]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] url [URL string]
     * @param [string] url_param [URL get parameter in JSON structure]
     */
    function attach_url ($accordion_cell, $url, $url_param) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachURL('" . $url . "', true, " . $url_param . ");";
        return $html_string;
    }

    /**
     * attach_html_string [attaches html]
     * @param [string] html_body [html string to be attached]
     */
    function attach_html_string($accordion_cell, $html_body) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachHTMLString('" . $html_body . "');";
        return $html_string;
    }

    /**
     * attach_object [attaches an html object to a cell]
     * @param [string] accordion_cell [cell of accordion where component to be attached]
     * @param [string] object_id [html object id]
     */
    function attach_object($accordion_cell, $object_id) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachObject('" . $object_id . "');";
        return $html_string;
    }

    /**
     * attach_event  [adds any user-defined handler to available events]
     * @param [string] event_id [variable name to store event]
     * @param [string] event_name [name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxtoolbar_events.html]
     * @param [string] event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
     */
    function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
            $html_string = $this->accordion_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        } else  {
            $html_string = "var " . $event_id . "=" . $this->accordion_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
        }
        return $html_string;
    }

    /**
     * detach_event  [detach event]
     * @param [string] event_id [event id]
     */
    function detach_event($event_id) {
        $html_string = $this->accordion_name . ".detachEvent('". $event_id ."');" . "\n";
        return $html_string;
    }

    /**
     * dock_accordion [docks accordion cells]
     * @param [string] accordion_cell [cell id of accordion]
     */
    function dock_accordion($accordion_cell) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').dock();";
        return $html_string;
    }

    /**
     * undock_accordion [undocks accordion cells]
     * @param [string] accordion_cell [cell id of accordion]
     */
    function undock_accordion($accordion_cell) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').undock();";
        return $html_string;
    }

    /**
     * unload [destructor, unloads toolbar]
     * @param [string] accordion_name [dhtmlx accordion object]
     */
    function unload() {
        $html_string = $this->accordion_name . ".unload();" . "\n";
        $html_string .= $this->accordion_name . " = null;";
        return $html_string;
    }
}
?>