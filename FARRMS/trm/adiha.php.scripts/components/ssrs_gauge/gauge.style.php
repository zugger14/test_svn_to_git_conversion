<?php

/**
 * GaugeStyle
 * 
 * @package   
 * @author Pawan Adhikari
 * @copyright Pioneer Solutions Global
 * @version 2012
 * @access public
 */
class GaugeStyle {

    public static function get_style($gauge_style) {
        
        global $rdl_column_date_format_option, $rfx_report_default_param;
		require_once "../../../adiha.html.forms/_reporting/report_manager_dhx/report.global.vars.php";
        
        $style = array();
        #apply formattiing
        switch ($gauge_style['render_as']) {
            case '2':case '3'://Number or Currency
                $gauge_style_format = array();
                #currency
                if ($gauge_style['render_as'] == '3' && $gauge_style['currency'] > -1)
                    array_push($gauge_style_format, $gauge_style['currency']);
                array_push($gauge_style_format, '"#"');
                #thousand_seperation
                if ($gauge_style['thousand_seperation'] < 2) {
                    switch ($gauge_style['thousand_seperation']) {
                        case '0':
                            array_push($gauge_style_format, "Parameters!global_thousand_format.Value");
                            break;
                        case '1':
                            array_push($gauge_style_format, '",#"');
                            break;
                    }
                }
                #rounding
                if ($gauge_style['rounding'] > -2) {
                    switch ($gauge_style['rounding']) {
                        case '-1':
                            array_push($gauge_style_format, "Parameters!global_rounding_format.Value");
                            break;
                        default:
                            $strt = "#0." . str_repeat('0', $gauge_style['rounding']);
                            array_push($gauge_style_format, '"' . $strt . '"');
                    }
                }
                #merge all
                if (sizeof($gauge_style_format) > 0) {
                    $gauge_style_format = implode('+', $gauge_style_format);
                    $style['Format'] = "=" . $gauge_style_format;
                }
                break;
            case '5'://Percentage
                if ($gauge_style['rounding'] > -2) {
                    switch ($gauge_style['rounding']) {
                        case '-1':
                            $gauge_style_format = '="#"+Parameters!global_rounding_format.Value+"%"';
                            break;
                        default:
                            $strt = "#0." . str_repeat('0', $gauge_style['rounding']);
                            $gauge_style_format = "#" . $strt . "%";
                    }
                } else {
                    $gauge_style_format = "E";
                }
                $style['Format'] = $gauge_style_format;
                break;
            case '6'://Scientific
                if ($gauge_style['rounding'] > -2) {
                    switch ($gauge_style['rounding']) {
                        case '-1':
                            $gauge_style_format = '="E"+Parameters!global_science_rounding_format.Value';
                            break;
                        default:
                            $gauge_style_format = "E" . $gauge_style['rounding'];
                    }
                } else {
                    $gauge_style_format = "E";
                }
                $style['Format'] = $gauge_style_format;
                break;
            case '4'://Date
                if ($gauge_style['date_format'] == 0) {
					$style['Format'] = $rfx_report_default_param['global_date_format'];
				} else {
					$style['Format'] = $rdl_column_date_format_option[$gauge_style['date_format']][2];
				}
                break;
        }
        #font color
        $style['Color'] = (strlen($gauge_style['text_color']) > 0) ? $gauge_style['text_color'] : "Black";
        #font family
        $style['FontFamily'] = (strlen($gauge_style['font']) > 0) ? $gauge_style['font'] : 'Tahoma';

        #font size
        $style['FontSize'] = (strlen($gauge_style['font_size']) > 0) ? $gauge_style['font_size'] . 'pt' : '8pt';

        
        
        $font_style = explode(',', $gauge_style['font_style']);
        
        #font style - B I U
        if ($font_style[0] == 1)
            $style['FontWeight'] = 'Bold';
        if ($font_style[1] == 1)
            $style['FontStyle'] = 'Italic';
        if ($font_style[2] == 1)
            $style['TextDecoration'] = 'Underline';

        if (is_array($style) && sizeof($style) > 0) {
            return $style;
        } else {
            return NULL;
        }
    }
}

?>