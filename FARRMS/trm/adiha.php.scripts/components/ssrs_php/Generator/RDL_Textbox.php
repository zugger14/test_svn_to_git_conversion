<?php

/**
 * Description of RDL_Textbox
 *
 * @author mshrestha
 */
class RDL_Textbox extends RDL_Item {

    public $arr_textbox = array();

    public function set_textbox($content, $font, $font_size, $font_style, $dataset_name) {
        $tmp_array = array(
            'CanGrow' => 'true',
            'KeepTogether' => 'true',
            'Paragraphs' => array(
                'Paragraph' => array(
                    'TextRuns' => array(
                        'TextRun' => array(
                            'Value' => '=First(Fields!FunctionValue.Value, "' . $dataset_name . '")',
                            'Style' => array(
                                'FontFamily' => $font,
                                'FontSize' => $font_size,
                                'Color' => 'Black'
                            )
                        )
                    ),
                    'Style' => ''
                )
            ),
            'rd:DefaultName' => $this->name,
            'Top' => $this->top,
            'Left' => $this->left,
            'Width' => $this->width,
            'Height' => $this->height,
            'ZIndex' => '2',
            'Style' => array(
                'PaddingLeft' => '0pt',
                'PaddingRight' => '0pt',
                'PaddingTop' => '0pt',
                'PaddingBottom' => '0pt',
            ),
            '@attributes' => array('Name' => $this->name)
        );
        if ($font_style[0] == '1') {
            $tmp_array['Paragraphs']['Paragraph']['TextRuns']['TextRun']['Style']['FontWeight'] = 'Bold';
        }
        if ($font_style[1] == '1') {
            $tmp_array['Paragraphs']['Paragraph']['TextRuns']['TextRun']['Style']['FontStyle'] = 'Italic';
        }
        if ($font_style[2] == '1') {
            $tmp_array['Paragraphs']['Paragraph']['TextRuns']['TextRun']['Style']['TextDecoration'] = 'Underline';
        }
        array_push($this->arr_textbox, $tmp_array);
    }

}