<?php
    Class AdihaTree {
        public $tree_name;
        public $draghandler_function;
        public $parent_id_index;
        public $parent_label_index;
        public $child_id_index;
        public $child_label_index;
        public $sub_child_id_index;
        public $sub_child_label_index;
        public $linked_datasource_jsoned;
        public $name_space;

        /**
         * Initialize Tree.
         * @param  String       $tree_name    Tree Name, String without space
         * @param  Integer      $height       Height of tree
         * @param  Integer      $width        Width of tree
         * @param  String       $namespace    Same name to be used in all components in a form
         */
        public function init_tree($tree_name, $height, $width, $namespace) {
            global $app_php_script_loc, $app_adiha_loc;
            $this->name_space = $namespace;
            $this->tree_name = $this->name_space . "." . $tree_name;
            $html_string = '    <div id="' . $this->tree_name . '" style="background: white; width:' . $width . ';height:' . $height . ';scroll:auto;font-weight:normal;float:left;"></div>'. "\n";
            $html_string .= $this->tree_name . ' = new dhtmlXTreeObject("' . $this->tree_name . '","100%","100%",0);'. "\n";
            return $html_string;
        }

        /**
         * Initialize Tree when it is attached to other object.
         * @param  String $tree_name    Tree Name, string without space.
         * @param  String $namespace    Same name to be used in all components in a form
         */
        public function init_by_attach($tree_name, $namespace) {
            global $app_php_script_loc, $app_adiha_loc, $image_path;
            $this->name_space = $namespace;
            $this->tree_name = $this->name_space . "." . $tree_name;
            $html_string = $this->tree_name . '.setImagePath("' . $image_path . 'dhxtree_web/");'. "\n";
            return $html_string;
        }

        /**
         * Enable the checkbox.
         * @return  String html.
         */
        public function enable_checkbox() {
            $html_string = $this->tree_name . '.enableCheckBoxes(true);'. "\n";
            return $html_string;
        }

        /**
         * Enable drag and drop.
         * @param  Boolean  $root_dnd Allow root level drag and drop
         */
        public function enable_DND($root_dnd = 'false') {
            $html_string =  $this->tree_name . '.enableDragAndDrop(true, ' . $root_dnd . ');'. "\n";
            return $html_string;
        }

        /**
         * Sets Drag-And-Drop behavior.
         * @param String $behavior  Child - drop as child, Sibling - drop as sibling, Complex - Complex drop behaviour
         * @return  String html. 
         */
        public function set_drag_behavior($behavior) {
            $html_string =  $this->tree_name . '.setDragBehavior("' . $behavior . '");'. "\n";
            return $html_string;
        }
        
        /**
         * Enable_ext Drag the tree item out of tree component.
         * @param  Integer  $drop_area_id             ID of drop area
         * @param  String   $draghandler_function     Drag handler function name
         */
        public function enable_external_drag($drop_area_id, $draghandler_function) {
            $this->draghandler_function = $draghandler_function;
            $html_string =  $this->tree_name . '.enableDragAndDrop(true);'. "\n";
            $html_string .= $this->tree_name . '.enableDragAndDropScrolling(true);'. "\n";
            $html_string .= $this->tree_name . '.enableMercyDrag(true);'. "\n";

            $html_string .= $this->tree_name . '.setDragHandler(true);'. "\n";

            if ($drop_area_id != '') {
                $html_string .= 'var drag_area = document.getElementById("' . $drop_area_id . '");'. "\n";
                $html_string .= $this->tree_name . '.dragger.addDragLanding(drag_area, new tree_drag_handler);'. "\n";
            }

            return $html_string;
        }
        
        /**
         * Expand the parameter item in the tree.
         * @param  Integer $item_id id of component to expand
         * @return  String html.
         */
        public function expand_tree($item_id) {
            $html_string = $this->tree_name . '.openItem("'.$item_id.'");'. "\n";
            return $html_string;
        }

        /**
         * Adds any user-defined handler to available events.
         * @param Integer $event_id          Variable name to store event
         * @param String $event_name        Name of the event. Available event: http://docs.dhtmlx.com/api__refs__dhtmlxtree_events.html
         * @param String $event_function    User defined function name, which will be called on particular event. This function can be defined in main page itself.
         */
        public function attach_event($event_id = '', $event_name, $event_function) {
            if ($event_id == '') {
                    $html_string = $this->tree_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
            } else  {
                    $html_string = "var " . $event_id . "=" . $this->tree_name . ".attachEvent('". $event_name . "', $event_function);" . "\n";
            }
            return $html_string;
        }
        
        /**
         * Function called when right clicked on tree.
         * @param  String $function_name    Function name to call on right click
         */
        public function onright_click_function($function_name) {
            $html_string = $this->tree_name . '.setOnRightClickHandler(' . $function_name . ')'. "\n";
            return $html_string;
        }

        /**
         * Load the data from spa, build JSON and load in the tree.
         * @param  String    $grid_sp                  SP url
         * @param  Integer   $parent_id_index          Index of parent id
         * @param  Integer   $parent_label_index       Index of parent label
         * @param  Integer   $child_id_index           Index of child id
         * @param  Integer   $child_label_index        Index of child label
         * @param  Integer   $sub_child_label_index    Index of sub child id
         * @param  Integer   $sub_child_label_index    Index of sub child label
         * @return Html string.
         */
        public function load_tree_data($grid_sp, $parent_id_index, $parent_label_index, $child_id_index, $child_label_index, $sub_child_id_index, $sub_child_label_index) {
            $this->parent_id_index = $parent_id_index;
            $this->parent_label_index = $parent_label_index;
            $this->child_id_index = $child_id_index;
            $this->child_label_index = $child_label_index;
            $this->sub_child_id_index = $sub_child_id_index;
            $this->sub_child_label_index = $sub_child_label_index;

            global $app_php_script_loc, $app_adiha_loc;
            $grid_array = array();

            /* Building JSON */
            if ($grid_sp != '') {
                $grid_array = readXMLURL($grid_sp);

                $grouped_array = array();
                $key_array = array_keys($grid_array[0]);
                $grouping_key = $key_array[$parent_id_index];
                $child_array = array();
                $child_key = $key_array[$child_id_index];

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

                if (is_array($grid_array) && sizeof($grid_array) > 0) {
                    foreach ($grid_array as $js_array) {
                        if (!is_array($child_array[$js_array[$child_key]]))
                            $child_array[$js_array[$child_key]] = array();

                        $child_value_array = array();
                        $i = 0;
                        foreach ($js_array as $key => $value) {
                            if ($key == $child_key) {
                                $child_value_array[$key] = '';
                            } else {
                                $child_value_array[$key] = $value;
                            }
                        }
                        array_push($child_array[$js_array[$child_key]], $child_value_array);
                    }
                }

                $json_data = '';
                $json_data = "{ id: 0, item:[";
                $string_array = array();

                if (is_array($grouped_array) && sizeof($grouped_array) > 0) {
                    foreach ($grouped_array as $parent_key => $js_array) {
                        $string_array2 = array();
                        $string = "{id:'" . $parent_key . "', text:'" . $js_array[0][$parent_label_index] . "',item:[";
                        foreach ($child_array as $second_array => $ch_array) {
                            if ($parent_key == $ch_array[0][$parent_id_index] && $second_array != '') {
                                $string2 = " {id:'" . $second_array . "'" . ", text:'" . $ch_array[0][$child_label_index] . "',item:[";

                                $sub_child_array = array();
                                $i = 0;

                                foreach ($ch_array as $child_arr) {
                                    if ($child_arr[$sub_child_id_index] != '') {
                                        $string3 = " {id:'" . $child_arr[$sub_child_id_index] . "'" . ", text:'" . $child_arr[$sub_child_label_index] . "',item:[]}";
                                        //echo $string3;
                                        array_push($sub_child_array, $string3);
                                    }
                                    $i++;
                                }
                                $string2 .= implode(", \n", $sub_child_array) . "]}";
                                array_push($string_array2, $string2);
                            }
                        }
                        $string .= implode(", \n", $string_array2) . "]}";
                        array_push($string_array, $string);
                    }
                }
                $json_data .= implode(", \n", $string_array) . "]}";
                $this->linked_datasource_jsoned = $json_data;
            } else {
                $this->linked_datasource_jsoned = '{ id : 0, item:[]}';
            }
            
            $html_string =  $this->tree_name . '.setSkin("dhx_skyblue");'. "\n";
            
            $html_string .= ' var jsoned_data = ' . $this->linked_datasource_jsoned . ';'. "\n";
            $html_string .= $this->tree_name . '.loadJSONObject(jsoned_data);'. "\n";
            $html_string .= $this->tree_name . '.setDataMode("json");'. "\n";
            $html_string .= $this->load_tree_functions();
            return $html_string;
        }

        /**
         * Load tree data by preparing xml.
         * @param  String $action           Action name - SP
         * @param  String $value_list       Value combination, separated by colon - id and value combination of last child in tree - Eg. source_deal_header_id:deal_id
         * @param  type $grouping_list    Grouping combination. 
         *                                  id and value combination is separated by colon,
         *                                  where as multiple grouping columns combination is separated by comma
         *                                  Eg. "counterparty_id:counterparty,contract_id:contract" 
         *                                      - will create tree with first parent Counterparty and second parent contract
         * @param  String $additional_param Any additional parameters Eg. "calc_id=101&flag=u"
         */
        public function load_tree_xml($action, $value_list, $grouping_list, $additional_param = '') {
            global $app_php_script_loc;
            $html_string = 'var param = {' . "\n";
            $html_string .= '   "action":"' . $action . '",' . "\n";
            $html_string .= '   "grid_type": "t",' . "\n";
            $html_string .= '   "value_list": "' . $value_list . '",' . "\n";
            $html_string .= '   "grouping_column":"' . $grouping_list . '"' . "\n";
            $html_string .= '};' . "\n";
            $html_string .= 'param = $.param(param);' . "\n";
            $html_string .= ' var data_url = js_data_collector_url + "&" + param;' . "\n";

            if ($additional_param != '') {
                $html_string .= ' data_url += "&' . $additional_param . '";' . "\n";
            }
            $html_string .= $this->tree_name . '.loadXML(data_url);' . "\n";
            return $html_string;
        }

        public function load_tree_functions() {
            global $app_php_script_loc, $app_adiha_loc, $image_path;
            /**
             * Drag Handler function for drag and drop.
             */
            $html_string =  '   function tree_drag_handler() {'. "\n";
            $html_string .= '      this._drag=function(sourceHtmlObject,dhtmlObject,targetHtmlObject){'. "\n";
            $html_string .= '          targetHtmlObject.style.backgroundColor="white";'. "\n";
            $html_string .= '          var drag_item_id = sourceHtmlObject.parentObject.id;'. "\n";
            $html_string .= '          var parent_label = sourceHtmlObject.parentObject.parentObject.label;'. "\n";
            $html_string .= '          var drag_item_value = sourceHtmlObject.parentObject.label;'. "\n";
            $html_string .= '          if(parent_label == 0) {return 0;}'. "\n";
            if ($this->draghandler_function != '') {
                $html_string .= '              ' . $this->draghandler_function . '(drag_item_id, drag_item_value);'. "\n";
            }
            $html_string .= '      };'. "\n";
            $html_string .= '      this._dragIn=function(htmlObject,shtmlObject){'. "\n";
            $html_string .= '          return htmlObject;'. "\n";
            $html_string .= '      };'. "\n";
            $html_string .= '      this._dragOut=function(htmlObject){'. "\n";
            $html_string .= '          htmlObject.style.backgroundColor="";'. "\n";
            $html_string .= '          return this;'. "\n";
            $html_string .= '      }'. "\n";
            $html_string .= '   }'. "\n";

            /**
             * Refresh the tree.
             * @param String sp_url sp for refresh
             */
            $html_string .=         $this->name_space . '.refresh_tree = function(action, value_list, grouping_list, additional_param, callback_function) {'. "\n";
            $html_string .=         $this->tree_name . '.saveOpenStates("tree_open_state");' . "\n";
            $html_string .=         $this->tree_name . '.deleteChildItems(0);'. "\n";
            $html_string .=         $this->tree_name . '.setSkin("dhx_web");'. "\n";
            $html_string .=         $this->tree_name . '.setImagePath("' . $image_path . 'dhxtree_web/");'. "\n";
            //$html_string .=         $this->tree_name . '.setImagePath("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/adiha_tree_3.0/adiha_dhtmlxTree/codebase/imgs/dhxtree_web/");'. "\n";
            
            $html_string .= '       var param = {' . "\n";
            $html_string .= '           "action":action,' . "\n";
            $html_string .= '           "grid_type": "t",' . "\n";
            $html_string .= '           "value_list":value_list,' . "\n";
            $html_string .= '           "grouping_column":grouping_list' . "\n";
            $html_string .= '       };' . "\n";
            
            $html_string .= '       param = $.param(param);' . "\n";
            $html_string .= '       var data_url = js_data_collector_url + "&" + param;' . "\n";

            $html_string .= '       if (additional_param != undefined) { ' . "\n";
            $html_string .= '           data_url += "&" + additional_param;' . "\n";
            $html_string .= '       } ' . "\n";  

            $html_string .=         $this->tree_name . '.loadXML(data_url, function() {' ."\n";
            $html_string .=            $this->tree_name . '.loadOpenStates("tree_open_state");' ."\n";
            $html_string .= '           if (callback_function != undefined) { ' . "\n";
            $html_string .= '               eval("'.$this->name_space.'."+ callback_function + "()");'."\n";
            $html_string .= '           }' . "\n";
            $html_string .= '       });' . "\n"; 
            
            $html_string .= '   }'. "\n";

            
            //Check all the items in the tree.
             
            $html_string .=    $this->name_space . '.tree_check_all = function() {'. "\n";
            $html_string .=         $this->tree_name . '.setCheck(0, true);'. "\n";
            $html_string .= '  }'. "\n";

            
            //Uncheck all the items in the tree.
             
            $html_string .=    $this->name_space . '.tree_uncheck_all = function() {'. "\n";
            $html_string .=         $this->tree_name . '.setCheck(0, false);'. "\n";
            $html_string .= '  }'. "\n";

           
            //Expand all the nodes. 
             
            $html_string .=    $this->name_space . '.tree_expand_all = function() {'. "\n";
            $html_string .=         $this->tree_name . '.openAllItems(0);'. "\n";
            $html_string .= '  }'. "\n";

            
            //Collapse all the nodes. 
             
            $html_string .=    $this->name_space . '.tree_collapse_all = function() {'. "\n";
            $html_string .=         $this->tree_name . '.closeAllItems(0);'. "\n";
            $html_string .= '  };'. "\n";

            
            //Returns the id of the selected node.
             
            $html_string .=    $this->name_space . '.get_tree_selected_id = function() {'. "\n";
            $html_string .= '       var selected_id = ' . $this->tree_name . '.getSelectedItemId();'. "\n";
            $html_string .= '       return selected_id;'. "\n";
            $html_string .= '  }'. "\n";

            
            //Returns the text of the selected node.
             
            $html_string .=    $this->name_space . '.get_tree_selected_label = function() {'. "\n";
            $html_string .= '       var selected_label = ' . $this->tree_name . '.getSelectedItemText();'. "\n";
            $html_string .= '       return selected_label;'. "\n";
            $html_string .= '  }'. "\n";

            
            //Returns the hierarchy level of the selected node.
             
            $html_string .=    $this->name_space . '.get_tree_selected_level = function() {'. "\n";
            $html_string .= '       var selected_id = ' . $this->tree_name . '.getSelectedItemId();'. "\n";
            $html_string .= '       var level = ' . $this->tree_name . '.getLevel(selected_id);'. "\n";
            $html_string .= '       return level;'. "\n";
            $html_string .= '  }'. "\n";

            
            //Returns the parent id of selected node.
          
            $html_string .=    $this->name_space . '.get_tree_selected_parentid = function() {'. "\n";
            $html_string .= '       var selected_id = ' . $this->tree_name . '.getSelectedItemId();'. "\n";
            $html_string .= '       var parent_id = ' . $this->tree_name . '.getParentId(selected_id);'. "\n";
            $html_string .= '       return parent_id;'. "\n";
            $html_string .= '  }'. "\n";

            
            //Returns id of the checked item in array.
            //@level      type       Hierarchy level of tree which value is to be returned
            //                         Options-
            //                          0 - Return checked value in both parent and child level
            //                          1 - Return checked value in parent level     
            //                          2 - Return checked value in child level
             
            $html_string .=    $this->name_space . '.get_tree_checked_value = function(level, call_from) {'. "\n";
            $html_string .= '      if(call_from == "browser") { ';
            $html_string .= '           var all_checked_value = ' . $this->tree_name . '.getAllCheckedBranches();'. "\n";
            $html_string .= '      } else {';
            $html_string .= '           var all_checked_value = ' . $this->tree_name . '.getAllChecked();'. "\n";
            $html_string .= '      }';
            $html_string .= '      var checked_value = new Array();'. "\n";
            $html_string .= '      if (level == 0) {'. "\n";
            $html_string .= '          checked_value = all_checked_value;'. "\n";
            $html_string .= '      } else {'. "\n";
            $html_string .= '          var splited_value = all_checked_value.split(",");'. "\n";
            $html_string .= '          for(var i = 0; i <= splited_value.length; i++) {'. "\n";
            $html_string .= '              var item_level = ' . $this->tree_name . '.getLevel(splited_value[i]);'. "\n";
            $html_string .= '              if(item_level == level) {'. "\n";
            $html_string .= '                  checked_value.push(splited_value[i]);'. "\n";
            $html_string .= '              }'. "\n";
            $html_string .= '          }'. "\n";
            $html_string .= '      }'. "\n";
            $html_string .= '      return checked_value;'. "\n";
            $html_string .= '  }'. "\n";
            
            // *
            // * Returns label of the checked item in array.
            //* @level             Hierarchy level of tree which value is to be returned
            //*                       Options-
            //*                         0 - Return checked value in both parent and child level
            //*                         1 - Return checked value in parent level     
            //*                         2 - Return checked value in child level
             
            $html_string .=    $this->name_space . '.get_tree_checked_label = function(level, call_from) {'. "\n";
            $html_string .= '      if(call_from == "browser") { ';
            $html_string .= '           var all_checked_value = ' . $this->tree_name . '.getAllCheckedBranches();'. "\n";
            $html_string .= '      } else {';
            $html_string .= '           var all_checked_value = ' . $this->tree_name . '.getAllCheckedBranches();'. "\n";
            $html_string .= '      }';
            $html_string .= '      var checked_value = new Array();'. "\n";
            $html_string .= '      if (level == 0) {'. "\n";
            $html_string .= '          checked_value = all_checked_value;'. "\n";
            $html_string .= '      } else {'. "\n";
            $html_string .= '          var splited_value = all_checked_value.split(",");'. "\n";
            $html_string .= '          for(var i = 0; i <= splited_value.length; i++) {'. "\n";
            $html_string .= '              var item_level = ' . $this->tree_name . '.getLevel(splited_value[i]);'. "\n";
            $html_string .= '              if(item_level == level) {'. "\n";
            $html_string .= '                  var item_text = ' . $this->tree_name . '.getItemText(splited_value[i]);'. "\n";
            $html_string .= '                  checked_value.push(item_text);'. "\n";
            $html_string .= '              }'. "\n";
            $html_string .= '          }'. "\n";
            $html_string .= '      }'. "\n";
            $html_string .= '      return checked_value;'. "\n";
            $html_string .= '  }'. "\n";

            
            //Clear the tree selection. 
             
            $html_string .=    $this->name_space . '.get_tree_clear_selection = function() {'. "\n";
            $html_string .=         $this->tree_name . '.clearSelection();'. "\n";
            $html_string .= '  }'. "\n";

            /**
             * Enables/Disables Tree (Locks tree)
             * @param  boolean mode True enables the tree and vice versa.
             */
            $html_string .=    $this->name_space . '.enable_tree = function(mode) {'. "\n";
            $html_string .=         $this->tree_name . '.lockTree(!mode);'. "\n";
            $html_string .= '  }'. "\n";

            // Clears and Disables the tree
            // Clears selection in tree if any
            // Unchecks all nodes and locks the tree
             
            $html_string .=    $this->name_space . '.clear_and_disable_tree = function() {'. "\n";
            $html_string .=         $this->tree_name . '.clearSelection();'. "\n";
            $html_string .=         $this->tree_name . '.setCheck(0, false);'. "\n";
            $html_string .=         $this->tree_name . '.lockTree(true);'. "\n";
            $html_string .= '  }'. "\n";

            
            //Function to search item in book structure.
            
            $html_string .= 'search_tree = function() {'. "\n";
            $html_string .= '   var search_value = search_obj.value;'. "\n";
            $html_string .= '   var first_child = ' . $this->tree_name  . '.getAllSubItems(0);'. "\n";
            $html_string .= '   var first_child_arr = first_child.split(",");'. "\n";
            
            $html_string .= '   for (i=0; i<first_child_arr.length; i++) {'. "\n";
            $html_string .= '       ' . $this->tree_name  . '._idpull[first_child_arr[i]].htmlNode.parentNode.parentNode.style.display="";'. "\n";
            $html_string .= '   }'. "\n";
            
            //Checking Module//
            $html_string .= '   for (i=0; i<first_child_arr.length; i++) {'. "\n";
            $html_string .= '       var f_tree_level = ' . $this->tree_name  . '.getLevel(first_child_arr[i]);'. "\n";
            $html_string .= '       if (f_tree_level == 2) { '. "\n";
            $html_string .= '           if (' . $this->tree_name  . '.getItemText(first_child_arr[i]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking Menu Group//
            $html_string .= '               var second_child = ' . $this->tree_name  . '.getAllSubItems(first_child_arr[i]);'. "\n";
            $html_string .= '               var second_child_arr = second_child.split(",");'. "\n";
            $html_string .= '               var second_child_chk = 0;'. "\n";
            $html_string .= '               for (j=0; j<second_child_arr.length; j++) {'. "\n";
            $html_string .= '                   var s_tree_level = ' . $this->tree_name  . '.getLevel(second_child_arr[j]);'. "\n";
            $html_string .= '                   if (s_tree_level == 3) {'. "\n";
            $html_string .= '                       if (' . $this->tree_name  . '.getItemText(second_child_arr[j]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking Menu//
            $html_string .= '                           var third_child = ' . $this->tree_name  . '.getAllSubItems(second_child_arr[j]);'. "\n";
            $html_string .= '                           var third_child_arr = third_child.split(",");'. "\n";
            $html_string .= '                           var third_child_chk = 0;'. "\n";
            $html_string .= '                           for (k=0; k<third_child_arr.length; k++) {'. "\n";
            $html_string .= '                               var t_tree_level = ' . $this->tree_name  . '.getLevel(third_child_arr[k]);'. "\n";
            $html_string .= '                               if (t_tree_level == 4) {'. "\n";
            $html_string .= '                                   if (' . $this->tree_name  . '.getItemText(third_child_arr[k]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking Privilege//
            $html_string .= '                                       var fourth_child = ' . $this->tree_name  . '.getAllSubItems(third_child_arr[k]);'. "\n";
            $html_string .= '                                       var fourth_child_arr = fourth_child.split(",");'. "\n";
            $html_string .= '                                       var fourth_child_chk = 0;'. "\n";
            $html_string .= '                                       for (l=0; l<fourth_child_arr.length; l++) {'. "\n";
            $html_string .= '                                           if (' . $this->tree_name  . '.getItemText(fourth_child_arr[l]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //$html_string .= '                                             ' . $this->tree_name  . '._idpull[fourth_child_arr[l]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '                                           } else {'. "\n";
            //$html_string .= '                                             ' . $this->tree_name  . '._idpull[fourth_child_arr[l]].htmlNode.parentNode.parentNode.style.display="";'. "\n";
            $html_string .= '                                               fourth_child_chk = 1;'. "\n";
            $html_string .= '                                               third_child_chk = 1;'. "\n";
            $html_string .= '                                           }'. "\n";
            $html_string .= '                                       }'. "\n";
            //Checking Privilege end//
            $html_string .= '                                       if (fourth_child_chk == 0) {'. "\n";
            $html_string .= '                                           ' . $this->tree_name  . '._idpull[third_child_arr[k]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '                                       }'. "\n";
            $html_string .= '                                   } else { third_child_chk = 1;}'. "\n";
            $html_string .= '                               }'. "\n";
            $html_string .= '                           }'. "\n";
            //Checking Menu end//
            $html_string .= '                           if (third_child_chk == 0) {'. "\n";
            $html_string .= '                               ' . $this->tree_name  . '._idpull[second_child_arr[j]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '                           } else { second_child_chk = 1; }'. "\n";
            $html_string .= '                       } else { second_child_chk = 1; }'. "\n";
            $html_string .= '                   }'. "\n";
            $html_string .= '               }'. "\n";
            //Checking Menu Group end//
            $html_string .= '               if (second_child_chk == 0) {'. "\n";
            $html_string .= '                   ' . $this->tree_name  . '._idpull[first_child_arr[i]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '               }'. "\n";
            $html_string .= '           }'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .= '   }'. "\n";
            //Checking Module end//
            $html_string .= '}'. "\n";
            
            $html_string .= 'hide_after_next_prev = function() {'. "\n";
            $html_string .= '   var first_child = ' . $this->tree_name  . '.getAllSubItems(0);'. "\n";
            $html_string .= '   var first_child_arr = first_child.split(",");'. "\n";
            $html_string .= '   for (i=0; i<first_child_arr.length; i++) {'. "\n";
            $html_string .= '       var f_tree_level = ' . $this->tree_name  . '.getLevel(first_child_arr[i]);'. "\n";
            $html_string .= '       if (f_tree_level == 2) { '. "\n";
            $html_string .= '           var open_state = ' . $this->tree_name  . '.getOpenState(first_child_arr[i]);' . "\n";
            $html_string .= '           if (open_state == -1) { '. "\n";
            $html_string .= '               ' . $this->tree_name  . '._idpull[first_child_arr[i]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '           }'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '}'. "\n";

            return $html_string;
        }

        /**
         * Enable three state checkbox.
         */
        public function enable_three_state_checkbox() {
            $html_string = $this->tree_name .  '.enableThreeStateCheckboxes(true);'. "\n";
            return $html_string; 
        }

        /**
         * Enable multiselect.
         * @param  String $strict_mode Strict mode - allows to select multiple items from same level only
         */
        public function enable_multi_selection($strict_mode = 'true') {
            $html_string = $this->tree_name .  '.enableMultiselection(true, ' . $strict_mode . ');'. "\n";
            return $html_string;
        }

        /**
         * Enable Item Editor.
         */
        public function enable_editor() {
            $html_string = $this->tree_name .  '.enableItemEditor(true);'. "\n";
            return $html_string;
        }
        /**
         * Attach search filter.
         * @param  String $layout_name Layout name string without space
         * @param  String $layout_cell Layout cell Example a,b,c
         */
        public function attach_search_filter($layout_name, $layout_cell) {
            global $app_php_script_loc;   
            $tree_toolbar_json = '[
                            {id:"search_text", type:"buttonInput", text:"Search...", title:"Search", width:140},
                            {id:"prev", type:"button", img: "arrow_r.png", title:"Prev", width:80}, 
                            {id:"next", type:"button", img: "arrow_l.png", title:"Next", width:80}
                        ]';
			$theme_selected = '';//js_dhtmlx_theme;
                    
            $html_string = $this->name_space . '.toolbar = ' . $layout_name . '.cells("' . $layout_cell . '").attachToolbar();'. "\n";
            $html_string .= $this->name_space . '.toolbar.setIconsPath("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/themes/'.$theme_selected.'/imgs/dhxtoolbar_web/");';
            $html_string .= $this->name_space . '.toolbar.loadStruct(' . $tree_toolbar_json . ');'. "\n";
            
            $html_string .= 'search_obj = ' . $this->name_space . '.toolbar.getInput("search_text");'. "\n";
            $html_string .= 'dhtmlxEvent(search_obj, "focus", function(ev){'. "\n";
            $html_string .= '   if (search_obj.value == "Search...") {' . "\n";
            $html_string .= '    search_obj.value = "";'. "\n";
            $html_string .= '   }' . "\n";
            $html_string .= '});'. "\n";

            $html_string .= 'dhtmlxEvent(search_obj, "blur", function(ev){'. "\n";
            $html_string .= '    if(search_obj.value == "") {'. "\n";
            $html_string .= '        search_tree();'. "\n";
            $html_string .=          $this->tree_name.'.clearSelection()'. "\n";
            $html_string .= '        search_obj.value = "Search...";'. "\n";
            $html_string .= '    }'. "\n";
            $html_string .= '});'. "\n";

            $html_string .= 'dhtmlxEvent(search_obj, "keyup", function(ev){'. "\n";
            $html_string .= '   search_tree();'. "\n";
            $html_string .=     $this->tree_name.'.findItem(search_obj.value,0,1)'. "\n";
            $html_string .= '    if(search_obj.value == "") {'. "\n";
            $html_string .=          $this->tree_name.'.clearSelection()'. "\n";
            $html_string .= '    }'. "\n";
            $html_string .= '});'. "\n";
            
            $html_string .= $this->name_space . '.toolbar.attachEvent("onClick", function(id){'. "\n";

            $html_string .= '   if(id == "exp_coll") {'. "\n";
            $html_string .= '               if (' . $this->tree_name . '.tree_expand_flag == 1) {'. "\n";
            $html_string .= '                   '. $this->tree_name .'.closeAllItems("x_1"); '. "\n";
            $html_string .= '                   '. $this->tree_name .'.openItem("x_1"); '. "\n";
            $html_string .= '               '. $this->tree_name . '.tree_expand_flag = 0;'. "\n";
            $html_string .= '               } else {'. "\n";
            $html_string .= '                   '. $this->tree_name .'.openAllItems("x_1"); '. "\n";
            $html_string .= '                   '. $this->tree_name . '.tree_expand_flag = 1;'. "\n";
            $html_string .= '               } '. "\n";
            $html_string .= '           } '. "\n";

            $html_string .= '   if (search_obj.value != "Search..." &&  search_obj.value != "") {'. "\n";            
            $html_string .= '       if(id == "next") {'. "\n";
            $html_string .=             $this->tree_name.'.findItem(search_obj.value)'. "\n";
            $html_string .= '       } else {'. "\n";
            $html_string .=             $this->tree_name.'.findItem(search_obj.value, 1)'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .= '       hide_after_next_prev();'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '});'. "\n";
            
            return $html_string;
        }
    }
?>