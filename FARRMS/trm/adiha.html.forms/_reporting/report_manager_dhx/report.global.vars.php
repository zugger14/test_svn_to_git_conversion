<?php
/**
* Report global vars screen
* @copyright Pioneer Solutions
*/
?>
<?php

/*
 * This file has all global variables needed for Report Manager; try to make long unique array names to avoid collisions
 * TODO: Shift appropriate datasets to Database 
 */
/**
 * Convert's Standard PHP date format to SSRS date format
 * @param string $date_format_string Standard PHP date format
 * @return string SSRS Date Format
 */
function get_ssrs_date_format($date_format_string) {
    //$date_format_string = str_replace('dd', 'd', $date_format_string);
    //$date_format_string = str_replace('mm', 'M', $date_format_string);
    return $date_format_string;
}

$global_decimal_separator = '.';
$global_group_separator = ',';
$global_thousand_format = $global_group_separator . '#';
$global_rounding_format = '#0' . $global_decimal_separator . str_repeat("0", $GLOBAL_NUMBER_ROUNDING);
$global_price_rounding_format = '#0' . $global_decimal_separator . str_repeat("0", $GLOBAL_PRICE_ROUNDING);
$global_volume_rounding_format = '#0' . $global_decimal_separator . str_repeat("0", $GLOBAL_VOLUME_ROUNDING);
$global_amount_rounding_format = '#0' . $global_decimal_separator . str_repeat("0", $GLOBAL_AMOUNT_ROUNDING);

$global_number_format_region = $ssrs_config['REPORT_REGION'];
if ($DECIMAL_SEPARATOR == ',') {
	$global_number_format_region = 'de-DE'; //Euro format number
}

#report view params (Global/User)
$rfx_report_default_param = array(
    'report_region' => $ssrs_config['REPORT_REGION'],
    'runtime_user' => $app_user_name,
    'global_currency_format' => '$',
    'global_date_format' => str_replace('mm', 'M', $client_date_format),
    'global_thousand_format' => $global_thousand_format,
    'global_rounding_format' => $global_rounding_format,
    'global_science_rounding_format' => '2',
    'global_negative_mark_format' => '1',
	'global_price_rounding_format' => $global_price_rounding_format, //'#0.00',
	'global_volume_rounding_format' => $global_volume_rounding_format,
	'global_amount_rounding_format' => $global_amount_rounding_format,
	'global_number_format_region' => $global_number_format_region,
);

#RDL Application language
$rdl_language = array(
    'de-de' => $language_xml_path . "\\" . "DE" . ".xml",
    'nl-nl' => $language_xml_path . "\\" . "NL" . ".xml"
);
#Render type - defaults
$rdl_generic_drop_options_yes_no = array(
    0 => array(0, 'Global'),
    1 => array(1, 'Yes'),
    2 => array(2, 'No'),
);
#Line style
$rdl_column_line_style = array(
    1 => array(1, 'Solid'),
    2 => array(2, 'Dotted'),
    3 => array(3, 'Dashed')
);
#Line size
$rdl_column_line_size = array(
    1 => array(1, '1pt'),
    2 => array(2, '2pt'),
    3 => array(3, '3pt'),
    5 => array(5, '5pt'),
    10 => array(10, '10pt'),
);
#Render Options
$rdl_column_render_as_options = array(
    array(0, 'Text'),
    array(2, 'Number'),
    array(3, 'Amount'),
	array(13, 'Price'),
	array(14, 'Volume'),
    array(4, 'Date'),
    array(5, 'Percentage'),
    array(6, 'Scientific'),
    array(1, 'HTML'),
);
#Value templates 
#Type 1 - Text, HTML; 2 - Number, 3 - Amount; 4 - Date; 5 - Percentage; 6 - Scientific Mode ; 13-Price; 14- Volume
$rdl_column_attributes_template = array(
    1 => array(
        1 => array(
            'id' => 1,
            'type' => 1,
            'label' => 'Default',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Left',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Left',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1'
        ),
        2 => array(
            'id' => 2,
            'type' => 1,
            'label' => 'Reverse',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Left',
            'text_color' => '#000000',
            'background' => '#e5eef4',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Left',
            'header_text_color' => '#458bc1',
            'header_background' => '#ffffff'
        )
    ),
    2 => array(
        3 => array(
            'id' => 3,
            'type' => 2,
            'label' => 'Default',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'thousand' => '1',
            'rounding' => '2',
            'negative_mark' => '1'
        ),
        4 => array(
            'id' => 4,
            'type' => 2,
            'label' => 'Reverse',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#e5eef4',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#458bc1',
            'header_background' => '#ffffff',
            'thousand' => '1',
            'rounding' => '2',
            'negative_mark' => '0'
        ),
    ),
    3 => array(
        5 => array(
            'id' => 5,
            'type' => 3,
            'label' => 'Default',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'currency' => '1',
            'thousand' => '1',
            'rounding' => '2',
            'negative_mark' => '1'
        ),
        6 => array(
            'id' => 6,
            'type' => 3,
            'label' => 'Reverse',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,1,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#e5eef4',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#458bc1',
            'header_background' => '#ffffff',
            'currency' => '2',
            'thousand' => '1',
            'rounding' => '2',
            'negative_mark' => '0'
        ),
    ),
    4 => array(
        7 => array(
            'id' => 7,
            'type' => 4,
            'label' => 'US',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'date_format' => '3',
        ),
        10 => array(
            'id' => 10,
            'type' => 4,
            'label' => 'EURO',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'date_format' => '12',
        ),
    ),
    5 => array(
        8 => array(
            'id' => 8,
            'type' => 5,
            'label' => 'Default',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'rounding' => '2',
        ),
        11 => array(
            'id' => 11,
            'type' => 5,
            'label' => 'Reverse',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,1,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#e5eef4',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#458bc1',
            'header_background' => '#ffffff',
            'rounding' => '0',
        ),
    ),
    6 => array(
        9 => array(
            'id' => 9,
            'type' => 6,
            'label' => 'Default',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,0,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#ffffff',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#ffffff',
            'header_background' => '#458bc1',
            'rounding' => '2',
        ),
        12 => array(
            'id' => 12,
            'type' => 6,
            'label' => 'Reverse',
            'font' => 'Tahoma',
            'font_size' => '8',
            'font_style' => '0,1,0',
            'text_align' => 'Right',
            'text_color' => '#000000',
            'background' => '#e5eef4',
            'header_font' => 'Tahoma',
            'header_font_size' => '8',
            'header_font_style' => '1,0,0',
            'header_text_align' => 'Right',
            'header_text_color' => '#458bc1',
            'header_background' => '#ffffff',
            'rounding' => '0',
        ),
    ),
	13 => array(
    ),
	14 => array(
    ),
	
);
#Aggregation functions available for a column in RDL (SSRS Reports)
$rdl_column_default_attributes = array(
    'sortable' => '1',
    'font' => 'Tahoma',
    'font_size' => '8',
    'text_align' => 'Left',
    'text_color' => '#000000',
    'background' => '#ffffff'
);
$rdl_header_default_attributes = array(
    'font' => 'Tahoma',
    'font_size' => '8',
    'text_align' => 'Left',
    'text_color' => '#ffffff',
    'background' => '#458bc1',
    'font_style' => '1,0,0'
);
$rdl_column_aggregation_option = array(
    #id, function_name, label, only_for_number(true:1,false:0), for_group(1,0), for_non_group(1,0)
    1 => array(1, 'Avg', 'Average (non-null values)', '1', '1', '1'),
    2 => array(2, 'Count', 'Count', '0', '1', '1'),
    3 => array(3, 'CountDistinct', 'Count (distinct values)', '0', '1', '0'),
    //5 => array(5, 'CountRows','Count (rows)','0','1','0'),
    6 => array(6, 'First', 'First value', '0', '1', '0'),
    7 => array(7, 'Last', 'Last value', '0', '1', '0'),
    8 => array(8, 'Max', 'Max (non-null values)', '0', '1', '1'),
    9 => array(9, 'Min', 'Min (non-null values)', '0', '1', '1'),
    10 => array(10, 'MinMax', 'Min - Max (non-null values)', '0', '1', '0'),
    11 => array(11, 'StDev', 'Standard Deviation (non-null values)', '1', '1', '1'),
    12 => array(12, 'StDevP', 'Population Standard Deviation (non-null values)', '1', '1', '1'),
    13 => array(13, 'Sum', 'Sum', '1', '1', '1'),
    14 => array(14, 'Var', 'Variance (non-null values)', '1', '1', '1'),
    15 => array(15, 'VarP', 'Population Variance (non-null values)', '1', '1', '1'),
    16 => array(16, 'COUNT_BIG', 'Count Big', '0', '0', '1'),
    17 => array(17, 'GROUPING', 'Grouping', '0', '0', '1'),
    18 => array(18, '', 'Derive Aggregate', '0', '0', '1')
        #18 => array(27, 'RunningValue'),
        #19 => array(28, 'Aggregate')
);

$rdl_column_rounding_option = array(
    -1 => array(-1, 'Global'),
    0 => array(0, 0),
    1 => array(1, 1),
    2 => array(2, 2),
    3 => array(3, 3),
    4 => array(4, 4),
    5 => array(5, 5),
    6 => array(6, 6),
    7 => array(7, 7),
    8 => array(8, 8),
    9 => array(9, 9),
    10 => array(10, 10),
    11 => array(11, 11),
    12 => array(12, 12),
    13 => array(13, 13),
    14 => array(14, 14),
    15 => array(15, 15),
    16 => array(16, 16),
    17 => array(17, 17),
    18 => array(18, 18),
    19 => array(19, 19),
    20 => array(20, 20)
);

$rdl_column_currency_option = array(
    -1 => array(-1, 'None', ''),
    0 => array(0, 'Global', 'Parameters!global_currency_format.Value'),
    1 => array(1, '$', '"$"'),
    2 => array(2, '¥', '"¥"'),
    3 => array(3, '€', '"€"')
);

$rdl_column_date_format_option = array(
    0 => array(0, 'Global', 'Parameters!global_date_format.Value'),
    1 => array(1, 'mm/dd/yyyy', 'M/d/yyyy'),
    2 => array(2, 'mm/dd/yyyy hh:mm', 'M/d/yyyy HH:mm'),
    3 => array(3, 'mm/dd/yyyy hh:mm:ss', 'M/d/yyyy HH:mm:ss'),
    4 => array(4, 'mm-dd-yyyy', 'M-d-yyyy'),
    5 => array(5, 'mm-dd-yyyy hh:mm', 'M-d-yyyy HH:mm'),
    6 => array(6, 'mm-dd-yyyy hh:mm:ss', 'M-d-yyyy HH:mm:ss'),
    7 => array(7, 'dd/mm/yyyy', 'd/M/yyyy'),
    8 => array(8, 'dd/mm/yyyy hh:mm', 'd/M/yyyy HH:mm'),
    9 => array(9, 'dd/mm/yyyy hh:mm:ss', 'd/M/yyyy HH:mm:ss'),
    10 => array(10, 'dd-mm-yyyy', 'd-M-yyyy'),
    11 => array(11, 'dd-mm-yyyy hh:mm', 'd-M-yyyy HH:mm'),
    12 => array(12, 'dd-mm-yyyy hh:mm:ss', 'd-M-yyyy HH:mm:ss'),
    13 => array(13, 'dd.mm.yyyy', 'd.M.yyyy'),
    14 => array(14, 'dd.mm.yyyy hh:mm', 'd.M.yyyy HH:mm'),
    15 => array(15, 'dd.mm.yyyy hh:mm:ss', 'd.M.yyyy HH:mm:ss'),
    16 => array(16, 'Time', 'T'),
    17 => array(17, 'Month Day', 'M'),
    18 => array(18, 'Month-Year', 'MMM yyyy'),
    19 => array(19, 'Full Month-Year', 'MMMM yyyy'),
);

$rdl_column_sort_option = array(
    array('1', 'ASC'),
    array('2', 'DESC')
);

$rdl_column_font_option = array(
    array('Andale Mono', 'Andale Mono'),
    array('Arial', 'Arial'),
    array('Arial Black', 'Arial Black'),
    array('Comic Sans MS', 'Comic Sans MS'),
    array('Courier New', 'Courier New'),
    array('Georgia', 'Georgia'),
    array('Impact', 'Impact'),
    array('Lucida Console', 'Lucida Console'),
    array('Marlett', 'Marlett'),
    array('Symbol', 'Symbol'),
    array('Times New Roman', 'Times New Roman'),
    array('Tahoma', 'Tahoma'),
    array('Trebuchet MS', 'Trebuchet MS'),
    array('Verdana', 'Verdana'),
    array('Webdings', 'Webdings')
);

$rdl_column_font_size_option = array(
    array(7, 7),
    array(8, 8),
    array(9, 9),
    array(10, 10),
    array(11, 11),
    array(12, 12),
    array(14, 14),
    array(18, 18),
    array(20, 20),
    array(22, 22),
    array(24, 24),
    array(27, 27),
);

$rdl_column_text_align_option = array(
    array('Left', 'Left'),
    array('Right', 'Right'),
    array('Center', 'Center')
);

$gauge_type[] = array('1', 'Radial');
$gauge_type[] = array('2', 'Radial - 180 Degrees North');
$gauge_type[] = array('3', 'Linear - Three Color Range Horizontal');
$gauge_type[] = array('4', 'Linear - Three Color Range Vertical');

$data_array_as_of_date = array(
    array('DATE.C', 'Custom As of Date'),
    array('DATE.F', 'First Day of the Month'),
    array('DATE.L', 'Last Day of the Month'),
    array('DATE.1', 'Day Before Run Date'),
    array('DATE.X', 'Custom Days Before Run Date'),
);

#Chart Types LookUp Array
$rfx_chart_category = array(
    1 => array(1, 'Area'),
    2 => array(2, 'Bar'),
    3 => array(3, 'Column'),
    4 => array(4, 'Linear'),
    5 => array(5, 'Polar'),
    6 => array(6, 'Scatter'),
    7 => array(7, 'Shape'),
    8 => array(8, 'Composite'),
);

$rfx_chart_type = array(
    4 => array(4, 'Area', 1, 'area.gif'),
    50 => array(50, 'Area 3d', 1, 'area-3d.gif'),
    9 => array(9, 'Smooth', 1, 'area-smooth.gif'),
    6 => array(6, 'Smooth 3d', 1, 'area-3d-smooth.gif'),
    10 => array(10, 'Stacked', 1, 'area-stacked.gif'),
    7 => array(7, 'Stacked 3d', 1, 'area-3d-stacked.gif'),
    8 => array(8, 'Percent Stacked', 1, 'area-percent-stacked.gif'),
    5 => array(5, 'Percent Stacked 3d', 1, 'area-3d-percent-stacked.gif'),
    
    2 => array(2, 'Bar', 2, 'bar.gif'),
    11 => array(11, 'Bar 3d', 2, 'bar-3d.gif'),
    17 => array(17, 'Stacked', 2, 'bar-stacked.gif'),
    18 => array(18, 'Stacked 3d', 2, 'bar-3d-stacked.gif'),
    15 => array(15, 'Percent Stacked', 2, 'bar-percent-stacked.gif'),
    16 => array(16, 'Percent Stacked 3d', 2, 'bar-3d-percent-stack.gif'),
    14 => array(14, 'Cylinder 3d', 2, 'bar-3d-cylinder.gif'),
    13 => array(13, 'Cylinder Stacked 3d', 2, 'bar-3d-stacked-cylinder.gif'),
    12 => array(12, 'Cylinder Percent Stacked 3d', 2, 'bar-3d-percent-stacked-cylinder.gif'),
    
    19 => array(19, 'Column', 3, 'column.gif'),
    20 => array(20, 'Column 3d', 3, 'column-3d.gif'),
    21 => array(21, 'Clustered 3d', 3, 'column-3d-clustered.gif'),
    28 => array(28, 'Stacked', 3, 'column-stacked.gif'),
    29 => array(29, 'Stacked 3d', 3, 'column-3d-stacked.gif'),
    27 => array(27, 'Percent Stacked', 3, 'column-percent-stacked.gif'),
    26 => array(26, 'Percent Stacked 3d', 3, 'column-3d-percent-stacked.gif'),
    22 => array(22, 'Cylinder 3d', 3, 'column-3d-cylinder.gif'),
    23 => array(23, 'Cylinder Clustered 3d', 3, 'column-3d-cylinder-clustered.gif'),
    25 => array(25, 'Cylinder Stacked 3d', 3, 'column-3d-cylinder-stacked.gif'),
    24 => array(24, 'Cylinder Percent Stacked 3d', 3, 'column-3d-cylinder-percent-stacked.gif'),
    
    3 => array(3, 'Line', 4, 'line.gif'),
    30 => array(30, 'Line 3d', 4, 'line-3d.gif'),
    33 => array(33, 'Smooth', 4, 'line-smooth.gif'),
    34 => array(34, 'Stepped', 4, 'line-stepped.gif'),
    32 => array(32, 'Marker Enabled', 4, 'line-marker-enabled.gif'),
    31 => array(31, 'Marked Enabled And Smooth', 4, 'line-marker-enabled-smooth.gif'),
    
    48 => array(48, 'Polar', 5, 'polar.gif'),
    35 => array(35, 'Radar', 5, 'radar.gif'),
    36 => array(36, 'Radar 3d', 5, 'radar-3d.gif'),
    
    37 => array(37, 'Scatter', 6, 'scatter.gif'),
    38 => array(38, 'Bubble', 6, 'scatter-bubble.gif'),
    49 => array(49, 'Bubble 3d', 6, 'scatter-3d-bubble.gif'),
    
    1 => array(1, 'Pie', 7, 'pie.gif'),
    43 => array(43, 'Pie 3d', 7, 'pie-3d.gif'),
    41 => array(41, 'Funnel', 7, 'funnel.gif'),
    42 => array(42, 'Funnel 3d', 7, 'funnel-3d.gif'),
    46 => array(46, 'Pyramid', 7, 'pyramid.gif'),
    47 => array(47, 'Pyramid 3d', 7, 'pyramid-3d.gif'),
    45 => array(45, 'Exploded', 7, 'pie-exploded.gif'),
    44 => array(44, 'Exploded 3d', 7, 'pie-3d-exploded.gif'),
    39 => array(39, 'Doughnut', 7, 'doughnut.gif'),
    40 => array(40, 'Doughnut Exploded', 7, 'doughnut-exploded.gif'),
    
    51 => array(51, 'Column And Line', 8, 'column-line.gif')
);

//specify columns without space, underscore and dash - all in lowercase; this is to optimize search
$rdl_column_common_variance_list = array(
    'asofdate' => array('pnlasofdate')
    
);

/*EOF: of Report Variable localStorage File. donot add php end tag here... */
?>
<script type="application/javascript">
    
        function construct_report_export_cmd(output_file, report_path, paramset_id, report_filter, items_combined, v_paramset_hash, v_is_refresh, export_extension, export_extension_full, delim, header_info) { //rds_display_combined) {            
            
            var cmd_call = '<?php
                            $report_export_cmd = 'is_refresh:' . "' + v_is_refresh + '" . '';
                            $report_export_cmd .= ',report_region:' . $rfx_report_default_param['report_region'] . '';
                            $report_export_cmd .= ',runtime_user:' . $rfx_report_default_param['runtime_user'] . '';
                            $report_export_cmd .= ',global_currency_format:' . $rfx_report_default_param['global_currency_format'] . '';
                            $report_export_cmd .= ',global_date_format:' . $rfx_report_default_param['global_date_format'] . '';
                            $report_export_cmd .= ',global_thousand_format:' . $rfx_report_default_param['global_thousand_format'] . '';
                            $report_export_cmd .= ',global_rounding_format:' . $rfx_report_default_param['global_rounding_format'] . '';
                            $report_export_cmd .= ',global_price_rounding_format:' . $rfx_report_default_param['global_price_rounding_format'] . '';
							$report_export_cmd .= ',global_volume_rounding_format:' . $rfx_report_default_param['global_volume_rounding_format'] . '';
							$report_export_cmd .= ',global_amount_rounding_format:' . $rfx_report_default_param['global_amount_rounding_format'] . '';
                            $report_export_cmd .= ',global_science_rounding_format:' . $rfx_report_default_param['global_science_rounding_format'] . '';
                            $report_export_cmd .= ',global_negative_mark_format:' . $rfx_report_default_param['global_negative_mark_format'] . '';
                            $report_export_cmd .= ',global_number_format_region:' . $rfx_report_default_param['global_number_format_region'] . '';
                            $report_export_cmd .= ',is_html:n';

                            echo $report_export_cmd;
                            ?>';
            return cmd_call;
        }
		

        function return_batch_sp_call(cmd_command, report_name, report_file) {           
            var batch_report = 'BatchReport';
            var user_name = js_user_name;
            // var date_time = '<?php echo date('Y_m_d_His');; ?>';
            // var report_file = report_file + "_" + user_name + "_" + date_time
            // var report_file_path = '<?php echo addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']) ?>/' + report_file;
            return "EXEC spa_rfx_export_report_job @report_param='" + cmd_command 
                    + "', @proc_desc='" + batch_report 
                    + "', @user_login_id='" + user_name                   
                    + "', @report_RDL_name='" + report_name + "'";
        }
        
</script>