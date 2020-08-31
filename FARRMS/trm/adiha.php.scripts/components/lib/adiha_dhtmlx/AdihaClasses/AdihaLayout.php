<?php
/**
 *  @brief AdihaLayout
 *  
 *  @par Description
 *  This class is used to create a layout
 *  
 *  @copyright Pioneer Solutions
 */
class AdihaLayout {

    public $layout_name; //!< Name of the layout
    public $name_space; //!< Name space
    private $init_type; //!< Initialization type

    /**
     * Init_script,Initialize Script.
     * @return String JS to initialize script
     */
    private function init_script() {
        global $app_php_script_loc;
        $html_string = "<script type='text/javascript'>";
        $html_string .= "hideHourGlass();" . "\n";
        $html_string .= "$(function(){" . "\n";
        $html_string .= "	load_layout();" . "\n";
        $html_string .= "});" . "\n";
        $html_string .= $this->name_space . " = {};"  . "\n";
        $html_string .= $this->name_space . ".pages = {};"  . "\n";
        $html_string .= "function load_layout() {" . "\n";
        return $html_string;
    }

    /**
     * close_layout,Close script tag.
     * @return String JS close script
     */
    function close_layout() {
        if ($this->init_type == 1) {
            $html_string = "}" . "\n";
            $html_string .= "</script>" . "\n";
            return $html_string;
        }        
    }

    /**
     * Initialize layout.
     * @param  String $layout_name   Layout Name, String without space.
     * @param  type $parent_object   Parent element id for layout.
     * @param  String $pattern       Pattern for layout. Example: 3L, 1C... for more infor: http://docs.dhtmlx.com/layout__patterns.html
     * @param  String $cells_jsoned  JSON to create cell  
     * @param  String $namespace     Namespace
     * @return String html.
     */
    function init_layout($layout_name, $parent_object, $pattern, $cells_jsoned = "", $namespace) {
        $this->init_type = 1;
        $this->name_space = $namespace;
        $this->layout_name = $this->name_space . "." . $layout_name;

        $html_string = $this->init_script();
        
        $html_string .= $this->layout_name . " = new dhtmlXLayoutObject({" . "\n";
        $html_string .= "	pattern:\"" . $pattern . "\"," . "\n";
        if ($parent_object != '') {
            $html_string .= "	parent:\"" . $parent_object . "\"," . "\n";
            $html_string .= "	offsets: {
										top:    0,
										right:  2,
										bottom: 2,
										left:   2
									}" . "\n";
            $html_string .= "   ,skin: 'dhx_web'" . "\n";
        } else {
            $html_string .= "	parent:document.body," . "\n";
            $html_string .= "	offsets: {
										top:    0,
										right:  0,
										bottom: 0,
										left:   0
									}" . "\n";
        }

        if ($cells_jsoned != "") {
            $html_string .= ",cells:" . $cells_jsoned . "\n";
        }

        $html_string .= "}); " . "\n";
        $html_string .= ' global_layout_object = ' . $this->layout_name . ';' . "\n";
        return $html_string;
    }

    /**
     * Initialize layout when attached to a layout.
     * @param  String $layout_name Layout Name, string without space
     * @param  String $name_space  Namespace
     */
    function init_by_attach($layout_name, $name_space) {
        $this->init_type = 2;
        $this->name_space = $name_space;
        $this->layout_name = $name_space . "." . $layout_name;
    }

    /**
     * Attach header to layout from HTML element.
     * @param  String $header_element_id  HTML element id. Element should contains header content.
     * http://docs.dhtmlx.com/api__dhtmlxlayout_attachheader.html
     * @return String html.  
     */
    function attach_header($header_element_id) {
        $html_string = $this->layout_name . ".attachHeader('" . $header_element_id . "');" . "\n";
        return $html_string;
    }

    /**
     * Attach footer to layout from HTML element
     * @param  String $footer_element_id HTML element id. Element should contains footer content.
     * http://docs.dhtmlx.com/api__dhtmlxlayout_attachfooter.html
     *  @return String html.  
     */
    function attach_footer($footer_element_id) {
        $html_string = $this->layout_name . ".attachFooter('" . $footer_element_id . "');" . "\n";
        return $html_string;
    }

    /**
     *  Detach header from layout.
     * @return String html.
     */
    function detach_header() {
        $html_string = $this->layout_name . ".detachHeader();" . "\n";
        return $html_string;
    }

    /**
     * Set header for layout cell]
     * @param $String $cell Cell id Example a,b]
     * @param $String $text Header text
     * @return  String html.
     */
    function set_text($cell, $text) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').setText('" . $text . "');" . "\n";
        return $html_string;
    }

    /**
     * Attach form to a cell in layout.
     * @param  String   $form_name       Form name
     * @param  String   $cell            Cell name(Example a,b,c)
     * @param  String   $form_json       Form JSON 
     * @param  Integer  $dependent_combo Loads combo value according to parent value selected
     * @return String html.
     */
    function attach_form($form_name, $cell, $form_json = false, $dependent_combo = '') {
        $html_string = $this->name_space . "." . $form_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachForm();" . "\n";
        

        $call_back_func = '';
        if ($dependent_combo != '') {
            $call_back_func = '), function() { ';
            $call_back_func .=      'var form_obj = ' . $this->name_space . '.' . $form_name . '.getForm();';
            $call_back_func .=      'load_dependent_combo("' . $dependent_combo . '"  , 0 , form_obj);';     
            $call_back_func .= '}';
        } else {
            $call_back_func .= ')';
        }

        if ($form_json) {
            $html_string = $html_string. $this->name_space . "." . $form_name . ".loadStruct(get_form_json_locale(". $form_json . $call_back_func .");" . "\n";
        }
        return $html_string;
    }
   
    /**
     * Detach header from layout.
     * @return String html.
     */
    function detach_footer() {
        $html_string = $this->layout_name . ".detachFooter();" . "\n";
        return $html_string;
    }

    /**
     * Sets autosize for the layout]
     * @param  String $horizontal_resize Comma seperated list of cells that will be autosized horizontally
     * @param  String $vertical_resize   Comma seperated list of cells that will be autosized vertically
     * @return  String html.
     */
    function set_auto_size($horizontal_resize, $vertical_resize) {
        $html_string = $this->layout_name . ".setAutoSize('" . $horizontal_resize . "', '" . $vertical_resize . "');" . "\n";
        return $html_string;
    }

    /**
     * Set predefined skin.
     * @param String $skin_name Name of the skin
     * @return String html. 
     */
    function set_skin($skin_name) {
        $html_string = $this->layout_name . ".setSkin('" . $skin_name . "');" . "\n";
        return $html_string;
    }

    /**
     * Adjusts layout's outer size when parent's size changed.
     * @return  String html.
     */
    function set_sizes() {
        $html_string = $this->layout_name . ".setSizes();" . "\n";
        return $html_string;
    }

    /**
     * [set_offsets - sets outer offsets for layout. This function overwrites the offset defined during initialization.]
     * @param  [string] $offset_list [- ]offset values Example: 'top: number, right: number, bottom: number, left: number']
     * @return String JS to set offset
     */
    function set_offsets($offset_list) {
        $html_string = $this->layout_name . ".setOffsets({" . $offset_list . "});" . "\n";
        return $html_string;
    }

    /**
     * [unload - destructor, unloads layout]
     * @return String JS to unload layout
     */
    function unload() {
        $html_string = $this->layout_name . ".unload();" . "\n";
        $html_string .= $this->layout_name . "= null;";
        return $html_string;
    }

    /**
     * Adds any user-defined handler to available events.
     * @param  String $event_id     Variable name to store event
     * @param  String $event_name   Name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxlayout_events.html
     * @param  String $event_function User defined function name, which will be called on particular event. This function can be defined in main page itself
     * @return  String html.
     */
    function attach_event($event_id = '', $event_name, $event_function) {
        if ($event_id == '') {
            $html_string = $this->layout_name . ".attachEvent('" . $event_name . "', " . $event_function . ");" . "\n";
        } else {
            $html_string = "var " . $event_id . "=" . $this->layout_name . ".attachEvent('" . $event_name . "'," . $event_function . ");" . "\n";
        }
        return $html_string;
    }

    /**
     * Detach event
     * @param  String $event_id event_id
     * @return String html.
     */
    function detach_event($event_id) {
        $html_string = $this->layout_name . ".detachEvent('" . $event_id . "');" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxToolbar to layout's top.
     * @param  String $toolbar_name Toolbar name
     * @return String html. 
     */
    function attach_toolbar($toolbar_name) {
        $html_string = $this->name_space . "." . $toolbar_name . " = " . $this->layout_name . ".attachToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxToolbar to  particular cell in layout.
     * @param  String $toolbar_name Toolbar name
     * @param  String $cell         Cell id
     */
    function attach_toolbar_cell($toolbar_name, $cell) {
        $html_string = $this->name_space . "." . $toolbar_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxGrid to  particular cell in layout]
     * @param  String $grid_name Grid name
     * @param  String $cell      Cell id
     */
    function attach_grid_cell($grid_name, $cell) {
        $html_string = $this->name_space . "." . $grid_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachGrid();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxGrid to particular cell in layout.
     * @param  String $grid_name  Grid name
     * @param String $cell        Cell id
     * @param String $layout_name Layout name
     * @return String JS to attach grid in layout cell
     */
    function attach_grid_custom_layout($grid_name, $cell, $layout_name) {
        $html_string = $this->name_space . "." .  $grid_name . " = " . $layout_name . ".cells('" . $cell . "').attachGrid();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxToolbar to  particular cell in layout
     * @param  String $toolbar_name Toolbar name
     * @param  String $cell         Cell id
     * @param  String $layout_name  Layout name
     * @return String JS to attach toolbar
     */
    function attach_toolbar_custom_layout($toolbar_name, $cell, $layout_name) {
        $html_string = $this->name_space . "." . $toolbar_name . " = " . $layout_name . ".cells('" . $cell . "').attachToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxTree to  particular cell in layout.
     * @param  String $tree_name    Tree name
     * @param  String $cell         Cell id
     * @return String JS to attach tree
     */
    function attach_tree_cell($tree_name, $cell) {
        $html_string = $this->name_space . "." . $tree_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachTree();" . "\n";
        return $html_string;
    }
    
    /**
     * Attaches dhtmlxAccordion to  particular cell in layout.
     * @param  String $accordion_name Accordion name
     * @param  String $cell           Cell id
     * @param  String $accordion_json JSON accordion
     * @return String JS to attach accordion
     */
    function attach_accordion_cell($accordion_name, $cell) {
        $html_string = $this->name_space . "." .  $accordion_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachAccordion();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxTab to  particular cell in layout
     * @param  String $tab_name     Tab name
     * @param  String $cell         Cell id
     * @param  String $json_tab     JSON tabs structure only
     * @return String JS to attach tabbar
     */
    function attach_tab_cell($tab_name, $cell, $json_tab = '') {
        if ($json_tab == '') {
            $html_string = $this->name_space . "." . $tab_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachTabbar(); " . "\n";
        } else {
            $html_string = $this->name_space . "." . $tab_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachTabbar({
                tabs: get_tab_json_locale(" . $json_tab . ")
            })" . "\n";
        }
        return $html_string;
    }

    /**
     * Attaches dhtmlxTab structure to  particular cell in layout.
     * @param  String $tab_name         Tab name
     * @param  String $cell             Cell id
     * @param  String $json_tab_struct JSON tab structure which contains all possible tab parameters like mode, offsets and more
     * @return String HTML string
     */
    function attach_tab_structure($tab_name, $cell, $json_tab_struct = '') {
        if ($json_tab_struct == '') {
            $html_string = $this->name_space . "." . $tab_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachTabbar(); " . "\n";
        } else {
            $html_string = $this->name_space . "." . $tab_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachTabbar(" . $json_tab_struct . ");" . "\n";
        }
        return $html_string;
    }

    /**
     * Attaches dhtmlxTab to  particular cell in custom layout.
     * @param  String $tab_name     Tab name
     * @param  String $cell         Cell id
     * @param  String $json_tab     JSON tab
     * @param  String $layout_name  Layout name
     * @return String JS to attach tabbar in provided layout cell
     */
    function attach_tab_custom_layout($tab_name, $cell, $json_tab = '', $layout_name) {
        if ($json_tab == '') {
            $html_string = $this->name_space . "." . $tab_name . " = " . $layout_name . ".cells('" . $cell . "').attachTabbar(); " . "\n";
        } else {
            $html_string = $this->name_space . "." . $tab_name . " = " . $layout_name . ".cells('" . $cell . "').attachTabbar({
                tabs: get_tab_json_locale(" . $json_tab . ")
            });" . "\n";
        }
        
        return $html_string;
    }

    /**
     * Attaches dhtmlxlayout to  particular cell in layout.
     * @param  String $layout_name      Layout name
     * @param  String $cell             Cell id
     * @param  String $pattern          Pattern of the layout cell
     * @param  String $cell_json        JSON for the cell of the layout.
     * @return String JS to attach layout
     */
    function attach_layout_cell($layout_name, $cell, $pattern, $cell_json) {
        $html_string = $this->name_space . "." . $layout_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachLayout({
                pattern:\"" . $pattern . "\"" . "\n" .
                ",cells: " . $cell_json . "\n" .
                "});" . "\n";
        return $html_string;
    }

    /**
     * Attaches status bar in particular cell in layout
     * @param  String $grid_name        Grid name
     * @param  String $cell             Cell id
     * @param  Boolean $is_paging       true/false - true - display paging on status bar
     * @param  String $status_bar_text  Contet for status bar
     * @param  String $paging_area_name Name of the paging area which is optional
     * @return String JS to attach status bar
     */
    function attach_status_bar($cell, $is_paging, $status_bar_text = null, $paging_area_name = null) {
        if ($paging_area_name == null) $paging_area_name = $cell;
        
        if ($is_paging) {
            $html_string = $this->layout_name . ".cells('" . $cell . "').attachStatusBar({
                                height: 30,
                                text: '<div id=\"pagingArea_" . $paging_area_name . "\"></div>'
                            });";
        } else {
            $html_string = $this->layout_name . ".cells('" . $cell . "').attachStatusBar({
                                height: 31,
                                text: '" . $status_bar_text . "'
                            });";
        }
        
        return $html_string;
    }

    /**
     * Attaches dhtmlxdataview to  particular cell in layout
     * @param  String $dataview_name     Name of the dataview
     * @param  String $cell              Cell id
     * @param  Integer $width            Width
     * @param  Integer $height           Height
     * @param  String $template          Template
     * @param  String $tooltip           Tooltip
     * @return String JS to attach dataview
     */
    function attach_dataview($dataview_name, $cell, $width, $height, $template, $tooltip) {
        $html_string = $this->name_space . "." . $dataview_name . " = " . $this->layout_name . ".cells('" . $cell . "').attachDataView({" . "\n";
        $html_string .= " edit:true," . "\n";
        $html_string .= " type: {" . "\n";
        $html_string .= " template:" . '"' . $template . '"' . "," . "\n";
        $html_string .= " template_edit:" . '"<textarea class=' . "'dhx_item_editor'" . ' bind=' . "'obj.description_1'" . '>"' . ",\n";
        $html_string .= " padding: 10," . "\n";
        $html_string .= " height: " . $height . "," . "\n";
        $html_string .= " width: " . $width . "" . "\n";
        $html_string .= " }," . "\n";
        $html_string .= " tooltip:{" . "\n";
        $html_string .= " template:'" . $tooltip . "'" . "\n";
        $html_string .= "}, " . "\n";
        $html_string .= " drag: true, " . "\n";
        $html_string .= " select: true, " . "\n";
        $html_string .= "});";
        return $html_string;
    }

    /**
     * attach_layout_cell - Attaches dhtmlxdataview to  particular cell in custom layout
     * @param  String $dataview_name    Layout name
     * @param  String $cell             Cell id
     * @param  Integer $width            Width
     * @param  Integer $height           Height
     * @param  String $template         Template
     * @param  String $tooltip          Tooltip 
     * @param  String $layout           Layout
     * @return String JS to attach dataview in provided layout cell
     */
    function attach_dataview_custom_layout($dataview_name, $cell, $width, $height, $template, $tooltip, $layout) {
        $html_string = $this->name_space . "." .  $dataview_name . " = " . $layout . ".cells('" . $cell . "').attachDataView({" . "\n";
        $html_string .= " edit:true," . "\n";
        $html_string .= " type: {" . "\n";
        $html_string .= " template:" . '"' . $template . '"' . "," . "\n";
        $html_string .= " template_edit:" . '"<textarea class=' . "'dhx_item_editor'" . ' bind=' . "'obj.description_1'" . '>"' . ",\n";
        $html_string .= " padding: 10," . "\n";
        $html_string .= " height: " . $height . "," . "\n";
        $html_string .= " width: " . $width . "" . "\n";
        $html_string .= " }," . "\n";
        $html_string .= " tooltip:{" . "\n";
        $html_string .= " template:'" . $tooltip . "'" . "\n";
        $html_string .= "}, " . "\n";
        $html_string .= " drag: true, " . "\n";
        $html_string .= " select: true, " . "\n";
        $html_string .= "});";
        return $html_string;
    }

    /**
     * Attaches HTML object to layout's cell.
     * @param  String $cell   cell id
     * @param  String $obj_id Id of the html object
     * @return String JS to attach object
     */
    function attach_html_object($cell, $obj_name) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').attachObject('" . $obj_name . "')" . "\n";
        return $html_string;
    }
    
    /**
     * Attaches URL to layout's cell.
     * @param  String $cell Cell id
     * @param  String $url  Attaching URL
     * @return String JS to attach URL
     */
    function attach_url($cell, $url) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').attachURL('" . $url . "')" . "\n";
        return $html_string;
    }

    /**
     * Attach dhtmlxMenu to layout.
     * @param  String $menu_name  Menu name
     * @return String JS to attach menu
     */
    function attach_menu($menu_name) {
        $html_string = $this->name_space . "." . $menu_name . " = " . $this->layout_name . ".attachMenu();" . "\n";
        return $html_string;
    }

    /**
     * Attaches dhtmlxMenu to layout's top]
     * @param  String $menu_name        Menu name
     * @param  String $parent_obj       Parent div - this must be defined as a layout cell header text
     * @param  json string $menu_json   Menu Json
     * @return String JS to attach menu with items
     */
    function attach_menu_layout_cell($menu_name, $cell, $menu_json, $onClick) {
        $html_string = $this->name_space . '.' . $menu_name . ' = ' . $this->layout_name . ".cells('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/",'. "\n";
        $html_string .= '   items:' . $menu_json . "\n";
        $html_string .= '});';
        $html_string .= $this->name_space . '.' . $menu_name . '.attachEvent("onClick",' . $onClick . ')' . "\n";
        return $html_string;
    }
    
    /**
     * Attaches dhtmlxMenu to the layout cell.
     * @param  String $menu_name    Menu name
     * @param  String $cell         Cell id
     * @return String JS to attach menu
     */
    function attach_menu_cell($menu_name, $cell) {
        $html_string = $this->name_space . '.' . $menu_name . ' = ' . $this->layout_name . ".cells('" . $cell . "').attachMenu({". "\n";
        $html_string .= '   icons_path: js_image_path + "dhxmenu_web/"'. "\n";
        $html_string .= '});';
        return $html_string;
    }

    /**
     * Attaches dhtmlxRibbon to layout's top
     * @param  String $ribbon_name Ribbon name
     * @return String JS to attach Ribbon
     */
    function attach_ribbon($ribbon_name) {
        $html_string = $this->name_space . "." .  $ribbon_name . " = " . $this->layout_name . ".attachRibbon();" . "\n";
        return $html_string;
    }

    /**
     * Detaches dhtmlxRibbon from layout's top.
     * @param  String $ribbon_name Ribbon name
     * @return String JS to detach Ribbon
     */
    function detach_ribbon($ribbon_name) {
        $html_string = $this->layout_name . ".detachRibbon();" . "\n";
        $html_string .= $this->name_space . "." . $ribbon_name . " = null;";
        return $html_string;
    }

    /**
     * Detaches dhtmlxMenu from layout's top.
     * @param  String $menu_name Menu name
     * @return String JS to detach menu
     */
    function detach_menu($menu_name) {
        $html_string = $this->layout_name . ".detachMenu();" . "\n";
        $html_string .= $this->name_space . "." . $menu_name . " = null;";
        return $html_string;
    }

    /**
     *  Detaches dhtmlxToolbar from layout's top.
     * @param  String $toolbar_name Toolbar name
     * @return String JS to detach toolbar
     */
    function detach_toolbar($toolbar_name) {
        $html_string = $this->layout_name . ".detachToolbar();" . "\n";
        $html_string .= $this->name_space . "." . $toolbar_name . " = null;";
        return $html_string;
    }

    /**
     * Returns dhtmlxMenu instance attached to layout's top
     * @param  String $attached_menu Variable to return attached menu
     * @return String JS to get attached menu instance
     */
    function get_attached_menu($attached_menu) {
        $html_string = $this->name_space . "." .  $attached_menu . " = " . $this->layout_name . ".getAttachedMenu();" . "\n";
        return $html_string;
    }

    /**
     * Returns dhtmlxRibbon instance attached to layout's top
     * @param  String $attached_ribbon Variable to return attached ribbon
     * @return String JS to get attached ribbon instance
     */
    function get_attached_ribbon($attached_ribbon) {
        $html_string = $this->name_space . "." . $attached_ribbon . " = " . $this->layout_name . ".getAttachedRibbon();" . "\n";
        return $html_string;
    }

    /**
     * Returns dhtmlxRibbon instance attached to layout's top.
     * @param  String $attached_toolbar Variable to return attached toolbar
     * @return String JS to get attached toolbar instance
     */
    function get_attached_toolbar($attached_toolbar) {
        $html_string = $this->name_space . "." .  $attached_toolbar . " = " . $this->layout_name . ".getAttachedToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Hides dhtmlxMenu attached to layout's top
     * @return String JS to hide menu
     */
    function hide_menu() {
        $html_string = $this->layout_name . ".hideMenu();" . "\n";
        return $html_string;
    }

    /**
     * Hides dhtmlxRibbon attached to layout's top
     * @return String JS to hide ribbon
     */
    function hide_ribbon() {
        $html_string = $this->layout_name . ".hideRibbon();" . "\n";
        return $html_string;
    }

    /**
     * Hides dhtmlxToolbar attached to layout's top
     * @return String JS to hide toolbar
     */
    function hide_toolbar() {
        $html_string = $this->layout_name . ".hideToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Shows dhtmlxMenu attached to layout's top.
     * @return String JS to show menu
     */
    function show_menu() {
        $html_string = $this->layout_name . ".showMenu();" . "\n";
        return $html_string;
    }

    /**
     * Shows dhtmlxRibbon attached to layout's top.
     * @return String JS to show ribbon
     */
    function show_ribbon() {
        $html_string = $this->layout_name . ".showRibbon();" . "\n";
        return $html_string;
    }

    /**
     * shows dhtmlxToolbar attached to layout's top.
     * @return String JS to show toolbar
     */
    function show_toolbar() {
        $html_string = $this->layout_name . ".showToolbar();" . "\n";
        return $html_string;
    }

    /**
     * Shows header for layout cell.
     * @param  String $cell Name of the layout cell
     * @return String $html_string Returns the Html string with layout name, cells to show header.
     */
    function show_header($cell) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').showHeader();" . "\n";
        return $html_string;
    }

    /**
     * Hides header for layout cell
     * @param  String $cell Name of the layout cell
     * @return String $html_string Returns the Html string with layout name, cells to hide header. 
     */
    function hide_header($cell) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').hideHeader();" . "\n";
        return $html_string;
    }
   
    /**
     * Set height for layout cell.
     * @param String $cell    Name of the cell
     * @param Integer $height Height.
     * @return String JS to set cell height
     */
    function set_cell_height($cell, $height) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').setHeight('" . $height . "')" . "\n";
        return $html_string;
    }
    
    /**
     * Collapse cell.
     * @param  String $cell Cell(Example:a,b)
     * @return String JS to collapse cell
     */
    function collapse_cell($cell) {
        $html_string = $this->layout_name . ".cells('" . $cell . "').collapse();" . "\n";
        return $html_string;
    }

    /**
     * Progress On.
     * @return String JS to start progress bar
     */
    function progress_on() {
        $html_string = $this->layout_name . ".progressOn();" . "\n";
        return $html_string;
    }
}

?>