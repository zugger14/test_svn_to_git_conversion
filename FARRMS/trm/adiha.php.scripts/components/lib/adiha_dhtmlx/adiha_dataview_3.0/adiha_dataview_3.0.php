<?php

class AdihaDataView {

    public $dataview_name;
    public $layout_name;
    public $layout_cell;

    /*
     * [init_script Initialize Script]
     */

    function init_script() {
        $html_string = "<script type='text/javascript'>";
        $html_string .= "hideHourGlass();" . "\n";
        $html_string .= "$(function(){" . "\n";
        $html_string .= "	load_dataview();" . "\n";
        $html_string .= "});" . "\n";
        $html_string .= "function load_dataview() {" . "\n";
        return $html_string;
    }

    /*
     * [close_layout Close script tag]
     */

    function close_dataview() {
        global $app_php_script_loc, $app_adiha_loc;
        $html_string = "}" . "\n";
        $html_string .= $this->init_functions();
        $html_string .= "</script>" . "\n";
        return $html_string;
    }

    /*
     * [init_dataview Initialize dataview]
     * @param  [string] $dataview_name    [dataview Name, string without space.]
     * @param  [int] $width           [Width of dataview]    
     * @param  [int] $height          [Height of dataview]
     * @param  [string] $template     [Templates define the way data is rendered inside of DataView. e.g <font><b>"#Package#</font></b> : #Version#<br/>#Maintainer#"]
     * @param  [string] $tooltip      [similar to Templates, tooltip define the way data is rendered inside of DataView. e.g <font><b>"#Package#</font></b> : #Version#<br/>#Maintainer#"]

     */

    function init_dataview($dataview_name, $width, $height, $template, $tooltip) {
        global $app_php_script_loc, $app_adiha_loc;

        $this->dataview_name = $dataview_name;

        $html_string .= $this->init_script();

        $html_string .= 'dataview_' . $this->dataview_name . '= new dhtmlXDataView({container:"' . $this->dataview_name . '",' . "\n";
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
        $html_string .= '});';
        return $html_string;
    }

    /*
     * [init_dataview_by_attach Initialize dataview when it is attached to other object]
     * @param  [string] $dataview_name    [dataview Name, string without space.]
     * @param  [string] $layout_name     [layout Name where the dataview is attached.]
     * @param  [string] $layout_cell     [layout Cell Name where the dataview is attached.]

     */

    public function init_dataview_by_attach($dataview_name, $layout_name, $layout_cell) {
        global $app_php_script_loc, $app_adiha_loc;

        $this->dataview_name = $dataview_name;
        $this->layout_name = $layout_name;
        $this->layout_cell = $layout_cell;
        return $html_string;
    }

    /*
     * [load_dataview_functions Load Data view functions]

     */

    public function init_functions_attach() {
        $html_string = '<script>';
        $html_string.= $this->init_functions();
        $html_string .= '</script>';
        return $html_string;
    }
     function init_functions() {
        $html_string .= $this->refresh_dataview_data();
        $html_string .= $this->flush_dataview_data();
        return $html_string;
     }

    /*
     * [refresh_dataview_data Returns functions to refresh dataview with JSON data]

     */

    private function refresh_dataview_data() {
        global $app_php_script_loc, $app_adiha_loc;
        $html_string = 'function refresh_dataview_' . $this->dataview_name . '(data) {';
        $html_string .= $this->showprogress_dataview();
        $html_string .= '		var php_path = "' . $app_php_script_loc . '";';
        $html_string .= '		var result = "";';
        $html_string .= '		result = adiha_post_data("return_json", data,"","","callback_' . $this->dataview_name . '");';
        $html_string .= '	} ';
        $html_string .= '	function callback_' . $this->dataview_name . '(result){ ';
        $html_string .= 'dataview_' . $this->dataview_name . '.clearAll();';
        $html_string .= 'dataview_' . $this->dataview_name . '.parse(result,"json");';
        $html_string .= $this->hideprogress_dataview();
        $html_string .= '}';
        return $html_string;
    }
     /*
     * [flush_dataview_data flushes all the loaded data from dataview.]

     */
     private function flush_dataview_data() {
        global $app_php_script_loc, $app_adiha_loc;
        $html_string = 'function flush_dataview_' . $this->dataview_name . '() {';
        $html_string .= 'dataview_' . $this->dataview_name . '.clearAll();';
        $html_string .= '}';
        return $html_string;
    }

    /*
     * [showprogress_dataview Show data loading image]

     */

    private function showprogress_dataview() {
        $html_string = $this->layout_name . ".cells('" . $this->layout_cell . "').progressOn();";
        return $html_string;
    }

    /*
     * [hideprogress_dataview Hide data loading image]

     */

    private function hideprogress_dataview() {
        $html_string = $this->layout_name . ".cells('" . $this->layout_cell . "').progressOff();";
        return $html_string;
    }

    /*
     * [attach_dataview_events - adds any user-defined handler to available events]
     * @param  [string] $event_name [name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxdataview_events.html]
     * @param  [string] $event_function [user defined function name, which will be called on particular event. This function can be defined in main page itself.]
     */

    public function attach_dataview_events($event_name, $event_function) {

        $html_string = 'dataview_' . $this->dataview_name . ".attachEvent('" . $event_name . "', $event_function);" . "\n";
        return $html_string;
    }

}
?>



