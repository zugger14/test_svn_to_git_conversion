<?php
/**
* Generic portfolio mapping template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<body style="margin:0px;">
    <?php
    $function_id = get_sanitized_value($_POST['func_id']);
   
    $sub_book = $_POST['sub_book'];
    $filter = $_POST['book_filter'];
    $deals = $_POST['deals'];
    
    $is_tenor_enable = get_sanitized_value($_POST['is_tenor_enable'] ?? false ,'boolean');

    $component_portfolio_group = get_sanitized_value($_POST['req_portfolio_group'] ?? false ,'boolean'); 
    
    $namespace = 'generic_portfolio';
    $layout_name = 'generic_layout';
    $layout = new AdihaLayout();

    $layout_json = '[
                        {
                            id:       "a",
                            header:   true,
                            collapse: false,
                            text:     "Portfolio Hierarchy",
                            width:    300,
                            fix_size: [false,null]
                        },
                        {
                            id:       "b",
                            header:   true,
                            collapse: false,
                            text:     "Details",
                            fix_size: [false,null]
                        },
                        {
                            id:       "c",
                            header:   true,
                            collapse: false,
                            text:     "Deals",
                            fix_size: [false,null]
                        }
                    ]';
    echo $layout->init_layout($layout_name, '', '3L', $layout_json, $namespace);
    echo $layout->close_layout();
    ?>
    <div id="parentObj" style="margin:0px;"></div>
</body>
<script>
    var theme_selected = 'dhtmlx_' + default_theme;
    var portfolio_form_xml = '<Root><MappingXML ';
    var call_from_deal_ok = false;
    var func_id = "<?php echo $function_id;?>";

    $(function() {
        //attaching book structure
        var sub_book = "<?php echo $sub_book;?>";
        generic_portfolio.generic_layout.cells('a').attachURL("../run_at_risk/book.structure.template.php", null, {dataquery: sub_book, function_id: func_id});
        
        //attaching book filter
        var filter = "<?php echo $filter;?>";
        var is_tenor_enable = Boolean(<?php echo $is_tenor_enable;?>);
        var portfolio_group_enable = Boolean(<?php echo $component_portfolio_group;?>);
        generic_portfolio.generic_layout.cells('b').attachURL("../run_at_risk/run.risk.filters.php", null, {dataquery: filter, tenor_enable: is_tenor_enable, req_portfolio_group: portfolio_group_enable});
        
        //attaching deal selection template
        var deals = "<?php echo $deals;?>";
        generic_portfolio.generic_layout.cells('c').attachURL("../run_at_risk/deal.selection.template.php", null, {dataquery: deals});
    });
    /**
     *
     */
    generic_portfolio.get_portfolio_form_data = function() {
        var field_value_arr = [];
        var field_label_arr = [];
        var portfolio_form_xml = '<Root><MappingXML ';
        
        //book hierarchy data
        var book_ifr = generic_portfolio.generic_layout.cells('a').getFrame();
        var sub_book_id = book_ifr.contentWindow.book_structure.get_subbook();
        portfolio_form_xml += " " + 'sub_book_id' + "=\"" + sub_book_id + "\"";

        //save deal ids
        var deal_ifr = generic_portfolio.generic_layout.cells('c').getFrame();
        var deal_ids = deal_ifr.contentWindow.deal_selection.get_all_grid_cell_value(1);
        
        portfolio_form_xml += " " + 'deal_ids' + "=\"" + deal_ids + "\"";   

        //book filter data
        var book_filter_ifr = generic_portfolio.generic_layout.cells('b').getFrame();
        var book_filter_form_obj = book_filter_ifr.contentWindow.at_risk_filters.filter_form;
        var book_filter_data = book_filter_form_obj.getFormData();
        var status = validate_form(book_filter_form_obj);
        if(!status)
            return false;

        for (var a in book_filter_data) {
            field_label = a;

            if (book_filter_form_obj.getItemType(a) == "calendar") {
                field_value = book_filter_form_obj.getItemValue(a, true);
            } else {
                field_value = book_filter_data[a];
            }

            if (field_label == 'relative_term' && field_value == 'y') {
                field_value = 1;
            }
            if (field_label == 'relative_term' && field_value == 'n') {
                field_value = 0;
            }
            
            if (field_label == 'fixed_term' && field_value == 'y') {
                field_value = 1;
            }
            if (field_label == 'fixed_term' && field_value == 'n') {
                field_value = 0;
            }

            if (field_label == 'fixed_term') { 
                var fixed_term = field_value;
            }

            if (field_label == 'term_start') { 
                var term_start = field_value;
            }

            if (field_label == 'term_end') { 
                var term_end = field_value;
            }

            if (field_label == 'relative_term') { 
                var relative_term = field_value;
            }

            if (field_label == 'starting_month') { 
                var starting_month = field_value;
                field_value_arr.push(starting_month);
                field_label_arr.push(field_label);
            }

            if (field_label == 'no_of_month') { 
                var no_of_month = field_value;
                field_value_arr.push(no_of_month);
                field_label_arr.push(field_label);
            }

            if (fixed_term == "1") {
                if (term_start == "" && term_end == ""){
                    show_messagebox("<b>Tenor</b> cannot be empty.");
                    return false;
                }
            }
            if (relative_term == "1") {
                if (starting_month == "" && no_of_month == "") {
                    show_messagebox("<b>Tenor</b> cannot be empty.");
                    return false;
                }
            }
            if (term_start != '' && term_end != '') {
                if (Date.parse(term_start) >= Date.parse(term_end)) {
                    show_messagebox("<b>Term End</b> should be greater than <b>Term Start</b>.");
                    return false;
                }
            }

            portfolio_form_xml += " " + field_label + "=\"" + field_value + "\"";
        }

        if (relative_term == "1") {
            var status = check_numeric(field_value_arr, book_filter_form_obj, field_label_arr);
            if (!status) {
                parent.validation_status = false;
                return false;
            }
        }

        portfolio_form_xml += "></MappingXML></Root>";
        parent.validation_status = true;
        return portfolio_form_xml;
    }
    /**
     *
     */
    generic_portfolio.get_deal_frame = function() {
        var deal_ifr = generic_portfolio.generic_layout.cells('c').getFrame();
        return deal_ifr;
    }
    /**
     *
     */
    function check_numeric (value, form_obj, field_label) {
 
        var field_labels = "";
        for (i = 0 ; i < 2 ; i ++) {
            if(isNaN(value[i]) == true) {
                var lbl = form_obj.getItemLabel(field_label[i]);
                lbl = lbl.bold();
                field_labels += lbl + ", ";
                var numeric = true;
            }
        }
        field_labels = field_labels.slice(0, field_labels.length -2);
        if (numeric) {
            dhtmlx.alert({
                title:"Error",
                type:"alert-error",
                text:"Data should be numeric in " + "( " + field_labels + " )."
            });
            return false; 
        } else {
            return true;
        }
    }

    /**
     *
     */
    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }
    /**
     *
     */
    function collapse_on() {
        //collapse parent layout
        parent.global_layout_object.cells('a').collapse();
        //collapse template cells
        generic_portfolio.generic_layout.cells('a').collapse();
        generic_portfolio.generic_layout.cells('b').collapse();
    }
    /**
     *
     */
    function collapse_off() {
        //expand parent
        parent.global_layout_object.cells('a').expand();
        //expand template cells
        generic_portfolio.generic_layout.cells('a').expand();
        generic_portfolio.generic_layout.cells('b').expand();
    }
    
    function select_deal(col_list) {
        collapse_on();
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'run_mtm_process.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 0, 0);
        deal_win.setModal(true);
        
        var win_title = 'Select Deal';
        var win_url = '../../_deal_capture/maintain_deals/maintain.deals.new.php';  
        /*
        read_only: Default value is false. Set this to true to opens deal page in read only mode. In this mode user are allowed to select existing deals only.
        col_list: List of columns to be listed in grid
        deal_select_completed: Callback function name
        Note: Beside these parameters if extra parameters are added then they should be properly handled in maintain.deals.php
        */      
        var params = {read_only:true,col_list:col_list,deal_select_completed:'callback_select_deal'};
        
        deal_win.setText(win_title);
        deal_win.maximize();
        deal_win.attachURL(win_url, false, params);
        deal_win.attachEvent("onClose", function(win){
            if (!call_from_deal_ok) {
                confirm_messagebox('Are you sure to exit without selecting any deals?',
                    function(){
                        collapse_off();
                        call_from_deal_ok = true;
                        deal_win.close();
                    }
                    ,function(){
                        return false;
                    }    
                );
            } else {
                call_from_deal_ok = false;
                return true;
            }
        });
    }
    
    function callback_select_deal(result) {
        var deal_ifr = generic_portfolio.generic_layout.cells('c').getFrame();
        deal_ifr.contentWindow.deal_selection.callback_select_deal(result);
    }    
</script>