<?php
	ob_start();
	include 'components/include.file.v3.php';

	$sp_url = (isset($_POST["sp_url"]) && !empty($_POST["sp_url"])) ? $_POST["sp_url"] : "";
        $grid_obj_name = (isset($_POST["grid_obj_name"]) && !empty($_POST["grid_obj_name"])) ? $_POST["grid_obj_name"] : "";
       function_load_grid_data($sp_url,$grid_obj_name);


	function function_load_grid_data($grid_sp,$grid_obj_name) {
           $grid_name= $grid_obj_name;
		if ($grid_sp != '') {
				$grid_array = readXMLURL2($grid_sp);
		        $total_count = sizeof($grid_array);

		        $json_data = '';
		        $json_data = '{"total_count":"' . $total_count . '", "pos":"0", "data":[';
		        $string_array = array();
		        if (is_array($grid_array) && sizeof($grid_array) > 0) {
		            foreach ($grid_array as $js_array) {
		                $string = '{ ';
		                $i = 0;
		                foreach ($js_array as $key => $value) {
		                  if ($i == 0) {
		                    $string .= '"' . $key . '":' . '"' . $value . '"';
		                  } else {
		                      $string .= ',"' . $key . '":' . '"' . $value . '"';
		                  }
		                  $i++;
		                }
		                $string .= '}';
		                array_push($string_array, $string);
		            }
		        }
		        $json_data .= implode(", \n",$string_array) . ']}';
		        $linked_datasource_jsoned = $json_data;
			} else {
				$linked_datasource_jsoned = '{ rows:[]}';
			}

	        $grid_data = $linked_datasource_jsoned;

	        $html_string = '';

	        $html_string .= '		var jsoned_data = ' . $grid_data . ';';

			// do not comment this line, it is enabled in all cases and if function is made for this it must be called after grid.init()/return_init()
	        $html_string .= $grid_name . '.enableHeaderMenu();';

        	$html_string .= '		try {';
	        $html_string .= 			$grid_name . '.parse(jsoned_data, "js");';
	        $html_string .= '		} catch (exception) {';
	        $html_string .= '			alert("parse json exception.");';
	        $html_string .= '		}';
ob_get_clean();
	        echo json_encode($html_string);
	}

	
?>