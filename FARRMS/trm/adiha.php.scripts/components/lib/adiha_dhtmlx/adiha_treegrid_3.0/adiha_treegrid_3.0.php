<?php

    class AdihaTreegrid extends AdihaGrid {
        public $group_by;
        
        /**
         * Load the JSON data for the treegrid
         * @param  [string] $grid_sp        [sp url for data to be loaded in treegrid]
         * @param  [string] $group_by       [Grouping column index for treegrid]
         */
        function load_grid_data($grid_sp, $group_by) {
            $this->group_by = $group_by;
            $grid_array = array();

            if ($grid_sp != '') {
                    $grid_array = readXMLURL2($grid_sp);

                    $grouped_array = array();
                $key_array = array_keys($grid_array[0]);
                $grouping_key = $key_array[$group_by];

                if (is_array($grid_array) && sizeof($grid_array) > 0) {
                    foreach ($grid_array as $js_array) {
                        if (!is_array($grouped_array[$js_array[$grouping_key]]))
                            $grouped_array[$js_array[$grouping_key]] = array();

                        $key_value_array = array();
                        $i = 0;
                        foreach ($js_array as $key => $value) {
                            if ($key == $grouping_key) {
                                    $key_value_array[$key] = '';
                            } else {
                                    $key_value_array[$key] = $value;
                            }
                        }
                        array_push($grouped_array[$js_array[$grouping_key]], $key_value_array);
                    }
                }

                $json_data = '';
                $json_data = "{rows:[";
                $string_array = array();
                if (is_array($grouped_array) && sizeof($grouped_array) > 0) {
                    foreach ($grouped_array as $parent_key => $js_array) {
                        $string_array2 = array();
                        $string = "{id:'" . preg_replace('/[^A-Za-z0-9\-]/', '', html_to_txt($parent_key)) . "', data:[{'value':'" . $parent_key . "'}],rows:[";
                        $i = 1;
                        foreach ($js_array as $second_array) {
                            $string2 = " {id:'sub_" . preg_replace('/[^A-Za-z0-9\-]/', '', html_to_txt($parent_key)) . "_". $i . "'" . ", data:[";
                            $j = 0;
                            foreach ($second_array as $key => $value) {
                                if ($j == 0) {
                                  $string2 .= "'" . $value . "'";
                                } else {
                                  $string2 .= ",'" . $value . "'";
                                }
                                $j++;
                            }
                            $string2 .= "]}";
                            array_push($string_array2, $string2);
                            $i++;
                        }
                        $string .= implode(", \n",$string_array2) . "]}";
                        array_push($string_array, $string);
                    }
                }
                $json_data .= implode(", \n",$string_array) . "]}";
                $linked_datasource_jsoned = $json_data;
                $headers = join(',', array_keys($grid_array[0]));
            } else {
                $linked_datasource_jsoned = '{ rows:[]}';
                $headers = '';
            }
 
            $html_string = 'var jsoned_data = '. $linked_datasource_jsoned .';' . "\n";
            
            // do not comment this line, it is enabled in all cases and if function is made for this it must be called after grid.init()
            $html_string .= $this->grid_name . '.enableHeaderMenu();' . "\n";
            $html_string .= 'try {' . "\n";
            $html_string .=     $this->grid_name . '.parse(jsoned_data, "json");' . "\n";
            $html_string .= '} catch (exception) {' . "\n";
            $html_string .= '   alert("parse json exception.");' . "\n";
            $html_string .= '}' . "\n";
            $html_string .= $this->load_grid_functions();
            return $html_string;
        }
        
        /**
         * [Javascript Functions]
         */
        public function load_grid_functions() {
            global $app_php_script_loc;
            $html_string = parent::load_grid_functions();
            
            /**
             * Grid Refresh function
             * @data - data for sp_url to refresh grid
             * Data in the following format:
                 data = {"action": "spa_source_contract_detail",
                            "flag": mode,
                            "source_contract_id": source_contract_id,
                            "source_system_id": "NULL",
                            "contract_name": contract_name,
                            "contract_desc": contract_desc,
                            "is_active": active,
                            "standard_contract": standard_contract,
                            "session_id": session
                         };
             */
            $html_string .= $this->name_space . '.refresh_treegrid = function(sp_url) {'. "\n";
            $html_string .= '   var php_path = "' . $app_php_script_loc . '";'. "\n";
            $html_string .= '   var result = "";'. "\n";
            $html_string .= '   result = adiha_post_data("return_json", sp_url,"","","' . $this->name_space . '.refresh_treegrid_callback","false");'. "\n";
            $html_string .= '}'. "\n";
            
            $html_string .= $this->name_space . '.refresh_treegrid_callback = function(result) {'. "\n";
            $html_string .= '   var json_object = $.parseJSON(result);'. "\n";
            $html_string .= '   var jsoned_data = get_treegrid_json(json_object, ' . $this->group_by . ');'. "\n";
            $html_string .=     $this->grid_name . '.clearAll();'. "\n";
            $html_string .=     $this->grid_name . '.parse(jsoned_data, "json");'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * Add New Row
             * @param [String] default_value: Default value in new added row. Eg: ['','','','0','0','0'] 
             */
            $html_string .= $this->name_space . '.add_treegrid_row = function(default_value) {'. "\n";
            $html_string .= '   var select_id = ' . $this->grid_name . '.getSelectedId();'. "\n";
            $html_string .= '   var new_id = '. $this->grid_name .'.uid();'. "\n";
            $html_string .= '   if (select_id == null) {'. "\n";
            $html_string .=         $this->grid_name . '.addRow(new_id, "");'. "\n";
            $html_string .=         $this->grid_name . '.selectRow('. $this->grid_name . '.getRowIndex(new_id), false, false, true);'. "\n";
            $html_string .= '   } else {'. "\n";
            $html_string .=         $this->grid_name . '.addRow(new_id, "", 0, select_id);'. "\n";
            $html_string .=         $this->grid_name . '.selectRow('. $this->grid_name . '.getRowIndex(new_id), false, false, true);'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * Returns the treegrid data in XML format
             */
            $html_string .= $this->name_space . '.get_treegrid_data = function() {'. "\n";
            $html_string .= '   var ps_xml = "<Root>";'. "\n";
            $html_string .=     $this->grid_name . '.forEachRow(function(parent_id) {'. "\n";
            $html_string .=         $this->grid_name . '._h2.forEachChild(parent_id,function(element) {'. "\n";
            $html_string .= '           ps_xml = ps_xml + "<PSRecordset ";'. "\n";
            $html_string .= '           for(var cell_index = 0; cell_index < '. $this->grid_name . '.getColumnsNum(); cell_index++){'. "\n";
            $html_string .= '			    if (cell_index == ' . $this->group_by . ') {'. "\n";
            $html_string .= '                   ps_xml = ps_xml + " " + '. $this->grid_name .'.getColumnId(cell_index) + \'="\' + '. $this->grid_name . '.cells(parent_id, cell_index).getValue().replace(/(<([^>]+)>)/ig,"") + \'"\';'. "\n";
            $html_string .= '			    } else {'. "\n";
            $html_string .= '                   ps_xml = ps_xml + " " + '. $this->grid_name .'.getColumnId(cell_index) + \'="\' + '. $this->grid_name . '.cells(element.id, cell_index).getValue().replace(/(<([^>]+)>)/ig,"") + \'"\';'. "\n";
            $html_string .= '			    }'. "\n";
            $html_string .= '           }'. "\n";
            $html_string .= '           ps_xml = ps_xml + " ></PSRecordset> ";'. "\n";
            $html_string .= '       });'. "\n";
            $html_string .= '   });'. "\n";
            $html_string .= '   ps_xml = ps_xml + "</Root>";'. "\n";
            $html_string .= '   return ps_xml;'. "\n";
            $html_string .= '};'. "\n";
            
            return $html_string;
        }
    }
?>