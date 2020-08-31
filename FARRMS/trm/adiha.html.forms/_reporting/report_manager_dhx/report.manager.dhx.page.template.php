<?php
/**
* Report manager page template screen
* @copyright Pioneer Solutions
*/
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html>
    <?php
    require_once('../../../adiha.php.scripts/components/include.file.v3.php');
    require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    #load global variables
    require_once '../report_manager_dhx/report.global.vars.php';
    $php_script_loc = $app_php_script_loc;

    //echo paint_formHeaderUI("FARRMS: Report Page IU");

    $rights_report_page = 10201617;
    $rights_page_paramset_iu = 10201622;
    $rights_page_paramset_del = 10201623;
    $rights_page_chart_iu = 10201629;
    $rights_page_chart_del = 10201630;
    $rights_page_tablix_iu = 10201631;
    $rights_page_tablix_del = 10201632;

    list (
        $has_rights_page_paramset_iu,
        $has_rights_page_paramset_del,
        $has_rights_page_chart_iu,
        $has_rights_page_chart_del,
        $has_rights_page_tablix_iu,
        $has_rights_page_tablix_del
    ) = build_security_rights(
        $rights_page_paramset_iu, 
        $rights_page_paramset_del, 
        $rights_page_chart_iu, 
        $rights_page_chart_del, 
        $rights_page_tablix_iu,
        $rights_page_tablix_del
    );

    $form_name = 'report_page_iu';

    $mode = get_sanitized_value($_GET['mode'] ?? '');
    $page_id = get_sanitized_value($_GET['page_id'] ?? 'NULL');
    $report_id = get_sanitized_value($_GET['report_id'] ?? 'NULL');
    $process_id = get_sanitized_value($_GET['process_id'] ?? 'NULL');
    $report_flag = get_sanitized_value($_GET['report_flag'] ?? '');
    $report_privilege_type = get_sanitized_value($_GET['report_privilege_type'] ?? 'NULL');
    $width = get_sanitized_value($_GET['width'] ?? '');
    $page_name = get_sanitized_value($_GET['page_name'] ?? '');
    $dataset_id = get_sanitized_value($_GET['dataset_id'] ?? '');
    $height = get_sanitized_value($_GET['height'] ?? '');
    $report_items = array();

    if ($mode == 'u') {
        $xml_url = "EXEC spa_rfx_report_page_dhx @flag='a', @process_id='$process_id', @report_page_id='$page_id'";
        $data = readXMLURL2($xml_url);
        $page_name = $data[0]['page_name'];
        $width = $data[0]['width'];
        $height = $data[0]['height'];
        $xml_report_items = "EXEC spa_rfx_report_page_dhx @flag='r', @process_id='$process_id', @report_page_id='$page_id'";
        $report_items = readXMLURL($xml_report_items);
    }

    $report_items_jsoned = json_encode($report_items);
    //echo '<pre>' . print_r($report_items);exit();
    ?>
    <body style="margin: 1px;">
    <div id="layout-container" style="height: 98%; position: relative; margin: 0px 10px 10px 0px; xoverflow: auto;">
        <div id="layout" style="height: 100%; width: 100%;"></div>
    </div>
    <div id="report-items" style="margin-top: 4px;" style="display: none;">
        <span id="report-item-1" item_type="1">
        </span>
        <span id="report-item-2" item_type="2">
        </span>
        <span id="report-item-3" item_type="3">
        </span>
        <span id="report-item-4" item_type="4">
        </span>                                        
        <span id="report-item-5" item_type="5">
        </span>                                        
        <span id="report-item-6" item_type="6">
        </span>                                        
    </div>
    <form name= '<?php echo $form_name ?>' style="display: none;">
        <textarea id="xml_ri" name="xml_ri" style="display: none;"></textarea>
    </form>
    </body>
    <link type="text/css" href="<?php echo $app_php_script_loc; ?>components/ui/theme/jquery-ui-1.8.20.custom.css" rel="stylesheet" />
    <script type="text/javascript">
        //top.window.moveTo(0, 0);
        //top.window.resizeTo(screen.availWidth, screen.availHeight);
    </script>
    <!-- <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/underscore.min.js"></script> --> 
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery.fixedposition.js"></script>
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/raphael.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function() {
            //$("#floating-save-bar").fixedPosition({
//                debug: false,
//                fixedTo: "bottom"
//            });
        });
    </script>
    <style type="text/css">
        #floating-save-bar {
            background: white;
            width: 100%;
            height: 25px;
            border-top: 1px solid #bcd0f4;
            z-index:1200;
        }

        #main-block-report-page {
            padding-bottom: 25px;
        }

        #layout .report-item {
            background: #88D9B1;
            position: absolute;
            z-index:1000;
            display:inline-block;
        }

        .report-item input {
            cursor: pointer;
        }

        #layout {
            position: relative;
            z-index:10;
        }

        .clean {
            background: none!important;
            width: 200px;
            height: 20px;
        }

        .blotter {
            width: 300px;
            height: 200px;
            min-width: 170px;
            min-height: 140px;
        }

        #layout .report-item img.report-item-type {
            width: 50px;
        }

        .auto-image img.label {
            width: 32px;
        }

        form.image-form {
            margin: 0px;
            padding: 0px;
        }

        #layout-container {
            border: 1px solid silver; 
            xborder-top: 2px solid #666;
            xborder-right: 4px solid #666;
            xborder-bottom: 4px solid #666;
            background: #ffffff!important;
            width:auto;
            height:auto;
        }

        #report-items img {
            display: inline;
        }
        
        .auto-textbox-blotter{
            min-width: 70px;
            min-height:12px;
        }

        .auto-textbox,.auto-image {
            display:inline-block;
            width: 100%;
            height: 100%;
            border: 1px dashed #ddd
        }

        .auto-textbox span.label {
            margin-top: 2px;
        }

        .auto-textbox textarea.textbox {
            width: 100%;
            height: 100%;
            display: none;
        }

        .more-options {
            position: absolute;
            width: 220px;
            height: 50px;
            display: none;
        }

        .less-options {
            position: absolute;
            width: 20px;
            height: 15px;
            top: 2px;
            left:-30px;
            text-align:right;
        }

        #report-items {
            width:288px;
        }

        #report-items img {
            display: inline;
        }

        #report-items span {
            float: left;
            width: 72px;
            cursor: move;
        } 
        #layout a{
            color: #666;
            text-decoration: none;
        }
        .line .form{ position:absolute;z-index:1100;}
        .line .top,.line .bottom {
            position: absolute;
            width: 6px;
            height: 6px;
            background: #FFF;
            border: 1px solid #666;
            z-index: 1100;
            cursor: move;
            display: inline;
        }
        .small-form-element {
            width: 25px!important;
        }
        .has-colorpicker{
            cursor: pointer;
        }
    </style>
    <script type="text/javascript">
        //pixl per inch
        var ppi = parseFloat(75);
        var line_overhead = 3.25;//calc by ui.helper.width() / 2 at runtime
        var paper = false;
        var has_rights_page_paramset_iu = Boolean(<?php echo $has_rights_page_paramset_iu; ?>);
        var has_rights_page_paramset_del = Boolean(<?php echo $has_rights_page_paramset_del; ?>);

        var php_path = '<?php echo $php_script_loc; ?>';
        var session_id = '<?php echo $session_id; ?>';
        var accepted_img_extensions = ['jpg', 'png', 'gif'];
        var default_tbx_caption = '<?php echo $default_tbx_caption = ' Enter text...'; ?>';//required step 
        var save_required = false;
        var report_privilege_type = '<?php echo $report_privilege_type; ?>';
        var page_name = '<?php echo $page_name; ?>';
        var page_height = '<?php echo $height; ?>';
        var page_width = '<?php echo $width; ?>';
        var process_id_gbl = '<?php echo $process_id; ?>';
        var report_flag_gbl = '<?php echo $report_flag; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var page_id = '<?php echo $page_id; ?>';
        var post_data = '';

        function btn_close_click() {
            parent.window.close();
        }

        function get_message(msg) {
            switch (msg) {
                case 'INVALID_WIDTH':
                    return 'Width must be numeric.';
                case 'INVALID_NAME':
                    return 'Invalid Name! Only letters, numbers, underscore and space are allowed.';
                case 'INVALID_HEIGHT':
                    return 'Height must be numeric.';
                case 'REPORT_PAGE_INSERTED':
                    return 'Report page inserted with default parameter set.';
                case 'REPORT_PAGE_UPDATED':
                    return 'Report page successfully updated.';
                case 'BLANK_NAME':
                    return 'Please enter Name.';
                case 'GRID_EMPTY':
                    return 'Please select an item from the grid.';
                case 'BLANK_FONT':
                case 'BLANK_FONT_SIZE':
                    return 'Please select Font Information.';
                case 'PAGE_NOT_SAVED':
                    return 'Please save the Page to continue.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete the selected data?';
                case 'INVALID_IMAGE_TYPE':
                    return 'Please select valid image file. Only JPEG, GIF, PNG images are allowed.';
                case 'IMAGE_NOT_SELECTED':
                    return 'Please select Image file.';
                case 'BLANK_TEXTBOX':
                    return 'Please add text.';
                case 'REPORT_PAGE_IMAGE_INSERTED':
                case 'REPORT_PAGE_IMAGE_UPDATED':
                    return 'Image uploaded successfully.';
                case 'NO_RIGHTS':
                    return 'Privilege Issue! Contact your System Administrator for the required privilege.';
                case 'PAGE_SAVE':
                    return 'Please save the Page to continue.';
                case 'DELETE_ITEM_CONFIRM':
                    return "Are you sure you want to delete the selected report item?";
                case 'VALIDATE_PARAMSET_SAVE':
                    return 'Please save the paramset to complete the report.'
            }
        }

        function update_layout() {
            var container_width = page_width;
            var container_height = page_height;
            //layout width height
            var layout_width = '100%'; //container_width * ppi;
            var layout_height = '100%'; //container_height * ppi;
            //apply dimension
            $('#layout, #layout-container').width(layout_width);
            $('#layout, #layout-container').height(layout_height);
            //resize paper
            try{
                paper.setSize(layout_width,layout_height);
            } catch (e) {
            }
        }

        function save_layout() {
            //calculate items position
            var xml_ri = '<Root>';
            $('#layout .report-item').each(function() {
                var js_object = $(this);
                var item_id = $('.item-id', js_object).val();
                var item_type = $('.item-type', js_object).val();
                //if(item_type != '6')
//                    update_wh(js_object);

                if (item_id != '') {
                    var top = $('.its-top', js_object).val();
                    var left = $('.its-left', js_object).val();
                    var width = $('.its-width', js_object).val();
                    var height = $('.its-height', js_object).val();
                    xml_ri += '<PSRecordset ItemID="' + item_id
                                + '" ItemType="' + item_type
                                + '" TopCR="' + top
                                + '" LeftCR="' + left
                                + '" Width="' + width
                                + '" Height="' + height
                                + '" ></PSRecordset>';
                }
            });
            return xml_ri += '</Root>';
        }

        function remove_report_item(context) {
            var context_object = $('#' + context.id).parents('div.report-item').eq(0);
            var process_id = process_id_gbl;
            var item_id = $('.item-id', context_object).val();
            var item_type = $('.item-type', context_object).val();
            //var message = get_message('DELETE_ITEM_CONFIRM');
            
            parent.parent.parent.confirm_messagebox(get_message('DELETE_ITEM_CONFIRM'), function() {
                if (item_id != '') {
                    var delete_url;

                    switch (item_type) {
                        case '1':
                            delete_url = "EXEC spa_rfx_chart_dhx @flag='d', @process_id='" + process_id + "', @report_page_chart_id=" + item_id;
                            break;
                        case '2':
                            //delete_url = php_path + 'spa_rfx_report_page_tablix_dhx.php?flag=d&process_id=' + process_id + '&report_page_tablix_id=' + item_id;
                            delete_url = "EXEC spa_rfx_report_page_tablix_dhx @flag='d', @process_id='" + process_id + "', @report_page_tablix_id=" + item_id;
                            break;
                        case '3':
                            //delete_url = php_path + 'spa_rfx_report_page_textbox_dhx.php?flag=d&process_id=' + process_id + '&report_page_textbox_id=' + item_id;
                            delete_url = "EXEC spa_rfx_report_page_textbox_dhx @flag='d', @process_id='" + process_id + "', @report_page_textbox_id=" + item_id;
                            break;
                        case '4':
                            //delete_url = php_path + 'spa_rfx_report_page_image_dhx.php?flag=d&process_id=' + process_id + '&report_page_image_id=' + item_id;
                            delete_url = "EXEC spa_rfx_report_page_image_dhx @flag='d', @process_id='" + process_id + "', @report_page_image_id=" + item_id;
                            break;
                        case '5':
                            //delete_url = php_path + 'spa_rfx_gauge_dhx.php?flag=d&process_id=' + process_id + '&report_page_gauge_id=' + item_id;
                            delete_url = "EXEC spa_rfx_gauge_dhx @flag='d', @process_id='" + process_id + "', @report_page_gauge_id=" + item_id;
                            break;
                        case '6':
                            //delete_url = php_path + 'spa_rfx_report_page_line_dhx.php?flag=d&process_id=' + process_id + '&report_page_line_id=' + item_id;
                            delete_url = "EXEC spa_rfx_report_page_line_dhx @flag='d', @process_id='" + process_id + "', @report_page_line_id=" + item_id;
                            break;
                    }
                    //console.log(delete_url);
                    
                    //ajax call
                    
                    post_data = { sp_string: delete_url };
                    $.ajax({
                        url: js_form_process_url,
                        data: post_data,
                    }).done(function(data) {
                        //console.log(data['json'][0].name);
                        var json_data = data['json'][0];
                        if(json_data.errorcode == 'Success') {
                            if(item_type == '6'){
                                $('#'+context_object.attr('id')+'-path').remove();
                            }
                            context_object.remove();
                        } else {
                            parent.parent.dhtmlx.message({
                                title: 'error',
                                type: 'alert-error',
                                text: 'Error on deletion. (' + json_data.recommendation + ')'
                            });
                        }
                        
                    });
                    
                } else {
                    if(item_type == '6'){
                        $('#'+context_object.attr('id')+'-path').remove();
                    }
                    context_object.remove();
                }
            });
           
        }

        function open_report_item_form(context) {
            var js_object = $('#' + context.id).parents('div.report-item').eq(0);
            
            var top = $('.its-top', js_object).val();
            var left = $('.its-left', js_object).val();
            var width = $('.its-width', js_object).val();
            var height = $('.its-height', js_object).val();
            var item_id = $('.item-id', js_object).val();
            var ri_info_obj = {
                item_id: $('.item-id', js_object).val(),
                top: $('.its-top', js_object).val(),
                left: $('.its-left', js_object).val(),
                width: $('.its-width', js_object).val(),
                height: $('.its-height', js_object).val(),
                item_type: 'report-item-' + $('.item-type', js_object).val(),
                page_id: page_id,
                page_name: page_name,
                report_item_id: js_object.attr('id')
            };
            
            var param_obj = {
                process_id: process_id_gbl,
                item_flag: 'u',
                ri_info_obj: ri_info_obj
            };
            fx_open_report_item_detail(param_obj);
            
            
            
            return;
            
            /*
            var js_object = $('#' + context.id).parents('div.report-item').eq(0);
            var page_id = get_txt_page_id_value();

            if (page_id == 'NULL') {
                adiha_CreateMessageBox('alert', get_message('PAGE_SAVE'));
                return false;
            }

            var top = $('.its-top', js_object).val();
            var left = $('.its-left', js_object).val();
            var width = $('.its-width', js_object).val();
            var height = $('.its-height', js_object).val();
            var item_id = $('.item-id', js_object).val();
            var mode = 'i';

            if (item_id != '') {
                mode = 'u';
            }

            var report_id = get_txt_report_id_value();
            var process_id = get_txt_process_id_value();
            var param = 'page_id=' + page_id
                        + '&process_id=' + process_id
                        + '&report_id=' + report_id
                        + '&top=' + top
                        + '&left=' + left
                        + '&width=' + width
                        + '&height=' + height
                        + '&mode=' + mode
                        + '&item_id=' + item_id;
            var item_type = $('img.report-item-type', js_object).attr('rel');
            var return_value = false;
            try {
                switch (item_type) {
                    case '1':
                        return_value = createWindow('windowReportPageChart', false, true, param);
                        break;
                    case '2':
                        return_value = createWindow('windowReportPageTablix', false, true, param);
                        break;
                    case '5':
                        return_value = createWindow('windowReportPageGauge', false, true, param);
                        break;
                }
                //return primary key -- thus recommendation required at end
                if (return_value.item_id != undefined) {
                    if (mode == 'i' && return_value.item_id != 'NULL,') {
                        $('.item-id', js_object).val(return_value.item_id);
                    }
                    $('.its-name', js_object).html(return_value.item_name);
                    $('.its-width', js_object).val(return_value.width);
                    $('.its-height', js_object).val(return_value.height);
                }
                update_report_item_form(context);
            } catch (exceptions) {
            }
            */

        }
        
        /*
         * Updates width height of a report item once its dragged or dropped
         **/
        function update_wh(jq_object, save_mode) {
            var new_width = parseFloat(jq_object.width()) / ppi;
            var new_height = parseFloat(jq_object.height()) / ppi;
            $('.its-width', jq_object).val(new_width);
            $('.its-height', jq_object).val(new_height);

            var pos = jq_object.position();
            //console.log(pos);
            $('.its-top-show', jq_object).html(pos.top);
            $('.its-left-show', jq_object).html(pos.left);
            var new_top = parseFloat(pos.top / ppi);
            var new_left = parseFloat(pos.left / ppi);

            if (new_top < 0)
                new_top = 0;

            if (new_left < 0)
                new_left = 0;

            $('.its-top', jq_object).val(new_top);
            $('.its-left', jq_object).val(new_left);

            //if (save_mode == undefined)
                //set_btn_save_report_enabled(true);
        }

        function update_report_item_form(context) {
            var js_object = $('#' + context.id).parents('div.report-item').eq(0);
            var new_width = $('.its-width', js_object).val() * ppi;
            var new_height = $('.its-height', js_object).val() * ppi;
            js_object.css('width', new_width);
            js_object.css('height', new_height);
            update_wh(js_object);
        }

        function register_auto_textbox(context_object, item) {
            var textbox_object = $('.auto-textbox', context_object);

            if (item) {
                var default_text = (item[2].length > 0) ? item[2] : default_tbx_caption;
                var label_item = $('span.label', textbox_object);
                label_item.text(default_text);

                if (default_text.length > 0 && default_text != default_tbx_caption)
                    $('textarea.textbox', textbox_object).val(default_text);

                $('.font-list', textbox_object).val(item[7]);
                label_item.css('font-family', item[7]);
                $('.font-size-list', textbox_object).val(item[8]);

                if (item[8].length > 0)
                    label_item.css('font-size', item[8] + 'pt');

                var font_style = item[9].split(',');

                if (font_style[0] == '1') {
                    $('.bold-checkbox', textbox_object).attr('selected', true);
                    label_item.css('font-weight', 'bold');
                } else {
                    label_item.css('font-weight', 'normal');
                }

                if (font_style[1] == '1') {
                    $('.italic-checkbox', textbox_object).attr('selected', true);
                    label_item.css('font-style', 'italic');
                } else {
                    label_item.css('font-style', 'normal');
                }

                if (font_style[2] == '1') {
                    $('.underline-checkbox', textbox_object).attr('selected', true);
                    label_item.css('text-decoration', 'underline');
                } else {
                    label_item.css('text-decoration', 'none');
                }

                $('.font-size-list', textbox_object).val(item[8]);
            }

            $('span.label', textbox_object).dblclick(function() {
                var input_item = $('textarea.textbox', textbox_object);

                if (input_item.css('display') == 'none') {
                    var text_val = $.trim(input_item.val());

                    if (text_val.length > 0 && text_val != default_tbx_caption)
                        input_item.val(text_val);

                    $('span.label', textbox_object).hide();
                    input_item.show();
                    $('.more-options', textbox_object).show();
                    $('.less-options', textbox_object).hide();
                }
            });

            $('.cancel-change', textbox_object).click(function() {
                $('.more-options', textbox_object).hide();
                $('textarea.textbox', textbox_object).hide();
                $('span.label', textbox_object).show();
            });

            $('.apply-change', textbox_object).click(function() {
                var text_val = $.trim($('textarea.textbox', textbox_object).val());

                if (text_val.length == 0) {
                    dhtmlx.message({
                        title: 'error',
                        type: 'alert-error',
                        text: get_message('BLANK_TEXTBOX')
                    });
                    return false;
                }

                var font = $('.font-list', textbox_object).val();
                var font_size = $('.font-size-list', textbox_object).val();

                if (font == '') {
                    dhtmlx.message({
                        title: 'error',
                        type: 'alert-error',
                        text: get_message('BLANK_FONT')
                    });
                    return false;
                }

                if (font_size == '') {
                    dhtmlx.message({
                        title: 'error',
                        type: 'alert-error',
                        text: get_message('BLANK_FONT_SIZE')
                    });
                    return false;
                }

                //var page_id = get_txt_page_id_value();
                //var process_id = get_txt_process_id_value();
                var label_item = $('span.label', textbox_object);

                if (text_val.length > 0)
                    label_item.text(text_val);
                else
                    label_item.text(default_tbx_caption);

                $('textarea.textbox', textbox_object).hide();
                $('.more-options', textbox_object).hide();
                $('.less-options', textbox_object).show();

                var bold = $('input.bold-checkbox:checked', textbox_object).val();
                var italic = $('input.italic-checkbox:checked', textbox_object).val();
                var underline = $('input.underline-checkbox:checked', textbox_object).val();
                var font_style = '';

                if (bold == '1') {
                    label_item.css('font-weight', 'bold');
                    font_style = '1,';
                } else {
                    label_item.css('font-weight', 'normal');
                    font_style = '0,';
                }

                if (italic == '1') {
                    label_item.css('font-style', 'italic');
                    font_style += '1,';
                } else {
                    label_item.css('font-style', 'normal');
                    font_style += '0,';
                }

                if (underline == '1') {
                    label_item.css('text-decoration', 'underline');
                    font_style += '1';
                } else {
                    label_item.css('text-decoration', 'none');
                    font_style += '0';
                }

                label_item.css('font-family', font);
                label_item.css('font-size', font_size + 'pt');

                var width = $('.its-width', textbox_object).val();
                var height = $('.its-height', textbox_object).val();
                var top = $('.its-top', textbox_object).val();
                var left = $('.its-left', textbox_object).val();
                var item_id = $('.item-id', textbox_object).val();
                var mode = (item_id != '') ? 'u' : 'i';

                if (item_id == '')
                    item_id = 'NULL';
               
                var sp_url = "EXEC spa_rfx_report_page_textbox_dhx @flag='" + mode 
                    + "', @process_id='" + process_id_gbl 
                    + "', @report_page_textbox_id=" + item_id
                    + " , @page_id=" + page_id
                    + " , @content='" + text_val
                    + "', @font='" + font
                    + "', @font_size='" + font_size
                    + "', @font_style='" + font_style
                    + "', @width='" + width
                    + "', @height='" + height
                    + "', @top='" + top
                    + "', @left='" + left + "'"
                    ;
                          
                post_data = { sp_string: sp_url };
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    console.log(data);
                    var json_data = data['json'][0];
                    if(json_data.errorcode == 'Success') {
                        if (mode == 'i') {
                            $('.item-id', textbox_object).val(json_data.recommendation);
                        }
                    } else {
                        parent.parent.dhtmlx.message({
                            title: 'error',
                            type: 'alert-error',
                            text: 'Error on Textbox save.'
                        });
                    }
                    
                });

                label_item.show();
            });
        }
        
        function draw_line(x1, y1, x2, y2, id, color, size, style){
            switch(style){
                case '2':
                    style = '.'; 
                    break;
                case '3':
                    style = '-'; 
                    break;
                default://case '1':    
                    style = ''; 
            }
            $('#' + id).remove();//remove old line
            var line_item = paper.path("M" + x1 + " " + y1 + " L" + x2 + " " + y2).attr({'stroke-dasharray': style,'stroke':color,'stroke-width':size});
            line_item.node.id = id;
            $('#' + id).css('z-index', 100);
            $(paper.canvas).css('z-index', 100);
        }
        
        function register_auto_line(context_object, item, pos) {
            if(item){
                x1 = item[4];
                y1 = item[3];
                x2 = item[5];
                y2 = item[6];
                color = item[2];
                size = item[7];
                style = item[8];
            }else{
                x1 = pos.x1 + line_overhead;
                y1 = pos.y1 + line_overhead;
                x2 = pos.x2 + line_overhead;
                y2 = pos.y2 + line_overhead;   
                color = $('.line-color',context_object).val();
                size = $('.line-size',context_object).val();
                style = $('.line-style',context_object).val();
                set_btn_save_report_enabled(true);
            }
            //draw first with existing data
            draw_line(x1, y1, x2, y2, context_object.attr('id')+'-path', color, size, style);
            $(".pointer",context_object).draggable({
                containment: '#layout',
                drag: function(event, ui) {
                    var sline = [];
                    sline.parent = $(this).parent('.line');
                    sline.id = sline.parent.attr('id') + '-path';
                    sline.top = sline.parent.find('.top');
                    sline.bottom = sline.parent.find('.bottom');
                    color = $('.line-color',sline.parent).val();
                    size = $('.line-size',sline.parent).val();
                    style = $('.line-style',sline.parent).val();
                    sline.top_pos = sline.top.position();
                    sline.bottom_pos = sline.bottom.position();
                    draw_line( (sline.top_pos.left + line_overhead), 
                    (sline.top_pos.top + line_overhead), 
                    (sline.bottom_pos.left + line_overhead), 
                    (sline.bottom_pos.top + line_overhead), sline.id, color, size, style);
                },
                stop: function() {
                    var sline = [];
                    sline.parent = $(this).parent('.line');
                    sline.top = sline.parent.find('.top');
                    sline.bottom = sline.parent.find('.bottom');

                    sline.top_pos = sline.top.position();
                    sline.bottom_pos = sline.bottom.position();
                    $('.its-top',sline.parent).val((sline.top_pos.top + line_overhead));
                    $('.its-left',sline.parent).val((sline.top_pos.left + line_overhead));
                    $('.its-width',sline.parent).val((sline.bottom_pos.left + line_overhead));
                    $('.its-height',sline.parent).val((sline.bottom_pos.top + line_overhead));
                    set_btn_save_report_enabled(true);
                }        
            });
            $(".pointer",context_object).dblclick(function() {
                line_object = $(this);
                var stack = [];
                stack.pos = line_object.position();
                stack.form = line_object.parent('.line').find('.form');
                stack.form.css({top: stack.pos.top+7,left:stack.pos.left+7});
                stack.buffer = $('.its-top',stack.form).val()+'-'+$('.its-left',stack.form).val()+'-'+
                    $('.its-width',stack.form).val()+'-'+$('.its-height',stack.form).val()+'-'+
                    $('.line-color',stack.form).val()+'-'+$('.line-size',stack.form).val()+'-'+
                    $('.line-style',stack.form).val();
                $('.item-buffer',stack.form).val(stack.buffer);
                line_object.parent('.line').find('.pointer').draggable( "disable" );
                stack.form.show();
            });
			
			/** to be removed as colorpicker.js is not included , to be used dhtmlxColorpicker
            //colorpicker for custom field
            $('#'+context_object.attr('id')+'-picker').ColorPicker({
                onSubmit : function (hsb, hex, rgb, el) {
                    var picker_id = '#' + $(el).attr('id');
                    $(picker_id).val('#' + hex);
                    $(picker_id).css('background', '#' + hex);
                    $(picker_id).css('color', '#' + hex);
                    $(picker_id).ColorPickerHide();
                },
                onBeforeShow : function() {
                    $(this).ColorPickerSetColor(this.value);
                }
            }).bind('keyup', function() {
                $(this).ColorPickerSetColor(this.value);
            }).addClass('has-colorpicker'); 
            */
			
            //some ops
            $('.cancel-change', context_object).click(function() {
                prev_stack = $('.item-buffer', context_object).val();
                prev_stack = prev_stack.split('-');
                $('.its-top',context_object).val(prev_stack[0]);
                $('.its-left',context_object).val(prev_stack[1]);
                $('.its-width',context_object).val(prev_stack[2]);
                $('.its-height',context_object).val(prev_stack[3]);
                $('.line-color',context_object).val(prev_stack[4]);
                $('.line-size',context_object).val(prev_stack[5]);
                $('.line-size',context_object).css({background: prev_stack[5],color:prev_stack[5]});
                $('.line-style',context_object).val(prev_stack[6]);
                $('.item-buffer',context_object).val('');
                $('.form', context_object).hide();
                context_object.find('.pointer').draggable( "enable" );
            });

            $('.apply-change', context_object).click(function() {
                var stack = [];
                stack.item_id = $('.item-id',context_object).val();
                if(stack.item_id == ''){
                    stack.item_id = 'NULL';
                    stack.mode = 'i';
                }else{
                    stack.mode = 'u';
                }
                stack.page_id = get_txt_page_id_value();
                stack.process_id = get_txt_process_id_value();
                stack.top =   $('.its-top',context_object).val();
                stack.left =   $('.its-left',context_object).val();
                stack.width =   $('.its-width',context_object).val();
                stack.height =   $('.its-height',context_object).val();
                stack.color =   $('.line-color',context_object).val();
                //remove # from color
                stack.color = stack.color.substring(1);
                stack.size =   $('.line-size',context_object).val();
                stack.style =   $('.line-style',context_object).val();
                var sp_url = php_path + 'spa_rfx_report_page_line_dhx.php?useGridLabels=false&flag=' + stack.mode +
                            '&process_id=' + stack.process_id +
                            '&session_id=' + session_id + '&' + getAppUserName() +
                            '&report_page_line_id=' + stack.item_id +
                            '&page_id=' + stack.page_id +
                            '&top=' + stack.top +
                            '&left=' + stack.left +
                            '&width=' + stack.width +
                            '&height=' + stack.height +
                            '&color=' + stack.color +
                            '&size=' + stack.size +
                            '&style=' + stack.style ;
                var result = adiha_CreateMessageBox('info', '', '', sp_url);
                if (result[3] == 'Success') {
                    if (stack.mode == 'i') {
                        $('.item-id', context_object).val(result[5]);
                    }
                    draw_line(stack.left, stack.top, stack.width, stack.height, context_object.attr('id')+'-path', stack.color, stack.size, stack.style);
                    $('.form', context_object).hide();
                    context_object.find('.pointer').draggable( "enable" );
                }

            });
        }
        function register_auto_image(context_object, item) {
            var process_id = get_txt_process_id_value();
            var image_object = $('.auto-image', context_object);
            context_object.css('width', '0px');
            context_object.css('height', '0px');

            if (item) {
                var default_image = '<?php echo $app_php_script_loc; ?>/dev/report.image.php?session_id=' + session_id + '&' + getAppUserName() + '&process_id=' + process_id + '&image_id=' + item[0] + '&cache_remover=' + Math.random();
                $('img.label', image_object).attr('src', default_image);
                $('img.label', image_object).css('width', 'auto');

            }

            $('img.label', image_object).dblclick(function() {
                if (get_txt_page_id_value() == 'NULL') {
                    adiha_CreateMessageBox('alert', get_message('PAGE_NOT_SAVED'));
                    return false;
                }

                if ($('.more-options', image_object).css('display') == 'none') {
                    $('img.label', image_object).hide();
                    $('.more-options', image_object).show();
                    $('.less-options', image_object).hide();
                }
            });

            update_wh(context_object);

            $('.cancel-change', image_object).click(function() {
                $('.more-options', image_object).hide();
                $('img.label', image_object).show();
            });

            $('.apply-change', image_object).click(function() {
                var filename = $('.image-picker', image_object).val();

                if (filename == '') {
                    adiha_CreateMessageBox('alert', get_message('IMAGE_NOT_SELECTED'));
                    return false;
                }

                filename = filename.split("\\");
                filename = filename[(filename.length - 1)];
                var file_ext = filename.split('.');
                file_ext = file_ext[file_ext.length - 1];


                if (_.indexOf(accepted_img_extensions, file_ext) == -1) {
                    adiha_CreateMessageBox('alert', get_message('INVALID_IMAGE_TYPE'));
                    return false;
                }

                var form_name = $(this).parents('form.image-form').eq(0).attr('name');
                var image_parent_id = $(this).parents('div.report-item').eq(0).attr('id');
                var file_input_name = $('.image-picker', image_object).attr('name');
                var width = $('.its-width', image_object).val();
                var height = $('.its-height', image_object).val();
                var top = $('.its-top', image_object).val();
                var left = $('.its-left', image_object).val();
                var item_id = $('.item-id', image_object).val();
                var page_id = get_txt_page_id_value();
                var process_id = get_txt_process_id_value();
                var mode = (item_id != '') ? 'u' : 'i';

                if (item_id == '')
                    item_id = 'NULL';

                var sp_url = '<?php echo $app_php_script_loc; ?>' + 'spa_rfx_report_page_image_dhx.php?flag=' + mode +
                            '&process_id=' + process_id +
                            '&session_id=' + session_id + '&' + getAppUserName() +
                            '&report_page_image_id=' + item_id +
                            '&page_id=' + page_id +
                            '&filename=' + filename +
                            '&image_parent_id=' + image_parent_id +
                            '&extension=' + file_ext +
                            '&file_input_name=' + file_input_name +
                            '&width=' + width +
                            '&height=' + height +
                            '&top=' + top +
                            '&left=' + left;
                //eval used to prepare dynamic name of form at runtime
                eval("document." + form_name + ".method='post';");
                eval("document." + form_name + ".target='f1';");
                eval("document." + form_name + ".action='" + sp_url + "';");
                eval("document." + form_name + ".submit();");

            });
        }

        function refresh_image_item(div_id, recommendation, width, height) {
            var context_object = $('#' + div_id);
            var image_object = $('.auto-image', context_object);
            var process_id = get_txt_process_id_value();
            $('.item-id', image_object).val(recommendation);
            $('img.label', image_object).attr('src', '<?php echo $app_php_script_loc; ?>/dev/report.image.php?session_id=' + session_id + '&' + getAppUserName() + '&process_id=' + process_id + '&image_id=' + recommendation + '&cache_remover=' + Math.random());
            $('img.label', image_object).css('width', 'auto');
            $('img.label', image_object).show();
            $('.more-options', image_object).hide();
            $('.less-options', image_object).show();
            context_object.css('width', width);
            context_object.css('height', height);
            update_wh(context_object);
        }

        $(function() {
            var report_items = <?php echo $report_items_jsoned ?>;
            update_layout();
            
            //hideHourGlass();
            //refresh_grid_paramset();
            var report_item_part = _.template($('#report-part-form').html());
            var report_item_part_textbox = _.template($('#report-part-form-textbox').html());
            var report_item_part_image = _.template($('#report-part-form-image').html());
            var report_item_part_line = _.template($('#report-part-form-line').html());
            //$("#report-items span").draggable({
                //helper: "clone"
            //});
            
            $('#layout-container').resizable({
                handles: 'se,e,s',
                disabled: true,
                alsoResize: "#layout"
            });
            $('#div_controls_main input').change(function() {
                set_btn_save_report_enabled(true);
            });

            function register_report_items(d_content, prefix_report_item, link_id, item_type, item, pos) {
                var js_object = false;
                switch (item_type) {
                    case '1':case 1:
                        prefix_report_item += 'chart-';
                        prefix_report_item += link_id;
                        $("#layout").append(report_item_part({
                            img: 'Chart',
                            id_prefix: prefix_report_item,
                            item_pk: (item) ? item[0] : '',
                            item_type: '1',
                            item_name: (item) ? item[2] : ''
                        }));
                        js_object = $("#" + prefix_report_item);
                        break;
                    case '2':case 2:
                        prefix_report_item += 'tablix-';
                        prefix_report_item += link_id;
                        $("#layout").append(report_item_part({
                            img: 'Tablix',
                            id_prefix: prefix_report_item,
                            item_pk: (item) ? item[0] : '',
                            item_type: '2',
                            item_name: (item) ? item[2] : ''
                        }));
                        
                        js_object = $("#" + prefix_report_item);
                        break;
                    case '3':case 3:
                        prefix_report_item += 'textbox-';
                        prefix_report_item += link_id;
                        $("#layout").append(report_item_part_textbox({
                            img: 'Textbox',
                            id_prefix: prefix_report_item,
                            item_pk: (item) ? item[0] : '',
                            item_type: '3',
                            item_name: (item) ? item[2] : ''
                        }));
                        js_object = $("#" + prefix_report_item);
                        register_auto_textbox(js_object, item);
                        break;
                    case '4':case 4:
                        prefix_report_item += 'image-';
                        prefix_report_item += link_id;
                        var form_name = prefix_report_item.replace(/\b-\b/gi, '_');
                        $("#layout").append(report_item_part_image({
                            img: 'Image',
                            id_prefix: prefix_report_item,
                            form_name: form_name,
                            item_pk: (item) ? item[0] : '',
                            item_type: '4',
                            item_name: (item) ? item[2] : ''
                        }));
                        js_object = $("#" + prefix_report_item);
                        register_auto_image(js_object, item);
                        break;

                    case '5':case 5:
                        prefix_report_item += 'gauge-';
                        prefix_report_item += link_id;
                        $("#layout").append(report_item_part({
                            img: 'Gauge',
                            id_prefix: prefix_report_item,
                            item_pk: (item) ? item[0] : '',
                            item_type: '5',
                            item_name: (item) ? item[2] : ''
                        }));
                        js_object = $("#" + prefix_report_item);
                        break;
                    case '6':case 6:
                        prefix_report_item += 'line-';
                        prefix_report_item += link_id;
                        var sline = [];
                        if (!item) {
                            //we give a 100px straight line incase its new
                            sline.y1 = pos.top + line_overhead;
                            sline.x1 = pos.left + line_overhead;
                            sline.x2 = sline.x1 + 100;
                            sline.y2 = sline.y1;
                            sline.color = "#666666";
                            sline.size = '1';
                            sline.style = 'Solid';
                        } else {//we give as per item
                            sline.y1 = item[3];
                            sline.x1 = item[4];
                            sline.x2 = item[5];
                            sline.y2 = item[6];
                            sline.color = item[2];
                            sline.size = item[7];
                            sline.style = item[8];
                        }
                        $("#layout").append(report_item_part_line({
                            id_prefix: prefix_report_item,
                            img: 'Line',
                            item_pk: (item) ? item[0] : '',
                            y1: sline.y1,
                            x1: sline.x1,
                            x2: sline.x2,
                            y2: sline.y2,
                            color: sline.color,
                            size: sline.size,
                            style: sline.style
                        }));
                        js_object = $("#" + prefix_report_item);
                        register_auto_line(js_object, item, sline);
                        break;
                }
                if (item_type != '6') {
                    if (!item) {
                        js_object.css({
                            'top': pos.top,
                            'left': pos.left
                        });
                    }
                    //console.log(js_object);
                    
                    $(js_object).draggable({
                        grid: [2, 2],
                        //revert: false,
                        revert: function(is_valid_drop) {
                            
                            if(is_valid_drop === false) {
                                js_object.css({
                                    'top': 0,
                                    'left': 0
                                });
                            }
                            
                        },  
                        scroll: true,
                        snap: true,
                        snapMode: "outer",
                        snapTolerance: 5,
                        stop: function() {
                            update_wh(js_object);
                        }
                    });
                    
                    
                }
                if (item_type != '4' && item_type != '6') {
                    $(js_object).resizable({
                        grid: 2,
                        containment: 'parent',
                        stop: function() {
                            update_wh(js_object);
                        }
                    });
                }
                return js_object;
            }
            
            
            $("#layout").droppable({
                drop: function() {
                    
                },
                tolerance: 'fit'
            });
            

            //update_layout();
            //register canvas,
            var pos_layout = $('#layout').position();
            paper = new Raphael(pos_layout.left, pos_layout.top, $('#layout').width(), $('#layout').height());
            //restore if data found
            if (report_items.length > 0) {
                item_id_list = new Array();
                _.each(report_items, function(item) {
                    var d_content = $('#report-item-' + item[1]).html();
                    item_id_list.push(item[0]);
                    var prefix_report_item = 'link-report-';
                    var link_id = 'old-' + item[0];
                    var item_type = item[1];
                    //alert(d_content + ':'+ prefix_report_item + ':'+ link_id + ':'+ item_type + ':'+ item);
                    var js_object = register_report_items(d_content, prefix_report_item, link_id, item_type, item);
                    //update dimension & position
                    if(item_type != '6'){
                        js_object.width(parseFloat(item[5]) * ppi);
                        js_object.height(parseFloat(item[6]) * ppi);
                        js_object.css({
                            'top': parseInt(parseFloat(item[3]) * ppi),
                            'left': parseInt(parseFloat(item[4]) * ppi)
                        });
                        $('.its-top', js_object).val(item[3]);
                        $('.its-left', js_object).val(item[4]);
                        $('.its-width', js_object).val(item[5]);
                        $('.its-height', js_object).val(item[6]);
                        update_wh(js_object, true);
                    }
                });
                parent.div_obj.attr('item_id', item_id_list.join(','));
            }

            if (report_privilege_type == 'a') {
                $('.to_disable :input').attr('disabled', true);
                $('#report-items span').draggable('disable');
                $('#layout').droppable('disable');
                $('#layout .report-item').resizable('disable');
                $('#layout .report-item a').attr('onclick', '');
                $('#layout .report-item a').click(function(e) {
                    e.preventDefault();
                });
            }
            $('html').css({'overflow-y': 'scroll'});
            
            //temporarily made hidden
            $('svg').hide();
            
            
            
            /* later added code */ 
            //$('#test_drag').draggable();
            new dhtmlDragAndDropObject();
            function s_control(){
                this._drag=function(sourceHtmlObject,dhtmlObject,targetHtmlObject, targetObject){
                    targetHtmlObject.style.backgroundColor="";
                    var ri_info_obj = {
                        item_id: '',
                        top: 0,
                        left: 0,
                        width: 10,
                        height: 10,
                        item_type: sourceHtmlObject.parentObject.id,
                        page_id: page_id,
                        page_name: page_name,
                        dataset_id: '<?php echo $dataset_id; ?>'
                    };
                    var param_obj = {
                        process_id: process_id_gbl,
                        item_flag: 'i',
                        ri_info_obj: ri_info_obj
                    };
                    fx_open_report_item_detail(param_obj);
                    //fx_add_report_item(sourceHtmlObject.parentObject.id);
                }
                
                this._dragIn=function(htmlObject,shtmlObject,targetHtmlObject, targetObject){
                    htmlObject.style.backgroundColor="#fffacd";
                    return htmlObject;
                }
                
                this._dragOut=function(htmlObject){
                    htmlObject.style.backgroundColor="";
                    return this;
                }
            }
            function setDragLanding(){
             var sinput= document.body;
             parent.parent.parent.tree_sources.dragger.addDragLanding(sinput, new s_control);
            }
            setDragLanding();
            //function to add item on layout canvas
            fx_add_report_item = function(item, item_arr) {
                if(item.indexOf('report-item') > -1 && item != 'report-item-6') {
                    var ui = $('#' + item);
                    var d_content = ui.html();
                    //grab drop position
                    var pos = {};
                    pos.left = ui.position.left - $("#layout").offset().left;
                    pos.top = ui.position.top - $("#layout").offset().top;
                    //console.log(pos);
                    d_content = d_content.toLowerCase();
                    //this has to be done as once items are inside the system we dont need to append them; they just move via sort
                    if (d_content.search('<div') == -1) {
                        var prefix_report_item = 'link-report-';
                        var link_id = _.uniqueId('new-');
                        var item_type = ui.attr('item_type');
                        var js_object = register_report_items(d_content, prefix_report_item, link_id, item_type, item_arr, pos);
                        if(item_type !='6')
                            update_wh(js_object);
                        
                    }
                    
                }
            };
            //function to open report item detail window
            fx_open_report_item_detail = function(param_obj) {
                //param_obj.ri_info_obj.page_id = page_id;
                window_ri = parent.parent.parent.dhx_wins.createWindow({
                    id: 'window_ri'
                    ,modal: true
                    ,resize: true
                    ,text: get_locale_value('Report Item Detail')
                    ,center: true
                    ,width: 1100
                    ,height: 500
                    
                });
                var post_params = {
                    process_id: param_obj.process_id,
                    item_flag: param_obj.item_flag,
                    report_id: report_id,
                    ri_info_obj: JSON.stringify(param_obj.ri_info_obj)
                };
                
                var report_item_url = '';
                switch(param_obj.ri_info_obj.item_type) {
                    case 'report-item-1': //chart
                        report_item_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.chart.php';
                        window_ri.attachURL(report_item_url, null, post_params);
                        break;
                    case 'report-item-2': //tablix
                        report_item_url = app_form_path + '_reporting/report_manager_dhx/report.manager.dhx.tablix.php';
                        window_ri.attachURL(report_item_url, null, post_params);
                        break;
                    case 'report-item-3': //text
                        var item_arr = new Array();
                        var item_id = 'NULL';
                        var item_name = '';
                        item_arr.push(item_id, item_name);
                        window_ri.close();
                        fx_add_report_item(param_obj.ri_info_obj.item_type, false);
                        break;
                    case 'report-item-4': //image
                        console.log('*** image drag ***');
                        break;
                }
                
            } 
            
            //function to set item name on draggable item
            fx_set_item_name = function(report_item_id, item_name) {
                $('.its-name', $('#' + report_item_id)).text(item_name);
            }
            
        });
        
        //ajax setup for default values
        $.ajaxSetup({
            method: 'POST',
            dataType: 'json',
            error: function(jqXHR, text_status, error_thrown) {
                console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
            }
        });
      
    
    
</script>
<script id="report-part-form" type="text/template">
    <div id="<%= id_prefix%>" class="report-item blotter class-trm-report-item">
    <table height="100%" width="100%" border="0" class="data-table data-table-hoverless" cellpadding="5" cellspacing="0">
            <tr valign="top">
                <td>
                    <table>
                        <tr class='header'>
                       
                            <td><%= img%></td>
                            <td>
                            
                                <span class="its-name"><%= item_name%></span>
                                <input type="hidden" class="item-id" value="<%= item_pk%>" />
                                <input type="hidden" class="item-type" value="<%= item_type%>" />
                                <input type="hidden" class="its-top" value="" />
                                <input type="hidden" class="its-left" value="" />
                           
                               
                            </td>
                            
                        </tr>

                        <tr class='itemlist'>
                            <td><label class="FormLabelL"><?php echo get_locale_value('Dimension', true); ?></label></td>
                            <td>
                                <input type="text" size="2" class="its-width adiha_control" />
                                <input type="text" size="2" class="its-height adiha_control" />
  

    <a class='change-btn' id="<%= id_prefix%>-update" href="javascript:void(0);" onclick="update_report_item_form(this)"><i class="fa fa-retweet" aria-hidden="true"></i><span class='btn-text'><?php echo get_locale_value('Change', false); ?></span></a>
                            </td>
                        </tr>
                        <tr class='itemlist'>
                            <td><label class="FormLabelL"><?php echo get_locale_value('Location', true); ?></label></td>
                            <td>
                                (<span class="its-top-show"></span>,<span class="its-left-show"></span>)
                            </td>
                        </tr>


                        <tr class='itemlist'>
                          

                                <td>
                                         <div class='trm-report-item-action-button'>

    <a id="<%= id_prefix%>-edit" href="javascript:void(0);" onclick="open_report_item_form(this)">
<i class="fa fa-pencil" aria-hidden="true"></i>
    <!-- <?php echo get_locale_value('Update', false); ?> -->

    </a>
	         <a id="<%= id_prefix%>-delete" href="javascript:void(0);" onclick="remove_report_item(this)">
<i class="fa fa-trash-o" aria-hidden="true"></i>
         <!-- <?php echo get_locale_value('Delete', false); ?> -->

         </a>
   </div>
                                </td>


                        </tr>


                    </table>
                </td>
            </tr>    
        </table> 
   
    </div>
</script>
<script id="report-part-form-textbox" type="text/template">
    <div id="<%= id_prefix%>" class="report-item clean auto-textbox-blotter">
        <div class="auto-textbox">
            <span class="label"><?php echo $default_tbx_caption; ?></span>
            <textarea class="textbox"></textarea>
    <table height="100%" width="100%" border="0" class="data-table more-options data-table-hoverless" cellpadding="5" cellspacing="0" style="display:none;">
                <tr valign="top">
                    <td rowspan="3"><%= img%></td>
                    <td>
                        <div style="display: none;">
                            <span class="its-top-show"></span>,<span class="its-left-show"></span>
                            <input type="text" size="2" class="its-width adiha_control" />
                            <input type="text" size="2" class="its-height adiha_control" />
                            <input type="hidden" class="item-id" value="<%= item_pk%>" />
                            <input type="hidden" class="item-type" value="<%= item_type%>" />
                            <input type="hidden" class="its-top" value="" />
                            <input type="hidden" class="its-left" value="" />
                        </div>
                        <select class="adiha_control font-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_option as $font): ?>
                                <option value="<?php echo $font[0] ?>"><?php echo $font[1] ?></option>
                            <?php endforeach; ?>
                        </select>
                        <select class="adiha_control font-size-list context-form-item">
                            <option value=""></option>
                            <?php foreach ($rdl_column_font_size_option as $font_size): ?>
                                <option value="<?php echo $font_size[0] ?>"><?php echo $font_size[1] ?></option>
                            <?php endforeach; ?>
                        </select>
                    </td>
                </tr> 
                <tr>
                    <td align="right">
                        <label style="display: inline-block"><input type="checkbox" value="1" class="bold-checkbox context-form-item" /><b>B</b></label>
                        <label style="display: inline-block"><input type="checkbox" value="1" class="italic-checkbox context-form-item" /><b><i>I</i></b></label>
                        <label style="display: inline-block"><input type="checkbox" value="1" class="underline-checkbox context-form-item" /><b><u>U</u></b></label>
                    </td>
                </tr>
                <tr>
                    <td align="right">
    <a id="<%= id_prefix%>-cancel" class="cancel-change" href="javascript:void(0);" ><span class="icons r-icon-cancel"></span><?php echo get_locale_value('Cancel', false); ?></a> 
    <a id="<%= id_prefix%>-delete" href="javascript:void(0);" onclick="remove_report_item(this)"><span class="icons r-icon-delete"></span><?php echo get_locale_value('Delete', false); ?></a> 
    <a id="<%= id_prefix%>-edit" class="apply-change" href="javascript:void(0);"><span class="icons r-icon-save"></span><?php echo get_locale_value('Save', false); ?></a>
                    </td>
                </tr>    
            </table>
        </div>
    </div>
</script>
<script id="report-part-form-image" type="text/template">
    <div id="<%= id_prefix%>" class="report-item clean">
        <form enctype="multipart/form-data" class="image-form" id="<%= form_name%>_appform" name="<%= form_name%>_appform">
            <div class="auto-image">
                <img class="label" src="<?php echo $app_php_script_loc; ?>/adiha_pm_html/process_controls/imageitem.jpg"  />
    <table height="100%" width="100%" border="0" class="data-table more-options data-table-hoverless" cellpadding="5" cellspacing="0" style="display:none;">
                    <tr valign="top">
                        <td>
                            <div style="display: none;">
                                <%=img%>
                                <span class="its-top-show"></span>,<span class="its-left-show"></span>
                                <input type="hidden" class="item-id" value="<%= item_pk%>" />
                                <input type="hidden" class="its-top" value="" />
                                <input type="hidden" class="its-left" value="" />
                                <label class="FormLabelL"><?php echo get_locale_value('Dimension', true); ?></label>
                                <input type="text" size="2" class="its-width adiha_control" />
                                <input type="text" size="2" class="its-height adiha_control" />
                                <a id="<%= id_prefix%>-update" href="javascript:void(0);" onclick="update_report_item_form(this)"><?php echo get_locale_value('change', false); ?></a>
                            </div>
                            <input type="file" class="image-picker" name="image_picker"/>
                        </td>
                    </tr>    
                    <tr>
                        <td align="right">
    <a id="<%= id_prefix%>-cancel" class="cancel-change" href="javascript:void(0);" ><span class="icons r-icon-cancel"></span><?php echo get_locale_value('Cancel', false); ?></a>  
    <a id="<%= id_prefix%>-delete" href="javascript:void(0);" onclick="remove_report_item(this)"><span class="icons r-icon-delete"></span><?php echo get_locale_value('Delete', false); ?></a>  
    <a id="<%= id_prefix%>-edit" class="apply-change" href="javascript:void(0);"><span class="icons r-icon-save"></span><?php echo get_locale_value('Upload', false); ?></a>
                        </td>
                    </tr>
                </table>
            </div>
        </form>
    </div>
</script>
<script id="report-part-form-line" type="text/template">
    <div class="line report-item clean" id="<%=id_prefix%>">
        <div class="top pointer" style="left:<%=x1%>px;top: <%=y1%>px;" ><!--<div><div!--></div>
        <div class="bottom pointer" style="left:<%=x2%>px;top: <%=y2%>px;" ><!--<div><div!--></div>
        <div class="form" style="display: none;">
            <input type="hidden" class="item-buffer" value="" />
            <input type="hidden" class="item-id" value="<%= item_pk%>" />
            <input type="hidden" class="its-top" value="<%= y1%>" />
            <input type="hidden" class="its-left" value="<%= x1%>" />
            <input type="hidden" class="its-width" value="<%= x2%>" />
            <input type="hidden" class="its-height" value="<%= y2%>" />
    <table height="100%" width="100%" border="0" class="data-table data-table-hoverless" cellpadding="5" cellspacing="0">            
                <tr>
                    <td rowspan="2"><%= img%></td>
                    <td>Color</td>     
                    <td><input type="text" class="adiha_control small-form-element line-color" style="color:<%=color%>;background: <%=color%>;" id="<%=id_prefix%>-picker" value="<%=color%>" /></td>    
                    <td>Size</td>     
                    <td>
                        <select class="adiha_control line-size">
                            <?php foreach ($rdl_column_line_size as $line_size): ?>
                                <option value="<?php echo $line_size[0] ?>" <%if (size == "<?php echo $line_size[0] ?>") {print("selected")} %> ><?php echo $line_size[1] ?></option>
                            <?php endforeach; ?>
                        </select>   
                    </td>     
                </tr>        
                <tr>
                    <td>Style</td>     
                    <td colspan="4">
                        <select class="adiha_control line-style">
                            <?php foreach ($rdl_column_line_style as $line_style): ?>
                                <option value="<?php echo $line_style[0] ?>" <%if (style == "<?php echo $line_style[0] ?>") {print("selected")} %> ><?php echo $line_style[1] ?></option>
                            <?php endforeach; ?>
                        </select>         
                    </td>    
                </tr>
                <tr>
                    <td colspan="5" align="right">
    <a id="<%= id_prefix%>-cancel" class="cancel-change" href="javascript:void(0);" ><span class="icons r-icon-cancel"></span><?php echo get_locale_value('Cancel', false); ?></a>  
    <a id="<%= id_prefix%>-delete" href="javascript:void(0);" onclick="remove_report_item(this)" ><span class="icons r-icon-delete"></span><?php echo get_locale_value('Delete', false); ?></a>  
    <a id="<%= id_prefix%>-edit" class="apply-change" href="javascript:void(0);" ><span class="icons r-icon-save"></span><?php echo get_locale_value('Save', false); ?></a>
                    </td>
                </tr>
            </table>            

        </div>
    </div>  
</script>
  
    