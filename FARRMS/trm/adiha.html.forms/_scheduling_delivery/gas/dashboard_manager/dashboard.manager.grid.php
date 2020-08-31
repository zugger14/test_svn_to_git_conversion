<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<body>
    <?php 
    include '../../../../adiha.php.scripts/components/include.file.v3.php'; 
    
    $dashboard_template_id = get_sanitized_value($_POST['dashboard_template_id']);
    $term_start = get_sanitized_value($_POST['term_start']);
    $next_hour = get_sanitized_value($_POST['next_hour']);
    $current_hour = get_sanitized_value($_POST['current_hour']);
    ?>
    <div class="component-container-grid">
        <?php
        echo adiha_dhtmlx_grid('grd_dashboard_manager', '', '1430px', '455px', '', '', true, 'Insert', 'Delete', false, 25,'2,3,4,5', '', 'dashboard_onload',true,false, '', '', false, false, '', true);
        ?>
    </div>
</body>
</html>
<script>
    var grouping_header = '';
    var non_calc_col = 6;
    var dashboard_template_id = '<?php echo $dashboard_template_id; ?>';
    var term_start = '<?php echo $term_start; ?>';
    var next_hour = '<?php echo $next_hour; ?>';
    var current_hour = '<?php echo $current_hour; ?>';
    
    $(document).ready(function(){
        data = {"action": "spa_dashboard_manager",
                "flag": "s",
                "dashboard_template_id": dashboard_template_id,
                "term_start": term_start,
                "next_hour": next_hour,
                "current_hour": current_hour
                };
        var each_column_length = get_column_length();
        grid_grd_dashboard_manager_refresh(data, true, '2,3,4,5', each_column_length, true, false);
    });
    
    /*
    cell(i,2) - Datatype
    cell(i,3) - Editable or not
    cell(i,4) - Formula
    cell(i,5) - Max capacity of Generator
    */
    
    /* Onload function */
    /* Find the row and column need to be subtotal and pass in the function grid_grd_dashboard_manager_subtotal*/
    function dashboard_onload() {
		$('#grd_dashboard_manager').css('visibility','hidden');			
        set_grouped_header();
        remove_repeat_category();
        value_replace();
        colorize_grd_dashboard_manager();
        set_subtotal();
        set_row_editable();     
        check_max_capacity();       
        $('#grd_dashboard_manager').css('visibility','visible');
        
        /**
         * Function called when the value in the cell is changed.
         * Convert input formula into maths formula to sum the input cells
         * Eg: !1+2+3 for 4th column --> =[[1,4]]+[[2,4]]+[[3,4]]
         */
        grid_grd_dashboard_manager.attachEvent("onCellChanged",function(row_id,col_id,value){ 
            var row_id = row_id;
            var col_id = col_id;
            var set_col = col_id;
            var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
            var max_col = grid_grd_dashboard_manager.getColLabel(no_of_cols - 1, 1);
            var datatype = grid_grd_dashboard_manager.cells(row_id,2).getValue();
            var sel_col = grid_grd_dashboard_manager.getColLabel(col_id, 1);
            var count_24hr =  parseInt((no_of_cols - 6)/24);
            var max_24hr = count_24hr * 24 + 6;
            
            var value = value;
            if (value[0] == "!" && value[1] == "!") {
                var new_value = value.replace(/!/g, '');
                grid_grd_dashboard_manager.cells(row_id,col_id).setValue(new_value);
            } else if(value[0] == "!") {
                var new_value = "=";
                for(var i = 1; i < value.length; i++) {
                    if(value[i] == "+" || value[i] == "*" || value[i] == "/") {
                        var n_val = grid_grd_dashboard_manager.cells(value[i+1],col_id).getValue();
                        var p_val = grid_grd_dashboard_manager.cells(value[i-1],col_id).getValue();
                        if (n_val != "-" && p_val != "-" && n_val != "" && p_val != "") {
                            new_value = new_value + "," + col_id + "]]" + value[i];
                        }
                    } else {
                        if (grid_grd_dashboard_manager.cells(value[i],col_id).getValue() != "" && grid_grd_dashboard_manager.cells(value[i],col_id).getValue() != "-") {
                            new_value = new_value + "[[";
                            new_value = new_value + value[i];
                        }
                    }
                }
                new_value = new_value + "," + col_id + "]]";
                grid_grd_dashboard_manager.cells(row_id,col_id).setValue(new_value);
            } else if (datatype == '27305') { //Copy the cell value in what if data type
                
                if (sel_col == '24') {
                    return;
                }
                    
                if (sel_col == max_col && set_col > max_24hr) {
                    return;
                }

                grid_grd_dashboard_manager.cells(row_id, parseInt(set_col)+1).setValue(value);
            }
            
            //Replace the value
            if(value == -9999) {
                grid_grd_dashboard_manager.cells(row_id, col_id).setValue("-");
            } else if(value == -1111) {
                grid_grd_dashboard_manager.cells(row_id, col_id).setValue("");
            }
            
            value = grid_grd_dashboard_manager.cells(row_id, col_id).getValue();
            
            //Colorize the cell 
            if (datatype == '27305') {
                if(value == '') {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:#FFFFC2;");
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id+1, "background-color:#FFFFC2;");
                } else if(value == '-') {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:#F05672;");
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id+1, "background-color:#F05672;");
                } else {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:none;");
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id+1, "background-color:none;");
                }
            } else { 
                if(value == '') {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:#FFFFC2;");
                } else if(value == '-') {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:#F05672;");
                } else {
                    grid_grd_dashboard_manager.setCellTextStyle(row_id, col_id, "background-color:none;");
                }
            }
            //value_replace();
            //colorize_grd_dashboard_manager(); 
        })
        
        set_formula_onload();
    }
    
    function set_subtotal() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
        var row_for_subtoal = new Array();
        var column_for_subtotal = new Array();
        
        for(var i = non_calc_col; i < no_of_cols; i++) {
            column_for_subtotal.push(i);
        }
        
        for (var i = 1; i <= no_of_rows; i++) {
            if(grid_grd_dashboard_manager.cells(i,2).getValue() == '27307') {
                grid_grd_dashboard_manager.setRowColor(i, "EDDE90");
                grid_grd_dashboard_manager_subtotal(row_for_subtoal, column_for_subtotal, i);
                row_for_subtoal = [];
            } else {
                row_for_subtoal.push(i);
            }
        }
    }
    
    function value_replace() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
        
        for (var i = 1; i <= no_of_rows; i++) {
            for (var j = non_calc_col; j < no_of_cols; j++) {
                if(grid_grd_dashboard_manager.cells(i,j).getValue() == -9999) {
                    grid_grd_dashboard_manager.cells(i, j).setValue("-");
                } else if(grid_grd_dashboard_manager.cells(i,j).getValue() == -1111) {
                    grid_grd_dashboard_manager.cells(i, j).setValue("");
                } 
            }
        }
    }
    
    function set_formula_onload() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
        
        for (var i = 1; i <= no_of_rows; i++) {
            if(grid_grd_dashboard_manager.cells(i,2).getValue() != '27307') {
                  if(grid_grd_dashboard_manager.cells(i,4).getValue() != 0) {
                        var value = grid_grd_dashboard_manager.cells(i,4).getValue();
                        for(var j = non_calc_col; j < no_of_cols; j++) {
                            grid_grd_dashboard_manager.cells(i, j).setValue('!' + value);
                        }  
                  }
            } 
        }
    }
    
    function set_grouped_header() {
        get_grouping_header();
        var grouping_header = grouping_header_global;
        var non_group_col = '0,1,2,3,4,5';
        var no_of_col = grid_grd_dashboard_manager.getColumnsNum();
        
        var col_header = new Array();
        for (i = 0; i < no_of_col; i++) {
            col_header.push(grid_grd_dashboard_manager.getColLabel(i));
        }
        
        var multiline_header = get_multiline_header(col_header, non_group_col, grouping_header);
        var multiline_attach_header = get_multiline_attach_header(col_header, non_group_col, grouping_header);
        var flter_list = get_filterlist(col_header); 
        
        grid_grd_dashboard_manager.detachHeader(0);
        grid_grd_dashboard_manager.attachHeader(multiline_header);
        grid_grd_dashboard_manager.attachHeader(multiline_attach_header);
    }
    
    /**
     * [get_multiline_header Get column name for the group header]
     * @string          [type]     headers [description]
     * @non_group_col   [type]     List of column having no multiline header [description]
     * @grouping_header [type]     List of the group headings
     * @return          [type]      
     */
    function get_multiline_header(string, non_group_col, grouping_header) {
        var spilited_header = new Array();
        spilited_header = string.toString().split(',');
        var spilited_group_header = new Array();
        
        spilited_group_header = grouping_header.split(',');
        var spilited_non_group_col = new Array();
        spilited_non_group_col = non_group_col.split(',');
        
        var header = new Array();
        var prev_col = '';
        var now_col;
        
        for (i = 0; i < spilited_header.length; i++) {
            if ($.inArray(i.toString(),spilited_non_group_col) == -1) {
                for (j = 0; j < spilited_group_header.length; j++) {
                    split_header = spilited_header[i].split(' ');
                    var split_header = split_header[0].toString().replace(/\//g,' ');
                    
                    if(split_header.search(spilited_group_header[j]) > -1) 
                        now_col = spilited_group_header[j];
                }
                
                if (prev_col == now_col) {
                    header.push('#cspan');
                } else {
                    header.push($.trim(now_col.replace(/ /g,'/')));
                }
                prev_col = now_col;
            } 
            else {
                header.push($.trim(spilited_header[i]));
            }
        }
        return header;
    }
    
        
    /**
     * [get_multiline_attach_header Get column name for the sub header]
     * @string          [type]     headers [description]
     * @non_group_col   [type]     List of column having no multiline header [description]
     * @grouping_header [type]     List of the group headings
     * @return          [type]      
     */
    function get_multiline_attach_header(string, non_group_col, grouping_header) {
        var spilited_header = new Array();
        spilited_header = string.toString().split(',');
        var spilited_group_header = new Array();
        spilited_group_header = grouping_header.split(',');
        var spilited_non_group_col = new Array();
        spilited_non_group_col = non_group_col.split(',');
        
        var attach_header = new Array();
        var attach_header_item = '';
        
        for (i = 0; i < spilited_header.length; i++) {
            if ($.inArray(i.toString(),spilited_non_group_col) == -1) {
                
                for (j = 0; j < spilited_group_header.length; j++) {
                    if(spilited_header[i].search(spilited_group_header[j]) > -1) 
                        attach_header_item = $.trim(spilited_group_header[j]);
                        
                }
                var split_header = spilited_header[i].split(" ");
                attach_header.push($.trim(split_header[1]).substr(0, 2));
            } 
            else {
                attach_header.push("#rspan");
            }
        }
        return attach_header;
    }
    
    /* Make the row editable if it is enabled in option filter else read only */
    /* Always editable for custom datatype */
    function set_row_editable() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        
        for (var i = 1; i <= no_of_rows; i++) {
            if (grid_grd_dashboard_manager.cells(i,2).getValue() != '27306') {
                if((grid_grd_dashboard_manager.cells(i,3).getValue() == 'y') || (grid_grd_dashboard_manager.cells(i,2).getValue() == '27305')) {
                    //grid_grd_dashboard_manager.setRowExcellType(i,"ed");
                } else {
                    grid_grd_dashboard_manager.setRowExcellType(i,"ro");
                }
            }
        }
    }
    
    function get_grouping_header() {
        //var dashboard_template_id = dashboard_manager.filters_form.getItemValue('template_id');
//            var term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
//            var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
//            var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
//            
        data = {"action": "spa_dashboard_manager",
                "flag": "g",
                "dashboard_template_id": dashboard_template_id,
                "term_start": term_start,
                "next_hour": next_hour,
                "current_hour": current_hour
                };
    
        result = adiha_post_data('return_array', data, '', '', 'return_grouping_header', '', '');
    }
    
    function return_grouping_header(result) {
        grouping_header = result[0];
        grouping_header = grouping_header.toString().replace(/\//g,' ');
        grouping_header_global = grouping_header.toString();
    }
    
    /* Display the category name in first row and remove on the following rows if the category name is same */
    function remove_repeat_category() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var show_category;
        
        for (var i = 1; i <= no_of_rows; i++) {
            if(show_category == grid_grd_dashboard_manager.cells(i,0).getValue()) {
                grid_grd_dashboard_manager.cells(i,0).setValue(''); 
            } else {
                show_category = grid_grd_dashboard_manager.cells(i,0).getValue();
            }
        }
    }
    
    /* Get the length of the column */
    function get_column_length() {
        var next_hours = next_hour;
        var column_length = '116,120,120,120,120,120';
        
        for (i = 0; i < next_hours; i++) {
            column_length = column_length + ',50';
        }
        return column_length;
    }
    
    function get_filterlist(headers) {
		string = headers.toString().replace(/[^,]+/g, "#text_filter");
        return string;
	}
    
    function btn_save_click() {
        var template_name = 'What_if';
                
        var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var what_if_value = new Array();
        var what_if_date = new Array();
        var what_if_hour = new Array();
        var p_date;
          
        //Building the array of date, hour and volume of the what-if data type
        for (var i = non_calc_col; i < no_of_cols; i++) {
            if (grid_grd_dashboard_manager.getColLabel(i, 1) == '')
                what_if_date.push(p_date);
            else {
                what_if_date.push(grid_grd_dashboard_manager.getColLabel(i, 1));
                p_date = grid_grd_dashboard_manager.getColLabel(i, 0);
            }
            what_if_hour.push(grid_grd_dashboard_manager.getColLabel(i, 1));
        }
        
        for (var i = 1; i <= no_of_rows; i++) {
            if (grid_grd_dashboard_manager.cells(i,2).getValue() == '27305') {
                for (var j = non_calc_col; j < no_of_cols; j++) {
                    what_if_value.push(grid_grd_dashboard_manager.cells(i,j).getValue());   
                }
            }
        }
        
        var no_of_hours = what_if_hour.length;
        var row_id;
        
        //Save the Source Deal Header Hour
        var deal_hour_xml = '';
        deal_hour_xml = '<Root>';
        for (i = 0; i < no_of_hours; i++) {
            row_id = i + 1;
            
            deal_hour_xml = deal_hour_xml + '<PSRecordset  edit_grid0="' + row_id +'" edit_grid1="' + what_if_date[i] + '" edit_grid2="' + what_if_hour[i] + ':00" edit_grid3="0" edit_grid4="' + what_if_value[i] + '" edit_grid5="" edit_grid6=""></PSRecordset>'
        }
        deal_hour_xml = deal_hour_xml + '</Root>';
        
        data = {"action": "spa_dashboard_deal",
                "flag": "w",
                "template_name": template_name,
                "term_start": term_start,
                "next_hour": next_hour,
                "current_hour": current_hour,
                "deal_hour_xml": deal_hour_xml
                };
    
        result = adiha_post_data('alert', data, '', '', '', '', '');
        
//        var sp_url = 'spa_dashboard_deal.php?flag=w' +
//                         '&template_name=' + template_name +
//                         '&term_start=' + term_start +
//                         '&current_hour=' + current_hour +
//                         '&next_hour=' + next_hour +
//                         '&session_id=' + js_session_id;
//        
//        
//        document.form_power_schedule_dash_board.method = 'post';
//        document.form_power_schedule_dash_board.target = 'f1';
//        document.form_power_schedule_dash_board.deal_hour_xml.value = deal_hour_xml;
//        document.form_power_schedule_dash_board.action = js_php_path + sp_url;
//        document.form_power_schedule_dash_board.submit();
    }
    
    function check_max_capacity() {
        var no_of_rows = grid_grd_dashboard_manager.getRowsNum();
        var no_of_cols = grid_grd_dashboard_manager.getColumnsNum();
        var max_capacity;
        
        for (var i = 1; i <= no_of_rows; i++) {
            max_capacity = '';
            if (grid_grd_dashboard_manager.cells(i,2).getValue() == '27308') {
                max_capacity = grid_grd_dashboard_manager.cells(i,5).getValue();
                for (var j = non_calc_col; j < no_of_cols; j++) {
                    if(grid_grd_dashboard_manager.cells(i,j).getValue() == max_capacity && max_capacity != 0) {
                        grid_grd_dashboard_manager.setCellTextStyle(i, j, "background-color:#768EDB;");
                    }
                }
            }
        }
    }        
</script>
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>