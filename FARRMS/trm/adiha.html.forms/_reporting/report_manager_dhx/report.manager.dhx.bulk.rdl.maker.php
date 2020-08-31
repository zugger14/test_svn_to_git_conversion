<?php
/**
* Report manager bulk rdl maker screen
* @copyright Pioneer Solutions
*/
?>
<?php
/* Application Required Resources */
include_once "../../../adiha.php.scripts/components/include.file.v3.php";

//change for open call -start

// $url = 'report.manager.dhx.bulk.rdl.maker.open.php';
// $data = array(
//     'report_id' => $_POST['report_id'],
//     'app_user_name' => $app_user_name,
//     'client_date_format' => $client_date_format
// );

// // use key 'http' even if you send the request to https://...
// $options = array(
//     'http' => array(
//         'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
//         'method'  => 'POST',
//         'content' => http_build_query($data)
//     )
// );
// $context  = stream_context_create($options);
// $result = file_get_contents($url, false, $context);
// if ($result === FALSE) { /* Handle error */ echo 'error'; }
// echo($result);
// die();
//change for open call -end


require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
include_once "../../../adiha.php.scripts/components/XML2Array.php";
include_once "../../../adiha.php.scripts/components/Array2XML.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Item.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Chart.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Tablix.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Textbox.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Line.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Image.php";
include_once "../../../adiha.php.scripts/components/ssrs_php/Generator/RDL_Gauge.php";
include_once "../../../adiha.php.scripts/components/ssrs_charts/chart.style.php";
include_once "../../../adiha.php.scripts/components/ssrs_charts/chart.composite.php";
include_once "../../../adiha.php.scripts/components/ssrs_gauge/gauge.style.php";
require_once '../report_manager_dhx/report.global.vars.php';

$phpScriptLoc = $app_php_script_loc;
global $app_adiha_loc, $app_php_script_loc, $SQLSRV_QUERY_TIME_OUT, $db_servername, $connection_info;

$DB_CONNECT = sqlsrv_connect($db_servername, $connection_info);
/* Application Required Resources */

?>
<head>
    
</head>
<style>
.header_text {
    font-family: Ubuntu;
    font-size: 12px;
    
}
.wrapper_div {
    border: solid 1px green;
    overflow:auto;
    font-size: 10px;
}
.data-table {
    border-collapse: collapse;
    width: 100%;
}
.data-table th {
    font-family: Ubuntu;
    text-align: left;
}
</style>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
        <td width="90%">
            <p class="header_text">Following report(s) were processed for deployment.</p>
            <div class="wrapper_div">
                <table class="data-table" border="1">
                    <tr>
                        <th>S.N.</th>
                        <th>Name</th>
                        <th>Write</th>
                        <th>Deployment Job</th>
                    </tr>
<?php                    
$report_main_info_bulk = array();

$report_id = get_sanitized_value($_POST['report_id'] ?? '');
if ($report_id != '') {
    $report_main_info_bulk = explode(',', trim($_POST['report_id']));
    krsort($report_main_info_bulk); /* reverse sort an array */
}

$row_num = 1;
//print_r($report_main_info_bulk);exit();   
#set language variable
$dictionary = array();

foreach ($rdl_language as $culture => $lang_path) {

    if (is_file($lang_path)) {

        $dict = XML2Array::createArray(file_get_contents($lang_path));

        if (is_array($dict) && sizeof($dict['farrms']) > 0)
            $dictionary[$culture] = $dict['farrms'];
    }
}

foreach ($report_main_info_bulk as $report_id): /*Start for record id*/
    /* RDL Specific Control Variables */
    $report_name_separator = '_';
    $report_id = (integer) $report_id;
    $last_group_header = array();
    $toggle_item = NULL;
    
    /* Start of RDL Generation Cycle */
    if ($report_id > 0) {
        /* Create ODBC Handle */
        //$identifier = odbc_connect($odbc_DB, $odbcUser, $odbcPass);
    
        #report being processed
        $report_in_context = array();
    
        #get report pages of given report
        $xml_url = 'EXEC spa_rfx_rdl_maker @flag=s, @report_id=' . $report_id;
        $report_pages = readXMLURL2($xml_url);
        
        foreach ($report_pages as $zzz => $report_data) {            
            $report_page = $report_data['report_page_id'];
            //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=a&useGridlabels=false&page_id=' . $report_page;
            $xml_url = 'EXEC spa_rfx_rdl_maker @flag=a, @page_id=' . $report_page;
            $report_details = readXMLURL2($xml_url);
    
            $rdl = new RDL($report_details[0]['name'], $ssrs_config);
            $rdl->set_base($report_details[0]['height'], $report_details[0]['width'], $report_details[0]['report_hash']);
            try {
                #get report items (Gauge)        
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=g&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=g, @page_id=' . $report_page;
                $gauges = readXMLURL2($xml_url);
                
                $rdl_gauge = new RDL_Gauge($ssrs_config, $dictionary);
        
                foreach ($gauges as $ri => $ggauge) {
                    $rdl->init_gauge();
                    $rdl->push_rds_alias($ggauge['alias']);
                    $rdl_gauge->init($ggauge['name'], $ggauge['top'], $ggauge['left'], $ggauge['width'], $ggauge['height'], 'Datasetg' . ($ri + 1), 'c', $ggauge['alias']);
        
                    #trace columns
                    //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=h&useGridlabels=false&page_id=' . $report_page . '&page_gauge_id=' . $ggauge['report_component_id'];
                    $xml_url = 'EXEC spa_rfx_rdl_maker @flag=h, @page_id=' . $report_page . ', @page_gauge_id=' . $ggauge['report_component_id'];
                    $gauge_items = readXMLURL2($xml_url);
                    
                    foreach ($gauge_items as $ik => $gauge_column) {
                        $start_key = array_search('rounding', array_keys($gauge_column));
                        $gauge_style = array_slice($gauge_column, $start_key, null);                                
                    }
                    $xml = Array2XML::createXML('Style', GaugeStyle::get_style($gauge_style));
                    $gauge_style_xml = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                    
                    foreach ($gauge_items as $ik => $gauge_column) {
                        //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=r&useGridlabels=false&page_id=' . $report_page . '&page_gauge_id=' . $ggauge['report_component_id'] . '&gauge_column_id=' . $gauge_column['report_gauge_column_id'];
                        $xml_url = 'EXEC spa_rfx_rdl_maker @flag=r, @page_id=' . $report_page . ', @page_gauge_id=' . $ggauge['report_component_id'] . ', @gauge_column_id=' . $gauge_column['report_gauge_column_id'];
                        $gauge_ranges = readXMLURL2($xml_url);
                        #make series, members
                        $data_type = ($gauge_column['datatype_id'] == '3' || $gauge_column['datatype_id'] == '4') ? 1 : 2;
        
                        $gauge_column['alias'] = trim($gauge_column['alias']);
                        $column_var = preg_replace('/[^\w]/', '_', $gauge_column['column_name']);
                        $column_alias = $gauge_column['alias'];
                        $gauge_items[$ik]['ranges'] = $gauge_ranges;
        
                        #push dataset field info
                        $rdl_gauge->push_dataset_field($column_var, $column_alias, $data_type);
                    }
        
                    #make dataset
                    $rdl->push_dataset($rdl_gauge->set_dataset());
                    #make gauge
        
                    $gauge = GaugeFactory::get_gauge($rdl_gauge->get_gauge_type($ggauge['type']));
                    $gauge->set_ds_name($rdl_gauge->dataset_name)
                            ->set_name($rdl_gauge->name)
                            ->set_top($rdl_gauge->top)
                            ->set_left($rdl_gauge->left)
                            ->set_width($rdl_gauge->width)
                            ->set_height($rdl_gauge->height)
                            ->set_zindex(($ri + 1))
                            ->set_gauge_label($ggauge['gauge_label'])
                            ->set_scales($gauge_items)
                            ->set_style($gauge_style_xml);
                    
                    $rdl->push_gauge($gauge->get_gauge_rdl());
                }        
        
                #get report items (Charts)
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=p&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=p, @page_id=' . $report_page;
                $charts = readXMLURL2($xml_url);
                
                $rdl_chart = new RDL_Chart($ssrs_config, $dictionary);
                
                foreach ($charts as $ri => $cchart) {
                    $chart_prop = json_decode(($charts[$ri]['chart_properties']));
                    
                    $rdl->init_chart();
                    $rdl->push_rds_alias($cchart['alias']);
                    $rdl_chart->init($cchart['name'], $cchart['top'], $cchart['left'], $cchart['width'], $cchart['height'], 'Datasetc' . ($ri + 1), 'c', $cchart['alias']);
                    #common item information
                    $y_axis_caption = $rdl_chart->_(((strlen($cchart['y_axis_caption']) > 0) ? $cchart['y_axis_caption'] : ' '));
                    $x_axis_caption = $rdl_chart->_(((strlen($cchart['x_axis_caption']) > 0) ? $cchart['x_axis_caption'] : ' '));
        
                    #trace columns
                    //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=c&useGridlabels=false&page_id=' . $report_page . '&page_chart_id=' . $cchart['report_component_id'];
                    $xml_url = 'EXEC spa_rfx_rdl_maker @flag=c, @page_id=' . $report_page . ', @page_chart_id=' . $cchart['report_component_id'];
                    $chart_items = readXMLURL2($xml_url);
                    
                    $chart_data = array();
                    $chart_series = array();
                    $chart_categories = array();
                    $chart_sorts = array();
                    
                    $composite_members = array();
                    $composite_series = array();
        
                    foreach ($chart_items as $chart_column) {
                        #make series, members
                        $data_type = ($chart_column['datatype_id'] == '3' || $chart_column['datatype_id'] == '4') ? 1 : 2;
                        $chart_column['alias'] = trim($chart_column['alias']);
                        $column_var = preg_replace('/[^\w]/', '_', $chart_column['alias']);
                        $column_alias = $chart_column['alias'];
                        
                        $chart_column['sorting_column'] = trim($chart_column['sorting_column']);
                        $sorting_column_var = preg_replace('/[^\w]/', '_', $chart_column['sorting_column']);
                        $sorting_column_alias = $chart_column['sorting_column'];
                        $sorting_column_direction = trim($chart_column['default_sort_direction']);
                        $sorting_column_direction = ($sorting_column_direction == "") ? "Ascending" : $sorting_column_direction;
        
                        if ($chart_column['placement'] == 1) {
                            array_push($chart_data, $column_var);
                        } else if ($chart_column['placement'] == 2 ) {
                            array_push($chart_series, $column_var);
                        } else {
                            array_push($chart_categories, $column_var);
                        }
                        
                        if (($chart_column['placement'] == 1) || ($chart_column['render_as_line'] == 1)) {
                            array_push($composite_members, $column_var);
                        }
                        
                        if ($chart_column['render_as_line'] == 1) {
                            array_push($composite_series, $column_var);
                        }
                        
                        #push dataset field info
                        $rdl_chart->push_dataset_field($column_var, $column_alias, $data_type);
                        if ($sorting_column_var != '' && $sorting_column_var != 'NULL') {
                            $rdl_chart->push_dataset_field($sorting_column_var, $sorting_column_alias, $data_type);
                            array_push($chart_sorts, $sorting_column_var.'||'.$sorting_column_direction);
                        }
                    }
        
                    #make dataset
                    $rdl->push_dataset($rdl_chart->set_dataset());
        
                    #get chart type            
                    $chart_type = ($rfx_chart_category[$rfx_chart_type[$cchart['type']][2]][1]);
                    $chart_type .= '/';
                    $chart_type .= str_replace(' ', '', $rfx_chart_type[$cchart['type']][1]);
        
                    #make chart
                    $chart = ChartFactory::get_chart($chart_type);
                    $chart->set_ds_name($rdl_chart->dataset_name)
                            ->set_name($rdl_chart->name)
                            ->set_caption($cchart['name'])
                            ->set_top($rdl_chart->top)
                            ->set_left($rdl_chart->left)
                            ->set_width($rdl_chart->width)
                            ->set_height($rdl_chart->height)
                            ->set_zindex(($ri + 1))
                            ->set_members($chart_data)
                            ->set_series($chart_series)
                            ->set_groups($chart_categories)
                            ->set_sorts($chart_sorts)
                            ->set_y_axis_caption($y_axis_caption)
                            ->set_x_axis_caption($x_axis_caption)
                            ->set_page_break($cchart['page_break']);     
                    
                    $rdl_str = '';
                    $xml = Array2XML::createXML('Style', ChartStyle::get_style((array) $chart_prop->axes->x));
                    $style = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                    $rdl_str = str_replace('<StyleXAxisReplaceText>', $style, $chart->get_chart_rdl());
                
                    $xml = Array2XML::createXML('Style', ChartStyle::get_style((array) $chart_prop->axes->y));
                    $style = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                    $rdl_str = str_replace('<StyleYAxisReplaceText>', $style, $rdl_str);
                    
                    $xml = Array2XML::createXML('Style', ChartStyle::get_style((array) $chart_prop->axes->z));
                    $style = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                    $rdl_str = str_replace('<StyleZAxisReplaceText>', $style, $rdl_str);
                    
                    if (isset($chart_prop->axes_caption->x)) {
                        $xml = Array2XML::createXML('Style', ChartStyle::get_style((array) $chart_prop->axes_caption->x));
                        $style = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                        $rdl_str = str_replace('<StyleXAxisCaptionReplaceText>', $style, $rdl_str);
                    }
                    
                    if (isset($chart_prop->axes_caption->y)) {
                        $xml = Array2XML::createXML('Style', ChartStyle::get_style((array) $chart_prop->axes_caption->y));
                        $style = (string) str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml->saveXML());
                        $rdl_str = str_replace('<StyleYAxisCaptionReplaceText>', $style, $rdl_str);
                    }
                    #composite charts :: add members
                    $rdl_str = str_replace('<CompositeMembers>', ChartComposite::get_members($composite_members), $rdl_str);
                    
                    #composite charts :: add series
                    $rdl_str = str_replace('<CompositeSeries>', ChartComposite::get_series($composite_series), $rdl_str);
                                
                    $rdl->push_chart($rdl_str);          
                }
                
                #get report items (Tablix)
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=m&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=m, @page_id=' . $report_page;
                $tablixes = readXMLURL2($xml_url);
        
                $rdl_tablix = new RDL_Tablix($ssrs_config, $dictionary, $rdl_column_currency_option, $rdl_column_date_format_option, $rdl_column_aggregation_option);
        
                foreach ($tablixes as $ri => $ttablix) {
                    $rdl->push_rds_alias($ttablix['alias']);
                    $rdl_tablix->init($ttablix['name'], $ttablix['top'], $ttablix['left'], $ttablix['width'], $ttablix['height'], ('Datasett' . ($ri + 1)), 'c', $ttablix['alias']);
                    $rdl_tablix->init_tablix($ttablix['group_mode'], $ttablix['border_style'], $ttablix['page_break'], $ttablix['type_id'], $ttablix['cross_summary'], $ttablix['no_header']);
        
                    #trace report item's columns
                    //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=t&useGridlabels=false&page_id=' . $report_page . '&page_tablix_id=' . $ttablix['report_component_id'];
                    $xml_url = 'EXEC spa_rfx_rdl_maker @flag=t, @page_id=' . $report_page . ', @page_tablix_id=' . $ttablix['report_component_id'];
                    $tablix_items = readXMLURL2($xml_url);
                    $rdl_tablix->set_base($tablix_items);
                    $rdl_tablix->set_tablix_columns();
                    $rdl_tablix->set_tablix_column_hierarchy();
                    $rdl_tablix->set_tablix_row_hierarchy();
                    $rdl_tablix->set_tablix_row();
        
                    #make dataset
                    $rdl->push_dataset($rdl_tablix->set_dataset());
        
                    #push tablix object
                    $rdl_tablix->finalize_tablix();
                }
                $rdl->push_tablix($rdl_tablix->get_tablix_collection());
        
                #manage textboxes
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=b&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=b, @page_id=' . $report_page;
                $textbox_items = readXMLURL2($xml_url);
        
                if (sizeof($textbox_items) > 0) {
                    $rdl_textbox = new RDL_Textbox();
        
                    foreach ($textbox_items as $report_textbox) {
                        $dataset_name_text_param = 'DatasetTextParam_' . $report_textbox['report_page_textbox_id'];
                        $font = (strlen($report_textbox['font']) > 0) ? $report_textbox['font'] : $rdl_column_default_attributes['font'];
                        $font_size = (strlen($report_textbox['font_size']) > 0) ? $report_textbox['font_size'] . 'pt' : $rdl_column_default_attributes['font_size'] . 'pt';
                        $font_style = explode(',', $report_textbox['font_style']);
        
                        $rdl_textbox->init('static_textbox_' . $report_textbox['report_page_textbox_id'], $report_textbox['top'], $report_textbox['left'], $report_textbox['width'], $report_textbox['height']);
                        $rdl_textbox->set_textbox($report_textbox['content'], $font, $font_size, $font_style, $dataset_name_text_param);
                        #make dataset
                        $rdl->push_dataset(
                            array(
                                'Fields' => array('Field' => array(
                                    'DataField' => 'value',
                                    'rd:TypeName' => 'System.String',
                                    '@attributes' => array('Name' => 'FunctionValue')
                                )),
                                'Query' => array(
                                    'DataSourceName' => $ssrs_config['DATA_SOURCE'],
                                    'CommandText' => '="EXEC spa_rfx_resolve_text_param " &Parameters!report_filter.Value & ",\'' . $report_textbox['content'] . '\',\'" & Parameters!runtime_user.Value & "\'"',
                                    'rd:UseGenericDesigner' => 'true'
                                ),
                                '@attributes' => array('Name' => $dataset_name_text_param)
                            )
                        );
                    
                    }
                    $rdl->push_textbox($rdl_textbox->arr_textbox);
                }
                
                #manage lines
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=l&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=l, @page_id=' . $report_page;
                $line_items = readXMLURL2($xml_url);
        
                if (sizeof($line_items) > 0) {
                    $rdl_line = new RDL_Line(NULL, NULL, $rdl_column_line_size, $rdl_column_line_style);
        
                    foreach ($line_items as $report_line) {
                        $rdl_line->init('static_line_' . $report_line['report_page_line_id'], $report_line['top'], $report_line['left'], $report_line['width'], $report_line['height'], NULL, NULL, NULL, '');
                        $rdl_line->set_line($report_line['color'], $report_line['size'], $report_line['style']);
                    }
                    $rdl->push_line($rdl_line->arr_line);
                }
        
                #manage images
                //$xml_url = $phpScriptLoc . 'spa_rfx_rdl_maker.php?flag=j&useGridlabels=false&page_id=' . $report_page;
                $xml_url = 'EXEC spa_rfx_rdl_maker @flag=j, @page_id=' . $report_page;
                $image_items = readXMLURL2($xml_url);
        
                if (sizeof($image_items) > 0) {
                    $rdl_image = new RDL_Image();
        
                    foreach ($image_items as $report_image) {
                        $content = $app_php_script_loc . '/dev/report.open.image.php?image_id=' . $report_image['report_page_image_id'];
                        $name_var = 'static_image_' . $report_image['report_page_image_id'] . '_' . $report_image['name'];
                        $rdl_image->init($name_var, $report_image['top'], $report_image['left'], $report_image['width'], $report_image['height']);
                        $rdl_image->set_image($content, $report_image['name']);
                    }
                    $rdl->push_image($rdl_image->arr_image);
                }

                #Column Headers Dataset
                $xml_url = "EXEC spa_rfx_headers @flag='h', @page_id=$report_page";
                $report_dataset_headers_result = readXMLURL2($xml_url);
                $report_dataset_headers = $report_dataset_headers_result[0]['header_list'];
                $report_dataset_headers_arr = explode(',', $report_dataset_headers);
                $header_array = array();
                foreach($report_dataset_headers_arr as &$x) {
                    $y = array(
                        'DataField' => $x,
                        'rd:TypeName' => 'System.String',
                        '@attributes' => array('Name' => $x)
                    );
                    array_push($header_array, $y);
                }
                
                $rdl->push_dataset(
                    array(
                        'Fields' => array('Field' => $header_array
                        ),
                        'Query' => array(
                            'DataSourceName' => $ssrs_config['DATA_SOURCE'],
                            'CommandText' => '="EXEC spa_rfx_headers \'s\', " & Parameters!paramset_id.Value & ",\'" &Parameters!runtime_user.Value & "\'"',
                            'rd:UseGenericDesigner' => 'true'
                        ),
                        '@attributes' => array('Name' => 'Dataset_header')
                    )
                );
        
                #settle report param finally with the dynamic parameter
                $rdl->set_rds_params();
                $write_status = $rdl->save_rdl();
                $rdl_deployer_job = $rdl->get_job_sql($report_page);
                //run batch job
                //$result = odbc_exec($DB_CONNECT, $rdl_deployer_job);
                $result = sqlsrv_query($DB_CONNECT, $rdl_deployer_job, array(), $SQLSRV_QUERY_TIME_OUT);
                $report_in_context[$zzz] = array($rdl->report_name, $write_status, $result);
            }
            catch (Exception $e) {
                $err_msg = $e->getMessage();
                $report_in_context[$zzz] = array($rdl->report_name, 'Failed', 'Failed');
            }
        }
    }
    /* End of RDL Generation Cycle */
            foreach ($report_in_context as $sn => $report): 
    ?>
                <tr>
                    <td width="5"><?php echo $row_num; ?>.</td>
                    <td> <?php echo $report[0] ?></td>
                    <td> <?php echo ($report[1]) ? 'Ok' : 'Failed'; ?> </td>
                    <td> <?php echo ($report[2]) ? 'Started' : 'Failed'; ?></td>
                </tr>
    <?php 
                $row_num++;
            endforeach;
            
    endforeach; /*End for record id*/
    
    sqlsrv_close($DB_CONNECT);
    ?>
            </table>
            </div>
            
        </td>
    </tr>
    
</table>
<script type="text/javascript">
    
</script>