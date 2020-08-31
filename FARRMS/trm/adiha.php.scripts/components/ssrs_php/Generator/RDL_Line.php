<?php

/**
 * Description of RDL_Line
 *
 * @author mshrestha
 */
class RDL_Line extends RDL_Item {

    public $arr_line = array();
    public $ppi = 75;
    
    public function __construct($ssrs_config = null, $language_dict = null, $rdl_column_line_size = null, $rdl_column_line_style = null, $rdl_type = null, $process_id = null) {
        parent::__construct($ssrs_config, $language_dict, $rdl_type, $process_id);
        $this->rdl_column_line_size = $rdl_column_line_size;
        $this->rdl_column_line_style = $rdl_column_line_style;
    }

    public function set_line($color, $size, $style) {
        $x1 = $this->left;
        $y1 = $this->top;
        $x2 = $this->width - $x1;
        $y2 = $this->height - $y1;
        $tmp_array = array(
            'Top' => ($y1/$this->ppi).'in',
            'Left' => ($x1/$this->ppi).'in',
            'Width' => ($x2/$this->ppi).'in',
            'Height' => ($y2/$this->ppi).'in',
            'Style' => array(
                'Border' => array(
                    'Color' => $color,
                    'Style' => $this->rdl_column_line_style[$style][1],
                    'Width' => $this->rdl_column_line_size[$size][1]
                )
            ),
            '@attributes' => array('Name' => $this->name)
        );
        array_push($this->arr_line, $tmp_array);
    }

}