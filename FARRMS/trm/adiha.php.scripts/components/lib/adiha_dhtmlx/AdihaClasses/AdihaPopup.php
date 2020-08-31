<?php

class AdihaPopup {

    public $popup_name;

    /**
     * init_script() [initializes script resources required to popup]
     */
    private function init_script() {
        global $app_php_script_loc, $app_adiha_loc;
        $html_string = '';
        $html_string .= "<script type='text/javascript'>";
        return $html_string;
    }

    /**
     * init_form() [initializes popup.]
     * @param [string] popup_name [is the name of the popup]
     * @return [string] html_string [creates and return DHTMLX popup object]
     */
    function init_popup($popup_name) {
        $this->popup_name = $popup_name;
        //$html_string = $this->init_script();
        $html_string .= "var  " . $this->popup_name . " = new dhtmlXPopup();";
        //$html_string .= $this->close_script();
        return $html_string;
    }

    /**
     * close_script [Close script tag]
     */
    function close_script() {
        $html_string = "</script>";
        return $html_string;
    }

    /**
     * init_by_attach() [sets the popup name]
     * @param [string] $popup_name  [popup name to be attached]
     */
    function init_by_attach($popup_name) {
        $this->popup_name = $popup_name;
        return;
    }

    /**
     * hide_popup [Hides the popup]
     */
    function hide_popup() {
        $html_string = $this->popup_name . ".hide();";
        return $html_string;
    }

    /**
     * attach_HTML() [attaches HTML to popup. Usually for attaching php file in iframe inside of popup.]
     * @param [mixed] src [is the source path to the php file that is to be displayed in popup from where this function has been called.]
     * @param [int] width [is the width of the popup]
     * @param [int] height [is the height of the popup]
     * @return [string] html_string [attaches HTML in DHTMLX popup object]
     */
    function attach_HTML($src, $width, $height) {
        $html_string = "" . $this->popup_name . ".attachHTML('<iframe style=" . '"' . "width:" . $width . "px;height:" . $height . "px;" . '"' . " src=" . '"' . $src . '"' . "></iframe>');" . "";
        return $html_string;
    }

    /**
     * show_popup() [shows the popup.]
     * @param [int] x_cordinates [is the x cordinates for the popup]
     * @param [int] y_cordinates [is the height of the popup]
     * @return [string] html_string [shows DHTMLX popup object]
     */
    function show_popup($x_cordinates, $y_cordinates) {
        $html_string = $this->popup_name . ".show(" . $x_cordinates . "," . $y_cordinates . ",50,50);";
        return $html_string;
    }

}

?>