<?php
/**
* Report manager chart advance screen
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
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/contextmenu/jquery.contextMenu.js"></script>
    <link rel="stylesheet" media="screen" type="text/css" href="<?php echo $app_php_script_loc; ?>components/ui/contextmenu/jquery.contextMenu.css" />

    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery.nestedSortable.js"></script>
    <link rel="stylesheet" type="text/css" href="<?php echo $appBaseURL; ?>css/adiha_style.css" />      
</head>
<body>
    <?php
    function show_label($label_name, $flag=false) {
        return $label_name;
    }

    $form_name = 'report_chart';

    $page_id = get_sanitized_value($_POST['page_id'] ?? '');
    $report_id = get_sanitized_value($_POST['report_id'] ?? '');
    $process_id = get_sanitized_value($_POST['process_id'] ?? '');
    $top = get_sanitized_value($_POST['top'] ?? '');
    $left = get_sanitized_value($_POST['left'] ?? '');
    $mode = get_sanitized_value($_POST['mode'] ?? '');
    $item_id = get_sanitized_value($_POST['item_id'] ?? '');
    $chart_name = '';
    $type = '1'; //default select pie chart
    $width = get_sanitized_value($_POST['width'] ?? '');
    $height = get_sanitized_value($_POST['height'] ?? '');
    $renderer_type = get_sanitized_value($_POST['renderer_type'] ?? '');
    $dataset_alias = get_sanitized_value($_POST['dataset_alias'] ?? '');

    $chart_name = '';
    $type = '1'; //default select pie chart    
    $y_axis_caption = '';
    $x_axis_caption = '';
    $dataset_id = '';
    $current_page_break = '';
    $current_type_id = '';
    
    $existing_columns = array();
	
    $dataset_id = get_sanitized_value($_POST['dataset_id'] ?? '1');
	
    if ($mode == 'u' && ($item_id != '' && $item_id != 'NULL')) {
        $chart_info_url = "EXEC spa_rfx_chart_dhx @flag='s', @process_id='$process_id', @report_page_chart_id='$item_id'";
        $chart_info = readXMLURL2($chart_info_url);
        if (is_array($chart_info) && sizeof($chart_info) > 0) {
            $dataset_id = $chart_info[0]['root_dataset_id'];
            $chart_name = $chart_info[0]['name'];
            $y_axis_caption = $chart_info[0]['y_axis_caption'];
            $x_axis_caption = $chart_info[0]['x_axis_caption'];
            $current_page_break = $chart_info[0]['page_break'];
            $chart_properties_jsoned = ($chart_info[0]['chart_properties']); //will be used later, don't delete
            $chart_properties = json_decode($chart_properties_jsoned);
            $type = $chart_info[0]['type_id'];
        }

        $updated_values_url = "EXEC spa_rfx_chart_dhx @flag='a', @process_id='$process_id', @report_page_chart_id='$item_id'";
        $updated_values = readXMLURL2($updated_values_url);

        if (is_array($updated_values) && sizeof($updated_values) > 0) {
            foreach ($updated_values as $data) {
                $data['chart_properties'] = '';
                array_push($existing_columns, $data);
            }
        }
    }	

    $xml_url = "EXEC spa_rfx_report_dataset_dhx @flag='h', @process_id='$process_id', @report_dataset_id='$dataset_id'";
    $ds_col_info_list = readXMLURL2($xml_url);    
    /*foreach ($ds_col_info_list as $ds_col_info):

        echo '<pre>';
        var_dump($ds_col_info);ds_col_info_list
        echo '</pre>';
    endforeach;
    */

    $existing_columns_jsoned = json_encode($existing_columns);

    $xml_get_ds = "EXEC spa_rfx_report_dataset_dhx @flag='s', @process_id='$process_id', @report_id='$report_id'";
    $datasets = readXMLURL($xml_get_ds);

    $xml_get_dsc = "EXEC spa_rfx_report_dataset_dhx @flag='h', @process_id='$process_id', @report_id='$report_id'";
    $dataset_columns_linear = readXMLURL($xml_get_dsc);
    
    $dataset_columns = array();

    if (is_array($dataset_columns_linear) && sizeof($dataset_columns_linear) > 0) {
        foreach ($dataset_columns_linear as $column) {
            if (!isset($dataset_columns[$column[0]]))
                $dataset_columns[$column[0]] = array();
            $data_type = ($column[4] == '3' || $column[4] == '4') ? 1 : 2;
            array_push($dataset_columns[$column[0]], array($column[1], $column[2], $column[3], $data_type, $column[5], $column[6], $column[7]));
        }
    }

    $dataset_columns_jsoned = json_encode($dataset_columns);        
     
    ?>
    
    <style type="text/css">
        /*holds page specific logics - so cant be added to adiha_style.css*/
        .column-template {
            display : none;
        }

        .small-form-element {
            width : 25px !important;
        }

        .medium-form-element {
            width : 55px !important;
        }

        .large-form-element {
            width : 150px !important;
        }

        .mega-form-element {
            width : 276px !important;
        }

        ul.connected_sorts_group {
            height : 120px;
        }

        ul.connected_sorts {
            border : 1px solid #458bc1;
            height : 115px;
            overflow : scroll;
        }

        ul.connected_sorts {
            width : 300px;
            list-style-position : inside;
            list-style-type : none;
            margin : 0;
            padding : 0 0.5em;
            float : left;
            margin-right : 10px;
        }

        ul.connected_sorts li {
            background : #cbe1fc;
            padding : 5px;
            margin : 0px;
            color : #333;
            cursor : move;
            width : auto;
            min-width : 200px;
            height : 15px;
            border : 1px solid #b6d4f8;
        }

        ul.connected_sorts .place-holding {
            height : 15px;
            border : 1px dotted #fff;
            background : #e3effd;
            list-style : none !important;
        }

        ul.connected_sorts p {
            margin : 0;
        }

        ul.connected_sorts li .styler {
            display : inline;
            cursor : pointer;
            background : #cbe1fc;
            border : 1px solid #458bc1;
            padding : 0px 4px;
            font-weight : bold;
            font-size : 10px;
        }

        ul.connected_sorts_large {
            border : 1px solid #458bc1;
            height : 363px;
            overflow : scroll;
            margin : 0;
            padding : 0;
        }

        ul.connected_sorts_large {
            width : 187px;
            list-style-position : inside;
            list-style-type : none;
            margin : 0;
            padding : 0 0.5em;
            float : left;
            margin-right : 10px;
        }

        ul.connected_sorts_large li {
            background : #cbe1fc;
            padding : 5px;
            margin : 0px;
            color : #333;
            cursor : move;
            height : 15px;
            border : 1px solid #b6d4f8;
        }

        ul.connected_sorts_large .place-holding {
            height : 15px;
            border : 1px dotted #fff;
            background : #e3effd;
            list-style : none !important;
        }

        ul.connected_sorts_large li .styler {
            display : inline;
            cursor : pointer;
            background : #cbe1fc;
            border : 1px solid #458bc1;
            padding : 0px 4px;
            font-weight : bold;
            font-size : 10px;
        }

        #all-columns-rs li .styler {
            display : none !important;
        }

        #data-columns-rs li .styler {
            display : none !important;
        }
        #series-columns-rs {
            margin-top : 3px;
            vertical-align : top;
        }

        #category-columns-rs {
            margin-top : 3px;
        }

        #resultset-param-block {
            overflow : scroll;
            height : 500px;
        }

        #preview-image {
            height : 183px;
            width : 284px;
            border : 1px solid #fafafa;
        }

        .mega-form-element {
            width : 276px!important;
        }

        .disabled {
            background : #ebeae9;
        }
        #category-columns-rs-table .composite-line-items, #series-columns-rs-table .composite-line-items {
            display:none!important;
        }

        /*hide sort block in Y and Z blocks*/
        #data-columns-rs-table .sort-items, #series-columns-rs-table .sort-items {
            display : none !important;
        }
        /*hide sort block in Y and Z blocks*/
        #data-columns-rs-table .sort-items, #series-columns-rs-table .sort-items {
            display : none !important;
        }

        /*hide aggregation block in X and Z blocks*/
        #category-columns-rs-table .aggregation-items, #series-columns-rs-table .aggregation-items {
            display : none !important;
        }

        #simple-plan, #advanced-plan, #axes-option-plan {
            height : 400px;
        }

        /* show hide tabs-base display toggle*/
        ul.mode-trigger {
            margin-left : 375px !important;
        }

        .base-mode .base, .display-mode .display {
            /*display : table-column !important;*/
        }

        .base-mode .display, .display-mode .base {
            display : none !important;
        }

        .data-table th.base, .data-table th.main {
            /* border-top : 2px solid #458bc1;
            border-bottom : 2px solid #458bc1; */
            /* added for questar only */
            border-top: 2px solid #85E1D4;                 
            border-bottom: 2px solid #85E1D4; 
        }

        .data-table th.base, .data-table th.display {
            background : #85E1D4;
            color : #fff;
            border-top : 2px solid #85E1D4;
            border-bottom : 2px solid #85E1D4;
        }
        /* added for questar only */
        .data-table th {
            background: #85E1D4;
        }
        ul.jtabs li.active a.theme-blue span {
            background: #85E1D4;
            
        }
        ul.jtabs li a {
            color: white;
            background: #CBCBCB;
            
        }
        /* added for questar only */

        /*Standard mode hack for tabs*/
        ul.jtabs li.active a.default{
            background : url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/tab-right.gif")no-repeat 100% 0px!important;
        }

        ul.jtabs li.active a.theme-blue {
            background : url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/tab-right-inner.gif")no-repeat 100% 0px!important;
        }

        ul.jtabs li.active {
            background : #ced9e1 no-repeat0-5px!important;
            display : inline-block;
        }

        #overlay-info-template, #overlay-area {
            position : absolute;
            display : block;
            width : 250px;
            height : 232px;
            z-index : 1002;
            border : 1px solid #458bc1;
            background : #bcd0f4;
            padding : 0px;
            display : none;
        }

        #overlay-area {
            width : 200px;
            padding : 4px;
        }

        #overlay-area textarea {
            height : 97%;
            width : 98%;
        }

        #close-template-info {
            position : absolute;
            left : 220px;
            top : 0;
            text-decoration : underline;
            color : #fff;
            cursor : pointer;
        }

        .clone-buttons {
            margin : 10px 0px 5px 5px;
        }

        .has-colorpicker, .clone-buttons img, .zoomer, .template-info {
            cursor : pointer;
        }

        /*Item Data type Logo*/
        .item-logo {
            width : 16px;
            height : 16px;
            display : inline-block;
        }

        .item-logo {
            background : url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/number-item.gif");
        }

        .text-item.item-logo {
            background : url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/text-item.gif");
        }

        .custom-column.item-logo {
            background : url("<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/custom-item.gif");
        }

        .shift-down {
            display:block;
            margin: 5px 0 5px 2px;
            font-size : 11px;
        }
        .shift-down-nav-top {
            position:absolute;
            margin : 5px 0 0 2px;
            font-size : 11px;
        }
        .space{
            margin-bottom:15px;
            display:block;
        }
    </style>
    
    <script type="text/javascript">
        var report_table_part = _.template(
        '<tr class="clone" id="<%= link_id%>-table">\
            <td class="main">\
                <label><input type="checkbox" value="1" class="remove-column context-form-item" /><span class="column-name"><%=real_name%></span></label>\
                <input type="hidden" class="column-dataset-id" value="<%=dataset_id%>" />\
                <input type="hidden" class="column-id" value="<%=column_id%>" />\
                <input type="hidden" class="item-id" value="<%=item_id%>" />\
            </td>\
            <td class="main"><span class="column-label"><%=label%></span></td>\
            <td width="25">\
                <span class="item-logo"></span>\
            </td>\
            <td class="base"><input type="text" class="adiha_control column-function enlarge-this" value="<%=functions%>" /></td>\
            <td class="base"><input type="text" class="adiha_control column-alias" value="<%=alias%>" /></td>\
            <td class="base aggregation-items">\
                <select class="adiha_control aggregations-list context-form-item" disabled>\
                <option value="<%=agg_id%>"><%=agg_label%></option>\
                <?php
                foreach ($rdl_column_aggregation_option as $aggr_data):
                    if ($aggr_data[5] == '1'):
                        ?>
                        <option value="<?php echo $aggr_data[0]; ?>" ><?php echo $aggr_data[2]; ?></option>\
                        <?php
                    endif;
                endforeach;
                ?>
                </select>\
            </td>\
            <td class="base sort-items"> <input type="text" value="" class="adiha_control sort-priority small-form-element" /> </td>\
			<td class="base sort-items">\
                <select class="adiha_control sorting-column context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($ds_col_info_list as $ds_col_info): ?>
                        <option value="<?php echo $ds_col_info["data_source_column_id"]; ?>"><?php echo $ds_col_info["alias"]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="base sort-items">\
                <select class="adiha_control sort-to-list context-form-item">\
                    <option value=""></option>\
                    <?php foreach ($rdl_column_sort_option as $sort_to): ?>
                        <option value="<?php echo $sort_to[0]; ?>"><?php echo $sort_to[1]; ?></option>\
                    <?php endforeach; ?>
                </select>\
            </td>\
            <td class="base composite-line-items">\
                <input type="checkbox" class="render-as-line" />\
            </td>\
        </tr>')
        
        var report_item_part = _.template(
        '<li id="<%= link_id%>-container">\
        <p>\
        <span><%= text%></span>\
        <a id="<%= link_id%>-remove" href="javascript:void(0);" onclick="remove_report_item(\"<%= link_id%>-container\")"><?php echo get_locale_value("remove", false); ?></a>\
        </p>\
        </li>')
        
        var template_info_block = _.template(
        '<a onclick="javascript:close_tinfo()" id="close-template-info"><?php echo get_locale_value("close", false); ?></a>\
        <table class="data-table" width="100%">\
            <tr>\
                <th colspan="3"> <?php echo get_locale_value("About template", true); ?> <%if (typeof(label) != "undefined") {print(label)} else {print("N/A")}%></th>\
            </tr>\
            <%if (typeof(label) != "undefined" && label != "Global") {%>\
            <tr>\
                <th colspan="2" width="40"><?php echo get_locale_value("Style", false); ?></th>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Font", false); ?></td>\
                <td><%if (typeof(font) != "undefined") {print(font)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Font Size", false); ?></td>\
                <td><%if (typeof(font_size) != "undefined") {print(font_size + "pt")} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Font Style", false); ?></td>\
                <td><%if (typeof(font_style) != "undefined") {print(font_style)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Text Align", false); ?></td>\
                <td><%if (typeof(text_align) != "undefined") {print(text_align)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td nowrap><?php echo get_locale_value("Text Color", false); ?></td>\
                <td>\
                    <%if (typeof(text_color) != "undefined") {%>\
                    <input type="text" readonly style="background:<%=text_color%>" class="adiha_control small-form-element" />\
                    <% } else { %>\
                    <input type="text" readonly value="N/A" class="adiha_control small-form-element" />\
                    <% }%>\
                </td>\
            </tr>\
            <% }%>\
        </table>\
        <table class="data-table" width="100%">\
            <tr>\
                <th colspan="2"><b class="formlabelL"><?php echo get_locale_value("Column Formats", false); ?></b></th>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Thousand Separation", false); ?></td>\
                <td><%if (typeof(thousand) != "undefined") {print(thousand)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Rounding", false); ?></td>\
                <td><%if (typeof(rounding) != "undefined") {print(rounding)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Currency", false); ?></td>\
                <td><%if (typeof(currency) != "undefined") {print(currency)} else {print("N/A")}%></td>\
            </tr>\
            <tr>\
                <td><?php echo get_locale_value("Date format", false); ?></td>\
                <td><%if (typeof(date_format) != "undefined") {print(date_format)} else {print("N/A")}%></td>\
            </tr>\
        </table>')
        
        var repo_function_list = [];
        var dataset_columns = <?php echo $dataset_columns_jsoned; ?>;
        var template = <?php echo json_encode($rdl_column_attributes_template); ?>;
        var rounding_list = <?php echo json_encode($rdl_column_rounding_option); ?>;
        var date_format_list = <?php echo json_encode($rdl_column_date_format_option); ?>;
        var currency_list = <?php echo json_encode($rdl_column_currency_option); ?>;
        var drop_yesno_list = <?php echo json_encode($rdl_generic_drop_options_yes_no); ?>;
        var dataset_alias = '<?php echo $dataset_alias; ?>';
        var dataset_id = '<?php echo $dataset_id; ?>';
        
        fx_set_dataset_id = function(id) {
            dataset_id = id;
        }
        
        $(function() {
            /*new filter selector - case insensitive contains filter*/
            $.expr[':'].ci_contains = function(a, i, m) {
                return $(a).text().toLowerCase().indexOf(m[3].toLowerCase()) >= 0;
            };

            /* toggle tab for column tables (Data format and legend style click)*/
            $('.mode-trigger a').click(function() {
                var current_link = $(this);
                var current_value = current_link.attr('rel');
                current_link.parents('ul').eq(0).find('li').removeClass('active');
                $('ul.jtabs li a.theme-blue span', current_link.parents('ul').eq(0)).css('background', 'none');
                current_link.parents('li').eq(0).addClass('active');
                var next_table = current_link.parents('ul').eq(0).next('table.column-table');

                switch (current_value) {
                    case '1':
                        next_table.removeClass('display-mode');
                        next_table.addClass('base-mode');
                        break;
                    case '2':
                        next_table.removeClass('base-mode');
                        next_table.addClass('display-mode');
                        break;
                }

                next_table.append(' ');
            });

            function prep_drags(dataset_id) {
                if (dataset_id != undefined || dataset_id != '') {
                    var html_prepd = '';
                    repo_function_list = [];
                    _.each(dataset_columns[dataset_id], function(item) {
                        html_prepd += '<li data-master_column_template="' + item[6] + '" rel="' + item[3] + '" data-alias="" class="drag-items" id="rs-column-' + item[2] + '-' + item[0] + '" data-real-name="' + item[4] + '" title="' + item[5] + '">' + item[1] + '</li>';
                        repo_function_list.push(item[1]);
                    });

                    return html_prepd;
                } else {
                    return '';
                }
            }
            
            function settle_composite_items(){
                var chart_type = $('#chart-type').val();
                if(chart_type === "51"){
                    $('#data-columns-rs-table .composite-line-items').show();
                }else{
                    $('#data-columns-rs-table .composite-line-items').hide();
                }
            }

           fx_chart_type_change = function(chart_type_id) {
                var chart_type = chart_type_id;
                if (chart_type == 1) {
                    var chart_category = 7;
                } else {
                     var chart_category = chart_type;
                }
                var chart_thumb = $('#chart-type :selected').data('thumbnail');

                if (chart_type === "") {
                    chart_thumb = "blank_preview.gif";
                }
                
                switch(chart_category) {
                    case 7:
                        $("#series-columns-rs").addClass('disabled');
                        $("#series-columns-rs li").remove();
                        $("#series-columns-rs-table tr.clone").remove();
                        $("#series-columns-rs-table").parent('div.table-container').hide();
                        $("#axes-caption-properties-wrapper").hide();
                        $('#axes-properties tr.clone[data-axis="z"]').hide();
                        //set_y_axis_caption_value('');
                        //set_x_axis_caption_value('');
                        //setEnabled(<?php echo $form_name; ?>.y_axis_caption, false);
                        //setEnabled(<?php echo $form_name; ?>.x_axis_caption, false);
                        break;
                    case 2:
                        $('#axes-properties tr.clone[data-axis="z"]').show();
                        $("#axes-caption-properties-wrapper").show();
                        $("#series-columns-rs").removeClass('disabled');
                        $("#series-columns-rs-table").parent('div.table-container').show();
                        //setEnabled(<?php echo $form_name; ?>.y_axis_caption, true);
                        //setEnabled(<?php echo $form_name; ?>.x_axis_caption, true);
                        $('.y-cat-label').text('X');
                        $('.x-cat-label').text('Y');
                        break;
                    default:
                        $('#axes-properties tr.clone[data-axis="z"]').show();
                        $("#axes-caption-properties-wrapper").show();
                        $("#series-columns-rs").removeClass('disabled');
                        $("#series-columns-rs-table").parent('div.table-container').show();
                        //setEnabled(<?php echo $form_name; ?>.y_axis_caption, true);
                        //setEnabled(<?php echo $form_name; ?>.x_axis_caption, true);
                        $('.y-cat-label').text('Y');
                        $('.x-cat-label').text('X');
                }
                settle_composite_items();
                $('#preview-image').attr('src', "<?php echo $app_php_script_loc; ?>/adiha_pm_html/process_controls/chart_types/" + chart_thumb);
            }
           
           /*
            $('#datasets-list').change(function() {
                var dataset_id = $(this).val();
                $('#data-columns-rs').html('');
                $('#data-columns-rs-table tr.clone').remove();
                $('#category-columns-rs').html('');
                $('#category-columns-rs-table tr.clone').remove();
                $('#series-columns-rs').html('');
                $('#series-columns-rs-table tr.clone').remove();
                $('#all-columns-rs').html(prep_drags(dataset_id));
                $("#all-columns-rs li").draggable({
                    helper: "clone"
                });
            });
            
            */
           
            /*sortable widget codes*/
            /* function that applies changes once a template is selected for a given render type*/
            var register_template_event = function(context) {
                var container_obj = context.parents('tr').eq(0);
                var template_type = context.find('option:selected').attr('rel');
                var template_selected = context.val();

                if (template_selected == '-1')
                    return false;

                var populate_list = [
                    ['font', '.font-list', 1],
                    ['font_size', '.font-size-list', 1],
                    ['font_style', '.bold-checkbox,.italic-checkbox,.underline-checkbox', 4],
                    ['text_align', '.text-align-list', 1],
                    ['text_color', '.text-color-list', 2],
                    ['background', '.background-list', 2],
                    ['thousand', '.thousand-list', 1],
                    ['rounding', '.rounding-list', 1],
                    ['negative_mark', '.negative-mark-list', 1],
                    ['currency', '.currency-list', 1],
                    ['date_format', '.date-format-list', 1]
                ];

                if (template_selected == '0') { //act for global template; handles thousand, rounding, negative_mark, currency, date_format    
                    populate_list = [
                        ['thousand', '.thousand-list', 1],
                        ['rounding', '.rounding-list', 1],
                        ['negative_mark', '.negative-mark-list', 1],
                        ['currency', '.currency-list', 1],
                        ['date_format', '.date-format-list', 1]
                    ];
                    _.each(populate_list, function(item) {
                        $(item[1], container_obj).val((item[0] === 'rounding') ? '-1' : '0');
                    });
                    return true;
                }
                _.each(populate_list, function(item) {
                    var item_value = template[template_type][template_selected][item[0]];

                    switch (item[2]) {
                        case 1://normal input and select
                            if (item_value != undefined)
                                $(item[1], container_obj).val(item_value);
                            break;

                        case 2://colorpicker
                            if (item_value != undefined) {
                                $(item[1], container_obj).val(item_value);
                                $(item[1], container_obj).css('color', item_value);
                                $(item[1], container_obj).css('background', item_value);
                            }
                            break;

                        case 3://checkbox
                            if (item_value != undefined) {
                                if (item_value == '1') {
                                    $(item[1], container_obj).attr('checked', true);
                                } else {
                                    $(item[1], container_obj).attr('checked', false);
                                }
                            }
                            break;

                        case 4:// B I U
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
            var register_render_event = function(context_item) {
                var container_obj = context_item.parents('tr').eq(0);
                var render_value = context_item.val();

                switch (render_value) {
                    case '2'://Number
                        $('.render-option', container_obj).hide();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;

                    case '3'://Currency
					case '13': //Price
                        $('.render-option', container_obj).hide();
                        $('.render-option-currency', container_obj).show();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;

                    case '4'://Date
                        $('.render-option', container_obj).hide();
                        $('.render-option-date', container_obj).show();
                        break;

                    case '5':
                    case '6'://Percentage & Scientific
                        $('.render-option', container_obj).hide();
                        $('.render-option-round', container_obj).show();
                        break;
					case '14': //Volume
                        $('.render-option', container_obj).hide();
                        $('.render-option-thousand', container_obj).show();
                        $('.render-option-round', container_obj).show();
                        $('.render-option-negative', container_obj).show();
                        break;
                    case '1'://HTML
                    default://TEXT
                        $('.render-option', container_obj).hide();
                }

                if (render_value == '0') { // For Text (default) to be implemented as HTML templating
                    render_value = '1';
                }

                $('.column-template', container_obj).hide();
                $('.column-template', container_obj).removeClass('current-template-option');
                var valueExists = $('.column-template-' + render_value, container_obj).has('[selected]');

                if (!valueExists)//tick if @ add mode
                    $('.column-template-' + render_value, container_obj).val('-1');
                $('.column-template-' + render_value, container_obj).addClass('current-template-option');
                $('.column-template-' + render_value, container_obj).show();
            }

            /* registers context menu, colorpicker, bind event to render list, column templates, template info etc.*/
            var register_widgets = function(context_menu, item_id, restoration) {
                //add js change function to alias field  used to captioning alias
                if (context_menu.hasClass('custom-column')) {
                    $('.column-alias', context_menu).change(function() {
                        curr_item_id = $('.item-id', $(this).parents('tr').eq(0)).val();
                        $('.column-label', $(this).parents('tr').eq(0)).html($(this).val());
                        $('#' + curr_item_id + '-container p span').text($(this).val());
                    });
                }
                //enlarger
                $('.enlarge-this', context_menu).click(function() {
                    if ($('.overlay-content-reciever').length === 0) {
                        var context_item = $(this);
                        var location = context_item.offset();
                        var modal_height = 100;
                        $('#overlay-area').css({
                            'height': modal_height
                        });
                        $('#overlay-area').css({
                            //'top':(location.top < modal_height)?(location.top):(location.top-modal_height),
                            'top': location.top,
                            'left': (location.left)
                        });
                        $('#overlay-area').show();
                        $('#overlay-area textarea').focus().val('').val(context_item.val());
                        context_item.addClass('overlay-content-reciever');
                    }
                });

                var save_text_overlay = function(container) {
                    $('.overlay-content-reciever').val(container.find('textarea').val());
                    $('.overlay-content-reciever').removeClass('overlay-content-reciever');
                    container.find('textarea').val('');
                    container.hide();
                }

                $(document).mouseup(function(e) { //hide info if clicked outside
                    var container = $("#overlay-area");
                    if (container.has(e.target).length === 0) {
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
                var context_menu_assigner = function(el, item_object, value_current) {
                    if ($(el).is('select')) {//if select 
                        if (item_object.find('option[value="' + value_current + '"]').prop('disabled') != true
                                && $(el).find('option[value="' + value_current + '"]').prop('disabled') != true
                                )
                            item_object.val(value_current);
                    } else { //else shud be input
                        item_object.val(value_current);
                    }
                    //man handle checkbox 
                    if ($(el).is('input:checkbox')) {
                        value_current = $(el).prop('checked');
                        item_object.prop('checked', value_current);
                    }
                };
                //fix to bypass hidden form elements as well -
                var hidden_input_fixer = function(item_object) {
                    if (item_object.length > 0) {
                        item_object.each(function() {
                            if ($(this).css('display') != 'none') {
                                item_object = $(this);
                            }
                        });
                    }
                }
                
                /*
                //mother function to assign context menu and stuffss
                $(".context-form-item", context_menu).contextMenu({menu: 'myMenu', width: 180}, function(action, el, pos) { //pos.docX pos.x
                    var value_current = $(el).val();
                    var td_position = $(el).parents('td').eq(0).index();
                    var tr_position = $(el).parents('tr').eq(0).index() - 1;
                    var context = $(el).parents('table').eq(0);
                    switch (action) {
                        case 'apply-to-all':
                            $('tr.clone', context).each(function(index, elem) {
                                if (index > tr_position) {
                                    var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                    hidden_input_fixer(item_object);
                                    if (item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                        context_menu_assigner(el, item_object, value_current);
                                    }
                                }
                            });
                            break;
                        case 'apply-to-even':
                            $('tr.clone', context).each(function(index, elem) {
                                var is_even = ((index + 1) % 2 == 0) ? true : false;
                                var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                hidden_input_fixer(item_object);
                                if (is_even && item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                    context_menu_assigner(el, item_object, value_current);
                                }
                            });
                            break;
                        case 'apply-to-odd':
                            $('tr.clone', context).each(function(index, elem) {
                                var is_odd = ((index + 1) % 2 == 0) ? false : true;
                                var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                hidden_input_fixer(item_object);
                                if (is_odd && item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                    context_menu_assigner(el, item_object, value_current);
                                }
                            });

                            break;
                    }

                });
                */
            };

            /* registers context menu, colorpicker, bind event to render list, column templates, template info etc.*/
            var register_axes_widgets = function(context_menu, item_id) {
                //colorpicker for custom field   
                /*
                $('#text-color-list-' + item_id).ColorPicker({
                    onSubmit: function(hsb, hex, rgb, el) {
                        var picker_id = '#' + $(el).attr('id');
                        $(picker_id).val('#' + hex);
                        $(picker_id).css('background', '#' + hex);
                        $(picker_id).css('color', '#' + hex);
                        $(picker_id).ColorPickerHide();
                    }, onBeforeShow: function() {
                        $(this).ColorPickerSetColor(this.value);
                    }
                }).bind('keyup', function() {
                    $(this).ColorPickerSetColor(this.value);
                }).addClass('has-colorpicker'); // markdown at last
                */
                
                //apply context menu
                var context_menu_assigner = function(el, item_object, value_current) {
                    if ($(el).is('select')) {//if select 
                        if (item_object.find('option[value="' + value_current + '"]').prop('disabled') != true
                                && $(el).find('option[value="' + value_current + '"]').prop('disabled') != true
                                )
                            item_object.val(value_current);
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
                //fix to bypass hidden form elements as well -
                var hidden_input_fixer = function(item_object) {
                    if (item_object.length > 0) {
                        item_object.each(function() {
                            if ($(this).css('display') != 'none') {
                                item_object = $(this);
                            }
                        });
                    }
                }
                
                /*
                //mother function to assign context menu and stuffss
                $(".context-form-item", context_menu).contextMenu({menu: 'myMenu', width: 180}, function(action, el, pos) { //pos.docX pos.x
                    var value_current = $(el).val();
                    var td_position = $(el).parents('td').eq(0).index();
                    var tr_position = $(el).parents('tr').eq(0).index() - 1;
                    var context = $(el).parents('table').eq(0);
                    switch (action) {
                        case 'apply-to-all':
                            $('tr.clone', context).each(function(index, elem) {
                                if (index > tr_position) {
                                    var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                    hidden_input_fixer(item_object);
                                    if (item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                        context_menu_assigner(el, item_object, value_current);
                                    }
                                }
                            });
                            break;
                        case 'apply-to-even':
                            $('tr.clone', context).each(function(index, elem) {
                                var is_even = ((index + 1) % 2 == 0) ? true : false;
                                var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                hidden_input_fixer(item_object);
                                if (is_even && item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                    context_menu_assigner(el, item_object, value_current);
                                }
                            });
                            break;
                        case 'apply-to-odd':
                            $('tr.clone', context).each(function(index, elem) {
                                var is_odd = ((index + 1) % 2 == 0) ? false : true;
                                var item_object = $('td', elem).eq(td_position).find('input,select,checkbox');
                                hidden_input_fixer(item_object);
                                if (is_odd && item_object.prop('disabled') != true && item_object.css('display') != 'none') {
                                    context_menu_assigner(el, item_object, value_current);
                                }
                            });

                            break;
                    }

                });
                */
                
                /*Apply Event on Render as field - to show/hide render additional options*/
                $('.renderas-list', context_menu).change(function() {
                    var context_item = $(this);
                    register_render_event(context_item);
                });
                /*Apply Event on Column templates - to apply template data on form row*/
                $('.column-template', context_menu).change(function() {
                    var context_item = $(this);
                    register_template_event(context_item);
                });
                /*Apply Event on Render options - to mark custom if render option changed that chosen from template*/
                $('.render-option', context_menu).change(function(event) {
                    var context_item = $(this);
                    var container_obj = context_item.parents('tr').eq(0);
                    $('.current-template-option', container_obj).val('-1');
                    event.preventDefault();
                });
                /*Apply Event on Template info image - to show info abt current template selected*/
                $('.template-info', context_menu).click(function(event) {
                    var context_item = $(this);
                    var template_ddn = context_item.prevAll('.current-template-option');
                    var template_id = template_ddn.val();
                    var template_options = {};
                    var template_type = template_ddn.attr('rel');
                    var x_val, modal_height;
                    switch (template_id) {
                        case '-1':
                            return false;
                            break;
                        case '0':
                            modal_height = 130;
                            template_options = {label: 'Global', thousand: 'Global', rounding: 'Global', negative_mark: 'Global', currency: 'Global', date_format: 'Global'};
                            break;
                        default:
                            modal_height = 240;
                            if (template[template_type][template_id]) {
                                _.each(template[template_type][template_id], function(val, k) {
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
                        'height': modal_height
                    });
                    $('#overlay-info-template').css({
                        'top': (location.top < modal_height) ? (location.top) : (location.top - modal_height),
                        'left': (location.left + 20)
                    });
                    $('#overlay-info-template').html(template_info_block(template_options));
                    $('#overlay-info-template').fadeIn('fast');
                });
                $(document).mouseup(function(e) { //hide template info if clicked outside
                    var container = $("#overlay-info-template");
                    if (container.has(e.target).length === 0)
                        container.hide();
                });
                $('.renderas-list', context_menu).trigger('change');
                $('html').css({'overflow-y': 'scroll'});
            };
            /* removes custom field from sortable widget and Column table @ Advanced tab, and while deleting dataset column, removes from the column table @ Advanced tab and shifts sort li to Available Fields*/
            var delete_column = function(context) {
                var deletion_queue = $('.remove-column:checked', context);
                var parent_block, sort_item_id;

                if (deletion_queue.length == 0) {
                    show_messagebox('Please select columns to delete.');
                    return false;
                } else {
                    deletion_queue.each(function(index, item) {
                        parent_block = $(item).parents('tr.clone').eq(0);
                        sort_item_id = parent_block.attr('id').replace('-table', '');
                        $('#' + sort_item_id).remove();
                        parent_block.remove();
                    });
                }
            }
            
            /* Check the field to remove and call delete function */
            delete_column_dragged = function (context, i_id) {
                var c_flag = 0;
                $( ".item-id" ).each(function() {
                    var item_id = $(this).val();
                    if (item_id == i_id) {
                        c_flag = 1;
                        $('.remove-column', $(this).closest('tr')).attr('checked','checked');
                    }
                });
                
                if (c_flag == 1) {
                    delete_column(context);
                }
            }
            
            /*adds custom fields to sortable widget and column table @ Advanced tab*/
            var register_column = function(location) { //Y:1,Z:2,X:3
                var context, context_sort, context_menu, item_id;

                switch (location) {
                    case 1:
                        context = '#data-columns-rs-table tbody';
                        context_sort = '#data-columns-rs';
                        break;
                    case 2:
                        context = '#category-columns-rs-table tbody';
                        context_sort = '#category-columns-rs';
                        break;
                    case 3:
                        context = '#series-columns-rs-table tbody';
                        context_sort = '#series-columns-rs';
                        break;
                }

                item_id = 'rs-column-' + _.uniqueId('new-clone-');
                $(context).append(report_table_part({//till here
                    real_name: '&lt;Custom Column&gt;',
                    label: '&lt;Custom Column&gt;',
                    functions: '',
                    alias: '',
                    link_id: item_id + '-container',
                    dataset_id: dataset_id,
                    column_id: '',
                    item_id: item_id,
                    agg_id: '',
                    agg_label:''
                }));
                //add sort control to sort widget
                $(context_sort).append(report_item_part({text: '&lt;Custom Column&gt;', link_id: item_id}));
                $('li:last', context_sort).addClass('custom-column');
                context_menu = $(context + ' tr:last');
                context_menu.addClass('custom-column');
                register_widgets(context_menu, item_id);
                settle_composite_items();
            }
            
            register_column_dragged = function(location, item_id, item_real_name, item_label, alias, agg_id, agg_label) {
                var context, context_sort, context_menu, item_id;
                var item_column_id = item_id.split('-');
                switch (location) {
                    case 1:
                        context = '#data-columns-rs-table tbody';
                        context_sort = '#data-columns-rs';
                        break;
                    case 2:
                        context = '#category-columns-rs-table tbody';
                        context_sort = '#category-columns-rs';
                        break;
                    case 3:
                        context = '#series-columns-rs-table tbody';
                        context_sort = '#series-columns-rs';
                        break;
                }

                $(context).append(report_table_part({//till here
                    real_name: item_real_name,
                    label: item_label,
                    functions: '',
                    alias: alias,
                    link_id: item_id + '-container',
                    dataset_id: dataset_id,
                    column_id: item_column_id[1],
                    item_id: item_id,
                    agg_id: agg_id,
                    agg_label:agg_label
                }));
                //add sort control to sort widget
                //$(context_sort).append(report_item_part({text: '&lt;Custom Column&gt;', link_id: item_id}));
                //$('li:last', context_sort).addClass('custom-column');
                //context_menu = $(context + ' tr:last');
                //context_menu.addClass('custom-column');
                //register_widgets(context_menu, item_id);
                //settle_composite_items();
            }

            var get_ds_column_suggestion = function(req, responseFn) {
                var re = $.ui.autocomplete.escapeRegex(req.term.toLowerCase());
                var matcher = new RegExp(re, "i");
                var a = $.grep(repo_function_list, function(item, index) {
                    return matcher.test(item.toLowerCase());
                });
                responseFn(a);
            };

            var move_table_row = function(current_row, to_context, item_position) {
                var selected_data = Array();
                var item_content;
                current_row.find('.column-function').autocomplete('destroy');
                current_row.find('select').each(function() {
                    selected_data.push($(this).val());
                });
                item_content = current_row.clone(true, true);
                current_row.remove();
                //$(to_context) has to be used multiple times instead of creating just one var as DOM changes between the steps
                $(to_context).eq(item_position).after(item_content);//$('#detail-column-region tr')
                $(to_context).eq(item_position + 1).find('select').each(function(index, item) {
                    $(item).val(selected_data[index]);
                });
            };

            var sync_table = function(event, ui) {
                var item_full_id = ui.item.attr('id');
                var item_position = ui.item.index();
                var location = ui.item.parent().attr('id');//landed on?
                var data_table_row = $('#' + item_full_id + '-table', $('#data-columns-rs-table'));
                var category_table_row = $('#' + item_full_id + '-table', $('#category-columns-rs-table'));
                var series_table_row = $('#' + item_full_id + '-table', $('#series-columns-rs-table'));
                var move = true;

                if (data_table_row.length > 0 && move) {//if sorted on self
                    if (location === 'data-columns-rs') {
                        var table_position = data_table_row.index() - 1;
                        move = (item_position !== table_position) ? true : false;
                    }

                    if (move) {
                        move_table_row(data_table_row, '#' + location + '-table tr', item_position);
                    }

                } else if (category_table_row.length > 0) {//if exists on category
                    if (location === 'category-columns-rs') {
                        var table_position = category_table_row.index() - 1;
                        move = (item_position !== table_position) ? true : false;
                    }

                    if (move) {
                        move_table_row(category_table_row, '#' + location + '-table tr', item_position);
                    }
                } else if (series_table_row.length > 0) {//if exists on rows
                    if (location === 'series-columns-rs') {
                        var table_position = series_table_row.index() - 1;
                        move = (item_position !== table_position) ? true : false;
                    }
                    if (move) {
                        move_table_row(series_table_row, '#' + location + '-table tr', item_position);
                    }
                }
                settle_composite_items();
            };
            
            /*
            $("ul.drop-zone").droppable({
                drop: function(event, ui) {
                    var d_content = ui.draggable.html();
                    var d_content_chk = d_content.toLowerCase();
                    //this has to be done as once items are inside the system we dont need to append them; they just move via sort
                    if (d_content_chk.search('<p>') === -1 && !$(this).hasClass('disabled')) {
                        var init_id = ui.draggable.attr('id');
                        var real_name = ui.draggable.data('real-name');
                        var item_class = (ui.draggable.attr('rel') === '2') ? 'text-item' : '';
                        var link_id = init_id + '-' + _.uniqueId('chart');
                        var item = init_id.replace('rs-column-', '');

                        if ($('#' + this.id + ' li[id^=' + init_id + '-]').length === 0) {
                            item = item.split('-');
                            item_name_splitted = d_content.split('.');
                            $(this).append(report_item_part({text: d_content, link_id: link_id}));

                            $('#' + this.id + '-table tbody').append(report_table_part({
                                real_name: real_name,
                                label: d_content,
                                functions: '',
                                alias: item_name_splitted[1],
                                link_id: link_id + '-container',
                                dataset_id: item[0],
                                column_id: item[1],
                                item_id: item[0] + '-' + item[1]
                            }));

                            $('#' + this.id + '-table tbody tr:last').addClass(item_class)
                            register_widgets($('#' + this.id + '-table tbody tr:last'), item[0] + '-' + item[1]);
                            settle_composite_items();
                        }
                    }
                }
            }).sortable({
                connectWith: '.drop-zone',
                items: "li:not(.placeholder)",
                placeholder: 'place-holding',
                sort: function() {
                    $(this).removeClass("ui-state-default");
                },
                out: function(event, ui) {
                    var item_stack = ui.item.attr('id').split('-');
                    var item_id_partial = item_stack[0] + '-' + item_stack[1] + '-' + item_stack[2] + '-' + item_stack[3] + '-';
                    //secondary condition added to fix a jquery UI bug of allowing duplicate entries; during the case sender and reciever ui resource (ul) is show same
                    //happens when sortable item is dropped on empty area inside containment but not in other uls
                    if (ui.item.parent().hasClass('disabled') || (ui.item.parent().find('li[id^=' + item_id_partial + ']').length > 1 && !ui.item.hasClass('custom-column')) || ui.item.parent().attr('id') === $(ui.sender).attr('id'))
                        $(ui.sender).sortable('cancel');
                },
                stop: sync_table
            });
            */
            
            $('.add-custom-button').click(function() {
                register_column($(this).data('place'));
            });
            $('.remove-custom-button').click(function() {
                switch ($(this).data('place')) {
                    case 1:
                        delete_column($('#data-columns-rs-table'));
                        break;
                    case 2:
                        delete_column($('#category-columns-rs-table'));
                        break;
                    case 3:
                        delete_column($('#series-columns-rs-table'));
                        break;
                }
            });
            
            $('#axes-properties tr.clone').each(function(index,item){
                register_axes_widgets($(item),$(item).data('axis')+'-axis');
            })
            $('#axes-caption-properties tr.clone').each(function(index,item){
                register_axes_widgets($(item),$(item).data('axis')+'-axis-caption');
            })

            var mode = '<?php echo $mode; ?>';

            if (mode === 'u') {
                var existing_columns = <?php echo $existing_columns_jsoned; ?>;
                $('#datasets-list').val(<?php echo $dataset_id; ?>);
                $('#datasets-list').trigger('change');
                var places = ['', '#data-columns-rs', '#series-columns-rs', '#category-columns-rs'];
                existing_columns = _.sortBy(existing_columns, function(item) {
                    return parseInt(item['placement'] + '' + item['column_order'], 10);
                });
                var dom_elem, d_content, link_id, current_item, real_name, item_class, styles;
                _.each(existing_columns, function(item) {
                    dom_elem = $('#rs-column-' + item['dataset_id'] + '-' + item['column_id'], $('#all-columns-rs'));
                    d_content = (item['custom_field'] === '1') ? item['alias'] : dom_elem.html();
                    real_name = dom_elem.data('real-name');
                    item_class = (dom_elem.attr('rel') === '2') ? 'text-item' : '';
                    link_id = (item['custom_field'] === '1') ? _.uniqueId('rs-column-old-clone-') : dom_elem.attr('id') + '-' + _.uniqueId('chart');
                    $(places[item['placement']]).append(report_item_part({text: d_content, link_id: link_id}));
                    $(places[item['placement']] + '-table tbody').append(report_table_part({
                        real_name:  (item['custom_field'] === '1') ? '&lt;Custom Column&gt;' : dataset_alias + '.' + item['alias'],
                        label: dataset_alias + '.' + item['alias'],
                        functions: (item['functions'] === null) ? '' : item['functions'],
                        alias: item['alias'],
                        link_id: item['dataset_id'] + '-' + item['column_id'] + '-container',
                        dataset_id: item['dataset_id'],
                        column_id: item['column_id'],
                        item_id: item['dataset_id'] + '-' + item['column_id'],
                        agg_id: '',
                        agg_label: ''
                    }));
                    current_item = $(places[item['placement']] + '-table tbody tr:last');
                    current_item.addClass(item_class);
                    if (item['custom_field'] === '1') {
                        current_item.addClass('custom-column');
                    }
                    register_widgets($(places[item['placement']] + '-table tbody tr:last'), item['dataset_id'] + '-' + item['column_id'], true);//repeating selector, necessary. some weird bug
                    //setters for the block
                    $('.aggregations-list', current_item).val(item['aggregation']);
                    $('.sort-priority', current_item).val(item['default_sort_order']);
					$('.sorting-column', current_item).val(item['sorting_column']);
                    $('.sort-to-list', current_item).val(item['default_sort_direction']);
                    if (item['render_as_line'] === '1')
                        $('.render-as-line', current_item).prop('checked', true);
/*---------
                    $('.renderas-list', current_item).val(item['render_as']).trigger('change');
                    $('.current-template-option', current_item).val(item['column_template']);
                    $('.date-format-list', current_item).val(item['date_format']);
                    $('.currency-list', current_item).val(item['currency']);
                    $('.thousand-list', current_item).val(item['thousand_seperation']);
                    $('.rounding-list', current_item).val(item['rounding']);
                    $('.font-list', current_item).val(item['font']);
                    $('.font-size-list', current_item).val(item['font_size']);
                    $('.text-align-list', current_item).val(item['text_align']);

                    styles = item['font_style'].split(',');
                    if (styles[0] === '1')
                        $('.bold-checkbox', current_item).prop('checked', true);
                    if (styles[1] === '1')
                        $('.italic-checkbox', current_item).prop('checked', true);
                    if (styles[2] === '1')
                        $('.underline-checkbox', current_item).prop('checked', true);

                    $('.text-color-list', current_item).val(item['text_color']);
                    $('.text-color-list', current_item).css('color', item['text_color']);
                    $('.text-color-list', current_item).css('background', item['text_color']);
--------*/
                });
            }
            $('#chart-type').trigger('change');
            $('.drag-area').disableSelection();
        });
        
        function remove_report_item(item) {
            $('#' + item).remove();
            $('#' + item + '-table').remove();
        }
        
        function close_tinfo() {
            $('#overlay-info-template').fadeOut('fast');
        }

        
        /*============================================== SAVE LOGIC ==============================================*/
        
        var xml_rs_columns, error, chart_properties;
        
        /*prepare data for save logic*/
        var set_save_chart_params = function(placement, current_context, item_order) {
            stack = {};
            stack.placement = placement;
            stack.column_id = $('.column-id', current_context).val();
            stack.dataset_id = $('.column-dataset-id', current_context).val();
            stack.column_alias = $('.column-alias', current_context).val();

            if (stack.column_alias == 'NULL' || stack.column_alias == '') {
                error = 1;
                return;
            }

            stack.function_name = $('.column-function', current_context).val();
            //stack.function_name = stack.function_name.replace(/'/g, "''");

            stack.aggregation = (stack.placement == '1') ? $('.aggregations-list', current_context).val() : '';
            
            if(stack.placement == '1' && $('#chart-type :selected').data('category')== '8')
                stack.render_as_line = ( $('.render-as-line', current_context).is(':checked')) ? 1 : 0;
            else
                stack.render_as_line = 0;

            if (stack.placement == '3') {
                stack.sort_priority = $('.sort-priority', current_context).val();
				stack.sorting_column = $('.sorting-column', current_context).val();
                stack.sort_to = $('.sort-to-list', current_context).val();
            } else {
                stack.sort_priority = '';
				stack.sorting_column = '';
                stack.sort_to = '';
            }

            stack.custom_field = (current_context.hasClass('custom-column')) ? '1' : '0';
            if (stack.custom_field == '1')
                stack.column_id = '';
            
            

            xml_rs_columns += '<PSRecordset DataSetID="' + stack.dataset_id
                            + '" ColumnID="' + stack.column_id
                            + '" ColumnAlias="' + escapeXML(stack.column_alias)
                            + '" FunctionName="' + escapeXML(stack.function_name)
                            + '" Aggregation="' + stack.aggregation
                            + '" SortPriority="' + stack.sort_priority
							+ '" SortingColumn="' + stack.sorting_column
                            + '" SortTo="' + stack.sort_to
                            + '" CustomField="' + stack.custom_field
                            + '" ColumnOrder="' + item_order
                            + '" Placement="' + stack.placement
                            + '" RenderAsLine="' + stack.render_as_line
                            + '"></PSRecordset>';
        }
        
        var set_save_axes_params = function(current_context,axes) {
            stack = {};
            stack.render_as = $('.renderas-list', current_context).val();
            stack.column_template = $('.current-template-option', current_context).val();

            switch (stack.render_as) {
                case '0':
                case '1'://Text, HTML
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = '';
                    stack.date_format = '';
                    break;
                case '2'://Number
                    stack.currency = '';
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.date_format = '';
                    break;
                case '3'://Currency
				case '13': //Price
                    stack.currency = $('.currency-list', current_context).val();
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.date_format = '';
                    break;
                case '4'://Date
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = '';
                    stack.date_format = $('.date-format-list', current_context).val();
                    break;

                case '5':
                case '6'://Percentage, Scientific
                    stack.currency = '';
                    stack.thousand_list = '';
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.date_format = ''
                    break;
				case '14': //Volume
                    stack.currency = '';
                    stack.thousand_list = $('.thousand-list', current_context).val();
                    stack.rounding = $('.rounding-list', current_context).val();
                    stack.date_format = '';
                    break;
            }
                
            stack.font = $('.font-list', current_context).val();
            stack.font_size = $('.font-size-list', current_context).val();
            stack.bold_style = $('.bold-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.italic_style = $('.italic-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.underline_style = $('.underline-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.text_align = $('.text-align-list', current_context).val();
            stack.text_color = $('.text-color-list', current_context).val();

            chart_properties['axes'][axes] = stack;
        }
        var set_save_axes_caption_params = function(current_context,axes) {
            stack = {};
            stack.font = $('.font-list', current_context).val();
            stack.font_size = $('.font-size-list', current_context).val();
            stack.bold_style = $('.bold-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.italic_style = $('.italic-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.underline_style = $('.underline-checkbox', current_context).is(':checked') ? 1 : 0;
            stack.text_align = $('.text-align-list', current_context).val();
            stack.text_color = $('.text-color-list', current_context).val();
            stack.caption = $('input[name=' + (axes == 'y' ? 'y_axis_caption' : 'x_axis_caption') + ']', current_context).val();
            chart_properties['axes_caption'][axes] = stack;
        }

        save_chart_xml = function() {
            //var x_axis_caption = get_x_axis_caption_value();
            //var y_axis_caption = get_y_axis_caption_value();
           
            //prep XML from table
            xml_rs_columns = '<Root>';
            chart_properties = {};
            chart_properties['axes'] = {};
            chart_properties['axes_caption'] = {};
            error = 0;

            $('#axes-properties tr.clone').each(function(index, item) {
                if($(item).css('display') !== 'none')
                    set_save_axes_params($(item),$(item).data('axis'));
            });
            if($('#axes-caption-properties').is(":visible")){
                $('#axes-caption-properties tr.clone').each(function(index, item) {
                    set_save_axes_caption_params($(item),$(item).data('axis'));
                });
            }
            
            $('#data-columns-rs-table tr.clone').each(function(index, item) {
                set_save_chart_params(1, $(item), (index+1));
            });
            $('#series-columns-rs-table tr.clone').each(function(index, item) {
                set_save_chart_params(2, $(item), (index+1));
            });
            $('#category-columns-rs-table tr.clone').each(function(index, item) {
                set_save_chart_params(3, $(item), (index+1));
            });

            xml_rs_columns += '</Root>';
            var return_obj = {
                chart_properties: chart_properties,
                xml_rs_columns: xml_rs_columns
            };
            return return_obj;
        }

        /*============================================END SAVE LOGIC =============================================*/
    </script>
    
    <form name= "<?php echo $form_name; ?>" style="margin: 0px 0px 0px 3px;">
        <textarea id="xml_columns" name="xml_columns" style="display:none;" ></textarea>
        <textarea id="chart_properties" name="chart_properties" style="display:none;" ></textarea>
        
        <ul class="jtabs-content">
            <li id="advanced-plan">
                <div class="class-trm-chart-advance-table">
                <?php
                $group_tabs = array(
                    array('label' => get_locale_value('Data', false) . ' [<span class="y-cat-label">Y</span>]', 'id' => 'data-columns-rs-table', 'placement' => 1, 'data_var' => 'data_columns', 'name' => 'group', 'display' => ($current_type_id == 1) ? '' : 'none'),
                    array('label' => get_locale_value('Series', false) . ' [Z]', 'id' => 'series-columns-rs-table', 'placement' => 3, 'data_var' => 'series_columns', 'name' => 'rows', 'display' => ($current_type_id == 1) ? 'none' : ''),
                    array('label' => get_locale_value('Category', false) . ' [<span class="x-cat-label">X</span>]', 'id' => 'category-columns-rs-table', 'placement' => 2, 'data_var' => 'category_columns', 'name' => 'cols', 'display' => ($current_type_id == 1) ? 'none' : '')
                );
                foreach ($group_tabs as $tabnow):
                    ?>
                    <div class="table-container">
                        <label class="FormLabelHeader shift-down"><?php echo $tabnow['label']; ?>:</label>
                        <table width="99%" class="data-table" id="<?php echo $tabnow['id']; ?>">
                            <tr>
                                <th nowrap width="180" class=""><?php echo get_locale_value('Column', false); ?></th>
                                <th nowrap width="180" colspan="2"><?php echo get_locale_value('Alias', false); ?></th>
                                <th width="%"><?php echo get_locale_value('Function', false); ?></th>
                                <th width="%">* <?php echo get_locale_value('Display Name', false); ?></th>
                                <th class="aggregation-items" width="%"><?php echo get_locale_value('Aggregation', false); ?></th>								
                                <th width="70" class="sort-items" nowrap><?php echo get_locale_value('Sort Priority', false); ?></th>
								<th width="80" class="sort-items" nowrap><?php echo show_label('Sorting Column', false); ?></th>
                                <th width="%" class="sort-items" nowrap><?php echo get_locale_value('Sort To', false); ?></th>
                                <th width="%" class="composite-line-items" nowrap><?php echo get_locale_value('Render as Line', false); ?></th>
                            </tr>
                        </table>
                        <hr>
                    </div>
                <?php endforeach; ?>
            
                <div class="FormLabelHeader shift-down-nav-top"><?php echo get_locale_value('Axes Data Formatting', true); ?></div>
                <ul class="mode-trigger jtabs">
                    <li class="active"><a class="theme-blue" href="javascript:void(0)" rel="1"><span><?php echo get_locale_value('Data Format', false); ?></span></a></li>
                    <li><a class="theme-blue" href="javascript:void(0)" rel="2"><span><?php echo get_locale_value('Legend Style', false); ?></span></a></li>
                </ul>
                <table width="99%" class="data-table base-mode column-table" id="axes-properties">
                    <tr>
                        <th nowrap width="180" class="main"> </th>
                        <th width="50" class="base" nowrap><?php echo get_locale_value('Render as', false); ?></th>
                        <th width="116" class="base" nowrap><?php echo get_locale_value('Template', false); ?></th>
                        <th width="%" class="base" nowrap><?php echo get_locale_value('Date Format', false) . '**'; ?></th>
                        <th width="%" class="base" nowrap><?php echo get_locale_value('Currency', false) . '**'; ?></th>
                        <th width="%" class="base" nowrap><?php echo get_locale_value('Thousand', false) . '**'; ?></th>
                        <th width="%" class="base" nowrap><?php echo get_locale_value('Rounding', false) . '**'; ?></th>
                        <th width="%" class="display" nowrap><?php echo get_locale_value('Font', false); ?></th>
                        <th width="%" class="display" nowrap><?php echo get_locale_value('Font Size', false); ?></th>
                        <th width="%" class="display" colspan="3" nowrap><?php echo get_locale_value('Font Style', false); ?></th>
                        <th width="%" class="display" nowrap><?php echo get_locale_value('Text Align', false); ?></th>
                        <th width="%" class="display" nowrap><?php echo get_locale_value('Text Color', false); ?></th>
                    </tr>
                    <tr class="clone" data-axis="y">
                        <td class="main"><b><?php echo get_locale_value('Data', false) . ' [<span class="y-cat-label">Y</span>]'; ?></b></td>
                        <td class="base">
                            <select class="adiha_control renderas-list">
                                <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                                    <option value="<?php echo $render_as[0]; ?>" <?php echo (isset($chart_properties->axes->y->render_as) && $render_as[0] == $chart_properties->axes->y->render_as) ? 'selected' : ''; ?>><?php echo $render_as[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="base">
                            <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                                <select class="adiha_control column-template column-template-<?php echo $key; ?>" rel="<?php echo $key; ?>">
                                    <option class="custom" value="-1">Custom</option>
                                    <?php if ($key != '1' && $key != '6'): ?>
                                        <option class="custom" value="0" <?php echo (isset($chart_properties->axes->y->render_as) && $chart_properties->axes->y->column_template == '0') ? 'selected' : ''; ?>>Global</option>
                                    <?php endif; ?>
                                    <?php foreach ($template_base as $template): ?>
                                        <option rel="<?php echo $template['type']; ?>" value="<?php echo $template['id']; ?>" <?php echo (isset($chart_properties->axes->y->column_template) && $template['id'] == $chart_properties->axes->y->column_template) ? 'selected' : ''; ?>><?php echo $template['label']; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php endforeach; ?>
                            <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.gif" align="middle" />
                        </td>
                        <td class="base">
                            <div class="render-option render-option-date">
                                <select class="adiha_control date-format-list ">
                                    <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                                        <option value="<?php echo $date_format[0]; ?>" <?php echo (isset($chart_properties->axes->y->date_format) && $date_format[0] == $chart_properties->axes->y->date_format) ? 'selected' : ''; ?>><?php echo $date_format[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-currency">
                                <select class="adiha_control currency-list ">
                                    <?php foreach ($rdl_column_currency_option as $currency): ?>
                                        <option value="<?php echo $currency[0]; ?>" <?php echo (isset($chart_properties->axes->y->currency) && $currency[0] == $chart_properties->axes->y->currency) ? 'selected' : ''; ?>><?php echo $currency[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>    
                        <td class="base">
                            <div class="render-option render-option-thousand">
                                <select class="thousand-list adiha_control" >
                                    <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                        <option value="<?php echo $option[0]; ?>" <?php echo (isset($chart_properties->axes->y->thousand_seperation) && $option[0] == $chart_properties->axes->y->thousand_seperation) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-round">
                                <select class="adiha_control rounding-list ">
                                    <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                                        <option value="<?php echo $rounding[0]; ?>" <?php echo (isset($chart_properties->axes->y->rounding) && $rounding[0] == $chart_properties->axes->y->rounding) ? 'selected' : ''; ?>><?php echo $rounding[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font = (isset($chart_properties->axes->y->font))?$chart_properties->axes->y->font:$rdl_column_default_attributes['font'];
                                foreach ($rdl_column_font_option as $font): ?>
                                    <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $this_font) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-size-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font_size = (isset($chart_properties->axes->y->font_size))?$chart_properties->axes->y->font_size:$rdl_column_default_attributes['font_size'];
                                foreach ($rdl_column_font_size_option as $font_size): ?>
                                    <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $this_font_size) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display" nowrap> 
                            <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo (isset($chart_properties->axes->y->bold_style) && $chart_properties->axes->y->bold_style == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo (isset($chart_properties->axes->y->italic_style) && $chart_properties->axes->y->italic_style == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo (isset($chart_properties->axes->y->underline_style) && $chart_properties->axes->y->underline_style == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                        </td>
                        <td class="display">
                        </td>
                        <td class="display">
                            <?php $this_text_color = (isset($chart_properties->axes->y->text_color))?$chart_properties->axes->y->text_color:$rdl_column_default_attributes['text_color'];?>
                            <input type="text" style="background:<?php echo $this_text_color; ?>;color:<?php echo $this_text_color; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-y-axis" value="<?php echo $this_text_color; ?>" readonly="readonly"/>
                        </td>
                    </tr>
                    <tr class="clone" data-axis="z">
                        <td class="main"><b><?php echo get_locale_value('Series', false) . ' [Z]'; ?></b></td>
                        <td class="base">
                            <select class="adiha_control renderas-list">
                                <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                                    <option value="<?php echo $render_as[0]; ?>" <?php echo (isset($chart_properties->axes->z->render_as) && $render_as[0] == $chart_properties->axes->z->render_as) ? 'selected' : ''; ?>><?php echo $render_as[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="base">
                            <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                                <select class="adiha_control column-template column-template-<?php echo $key; ?>" rel="<?php echo $key; ?>">
                                    <option class="custom" value="-1">Custom</option>
                                    <?php if ($key != '1' && $key != '6'): ?>
                                        <option class="custom" value="0" <?php echo (isset($chart_properties->axes->z->render_as) && $chart_properties->axes->z->column_template == '0') ? 'selected' : ''; ?>>Global</option>
                                    <?php endif; ?>
                                    <?php foreach ($template_base as $template): ?>
                                        <option rel="<?php echo $template['type']; ?>" value="<?php echo $template['id']; ?>" <?php echo (isset($chart_properties->axes->z->column_template) && $template['id'] == $chart_properties->axes->z->column_template) ? 'selected' : ''; ?>><?php echo $template['label']; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php endforeach; ?>
                            <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.gif" align="middle" />
                        </td>
                        <td class="base">
                            <div class="render-option render-option-date">
                                <select class="adiha_control date-format-list ">
                                    <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                                        <option value="<?php echo $date_format[0]; ?>" <?php echo (isset($chart_properties->axes->z->date_format) && $date_format[0] == $chart_properties->axes->z->date_format) ? 'selected' : ''; ?>><?php echo $date_format[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-currency">
                                <select class="adiha_control currency-list ">
                                    <?php foreach ($rdl_column_currency_option as $currency): ?>
                                        <option value="<?php echo $currency[0]; ?>" <?php echo (isset($chart_properties->axes->z->currency) && $currency[0] == $chart_properties->axes->z->currency) ? 'selected' : ''; ?>><?php echo $currency[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>    
                        <td class="base">
                            <div class="render-option render-option-thousand">
                                <select class="thousand-list adiha_control" >
                                    <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                        <option value="<?php echo $option[0]; ?>" <?php echo (isset($chart_properties->axes->z->thousand_seperation) && $option[0] == $chart_properties->axes->z->thousand_seperation) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-round">
                                <select class="adiha_control rounding-list ">
                                    <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                                        <option value="<?php echo $rounding[0]; ?>" <?php echo (isset($chart_properties->axes->z->rounding) && $rounding[0] == $chart_properties->axes->z->rounding) ? 'selected' : ''; ?>><?php echo $rounding[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font = (isset($chart_properties->axes->z->font))?$chart_properties->axes->z->font:$rdl_column_default_attributes['font'];
                                foreach ($rdl_column_font_option as $font): ?>
                                    <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $this_font) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-size-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font_size = (isset($chart_properties->axes->z->font_size))?$chart_properties->axes->z->font_size:$rdl_column_default_attributes['font_size'];
                                foreach ($rdl_column_font_size_option as $font_size): ?>
                                    <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $this_font_size) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display" nowrap> 
                            <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo (isset($chart_properties->axes->z->bold_style) && $chart_properties->axes->z->bold_style == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo (isset($chart_properties->axes->z->italic_style) && $chart_properties->axes->z->italic_style == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo (isset($chart_properties->axes->z->underline_style) && $chart_properties->axes->z->underline_style == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                        </td>
                        <td class="display">
                            <select class="adiha_control text-align-list">
                                <option value=""></option>
                                <?php 
                                $this_text_align = (isset($chart_properties->axes->z->text_align))?$chart_properties->axes->z->text_align:$rdl_column_default_attributes['text_align'];
                                foreach ($rdl_column_text_align_option as $text_align): ?>
                                    <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $this_text_align) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <?php $this_text_color = (isset($chart_properties->axes->z->text_color))?$chart_properties->axes->z->text_color:$rdl_column_default_attributes['text_color'];?>
                            <input type="text" style="background:<?php echo $this_text_color; ?>;color:<?php echo $this_text_color; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-z-axis" value="<?php echo $this_text_color; ?>" readonly="readonly"/>
                        </td>
                    </tr>
                    <tr class="clone" data-axis="x">
                        <td class="main"><b><?php echo get_locale_value('Category', false) . ' [<span class="x-cat-label">X</span>]'; ?></b></td>
                        <td class="base">
                            <select class="adiha_control renderas-list">
                                <?php foreach ($rdl_column_render_as_options as $render_as): ?>
                                    <option value="<?php echo $render_as[0]; ?>" <?php echo (isset($chart_properties->axes->x->render_as) && $render_as[0] == $chart_properties->axes->x->render_as) ? 'selected' : ''; ?>><?php echo $render_as[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="base">
                            <?php foreach ($rdl_column_attributes_template as $key => $template_base): ?>
                                <select class="adiha_control column-template column-template-<?php echo $key; ?>" rel="<?php echo $key; ?>">
                                    <option class="custom" value="-1">Custom</option>
                                    <?php if ($key != '1' && $key != '6'): ?>
                                        <option class="custom" value="0" <?php echo (isset($chart_properties->axes->x->render_as) && $chart_properties->axes->x->column_template == '0') ? 'selected' : ''; ?>>Global</option>
                                    <?php endif; ?>
                                    <?php foreach ($template_base as $template): ?>
                                        <option rel="<?php echo $template['type']; ?>" value="<?php echo $template['id']; ?>" <?php echo (isset($chart_properties->axes->x->column_template) && $template['id'] == $chart_properties->axes->x->column_template) ? 'selected' : ''; ?>><?php echo $template['label']; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            <?php endforeach; ?>
                            <img class="template-info" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/info.gif" align="middle" />
                        </td>
                        <td class="base">
                            <div class="render-option render-option-date">
                                <select class="adiha_control date-format-list ">
                                    <?php foreach ($rdl_column_date_format_option as $date_format): ?>
                                        <option value="<?php echo $date_format[0]; ?>" <?php echo (isset($chart_properties->axes->x->date_format) && $date_format[0] == $chart_properties->axes->x->date_format) ? 'selected' : ''; ?>><?php echo $date_format[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-currency">
                                <select class="adiha_control currency-list ">
                                    <?php foreach ($rdl_column_currency_option as $currency): ?>
                                        <option value="<?php echo $currency[0]; ?>" <?php echo (isset($chart_properties->axes->x->currency) && $currency[0] == $chart_properties->axes->x->currency) ? 'selected' : ''; ?>><?php echo $currency[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>    
                        <td class="base">
                            <div class="render-option render-option-thousand">
                                <select class="thousand-list adiha_control" >
                                    <?php foreach ($rdl_generic_drop_options_yes_no as $option): ?>
                                        <option value="<?php echo $option[0]; ?>" <?php echo (isset($chart_properties->axes->x->thousand_seperation) && $option[0] == $chart_properties->axes->x->thousand_seperation) ? 'selected' : ''; ?>><?php echo $option[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="base">
                            <div class="render-option render-option-round">
                                <select class="adiha_control rounding-list ">
                                    <?php foreach ($rdl_column_rounding_option as $rounding): ?>
                                        <option value="<?php echo $rounding[0]; ?>" <?php echo (isset($chart_properties->axes->x->rounding) && $rounding[0] == $chart_properties->axes->x->rounding) ? 'selected' : ''; ?>><?php echo $rounding[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font = (isset($chart_properties->axes->x->font))?$chart_properties->axes->x->font:$rdl_column_default_attributes['font'];
                                foreach ($rdl_column_font_option as $font): ?>
                                    <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $this_font) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display">
                            <select class="adiha_control font-size-list context-form-item">
                                <option value=""></option>
                                <?php 
                                $this_font_size = (isset($chart_properties->axes->x->font_size))?$chart_properties->axes->x->font_size:$rdl_column_default_attributes['font_size'];
                                foreach ($rdl_column_font_size_option as $font_size): ?>
                                    <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $this_font_size) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td class="display" nowrap> 
                            <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo (isset($chart_properties->axes->x->bold_style) && $chart_properties->axes->x->bold_style == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo (isset($chart_properties->axes->x->italic_style) && $chart_properties->axes->x->italic_style == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                        </td>
                        <td class="display" nowrap>
                            <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo (isset($chart_properties->axes->x->underline_style) && $chart_properties->axes->x->underline_style == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                        </td>
                        <td class="display">
                        </td>
                        <td class="display">
                            <?php $this_text_color = (isset($chart_properties->axes->x->text_color))?$chart_properties->axes->x->text_color:$rdl_column_default_attributes['text_color'];?>
                            <input type="text" style="background:<?php echo $this_text_color; ?>;color:<?php echo $this_text_color; ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-x-axis" value="<?php echo $this_text_color; ?>" readonly="readonly"/>
                        </td>
                    </tr>
                </table>
                
                <div id="axes-caption-properties-wrapper">
                    <div class="FormLabelHeader shift-down"><?php echo get_locale_value('Axes Caption', true); ?></div>
                    <table width="99%" class="data-table column-table" id="axes-caption-properties">
                        <tr>
                            <th nowrap width="180"> </th>
                            <th nowrap width="180"><?php echo get_locale_value('Axis Caption', false); ?></th>
                            <th width="%" nowrap><?php echo get_locale_value('Font', false); ?></th>
                            <th width="%" nowrap><?php echo get_locale_value('Font Size', false); ?></th>
                            <th width="%" colspan="3" nowrap><?php echo get_locale_value('Font Style', false); ?></th>
                            <th width="%" nowrap><?php echo get_locale_value('Text Align', false); ?></th>
                            <th width="%" nowrap><?php echo get_locale_value('Text Color', false); ?></th>
                        </tr>
                        <tr class="clone" data-axis="y">
                            <td><b><?php echo get_locale_value('Data', false) . ' [<span class="y-cat-label">Y</span>]'; ?></b></td>
                            <td>
                                <input type="text" name="y_axis_caption"  value="<?php echo $y_axis_caption; ?>"/>
                                <?php
                                //echo adiha_textbox($form_name, 'y_axis_caption', $y_axis_caption, true, 180);
                                ?>
                            </td>
                            <td>
                                <select class="adiha_control font-list context-form-item">
                                    <option value=""></option>
                                    <?php 
                                        $this_font = (isset($chart_properties->axes_caption->y->font))?$chart_properties->axes_caption->y->font:$rdl_column_default_attributes['font'];
                                        foreach ($rdl_column_font_option as $font): ?>
                                        <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $this_font) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td>
                                <select class="adiha_control font-size-list context-form-item">
                                    <option value=""></option>
                                    <?php 
                                        $this_font_size = (isset($chart_properties->axes_caption->y->font_size))?$chart_properties->axes_caption->y->font_size:$rdl_column_default_attributes['font_size'];
                                        foreach ($rdl_column_font_size_option as $font_size): ?>
                                        <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $this_font_size) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td nowrap><?php echo isset($chart_properties->axes_caption->x->bold_check);?>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->y->bold_style) && $chart_properties->axes_caption->y->bold_style == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                            </td>
                            <td nowrap>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->x->italic_style) && $chart_properties->axes_caption->y->italic_style == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                            </td>
                            <td nowrap>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->x->underline_style) && $chart_properties->axes_caption->y->underline_style == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                            </td>
                            <td>
                                <select class="adiha_control text-align-list">
                                <option value=""></option>
                                <?php 
                                    $this_text_align = (isset($chart_properties->axes_caption->y->text_align))?$chart_properties->axes_caption->y->text_align:$rdl_column_default_attributes['text_align'];
                                    foreach ($rdl_column_text_align_option as $text_align): ?>
                                    <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $this_text_align) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                                <?php endforeach; ?>
                                </select>
                            </td>
                            <td>
                                <?php $this_text_color = (isset($chart_properties->axes_caption->y->text_color))?$chart_properties->axes_caption->y->text_color:$rdl_column_default_attributes['text_color'];?>
                                <input type="text" style="background:<?php echo $this_text_color; ?>;color:<?php echo $this_text_color ?>" class="adiha_control text-color-list small-form-element context-form-item" id="text-color-list-y-axis-caption" value="<?php echo $this_text_color ?>" readonly="readonly"/>
                            </td>
                        </tr>
                        <tr class="clone" data-axis="x">
                            <td class="main"><b><?php echo get_locale_value('Category', false) . ' [<span class="x-cat-label">X</span>]'; ?></b></td>
                            <td class="main">
                                <input type="text" name="x_axis_caption" value="<?php echo $x_axis_caption; ?>"/>
                                <?php
                                //echo adiha_textbox($form_name, 'x_axis_caption', $x_axis_caption, true, 180);
                                ?>
                            </td>
                            <td>
                                <select class="adiha_control font-list context-form-item">
                                    <option value=""></option>
                                    <?php 
                                        $this_font = (isset($chart_properties->axes_caption->x->font))?$chart_properties->axes_caption->x->font:$rdl_column_default_attributes['font'];
                                        foreach ($rdl_column_font_option as $font): ?>
                                        <option value="<?php echo $font[0]; ?>" <?php echo ($font[0] == $this_font) ? 'selected' : ''; ?>><?php echo $font[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td>
                                <select class="adiha_control font-size-list context-form-item">
                                    <option value=""></option>
                                    <?php 
                                        $this_font_size = (isset($chart_properties->axes_caption->x->font_size))?$chart_properties->axes_caption->x->font_size:$rdl_column_default_attributes['font_size'];
                                        foreach ($rdl_column_font_size_option as $font_size): ?>
                                        <option value="<?php echo $font_size[0]; ?>" <?php echo ($font_size[0] == $this_font_size) ? 'selected' : ''; ?>><?php echo $font_size[1]; ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </td>
                            <td nowrap>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="bold-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->x->bold_style) && $chart_properties->axes_caption->x->bold_style == 1) ? ' checked="checked"' : ''; ?> /><b>B</b></label>
                            </td>
                            <td nowrap>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="italic-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->x->italic_style) && $chart_properties->axes_caption->x->italic_style == 1) ? ' checked="checked"' : ''; ?> /><i>I</i></label>
                            </td>
                            <td nowrap>
                                <label style="display: inline-block;"><input type="checkbox" value="" class="underline-checkbox context-form-item" <?php echo (isset($chart_properties->axes_caption->x->underline_style) && $chart_properties->axes_caption->x->underline_style == 1) ? ' checked="checked"' : ''; ?> /><u>U</u></label>
                            </td>
                            <td>
                                <select class="adiha_control text-align-list">
                                <option value=""></option>
                                <?php 
                                    $this_text_align = (isset($chart_properties->axes_caption->x->text_align))?$chart_properties->axes_caption->x->text_align:$rdl_column_default_attributes['text_align'];
                                    foreach ($rdl_column_text_align_option as $text_align): ?>
                                    <option value="<?php echo $text_align[0]; ?>" <?php echo ($text_align[0] == $this_text_align) ? 'selected' : ''; ?>><?php echo $text_align[1]; ?></option>
                                <?php endforeach; ?>
                                </select>
                            </td>
                            <td>
                                <?php $this_text_color = (isset($chart_properties->axes_caption->x->text_color))?$chart_properties->axes_caption->x->text_color:$rdl_column_default_attributes['text_color'];?>
                                <input type="text" style="background:<?php echo $this_text_color; ?>;color:<?php echo $this_text_color ?>" class="adiha_control text-color-list small-form-element" id="text-color-list-x-axis-caption" value="<?php echo $this_text_color ?>" readonly="readonly"/>
                            </td>
                        </tr>
                    </table>
                </div>
                </div>
                <hr>
                <div class="class-trm-chart-advance-info">
                    <table width="100%">
                    <tr valign="top">
                        <td>
                            <b><?php echo show_label('Legend'); ?></b>
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/number-item.gif" align="middle" /> <?php echo show_label('Number Item', false); ?>,
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/text-item.gif" align="middle" /> <?php echo show_label('Text Item', false); ?>,
                            <img src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/custom-item.gif" align="middle" /> <?php echo show_label('Custom Item', false); ?>.
                        </td>
                        <td align="left">
                            <b><?php echo show_label('Note'); ?></b> 
                            <dl class="notes">
                                <dt>**</dt>
                                <dd><?php echo show_label('These options will be available/unavailable depending upon "Render as" option selected for the column.', false); ?></dd>
                                <dt>***</dt>
                                <dd><?php echo show_label('Total Aggregation when selected will let the column participate on Tablix Grand Total block.', false); ?></dd>
                                <dt>****</dt>
                                <dd><?php echo show_label('Placement for Total caption can be seletecd if this tablix has no grouping; on other cases it appears at first column.', false); ?></dd>
                            </dl>
                        </td>
                    </tr>
                    </table>  
                </div>
            </li>
        </ul>
    </form>
    
    <div class="class-trm-chart-advance-contextmenu">
    <div id="overlay-info-template">
    </div>
    <div id="overlay-area">
        <textarea class="" title="Press Enter or click Outer Region to end typing."</textarea>
    </div>    
    <ul id="myMenu" class="contextMenu" style="display: none;">
        <li class="blank"><a href="#apply-to-all"><?php echo get_locale_value('Apply to All', false); ?></a></li>
        <li class="blank"><a href="#apply-to-even"><?php echo get_locale_value('Apply to Even Rows', false); ?></a></li>
        <li class="blank"><a href="#apply-to-odd"><?php echo get_locale_value('Apply to Odd Rows', false); ?></a></li>
    </ul>
    </div>
</body>
</html>>