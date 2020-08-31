<?php
	ob_start();
	require_once('components/include.file.v3.php');
    ## Verify CSRF Token
    verify_csrf_token();
    
    $_REQUEST = array_merge($_GET, $_POST);
    
    $action = (isset($_REQUEST["action"])) ? get_sanitized_value($_REQUEST["action"]) : '';
	$grid_type = (isset($_REQUEST["grid_type"])) ? get_sanitized_value($_REQUEST["grid_type"]) : 'g';
	$grouping_column = (isset($_REQUEST["grouping_column"])) ? get_sanitized_value($_REQUEST["grouping_column"]) : 'n';
	$value_list = (isset($_REQUEST["value_list"])) ? get_sanitized_value($_REQUEST["value_list"]) : 'n';
    $sql = (isset($_REQUEST["sql"])) ? $_REQUEST["sql"] : '';
    $grouping_type = (isset($_REQUEST["grouping_type"])) ? get_sanitized_value($_REQUEST["grouping_type"]) : 1; // 1 - grouping columns will be shown in same columns
                                                                                           // 2 - grouping columns are shown in seperate columns.
                                                                                           // 3 - deal specific
	$xaxis_col = (isset($_REQUEST["xaxis_col"])) ? get_sanitized_value($_REQUEST["xaxis_col"]) : '';
	$yaxis_col = (isset($_REQUEST["yaxis_col"])) ? get_sanitized_value($_REQUEST["yaxis_col"]) : '';
	$chart_data = (isset($_REQUEST["chart_data"])) ? get_sanitized_value($_REQUEST["chart_data"]) : '';
    //$key_prefix = (isset($_REQUEST["key_prefix"])) ? $_REQUEST["key_prefix"] : '';
    /* Above line is commented and replaced with below line  to bypass grid data caching without reverting all changes done for data caching. */
    $key_prefix = '';

    $key_suffix = (isset($_REQUEST["key_suffix"])) ? get_sanitized_value($_REQUEST["key_suffix"]) : '';

    if ($sql == '') {
    	if ($action == '') die();
    	$i = 0;
    	$param = "";
        $param_values = array();
    	foreach ($_REQUEST as $name => $value) {
    		$pos = strpos($name, 'dhx');
    		if ($pos === false) {
                $names_to_avoid = array('action', 'connector', 'key_prefix', 'key_suffix', 'grid_type', '_csrf_token', 'grouping_column', 'value_list', 'PHPSESSID', 'grouping_type', 'xaxis_col', 'yaxis_col', 'chart_data', 'folder_icon');
    	    	if (!in_array($name, $names_to_avoid)) {
    	    		$param .= ($i == 0) ? "" : ",";
                    $param .= "@" . $name . "=?";
                    if ($name == 'flag' &&  strpos($value, '.') != false) die();
                    array_push($param_values, ($value == 'NULL') ? NULL : htmlspecialchars_decode($value));
                    $i++;
    	    	}
    	    }
    	}

    	$sql = "EXEC " . $action . " " . $param;
    }
    
    $def = ($key_prefix == '') ? readXMLURL2($sql, false, $param_values) : readXMLURLCached($sql, false, $key_prefix, $key_suffix, true, 0, 'general');;

    ob_end_clean();

    if ($grid_type == 'g') {
        prepare_grid_data($def);
    } else if ($grid_type == 't') {
        prepare_tree_data($def, $grouping_column, $value_list);
    } else if ($grid_type == 'tg') {
        prepare_tree_grid_data($def, $grouping_column, $grouping_type);
    } else if ($grid_type == 'c') {
        prepare_calendar_data($def);
    } else if ($grid_type == 'l') {
        prepare_graph_data($def, $xaxis_col, $yaxis_col, $chart_data);
    }
    
	function prepare_grid_data($def){
        global $image_path;

		$posStart = 0;
		$key_array = array_keys($def[0] ?? array());
		$totalCount = sizeof($def);
        
		header("Content-type:text/xml");
		print("<?xml version=\"1.0\"  encoding=\"UTF-8\"?>");
		print("<rows total_count='".$totalCount."' pos='".$posStart."'>");

		foreach ($def as $row_val) {
			print("<row id='".$posStart."'>");
				foreach($key_array as $key) {
					if (strpos($row_val[$key], '::::') !== false) {
						$val_arr = explode("::::", $row_val[$key]);
						print_r($val_arr);
						print("<cell title='" . $val_arr[1] . "'><![CDATA[");
						print($val_arr[0]);
					} else {						
					print("<cell><![CDATA[");
					print($row_val[$key]);
					}					
					print("]]></cell>");
				}
			print("</row>");
			$posStart++;
		}
		print("</rows>");
	}
	
    function prepare_tree_array(Array $array, $grouping_columns, &$column_array = array()) {
        if(!is_array($grouping_columns)) $grouping_columns = array($grouping_columns);

        foreach($array as $result) {
            $tree_array = &$column_array;

            foreach($grouping_columns as $column){
            	$value_id_array = array();
            	$value_id_array = explode(":", strtolower($column));
            	$id = $value_id_array[0];
            	$value = $value_id_array[1];

                if(!array_key_exists((string)$result[$id] . '___' . $result[$value], $tree_array)) {
                    $tree_array[(string)$result[$id] . '___' . $result[$value]] = array();
                }
                $tree_array = &$tree_array[(string)$result[$id] . '___' . $result[$value]];
                $result[$column]  = '';
            }

            $tree_array[] = $result;
        }
        return ($column_array);
    }

    function prepare_tree_data($def, $grouping_column_list, $value_list) {
        $grouping_columns = array();
        $grouping_columns = explode(",", strtolower($grouping_column_list));

        $tree_array = prepare_tree_array($def, $grouping_columns);
        header("Content-type:text/xml");
        print("<?xml version=\"1.0\"  encoding=\"UTF-8\"?>");
        print("<tree id='0'>");

        foreach ($tree_array as $key => $value) {
        	$value_id_array = explode("___", $key);
        	print ("<item id='".strtolower($value_id_array[0])."' text='" . htmlspecialchars($value_id_array[1]) . "'>");
        		child_xml_prepare($value, $value_list);
        	print ("</item>");
        }
        print("</tree>");
    }

    function child_xml_prepare($array, $value_list) {
        foreach ($array as $key => $value) {
            if (is_array($value)) {
                if (array_depth($value) > 1) {
                    $value_id_array = explode("___", $key);
                    if ($value_id_array[0] != '') {
                        print ("<item id='".$value_id_array[0]."' text='" . htmlspecialchars($value_id_array[1]) . "'>");
                        child_xml_prepare($value, $value_list);
                        print("</item>");
                    }
                } else {
                    $value_array = explode(":", $value_list);
                    $is_lock_image = '';
                    $user_data_lock = '';
                    if ($value[$value_array[0]] != '') {
                        if ((in_array('system_defined', $value_array) && $value['system_defined'] == 1)) {
                            $is_lock_image = "im0 = 'password_lock.gif' tooltip = '".htmlspecialchars($value[$value_array[1]])." [Locked]'";
                            $user_data_lock = " <userdata name='is_lock'>1</userdata>";
                        } else {
                            $is_lock_image = "tooltip = '".htmlspecialchars($value[$value_array[1]])."'";
                        }
                        print ("<item id='".$value[$value_array[0]]."' text='" . htmlspecialchars($value[$value_array[1]]) . "' ".$is_lock_image."> $user_data_lock </item>");
                    }
                }
            }
        }
    }

	/**
     * [prepare_tree_grid_array description]
     * @param  Array          $array            [Original array returned by SP]
     * @param  [string/array] $grouping_columns [Array or string - should be array if we need to group by multiple columns]
     * @param  array          &$column_array    [Return value passed by reference - to use the function in chunks - will help in processing large dataset]
     * @return [type]                           [description]
     */
    function prepare_tree_grid_array(Array $array, $grouping_columns, &$column_array = array()) {
        if(!is_array($grouping_columns)) $grouping_columns = array($grouping_columns);

        foreach($array as $result) {
            $tree_array = &$column_array;

            foreach($grouping_columns as $column) {
                if (array_key_exists($column, $result)) {
                    if (!array_key_exists((string)$result[$column], $tree_array)) {
                        if ($result[$column] != null || sizeof($grouping_columns) <= 2)
                            $tree_array[(string)$result[$column]] = array();
                    }
                    if ($result[$column] != null || sizeof($grouping_columns) <= 2)
                        $tree_array = &$tree_array[(string)$result[$column]];

                    $result[$column] = '';
                }
            }

            $tree_array[] = $result;
        }
        
        return ($column_array);
    }
    
	function prepare_tree_grid_data($def, $grouping_column_list, $grouping_type) {        
        $grouping_columns_keys_array = explode(",", strtolower($grouping_column_list));
        $grouping_columns = array();
        $grouping_columns = explode(",", strtolower($grouping_column_list));

        $tree_array = prepare_tree_grid_array($def, $grouping_columns); 
        
        // echo '<pre>';
        // echo $sql;
        // //print_r($tree_array);
        // echo '</pre>';
        // die();
        $folder_icon = (isset($_REQUEST["folder_icon"])) ? get_sanitized_value($_REQUEST["folder_icon"]) : 'folder.gif';

        header("Content-type:text/xml");
        print("<?xml version=\"1.0\"  encoding=\"UTF-8\"?>");
        print("<rows pos='0'>");

        foreach ($tree_array as $key => $value) {
            $is_locked = '0';
            if ($grouping_type == 3 && sizeof($value) == 1) {
                if ($value['lock_deal_detail'] == 'y') {
                    $is_locked = '1';
                } else {
                    $is_locked = '0';
                }
            } else {
                $is_locked = '0';
            }

            if ($is_locked == '1') {
                $locked = 'locked="1" style="background-color:lightgrey"';
            } else {
                $locked = '';
            }

            if($grouping_type == 4 && cleanString($key) == '') {
                foreach($value as $k => $v) {
                    if(cleanString($k) != '') {
                        print ("<row id='".cleanString($k)."' $locked>");
                        print ("<cell image='folder.gif'><![CDATA[".htmlspecialchars($k, ENT_COMPAT | ENT_HTML401 | ENT_QUOTES)."]]></cell>");
                        // print_r($v);
                        child_tree_grid_xml_prepare($v, $grouping_column_list, $k, $grouping_type);

                        print ("</row>");
                    } else {
                        child_tree_grid_xml_prepare($value[$k], $grouping_column_list, $k, $grouping_type);
                    }
                    
                }
                continue;
            }      

            if($grouping_type == 5 && cleanString($key) == '') {
                foreach($value as $k => $v) {                    
                    child_tree_grid_xml_prepare($value[$k], $grouping_column_list, $k, $grouping_type);
                }
                continue;
            }  

            print ("<row id='".cleanString($key)."' $locked>");
        		print ("<cell image='" . $folder_icon . "'><![CDATA[".htmlspecialchars($key, ENT_COMPAT | ENT_HTML401 | ENT_QUOTES)."]]></cell>");                
                $child_necessary = true;
                if ($grouping_type == 3) {
                    if (sizeof($value) == 1) {
                        // do not display child if only one child is present
                        $child_necessary = false;

                        foreach($value[0] as $k => $v) {
                            if(!in_array($k, $grouping_columns_keys_array)) {
                                if ($k == 'detail_flag' && $v == 1) {
                                    $disable = true;
                                }

                                if ($k == 'source_deal_detail_id') {
                                    print("<cell type='ro'><![CDATA[" . $v . "]]></cell>");
                                } else if ($key == 'New Group' && sizeof($value) > 1) {
                                    print("<cell type='ro'></cell>");
                                } else {
                                    print("<cell><![CDATA[" . $v . "]]></cell>");
                                }
                            }
                        }
                    } else {
                        foreach($value as $kk => $vv) {
                            $disable = false;
                            foreach($vv as $k => $v) { 
                                if(!in_array($k, $grouping_columns_keys_array)) {
                                    if ($k == 'detail_flag' && $v == 1) {
                                        $disable = true;
                                    }

                                    if ($disable || $k == 'source_deal_detail_id' || $k == 'lock_deal_detail' || (($k == 'term_start' || $k == 'term_end') && ($key != 'New Group' && strrpos($key, "Copied Group") === false))) {
                                        print("<cell type='ro'></cell>");
                                    } else if ($key == 'New Group' && sizeof($value) > 1) {
                                        print("<cell type='ro'></cell>");
                                    } else {
                                        print("<cell></cell>");  
                                    }
                                }
                            }
                        }
                    }
                    
                }

                if ($child_necessary && strrpos($key, "Copied Group") === false && ($key != 'New Group' || sizeof($value) > 1)) {
                    child_tree_grid_xml_prepare($value, $grouping_column_list, $key, $grouping_type);
                }

        	print ("</row>");
        }
        print("</rows>");
	}

	/**
	 * [child_tree_grid_xml_prepare prepare child array]
	 * @param  [type] $array [Array]
	 * @return [type]        [description]
	 */
	function child_tree_grid_xml_prepare($array, $grouping_column_list, $parent_key = '', $grouping_type) {
        $folder_icon = (isset($_REQUEST["folder_icon"])) ? get_sanitized_value($_REQUEST["folder_icon"]) : 'folder.gif';
        $grouping_columns_keys_array = explode(",", strtolower($grouping_column_list));
        $counter = 0;
        $parent_counter = 0;
        if ($grouping_type == 1) {
            foreach ($array as $key => $value) {            
                if (is_array($value)) {
                    if (array_depth($value) > 1 && (!array_key_exists("0", $value))) {
                        $rand_num = rand(10,10000);                                                                                  
                        print("<row id='".cleanString($parent_key)."_". $parent_counter . "_".$rand_num."'>");
                            print("<cell image='" . $folder_icon . "'><![CDATA[".$key."]]></cell>");
                            child_tree_grid_xml_prepare($value, $grouping_column_list, $key, $grouping_type);
                        print("</row>");
                        $parent_counter++;
                    } else if (array_depth($value) > 1) {
                        foreach($value as $kk => $vv) {                                                                                                                                                                      
                            $row_display = '';
                            if ($key !== 0 && empty($key)) {
                                $row_display = "style='display:none'";
                            }
                            $rand_num = rand(10,10000);
                            /* ADD lock icon for setup data import export */
                            $is_lock_image = '';
                            $user_data_lock = '';
                            if (array_key_exists ('system_defined', $vv) && $vv['system_defined'] == "1") {
                                $is_lock_image = "image = 'password_lock.gif' title = '".$key." [Locked]'";
                                $user_data_lock = " <userdata name='is_lock'>1</userdata>";
                            }
                            print("<row id='".cleanString($parent_key)."_". $counter . "_".$rand_num. "' $row_display>");
                            print($user_data_lock . " ". "<cell $is_lock_image><![CDATA[".$key."]]></cell>");

                            foreach ($vv as $k => $v) {
                                if(!in_array($k, $grouping_columns_keys_array) && $k != 'system_defined') { //system_defined column required only to generaate lock icon
                                    print("<cell><![CDATA[" . $v . "]]></cell>");
                                }
                            }
                            print("</row>");
                            $counter++;                   
                        }
                    }
                }
            }
        } else if ($grouping_type == 2 || $grouping_type == 3) {
            $is_locked = '0';

            foreach ($array as $key => $value) {            
                if (is_array($value)) {
                    if (array_depth($value) > 1) {
                        $rand_num = rand(10,100);                                                                                  
                        print("<row id='".cleanString($parent_key)."_". $parent_counter . "_".$rand_num."'>");
                            print("<cell image='folder.gif'><![CDATA[".$key."]]></cell>");                            
                           child_tree_grid_xml_prepare($value, $grouping_column_list, $key, $grouping_type);
                        print("</row>");
                        $parent_counter++;
                    } else {
                        $rand_num = rand(10,100);

                        if ($grouping_type == 3) {
                            if ($value['lock_deal_detail'] == 'y') {
                                $is_locked = '1';
                            } else {
                                $is_locked = '0';
                            }
                        } else {
                            $is_locked = '0';
                        }

                        if ($is_locked == '1') {
                            $locked = 'locked="1" style="background-color:lightgrey"';
                        } else {
                            $locked = '';
                        }

                        print("<row id='".cleanString($parent_key)."_". $counter . "_".$rand_num. "' $locked $row_display>");
                            child_tree_grid_xml_prepare($value, $grouping_column_list, $key, $grouping_type);                    
                        print("</row>");
                        $counter++; 
                    }
                } else {
                    if(!in_array($key, $grouping_columns_keys_array)) {
                        print("<cell><![CDATA[" . $value . "]]></cell>");    
                    } else {
                        print("<cell ><![CDATA[" . $value . "]]></cell>");
                    }
                }
            }
        } else if($grouping_type == 4 || $grouping_type == 5) {
            $is_locked = '0';
            foreach ($array as $key => $value) { 

                if(is_array($value)) { 
                    if(array_depth($value) > 2) {
                        if(cleanString($key) == '')  {                
                            child_tree_grid_xml_prepare($array[$key], $grouping_column_list, $key, $grouping_type);
                        } else {
                            $rand_num = rand(10,100);
                            print("<row id='".cleanString($parent_key)."_". $parent_counter . "_".$rand_num."'>");
                            print("<cell image='folder.gif'><![CDATA[".$key."]]></cell>"); 
                            child_tree_grid_xml_prepare($value, $grouping_column_list, $key, $grouping_type);
                            print("</row>");    
                        }                                                                                   
                        
                        $parent_counter++;
                    } else if(array_depth($value) > 1) {

                        foreach($value as $kk => $vv) {                                                                                                
                            $row_display = '';
                            if ($key !== 0 && empty($key)) {
                                $row_display = "style='display:none'";
                            }
                            $rand_num = rand(10,10000);
                            
                            print("<row id='".cleanString($parent_key)."_". $counter . "_".$rand_num. "' $row_display>");
                                print("<cell><![CDATA[".$key."]]></cell>");
                                
                                foreach ($vv as $k => $v) {
                                    if(!in_array($k, $grouping_columns_keys_array)) {
                                        print("<cell><![CDATA[" . $v . "]]></cell>");    
                                    }
                                }
                            print("</row>");
                            $counter++;                   
                        }
                    } else {
                        $row_display = '';
                        
                        $rand_num = rand(10,10000);
                        
                        print("<row id='".cleanString($parent_key)."_". $counter . "_".$rand_num. "' $row_display>");
                        print("<cell><![CDATA[".$parent_key."]]></cell>");
                        foreach($value as $k => $v) {
                            if(!in_array($k, $grouping_columns_keys_array)) {
                                print("<cell><![CDATA[" . $v . "]]></cell>");    
                            }
                        } 
                        print("</row>");
                        $counter++; 
                    }
                }               
                   
            }
        }
    }


    function array_depth(array $array) {
        $max_depth = 1;

        foreach ($array as $value) {
            if (is_array($value)) {
                $depth = array_depth($value) + 1;

                if ($depth > $max_depth) {
                    $max_depth = $depth;
                }
            }
        }

        return $max_depth;
    }
    
    /**
	 * [check_blank_value Check if the First value is blank]
	 * @param  [type] $array [Array]
	 */
    function check_blank_value($array){
        foreach ($array as $key => $value) {  
            if(array_search($key, array_keys($array))== 1 && trim($value) == ""){
                 return true;
                 break;
             }
        }
        return false;
    }

    /**
     * [cleanString Replace all special characters]
     * @param  [string] $text [string]
     */
    function cleanString($text) {
        $utf8 = array(
            '/[Ã¡Ã Ã¢Ã£ÂªÃ¤]/u'   =>   'a',
            '/[ÃÃ€Ã‚ÃƒÃ„]/u'    =>   'A',
            '/[ÃÃŒÃŽÃ]/u'     =>   'I',
            '/[Ã­Ã¬Ã®Ã¯]/u'     =>   'i',
            '/[Ã©Ã¨ÃªÃ«]/u'     =>   'e',
            '/[Ã‰ÃˆÃŠÃ‹]/u'     =>   'E',
            '/[Ã³Ã²Ã´ÃµÂºÃ¶]/u'   =>   'o',
            '/[Ã“Ã’Ã”Ã•Ã–]/u'    =>   'O',
            '/[ÃºÃ¹Ã»Ã¼]/u'     =>   'u',
            '/[ÃšÃ™Ã›Ãœ]/u'     =>   'U',
            '/Ã§/'           =>   'c',
            '/Ã‡/'           =>   'C',
            '/Ã±/'           =>   'n',
            '/Ã‘/'           =>   'N',
            '/â€“/'           =>   '-', // UTF-8 hyphen to "normal" hyphen
            '/[â€™â€˜â€¹â€ºâ€š]/u'    =>   '', // Literally a single quote
            '/[â€œâ€Â«Â»â€ž]/u'    =>   '', // Double quote
            '/ /'           =>   '', // nonbreaking space (equiv. to 0x160)
            '/,/'           =>   '',
        );
        return htmlspecialchars(preg_replace(array_keys($utf8), array_values($utf8), $text), ENT_COMPAT | ENT_HTML401 | ENT_QUOTES);
    }
    
    function prepare_calendar_data($def){
		$key_array = array_keys(($def[0] ?? array()));

		header("Content-type:text/xml");
		print("<?xml version=\"1.0\"  encoding=\"UTF-8\"?>");
        print("<data>");
        
		foreach ($def as $row_val) {
			print("<event id='".$row_val['id']."'>");
				foreach($key_array as $key) {
					if ($key != 'id') {
                        print("<".$key."><![CDATA[");
    					   print($row_val[$key]);
    					print("]]></".$key.">");
                    }
				}
			print("</event>");
		}

		print("</data>");
	}

    function prepare_graph_data($def, $xaxis_col, $yaxis_col, $chart_data) {
		$key_array = array_keys(($def[0] ?? array()));
        $show_date_type = 0; // 0 -> no date chart; 1 -> show only date, 2 -> show date time in 1st hour and then only hour
        
		$data_size = sizeof($def);
		if ($chart_data == 'd') {
			$first_date = $def[0][$xaxis_col];
			$second_date = $def[1][$xaxis_col];
			$granularity = strtotime($second_date) - strtotime($first_date);
			
            if ($granularity == 3600) {
                if ($data_size <= 48) {
                    $interval_size = 1;
                    $show_date_type = 2;
                } else if ($data_size > 48 and ($data_size/49) < 48) {
                    $interval_size = 24;
                    $show_date_type = 1;
                } else {
                    $interval_size = ($data_size/49) + 1;
                    $show_date_type = 1;
                }
            } else if ($granularity > 3600) {
				if ($data_size < 48) {
                    $interval_size = 1;
                    $show_date_type = 1;
                } else {
                    $interval_size = ($data_size/49) + 1;
                    $show_date_type = 1;
                }
			}
        } else if ($chart_data == 'n') {
			if ($data_size < 48) {
				$interval_size = 1;
				$show_date_type = 1;
			} else {
				$interval_size = ($data_size/49) + 1;
				$show_date_type = 1;
			}
		} else {
			$interval_size = 1;
		}
        
		$xaxis_col_arr = array();
        $xaxis_col_arr = explode(",", strtolower($xaxis_col));
		$yaxis_col_arr = array();
        $yaxis_col_arr = explode(",", strtolower($yaxis_col));
		$grouping_columns = array();
		$grouping_columns = array_merge($yaxis_col_arr,$xaxis_col_arr);
        
		header("Content-type:text/xml");
		print("<?xml version=\"1.0\"  encoding=\"UTF-8\"?>");
        print("<data>");
        
        $cnt = 1;
		foreach ($def as $row_val) {
			print("<item id='".$cnt."'>");
                foreach($grouping_columns as $group) {
                    foreach($key_array as $key) {
                        if ($key == $group) {
                            print("<".$key."><![CDATA[");
								if ($chart_data == 'd' && $key == $xaxis_col) {
									$new_date = Date($row_val[$key]);
									$date_val = date('Y', strtotime($new_date)) . '-' . date('m', strtotime($new_date)) . '-' . date('d', strtotime($new_date));
									$time_val = date('H', strtotime($new_date)) . ':' . date('i', strtotime($new_date));
								
									if($show_date_type == 1) {
                                        if(($cnt-1)%$interval_size > 0) {
											print('');
										} else {
											print($date_val);
										} 
									} else if ($show_date_type == 2) {
										if ($time_val == '00:00') {
											print($date_val);
										} else {
											print($time_val);
										}
									}
								} else if ($chart_data == 'n') {
									if($key == $xaxis_col && ($cnt-1)%$interval_size > 0) {
										print('');
									} else {
										print($row_val[$key]);
									} 
								} else {
									print $row_val[$key];
								}
							print("]]></".$key.">");
                        }
                    }
                }
			print("</item>");
			$cnt++;
		}

		print("</data>");
    }
?>