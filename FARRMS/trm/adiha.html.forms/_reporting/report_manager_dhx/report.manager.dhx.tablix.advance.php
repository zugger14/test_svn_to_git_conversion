<?php
/**
* Report manager tablix advance screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    
<head>
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php'); 
    require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    require_once('../report_manager_dhx/report.global.vars.php');
    ?>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/underscore.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui-1.8.20.custom.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery.tab.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery.nestedSortable.js"></script>
    <link rel="stylesheet" type="text/css" href="<?php echo $appBaseURL; ?>css/adiha_style.css" />      

        <style type="text/css">
            /* 
             * holds page specific logics
             * so cant be added to adiha_style.css
    */
            .legend_new {
                float: right;
                position: fixed;
                right: 30px;
                top: 160px
            }

            .legend_new_sub {
                border:1px solid #ccc; 
                padding: 5px; 
                border-radius: 3px; 
                background: #f2f2f2;
        }

        ul.connected_crosstab {
            height: 120px!important; 
        }
            
        .advanced-tables {
            margin-bottom: 20px;
        }
                
        ul.connected_sorts {
            border: 1px solid #458bc1; 
            height: 330px; 
            overflow: scroll; 
        }
            
        ul.connected_sorts {
            width: 300px; 
            list-style-position: inside;  
            list-style-type: none;  
            margin: 0;  
            padding: 0 0 .5em;  
            float: left;  
            margin-right: 10px;  
        }
            
        ul.connected_sorts li {
            background: #cbe1fc; 
            padding: 5px;  
            margin: 0px;  
            color: #333; 
            cursor: move;  
            height: 15px; 
            border: 1px solid #b6d4f8; 
            display: block; 
        }
            
        ul.connected_sorts .place-holding {
            height: 15px; 
            border: 1px dotted #fff; 
            background: #e3effd; 
            list-style: none!important; 
        }
            
        ul.connected_sorts li .styler {
            display: inline; 
            cursor: pointer; 
            background: #cbe1fc; 
            border: 1px solid #458bc1; 
            padding: 0px 4px; 
            font-weight: bold; 
            font-size: 10px; 
        }
        
        #all-columns-rs li .styler {
            display: none!important; 
        }
        
        .column-template {
            display: none; 
        }
        
        .small-form-element {
            width: 25px!important;
        }
        
       .medium-form-element {
            width: 55px!important; padding: 1px 2px;
        }
        
        .large-form-element {
            width: 150px!important; padding: 1px 2px;
        }
        
        .mega-form-element {
            width: 276px!important;  padding: 1px 2px;
        }
        
        /* show hide tabs - base display toggle*/
        .aggr-mode .aggr,.base-mode .base,.display-mode .display,.hdisplay-mode .hdisplay,.cformat-mode .cdisplay {
            display: table-cell; 
        }
        
        .base-mode .display,.base-mode .hdisplay,.base-mode .cdisplay, .base-mode .aggr, 
        .display-mode .base, .display-mode .hdisplay, .display-mode .cdisplay, .display-mode .aggr, 
        .hdisplay-mode .base, .hdisplay-mode .display, .hdisplay-mode .cdisplay,.hdisplay-mode .aggr, 
        .cformat-mode .base, .cformat-mode .display, .cformat-mode .hdisplay,.cformat-mode .aggr, 
        .aggr-mode .base, .aggr-mode .display, .aggr-mode .hdisplay, .aggr-mode .cdisplay {
            display: none!important; 
        }
        
        .data-table th.base, .data-table th.main {
            border-top: 2px solid #85E1D4;                 
            border-bottom: 2px solid #85E1D4;                
        }
        
        .data-table th.aggr,.data-table th.cdisplay, .data-table th.display, .data-table th.hdisplay {
            background: #85E1D4;                 
            color: #fff;                 
            border-top: 2px solid #85E1D4;                 
            border-bottom: 2px solid #85E1D4;                 
        }

        /* added for questar only */
        .data-table th {
                color: #000!important;
                font-size:12px!important;
                border-top:none!important;
                font-weight: normal;
        }

        ul.jtabs li.active a.theme-blue span {
            background: #85E1D4;
            }
            
        ul.jtabs li a {
            color: white;
            background: #CBCBCB;
        }
        /* added for questar only */

        /* hide aggregation in group tab*/
        .group-items .detail-item {
            display: none!important; 
        }
        
        /* show subtotal in row-by tab only*/
        .sub-total{
            display:none!important;
        }

        .row-by-item .sub-total {
            display: table-cell!important; 
        }
            
        .template-info {
            display: inline; 
        }
        
        .current-template-option {
            display: inline
        }
            
            .has-colorpicker,
            .clone-buttons img,
            .zoomer,
            .template-info {
            cursor: pointer; 
        }
            
        .move-item {
            cursor: move; 
        }
            
        ul.mode-trigger {
            margin-left: 250px!important; 
        }
            
        .clone-buttons {
            margin: 10px 0px 5px 5px; 
        }
            
        #advanced-plan {
            padding: 4px; 
            display: none; 
        }
            
        /* show hide item incase of custom column and text based column*/
            .na-for-text,
            .na-for-custom {
            display: none; 
        }
            
        .na-for-custom {
            display: inline; 
        }
        
        .text-item .na-for-text {
            display: inline!important; 
        }
            
        .custom-column .na-for-custom {
            display: none!important; 
        }
            
        /*Item Data type Logo*/
        .item-logo { 
            width: 16px; 
            height: 16px; 
            display: inline-block; 
        }
            
        .item-logo {
            background: url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/number-item.gif"); 
        }
            
        .text-item .item-logo {
            background: url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/text-item.gif"); 
        }
            
        .custom-column .item-logo {
            background: url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/custom-item.gif"); 
        }        
            
        /*Standard mode hack*/
        ul.jtabs li.active a.default {
            background: url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/tab-right.gif") no-repeat 100% 0px!important; 
        }
            
        ul.jtabs li.active a.theme-blue {
            background: url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/tab-right-inner.gif") no-repeat 100% 0px!important; 
        }
            
        ul.jtabs li.active {
            background: #ced9e1 no-repeat 0 -5px!important; 
            display: inline-block
        }
            
        #overlay-info-template {
            position: absolute; 
            display: block; 
            width: 250px; 
            height: auto!important;  
            z-index: 1002; 
            border-radius:2px; 
            background: #bcd0f4; 
            padding: 0px; 
            display: none;                 
        }
            
        #close-template-info {
            position: absolute; 
            left: 232px; 
            top: 0; 
            text-decoration: underline; 
            color: #fff; 
            cursor: pointer; 
        }
            
        .shift-down {
            position: relative; 
            margin: 5px 0 0 2px; 
            font-size: 11px; 
        }
            
        #overlay-info-template,#overlay-area {
            position: absolute; 
            display: block; 
            width: 250px; 
            height: 232px; 
            z-index: 1002; 
            border: 1px solid #458bc1; 
            xbackground: #bcd0f4; 
            padding: 0px; 
            display: none; 
        }
        
        #overlay-area {
            width: 200px; 
            padding: 4px; 
        } 
        
        #overlay-area textarea {
            height: 97%; 
            width: 98%; 
        }
        
        .connected_sorts li {
            font-weight: 200;
        }
        
        .decide-total-column .mark-as-total {
            display: block;
        }
        
        .mark-as-total {
            display: none;
            width: 100%;
            text-align: center;
        }
        
        dl.notes {
            margin: 0;
            padding: 0;
        }
        
        dl.notes dt {
            margin: 0 0 0 0;
            font-weight: bold;
        }
        
        dl.notes dd {
            margin: 0 0 5px 15px;
        }

            .column-real-name {
                position: relative;
                top: -3px;
                left:3px;
            }

            td label b,
            u,
            i {
                position:relative;
                top:-2px;
                left:2px;
            }

            #detail-column-region .main .zoomer {
                padding-right: 5px;
            }

            .small-form-element {
                padding: 0 0 0 3px
            }

            .invalid-data {
                background: #FB8689;
            }
    </style>
    </head>

    <body>
        <!-- Shift Legend from footer to tab fixed -->
        <div class="legend_new " >
            <div class="legend_new_sub">
                <table width="100%">
                    <tr valign="top">
                        <td>
                            <b><?php echo show_label('Legend'); ?></b>&nbsp &nbsp   
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/number-item.gif" align="middle" />&nbsp  <?php echo show_label('Number Item', false); ?> &nbsp  &nbsp 
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/text-item.gif" align="middle" />&nbsp  <?php echo show_label('Text Item', false); ?>&nbsp  &nbsp 
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/custom-item.gif" align="middle" />&nbsp  <?php echo show_label('Custom Item', false); ?>
                        </td>
                        <!--<td align="left">
                            <b><?php echo show_label('Note'); ?></b>     
                            <dl class="notes">
                                <dt>**</dt>
                                <dd><?php echo show_label('These options will be available/unavailable depending upon "Render as" option selected for the column.', false); ?></dd>
                                <dt>***</dt>
                                <dd><?php echo show_label('Total Aggregation when selected will let the column participate on Tablix Grand Total block.', false); ?></dd>
                                <dt>****</dt>
                                <dd><?php echo show_label('Placement for Total caption can be seletecd if this tablix has no grouping; on other cases it appears at first column.', false); ?></dd>
                            </dl> 
                        </td>-->
                    </tr>
                </table>                
            </div>
        </div>

        <?php
            function show_label($label_name, $flag = false) {
                return $label_name;
            }

            $mode = get_sanitized_value($_POST['mode'] ?? '');
            $resultset_id = get_sanitized_value($_POST['report_resultset_id'] ?? '');
            $report_id = get_sanitized_value($_POST['report_id'] ?? '');
            $page_id = get_sanitized_value($_POST['page_id'] ?? '');
            $top = get_sanitized_value($_POST['top'] ?? '');
            $left = get_sanitized_value($_POST['left'] ?? '');
            $report_tablix_id = get_sanitized_value($_POST['item_id'] ?? '');
            $width = get_sanitized_value($_POST['width'] ?? ''); 
            $height = get_sanitized_value($_POST['height'] ?? '');
            $summary_on = get_sanitized_value($_POST['summary_on'] ?? '');
            $process_id = get_sanitized_value($_POST['process_id'] ?? '');
            $current_type_id = 1;
            $renderer_type = get_sanitized_value($_POST['renderer_type'] ?? '');
            $dataset_id = get_sanitized_value($_POST['dataset_id'] ?? '');

            $xml_url = "EXEC spa_rfx_report_dataset_dhx @flag='h', @process_id='$process_id', @report_dataset_id='$dataset_id'";
            $ds_col_info_list = readXMLURL2($xml_url);

            $xml_url_udfs = "EXEC spa_rfx_report_dhx @flag='f', @process_id='null'";
            $scalar_functions_list = readXMLURL2($xml_url_udfs);    

            $tablix_name = '';
            $dataset_id = '';
            $current_cross_summary = '';
            $current_no_header = '';
            $current_border_style = '';
            $current_group_mode = '';
            $current_page_break = '';
            $export_table_name = '';
            $is_global = TRUE;
    
            $detail_columns = array();
            $grouping_columns = array();
            $cols_columns = array();
            $rows_columns = array();
            $existing_columns = array();

            $column_list_url = "EXEC spa_rfx_report_page_tablix_dhx @flag='c',@process_id='$process_id',@report_page_tablix_id='$report_tablix_id'";
            $column_list = readXMLURL2($column_list_url);
            
            if (is_array($column_list) && sizeof($column_list) > 0) {
                
                foreach ($column_list as $column) {
                    $column_variable = '';

                    switch ($column['placement']) {
                        case '1': $column_variable = 'detail_columns';
                            break;
                        case '2': $column_variable = 'grouping_columns';
                            break;
                        case '3': $column_variable = 'cols_columns';
                            break;
                        case '4': $column_variable = 'rows_columns';
                            break;
                    }

                    $font_style_array = explode(',', $column['font_style']);
                    $h_font_style_array = explode(',', $column['h_font_style']);
                    $data_type = ($column['datatype_id'] == '3' || $column['datatype_id'] == '4') ? 1 : 2;
                    
                    array_push($$column_variable, array(
                        'report_tablix_column_id' => $column['report_tablix_column_id'],
                        'group_entity' => $column['group_entity'],
                        'data_source_column_id' => $column['data_source_column_id'],
                        'column_id' => $column['column_id'],
                        'column_name' => $column['column_name'],
                        'column_real_name' => $column['column_real_name'],
                        'alias' => $column['alias'],
                        'functions' => $column['functions'],
                        'aggregation' => $column['aggregation'],
                        'sortable' => $column['sortable'],
                        'rounding' => $column['rounding'],
                        'thousand_seperation' => $column['thousand_seperation'],
                        'default_sort_order' => $column['default_sort_order'],
                        'sorting_column' => $column['sorting_column'],
                        'default_sort_direction' => $column['default_sort_direction'],
                        'font' => $column['font'],
                        'font_size' => $column['font_size'],
                        'font_style' => $column['font_style'],
                        'text_align' => $column['text_align'],
                        'text_color' => $column['text_color'],
                        'background' => $column['background'],
                        'h_font' => $column['h_font'],
                        'h_font_size' => $column['h_font_size'],
                        'h_font_style' => $column['h_font_style'],
                        'h_text_align' => $column['h_text_align'],
                        'h_text_color' => $column['h_text_color'],
                        'h_background' => $column['h_background'],
                        'placement' => $column['placement'],
                        'datatype' => $data_type,
                        'column_order' => $column['column_order'],
                        'bold_style' => $font_style_array[0],
                        'italic_style' => $font_style_array[1],
                        'underline_style' => $font_style_array[2],
                        'h_bold_style' => $h_font_style_array[0],
                        'h_italic_style' => ($h_font_style_array[1] ?? ''),
                        'h_underline_style' => ($h_font_style_array[2] ?? ''),
                        'render_as' => $column['render_as'],
                        'tooltip' => $column['tooltip'],
                        'column_template' => $column['column_template'],
                        'master_column_template' => $column['master_column_template'],
                        'negative_mark' => $column['negative_mark'],
                        'currency' => $column['currency'],
                        'date_format' => $column['date_format'],
                        'cross_summary_aggregation' => $column['cross_summary_aggregation'],
                        'mark_for_total' => $column['mark_for_total'],
                        'sql_aggregation' => $column['sql_aggregation'],
                        'subtotal' => $column['subtotal']
                    ));

                    array_push($existing_columns, $column['group_entity'] . '-' . $column['data_source_column_id']);
                }
            }

            $item_header_url = "EXEC spa_rfx_report_page_tablix_dhx @flag='a', @process_id='$process_id', @report_page_tablix_id='$report_tablix_id'";
            $item_header_values = readXMLURL2($item_header_url);
   
            if (is_array($item_header_values) && sizeof($item_header_values) > 0) {
                $item_name = $item_header_values[0]['name'];
                $dataset_id = $item_header_values[0]['root_dataset_id'];
                $dataset_alias = $item_header_values[0]['dataset_alias'];
                $data_source_id = $item_header_values[0]['data_source_id'];
                $group_mode = $item_header_values[0]['group_mode'];
                $border_style = $item_header_values[0]['border_style'];
                $page_break = $item_header_values[0]['page_break'];
                $tablix_type_id = ($item_header_values[0]['type_id'] == '') ? 1 : $item_header_values[0]['type_id'];
                $cross_summary = $item_header_values[0]['cross_summary'];
                $no_header = $item_header_values[0]['no_header'];
                $export_table_name = $item_header_values[0]['export_table_name'];
                $is_global = ($item_header_values[0]['is_global'] == '1') ? TRUE : FALSE;
            }

            $pivot_col_list['detail_columns'] = implode(',', array_map(function($item) {
                return $item['column_real_name'];
            }, $detail_columns));

            $pivot_col_list['grouping_columns'] = implode(',', array_map(function($item) {
                return $item['column_real_name'];
            }, $grouping_columns));

            $pivot_col_list['cols_columns'] = implode(',', array_map(function($item) {
                return $item['column_real_name'];
            }, $cols_columns));

            $pivot_col_list['rows_columns'] = implode(',', array_map(function($item) {
                return $item['column_real_name'];
            }, $rows_columns));
        ?>

    <script type="text/javascript">
        
        template_info_block = _.template(
        '<a onclick="javascript:close_tinfo()" id="close-template-info"><?php echo show_label('<img src="'. $app_php_script_loc . '/adiha_pm_html/process_controls/close.png"/>', false); ?></a>\
        <table class="data-table" width="100%">\
            <tr>\
                <th colspan="3"><?php echo show_label("About template"); ?> <%if (typeof(label) != "undefined") {print(label)} else{print("N/A")}%></th>\
            </tr>\
            <%if (typeof(label) != "undefined" && label != "Global") {%>\
            <tr>\
                <th width="40"><?php echo show_label("Style", false); ?></th>\
                <th><?php echo show_label("Header", false); ?></th>\
                <th><?php echo show_label("Column", false); ?></th>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Font", false); ?></td>\
                <td><%if (typeof(header_font) != "undefined") {print(header_font)} else{print("N/A")}%></td>\
                <td><%if (typeof(font) != "undefined") {print(font)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Font Size", false); ?></td>\
                <td><%if (typeof(header_font_size) != "undefined") {print(header_font_size)} else{print("N/A")}%></td>\
                <td><%if (typeof(font_size) != "undefined") {print(font_size+"pt")} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Font Style", false); ?></td>\
                <td><%if (typeof(header_font_style) != "undefined") {print(header_font_style)} else{print("N/A")}%></td>\
                <td><%if (typeof(font_style) != "undefined") {print(font_style)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Text Align", false); ?></td>\
                <td><%if (typeof(header_text_align) != "undefined") {print(header_text_align)} else{print("N/A")}%></td>\
                <td><%if (typeof(text_align) != "undefined") {print(text_align)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Text Color", false); ?></td>\
                <td>\
                    <%if (typeof(header_text_color) != "undefined") {%>\
                    <input type="text" readonly style="background:<%=header_text_color%>" class="adiha_control small-form-element" />\
                    <% } else { %>\
                    <input type="text" readonly value="N/A" class="adiha_control small-form-element" />\
                    <% }%>\
                </td>\
                <td>\
                    <%if (typeof(text_color) != "undefined") {%>\
                    <input type="text" readonly style="background:<%=text_color%>" class="adiha_control small-form-element" />\
                    <% } else { %>\
                    <input type="text" readonly value="N/A" class="adiha_control small-form-element" />\
                    <% }%>\
                </td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Background", false); ?></td>\
                <td>\
                    <%if (typeof(header_background) != "undefined") {%>\
                    <input type="text" readonly style="background:<%=header_background%>" class="adiha_control small-form-element" />\
                    <% } else { %>\
                    <input type="text" readonly value="N/A" class="adiha_control small-form-element" />\
                    <% }%>\
                </td>\
                <td>\
                    <%if (typeof(background) != "undefined") {%>\
                    <input type="text" readonly style="background:<%=background%>" class="adiha_control small-form-element" />\
                    <% } else { %>\
                    <input type="text" readonly value="N/A" class="adiha_control small-form-element" />\
                    <% }%>\
                </td>\
            </tr>\
            <% }%>\
        </table> \
        <table class="data-table" width="100%">\
            <tr>\
                <th colspan="2"><b class="formlabelL"><?php echo show_label("Column Formats", false); ?></b></th>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Thousand Separation", false); ?></td>\
                <td><%if (typeof(thousand) != "undefined") {print(thousand)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Rounding", false); ?></td>\
                <td><%if (typeof(rounding) != "undefined") {print(rounding)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Negative as Red", false); ?></td>\
                <td><%if (typeof(negative_mark) != "undefined") {print(negative_mark)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Currency", false); ?></td>\
                <td><%if (typeof(currency) != "undefined") {print(currency)} else{print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo show_label("Date format", false); ?></td>\
                <td><%if (typeof(date_format) != "undefined") {print(date_format)} else{print("N/A")}%></td>\
            </tr>\
                </table>'
            ); 
        
        add_column = _.template(
        '<tr class="clone <%=item_classes%>">\
            <td width="180" nowrap>\
                <label>\
                    <input type="checkbox" value="1" class="remove-column context-form-item" <%=item_disabled%> /><span class="column-real-name"><%=item_label_real%></span>\
                </label>\
            </td>\
            <td width="180" nowrap>\
                <span class="column"><%=item_label%></span>\
            </td>\
            <td width="25">\
                <input type="hidden" class="item-id" value="<%=item_id%>" />\
                <input type="hidden" class="column-id" value= "<%=item_column_id%>" />\
                <input type="hidden" class="report-tablix-column-id" value= "" />\
                <span class="item-logo"></span>\
            </td>\
            <td class="base">\
                <input type="text" value="" style="display:" class=" adiha_control function enlarge-this large-form-element" />\
            </td>\
            <td class="base"> <input type="text" value="<%=item_alias%>" class="adiha_control column-alias large-form-element" /></td>\
            <td class="base"> <input type="text" value="" class="adiha_control sort-priority small-form-element" /> </td>\
            <td class="base">\
                <select class="adiha_control sort-column context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($ds_col_info_list as $ds_col_info): ?>
                        <option value="<?php echo $ds_col_info["data_source_column_id"]; ?>"><?php echo $ds_col_info["alias"]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="base">\
                <select class="adiha_control sort-to-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_sort_option as $sort_to): ?>
                        <option value="<?php echo $sort_to[0]; ?>"><?php echo $sort_to[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="base"> <input type="checkbox" value="1" class="sort-link-header context-form-item" <?php echo ($rdl_column_default_attributes["sortable"] == 1) ? " checked=\"checked\"" : "";?>/></td>\
            <td class="base sub-total"> <input type="checkbox" value="1" class="add-sub-total context-form-item" <?php echo (array_key_exists('sub_total', $column ?? array()) && $column["sub_total"] == 1) ? " checked=\"checked\"" : ""; ?>/></td>\
            <td class="aggr detail-item">\
                <select class="adiha_control sql-aggregations-list context-form-item">\
                    <option value="">NONE</option>\
                    <?php
                    foreach ($rdl_column_aggregation_option as $aggregation):
                        if ($aggregation[5] == '1'):
                            ?>
                            <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>\
                            <?php
                        endif;
                    endforeach;
                    ?>
                </select>\
            </td>\
            <td class="aggr detail-item">\
                <select class="adiha_control aggregations-list context-form-item">\
                    <option value="<%=sub_sec_agg%>"><%=sub_sec_agg_label%></option>\
                    <?php
                    foreach ($rdl_column_aggregation_option as $aggregation):
                        if ($aggregation[4] == '1'):
                            ?>
                        <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>\
                            <?php
                        endif;
                    endforeach;
                    ?>
                </select>\
            </td>\
            <td class="aggr detail-item">\
                <select class="adiha_control cross-aggregations-list context-form-item">\
                    <option value="-1">NONE</option>\
                    <?php
                    foreach ($rdl_column_aggregation_option as $aggregation):
                        if ($aggregation[4] == '1'):
                            ?>
                            <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>\
                            <?php
                        endif;
                    endforeach;
                    ?>
                </select>\
            </td>\
            <td class="aggr">\
                <label class="mark-as-total"><input value="1" type="radio" class="adiha_control mark-for-total" name="mark_for_total" /></label>\
            </td>\
            <td class="cdisplay">\
                <select class="adiha_control renderas-list context-form-item">\
                    <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                        <option value="<?php echo $render_as[0]; ?>" ><?php echo $render_as[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="cdisplay">\
                <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                    <select class="adiha_control column-template column-template-<?php echo $key ?>" rel="<?php echo $key ?>">\
                        <option class="custom" value="-1">Custom</option>\
                        <?php if ($key != '1' && $key != '6'): ?>
                            <option class="custom" value="0">Global</option>\
                        <?php endif; ?>
                        <?php foreach ($template_base as $template): ?>
                            <option rel="<?php echo $template["type"]; ?>" value="<?php echo $template["id"]; ?>" ><?php echo $template["label"]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                <?php endforeach; ?>
                <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.png" align="middle" />\
            </td>\
            <td class="cdisplay">\
                <div class="render-option render-option-date">\
                    <select class="adiha_control date-format-list ">\
                        <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                            <option value="<?php echo $date_format[0]; ?>" ><?php echo $date_format[1]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                </div>\
            </td>\
            <td class="cdisplay">\
                <div class="render-option render-option-currency">\
                    <select class="adiha_control currency-list ">\
                        <?php foreach ($rdl_column_currency_option as $currency): ?>
                            <option value="<?php echo $currency[0]; ?>" ><?php echo $currency[1]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                </div>\
            </td>\
            <td class="cdisplay">\
                <div class="render-option render-option-thousand">\
                    <select class="thousand-list adiha_control" >\
                        <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                            <option value="<?php echo $option[0]; ?>" ><?php echo $option[1]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                </div>\
            </td>\
            <td class="cdisplay">\
                <div class="render-option render-option-round">\
                    <select class="adiha_control rounding-list ">\
                        <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                            <option value="<?php echo $rounding[0]; ?>"><?php echo $rounding[1]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                </div>\
            </td>\
            <td class="cdisplay">\
                <div class="render-option render-option-negative">\
                    <select class="negative-mark-list adiha_control" >\
                        <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                            <option value="<?php echo $option[0]; ?>"><?php echo $option[1]; ?></option>\
                        <?php endforeach; ?>
                    </select>\
                </div>\
            </td>\
            <td class="display">\
                <select class="adiha_control font-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_font_option as $font): ?>
                        <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $rdl_column_default_attributes["font"]) ? "selected" : ""; ?>><?php echo $font[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="display">\
                <select class="adiha_control font-size-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                        <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $rdl_column_default_attributes["font_size"]) ? "selected" : ""; ?>><?php echo $font_size[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="display" nowrap>\
                <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" /><b>B</b></label>\
            </td>\
            <td class="display" nowrap>\
                <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" /><i>I</i></label>\
            </td>\
            <td class="display" nowrap>\
                <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" /><u>U</u></label>\
            </td>\
            <td class="display">\
                <select class="adiha_control text-align-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                        <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $rdl_column_default_attributes["text_align"]) ? "selected" : ""; ?>><?php echo $text_align[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="display">\
                <input type="text" style="background: <?php echo $rdl_column_default_attributes["text_color"]; ?>; color: <?php echo $rdl_column_default_attributes["text_color"]; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-<%=item_id%>" value="<?php echo $rdl_column_default_attributes["text_color"]; ?>" readonly="readonly"/>\
            </td>\
            <td class="display">\
                <input type="text" style="background: <?php echo $rdl_column_default_attributes["background"]; ?>; color: <?php echo $rdl_column_default_attributes["background"]; ?>" class="adiha_control background-list small-form-element context-form-item" id="background-list-<%=item_id%>" value="<?php echo $rdl_column_default_attributes["background"]; ?>" readonly="readonly"/>\
            </td>\
            <td class="hdisplay">\
                <select class="adiha_control header-font-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_font_option as $font): ?>
                        <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $rdl_header_default_attributes["font"]) ? "selected" : ""; ?>><?php echo $font[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="hdisplay">\
                <select class="adiha_control header-font-size-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                        <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $rdl_header_default_attributes["font_size"]) ? "selected" : ""; ?>><?php echo $font_size[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <?php $font_default_info = explode(',', $rdl_header_default_attributes['font_style']); ?>
            <td class="hdisplay" nowrap> \
                <label style="display: inline-block;"><input type="checkbox" value="" class="header-bold-checkbox context-form-item" <?php echo ($font_default_info[0] == 1) ? " checked=\"checked\"" : ""; ?> /><b>B</b></label>\
            </td>\
            <td class="hdisplay" nowrap>\
                <label style="display: inline-block;"><input type="checkbox" value="" class="header-italic-checkbox context-form-item" <?php echo ($font_default_info[1] == 1) ? " checked=\"checked\"" : ""; ?> /><i>I</i></label>\
            </td>\
            <td class="hdisplay" nowrap>\
                <label style="display: inline-block;"><input type="checkbox" value="" class="header-underline-checkbox context-form-item" <?php echo ($font_default_info[2] == 1) ? " checked=\"checked\"" : ""; ?> /><u>U</u></label>\
            </td>\
            <td class="hdisplay">\
                <select class="adiha_control header-text-align-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                        <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $rdl_header_default_attributes["text_align"]) ? "selected" : ""; ?>><?php echo $text_align[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="hdisplay">\
                <input type="text" style="background: <?php echo $rdl_header_default_attributes["text_color"]; ?>; color: <?php echo $rdl_header_default_attributes["text_color"]; ?>" class="adiha_control header-text-color-list small-form-element context-form-item" id="header-text-color-list-<%=item_id%>" value="<?php echo $rdl_header_default_attributes["text_color"]; ?>" readonly="readonly"/>\
            </td>\
            <td class="hdisplay">\
                <input type="text" style="background: <?php echo $rdl_header_default_attributes["background"]; ?>; color: <?php echo $rdl_header_default_attributes["background"]; ?>" class="adiha_control header-background-list small-form-element context-form-item" id="header-background-list-<%=item_id%>" value="<?php echo $rdl_header_default_attributes["background"]; ?>" readonly="readonly"/>\
            </td>\
                </tr>'
            );
    </script>

    <script type="text/javascript">
        mode = '<?php echo $mode; ?>'
        resultset_id = '<?php echo $resultset_id ?>';
        var template = <?php echo json_encode($rdl_column_attributes_template); ?> ;
        var rounding_list = <?php echo json_encode($rdl_column_rounding_option); ?> ;
        var date_format_list = <?php echo json_encode($rdl_column_date_format_option); ?> ;
        var currency_list = <?php echo json_encode($rdl_column_currency_option); ?> ;
        var dataset_columns = null;
        var drop_yesno_list = <?php echo json_encode($rdl_generic_drop_options_yes_no); ?> ;
        var renderer_type_id = <?php echo $renderer_type; ?>;
        var tablix_summary_id = '<?php echo $summary_on; ?>';
        var scalar_functions_list = _.pluck(<?php echo json_encode($scalar_functions_list); ?>,'function_name');
        
        ace.require("ace/ext/language_tools");
        
        editor_gbl = '';
        
        function close_tinfo() {
            $('#overlay-info-template').fadeOut('fast');
        }

            /*
             * Function to show/hide mark-as-total radio, 
             * enable/disable total-aggr combo,
             * enable/disable sub-total checkbox
        */
        fx_summary_on_change = function(summary_on) {
            tablix_summary_id = summary_on;
            
            if(renderer_type_id == 1) {
                    
                if(summary_on == 2) {
                    $('.mark-as-total').show();
                    $('.cross-aggregations-list').attr('disabled', false);
                } else {
                    $('.mark-as-total').hide();
                    $('.cross-aggregations-list').attr('disabled', true);
                }
            } else {
                $('.mark-as-total').hide();
                    
                if(summary_on == 2 || summary_on == 3 || summary_on == 4) {
                    $('.cross-aggregations-list').attr('disabled', false);
                    $('.add-sub-total').attr('disabled', false);
                } else {
                    $('.cross-aggregations-list').attr('disabled', true);
                    $('.add-sub-total').attr('checked', false);
                    $('.add-sub-total').attr('disabled', true);
                }
            }
            }
            
            /* 
             *Function to set header and column alignment according to standard
        */
        fx_align_header_column_text_align = function() {
            $('.clone', '#detail-column-region,#group-column-region,#cols-column-region,#rows-column-region').each(function (index){
                
                if($('.report-tablix-column-id', $(this)).attr('value') == '') {
                        
                    if($(this).hasClass('text-item')) {
                        $('.text-align-list', $(this)).val('Left');
                        $('.header-text-align-list', $(this)).val('Left');   
                        
                        if(('.column-real-name', $(this)).text().indexOf('currency') > -1 || ('.column-real-name', $(this)).text().indexOf('uom') > -1) {
                            $('.text-align-list', $(this)).val('Right');
                            $('.header-text-align-list', $(this)).val('Right');
                        } 
                    } else {
                        $('.text-align-list', $(this)).val('Right');
                        $('.header-text-align-list', $(this)).val('Right');
                    }    
                }
            });
        }
        
            /*
             * Function to order the columns as moved on pivot UI
             */
        fx_order_columns = function(column_arr) {
            
            if(column_arr['renderer_type'] == 'Table') {
                
                var tr_header_dc = $('tr', $('#detail-column-region')).eq(0);
                var tr_header_gc = $('tr', $('#group-column-region')).eq(0);

                //ordering for detail columns
                if(column_arr['detail_columns'] != '') {
                        
                    $(column_arr['detail_columns'].split(',')).each(function(key, value) {
                            
                        $('tr.clone', '#detail-column-region').each(function(key1, value1) {
                            var col_name_adv = $('.column-real-name', $(this)).text();
                                
                            if(col_name_adv.toLowerCase() == value.toLowerCase() 
                                    || (
                                        $(this).hasClass('custom-column') 
                                        && $('.column-alias', $(this)).val().toLowerCase() == value.toLowerCase()
                                    )
                            ) {
                                var selected_data = [];
                
                                $(this).find('select').each(function() {
                                    selected_data.push($(this).val());
                                });
                                
                                var tr_new = $(this).clone(true, true).attr('column_order', key);
                                $(this).remove();
                                
                                if(key == 0) {
                                    tr_header_dc.after(tr_new);
                                } else {
                                    $('tr[column_order]', $('#detail-column-region')).eq(-1).after(tr_new);
                                }

                                tr_new.find('select').each(function (index, item) {
                                    $(item).val(selected_data[index]);
                                });
                            }
                        });
                    });
                }
                
                //ordering for grouping columns
                if(column_arr['grouping_columns'] != '') {
                        
                    $(column_arr['grouping_columns'].split(',')).each(function(key, value) {
                            
                        $('tr.clone', '#group-column-region').each(function(key1, value1) {
                            var col_name_adv = $('.column-real-name', $(this)).text();
                                 
                             if(col_name_adv.toLowerCase() == value.toLowerCase() 
                                    || (
                                        $(this).hasClass('custom-column') 
                                        && $('.column-alias', $(this)).val().toLowerCase() == value.toLowerCase()
                                    )
                            ) {
                                var selected_data = [];
                
                                $(this).find('select').each(function() {
                                    selected_data.push($(this).val());
                                });
                                
                                var tr_new = $(this).clone(true, true).attr('column_order', key);
                                $(this).remove();
                                
                                if(key == 0) {
                                    tr_header_gc.after(tr_new);
                                } else {
                                    $('tr[column_order]', $('#group-column-region')).eq(-1).after(tr_new);
                                }

                                tr_new.find('select').each(function (index, item) {
                                    $(item).val(selected_data[index]);
                                });
                            }
                        });
                    });
                }
            } else { //crosstab table
                var tr_header_dc = $('tr', $('#detail-column-region')).eq(0);
                var tr_header_rc = $('tr', $('#rows-column-region')).eq(0);
                var tr_header_cc = $('tr', $('#cols-column-region')).eq(0);
                
                //ordering for rows columns
                if(column_arr['rows'] != '') {
                        
                    $(column_arr['rows'].split(',')).each(function(key, value) {
                           
                        $('tr.clone', '#rows-column-region').each(function(key1, value1) {
                            var col_name_adv = $('.column-real-name', $(this)).text();
                                
                            if(col_name_adv.toLowerCase() == value.toLowerCase()) {
                                var selected_data = [];
                
                                $(this).find('select').each(function() {
                                    selected_data.push($(this).val());
                                });
                                
                                var tr_new = $(this).clone(true, true).attr('column_order', key);
                                $(this).remove();
                                
                                if(key == 0) {
                                    tr_header_rc.after(tr_new);
                                } else {
                                    $('tr[column_order]', $('#rows-column-region')).eq(-1).after(tr_new);
                                }

                                tr_new.find('select').each(function (index, item) {
                                    $(item).val(selected_data[index]);
                                });
                            }
                        });
                    });
                }
                
                //ordering for cols columns
                if(column_arr['columns'] != '') {
                        
                    $(column_arr['columns'].split(',')).each(function(key, value) {
                            
                        $('tr.clone', '#cols-column-region').each(function(key1, value1) {
                            var col_name_adv = $('.column-real-name', $(this)).text();
                                
                            if(col_name_adv.toLowerCase() == value.toLowerCase()) {
                                var selected_data = [];
                
                                $(this).find('select').each(function() {
                                    selected_data.push($(this).val());
                                });
                                
                                var tr_new = $(this).clone(true, true).attr('column_order', key);
                                $(this).remove();
                                
                                if(key == 0) {
                                    tr_header_cc.after(tr_new);
                                } else {
                                    $('tr[column_order]', $('#cols-column-region')).not('.custom-column').eq(-1).after(tr_new);
                                }

                                tr_new.find('select').each(function (index, item) {
                                    $(item).val(selected_data[index]);
                                });
                            }
                        });
                    });
                }
                
                //ordering for detail columns
                if(column_arr['detail_columns'] != '') {
                        
                    $(column_arr['detail_columns'].split(',')).each(function(key, value) {
                            
                        $('tr.clone', '#detail-column-region').each(function(key1, value1) {
                            var col_name_adv = $('.column-real-name', $(this)).text();
                            var col_name_pvt = value.split('||||')[1];                            

                            if(col_name_adv.toLowerCase() == col_name_pvt.toLowerCase() 
                                    || (
                                        $(this).hasClass('custom-column') 
                                        && $('.column-alias', $(this)).val().toLowerCase() == col_name_pvt.toLowerCase()
                                    )
                            ) {
                                var selected_data = [];
                
                                $(this).find('select').each(function() {
                                    selected_data.push($(this).val());
                                });
                                
                                var tr_new = $(this).clone(true, true).attr('column_order', key);
                                $(this).remove();
                                
                                if(key == 0) {
                                    tr_header_dc.after(tr_new);
                                } else {
                                    $('tr[column_order]', $('#detail-column-region')).eq(-1).after(tr_new);
                                }

                                tr_new.find('select').each(function (index, item) {
                                    $(item).val(selected_data[index]);
                                });
                            }
                        });
                    });
                }
            }
        }

        $(function() {
                /*
                 * new filter selector 
                 * case insensitive contains filter
                 * for search filter
                 */
            $.expr[':'].ci_contains = function (a, i, m) {
                return $(a).text().toLowerCase().indexOf(m[3].toLowerCase()) >= 0;
            };
            
            fx_summary_on_change(tablix_summary_id);
            fx_align_header_column_text_align();
	
            var move_table_row = function (current_row, to_context, item_position) {
                var selected_data = Array();
                var item_content;
                current_row.parents('tr').eq(0).find('.function').autocomplete('destroy');
                
                current_row.parents('tr').eq(0).find('select').each(function() {
                    selected_data.push($(this).val());
                });
                
                item_content = current_row.parents('tr').eq(0).clone(true, true);
                current_row.parents('tr').eq(0).remove();
                    $(to_context).eq(item_position).after(item_content);
               
               $(to_context).eq(item_position + 1).find('select').each(function (index, item) {
                    $(item).val(selected_data[index]);
                });
            }
	
            var sync_table = function (event, ui) {
                var item_id = ui.item.attr('id').replace('rs-column-', '');
                var item_label = ui.item.text();
                var item_real_name = ui.item.attr('otitle');
                var item_position = ui.item.index();
                var item_nature = ui.item.attr('rel');
                var location = ui.item.parent().attr('id'); //landed on?
                var group_row = $('.item-id[value="' + item_id + '"]', $('#group-column-region'));
                var detail_row = $('.item-id[value="' + item_id + '"]', $('#detail-column-region'));
                var cols_row = $('.item-id[value="' + item_id + '"]', $('#cols-column-region'));
                var rows_row = $('.item-id[value="' + item_id + '"]', $('#rows-column-region'));
                var type_id = renderer_type_id;
		
                switch (location) {
                    case 'all-columns-rs':
                        group_row.parents('tr').eq(0).remove();
                        detail_row.parents('tr').eq(0).remove();
                        cols_row.parents('tr').eq(0).remove();
                        rows_row.parents('tr').eq(0).remove();
                        break;
			
                    case 'detail-columns-rs':
                        if (type_id == '1' && group_row.length > 0) { //if exists on group
                            move_table_row(group_row, '#detail-column-region tr', item_position);				
                        } else if (type_id == '2' && cols_row.length > 0) { //if exists on cols
                            move_table_row(cols_row, '#detail-column-region tr', item_position);				
                        } else if (type_id == '2' && rows_row.length > 0) { //if exists on rows
                            move_table_row(rows_row, '#detail-column-region tr', item_position);				
                        } else if (detail_row.length == 0) { //else add to Detail Row
                            register_column(1, item_position, item_id, item_label, item_nature, item_real_name);				
                        } else if (detail_row.length > 0) { //if sorted on self
                            var table_position = detail_row.parents('tr').eq(0).index() - 1;
                            if (item_position != table_position) {
                                move_table_row(detail_row, '#detail-column-region tr', item_position);
                            }
                        }			
                        break;
			
                    case 'grouping-columns-rs':
                        //if exists on detail, we move table row from detail to group
                        if (detail_row.length > 0) {
                            move_table_row(detail_row, '#group-column-region tr', item_position);				
                        } else if ($('.item-id[value="' + item_id + '"]', $('#group-column-region')).length == 0) { //else add to Group Row
                            register_column(2, item_position, item_id, item_label, item_nature, item_real_name);				
                        } else if (group_row.length > 0) { //if in same group then sort it
                            var table_position = group_row.parents('tr').eq(0).index() - 1;
                            if (item_position != table_position) {
                                move_table_row(group_row, '#group-column-region tr', item_position);
                            }
                        }
                        break;
			
                    case 'cols-columns-rs':
                        //if exists on detail, we move table row from detail to group
                        if (detail_row.length > 0) {
                            move_table_row(detail_row, '#cols-column-region tr', item_position);				
                        } else if (rows_row.length > 0) { //if exists on rows
                            move_table_row(rows_row, '#cols-column-region tr', item_position);				
                        } else if ($('.item-id[value="' + item_id + '"]', $('#cols-column-region')).length == 0) { //else add to Cols Row
                            register_column(3, item_position, item_id, item_label, item_nature, item_real_name);				
                        } else if (cols_row.length > 0) { //if in same group then sort it
                            var table_position = cols_row.parents('tr').eq(0).index() - 1;
                            if (item_position != table_position) {
                                move_table_row(cols_row, '#cols-column-region tr', item_position);
                            }
                        }
                        break;
			
                    case 'rows-columns-rs':
                        //if exists on detail, we move table row from detail to group
                        if (detail_row.length > 0) {
                            move_table_row(detail_row, '#rows-column-region tr', item_position);				
                        } else if (cols_row.length > 0) { //if exists on rows
                            move_table_row(cols_row, '#rows-column-region tr', item_position);				
                        } else if ($('.item-id[value="' + item_id + '"]', $('#rows-column-region')).length == 0) { //else add to Cols Row
                            register_column(4, item_position, item_id, item_label, item_nature, item_real_name);				
                        } else if (rows_row.length > 0) { //if in same group then sort it
                            var table_position = rows_row.parents('tr').eq(0).index() - 1;
                            if (item_position != table_position) {
                                move_table_row(rows_row, '#rows-column-region tr', item_position);
                            }
                        }
                        break;
                }
		
                settle_aggregation();
            }
	
            $('#all-columns-rs,#detail-columns-rs,#grouping-columns-rs,#cols-columns-rs,#rows-columns-rs').sortable({
                connectWith : '.connected_sorts',
                placeholder : 'place-holding',
                revert : 100,
                containment : '.drag-area',
                stop : sync_table,
                out : function (event, ui) {
                        if (ui.item.hasClass('custom-column') && ui.item.parent().attr('id') == 'all-columns-rs') {
                        $(ui.sender).sortable('cancel');
                        }
                },
                receive : function (event, ui) {
                    var $this = $(this);
                    if ($this.children('li').length > 1 && ($this.attr('id') == "cols-columns-rs" || $this.attr('id') == "rows-columns-rs")) {
                        //$(ui.sender).sortable('cancel');
                    }
                }
            });

            $('#all-columns-rs,#detail-columns-rs,#grouping-columns-rs,#cols-columns-rs,#rows-columns-rs').disableSelection();
	
            if (renderer_type_id == '1') {
                $('#cols-columns-rs,#rows-columns-rs').sortable('disable');
            } else {
                $('#grouping-columns-rs').sortable('disable');
            }

                /* 
                 * function that applies changes once a template is selected for a given rtender type
                 */
            var register_template_event = function (context) {
                var container_obj = context.parents('tr').eq(0);
                var template_type = context.find('option:selected').attr('rel');
                var template_selected = context.val();
		
                    if (template_selected == '-1') {
                    return false;
                    }
		
                    var populate_list = [
                        ['font', '.font-list', 1],
                                    ['font_size', '.font-size-list', 1],
                                    ['font_style', '.bold-checkbox,.italic-checkbox,.underline-checkbox', 4],
                                    ['text_align', '.text-align-list', 1],
                                    ['text_color', '.text-color-list', 2],
                                    ['background', '.background-list', 2],
                                    ['header_font', '.header-font-list', 1],
                                    ['header_font_size', '.header-font-size-list', 1],
                                    ['header_font_style', '.header-bold-checkbox,.header-italic-checkbox,.header-underline-checkbox', 4],
                                    ['header_text_align', '.header-text-align-list', 1],
                                    ['header_text_color', '.header-text-color-list', 2],
                                    ['header_background', '.header-background-list', 2],
                                    ['thousand', '.thousand-list', 1],
                                    ['rounding', '.rounding-list', 1],
                                    ['negative_mark', '.negative-mark-list', 1],
                                    ['currency', '.currency-list', 1],
                                    ['date_format', '.date-format-list', 1]
                ];
		
                    // act for global template; handles thousand, rounding, negative_mark, currency, date_format
                    if (template_selected == '0') {
                        
                    populate_list = [
                                    ['thousand', '.thousand-list', 1],
                                    ['rounding', '.rounding-list', 1],
                                    ['negative_mark', '.negative-mark-list', 1],
                                    ['currency', '.currency-list', 1],
                                    ['date_format', '.date-format-list', 1]
                    ];
			
                    _.each(populate_list, function (item) {
                        $(item[1], container_obj).val('0');
                    });
			
                    return true;
                }
		
                _.each(populate_list, function (item) {
                    var item_value = template[template_type][template_selected][item[0]];
			
                    switch (item[2]) {
                        case 1: //normal input and select
                                
                                if (item_value != undefined) {
                                $(item[1], container_obj).val(item_value);
                                }
                            break;
                            case 2: //colorpicker
				
                            if (item_value != undefined) {
                                $(item[1], container_obj).val(item_value);
                                $(item[1], container_obj).css('color', item_value);
                                $(item[1], container_obj).css('background', item_value);
                            }
                            break;
                            case 3: //checkbox
				
                            if (item_value != undefined) {
                                    
                                if (item_value == '1') {
                                    $(item[1], container_obj).attr('checked', true);
                                } else {
                                    $(item[1], container_obj).attr('checked', false);
                                }
                            }
                            break;
                            case 4: // B I U
				
                            if (item_value != undefined) {
                                var style = item_value.split(',');
                                var tags = item[1].split(',');

                                for (x in tags) {
                                        
                                    if (style[x] == '1') {
                                        $(tags[x], container_obj).attr('checked', true);
                                    } else {
                                        $(tags[x], container_obj).attr('checked', false);
                                    }
                                }
                            }
                            break;
                    }
			
                });
            }
            
            /*function that shows/hides ** Render options  */
            var register_render_event = function (context_item) {
                var container_obj = context_item.parents('tr').eq(0);
                var render_value = context_item.val();
		
                switch (render_value) {
                    case '2': //Number
                        $('.render-option', container_obj).hide();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;
                    case '3': //Currency
					case '13': //Price
                        $('.render-option', container_obj).hide();
                        $('.render-option-currency', container_obj).show();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;
                    case '4': //Date
                        $('.render-option', container_obj).hide();
                        $('.render-option-date', container_obj).show();
                        break;
                    case '5':
                    case '6': //Percentage & Scientific
                        $('.render-option', container_obj).hide();
                        $('.render-option-round', container_obj).show();
                        break;
                    case '14': //Volume
                        $('.render-option', container_obj).hide();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;
					case '1': //HTML
                    default: //TEXT
                        $('.render-option', container_obj).hide();
                }
		
                    // For Text (default) to be implemented as HTML templating
                    if (render_value == '0') {
                    render_value = '1';
                }
		
                $('.column-template', container_obj).hide();
                $('.column-template', container_obj).removeClass('current-template-option');
                var valueExists = $('.column-template-' + render_value, container_obj).has('[selected]');
		
                    if (!valueExists) { //tick if @ add mode
                    $('.column-template-' + render_value, container_obj).val('-1');
                    }
		
                $('.column-template-' + render_value, container_obj).addClass('current-template-option');
                $('.column-template-' + render_value, container_obj).show();
            }
	
                /* 
                 * Registers context menu, colorpicker, bind event to render list, 
                 * column templates, template info etc.
                 */
            var register_widgets = function (context_menu, item_id, restoration) {
                    
                    // Add js change function to alias field  used to captioning alias
                if (context_menu.hasClass('custom-column')) {
                        
                    $('.column-alias', context_menu).change(function() {
                        curr_item_id = $('.item-id', $(this).parents('tr').eq(0)).val();
                        $('.column', $(this).parents('tr').eq(0)).html($(this).val());
                        $('#rs-column-' + curr_item_id).text($(this).val());
                    });
                }
                
                    // Enlarger
                $('.enlarge-this',context_menu).click(function(e) {
    					
                        if ($('.overlay-content-reciever').length === 0) {
                            var context_item = $(this);
                            var location = context_item.offset();
                        var modal_height = 98;

                            var input_offset = $(e.target)[0].offsetTop;
                            var row_offset = $(e.target).closest('tr')[0].offsetTop;
                            var table_offset = $(e.target).closest('table')[0].offsetTop;
                            var modal_top = table_offset + row_offset + input_offset;
                            
                        fx_init_ace_editor(context_item.val());
                        context_item.attr('disabled',true);

                            $('#overlay-area').css({
                            'height':modal_height,
                            'width':'411px'
                            });

                            $('#overlay-area').css({
                            'top':modal_top,
                            'left':(location.left)-8
                            });

                            $('#overlay-area').show();
                            context_item.addClass('overlay-content-reciever');
                        }
                    });

                    var save_text_overlay = function(container) {
                        container.hide();
                        if(editor_gbl != "") {
                            $('.overlay-content-reciever').removeAttr('disabled');
                            $('.overlay-content-reciever').val(editor_gbl.getValue());
                            $('.overlay-content-reciever').removeClass('overlay-content-reciever');
                            editor_gbl.destroy();
                        }
                    }
                    
                    // Hide template info if clicked outside
                    $(document).mouseup(function (e) { 
                        var container = $("#overlay-area");
                        
                        if (container.has(e.target).length === 0 
                            && $('.ace_autocomplete').has(e.target).length === 0
                        ) {
                            save_text_overlay(container);
                        }
                    });

                    $(document).keypress(function(e) {
                        var container = $("#overlay-area");
                        if (e.which === 13) {
                            if (container.has(e.target).length === 1) {
                                save_text_overlay(container);
                            }
                        }
                    });
                
                //apply context menu
                var context_menu_assigner = function (el, item_object, value_current) {
                        
                    if ($(el).is('select')) { //if select
                            
                        if (item_object.find('option[value="' + value_current + '"]').prop('disabled') != true
                                && $(el).find('option[value="' + value_current + '"]').prop('disabled') != true
                            ) {
                            item_object.val(value_current);
                            }
                    } else { //else shud be input
                        item_object.val(value_current);
                    }

                    //if colorpicker, set background as well
                    if (item_object.hasClass('has-colorpicker')) {
                        item_object.css('background', value_current);
                        item_object.css('color', value_current);
                    }

                    //man handle checkbox
                    if ($(el).is('input:checkbox')) {
                        value_current = $(el).prop('checked');
                        item_object.prop('checked', value_current);
                    }
                };
		
                /*
                     * Apply Event on Render as field
                     * to show/hide render additional options
                */
                $('.renderas-list', context_menu).change(function() {
                    var context_item = $(this);
                    register_render_event(context_item);
                    settle_aggregation();
                });
		
                    /* 
                     * Apply Event on Column templates
                     * to apply template data on form row
                     */
                $('.column-template', context_menu).change(function() {
                    var context_item = $(this);
                    register_template_event(context_item);
                });
		
                    /* 
                     * Apply Event on Render options
                     * to mark custom if render option changed that chosen from template
                     */
                $('.render-option', context_menu).change(function (event) {
                    var context_item = $(this);
                    var container_obj = context_item.parents('tr').eq(0);
                    $('.current-template-option', container_obj).val('-1');
                    event.preventDefault();
                });
		
                    /* 
                     * Apply Event on Template info image
                     * to show info abt current template selected
                     */
                $('.template-info', context_menu).click(function (event) {
                    var context_item = $(this);
                    var template_ddn = context_item.prevAll('.current-template-option');
                    var template_id = template_ddn.val();
                    var template_options = {};
                    var template_type = template_ddn.attr('rel');
                    var x_val,
                    modal_height;
			
                    switch (template_id) {
                        case '-1':
                            return false;
                            break;
                        case '0':
                            modal_height = 130;
                                
                            template_options = {
                                label : 'Global',
                                thousand : 'Global',
                                rounding : 'Global',
                                negative_mark : 'Global',
                                currency : 'Global',
                                date_format : 'Global'
                            };

                            break;
                        default:
                            modal_height = 262;
				
                            if (template[template_type][template_id]) {
                                    
                                _.each(template[template_type][template_id], function (val, k) {
						
                                    switch (k) {
                                        case 'font_style':
                                        case 'header_font_style':
                                            val = val.split(',');
                                            x_val = (val[0] == 1) ? 'Bold, ' : '-, ';
                                            x_val += (val[1] == 1) ? 'Italic, ' : '-, ';
                                            x_val += (val[2] == 1) ? 'Underline' : '-';
                                            template_options[k] = x_val;
                                            break;
                                        case 'thousand':
                                        case 'negative_mark':
                                            template_options[k] = drop_yesno_list[val][1];
                                            break;
                                        case 'rounding':
                                            template_options[k] = rounding_list[val][1];
                                            break;
                                        case 'currency':
                                            template_options[k] = currency_list[val][1];
                                            break;
                                        case 'date_format':
                                            template_options[k] = date_format_list[val][1];
                                            break;
                                        default:
                                            template_options[k] = val;
                                    }
                                });
                            }
				
                            break;
                    }
			
                    var location = context_item.offset();

                    //show tooltip up or down depending upon current block postion
                    $('#overlay-info-template').css({
                        'height' : modal_height
                    });
			
                    $('#overlay-info-template').css({
                        'top' : (location.top < modal_height) ? (location.top) : (location.top - modal_height),
                        'left' : (location.left + 20)
                    });
			
                    $('#overlay-info-template').html(template_info_block(template_options));
                    $('#overlay-info-template').fadeIn('fast');
                });
		
                    $(document).mouseup(function (e) { 
                    var container = $("#overlay-info-template");
                        
                        if (container.has(e.target).length === 0) {
                        container.hide();
                        }
                });
		
                if (restoration == undefined) {
                    stack_id = $('.item-id', context_menu).val();
                    $('.renderas-list', context_menu).val(0);
                } else if (restoration != true) {
                    stack_id = $('.item-id', context_menu).val();
                    $('.renderas-list', context_menu).val(restoration);
                }
		
                $('.renderas-list', context_menu).trigger('change');
            }
	       
                /*
                 *Function called when Table or CrossTab Table is changed 
                 */
            tablix_type_change = function (type_id) {
                renderer_type_id = type_id;
                var current_id,
                parent_id,
                li_item;

                if (type_id == '1') {
                        
                    $('#crosstab-group li.drag-items').each(function() {
                        li_item = $(this);
                        current_id = li_item.attr('id').replace('rs-column-', '');
                        parent_id = li_item.parent('ul').attr('id');
                        parent_id = (parent_id == 'cols-columns-rs') ? 'cols-column-region' : 'rows-column-region';
                        $('.item-id[value="' + current_id + '"]', $('#' + parent_id)).parents('tr').eq(0).remove();
                        li_item.appendTo('#all-columns-rs');
                    });

                    $('.default-type-item').show();
                    $('.crosstab-type-item').hide();
                    $('#grouping-columns-rs').sortable('enable');
                    $('#cols-columns-rs,#rows-columns-rs').sortable('disable');
                    $('#tablix_no_header').attr('disabled', false);
                } else {
                        
                    $('#default-group li.drag-items').each(function() {
                        li_item = $(this);
                        current_id = li_item.attr('id').replace('rs-column-', '');
                        $('.item-id[value="' + current_id + '"]', $('#group-column-region')).parents('tr').eq(0).remove();
                        li_item.appendTo('#all-columns-rs');
                    });

                    $('.default-type-item').hide();
                    $('.crosstab-type-item').show();
                    $('#cols-columns-rs,#rows-columns-rs').sortable('enable');
                    $('#grouping-columns-rs').sortable('disable');
                    $('#tablix_no_header').attr('disabled', true);
                }
            }
            
                /* 
                 * Adds custom fields to sortable widget and column table @ Advanced tab
                 */
            register_column = function (location, position, item_id, item_label, item_nature, item_real_name, sub_sec_agg, sub_sec_agg_label) { //detail:1,group:2,columns:3,rows:4
		
                    if (sub_sec_agg == undefined) sub_sec_agg = '';
                    
                    if (sub_sec_agg_label == undefined) sub_sec_agg_label = '';

                    var context, context_sort;
    		
                switch (location) {
                    case 1:
                        context = '#detail-column-region tbody';
                        context_sort = '#detail-columns-rs';
                        break;
                    case 2:
                        context = '#group-column-region tbody';
                        context_sort = '#grouping-columns-rs';
                        break;
                    case 3:
                        context = '#cols-column-region tbody';
                        context_sort = '#cols-columns-rs';
                        break;
                    case 4:
                        context = '#rows-column-region tbody';
                        context_sort = '#rows-columns-rs';
                        break;
                }
		
                var context_menu,
                item_alias,
                item_class,
                item_column_id,
                curr_item_id,
                picker_id;
		
                if (item_id === undefined) {
                    item_id = _.uniqueId('new-clone-');
                }
		
                if (position === undefined) {
                        
                    $(context).append(add_column({
                        item_id : item_id,
                        item_column_id : '',
                        item_label : '&lt;Custom Column&gt;',
                        item_label_real : '&lt;Custom Column&gt;',
                        item_alias : '',
                        function_display : '',
                        item_classes : 'custom-column text-item',
                        sub_sec_agg: sub_sec_agg,
                        sub_sec_agg_label: sub_sec_agg_label,
                        item_disabled: ''
                    }));

                    //add sort control to sort widget
                    $(context_sort).append("<li class='drag-items custom-column' id='rs-column-" + item_id + "'>&lt;Custom Column&gt;</li>");
                    context_menu = $(context + ' tr:last');

                    //set column order of custom column to last
                    var column_order_value = '0';
                        
                    if($('.clone[column_order]', context).length > 0) {
                        column_order_value = (parseInt($('.clone[column_order]', context).eq(-1).attr('column_order')) + 1).toString();
                    }

                    $(".item-id[value='" + item_id + "']", context).closest('tr.custom-column').attr('column_order', column_order_value);
                } else {
                    item_class = (item_nature == '0' || item_nature == '4') ? 'text-item' : '';
                    
                    if (item_real_name == 'Custom Column') {
                        item_real_name = '&lt;Custom Column&gt;';
                        var column_disabled = '';
                        item_alias = item_label;
                            item_column_id = '';
                        item_class = 'custom-column text-item';
                    } else {
                        var column_disabled = 'disabled=""';
                        item_alias = item_label.split('.')[1];
                        item_column_id = item_id.split('-')[1];
                        }

                    $(context + ' tr').eq(position).after(add_column({
                        item_id : item_id,
                        item_column_id : item_column_id,
                        item_label : item_label,
                        item_label_real : item_real_name,
                        item_alias : item_alias,
                        function_display : 'none',
                        item_classes : item_class,
                        sub_sec_agg: sub_sec_agg,
                        sub_sec_agg_label: sub_sec_agg_label,
                        item_disabled: column_disabled
                    }));

                    context_menu = $(context + ' tr').eq(position + 1);
                }

                register_widgets(context_menu, item_id, item_nature);
            }
	
                /* 
                 * Removes custom field from sortable widget and Column table 
                 * @ Advanced tab, and while deleting dataset column, removes 
                 * from the column table @ Advanced tab and shifts sort li to 
                 * Available Fields
                 */
            delete_column = function (context) {
                var deletion_queue = [];
                
                $('.remove-column', context).each(function(v) {
                    var is_remove = $(this).is(':checked');

                    if (is_remove) {
                        deletion_queue.push($(this));
                    }
                });
                
                var parent_block;
                var item_id;
                var html_content;
		
                if (deletion_queue.length == 0) {
                    show_messagebox('VALIDATE_COLUMN_DELETE');
                    return false;
                } else {
                    $.each(deletion_queue, function (index, item) {
                        parent_block = $(item).parents('tr.clone').eq(0);
                        item_id = $('.item-id', parent_block).val();
				
                        if (!parent_block.hasClass('custom-column')) {
                            html_content = $('#rs-column-' + item_id).clone(true);
                            $('#rs-column-' + item_id).remove();
                            $('#all-columns-rs').append(html_content);
                        } else {
                            $('#rs-column-' + item_id).remove();
                        }
				
                        parent_block.remove();
                    });
                }
            }
            
                /*
                 * Check the field to remove and call delete function
                 */
            delete_column_dragged = function (context, column_id) {
                var c_flag = 0;
                    
                $( ".column-id", context).each(function() {
                        
                    if ($(this).val() == '') {
                        var col_id = $(this).closest('tr').find('span.column').text();
                    } else {
                        var col_id = $(this).val();    
                    }

                    if (col_id == column_id) {
                        c_flag = 1;
                        $('.remove-column', $(this).closest('tr')).attr('checked','checked');
                    }
                });
                
                if (c_flag == 1) {
                    delete_column(context);
                }
            }
	
                /*
                 * Disable/Enable Aggregation Options in the dropdown 
                 * depending upon condition
                 */
            var settle_aggregation = function() {
                var type_id = renderer_type_id;
		
                    // if no group selected in default type
                    if (type_id == '1' && $('#group-column-region tr').length == 1) {                    
                    $('.aggregations-list', $('#detail-column-region')).attr('disabled', false);
                    $('#detail-column-region').addClass('decide-total-column');
                    }

                    // if grouping column exists  
                    else if (type_id == '2') {                 
                    $('#detail-column-region').removeClass('decide-total-column');
                    $('.aggregations-list', $('#detail-column-region')).attr('disabled', true);
                    $('tr.text-item .aggregations-list option[rel="111"]', $('#detail-column-region')).attr('disabled', true);
                }

                $('tr.text-item .cross-aggregations-list option[rel="111"]', $('#detail-column-region')).attr('disabled', true);
		 
            }
	
                /* 
                 * Register add/delete colum @ Advanced tab 
                */
            $('#add-detail-column').click(function() {
                register_column(1);
                settle_aggregation();
                    
                //Set Default agg as Sum to cross table custom column on ADD
                if ($('.pvtRenderer').val() == 'CrossTab Table') {          
                    $('tr.text-item:last .aggregations-list', $('#detail-column-region')).find('option').removeAttr('disabled');          
                    $('tr.text-item:last .aggregations-list', $('#detail-column-region')).val(13);
                }
            });
	
            $('#add-group-column').click(function() {
                register_column(2);
                settle_aggregation();
            });
	
            $('#delete-detail-column').click(function() {
                delete_column($('#detail-column-region'));
                settle_aggregation();
            });
	
            $('#delete-group-column').click(function() {
                delete_column($('#group-column-region'));
                settle_aggregation();
            });
	
            /* ----DONOT REMOVE THIS COMMENTED AREA AS THIS PORTION WILL BE UTILISED LATER
            $('#add-cols-column').click(function() {
            register_column(3);
            settle_aggregation();
            });
            $('#add-rows-column').click(function() {
            register_column(4);
            settle_aggregation();
            });
            $('#delete-cols-column').click(function() {
            delete_column($('#cols-column-region'));
            settle_aggregation();
            });
            $('#delete-rows-column').click(function() {
            delete_column($('#rows-column-region'));
            settle_aggregation();
            });----*/
	
                // toggle tab for column tables
            $('.mode-trigger a').click(function() {
                var current_link = $(this);
                var current_value = current_link.attr('rel');
                current_link.parents('ul').eq(0).find('li').removeClass('active');
                current_link.parents('li').eq(0).addClass('active');
                var next_table = current_link.parents('ul').eq(0).next('table.column-table');
		
                switch (current_value) {
                    case '1':
                        next_table.removeClass('hdisplay-mode');
                        next_table.removeClass('cformat-mode');
                        next_table.removeClass('display-mode');
                        next_table.removeClass('aggr-mode');
                        next_table.addClass('base-mode');
                        break;
                    case '2':
                        next_table.removeClass('hdisplay-mode');
                        next_table.removeClass('cformat-mode');
                        next_table.removeClass('base-mode');
                        next_table.removeClass('aggr-mode');
                        next_table.addClass('display-mode');
                        break;
                        case '3':
                        next_table.removeClass('base-mode');
                            next_table.removeClass('cformat-mode');
                        next_table.removeClass('display-mode');
                        next_table.removeClass('aggr-mode');
                            next_table.addClass('hdisplay-mode');
                        break;
                        case '4':
                        next_table.removeClass('base-mode');
                            next_table.removeClass('hdisplay-mode');
                        next_table.removeClass('display-mode');
                        next_table.removeClass('aggr-mode');
                            next_table.addClass('cformat-mode');
                        break;
                    case '5':
                        next_table.removeClass('base-mode');
                        next_table.removeClass('cformat-mode');
                        next_table.removeClass('display-mode');
                        next_table.removeClass('hdisplay-mode');
                        next_table.addClass('aggr-mode');
                        break;
                }
		
                next_table.append(' ');
            });
	
                // event that recreates scenario for new dataset
            fx_dataset_change = function() {
                var current_dataset = $(this).val();
                $('#all-columns-rs').html('');
                $('#grouping-columns-rs').html('');
                $('#cols-columns-rs').html('');
                $('#rows-columns-rs').html('');
                $('#group-column-region tr.clone').remove();
                $('#detail-columns-rs').html('');
                $('#detail-column-region tr.clone').remove();
                $('#datasets-list').attr('rel', current_dataset);                
            }
            
            $('.zoomer').click(function() {
                var container_obj = $(this).parents('div').eq(0);
		
                if (container_obj.css('position') != 'absolute') {
                    container_obj.css('position', 'absolute');
                    container_obj.css('z-index', 1000);
                    container_obj.css('top', 0);
                    container_obj.css('left', 0);
                    container_obj.css('width', $(window).width() - 10);
                    container_obj.css('height', $(window).height() - 10);
                    container_obj.css('background', '#bcd0f4');
                    container_obj.css('padding', 5);
			
                    if (container_obj.hasClass('drag-area')) {
                        $('ul.connected_sorts').css('height', $(window).height() - 100);
                    }
                } else {
                    container_obj.css('position', '');
                    container_obj.css('width', 'auto');
                    container_obj.css('height', 'auto');
                    container_obj.css('background', '');
                    container_obj.css('padding', 0);
			
                    if (container_obj.hasClass('drag-area')) {
                        $('ul.connected_sorts').css('height', '330');
                    }
                }
            });
	
                // script excution for startup @ edit mode 
            if (mode == 'u') {
                    
                $('.column-table').each(function() {
                        
                    $('tr.clone', $(this)).each(function() {
                        register_widgets($(this), $('.item-id', $(this)).val(), true);
                    });
                });
            }
	
            //and add mode
            settle_aggregation();
            $('html').css({'overflow': 'auto'});
            
                /*
                 * function to update sub aggr when changed on pivot UI 
                 */
            fx_update_sub_aggr = function(column_id, agg_detail) {
                    
                if (agg_detail[1].indexOf('.') > -1) {                    
                    var context = $('.column-id', '#detail-column-region').filter('[value="' + column_id + '"]').closest('tr');
                    $('.aggregations-list', context).find('option').removeAttr('disabled');
                    $('.aggregations-list', context).val(fx_column_aggregation_mapping(agg_detail[0]));
                } else {
                        
                        $.each($('.custom-column', '#detail-column-region'), function(k, tr){
                            
                            if ($(tr).find('.column').text() == column_id) {
                                var context = $(tr);
                                $('.aggregations-list', context).find('option').removeAttr('disabled');
                                $('.aggregations-list', context).val(fx_column_aggregation_mapping(agg_detail[0]));
                            }
                        });
                }
            };
        });
        
        
            /* SAVE LOGIC */
        var process_id = '<?php echo $process_id ?>';
        var xml_rs_columns, xml_rs_headers, stack;
        var error_aggregation, error_aggregation_reqd, error, column_order;
        
            // prepare data for save logic 
        var set_save_params = function (placement, current_context, item_id, index) {
            index = placement +''+ index;
            stack = {};
            stack.placement = placement;
            stack.column_id = $('.column-id', current_context).val();
            stack.dataset_id = $('.item-id', current_context).val();
            stack.dataset_id = stack.dataset_id.split('-');
            stack.dataset_id = stack.dataset_id[0];
            stack.report_tablix_column_id = $('.report-tablix-column-id', current_context).val();
            stack.column_alias = $('.column-alias', current_context).val();
            stack.column_order = current_context.attr('column_order');

            if (stack.column_alias == 'NULL' || stack.column_alias == '') {
                error = 1;
                return;
            }

            stack.function_name = $('.function', current_context).val();

            if (stack.placement == '1') {
                stack.tablix_type_id = renderer_type_id;
                
                //used render type and summary id to grab mark-for-total radio value
                if (renderer_type_id == 1 && tablix_summary_id == 2) {
                    stack.mark_for_total = $('.mark-for-total', current_context).is(':checked') ? 1 : 0;
                } else {
                    stack.mark_for_total = '';
                }
                    
                //SSRS based aggregation on Sub section
                    
                    // if no group selected in default type
                    if (stack.tablix_type_id == '1' && $('#group-column-region tr').length == 1) {
                    stack.aggregation = '';
                    }

                    //rest of the world
                    else {
                    stack.aggregation = $('.aggregations-list', current_context).val();
                        
                    if ($('.aggregations-list option[value="' + stack.aggregation + '"]', current_context).prop('disabled') == true) {
                        error_aggregation = 1;
                        return;
                    }
                }

                //needed for SQL based aggregation processing
                stack.sql_aggregation = $('.sql-aggregations-list', current_context).val();
                if ($('.sql-aggregations-list option[value="' + stack.sql_aggregation + '"]', current_context).prop('disabled') == true) {
                    error_aggregation = 1;
                    return;
                }

                    /* 
                     * needed for the summary column aggregation on tablixes, 
                     * started off with crosstab thus the var name;
                     * dont get confused
                     */
                stack.cross_summary_aggregation = $('.cross-aggregations-list', current_context).val();
                    
                if ($('.cross-aggregations-list option[value="' + stack.cross_summary_aggregation + '"]', current_context).prop('disabled') == true) {
                    error_aggregation = 1;
                    return;
                }

                //column aggregation necessity in case of crosstabs
                if (stack.tablix_type_id == '2' && stack.aggregation == '') {
                    error_aggregation_reqd = 1;
                    return;
                }
            } else {
                stack.aggregation = '';
                stack.sql_aggregation = '';
                stack.cross_summary_aggregation = '';
                stack.mark_for_total = '';
            }       

                if(stack.placement == '4') {
                stack.subtotal = $('.add-sub-total', current_context).is(':checked') ? 1 : 0;
                } else {
                stack.subtotal = '';
                }

            stack.sort_priority = $('.sort-priority', current_context).val();
            stack.sorting_column = $('.sort-column', current_context).val();
            stack.sort_to = $('.sort-to-list', current_context).val();
            stack.sort_link_header = $('.sort-link-header', current_context).is(':checked') ? 1 : 0;

            stack.font = $('.font-list', current_context).val();
            stack.font_size = $('.font-size-list', current_context).val();
            stack.bold_check = $('.bold-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.italic_check = $('.italic-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.underline_check = $('.underline-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.text_align = $('.text-align-list', current_context).val();
            stack.text_color = $('.text-color-list', current_context).val();
            stack.background = $('.background-list', current_context).val();

            stack.h_font = $('.header-font-list', current_context).val();
            stack.h_font_size = $('.header-font-size-list', current_context).val();
            stack.h_bold_check = $('.header-bold-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.h_italic_check = $('.header-italic-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.h_underline_check = $('.header-underline-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.h_text_align = $('.header-text-align-list', current_context).val();
            stack.h_text_color = $('.header-text-color-list', current_context).val();
            stack.h_background = $('.header-background-list', current_context).val();

            stack.custom_field = (current_context.hasClass('custom-column')) ? '1' : '0';
            stack.render_as = $('.renderas-list', current_context).val();
            stack.column_template = $('.current-template-option', current_context).val();

            switch (stack.render_as) {
                case '0':
                case '1': //Text, HTML
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = '';
                    stack.negative_mark = '';
                    stack.date_format = '';
                    break;
                case '2': //Number
                    stack.currency = '';
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.negative_mark = $('.negative-mark-list', current_context).val();
                    stack.date_format = '';
                    break;
                case '3': //Currency
				case '13': //Price
                    stack.currency = $('.currency-list', current_context).val();
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.negative_mark = $('.negative-mark-list', current_context).val();
                    stack.date_format = '';
                    break;
                case '4': //Date
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = '';
                    stack.negative_mark = '';
                    stack.date_format = $('.date-format-list', current_context).val();
                    break;
                case '5':
                case '6': //Percentage, Scientific
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.negative_mark = '';
                    stack.date_format = '';
                    break;
				case '14':
                    stack.currency = '';
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.negative_mark = $('.negative-mark-list', current_context).val();
                    stack.date_format = '';
                    break;
            }

                if (stack.custom_field == '1') stack.dataset_id = '';

            xml_rs_columns += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                            + '" DataSetID="' + stack.dataset_id
                            + '" TabLixID="' + item_id
                            + '" ColumnID="' + stack.column_id
                            + '" ColumnAlias="' + escapeXML(stack.column_alias)
                            + '" FunctionName="' + escapeXML(stack.function_name)
                            + '" Aggregation="' + stack.aggregation
                            + '" SQLAggregation="' + stack.sql_aggregation
                            + '" Subtotal="' + stack.subtotal
                            + '" CrossSummaryAggregation="' + stack.cross_summary_aggregation
                            + '" SortLinkHeader="' + stack.sort_link_header
                            + '" Rounding="' + stack.rounding
                            + '" ThousandSeperator="' + stack.thousand_list
                            + '" SortPriority="' + stack.sort_priority
                            + '" SortingColumn="' + stack.sorting_column
                            + '" SortTo="' + stack.sort_to
                            + '" Font="' + stack.font
                            + '" FontSize="' + stack.font_size
                            + '" TextAlign="' + stack.text_align
                            + '" TextColor="' + stack.text_color
                            + '" Background="' + stack.background
                            + '" FontStyle="' + stack.bold_check + ',' + stack.italic_check + ',' + stack.underline_check
                            + '" CustomField="' + stack.custom_field
                            + '" ColumnOrder="' + (stack.column_order)
                            + '" RenderAs="' + (stack.render_as)
                            + '" ColumnTemplate="' + (stack.column_template)
                            + '" NegativeMark="' + (stack.negative_mark)
                            + '" Currency="' + (stack.currency)
                            + '" FormatDate="' + (stack.date_format)
                            + '" Placement="' + stack.placement
                            + '" MarkForTotal="' + stack.mark_for_total
                            + '" MarkIndex="' + index
                            + '"></PSRecordset>';

            xml_rs_headers += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                            + '" TabLixID="' + item_id
                            + '" ColumnID="' + stack.column_id
                            + '" Font="' + stack.h_font
                            + '" FontSize="' + stack.h_font_size
                            + '" TextAlign="' + stack.h_text_align
                            + '" TextColor="' + stack.h_text_color
                            + '" Background="' + stack.h_background
                            + '" FontStyle="' + stack.h_bold_check + ',' + stack.h_italic_check
                            + ',' + stack.h_underline_check
                            + '" MarkIndex="' + index
                            + '"></PSRecordset>';
        }

            // save form 
        save_tablix = function() {
            var item_id = '<?php echo $report_tablix_id; ?>';
            var type_id = renderer_type_id;
            var cross_summary = tablix_summary_id;

                if (item_id == '') item_id = 'NULL';

            //bootup global vars
            error_aggregation = 0;
            error_aggregation_reqd = 0;
            error = 0;
            column_order = 1;
            xml_rs_columns = '<Root>';
            xml_rs_headers = '<Root>';

            var detail_column_length = $('#detail-columns-rs li').length;

                // if SQL based aggregation
                if (type_id == '1' && $('#group-column-region tr').length == 1) {
                    var aggr_faulty = true;

                $('.sql-aggregations-list',$('#detail-column-region')).each(function() {
                    if (!$(this).val() > 0) {
                        aggr_faulty = false;
                    }
                });

                if (aggr_faulty) {
                    show_messagebox('FAULTY_AGGR_GROUPLESS_TAB');
                    return;
                }
            }

            var root_dataset_id = $('#datasets-list').val();

            if (root_dataset_id == 'NULL' || root_dataset_id == '') {
                show_messagebox('EMPTY_DATASET');
                return;
            }

            $('#detail-column-region tr.clone').each(function(index, item) {
                set_save_params(1, $(this), item_id, index);
            });

            if (type_id == '1') {
                column_order = 1;            
                    
                $('#group-column-region tr.clone').each(function(index, item) {
                    set_save_params(2, $(this), item_id, index);
                });            
            } else {
                column_order = 1;            
                    
                $('#cols-column-region tr.clone').each(function(index, item) {
                    set_save_params(3, $(this), item_id, index);
                });            

                $('#rows-column-region tr.clone').each(function(index, item) {
                    set_save_params(4, $(this), item_id, index);
                });
            }

            if (error_aggregation == 1) {
                show_messagebox('INVALID_AGGREGATION');
                return;
            }

            if (error_aggregation_reqd == 1) {
                show_messagebox('CROSSTAB_AGGREGATION_REQD');
                return;
            }

            xml_rs_columns += '</Root>';
            xml_rs_headers += '</Root>';
            
			var validation_msg = '';
    			
			if (error == 1) {
				 validation_msg = 'Display Name cannot be empty.';
			}
			
            var return_obj = {
				valiation_status: validation_msg,
                xml_rs_headers: xml_rs_headers,
                xml_rs_columns: xml_rs_columns
            };

            return return_obj;
        }
        
        //get view columns in single dimensional array
        fx_get_view_columns = function() {
            var return_arr = [];
                
            return_arr = $('.column-real-name').map(function() {
                return $(this).text();
            }).get();

            return return_arr;
			  }

        //initialize ace editor with appropriate options
        fx_init_ace_editor = function(text_value) {
            editor_gbl = ace.edit("overlay-area");
            editor_gbl.session.setMode("ace/mode/sqlserver");
            editor_gbl.setTheme("ace/theme/sqlserver");
            editor_gbl.setValue(text_value, 1);

            // enable autocompletion and snippets
            editor_gbl.setOptions({
                enableBasicAutocompletion: true,
                enableSnippets: true,
                enableLiveAutocompletion: false,
                wrap: true,
                indentedSoftWrap: false
            });

            editor_gbl.focus();
            editor_gbl.renderer.setShowGutter(false);

            fx_add_ace_completers();
            }
            
        //add custom set of ace editor completers for autocomplete list
        fx_add_ace_completers = function() {
                
            //add extra completers for ace editor
            var datasetColsCompleter = {
                getCompletions: function(editor, session, pos, prefix, callback) {
                    var wordList = fx_get_view_columns();
                        
                    callback(null, wordList.map(function(word) {
                        return {
                            caption: word,
                            value: word,
                            meta: "Dataset Columns"
                        };
                    }));
                }
            }

            var scalarSQLFunctionsCompleter = {
                getCompletions: function(editor, session, pos, prefix, callback) {
                    var wordList = scalar_functions_list;
                        
                    callback(null, wordList.map(function(word) {
                        return {
                            caption: word,
                            value: word,
                            meta: "Scalar SQL Functions"
                        };
                    }));
                }
            }
            editor_gbl.completers.push(datasetColsCompleter);
            editor_gbl.completers.push(scalarSQLFunctionsCompleter);
        }
            /* END SAVE LOGIC */
    </script>
        
    <?php
    $group_tabs = array(
                array(
                    'type_class' => 'default-type-item', 
                    'label' => show_label('Group Columns(s)', false), 
                    'id' => 'group-column-region', 
                    'data_var' => 'grouping_columns', 
                    'name' => 'group', 
                    'display' => ($current_type_id == 1) ? '' : 'none'
                ),
                array(
                    'type_class' => 'crosstab-type-item', 
                    'label' => show_label('Column by', false), 
                    'id' => 'cols-column-region', 
                    'data_var' => 'cols_columns', 
                    'name' => 'cols', 
                    'display' => ($current_type_id == 1) ? 'none' : ''
                ),
                array(
                    'type_class' => 'crosstab-type-item row-by-item', 
                    'label' => show_label('Row by', false), 
                    'id' => 'rows-column-region', 
                    'data_var' => 'rows_columns', 
                    'name' => 'rows', 
                    'display' => ($current_type_id == 1) ? 'none' : ''
                )
    );

    foreach ($group_tabs as $tabnow):
    ?>
    <div class="<?php echo $tabnow['type_class']; ?> advanced-tables class-trm-tablix-advance-tab-table" style="display:<?php echo $tabnow['display']; ?>">
        <label class="FormLabelHeader shift-down"><?php echo $tabnow['label']; ?>:</label>
        <ul class="mode-trigger jtabs">
            <li class="active"><a class="theme-blue" href="javascript:void(0)" rel="1"><span><?php echo show_label('Basic', false); ?></span></a></li>
            <li><a class="theme-blue" href="javascript:void(0)" rel="4"><span><?php echo show_label('Column Format', false); ?></span></a></li>
            <li><a class="theme-blue" href="javascript:void(0)" rel="2"><span><?php echo show_label('Column Style', false); ?></span></a></li>
            <li><a class="theme-blue" href="javascript:void(0)" rel="3"><span><?php echo show_label('Header Style', false); ?></span></a></li>
        </ul>
        <table id="<?php echo $tabnow['id']; ?>" class="data-table base-mode column-table group-items" width="100%">
            <tr>
                <th width="180" nowrap class="main">
                    <img class="zoomer" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/grid_img/corner.gif" alt="<?php echo show_label('Zoom this area', false); ?>" title="<?php echo show_label('Zoom this area', false); ?>"/>
                    &nbsp;&nbsp;<?php echo show_label('Column'); ?>
                </th>
                <th width="180" nowrap class="main" colspan="2"><?php echo show_label('Alias', false); ?></th>
                <th width="150" class="base" nowrap><?php echo show_label('Function', false); ?></th>
                <th width="150" class="base" nowrap><?php echo show_label('Display Name', false) .'&nbsp<span style="color:red; font-weight:bold">*</span>'; ?></th>
                <th width="80" class="base" nowrap><?php echo show_label('Sort Priority', false); ?></th>
                <th width="80" class="base" nowrap><?php echo show_label('Sorting Column', false); ?></th>
                <th width="%" class="base" nowrap><?php echo show_label('Sort To', false); ?></th>
                <th width="%" class="base" nowrap><?php echo show_label('Sortable', false); ?></th>
                <th width="%" class="base sub-total" nowrap><?php echo show_label('Subtotal', false); ?></th>

                <th width="50" class="cdisplay" nowrap><?php echo show_label('Render as', false); ?></th>
                <th width="150" class="cdisplay" nowrap><?php echo show_label('Template', false); ?></th>
                <th width="%" class="cdisplay" nowrap><?php echo show_label('Date Format', false) . ''; ?></th>
                <th width="%" class="cdisplay" nowrap><?php echo show_label('Currency', false) . ''; ?></th>
                <th width="%" class="cdisplay" nowrap><?php echo show_label('Thousand', false) . ''; ?></th>
                <th width="%" class="cdisplay" nowrap><?php echo show_label('Rounding', false) . ''; ?></th>
                <th width="%" class="cdisplay" nowrap><?php echo show_label('Negative as Red', false) . ''; ?></th>

                <th width="%" class="display" nowrap><?php echo show_label('Font', false); ?></th>
                <th width="%" class="display" nowrap><?php echo show_label('Font Size', false); ?></th>
                <th width="%" class="display" colspan="3" nowrap><?php echo show_label('Font Style', false); ?></th>
                <th width="%" class="display" nowrap><?php echo show_label('Text Align', false); ?></th>
                <th width="%" class="display" nowrap><?php echo show_label('Text Color', false); ?></th>
                <th width="%" class="display" nowrap><?php echo show_label('Background', false); ?></th>

                <th width="%" class="hdisplay" nowrap><?php echo show_label('Font', false); ?></th>
                <th width="%" class="hdisplay" nowrap><?php echo show_label('Font Size', false); ?></th>
                <th width="%" class="hdisplay" colspan="3" nowrap><?php echo show_label('Font Style', false); ?></th>
                <th width="%" class="hdisplay" nowrap><?php echo show_label('Text Align', false); ?></th>
                <th width="%" class="hdisplay" nowrap><?php echo show_label('Text Color', false); ?></th>
                <th width="%" class="hdisplay" nowrap><?php echo show_label('Background', false); ?></th>
            </tr>
            <?php
            if (sizeof(${$tabnow['data_var']}) > 0) {
                                    
                foreach (${$tabnow['data_var']} as $column) {
                    $column_classes = '';
                    $disabled_checkbox = 'disabled';
                    $column_order_cc = '';

                    if ($column['datatype'] == '2') { #if text
                        $column_classes .= ' text-item';
                    } else {#if numeric/custom
                    }

                    if ($column['column_id'] == '' || $column['column_id'] == NULL) { #if custom column
                        $column_classes .= ' custom-column';
                        $column_real_name = '&lt;Custom Column&gt;';
                        $item_label = $column['alias'];
                        $function_display = '';
                        $item_id = 'old-item-' . $column['report_tablix_column_id'];

                        $disabled_checkbox = '';
                        $column_order_cc = ' column_order="' . $column['column_order'] . '"';
                    } else {#if regular column
                        $item_label = $column['column_name'];
                        $function_display = 'none';
                        $item_id = $column['group_entity'] . '-' . $column['data_source_column_id'];
                        $column_real_name = $column['column_real_name'];
                    }

                    ?>
                    <tr class="clone<?php echo $column_classes; ?>" <?php echo $column_order_cc; ?>>
                        <td width="180" nowrap> 
                            <label>
                                <input type="checkbox" value="1" class="remove-column context-form-item" <?php echo $disabled_checkbox; ?> /><span class="column-real-name"><?php echo $column_real_name; ?></span>
                            </label>  
                        </td>
                        <td width="180" nowrap> 
                            <span class="column"><?php echo $item_label; ?></span>
                        </td>
                        <td width="25">
                            <input type="hidden" class="item-id" value="<?php echo $item_id ?>" />
                            <input type="hidden" class="column-id" value= "<?php echo $column['column_id']; ?>" />
                            <input type="hidden" class="report-tablix-column-id" value= "<?php echo $column['report_tablix_column_id']; ?>" />
                            <span class="item-logo"></span>
                        </td>
                        <td class="base">
                            <input type="textbox" value="<?php echo $column['functions']; ?>" style="display:" class="adiha_control function enlarge-this large-form-element" />
                        </td>
                        <td class="base"> <input type="text" value="<?php echo $column['alias']; ?>" class="adiha_control column-alias large-form-element" /></td>                        
                        <td class="base"> <input type="text" value="<?php echo $column['default_sort_order']; ?>" class="adiha_control sort-priority small-form-element" /> </td>
                        <td class="base">
                            <select class="adiha_control sort-column context-form-item">
                                <option value=""></option>    
                                <?php foreach ($ds_col_info_list as $ds_col_info): ?>
                                    <option value="<?php echo $ds_col_info['data_source_column_id']; ?>" <?php echo ($ds_col_info['data_source_column_id'] == $column['sorting_column']) ? 'selected' : ''; ?>><?php echo $ds_col_info['alias']; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="base">
                            <select class="adiha_control sort-to-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_sort_option as $sort_to): ?>
                                    <option value="<?php echo $sort_to[0]; ?>" <?php echo ($sort_to[0] == $column['default_sort_direction']) ? 'selected' : ''; ?>><?php echo $sort_to[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="base"> <input type="checkbox" value="1" class="sort-link-header context-form-item" <?php echo ($column['sortable'] == 1) ? ' checked="checked"' : ''; ?>/></td>
                        <td class="base sub-total"> <input type="checkbox" value="1" class="add-sub-total context-form-item" <?php echo ($column['subtotal'] == 1) ? ' checked="checked"' : ''; ?>/></td>
                        <td class="aggr detail-item">
                            <select class="adiha_control sql-aggregations-list context-form-item">
                                <option value="">NONE</option>
                                <?php
                                foreach ($rdl_column_aggregation_option as $aggregation):
                                    if ($aggregation[5] == '1'):
                                        ?>
                                        <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>
                                        <?php
                                    endif;
                                endforeach;
                                ?>
                            </select>
                        </td>
                        <td class="aggr detail-item">
                            <select class="adiha_control aggregations-list context-form-item">
                                <option value=""></option>
                                <?php
                                foreach ($rdl_column_aggregation_option as $aggregation):
                                    if ($aggregation[4] == '1'):
                                        ?>
                                    <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>
                                        <?php
                                    endif;
                                endforeach;
                                ?>
                            </select>
                        </td>
                        <td class="aggr detail-item">
                            <select class="adiha_control cross-aggregations-list context-form-item">
                                <option value="-1">NONE</option>
                                <?php
                                foreach ($rdl_column_aggregation_option as $aggregation):
                                    if ($aggregation[4] == '1'):
                                        ?>
                                        <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" ><?php echo $aggregation[2]; ?></option>
                                        <?php
                                    endif;
                                endforeach;
                                ?>
                            </select>
                        </td>
                        <td class="aggr">
                            <label class="mark-as-total"><input value="1" type="radio" class="adiha_control mark-for-total" name="mark_for_total" /></label>
                        </td>
                        <td class="cdisplay">
                            <select class="adiha_control renderas-list">
                                <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                                    <option value="<?php echo $render_as[0]; ?>" <?php echo ($render_as[0] == $column['render_as']) ? 'selected' : ''; ?>><?php echo $render_as[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="cdisplay">
                            <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                                <select class="adiha_control column-template column-template-<?php echo $key ?>" rel="<?php echo $key ?>">
                                    <option class="custom" value="-1">Custom</option>
                                    <?php if ($key != '1' && $key != '6'): ?>
                                        <option class="custom" value="0" <?php echo ($column['column_template'] == '0') ? 'selected' : ''; ?>>Global</option>
                                    <?php endif; ?>
                                    <?php foreach ($template_base as $template): ?>
                                        <option rel="<?php echo $template['type']; ?>" value="<?php echo $template['id']; ?>" <?php echo ($template['id'] == $column['column_template']) ? 'selected' : ''; ?>><?php echo $template['label']; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php endforeach; ?>
                            <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.png" align="middle" />
                        </td>
                        <td class="cdisplay">
                            <div class="render-option render-option-date">
                                <select class="adiha_control date-format-list ">
                                    <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                                        <option value="<?php echo $date_format[0]; ?>" <?php echo ($date_format[0] == $column['date_format']) ? 'selected' : ''; ?>><?php echo $date_format[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="cdisplay">
                            <div class="render-option render-option-currency">
                                <select class="adiha_control currency-list ">
                                    <?php foreach ($rdl_column_currency_option as $currency): ?>
                                        <option value="<?php echo $currency[0]; ?>" <?php echo ($currency[0] == $column['currency']) ? 'selected' : ''; ?>><?php echo $currency[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>    
                        <td class="cdisplay">
                            <div class="render-option render-option-thousand">
                                <select class="thousand-list adiha_control" >
                                    <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                        <option value="<?php echo $option[0]; ?>" <?php echo ($option[0] == $column['thousand_seperation']) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="cdisplay">
                            <div class="render-option render-option-round">
                                <select class="adiha_control rounding-list ">
                                    <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                                        <option value="<?php echo $rounding[0]; ?>" <?php echo ($rounding[0] == $column['rounding']) ? 'selected' : ''; ?>><?php echo $rounding[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="cdisplay">
                            <div class="render-option render-option-negative">
                                <select class="negative-mark-list adiha_control" >
                                    <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                        <option value="<?php echo $option[0]; ?>" <?php echo ($option[0] == $column['negative_mark']) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>

                        <td class="display">
                            <select class="adiha_control font-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_font_option as $font): ?>
                                    <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $column['font']) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-size-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                                    <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $column['font_size']) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display" nowrap> 
                            <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo ($column['bold_style'] == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo ($column['italic_style'] == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo ($column['underline_style'] == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                        </td>
                        <td class="display">
                            <select class="adiha_control text-align-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                                    <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $column['text_align']) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <input type="text" style="background: <?php echo $column['text_color']; ?>; color: <?php echo $column['text_color']; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-<?php echo $item_id ?>" value="<?php echo $column['text_color']; ?>" readonly="readonly"/>
                        </td>
                        <td class="display">
                            <input type="text" style="background: <?php echo $column['background']; ?>; color: <?php echo $column['background']; ?>" class="adiha_control background-list small-form-element context-form-item" id="background-list-<?php echo $item_id ?>" value="<?php echo $column['background']; ?>" readonly="readonly"/>
                        </td>


                        <td class="hdisplay">
                            <select class="adiha_control header-font-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_font_option as $font): ?>
                                    <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $column['h_font']) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="hdisplay">
                            <select class="adiha_control header-font-size-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                                    <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $column['h_font_size']) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="hdisplay" nowrap> 
                            <label style="display: inline-block;"><input type="checkbox" value="" class="header-bold-checkbox context-form-item" <?php echo ($column['h_bold_style'] == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                        </td>
                        <td class="hdisplay" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="header-italic-checkbox context-form-item" <?php echo ($column['h_italic_style'] == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                        </td>
                        <td class="hdisplay" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="header-underline-checkbox context-form-item" <?php echo ($column['h_underline_style'] == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                        </td>
                        <td class="hdisplay">
                            <select class="adiha_control header-text-align-list context-form-item">
                                <option value=""></option>
                                <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                                    <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $column['h_text_align']) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="hdisplay">
                            <input type="text" style="background: <?php echo $column['h_text_color']; ?>; color: <?php echo $column['h_text_color']; ?>" class="adiha_control header-text-color-list small-form-element context-form-item" id="header-text-color-list-<?php echo $item_id ?>" value="<?php echo $column['h_text_color']; ?>" readonly="readonly"/>
                        </td>
                        <td class="hdisplay">
                            <input type="text" style="background: <?php echo $column['h_background']; ?>; color: <?php echo $column['h_background']; ?>" class="adiha_control header-background-list small-form-element context-form-item" id="header-background-list-<?php echo $item_id ?>" value="<?php echo $column['h_background']; ?>" readonly="readonly"/>
                        </td>
                    </tr>
                    <?php
                }
            }
            ?>
        </table>

        <?php if ($tabnow['name'] == 'group'): ?>
            <div class="clone-buttons class-trm-tablix-advance-button">
                <span class=""><?php echo show_label('Custom Field'); ?></span>
                <img class="add-button" id="add-group-column" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/toolbar/add.jpg" alt="<?php echo show_label('Add column', false); ?>" title="<?php echo show_label('Add column', false); ?>"/>
                <img class="remove-button "id="delete-group-column" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/toolbar/delete.jpg" alt="<?php echo show_label('Delete selected Column', false); ?>" title="<?php echo show_label('Delete selected Column', false); ?>"/>
            </div>
        <?php endif; ?>
                        
        <hr/>
    </div>
                <?php 
            endforeach; 
        ?>

    <div class="drag-area-detail class-trm-tablix-advance-table">
    <label class="FormLabelHeader shift-down"><?php echo show_label('Detail Column'); ?></label>
    <ul class="mode-trigger jtabs">
        <li class="active"><a class="theme-blue" href="javascript:void(0)" rel="1"><span><?php echo show_label('Basic', false); ?></span></a></li>
        <li><a class="theme-blue" href="javascript:void(0)" rel="5"><span><?php echo show_label('Aggregation', false); ?></span></a></li>
        <li class=""><a class="theme-blue" href="javascript:void(0)" rel="4"><span><?php echo show_label('Column Format', false); ?></span></a></li>
        <li class=""><a class="theme-blue" href="javascript:void(0)" rel="2"><span><?php echo show_label('Column Style', false); ?></span></a></li>
        <li class=""><a class="theme-blue" href="javascript:void(0)" rel="3"><span><?php echo show_label('Header Style', false); ?></span></a></li>
    </ul>
    <table id="detail-column-region" class="data-table base-mode column-table" width="100%">
        <tr>
            <th width="180" class="main">
                <img class="zoomer" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/grid_img/corner.gif" alt="<?php echo show_label('Zoom this area', false); ?>" title="<?php echo show_label('Zoom this area', false); ?>"/>
                Column
            </th>
            <th width="180" nowrap class="main" colspan="2"><?php echo show_label('Alias', false); ?></th>
            <th width="150" class="base" nowrap><?php echo show_label('Function', false); ?></th>
           <th width="150" class="base" nowrap><?php echo show_label('Display Name', false) .'&nbsp<span style="color:red; font-weight:bold">*</span>'; ?></th>
            <th width="80" class="base" nowrap><?php echo show_label('Sort Priority', false); ?></th>
            <th width="80" class="base" nowrap><?php echo show_label('Sorting Column', false); ?></th>
            <th width="%" class="base" nowrap><?php echo show_label('Sort To', false); ?></th>
            <th width="%" class="base" nowrap><?php echo show_label('Sortable', false); ?></th>
            <th width="%" class="base sub-total" nowrap><?php echo show_label('Sub-total', false); ?></th>

            <th width="%" class="aggr" nowrap><?php echo show_label('Column Aggregation', false); ?></th>
            <th width="%" class="aggr" nowrap><?php echo show_label('Subsection Aggregation', false); ?></th>
            <th width="%" class="aggr" nowrap><?php echo show_label('Total Aggregation', false) . ''; ?></th>
            <th width="%" class="aggr" nowrap><?php echo show_label('Mark for Total caption', false) . ''; ?></th>

            <th width="50" class="cdisplay" nowrap><?php echo show_label('Render as', false); ?></th>
            <th width="150" class="cdisplay" nowrap><?php echo show_label('Template', false); ?></th>
            <th width="%" class="cdisplay" nowrap><?php echo show_label('Date Format', false) . ''; ?></th>
            <th width="%" class="cdisplay" nowrap><?php echo show_label('Currency', false) . ''; ?></th>
            <th width="%" class="cdisplay" nowrap><?php echo show_label('Thousand', false) . ''; ?></th>
            <th width="%" class="cdisplay" nowrap><?php echo show_label('Rounding', false) . ''; ?></th>
            <th width="%" class="cdisplay" nowrap><?php echo show_label('Negative as Red', false) . ''; ?></th>

            <th width="%" class="display" nowrap><?php echo show_label('Font', false); ?></th>
            <th width="%" class="display" nowrap><?php echo show_label('Font Size', false); ?></th>
            <th width="%" class="display" colspan="3" nowrap><?php echo show_label('Font Style', false); ?></th>
            <th width="%" class="display" nowrap><?php echo show_label('Text Align', false); ?></th>
            <th width="%" class="display" nowrap><?php echo show_label('Text Color', false); ?></th>
            <th width="%" class="display" nowrap><?php echo show_label('Background', false); ?></th>

            <th width="%" class="hdisplay" nowrap><?php echo show_label('Font', false); ?></th>
            <th width="%" class="hdisplay" nowrap><?php echo show_label('Font Size', false); ?></th>
            <th width="%" class="hdisplay" colspan="3" nowrap><?php echo show_label('Font Style', false) ?></th>
            <th width="%" class="hdisplay" nowrap><?php echo show_label('Text Align', false); ?></th>
            <th width="%" class="hdisplay" nowrap><?php echo show_label('Text Color', false); ?></th>
            <th width="%" class="hdisplay" nowrap><?php echo show_label('Background', false); ?></th>
        </tr>
        <?php
        if (sizeof($detail_columns) > 0) {

            foreach ($detail_columns as $column) {
                $column_classes = '';
                $disabled_checkbox = 'disabled';
                $column_order_cc = '';

                if ($column['datatype'] == '2') { #if text
                    $column_classes .= ' text-item';
                } else {#if numeric/custom
                }

                if ($column['column_id'] == '' || $column['column_id'] == NULL) { #if custom column
                    $column_classes .= ' custom-column';
                    $column_real_name = '&lt;Custom Column&gt;';
                    $item_label = $column['alias'];
                    $function_display = '';
                    $item_id = 'old-item-' . $column['report_tablix_column_id'];

                    $disabled_checkbox = '';
                    $column_order_cc = ' column_order="' . $column['column_order'] . '"';
                } else {#if regular column
                    $item_label = $column['column_name'];
                    $function_display = 'none';
                    $item_id = $column['group_entity'] . '-' . $column['data_source_column_id'];
                    $column_real_name = $column['column_real_name'];
                }

                ?>
                <tr class="clone<?php echo $column_classes; ?>" <?php echo $column_order_cc; ?>>
                    <td width="180" nowrap> 
                        <label>
                            <input type="checkbox" value="1" class="remove-column context-form-item" <?php echo $disabled_checkbox; ?> /><span class="column-real-name"><?php echo $column_real_name; ?></span>
                        </label>  
                    </td>
                    <td width="180" nowrap> 
                        <span class="column"><?php echo $item_label; ?></span>
                    </td>
                    <td width="25">
                        <input type="hidden" class="item-id" value="<?php echo $item_id ?>" />
                        <input type="hidden" class="column-id" value= "<?php echo $column['column_id']; ?>" />
                        <input type="hidden" class="report-tablix-column-id" value= "<?php echo $column['report_tablix_column_id']; ?>" />
                        <span class="item-logo"></span>
                    </td>
                    <td class="base"> 
                        <input type="textbox" value="<?php echo $column['functions']; ?>" style="display:" class="adiha_control function enlarge-this large-form-element" />
                    </td>
                    <td class="base"> <input type="text" value="<?php echo $column['alias']; ?>" class="adiha_control column-alias large-form-element" /></td>
                    <td class="base"> <input type="text" value="<?php echo $column['default_sort_order']; ?>" class="adiha_control sort-priority small-form-element" /> </td>
                    <td class="base">
                        <select class="adiha_control sort-column context-form-item">
                            <option value=""></option>    
                            <?php foreach ($ds_col_info_list as $ds_col_info): ?>
                                <option value="<?php echo $ds_col_info['data_source_column_id']; ?>" <?php echo ($ds_col_info['data_source_column_id'] == $column['sorting_column']) ? 'selected' : ''; ?>><?php echo $ds_col_info['alias']; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="base">
                        <select class="adiha_control sort-to-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_sort_option as $sort_to): ?>
                                <option value="<?php echo $sort_to[0]; ?>" <?php echo ($sort_to[0] == $column['default_sort_direction']) ? 'selected' : ''; ?>><?php echo $sort_to[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="base"> <input type="checkbox" value="1" class="sort-link-header context-form-item" <?php echo ($column['sortable'] == 1) ? ' checked="checked"' : ''; ?>/></td>
                    <td class="base sub-total"> <input type="checkbox" value="1" class="add-sub-total context-form-item" <?php echo (array_key_exists('sub_total', $column) && $column['sub_total'] == 1) ? ' checked="checked"' : ''; ?>/></td>
                    <td class="aggr detail-item">
                        <select class="adiha_control sql-aggregations-list context-form-item">
                            <option value="">NONE</option>
                            <?php
                            foreach ($rdl_column_aggregation_option as $aggregation):
                                if ($aggregation[5] == '1'):
                                    ?>
                                    <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" <?php echo ($aggregation[0] == $column['sql_aggregation']) ? 'selected' : ''; ?>><?php echo $aggregation[2]; ?></option>
                                    <?php
                                endif;
                            endforeach;
                            ?>
                        </select>
                    </td>
                    <td class="aggr detail-item">
                        <select class="adiha_control aggregations-list context-form-item">
                            <option value=""></option>
                            <?php
                            foreach ($rdl_column_aggregation_option as $aggregation):
                                if ($aggregation[4] == '1'):
                                    ?>
                                <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" <?php echo ($aggregation[0] == $column['aggregation']) ? 'selected' : ''; ?>><?php echo $aggregation[2]; ?></option>
                                    <?php
                                endif;
                            endforeach;
                            ?>
                        </select>
                    </td>
                    <td class="aggr detail-item">
                        <select class="adiha_control cross-aggregations-list context-form-item">
                            <option value="-1">NONE</option>
                            <?php
                            foreach ($rdl_column_aggregation_option as $aggregation):
                                if ($aggregation[4] == '1'):
                                    ?>
                                    <option rel="<?php echo $aggregation[3] . $aggregation[4] . $aggregation[5]; ?>" value="<?php echo $aggregation[0]; ?>" <?php echo ($aggregation[0] == $column['cross_summary_aggregation']) ? 'selected' : ''; ?>><?php echo $aggregation[2]; ?></option>
                                    <?php
                                endif;
                            endforeach;
                            ?>
                        </select>
                    </td>
                    <td class="aggr">
                        <label class="mark-as-total"><input value="1" type="radio" class="adiha_control mark-for-total" name="mark_for_total" <?php echo ($column['mark_for_total'] == '1')?'checked':'';?> /></label>
                    </td>
                    <td class="cdisplay">
                        <select class="adiha_control renderas-list">
                            <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                                <option value="<?php echo $render_as[0]; ?>" <?php echo ($render_as[0] == $column['render_as']) ? 'selected' : ''; ?>><?php echo $render_as[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td nowrap class="cdisplay" style="padding: 0 2px; width: 150px!important;  ">
                        <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                            <select class="adiha_control column-template column-template-<?php echo $key ?>" rel="<?php echo $key ?>">
                                <option class="custom" value="-1">Custom</option>
                                <?php if ($key != '1' && $key != '6'): ?>
                                    <option class="custom" value="0" <?php echo ($column['column_template'] == '0') ? 'selected' : ''; ?>>Global</option>
                                <?php endif; ?>
                                <?php foreach ($template_base as $template): ?>
                                    <option rel="<?php echo $template['type']; ?>" value="<?php echo $template['id']; ?>" <?php echo ($template['id'] == $column['column_template']) ? 'selected' : ''; ?>><?php echo $template['label']; ?></option>
                                <?php endforeach; ?>
                            </select>
                        <?php endforeach; ?>
                        <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.png" align="middle" />
                    </td>
                    <td class="cdisplay">
                        <div class="render-option render-option-date">
                            <select class="adiha_control date-format-list ">
                                <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                                    <option value="<?php echo $date_format[0]; ?>" <?php echo ($date_format[0] == $column['date_format']) ? 'selected' : ''; ?>><?php echo $date_format[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </td>
                    <td class="cdisplay">
                        <div class="render-option render-option-currency">
                            <select class="adiha_control currency-list ">
                                <?php foreach ($rdl_column_currency_option as $currency): ?>
                                    <option value="<?php echo $currency[0]; ?>" <?php echo ($currency[0] == $column['currency']) ? 'selected' : ''; ?>><?php echo $currency[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </td>
                    <td class="cdisplay">
                        <div class="render-option render-option-thousand">
                            <select class="thousand-list adiha_control" >
                                <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                    <option value="<?php echo $option[0]; ?>" <?php echo ($option[0] == $column['thousand_seperation']) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </td>
                    <td class="cdisplay">
                        <div class="render-option render-option-round">
                            <select class="adiha_control rounding-list ">
                                <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                                    <option value="<?php echo $rounding[0]; ?>" <?php echo ($rounding[0] == $column['rounding']) ? 'selected' : ''; ?>><?php echo $rounding[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </td>
                    <td class="cdisplay">
                        <div class="render-option render-option-negative">
                            <select class="negative-mark-list adiha_control" >
                                <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                    <option value="<?php echo $option[0]; ?>" <?php echo ($option[0] == $column['negative_mark']) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </td>

                    <td class="display">
                        <select class="adiha_control font-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_option as $font): ?>
                                <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $column['font']) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="display">
                        <select class="adiha_control font-size-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                                <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $column['font_size']) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="display" nowrap> 
                        <label style="display:inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo ($column['bold_style'] == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                    </td>
                    <td class="display" nowrap>
                        <label style="display:inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo ($column['italic_style'] == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                    </td>
                    <td class="display" nowrap>
                        <label style="display:inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo ($column['underline_style'] == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                    </td>
                    <td class="display">
                        <select class="adiha_control text-align-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                                <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $column['text_align']) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="display">
                        <input type="text" style="background: <?php echo $column['text_color']; ?>; color: <?php echo $column['text_color']; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-<?php echo $item_id ?>" value="<?php echo $column['text_color']; ?>" readonly="readonly"/>
                    </td>
                    <td class="display">
                        <input type="text" style="background: <?php echo $column['background']; ?>; color: <?php echo $column['background']; ?>" class="adiha_control background-list small-form-element context-form-item" id="background-list-<?php echo $item_id; ?>" value="<?php echo $column['background']; ?>" readonly="readonly"/>
                    </td>

                    <td class="hdisplay">
                        <select class="adiha_control header-font-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_option as $font): ?>
                                <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $column['h_font']) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="hdisplay">
                        <select class="adiha_control header-font-size-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                                <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $column['h_font_size']) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="hdisplay" nowrap> 
                        <label style="display: inline-block;"><input type="checkbox" value="" class="header-bold-checkbox context-form-item" <?php echo ($column['h_bold_style'] == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                    </td>
                    <td class="hdisplay" nowrap>
                        <label style="display: inline-block;"><input type="checkbox" value="" class="header-italic-checkbox context-form-item" <?php echo ($column['h_italic_style'] == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                    </td>
                    <td class="hdisplay" nowrap>
                        <label style="display: inline-block;"><input type="checkbox" value="" class="header-underline-checkbox context-form-item" <?php echo ($column['h_underline_style'] == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                    </td>
                    <td class="hdisplay">
                        <select class="adiha_control header-text-align-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_text_align_option as $text_align): ?>
                                <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $column['h_text_align']) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                    <td class="hdisplay">
                        <input type="text" style="background: <?php echo $column['h_text_color']; ?>; color: <?php echo $column['h_text_color']; ?>" class="adiha_control header-text-color-list small-form-element context-form-item" id="header-text-color-list-<?php echo $item_id ?>" value="<?php echo $column['h_text_color']; ?>" readonly="readonly"/>
                    </td>
                    <td class="hdisplay">
                        <input type="text" style="background: <?php echo $column['h_background']; ?>; color: <?php echo $column['h_background']; ?>" class="adiha_control header-background-list small-form-element context-form-item" id="header-background-list-<?php echo $item_id; ?>" value="<?php echo $column['h_background']; ?>" readonly="readonly"/>
                    </td>
                </tr>
                <?php
            }
        }
        ?>
    </table>
    <div class="clone-buttons class-trm-tablix-advance-button">  
        <span class=""><?php echo show_label('Custom Field'); ?></span>
        <img class="add-button" id="add-detail-column" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/toolbar/add.jpg" alt="<?php echo show_label('Add Detail Column', false); ?>" title="<?php echo show_label('Add Detail Column', false); ?>"/>
        <img class="remove-button "id="delete-detail-column" src="<?php echo $app_php_script_loc ?>adiha_pm_html/process_controls/toolbar/delete.jpg" alt="<?php echo show_label('Delete selected Column', false); ?>" title="<?php echo show_label('Delete selected Column', false); ?>"/>
    </div>
    <hr/>
    </div>
    
    <div class="class-trm-tablix-advance-contextmenu">
    <div id="overlay-info-template">
    </div>    
            
    <div id="overlay-area" class="code-editor">
        <!--<textarea class="function_text_area" title="Press Enter or click Outer Region to end typing."></textarea>-->
    </div>  
    <ul id="myMenu" class="contextMenu" style="display:none;">
        <li class="blank"><a href="#apply-to-all"><?php echo show_label('Apply to All', false); ?></a></li>
        <li class="blank"><a href="#apply-to-even"><?php echo show_label('Apply to Even Rows', false); ?></a></li>
        <li class="blank"><a href="#apply-to-odd"><?php echo show_label('Apply to Odd Rows', false); ?></a></li>
    </ul>
    </div>
    </body>

</html>