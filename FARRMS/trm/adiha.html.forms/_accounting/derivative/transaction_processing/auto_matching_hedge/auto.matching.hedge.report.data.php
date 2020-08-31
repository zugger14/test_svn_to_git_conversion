<?php
//$sql_php_call = convert_sp_to_php_call($sql);

$html_str .= get_html($sql);

//output HTML only incase of HTML export, Excel and PDF are handled by spa_html.php file itself.
//just dump all html tags in a var $html_str
if ((!$writeCSV) && (!$writeFile)) {
    echo $html_str;
}

//converts direct sp call to corresponding php call
//eg. exec spa_auto_matching_report @process_id... to spa_auto_matching_report.php?process_id=@process_id
function convert_sp_to_php_call($sp_sql) {
    $arr_params = explode(',', $sp_sql);
    $php_call = '';

    if (count($arr_params) > 0) {
        $arr_sp_name = explode(' ', $arr_params[0]);
        $php_call = $arr_sp_name[1] . '.php';
        
        $php_call .= '?process_id=' . str_replace("'", "", $arr_sp_name[2])
                    . '&v_curve_id=' . str_replace("'", "", $arr_params[1])
                    . '&h_or_i=' . str_replace("'", "", $arr_params[2])
                    . '&v_buy_sell=' . str_replace("'", "", $arr_params[3])
                    . '&user_name=' . str_replace("'", "", $arr_params[4])
                    . '&ref_id=' . str_replace("'", "", $arr_params[5]);
    }

    return str_replace(' ', '', $php_call);
}

//get the HTML output of the report
function get_html($sql) {
    global $app_php_script_loc, $app_user_name;
    //$xml_file = $app_php_script_loc . $sql . "&__user_name__=" . $app_user_name . "&use_grid_labels=true";
    $xml_file = "EXEC spa_source_book_mapping_clm";
    $resultset = readXMLURL2($xml_file);
    $group_1 = $resultset[0]['group1'];
    $group_2 = $resultset[0]['group2'];
    $group_3 = $resultset[0]['group3'];
    $group_4 = $resultset[0]['group4'];
    
    $return_value = readXMLURL($sql);
    $row_count = count($return_value);
    $html_str = "<body><table name='report_table' id='index_table' align='left' border='1' cellpadding='2' cellspacing='0' width='100%' bgcolor='#CCFFFF'>";
    $html_str .= "<tr valign='middle' align='left' bgcolor='#3FC380'>
    			<th align='center'><input name='chk_all_row_id' type='checkbox' onClick='toggle_check_all(this.checked)'></th>
                <th visibility: collapse style='display:none' >row_id</th>
                <th>Match</th>
                <th>Hedged Item Product</th>
                <th>Tenor</th>
                <th>Effective Date</th>
                <th>Deal Date</th>
                <th>Type</th>
                <th>Deal ID</th>
                <th>Deal Reference ID</th>
                <th>Volume Percent Available</th>
                <th>Volume Available</th>
                <th>Volume Match</th>
                <th>Percent Matched</th>
                <th>UOM</th>
                <th>$group_1</th>
                <th>$group_2</th>
                <th>$group_3</th>
                <th>$group_4</th>
                <th>Counterparty</th>
                <th visibility: collapse style='display:none'>process_id</th></tr>";
    $checkbox_id = 1;            
    for ($i = 0, $row_cnt = count($return_value); $i < $row_cnt; $i++) {
        //echo $i;
        if ($i == 0) {
            $html_str .= " <tr valign='middle' align='left'><td><input id='chk_row_id_$checkbox_id' name='chk_row_id[]' type='checkbox' onchange=chk_row_id_clicked('chk_row_id_$checkbox_id')></td>";
            
            for ($j = 0, $col_cnt = count($return_value["$i"]); $j < $col_cnt; $j++) {
                $val = $return_value["$i"]["$j"];
                
                if ($j == 0) {// first column hidden
                    $html_str .= "<td visibility: collapse style='display:none' id='row-column' value='$val'>$val&nbsp;</td>";
                } else if ($j == $col_cnt - 1) {//last column hidden
                    $html_str .= "<td visibility: collapse style='display:none'>$val&nbsp;</td>";
                } else if ($j == 6) {
                    $html_str .= "<td id='type-column' value='$val'>$val&nbsp;</td>";
                } else {
                    $html_str .= "<td >$val&nbsp;</td>";    
                }
                
            }

            $html_str .= "</tr>";
            $j = 0;
            $col_cnt = 0;
            $checkbox_id++;
        } else {

            $html_str .= "<tr>";
            
            for ($j = 0, $col_cnt = count($return_value["$i"]); $j < $col_cnt; $j++) {
                $val = $return_value["$i"]["$j"];
               
                if ($j == 0 & $return_value["$i"]["$j"] != null) {
                    $html_str .= "<td valign='middle' align='center'><input id='chk_row_id_$checkbox_id' type='checkbox' name='chk_row_id[]' onchange=chk_row_id_clicked('chk_row_id_$checkbox_id')></td>
                                  <td visibility: collapse style='display:none' id='row-column' value='$val'>$val&nbsp;</td>";
                } else if ($j == 0 && $return_value["$i"]["$j"] == null) {//firt column
                    $html_str .= "<td></td>
                                  <td visibility: collapse style='display:none' id='row-column' value='$val'>$val&nbsp;</td>";
                } else if ($j != $col_cnt - 1) { //avoid last col (process_id)
                    $html_str .= '<td valign="middle" nowrap="nowrap"><font face="tahoma">'. $val . '&nbsp;</font></td>';
                }
            }

            $html_str .= "</tr>";
            $checkbox_id++;
        }
    }

    $html_str .= "</table>";
    $html_str .= "<script type='text/javascript'>

            hideHourGlass();
            
            function selected_rows() {
                var table = document.getElementById('index_table');
                var values = new Array();
            	for (var i = 1, row; row = table.rows[i]; i++) {
               	   
            	   var id = 'chk_row_id_' + i;
            	   checkbox = document.getElementById(id);
                     if (checkbox != undefined) {
        				if (checkbox.checked) {
        				    var row_id = (row.cells[1].textContent);
                            values.push(trim(row_id))
        				}
        			}
               	} 
                
                row_id = values.join(',');
                return row_id;   
            }
 
            function get_selected_rows() {
                return reduce(function(obj, val) {
                    if (obj.checked)
                        val += (val =='' ? '' : ',') + obj.value;
                    return val;
                }, '');
            }

            function toggle_check_all(checked) {
                if (" . $row_count . " > 0) {                    
                    reduce(function(obj, val) {
                        obj.checked = val;
                        return val;
                    }, checked);    
                                        
                    if (selected_rows() == '') {
                        parent.disable_menu_items();
                    } else {
                        parent.enable_menu_items();
                    }
                    
                }
            }

            function reduce(combine, base) {
                var row_count = " . $row_count . ";
                var row_obj;

                for (var i = 0; i < row_count; i++) {
                    row_obj = document.getElementById('chk_row_id_' + i);
                    if (row_obj) //apply function for each array item
                       base = combine(row_obj, base);
                }

                return base;
            }

            function chk_row_id_clicked() { 
                if (selected_rows() == '') {
                    parent.disable_menu_items();
                } else {
                    parent.enable_menu_items();
                }

            }";
    $html_str .= "
            function check_deal_type(row) {
                var row_id = row.split(',');
                var data = new Array();";
 
    for ($q = 0; $q < $row_count; $q++) {
        if ($return_value[$q][0] != '') {
            $html_str .= "
                        if(" . $return_value[$q][0] . " == row_id[0] || " . $return_value[$q][0] . " == row_id[1]) {
                            data.push('" . $return_value[$q][6] . "');
                        }";
        }
    }

    $html_str .= "
                
                if (data[0] != data[1]) {
                    return true;
                } else {
                    return false;
                }       
            }

        </script>";

    $html_str .= '
            <script>
            var column_no_filter;
            function filter(term, _id, cellNr) {
            	
            	cellNr = column_no_filter;
            	var invalidCharPos = -1;
            	var suche = term.value.toLowerCase();
            	
            	var use_wildcard = false;
            	
            	if (suche.toLowerCase().indexOf("%") > -1) {
            		use_wildcard = true;
            		suche = suche.replace("%", "");
            	}
            	
            	var table = document.getElementById(_id);	
            	var invalidChar = "/[*+()^?\][\\/]*/g";             	
            	invalidCharPos = suche.search(/[*+()^?\][\\/] / );
            	
            	var suche = suche.replace(invalidChar, "");
            	suche = suche.replace(/>/, "&gt;"); // replace ">" to "&gt;"
            	
            	var ele;
            	for (var r = 1; r < table.rows.length; r++) {
            		ele = table.rows[r].cells[cellNr].innerHTML.replace(/<[^>]+>/g, "");
            		
            		if ((ele.toLowerCase().indexOf(suche) > -1 && use_wildcard == true || (ele.toLowerCase().indexOf(suche) == 0) && use_wildcard == false) && invalidCharPos == -1)
            		{
            			table.rows[r].style.display = "";
            		} else {
            			table.rows[r].style.display = "none";
            		}
            	}
            }

            var sel_filter_obj;
            
            function table_header_click(cellNr, obj) {
            	column_no_filter = cellNr;
            	sel_filter_obj = obj;
            	clm_nos_filter.innerText = obj.innerText;
            	filter_div.style.top = event.y + 5;
            	filter_div.style.left = event.x;
            	filter_div.style.display = "";
            	//sel_filter_obj.style.background = "#D4D4D4";
            	filter_txt.focus();           	
            }
            
            function ClearText() {
            	var filter_txt = "";
            }
            
            function hide_filter_div() {
            	filter_div.style.display = "none";
            	var suche = filter_txt.value;
            	if (suche == "") {
            		//sel_filter_obj.style.background = "#EAEAEA";
            	}
            }
            </script>  
    ';


    return $html_str;
}
// var values = new Array();
//       $.each($("input[name='case[]']:checked").closest("td").siblings("td"),
//              function (a,b,c,d) {
//                      if(this.id == 'model-name') {
//                          values.push($(this).text());
//                      }
//              });
//    
//       alert("val---" + values.join (", "));
// }
?>
