<?php
/**
* Split nom volume screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
    <html> 
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';
        $form_function_id = 10163800;
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $location_id = 'NULL';
        $term_start = get_sanitized_value($_GET['term_start'] ?? '');
        $term_end = get_sanitized_value($_GET['term_end'] ?? '');
        $rights_split_nom_volume = 10163810;
        list (
            $has_rights_split_nom_volume
        ) = build_security_rights (
            $rights_split_nom_volume
        );

        // $xml_user = $app_php_script_loc . 'spa_get_regions.php?user_login_id=' . $app_user_name;
        // $def = readXMLURL2($xml_user);
        // $date_format = $def[0]['date_format'] ?? '';
        // $date_format = str_replace('yyyy', '%Y', str_replace('dd', '%j', str_replace('mm', '%n', $date_format)));


        $json = '[
            {
                id:             "a",
                text:           "Filter",
                header:         true,
                collapse:       true,
                width:          200,
                height:         100
            },
            {
                id:             "b",
                text:           "Filter Criteria",
                header:         true,
                collapse:       false,
                width:          200
            },
            {
                id:             "c",
                text:           "Split Volumes",
                header:         true,
                collapse:       false,
                height:         390
            }
        ]';

        $namespace = 'nomination';
        $nomination_layout_obj = new AdihaLayout();
        echo $nomination_layout_obj->init_layout('nomination_layout', '', '3E', $json, $namespace);

        //Attaching filter form for View Nom Schedules Grid
        $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163800', @template_name='split nom volume', @group_name='Filters'";
        $filter_arr = readXMLURL2($filter_sql);
        $tab_id = $filter_arr[0]['tab_id'];
        $form_json = $filter_arr[0]['form_json'];
        echo $nomination_layout_obj->attach_form('filter_form', 'b');
        $filter_form_obj = new AdihaForm();
        echo $filter_form_obj->init_by_attach('filter_form', $namespace);
        echo $filter_form_obj->load_form($form_json);

        //Attaching Toolbar for Locations Grid
        $location_toolbar_json = '[
            { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"},
            { type: "separator" },
            { id: "save", type: "button", img: "save.gif", text: "Save", imgdis:"save_dis.gif", title: "Save", enabled: "'.$has_rights_split_nom_volume.'"},
            { type: "separator" },
            {id: "expand_collapse", type: "button",img: "exp_col.gif", text: "Expand/Collapse"}
         ]';

        echo $nomination_layout_obj->attach_toolbar_cell('location_toolbar', 'c');
        $location_toolbar_obj = new AdihaToolbar();
        echo $location_toolbar_obj->init_by_attach('location_toolbar', $namespace);
        echo $location_toolbar_obj->load_toolbar($location_toolbar_json);
        echo $location_toolbar_obj->attach_event('', 'onClick', 'nomination_toolbar_onclick');
        echo "var undock_class = 'undock-btn-b';";
        echo 'nomination.nomination_layout.cells("b").setText("<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" nomination.undock_window(' . "'b'" . ');\"></a>Split Volumes</div>");';
        echo ' nomination.nomination_layout.attachEvent("onDock", function(name) {';
        echo " $('.undock-btn-a').show();";
        echo " });";
        echo ' nomination.nomination_layout.attachEvent("onUnDock", function(name) {';
        echo " $('.undock-btn-a').hide();";
        echo " });";
        echo $nomination_layout_obj->close_layout();
        ?> 

        <body class = "bfix2"></body>
        <style>
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                overflow: hidden;
            }           
            .div.dhxform_item_label_left.filter_save div.dhxform_btn_txt { margin: 8px 2px 0 10px}
            .grid_row_hover {
                background-color: #FFF1CC;
            }
        </style>
        

        <script type="text/javascript">
            var expand_state = 0;
            var expand_state1 = 0;
            var php_script_loc = '<?php echo $php_script_loc; ?>';
            grid_creation_status = {};
            grid_creation_status.status = 0;
            
            var header_style = [
                "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6", "background-color:#6A86A6"
            ];

            $(function() {
                var filter_obj = nomination.nomination_layout.cells('a').attachForm();
                var layout_cell_obj = nomination.nomination_layout.cells('b');
                var function_id =  '<?php echo $form_function_id; ?>';
                load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', nomination);

                var term_start ="<?php echo $term_start; ?>";
                var term_end = "<?php echo $term_end;?>";
                var currentTime = new Date();
                var today = new Date();
                today.setDate(30);
                var tomorrow = new Date();
                tomorrow.setDate(currentTime.getDate() + 1);
                date_start = formatDate(tomorrow);
                if(term_start)
                    nomination.filter_form.setItemValue('date_from', term_start);
                else
                    nomination.filter_form.setItemValue('date_from', date_start);
                var lastDay = new Date(tomorrow.getFullYear(), tomorrow.getMonth() + 1, 0);
                
                date_end = formatDate(lastDay);
                if (term_end)
                    nomination.filter_form.setItemValue('date_to', term_end);
                else
                    nomination.filter_form.setItemValue('date_to', date_end);

                create_first_grid();
            });
            /*Triggers when window is to be undocked.*/
            /*START*/
            nomination.undock_window = function(cell) {
                if (cell == 'b') {
                    w1 = nomination.nomination_layout.cells('b').undock(0, 0, 1000, 600);
                    nomination.nomination_layout.dhxWins.window('b').button('minmax').hide();
                    nomination.nomination_layout.dhxWins.window('b').button('park').hide();
                    nomination.nomination_layout.dhxWins.window('b').centerOnScreen();
                }
                w1.maximize();
            }
            /**
             * Loads data of the subgrid grid.
             * @param  {[type]} result [Array]
             * @return {boolean] true or false. if true creates sub grid else doesnt create grid.
             */
            function create_first_grid() {
                var date_from = nomination.filter_form.getItemValue("date_from", true);
                var date_to = nomination.filter_form.getItemValue("date_to", true);
                var split = date_from.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_from_js = new Date(year, month - 1, day);

                var split = date_to.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_to_js = new Date(year, month - 1, day);

                if (date_to_js < date_from_js) {
                    var message = 'Date To cannot be less than Date From.';
                    show_messagebox(message);
                    return;
                }
                var filter_type = nomination.filter_form.getItemValue("filter_type");
                var group_by = nomination.filter_form.getItemValue("group_by"); // h - location, b - nom group
                var location_id = "<?php echo $location_id; ?>";
                var header_list = (group_by == 'h') ? "Gathering Location,&nbsp;,Total Volume" : "Nomination Group,&nbsp;,Total Volume";

                if (nomination.myGrid) {
                    nomination.myGrid.destructor();
                }

                //grid attach
                nomination.myGrid = nomination.nomination_layout.cells('c').attachGrid();
                nomination.myGrid.setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
                nomination.myGrid.setHeader(header_list, null);
                nomination.myGrid.setColumnIds("gathering_location,gathering_location_id,group_volume");
                nomination.myGrid.setColTypes('ro,sub_row_grid,ron');
                nomination.myGrid.setColSorting('str,str,str');
                nomination.myGrid.setNumberFormat("0,000", 2, ".", ",");
                nomination.myGrid.setInitWidthsP("15,3,83");
                nomination.myGrid.enableRowsHover(true);
                nomination.myGrid.enableEditEvents(false, true, false);
                nomination.myGrid.attachHeader("#text_filter,,");
                nomination.myGrid.init();
                data = {"action": "spa_equity_gas_allocation_UI",
                    "flag": group_by,
                    "start_date": date_from,
                    "end_date": date_to,
                    "filter_type": filter_type,
                    "location_id": location_id
                };
                result = adiha_post_data("return_json", data, "", "", "create_grid");
            }
            /**
             * Creats the main grid.
             * @param  {[type]} result [Array]
             * @return calls funtion to load the data of the main grid.
             */
            function create_grid(result) {
                if (result != '[]') {
                    all_data = $.parseJSON(result);
                    var filtered_data = _.filter(all_data, function(item) {
                        return (item.group_volume != null);
                    });
                    
                    var route_level_data = _.filter(all_data, function(item) {
                        return (item.total_volume != null);
                    });

                    var sub_grid_filtered_data = _.filter(all_data, function(item) {
                        return (item.primary_secondary != null);
                    });

                    nom_grid_jsoned = get_grid_json(filtered_data);
                    route_jsoned = get_grid_json(route_level_data);
                    sub_grid_jsoned = get_grid_json(sub_grid_filtered_data);
                    nomination.myGrid.parse(nom_grid_jsoned, "js");
                }

                nomination.myGrid.attachEvent("onSubGridCreated", function(route_grid, rid, rind) {
                    route_jsoned_parsed = $.parseJSON(route_jsoned);
                    group_id = nomination.myGrid.cells(rid, 1).getValue();
                    if (group_id == 'null') {
                        return;
                    }
                    var filtered_route = _.filter(route_jsoned_parsed.data, function(item) {
                        return (item.gathering_location_id == group_id);
                    });
                    
                    route_grid_json = get_grid_json(filtered_route);                    
                    /*filtering*/
                    route_grid.setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
                    route_grid.setHeader("Route,,Total Volume", null);
                    route_grid.setColumnIds("route_name,route_id,total_volume");
                    route_grid.setColTypes('ro,sub_row_grid,ron');
                    route_grid.setColSorting('str,str,str');
                    route_grid.setNumberFormat("0,000", 2, ".", ",");
                    route_grid.setInitWidthsP("10,3,88");
                    route_grid.enableRowsHover(true);
                    route_grid.enableEditEvents(false, true, false);
                    //route_grid.attachHeader("#text_filter,,");
                    route_grid.init();
                    route_grid.parse(route_grid_json, "js");    
                    
                    route_grid.attachEvent("onSubGridCreated", function(subgrid_object, id, ind) {
                        group_id = nomination.myGrid.cells(rid, 1).getValue();
                        temp1_nom_jsoned = $.parseJSON(sub_grid_jsoned);
                        route_id = route_grid.cells(id, 1).getValue();
                        var filtered_nom = _.filter(temp1_nom_jsoned.data, function(item) {
                            return (item.route_id == route_id) && (item.gathering_location_id == group_id);
                        });
                        sub_grid_jsoned1 = get_grid_json(filtered_nom);
                        subgrid_object.setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
                        subgrid_object.setHeader("Type,Delivery Location,Del Location Id,Contract,Volume,Split Ratio, contract ID", null);
                        subgrid_object.setColumnIds("primary_secondary,delivery_location_name,delivery_location_id,contract_name,delivery_volume,split_percentage,contract_id");
                        subgrid_object.setColTypes("ro,ro,ro,ro,ed_v,edn,ro");
                        subgrid_object.setColSorting("str,str,str,str,int,int,str");
                        subgrid_object.setInitWidthsP("30,30,0,10,10,10,0");
                        subgrid_object.setNumberFormat("0,000", 4, ".", ",");
                        subgrid_object.enableMultiselect(true);
                        subgrid_object.setNumberFormat("0.00", 5);
                        subgrid_object.setMathRound(2);
                        subgrid_object.init();                  
                        subgrid_object.setColumnsVisibility("false,false,true,false,false,false,true");
                        subgrid_object.parse(sub_grid_jsoned1, "js");

                        //nomination["myGrid_row_id_" + id] = route_grid.cells(rid, 2).getValue();
                        subgrid_object.attachEvent("onEditCell", function(stage, rId, cInd, nValue, oValue) {
                            var init_total_rec_value = 0;
                            if (subgrid_object.cells(rId, 0).getValue() != 'Primary') {
                                if (stage == 2) {
                                    if (isNaN(nValue))
                                        return false;
                                    if (cInd == 4) {
                                        var total_volume = Number(route_grid.cells(id, 2).getValue());
                                        var pri_old_value = Number(subgrid_object.cells(1, 4).getValue());

                                        if (nValue > total_volume)
                                            return false;

                                        var diff = (oValue - nValue);
                                        if (diff > Math.abs(total_volume))
                                            return false;

                                        var new_val = pri_old_value + diff;
                                        if (Math.abs(new_val) > total_volume)
                                            return false;
                                        if (new_val < 0)
                                            return false;

                                        var set_pri_val = (new_val == 0) ? '0' : new_val;

                                        subgrid_object.cells(1, 4).setValue(set_pri_val);
                                            var pri_ratio = ((new_val / total_volume) == 0) ? '0' : (new_val / total_volume);
                                            var sec_ratio = ((nValue / total_volume) == 0) ? '0' : (nValue / total_volume);
                                        subgrid_object.cells(1, 5).setValue(pri_ratio);
                                        subgrid_object.cells(rId, 5).setValue(sec_ratio);

                                        return true;
                                    } else if (cInd == 5) {
                                        var pri_old_value = Number(subgrid_object.cells(1, 5).getValue());
                                        
                                        if (nValue > 1)
                                            return false;

                                        var per_diff = (oValue - nValue);
                                        if (per_diff > 1 || per_diff < -1 || per_diff == 0)
                                            return false;

                                        var new_val = Number((pri_old_value + per_diff)).toFixed(4);

                                        if (new_val > 1 || new_val < 0)
                                            return false;
                                        var set_new_val = (new_val == 0) ? '0' : new_val;
                                        subgrid_object.cells(1, 5).setValue(set_new_val);

                                            var total_value = Number(route_grid.cells(id, 2).getValue());
                                        var secondary_val = nValue * total_value;
                                        secondary_val = (secondary_val == 0) ? '0' : Math.floor(secondary_val);
                                        subgrid_object.cells(rId, 4).setValue(secondary_val);
                                        
                                        var total_secondary = 0;
                                        var i = 0;
                                        subgrid_object.forEachRow(function(r_id) {
                                            if (i != 0) {
                                                total_secondary = total_secondary + Number(subgrid_object.cells(r_id, 4).getValue());
                                            }
                                            i++;
                                        })
                                        var primary_val = total_value - total_secondary;
                                        subgrid_object.cells(1, 4).setValue(primary_val);                                   

                                        return true;
                                    }
                                }
                            }
                            else {
                                return false;
                            }
                        });
                        return false;

                    });
                
                });
            }
            /*
             * Filter form on change event
             * @param {type} parent_id
             * @returns {undefined}
             */
            function filter_form_onchange(name, value, is_checked) {
                if (name == 'date_from') {
                    var date_from = nomination.filter_form.getItemValue('date_from', true);
                    var split = date_from.split('-');
                    var year = +split[0];
                    var month = +split[1];
                    var day = +split[2];

                    var date = new Date(year, month - 1, day);
                    var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                    date_end = formatDate(lastDay);
                    nomination.filter_form.setItemValue('date_to', '');
                    nomination.filter_form.setItemValue('date_to', date_end);
                    create_first_grid();
                } else if (name == 'filter_type' || name == 'group_by') {
                    create_first_grid();
                }
            }
            //function to formatDate
            function formatDate(date) {
                var d = new Date(date),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

                if (month.length < 2)
                    month = '0' + month;
                if (day.length < 2)
                    day = '0' + day;

                return [year, month, day].join('-');
            }

            /**
             * [Function to expand/collapse Locations Grid when double clicked]
             */
            nomination.expand_counterparty = function(r_id, col_id) {
                var selected_row = nomination.location_grid.getSelectedRowId();
                var state = nomination.location_grid.getOpenState(selected_row);

                if (state)
                    nomination.location_grid.closeItem(selected_row);
                else
                    nomination.location_grid.openItem(selected_row);
            }

            /**
             *[openAllInvoices Open All nodes of Invoice Grid]
             */
            open_all_locations = function() {
                nomination.location_grid.expandAll();
                expand_state = 1;
            }

            /**
             *[closeAllInvoices Close All nodes of Invoice Grid]
             */
            close_all_locations = function() {
                nomination.location_grid.collapseAll();
                expand_state = 0;
            }


            /**
             * [Toolbar onclick function for Contract Settlement Grid]
             */
            function nomination_toolbar_onclick(name) {
                if (name == 'refresh') {
                    create_first_grid();
                    nomination.nomination_layout.cells('a').collapse();
                }
                else if (name == 'save') {
                    btn_save_click();
                }
                else if (name == 'expand_collapse') {
                    if (expand_state1 == 0) {
                        open_all_volumes();
                    } else {
                        close_all_volumes();
                    }
                }
            }
            /**
             *[openAllSchedules Open All nodes of Grid]
             */
            open_all_volumes = function() {
                if (nomination.myGrid) {
                    nomination.myGrid.forEachRow(function(id) {
                        nomination.myGrid.cellById(id, 1).open();
                        route_grid = nomination.myGrid.cellById(id, 1).getSubGrid();                        
                        route_grid.setSizes();
                        route_grid.callEvent("onGridReconstructed",[]);
                        if (route_grid) {
                            route_grid.forEachRow(function(rid) {
                                route_grid.cellById(rid, 1).open();                 
                            });
                        }
                    });
                    expand_state1 = 1;
                }
            }
            /**
             *[closeAllSchedules Close All nodes of Grid]
             */
            close_all_volumes = function() {
                if (nomination.myGrid) {
                    nomination.myGrid.forEachRow(function(id) {
                        nomination.myGrid.cellById(id, 1).close();
                    });
                    expand_state1 = 0;
                }
            }
            /**
             * Create JSON object for grid.
             * @param  {[type]} grid_array [JSON]
             * @return {[type]}      [JSON object]
             */
            function get_grid_json(grid_array) {
                var total_count = grid_array.length;

                var json_data = '';
                json_data = '{"total_count":"' + total_count + '", "pos":"0", "data":[';

                var string_array = new Array();

                if (total_count > 0) {
                    _.each(grid_array, function(array_value, array_key) {
                        var string = '{ ';
                        i = 0;

                        _.each(array_value, function(value, key) {
                            if (i == 0) {
                                string += '"' + key + '":' + '"' + value + '"';
                            } else {
                                string += ',"' + key + '":' + '"' + value + '"';
                            }
                            i++;
                        });
                        string += '}';
                        string_array.push(string);
                    });
                }
                json_data += string_array.join(", \n") + "]}";
                return json_data;
            }
            /**
             * Function when save button is clicked.
             * @param  
             * @return 
             */
            function btn_save_click() {
                var total_rows = nomination.myGrid.getRowsNum();
                var location_id = "<?php echo $location_id; ?>";
                if (total_rows == 0) {
                    show_messagebox('Grid is empty to perform any operations.');
                    return;
                }
                var date_to = nomination.filter_form.getItemValue('date_to', true);
                var date_from = nomination.filter_form.getItemValue('date_from', true);
                var group_by = nomination.filter_form.getItemValue('group_by', true);
                var filter_type = nomination.filter_form.getItemValue("filter_type");
                var split = date_from.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_from_js = new Date(year, month - 1, day);

                var split = date_to.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_to_js = new Date(year, month - 1, day);

                if (date_to_js < date_from_js) {
                    var message = 'Date To cannot be less than Date From.';
                    show_messagebox(message);
                    return;
                }

                var return_ids_xml = '<Root> <PSDate date_from= "' + date_from + '" date_to="' + date_to + '" group_by="' + group_by + '" location_id="' + location_id + '"></PSDate>';
                grid_object = nomination.myGrid;
                grid_object.forEachRow(function(parent_id) {
                    var gathering_loc = grid_object.cells(parent_id, 1).getValue();
                    var route_grid = grid_object.cells(parent_id, 1).getSubGrid();
                    if (route_grid) {                       
                        route_grid.forEachRow(function(r_parent_id) {
                            var route_id = route_grid.cells(r_parent_id, 1).getValue();
                            var subgrid_nom = route_grid.cells(r_parent_id, 1).getSubGrid();
                            if (subgrid_nom) {
                                subgrid_nom.clearSelection();
                                var total_vol = route_grid.cells(r_parent_id, 2).getValue();
                                var should_save = true;
                                subgrid_nom.forEachRow(function(nom_row_id) {
                                    var type = subgrid_nom.cells(nom_row_id, 0).getValue();
                                    var del_loc = subgrid_nom.cells(nom_row_id, 2).getValue();
                                    var rec_vol = subgrid_nom.cells(nom_row_id, 4).getValue();
                                    var split = subgrid_nom.cells(nom_row_id, 5).getValue();
                                    var contract_id = subgrid_nom.cells(nom_row_id, 6).getValue();

                                    if (type == 'Primary' && total_vol == rec_vol && filter_type != 's') {
                                        should_save = false;
                                    } else if (should_save) {
                                        return_ids_xml += '<PSRecordSet ' + 'gathering_loc_id="' + gathering_loc + '" route_id="' + route_id + '" type="' + type + '" delivery_location_id="' + del_loc + '" volume="' + rec_vol + '" split="' + split + '" contract_id="' + contract_id + '"></PSRecordSet>';
                                    }
                                });
                            }
                        });
                    }
                });
                return_ids_xml += '</Root>';
                data = {"action": "spa_equity_gas_allocation_UI",
                    "flag": "i",
                    "xml": return_ids_xml
                };
                
                result = adiha_post_data("alert", data, "", "", "");
            }
        </script>
        