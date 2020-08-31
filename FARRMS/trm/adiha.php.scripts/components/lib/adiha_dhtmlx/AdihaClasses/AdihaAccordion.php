<?php

class AdihaAccordion {

    public $accordion_name;
    public $name_space;
    
    /**
     * Initializes Accordion.
     * @param String $accordion_name Name of accordion
     * @param String $accordion_json Accordion json structure
     * @param String $namespace      Namespace
     * @return String html.
     */
    function init_accordion($accordion_name, $accordion_json, $namespace) {
    	$this->name_space = $namespace;
        $this->accordion_name = $this->name_space . "." . $accordion_name;
        $html_string = "var " . $this->accordion_name . " = new dhtmlXAccordion('" . $accordion_json . "')" . "\n";
        return $html_string;
    }

    /** 
     * Sets the calendar name.
     * @param String $accordion_name Accordion name to be attached
     * @param String $namespace      Namespace
     */
    function init_by_attach($accordion_name, $namespace) {
        $this->name_space = $namespace;
        $this->accordion_name = $this->name_space . "." . $accordion_name;
    }
    
    /**
     * Loads accordion.
     * @param  String $accordion_json JSON accordion structure
     * @return String html.
     */
    function load_accordion($accordion_json) {        
        $html_string = $this->accordion_name . ".loadStruct(" . $accordion_json . ");"  . "\n";
        return $html_string;
    }

    /**
     * Sets skin.
     * @param String $skin_name Name of a skin
     * @return String html.
     */
    function set_skin($skin_name) {
        $html_string = $this->accordion_name . ".setSkin('" . $skin_name . "');" . "\n";
        return $html_string;
    }
    
    /**
     * Sets path to icon.
     * @param String $icon_path Path to icon
     * @return String html.
     */
    function set_icon_path($icon_path) {
        $html_string = $this->accordion_name . ".setIconsPath('" . $icon_path. "')" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxlayout to particular cell in layout.
     * @param  String $layout_name    Layout name
     * @param  String $accordion_cell Cell id
     * @param  String $pattern        Pattern
     * @param  String $cell_json      JSON for the cell of the layout
     * @return String html.
     */
    function attach_layout_cell($layout_name, $accordion_cell, $pattern, $cell_json) {
        $html_string = $this->name_space . "." . $layout_name . " = " . $this->accordion_name . ".cells('" . $accordion_cell . "').attachLayout({
            	pattern:\"" . $pattern . "\"" . "\n" .
                ",cells: " . $cell_json . "\n" .
                "});" . "\n";
        return $html_string;
    }
    
    /**
     * Attaches tree component on accordion.
     * @param  String $accordion_cell Cell of accordion where component to be attached
     * @param  String $form_json      Form json structure
     * @return String html.
     */
    function attach_form($accordion_cell, $form_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachForm(" . $form_json . ")";
        return $html_string;
    }

    /**
     * Attach tree component on accordion.
     * @param  String $tree_name      Tree json structure
     * @param  String $accordion_cell Cell of accordion where component to be attached
     * @return String html.
     */
    function attach_tree_cell($tree_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $tree_name . " = " .$this->accordion_name . ".cells('" . $accordion_cell. "').attachTree()" . "\n";
        return $html_string;
    }
    
    /**
     * Attaches grid component on accordion.
     * @param String $grid_name      Grid to be attached
     * @param String $accordion_cell Id of accordion where grid is to be attached
     * @return String html.
     */
    function attach_grid_cell($grid_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $grid_name . "=" . $this->accordion_name . ".cells('" . $accordion_cell. "').attachGrid();" . "\n";
        return $html_string;
    }

    /**
     * Attaches tabbar component on accordion.
     * @param String $accordion_cell Cell of accordion where component to be attached
     * @param String $tab_json       Tab json structure
     * @return String html.
     */
    function attach_tab($accordion_cell, $tab_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachTabbar(" . $tab_json . ")";
        return $html_string;
    }

    /**
     * Attaches dataview component on accordion.
     * @param String $accordion_cell Cell of accordion where component to be attached
     * @param String $data_view_json Dataview json structure
     * @return String html.
     */
    function attach_data_view($accordion_cell, $data_view_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachDataView(" . $data_view_json . ")";
        return $html_string;
    }

    /**
     * Attaches toolbar on accordion.
     * @param String $toolbar_name   Toolbar name
     * @param String $accordion_cell Cell of accordion where component to be attached
     * @return String html.
     */
    function attach_toolbar_cell($toolbar_name, $accordion_cell) {
        $html_string = $this->name_space . "." . $toolbar_name . " = " . $this->accordion_name . ".cells('" . $accordion_cell . "').attachToolbar();" . "\n";
        return $html_string;
    }


    /**
     * Attaches dhtmlxMenu to the accordion cell.
     * @param  String $menu_name Menu name
     * @param  String $cell      Cell id
     * @return String html.
     */
    function attach_menu_cell($menu_name, $cell) {
        $html_string = $this->name_space . '.' . $menu_name . ' = ' . $this->accordion_name . ".cells('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }

    /**
     * Attaches ribbon on accordion.
     * @param String $accordion_cell Cell of accordion where component to be attached
     * @param String $ribbon_json    Ribbon json config
     * @return String html.
     */
    function attach_ribbon($accordion_cell, $ribbon_json) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell. "').attachRibbon(" . $ribbon_json . ")";
        return $html_string;
    }

    /**
     * Attaches status bar.
     * @param  Char    $cell            Cell value
     * @param  Boolean $is_paging       Enable paging
     * @param  String  $status_bar_text Json configuration for status bar
     * @return String html.
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
     * Attaches URL to accordion.
     * @param  String $accordion_cell Cell of accordion where component to be attached
     * @param  String $url            URL string
     * @param  String $url_param      URL get parameter in JSON structure
     * @return String html.
     */
    function attach_url ($accordion_cell, $url, $url_param) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachURL('" . $url . "', true, " . $url_param . ");";
        return $html_string;
    }

    /**
     * Attaches html.
     * @param  String $accordion_cell Cell of accordion where component to be attached
     * @param  String $html_body      Html string to be attached]
     * @return String html.
     */
    function attach_html_string($accordion_cell, $html_body) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachHTMLString('" . $html_body . "');";
        return $html_string;
    }

    /**
     * Attaches an html object to a cell.
     * @param  String $accordion_cell Cell of accordion where component to be attached]
     * @param  String $object_id      Html object id
     * @return String html.
     */
    function attach_object($accordion_cell, $object_id) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').attachObject('" . $object_id . "');";
        return $html_string;
    }

    /**
     * Adds any user-defined handler to available events. This function can be defined in main page itself.
     * @param  String $event_id       Variable name to store event
     * @param  String $event_name     Name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxtoolbar_events.html
     * @param  String $event_function User defined function name, which will be called on particular event
     * @return String html.
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
     * Detach event.
     * @param  String $event_id Event id
     * @return String html.
     */
    function detach_event($event_id) {
        $html_string = $this->accordion_name . ".detachEvent('". $event_id ."');" . "\n";
        return $html_string;
    }

    /**
     * Docks accordion cells.
     * @param  String $accordion_cell Cell id of accordion
     * @return String html.
     */
    function dock_accordion($accordion_cell) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').dock();";
        return $html_string;
    }

    /**
     * Undocks accordion cells.
     * @param  String $accordion_cell Cell id of accordion
     * @return String html.
     */
    function undock_accordion($accordion_cell) {
        $html_string = $this->accordion_name . ".cells('" . $accordion_cell . "').undock();";
        return $html_string;
    }

    /**
     * Destructor, unloads toolbar.
     * @param String $accordion_name Dhtmlx accordion object
     * @return String html.
     */
    function unload() {
        $html_string = $this->accordion_name . ".unload();" . "\n";
        $html_string .= $this->accordion_name . " = null;";
        return $html_string;
    }
}
?>