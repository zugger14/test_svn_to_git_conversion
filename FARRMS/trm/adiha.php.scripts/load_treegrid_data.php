<?php
	include 'components/include.file.v3.php';

	$sp_url = (isset($_POST["sp_url"]) && !empty($_POST["sp_url"])) ? $_POST["sp_url"] : "";
        $grid_obj_name = (isset($_POST["grid_obj_name"]) && !empty($_POST["grid_obj_name"])) ? $_POST["grid_obj_name"] : "";
        $group_by = (isset($_POST["group_by"]) && !empty($_POST["group_by"])) ? $_POST["group_by"] : "0";
       load_treegrid_data($sp_url,$grid_obj_name,$group_by);


	 function load_treegrid_data($grid_sp, $grid_name,$group_by) {
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
            $html_string .= $grid_name . '.enableHeaderMenu();' . "\n";
            $html_string .= 'try {' . "\n";
            $html_string .=     $grid_name . '.parse(jsoned_data, "json");' . "\n";
            $html_string .= '} catch (exception) {' . "\n";
            $html_string .= '   alert("parse json exception.");' . "\n";
            $html_string .= '}' . "\n";
            //return $html_string;
            ob_get_clean();
	    echo json_encode($html_string);
        }

	
?>