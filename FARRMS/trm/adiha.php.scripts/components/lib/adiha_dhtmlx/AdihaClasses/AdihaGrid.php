<?php
	/**
     *  @brief AdihaGrid
     *  
     *  @par Description
     *  This class is used to generate a grid
     *  
     *  @copyright Pioneer Solutions
     */
	class AdihaGrid {
		public $grid_name;
		public $set_search_filter;
		public $grid_sp;
		public $name_space;
		public $headers;		
		private $grouping_column;
		private $auto_adjust;
		private $grid_type;
        private $column_type;
        private $columns_alignment;
        public $connector_enabled = false;
	
		/**
		 * Initialize the grid by calling grid object - to be used, when grid is used alone.
		 * @param  String $grid_name 	Name of Grid
         * @param  String $namespace 	Same name to be used in all components in a form
		 * @return String 				JS to initialize grid
		 */
		public function init_grid($grid_name, $namespace) {
			$this->name_space = $namespace;
		    $this->grid_name = $this->name_space . "." . $grid_name;
	        $html_string = $grid_name . " = new dhtmlXGridObject('" . $grid_name . "'); " . "\n";

	        return $html_string;
		}

		/**
		 * Initialize the grid by attaching to another object - to be used, when grid is attached to other components.
		 * @param String $grid_name 	Name of Grid
		 * @param String $namespace 	Namespace
		 * @return String 				JS to initialize grid attached
		 */
		public function init_by_attach($grid_name, $namespace) {
			global $image_path;
			$this->name_space = $namespace;
		    $this->grid_name = $this->name_space . "." . $grid_name;
		    $html_string = $this->grid_name . '.setImagePath("' . $image_path . 'dhxgrid_web/");' . "\n";
		    return $html_string;
		}

		/**
		 * Set headers to a grid.
		 * @param String $headers 	Comma separated list of headers
		 * @param Boolean $translate Translate to locale
		 * @return String JS to set grid headers
		 */
		public function set_header($headers, $column_alignment = '', $translate = true) {
			$this->headers = $headers;
			
			if ($translate) {
				$headers = 'get_locale_value("' . $headers . '", true)';
			}
			$headers = str_replace("'", "\'", $headers);
			// To Fix comma in header didn't work when escaped single time when grid created from PHP
			$headers = str_replace("\,", "\\\\,", $headers);
			
			if (!$translate) {
				$headers = "'" . $headers . "'";
			}

            $column_header_alignment = '';
            if ($column_alignment != '') {
                $columns_alignment = explode(",", $column_alignment);
				
				$columns_size = sizeof($columns_alignment);
                for ($i = 0; $i < $columns_size; $i++) {
                    $column_header_alignment .= ', "text-align:' . $columns_alignment[$i] . ';"';
        		}
                
                $column_header_alignment = trim($column_header_alignment, ",");
                $column_header_alignment = '[' . $column_header_alignment . ']';

                $this->columns_alignment = $column_header_alignment;
                $html_string = $this->grid_name . ".setHeader(" . $headers . ", null, " . $column_header_alignment . "); " . "\n";
                $html_string .= $this->set_column_alignment($column_alignment);
            } else {
                $html_string = $this->grid_name . ".setHeader(" . $headers . "); " . "\n";
            } 
	        
            return $html_string;
		}

		/**
		 * Set widths for grid columns.
		 * @param String $widths Comma separated list of column widths
		 * @return String JS to set initial widths
		 */
		public function set_widths($widths) {
	        $html_string = $this->grid_name . ".setInitWidths('" . $widths . "'); " . "\n";
	        return $html_string;
		}


		/**
		 * Adjust Column Sizes.
		 * @return String JS to adjust column size
		 */
		public function adjust_column_widhts() {
			$header_array = array();
			$header_array = explode(",", $this->column_type);
			$html_string = '';

			for ($i = 0; $i < sizeof($header_array); $i++) {
				$html_string .=  $this->grid_name . '.adjustColumnSize(' .$i . ');' . "\n";
			}

			return $html_string;
		}

		/**
		 * Set column alignment.
		 * @param String $col_align Comma separated list of columns alignment eg. left,center,right
		 * @return String JS to set column alignment
		 */
		public function set_column_alignment($col_align) {
	        $html_string = $this->grid_name . ".setColAlign('" . $col_align . "'); " . "\n";
	        return $html_string;
		}

		/**
		 * Set columns types.
		 * @param String $col_types Comma separated list of columns types.
		 *                      Available Column Type - Options
	     *                      	* ro - read only,
	     *                      	* ed - single line editor
	     *                      	* txt - multi-line editor
	     *                      	* ch - Checkbox . Treats 1 as checked, 0 as not checked.
	     *                      	* ra - Radio button (column oriented)
	     *                      	* ra_str - row oriented radio button
	     *                      	* combo - Combo box
	     *                      	* coco - Select box
		 * @return String JS to set column types
	     */
		public function set_column_types($col_types) {
            $this->column_type = $col_types;
	        $html_string = $this->grid_name . '.setColTypes("' . $col_types . '".replace(/, */g , ",")); ';
	        return $html_string;
		}

		/**
		 * Set Column Ids.
		 * @param String $columns_ids Comma separated list of column ids
		 * @return String JS to set columns id
		 */
		public function set_columns_ids($columns_ids) {
			$html_string = $this->grid_name . '.setColumnIds("' . $columns_ids . '".replace(/, */g , ","));' . "\n";
			return $html_string;
		}

		/**
		 * Set sorting preferences.
		 * @param String $sorting_pref Comma separated list of sorting preferences for each columns
		 * <p>Available options 
		 * 				* int - Integer
		 * 				* str - String
		 * 				* na  - unsortable columns
		 * 				* str - string </p>
		 * @return String JS to set column sorting
		 */
		public function set_sorting_preference($sorting_pref) {
	        //** This portion is for the sorting of the 'NULL' sorting preference
	        $sort_array = array();
			$sort_array = explode(",", $sorting_pref);
			for($i = 0; $i < sizeof($sort_array); $i++) {
				if ($sort_array[$i] == 'NULL') { 
	        		if ($this->connector_enabled) $sort_array[$i] = "connector";
                	else $sort_array[$i] = 'str';	      	
	        	} else {
	        		if ($this->connector_enabled) $sort_array[$i] = "connector";
	        	}
			}
	        $sorting_pref = implode(",", $sort_array);
	        //**
	        $html_string = $this->grid_name . ".setColSorting('" . $sorting_pref . "'); " . "\n";
	        return $html_string;
		}

		/**
		 * Set auto size ON/OFF - adjusts column size to make all content visible on the header doublclick.
		 * @return String JS to enable column auto size
		 */
		public function set_column_auto_size() {
			$html_string = $this->grid_name . ".enableColumnAutoSize(true); " . "\n";
	        return $html_string;
		}

		/**
		 * Set search filters.
		 * @param Boolean $auto_set True/false, if true then will automatically set the text box filter at the top of grid
		 *                            			 , if false then needs to supply the text filters
		 * @param String  $search_filters Comma separated filter list
		 *    Available values for filers 
		 *      * #text_filter    - input box   which value is used as a filtering mask;
		 *      * #select_filter  - select box  which value is used as a filtering mask;
		 *      * #combo_filter   - dhtmlxcombo which value is used as a filtering mask;
		 *      * #text_search    - input box   the nearest row that contains inputed text, becomes selected;
		 *      * #numeric_filter - input box   which value is used as a filtering mask; allows to use comparison operators in it,
		 *      					such as:
		 *            				 * equal to = N;
		 *							 * greater than > N;
		 *							 * lesser than < N;
		 *							 * lesser or equal ⇐ N;
		 *							 * greater or equal >= N;
		 *							 * range of values N1 .. N2
		 */
		public function set_search_filter($auto_set, $search_filters = null) {
			if ($auto_set) {
				$this->set_search_filter = true;
                $header_type = explode(",", $this->column_type);
                if ($header_type[0] == 'tree') {
                    if ($this->connector_enabled) $filter_string = "#connector_text_filter";
                	else $filter_string = "#text_filter";
                } else {
                if ($header_type[0] == 'ron' || $header_type[0] == 'ro_no' || $header_type[0] == 'ro_p' || $header_type[0] == 'edn' || $header_type[0] == 'ed_no') {
                        if ($this->connector_enabled) $filter_string = "#connector_text_filter";
                		else $filter_string = "#numeric_filter";
                    } else {
                        if ($this->connector_enabled) $filter_string = "#connector_text_filter";
                		else $filter_string = "#text_filter";
                    }
                }
				for ($i = 1; $i < sizeof($header_type); $i++) {
					 if ($header_type[$i] == 'ron' || $header_type[$i]== 'ro_no' || $header_type[$i]=='ro_p' || $header_type[$i]=='edn' || $header_type[$i]=='ed_no') {
                        if ($this->connector_enabled) $filter_string .= ",#connector_text_filter";
                		else $filter_string .= ",#numeric_filter";
                     } else {
                        if ($this->connector_enabled) $filter_string .= ",#connector_text_filter";
                		else $filter_string .= ",#text_filter";
                    }
				}
				$html_string = $this->grid_name . ".attachHeader('" . $filter_string . "'); " . "\n";
  	 	     
			} else {
				$html_string = $this->grid_name . ".attachHeader('" . $search_filters . "'); " . "\n";
			}
			return $html_string;
		}
		
		/**
		 * Enable auto hide of grid inline filter.
		 * @return String JS to enable filter auto hide
		 */
		public function enable_filter_auto_hide() {
			$html_string = $this->grid_name . ".enableFilterAutoHide(); " . "\n";
        	return $html_string;
		}

		/**
		 * Enable multiselect on grid. If not set, multiselect is not allowed.
		 * @return String JS to enable multiple row select
		 */
		public function enable_multi_select() {
			$html_string = $this->grid_name . ".enableMultiselect(true); " . "\n";
        	return $html_string;
		}

		/**
		 * Set User Data - used to save some extra information.
		 * @param String $row_id  Row Id - if send blank, save user data for grid, if not blank, set user data for row
		 * @param String $name    Name
		 * @param String $value   Value
		 * @return String		  JS to set user data
		 */
		public function set_user_data($row_id, $name, $value) {
			$html_string = $this->grid_name . ".setUserData('" . $row_id . "', '" . $name . "', '" . $value . "'); " . "\n";
        	return $html_string;
		}

		/**
		 * Includes additional data with the info about which rows were added and which ones deleted, enabled by default.
		 * @return String JS to submit added rows
		 */
		public function submit_added_rows() {
			$html_string = $this->grid_name . ".submitAddedRows(true); " . "\n";
        	return $html_string;
		}

		/**
		 * Enable drag/drop on grid. - if not set DND is not allowed.
		 * @param  Boolean $mercy_drag True/false 
		 *                             - True  - Enable drag and drop on grid without removing the original rows
		 *                             - False - Remove the original object on drag and drop
		 * @return String JS to enable drag and drop
		 */
		public function enable_DND($mercy_drag) {
			$html_string = $this->grid_name . ".enableDragAndDrop(true); " . "\n";
			
			if ($mercy_drag) {
				$html_string .= $this->grid_name . ".enableMercyDrag(true); " . "\n";
			}

			// disable column auto resize for drag drop grid.
			$html_string .= $this->grid_name . ".enableColumnAutoSize(false);" . "\n";
        	return $html_string;
		}

		/**
		 * Hide column - hide one column at a time using column index.
		 * @param  Integer $column_index Column Index
		 * @return String JS to set column hidden
		 */
		public function hide_column($column_index) {
			$html_string = $this->grid_name . ".setColumnHidden(" . $column_index . ", true); " . "\n";
			return $html_string;
		}

		/**
		 * Set column visibility - sets the list of visible/hidden columns.
		 * @param String $visibility_string A list of true/false separated by comma, false to show column, true to hide column
		 * @return String JS to set column visibility
		 */
		public function set_column_visibility($visibility_string) {
			$html_string = $this->grid_name . ".setColumnsVisibility('" . $visibility_string . "'); " . "\n";
			return $html_string;
		}

        /**
		 * Set column visibility - sets the list of header menu in popup menu which allows hidding/showing columns.
		 * @param String $visibility_string A list of true/false separated by comma
		 *                                 * False to show column
		 *                                 * True to hide column
		 * @return String JS to set header menu
		 */
		public function set_header_menu($visibility_string) {
			$html_string = $this->grid_name . ".enableHeaderMenu('" . $visibility_string . "'); " . "\n";
			return $html_string;
		}

		/**
		 * Enable paging.
		 * @param  Ingeger $page_size    Page Size
		 * @param  String  $paging_area  Paging div id - usually generated while attaching statusbar to layout
		 * @return String JS to enable paging
		 */
		public function enable_paging($page_size, $paging_area, $show_page_per_select = 'true') {
			$page_per_array = range(10, max($page_size, 100), 10);
			if (!in_array($page_size, $page_per_array)) {
			    array_push($page_per_array, $page_size);
			    sort($page_per_array);
			}
			if ($show_page_per_select == true) {
				$html_string  = $this->grid_name . ".setPagingWTMode(true,true,true," . json_encode($page_per_array) . ");" . "\n";
			} else {
				$html_string  = $this->grid_name . ".setPagingWTMode(true,true,true," . $show_page_per_select . ");" . "\n";
			}
			
			$html_string .= $this->grid_name . ".enablePaging(true, " . $page_size . ", 0, '" . $paging_area . "'); " . "\n";
			$html_string .= $this->grid_name . ".setPagingSkin('toolbar'); " . "\n";
			return $html_string;
		}
        
        /**
		 * Enable Header Menu.
		 * @return String JS to enable header menu
		 */
        public function enable_header_menu($header_menu_list = '') {
        	if ($header_menu_list == '') {
        		$html_string = $this->grid_name . '.enableHeaderMenu();' . "\n";
        	} else {
        		$html_string = $this->grid_name . '.enableHeaderMenu("' . $header_menu_list . '");' . "\n";
        	}
	        
	        return $html_string;
		}

		/**
		 * Return grid init statement.
		 * @return String JS grid initialize
		 */
		public function return_init($visibility_string = '', $enable_header_menu = '', $dummy_grid = false) {
			global $DECIMAL_SEPARATOR, $GROUP_SEPARATOR;
			$html_string = $this->grid_name . ".init(); " . "\n";
			if ($visibility_string != '')	{
				$html_string .= $this->set_column_visibility($visibility_string);
			}
            
            if ($enable_header_menu != '')	{
				$html_string .= $this->set_header_menu($enable_header_menu);
			} else {
			     $html_string .= $this->grid_name . ".enableHeaderMenu();" . "\n";
			}
	        
	        if (!$dummy_grid) {
		        $html_string .= $this->grid_name . ".i18n.decimal_separator = '" . $DECIMAL_SEPARATOR . "';" . "\n";
		        $html_string .= $this->grid_name . ".i18n.group_separator = '" . $GROUP_SEPARATOR . "';" . "\n";

				$html_string .= ' var grid_id = ' . $this->grid_name . '.getUserData("", "grid_id");' . "\n";
	        	$html_string .= ' if (grid_id != null && grid_id != "") {' . "\n";
	    		$html_string .= 		$this->grid_name . ".loadOrderFromCookie(grid_id); " . "\n";
				$html_string .= 		$this->grid_name . ".loadHiddenColumnsFromCookie(grid_id); " . "\n";
				$html_string .= 		$this->grid_name . ".enableOrderSaving(grid_id,cookie_expire_date); " . "\n";
				$html_string .= 		$this->grid_name . ".enableAutoHiddenColumnsSaving(grid_id,cookie_expire_date); " . "\n";
	        	$html_string .= ' } else {' . "\n";
				$html_string .= 		$this->grid_name . ".loadOrderFromCookie('" . $this->grid_name . "'); " . "\n";
				$html_string .= 		$this->grid_name . ".loadHiddenColumnsFromCookie('" . $this->grid_name . "'); " . "\n";
				$html_string .= 		$this->grid_name . ".enableOrderSaving('" . $this->grid_name . "',cookie_expire_date); " . "\n";
				$html_string .= 		$this->grid_name . ".enableAutoHiddenColumnsSaving('" . $this->grid_name . "',cookie_expire_date); " . "\n";
				$html_string .= ' }' . "\n";
			}
			return $html_string;
		}

		/**
		 * Split and fixed columns.
		 * @return String JS to split grid
		 */
		public function split_grid($split_at) {
			$html_string = $this->grid_name . ".splitAt(" . $split_at . "); " . "\n";
			return $html_string;
		}

		/**
		 * Enable Column Move by drag and drop.
		 * @param String $boolean_columns_list Boolean list for each columns to allow and deny column moving (Optional)
		 * @param String $control_move		   Attach event when a column moving operation starts if only parameter passed otherwise no event attached (Optional)
		 * @return String JS to enable column move
		 */
		public function enable_column_move($boolean_columns_list = '', $control_move = '') {
			if ($boolean_columns_list != '') {
				$html_string = $this->grid_name . ".enableColumnMove(true, '" . $boolean_columns_list ."'); " . "\n";
			} else {
				$html_string = $this->grid_name . ".enableColumnMove(true); " . "\n";
			}

			if ($control_move != '') {
				$html_string .= $this->grid_name . '.attachEvent("onBeforeCMove",function(cInd, newPos){' . "\n";
				$html_string .= ' 	var col_type = ' . $this->grid_name . '.getColType(0);' . "\n";
				$html_string .= '		if (col_type == "tree") {' . "\n";
				$html_string .=	' 			if (cInd < 3 || newPos < 3) return false;' . "\n";
				$html_string .=	' 			else return true;' . "\n";
				$html_string .= '     	} else {' . "\n";
				$html_string .=	' 			if (cInd < 2 || newPos < 2) return false;' . "\n";
				$html_string .=	' 			else return true;' . "\n";	
				$html_string .= '     	}' . "\n";			
				$html_string .= '});' . "\n";
			}
			return $html_string;
		}

		/**
		 * Load Grid data.
		 * @param  String  $grid_sp     Grid SP
		 * @param  String  $key_prefix  Prefix used to cache grid Sp result set. Optional parameter
		 * @param  String  $key_suffix  SUffix used to cache grid Sp result set. Optional parameter
		 * @return String JS to load grid data
		 */
		public function load_grid_data($grid_sp, $grid_type = 'g', $grouping_column = '', $auto_adjust = false, $callback_function = '', $key_prefix = '', $key_suffix = '') {
			$this->grid_sp = $grid_sp;
			$this->grid_type = $grid_type;
			$this->grouping_column = $grouping_column;
			$this->auto_adjust = $auto_adjust;
			
			$html_string  = 'var sql_param = {' . "\n";
	        $html_string .= '    "sql":"' . $grid_sp .'",' . "\n";
	        $html_string .= '    "grid_type":"' . $grid_type . '",' . "\n";
	        $html_string .= '    "key_prefix":"' . $key_prefix . '",' . "\n";
	        $html_string .= '    "key_suffix":"' . $key_suffix . '"' . "\n";

	        if ($grid_type == 'tg') {
	        	$html_string .= '    ,"grouping_column":"' . $grouping_column . '"' . "\n";
	        }
	        $html_string .= '};' . "\n";

	        $html_string .= 'sql_param = $.param(sql_param);' . "\n";
	        $html_string .= 'var sql_url = js_data_collector_url + "&" + sql_param;' . "\n";
	        //$html_string .= $this->grid_name . '.clearAll();' . "\n";
	        
	        if ($auto_adjust == true) {
	        	$html_string .= $this->grid_name . '.load(sql_url, function() {' . "\n";
    	        if ($auto_adjust) {
    	           $html_string .= $this->adjust_column_widhts();
    	        }
    	        if ($callback_function != ''){
    	           $html_string .= 'eval('.$callback_function . '());';   
    	        }
                $html_string .= '});' . "\n";
	        } else {
	        	if ($callback_function != ''){
    	           $html_string .= $this->grid_name . '.load(sql_url, ' . $callback_function . ');' . "\n"; 
    	        } else {
    	        	$html_string .= $this->grid_name . '.load(sql_url);' . "\n";
    	        }	        	
	        }
	        
	        return $html_string;
        }

        /**
         * Combo on grid.
         * @param  String  $combo_id Column Id in grid
         * @param  String  $data     Combo data 
         *                        	eg: {options:[{value: "1", img: "austria.png", text: "Austria"}{value: "2", img: "cameroon.png", text: "Cameroon"}]}
         * @note This functions should be after return_init function.
		 * @return String JS to load combo data
         */
        public function load_combo($combo_id, $data) {
        	$html_string = 'var colIndex = ' . $this->grid_name . '.getColIndexById("' . $combo_id . '");' . "\n";
			$html_string .= 'var ' . str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . ' = ' . $this->grid_name . '.getColumnCombo(colIndex);' . "\n";
			$html_string .=  str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . '.enableFilteringMode("between", null, false);' . "\n";
			if ($data != '') {
				$html_string .=  str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . '.load(' . $data . ');' . "\n";
			}
			return $html_string;
        }

        /**
         * Load Combo on grid using connector.
         * @param  String $combo_id  Column Id in grid
         * @param  String $url       JSON URL eg: dropdown.connector.v2.php?application_field_id=74484
         * @note This functions should be after return_init function.
		 * @return String JS to load combo using connector
         */
        public function load_connector_combo($combo_id, $url) {
        	global $app_php_script_loc;
        	$html_string = 'var colIndex = ' . $this->grid_name . '.getColIndexById("' . $combo_id . '");' . "\n";
			$html_string .= 'var ' . str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . ' = ' . $this->grid_name . '.getColumnCombo(colIndex);' . "\n";
			$html_string .=  str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . '.enableFilteringMode("between", null, false);' . "\n";

			if ($url != '') {
				$html_string .=  str_replace($this->name_space.".", "", $this->grid_name) . '_column_object_' . $combo_id . '.load("' . $app_php_script_loc . $url . '&_csrf_token=' . $_COOKIE['_csrf_token'] . '");' . "\n";
			}
			return $html_string;
        }

        /**
         * Deletes all rows in the grid.
		 * @return String JS to clear grid data
         */
        public function set_clear() {
            $html_string = $this->grid_name . '.clearAll();' . "\n";
            return $html_string;
        }

        /**
         * Adds any user-defined handler to available events.
         * @param String $event_id 	     Variable name to store event
         * @param String $event_name     Name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxgrid_events.html
         * @param String $event_function User defined function name, which will be called on particular event. This function can be defined in main page itself.
		 * @return String JS to attach grid event
         */
        public function attach_event($event_id = '', $event_name, $event_function) {
            if ($event_id == '') {
                    $html_string = $this->grid_name . '.attachEvent("'. $event_name . '", ' . $event_function . ');' . "\n";
            } else  {
                    $html_string = "var " . $event_id . "=" . $this->grid_name . ".attachEvent('". $event_name . "', " . $event_function . ");" . "\n";
            }
            return $html_string;
        }
        
        /**
         * Create the grid when JSON is passed.
         * @param String $grid_json JSON to build the Grid
		 * @return String JS to parse json data to grid
         */
        public function load_grid_json($grid_json) {
            $html_string = '';
            $html_string .= '	var jsoned_data = ' . $grid_json . ';' . "\n";
            $html_string .= '	try {' . "\n";
            $html_string .= 		$this->grid_name . '.parse(jsoned_data, "js");' . "\n";
            $html_string .= '	} catch (exception) {' . "\n";
            $html_string .= '		alert("parse json exception.");' . "\n";
            $html_string .= '	}' . "\n";

            return $html_string;
        }

        /**
         * Load Grid using config JSON.
         * @param  String  $config_json  JSON
         * @param  Boolean $clear        clear options
		 * @return String JS to load grid config
         */
        public function load_config_json($config_json, $clear = true, $header_menu = '') {
        	$html_string = 	$this->grid_name . '.parse(' . $config_json . ', "json");' . "\n";
        	if ($clear) {
        		$html_string .= $this->grid_name . '.clearAll();' . "\n";
        	}
        	if ($header_menu == '') {
        		$html_string .= $this->grid_name . ".enableHeaderMenu();" . "\n";
        	} else {
        		$html_string .= $this->grid_name . ".enableHeaderMenu('" . $header_menu . "');" . "\n";
        	}
			$html_string .= $this->grid_name . ".loadOrderFromCookie('" . $this->grid_name . "'); " . "\n";
			$html_string .= $this->grid_name . ".loadHiddenColumnsFromCookie('" . $this->grid_name . "'); " . "\n";
			$html_string .= $this->grid_name . ".enableOrderSaving('" . $this->grid_name . "', cookie_expire_date); " . "\n";
			$html_string .= $this->grid_name . ".enableAutoHiddenColumnsSaving('" . $this->grid_name . "', cookie_expire_date); " . "\n";
        	return $html_string;
        }
        
        /**
         * Load grid functions.
		 * @return String Script to load all grid functions
         */
        public function load_grid_functions_attach() {
            $html_string = '  <script>';
            $html_string .= $this->load_grid_functions();
            $html_string .= '  </script>';
            return $html_string;
        }

        /**
         * Javascript Functions for Grid.
		 * 
		 * @param	Boolean Use grid instance to attach functions
		 * 
		 * @return 	String 	JS grid functions
         */
        public function load_grid_functions($use_grid_instance = false) {            
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
            $html_string =  ($use_grid_instance ? $this->grid_name : $this->name_space) . '.refresh_grid = function(sp_url, callback_function, filter_param) {'. "\n";
            $html_string .= ' if (sp_url == "" || sp_url == undefined) { '. "\n";
			$html_string .= '	var sql_param = {' . "\n";
	        $html_string .= '    	"sql":"' . $this->grid_sp .'",' . "\n";
	        $html_string .= '    	"grid_type":"' . $this->grid_type . '"' . "\n";

	        if ($this->grid_type == 'tg') {
	        	$html_string .= '    ,"grouping_column":"' . $this->grouping_column . '"' . "\n";
	        }
	        $html_string .= '		};' . "\n";
			$html_string .= ' } else { '. "\n";
			$html_string .= '		sql_param = sp_url; '. "\n";
			$html_string .= ' };' . "\n";
            $html_string .= ' if (filter_param != "" && filter_param != undefined) { ' . "\n";
            $html_string .= '       var modified_sql = sql_param["sql"];
                                    modified_sql += ", @xml=\'" + filter_param + "\'"
                                    sql_param["sql"] = modified_sql; ' . "\n";
            $html_string .= ' } ' . "\n";
	        $html_string .= ' sql_param = $.param(sql_param);' . "\n";
	        $html_string .= ' var sql_url = js_data_collector_url + "&" + sql_param;' . "\n";
	        $html_string .= ' var grid_id = ' . $this->grid_name . '.getUserData("", "grid_id");' . "\n";
	        $html_string .= ' var grid_obj = ' .	$this->grid_name . '.getUserData("", "grid_obj");' . "\n";
	        $html_string .= ' var grid_label = ' .	$this->grid_name . '.getUserData("", "grid_label");' . "\n";
	        $html_string .= 	$this->grid_name . '.clearAll();' . "\n";

	        $html_string .= ' if(grid_id != null) {' . "\n";
	        $html_string .= 	$this->grid_name . '.setUserData("", "grid_id", grid_id);' . "\n";
	        $html_string .= 	$this->grid_name . '.setUserData("", "grid_obj", grid_obj);' . "\n";
	        $html_string .= 	$this->grid_name . '.setUserData("", "grid_label", grid_label);' . "\n";
	        $html_string .= ' }' . "\n";
	        
	        if ($this->auto_adjust) {
	        	$html_string .= $this->grid_name . '.load(sql_url, function() {' . "\n";
	        	$html_string .= $this->adjust_column_widhts();
	        	$html_string .= '	if (callback_function != "" && callback_function != undefined) {	' . "\n";
	        	$html_string .= '		eval(callback_function ());' . "\n";  
	        	$html_string .= '	}' . "\n";
	        	$html_string .= '});' . "\n";
	        } else {
	        	$html_string .= '	if (callback_function != "" && callback_function != undefined) {	' . "\n";	        	
	        	//$html_string .= 		$this->grid_name . '.load(sql_url, callback_function);' . "\n";
	        	$html_string .= 		$this->grid_name . '.load(sql_url, function() {' . "\n";
	        	$html_string .=               $this->grid_name . '.filterByAll();' . "\n";  
	        	$html_string .= '		eval(callback_function ());' . "\n";  
	        	$html_string .= '       });' . "\n";
	        	$html_string .= '	} else {' . "\n";
	        	$html_string .= 		$this->grid_name . '.load(sql_url, function(){' . "\n";
	        	$html_string .=               $this->grid_name . '.filterByAll();' . "\n";  
	        	$html_string .= '       });' . "\n";
	        	$html_string .= '	}' . "\n";
	        }

            $html_string .= '}'. "\n";
            
            /**
             * Add New Row.
             * @param String $default_value Default value in new added row. Eg: ['','','','0','0','0'] 
             */
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.add_grid_row = function(default_value) {'. "\n";
            $html_string .= '	var new_id = (new Date()).valueOf();'. "\n";
            $html_string .=		$this->grid_name . '.addRow(new_id, default_value, ' . $this->grid_name . '.getRowsNum());'. "\n";
            $html_string .=		$this->grid_name . '.selectRow(' . $this->grid_name . '.getRowIndex(new_id), false, false, true);'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * Delete selected row
             */
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.delete_grid_row = function() {'. "\n";
            $html_string .= '	var select_id = ' . $this->grid_name . '.getSelectedId();'. "\n";
            $html_string .= '	if (select_id != null) {'. "\n";
            $html_string .=			$this->grid_name . '.deleteSelectedRows();'. "\n";
            $html_string .= '	}'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * To get data from dhtmlx grid in FARRMS standard XML format.
             */
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.get_grid_data = function() {'. "\n";
            $html_string .= '	var ps_xml = "<Root>";'. "\n";
            $html_string .= '	for (var row_index=0; row_index < ' . $this->grid_name . '.getRowsNum(); row_index++) {'. "\n";
            $html_string .= '		ps_xml = ps_xml + "<PSRecordset ";'. "\n";
            $html_string .= '		for(var cellIndex = 0; cellIndex < ' . $this->grid_name . '.getColumnsNum(); cellIndex++){'. "\n";
            $html_string .= '			ps_xml = ps_xml + " " + ' . $this->grid_name . '.getColumnId(cellIndex) + \'="\' + ' . $this->grid_name . '.cells2(row_index,cellIndex).getValue() + \'"\';'. "\n";
            $html_string .= '		}'. "\n";
            $html_string .= '		ps_xml = ps_xml + " ></PSRecordset> ";'. "\n";
            $html_string .= '	}'. "\n";
            $html_string .= '	ps_xml = ps_xml + "</Root>";'. "\n";
            $html_string .= '	return ps_xml;'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * To get value of choosen cell of selected rows.
             * @param cell_id Integer  Column Index
             */
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.get_grid_cell_value = function(cell_id) {'. "\n";
            $html_string .= '	var selected_row = ' . ($use_grid_instance ? $this->grid_name : $this->name_space) . '.get_grid_selected_row();'. "\n";
            $html_string .= '	var cell_value = "";'. "\n";
            $html_string .= '	if (selected_row.indexOf(",") != -1) {'. "\n";
            $html_string .= '		var selected_row_array = new Array();'. "\n";
            $html_string .= '		var cell_value_array = new Array();'. "\n";
            $html_string .= '		selected_row_array = selected_row.split(",");'. "\n";
            $html_string .= '		$.each(selected_row_array, function(index, value){'. "\n";
            $html_string .= '			cell_value_array.push(' . $this->grid_name . '.cells(value, cell_id).getValue());'. "\n";
            $html_string .= '		});'. "\n";
            $html_string .= '		cell_value = cell_value_array.join(",");'. "\n";
            $html_string .= '	} else {'. "\n";
            $html_string .= '		cell_value = ' . $this->grid_name . '.cells(selected_row, cell_id).getValue();'. "\n";
            $html_string .= '	}'. "\n";
            $html_string .= '	return cell_value;'. "\n";
            $html_string .= '}'. "\n";
            
            
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.get_all_grid_cell_value = function(cell_id) {'. "\n";
           
            $html_string .= '	var cell_value = "";'. "\n";
        
            $html_string .= '		var cell_value_array = new Array();'. "\n";
        
            $html_string .= '	for (var row_index=0; row_index < ' . $this->grid_name . '.getRowsNum(); row_index++) {'. "\n";
       
            $html_string .= '			cell_value_array.push(' . $this->grid_name . '.cells2(row_index,cell_id).getValue());'. "\n";
         
            $html_string .= '		};'. "\n";
            $html_string .= '		cell_value = cell_value_array.join(",");'. "\n";
            $html_string .= '	return cell_value;'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * To get selected rows.
             */
            $html_string .= ($use_grid_instance ? $this->grid_name : $this->name_space) . '.get_grid_selected_row = function() {'. "\n";
            $html_string .= '	var selected_row = ' . $this->grid_name . '.getSelectedRowId();'. "\n";
            $html_string .= '	return selected_row;'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * To delete all rows from the grid.
             */
            $html_string .=  ($use_grid_instance ? $this->grid_name : $this->name_space) . '.grid_flush = function() {'. "\n";
            $html_string .= '	var clear = ' . $this->grid_name . '.clearAll()'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * To validate grid data.
             */
			 $html_string .=  $this->name_space . '.validate_form_grid = function(attached_obj,grid_label,call_from) {;'. "\n";
			 $html_string .= ' 		var status = true;'. "\n";
			 $html_string .=  '		for (var i = 0;i < attached_obj.getRowsNum();i++){'. "\n";
			 $html_string .= ' 			var row_id = attached_obj.getRowId(i);'. "\n";
			 $html_string .= ' 			var no_of_child = ""; '. "\n";
			 $html_string .= ' 			if (call_from == "deal") {'. "\n";
			 $html_string .= ' 				no_of_child =  attached_obj.hasChildren(row_id);'. "\n";
			 $html_string .= ' 			}'. "\n";
			 $html_string .= ' 			call_from = (call_from && typeof call_from != "undefined") ? call_from : "";'. "\n";
			 $html_string .= '			if (call_from == "" || (call_from == "deal" && no_of_child == 0)) {'. "\n";
			 $html_string .= ' 			 for (var j = 0;j < attached_obj.getColumnsNum();j++){ '. "\n";
			 $html_string .= '				var type = attached_obj.getColType(j);'. "\n";
			 $html_string .= '				if (type == "combo") {'. "\n";
			 $html_string .= '					combo_obj = attached_obj.getColumnCombo(j);'. "\n";
			 $html_string .= '					var value = attached_obj.cells(row_id,j).getValue();'. "\n";
			 $html_string .= '					var selected_option = combo_obj.getIndexByValue(value);'. "\n";
			 $html_string .= '					if (selected_option == -1) {'. "\n";
			 $html_string .= '						var message = "Invalid Data";'. "\n";
			 $html_string .= '						attached_obj.cells(row_id,j).setAttribute("validation", message);'. "\n";
			 $html_string .= '						attached_obj.cells(row_id, j).cell.className = " dhtmlx_validation_error";'. "\n";
			 $html_string .= '					} else {'. "\n";
			 $html_string .= '						attached_obj.cells(row_id,j).setAttribute("validation", "");'. "\n";
			 $html_string .= '						attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");'. "\n";
			 $html_string .= '					}'. "\n";
			 $html_string .= '				}'. "\n";
			 $html_string .= ' 				var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");'. "\n";
			 $html_string .= ' 				if(validation_message != "" && validation_message != undefined){'. "\n";
			 $html_string .= ' 					var column_text = attached_obj.getColLabel(j);'. "\n";
			 $html_string .= '					show_messagebox("Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.");'. "\n";
 			 $html_string .= ' 					status = false; break;'. "\n";
			 $html_string .= ' 				}'. "\n";
			 $html_string .= ' 			}'. "\n";
			 $html_string .= ' 			}'. "\n";
			 $html_string .= '		if(validation_message != "" && validation_message != undefined){ break;};'. "\n";
			 $html_string .= ' 	}'. "\n";
			 $html_string .= ' return status;'. "\n";
			 $html_string .= '}'. "\n";
			
            return $html_string;
        }
	
		/**
		 * Set Validation Rule.
		 * @param String $validation_rule Comma separated list of validation rules for each columns. Available Validation Rules:http://docs.dhtmlx.com/grid__validation.html]
		 * @return String JS to set validation rules
		 */
		public function set_validation_rule($validation_rule){
			$html_string = $this->grid_name . '.enableValidation(true); ' . "\n";
            $html_string .= $this->grid_name . '.setColValidators("'.$validation_rule.'"); ' . "\n";
			$html_string .= $this->grid_name . '.attachEvent("onValidationError",function(id,ind,value){'. "\n";
			$html_string .= '		var message = "Invalid Data";'. "\n";
			$html_string .= 		$this->grid_name . '.cells(id,ind).setAttribute("validation", message);'. "\n";
			$html_string .= '		return true;'. "\n";
			$html_string .= '	});'. "\n";
			$html_string .= $this->grid_name . '.attachEvent("onValidationCorrect",function(id,ind,value){'. "\n";
			$html_string .= 		$this->grid_name . '.cells(id,ind).setAttribute("validation", "");'. "\n";
			$html_string .= '		return true;'. "\n";	
			$html_string .= '	});'. "\n";	
			return $html_string;
		}
		
		
		/**
		 * Set User and Server Date Format.
		 * @param String $cient_date_format  User date format displayed in the grid. Available date format: http://docs.dhtmlx.com/api__common_dateformat_other.html
		 * @param String $server_date_format Date format when submitting to database
		 * @return String JS to set date format
		 */
		public function set_date_format($cient_date_format,$server_date_format) {
	        $html_string = $this->grid_name . ".setDateFormat('" . $cient_date_format . "','" . $server_date_format . "'); " . "\n";
	        return $html_string;
		}
                
        /**
		 * Disable Grid for Editing.
		 * @return String JS to make grid uneditable
		 */
		public function disable_grid() {
			$html_string = $this->grid_name . ".setEditable(false); " . "\n";
			return $html_string;
		}

		/**
		 * Enable Context Menu.
		 * @param Object $menu_obj Enables/disables context menu
		 * @return String JS to enable context menu
		 */
		public function enable_context_menu($menu_obj) {
			$html_string = $this->grid_name . ".enableContextMenu(" . $menu_obj ."); " . "\n";
			return $html_string;
		}
	    
		/**
		 * Enable edit on events.
		 * @param Boolean $click 		Enable/disable editing by single click
		 * @param Boolean $double_click Enable/disable editing by double click
		 * @param Boolean $f2key 		Enable/disable editing by pressing F2 key
		 * @return String JS to enable edit events
		 */
		public function enable_cell_edit_events($click, $double_click, $f2key) {
			$html_string = $this->grid_name . ".enableEditEvents(" . $click . "," . $double_click . "," . $f2key . "); " . "\n";
			return $html_string;
		}
	
		/**
		 * Enable Smart Rendering.
		 * @return String JS to enable smart rendering
		 */
		public function enable_smart_rendering() {
			$html_string = $this->grid_name . ".enableSmartRendering(true); " . "\n";
			return $html_string;
		}

		/**
		 * Enables connector.
		 */
		public function enable_connector() {
			$this->connector_enabled = true;
		}
	
		/**
		 * Load Browser for the column.
		 * @param String $browser_column_id  Column ID
		 * @param String $browser_grid_name  Browser Name to be opened
		 * @return String JS to attach browser
		 */
		public function load_browser($browser_column_id, $browser_grid_name) {
        	$html_string = ' var data = {"' . $browser_column_id . '" : "' . $browser_grid_name . '"};' . "\n";
			$html_string .= $this->grid_name . ".attachBrowser(data);" . "\n";
			return $html_string;
		}

        /**
         * Enable copy/paste feature in the grid.
         * @param  Boolean $status Add new row if enabled
		 * @return String jS to copy from excel
         */
        public function copy_from_excel($status) {
            $html_string = $this->grid_name . ".copyFromExcel(" . $status ."); " . "\n";
            return $html_string;
		}
		
		public function set_no_header() {
			return $html_string = $this->grid_name . ".setNoHeader(true);" . "\n";
		}

        /**
         * Enable rounding at column level in grid
         * @param  String $rounding_values in CSV format
         * @return String Js to enable rounding in grid column
         */
        public function enable_rounding($rounding_values) {
            $html_string = $this->grid_name . ".enableRounding('" . $rounding_values ."'); " . "\n";
            return $html_string;
        }
	
	}
	
	
?>