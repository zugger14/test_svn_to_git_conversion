<?php

/**
	 *  @brief class ChartStyle 
     * 
	 *  @par Description
     * 
	 *  This class handles style of the chart used.
	 *  @copyright Pioneer Solutions
	 */
class ChartStyle {

    /**
     * gets style information of the chart used. 
     *
     * @param   array  $chart_style  array of chart styles information. 
     *
     * @return  array  returns array of chart style set. 
     */
    public static function get_style($chart_style) {
        global $rdl_column_date_format_option, $rfx_report_default_param, $rdl_column_currency_option;
		require_once "../../../adiha.html.forms/_reporting/report_manager_dhx/report.global.vars.php";
        $number_types = array(2, 3, 5, 6, 13, 14);
		if(isset($chart_style['render_as'])) {
			$is_number = (in_array($chart_style['render_as'], $number_types)) ? TRUE : FALSE;
		} else {
			$is_number = FALSE;
		}
        $style = array();
        #apply formattiing
        switch (($chart_style['render_as'] ?? '')) {
            case '2':case '3': case '13': //Number or Currency or Price
                $chart_style_format = array();
                #currency
                if (($chart_style['render_as'] == '3' || $chart_style['render_as'] == '13') && $chart_style['currency'] > -1)
                    array_push($chart_style_format, $rdl_column_currency_option[$chart_style['currency']][2]);
                array_push($chart_style_format, '"#"');
                #thousand_list
                if ($chart_style['thousand_list'] < 2) {
                    switch ($chart_style['thousand_list']) {
                        case '0':
                            array_push($chart_style_format, "Parameters!global_thousand_format.Value");
                            break;
                        case '1':
                            array_push($chart_style_format, '",#"');
                            break;
                    }
                }
                #rounding
                if ($chart_style['rounding'] > -2) {
                    switch ($chart_style['rounding']) {
                        case '-1':
                            if ($chart_style['render_as'] == '3'){
								array_push($chart_style_format, "Parameters!global_amount_rounding_format.Value");
							} else if ($chart_style['render_as'] == '13') {
								array_push($chart_style_format, "Parameters!global_price_rounding_format.Value");
							} else {
								array_push($chart_style_format, "Parameters!global_rounding_format.Value");
							}
                            break;
                        default:
                            $strt = "#0." . str_repeat('0', $chart_style['rounding']);
                            array_push($chart_style_format, '"' . $strt . '"');
                    }
                }
                #merge all
                if (sizeof($chart_style_format) > 0) {
                    $chart_style_format = implode('+', $chart_style_format);
                    $style['Format'] = "=" . $chart_style_format;
                }
                break;
            case '5'://Percentage
                if ($chart_style['rounding'] > -2) {
                    switch ($chart_style['rounding']) {
                        case '-1':
                            $chart_style_format = '="#"+Parameters!global_rounding_format.Value+"%"';
                            break;
                        default:
                            $strt = "#0." . str_repeat('0', $chart_style['rounding']);
                            $chart_style_format = "#" . $strt . "%";
                    }
                } else {
                    $chart_style_format = "E";
                }
                $style['Format'] = $chart_style_format;
                break;
            case '6'://Scientific
                if ($chart_style['rounding'] > -2) {
                    switch ($chart_style['rounding']) {
                        case '-1':
                            $chart_style_format = '="E"+Parameters!global_science_rounding_format.Value';
                            break;
                        default:
                            $chart_style_format = "E" . $chart_style['rounding'];
                    }
                } else {
                    $chart_style_format = "E";
                }
                $style['Format'] = $chart_style_format;
                break;
            case '4'://Date
                if ($chart_style['date_format'] == 0) {
					$style['Format'] = $rfx_report_default_param['global_date_format'];
				} else {
					$style['Format'] = $rdl_column_date_format_option[$chart_style['date_format']][2];
				}
                break;
			case '14': //Volume
                $chart_style_format = array();
                array_push($chart_style_format, '"#"');
                #thousand_list
                if ($chart_style['thousand_list'] < 2) {
                    switch ($chart_style['thousand_list']) {
                        case '0':
                            array_push($chart_style_format, "Parameters!global_thousand_format.Value");
                            break;
                        case '1':
                            array_push($chart_style_format, '",#"');
                            break;
                    }
                }
                #rounding
                if ($chart_style['rounding'] > -2) {
                    switch ($chart_style['rounding']) {
                        case '-1':
								array_push($chart_style_format, "Parameters!global_volume_rounding_format.Value");
                            break;
                        default:
                            $strt = "#0." . str_repeat('0', $chart_style['rounding']);
                            array_push($chart_style_format, '"' . $strt . '"');
                    }
                }
                #merge all
                if (sizeof($chart_style_format) > 0) {
                    $chart_style_format = implode('+', $chart_style_format);
                    $style['Format'] = "=" . $chart_style_format;
                }
                break;
        }
        #font color
        $style['Color'] = (isset($chart_style['text_color']) > 0) ? $chart_style['text_color'] : "Black";
        #font family
        $style['FontFamily'] = (isset($chart_style['font']) > 0) ? $chart_style['font'] : 'Tahoma';

        #font size
        $style['FontSize'] = (isset($chart_style['font_size']) > 0) ? $chart_style['font_size'] . 'pt' : '8pt';

        #font style - B I U
        if (($chart_style['bold_style'] ?? '') == 1)
            $style['FontWeight'] = 'Bold';
        if (($chart_style['italic_style'] ?? '') == 1)
            $style['FontStyle'] = 'Italic';
        if (($chart_style['underline_style'] ?? '') == 1)
            $style['TextDecoration'] = 'Underline';
		if ($is_number)
			$style['Language'] = "=Parameters!global_number_format_region.Value";
		
        if (is_array($style) && sizeof($style) > 0) {
            return $style;
        } else {
            return NULL;
        }
    }
}

?>