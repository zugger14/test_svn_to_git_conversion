<?php

/**
 * It handles report type: IMAGE
 *
 * @author mshrestha
 */
class RDL_Image extends RDL_Item {

    public $arr_image = array();

    public function set_image($content, $name) {
        array_push($this->arr_image, array(
            'Source' => 'External',
            'Value' => $content,
            'ToolTip' => $name,
            'Top' => $this->top,
            'Left' => $this->left,
            'Width' => $this->width,
            'Height' => $this->height,
            'ZIndex' => '2',
            'Style' => array(
                'Border' => array('Style' => 'None')
            ),
            '@attributes' => array('Name' => $this->name)
        ));
    }

}