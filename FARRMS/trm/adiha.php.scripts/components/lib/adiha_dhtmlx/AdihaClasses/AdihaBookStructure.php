<?php
    Class AdihaBookStructure extends AdihaTree {
        public $portfolio_option = 2;
        public $subsidiary_option = 2;
        public $strategy_option = 2;
        public $book_option = 2;
        public $subbook_option = 2;  
        public $double_click_function = NULL;
        public $function_id = NULL;   
        public $enable_double_click_to_expand = 1;     
        public $tree_expand_flag = 1;
        private $add_save_function_id = NULL;
        private $delete_function_id = NULL;
        public $cache_data = true;
        public $key_prefix = 'PH';
        protected $no_of_book_level = 4;
        protected $subsidiary_hierarchy_json = NULL;
        protected $strategy_hierarchy_json = NULL;

       /**
        * [__construct description]
        * @param Integer $function_id          Function id
        * @param Integer $add_save_function_id Add/Save function id
        * @param Integer $delete_function_id   Delete function id
        * @param Integer $user_name            User name
        */
        function __construct($function_id, $add_save_function_id = null, $delete_function_id = null, $user_name = null) {
            $this->function_id = $function_id;
            $this->add_save_function_id = $add_save_function_id;
            $this->delete_function_id = $delete_function_id;
            $this->user_name = $user_name;
        }
        
        /**
         * Set tree expand flag.
         * @param Integer $flag Default Value - 0
         *                     * 0 -> Tree in Collapsed State
         *                     * 1 -> Tree in Expanded State
         */
        public function set_tree_expand_flag($flag) {
            $this->tree_expand_flag = $flag;
        }
        
        /**
         * Set enable expand/collapse by double clicking first node.
         * @param Integer $flag Default Value - 1
         *                    * 0 -> Disable the feature
         *                    * 1 -> Enable the feature
         */
        public function set_enable_double_click_to_expand($flag) {
            $this->enable_double_click_to_expand = $flag;
        }
        
        /**
         * Set the option for portfolio header.
         * @param Integer $option Default Value - 2
         *                      * 0 -> Disable Selection
         *                      * 1 -> Single Selection
         *                      * 2 -> Multiple Selection
         */
        public function set_portfolio_option($option) {
            $this->portfolio_option = $option;
        }
        
        /**
         * Set the option for subsidiary.
         * @param Integer $option Default Value - 2  
         *                      * 0 -> Disable Selection
         *                      * 1 -> Single Selection
         *                      * 2 -> Multiple Selection
         */
        public function set_subsidiary_option($option) {
            $this->subsidiary_option = $option;
        }

        /**
         * Set the option for strategy.
         * @param Integer $option Default Value - 2
         *                      * 0 -> Disable Selection
         *                      * 1 -> Single Selection
         *                      * 2 -> Multiple Selection
         */
        public function set_strategy_option($option) {
            $this->strategy_option = $option;
        }

        /**
         * Set the option for book.
         * @param Integer $option Default Value - 2
         *                      * 0 -> Disable Selection
         *                      * 1 -> Single Selection
         *                      * 2 -> Multiple Selection
         */
        public function set_book_option($option) {
            $this->book_option = $option;
        }

        /**
         * Set the option for subbook.
         * @param Integer $option Default Value - 2 
         *                      * 0 -> Disable Selection
         *                      * 1 -> Single Selection
         *                      * 2 -> Multiple Selection
         */
        public function set_subbook_option($option) {
            $this->subbook_option = $option;
        }

        /**
         * Load the XML data from the spa and create the tree.
         */
        public function load_book_structure_data() {
            global $app_php_script_loc, $app_adiha_loc, $SHOW_SUBBOOK_IN_BS, $image_path; 
            if ($SHOW_SUBBOOK_IN_BS == 1) {
                $flag = 'y';
                $sp_url = "EXEC spa_getPortfolioHierarchy @function_id='" . $this->function_id . "', @flag='" . $flag . "', @add_save_function_id='" . $this->add_save_function_id . "', @delete_function_id='" . $this->delete_function_id . "'";
            } else {
                 $flag = 'x';
                $sp_url = "EXEC spa_getPortfolioHierarchy @function_id='" . $this->function_id . "', @flag='" . $flag . "', @add_save_function_id='" . $this->add_save_function_id . "', @delete_function_id='" . $this->delete_function_id . "'";
            }

            $key_suffx = $this->function_id . '_' . $flag ;
            $return_array = ($this->cache_data) ? readXMLURLCached($sp_url,true,$this->key_prefix,$key_suffx,true,0,'book_structure') : readXMLURL($sp_url);
            
            $return_arr_xml = $return_array[0][0];
            // ## Set the book level to show
            $this->no_of_book_level = $return_array[0][1];
            $this->subsidiary_hierarchy_json = $return_array[0][2];
            $this->strategy_hierarchy_json = $return_array[0][3];
            
            $html_string =      $this->tree_name . '.enableCheckBoxes(true);'. "\n";
            $html_string .=     $this->tree_name . '.setImagePath("' . $image_path . 'dhxtree_web/");'. "\n";           
            $html_string .= '   var xml_string = \'' . $return_arr_xml . '\'; '. "\n";
            $html_string .=     $this->load_tree_functons();
            //$html_string .=     $this->tree_name . '.loadXMLString(xml_string.replace(/!colon!/g, "\'")); '. "\n";
            $html_string .=     $this->tree_name . '.parse(xml_string.replace(/!colon!/g, "\'"),"xml");hide_unwanted_level(); '. "\n";
            $html_string .=     $this->load_bookstructure_events();
            if ($this->tree_expand_flag) {
                $html_string .= $this->tree_name .'.openAllItems("x_1"); '. "\n";     
                $html_string .=  $this->tree_name . '.tree_expand_flag = 1;'. "\n";                           
            }
            if ($this->enable_double_click_to_expand) {
                $html_string .= $this->tree_name .'.setItemText("x_1",'. $this->tree_name .'.getItemText("x_1"), "Double Click to Expand/Collapse"); '. "\n";
            }
            return $html_string;
        }

        /**
         * Load the XML data from the spa and create the book structure.
         */
        public function load_book_structure() {
            global $app_php_script_loc, $SHOW_SUBBOOK_IN_BS, $image_path;
            $include_subbook = ($SHOW_SUBBOOK_IN_BS == 1) ? 'y' :'n';
            $sp_url = "EXEC spa_getPortfolioHierarchy @function_id='" . $this->function_id . "', @flag='z', @add_save_function_id='" . $this->add_save_function_id . "', @delete_function_id='" . $this->delete_function_id . "', @include_subbook='" . $include_subbook . "'";
            //$return_array = ($this->cache_data) ? readXMLURLCached($sp_url,false,$this->key_prefix,'z',true) : readXMLURL2($sp_url);
            $return_array = readXMLURL2($sp_url);
            $process_table = $return_array[0]['process_table'];
            $this->no_of_book_level = $return_array[0]['node_level'];
            $this->subsidiary_hierarchy_json = $return_array[0]['sub_level_json'];
            $this->strategy_hierarchy_json = $return_array[0]['stra_level_json'];

            $html_string =      $this->tree_name . '.enableCheckBoxes(true);'. "\n";
            $html_string .=     $this->tree_name . '.setImagePath("' . $image_path . 'dhxtree_web/");'. "\n";  

            $html_string .=     $this->load_tree_functons();
            $html_string .=     $this->load_bookstructure_events();

            $html_string .= '   var sql_url = js_php_path + "tree.connector.php?process_table=' . $process_table . '"; console.log(sql_url);' . "\n";
            $html_string .= $this->tree_name . '.load(sql_url, function() {' . "\n";
                if ($this->tree_expand_flag) {
                    $html_string .= $this->tree_name .'.openAllItems("x_1"); '. "\n";     
                    $html_string .=  $this->tree_name . '.tree_expand_flag = 1;'. "\n";                           
                }
                
                if ($this->enable_double_click_to_expand) {
                    $html_string .= $this->tree_name .'.setItemText("x_1",'. $this->tree_name .'.getItemText("x_1"), "Double Click to Expand/Collapse"); '. "\n";
                }
            $html_string .= 'hide_unwanted_level();});' . "\n";

            return $html_string;
        }

        /**
         * Add search filter.
         * @param  String  $layout_name      Name of the layout string without space
         * @param  String  $layout_cell      Cells layout
         * @param  Boolean $show_filter_form Show filter form, sets the default value false
         * @return String html.
         */
        public function attach_search_filter($layout_name, $layout_cell, $show_filter_form = false) {
            global $app_php_script_loc,$default_theme;
            $tree_toolbar_json = '[
                            {id:"search_text", type:"buttonInput", text:"Search...", title:"Search", width:140},
                            {id:"prev", type:"button", img: "arrow_r.png", title:"Prev", width:80}, 
                            {id:"next", type:"button", img: "arrow_l.png", title:"Next", width:80},
                            {id:"exp_coll", type:"button", img:"exp_col.gif", imgdis:"exp_col_dis.gif", width:80, title:"Expand/Collapse"}';
                       

            if($show_filter_form) {
                $tree_toolbar_json .= ',
                            {id:"show_hide_filter", type:"button", img:"tag.png", width:80, title:"Show Tagging Filter"}';
            }

            $tree_toolbar_json .= ']';

            $theme_selected = 'dhtmlx_'.$default_theme;
                    
            $html_string = $this->name_space . '.book_toolbar = ' . $layout_name . '.cells("' . $layout_cell . '").attachToolbar();'. "\n";
            $html_string .= $this->name_space . '.book_toolbar.setIconsPath("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/themes/'.$theme_selected.'/imgs/dhxtoolbar_web/");';
            $html_string .= $this->name_space . '.book_toolbar.loadStruct(' . $tree_toolbar_json . ');'. "\n";
            
            //$html_string .= '    else if("show_hide_filter") {'. "\n";
            if($show_filter_form) {
                $html_string .= 'var popup_hide_show_status = 0;' . "\n";
                $html_string .= 'var form_json = ['. "\n";
                $html_string .= '   {type: "combo", comboType: "custom_checkbox", filtering: true, filtering_mode: "between", name: "group1", label: "Tag 1", width: 230, options: "", position:"label-top", offsetLeft: 10},'. "\n";
                $html_string .= '   {type: "newcolumn"},'. "\n";
                $html_string .= '   {type: "combo", comboType: "custom_checkbox", filtering: true, filtering_mode: "between", name: "group2", label: "Tag 2", width: 230, options: "", position:"label-top", offsetLeft: 10},'. "\n";
                $html_string .= '   {type: "newcolumn"},'. "\n";
                $html_string .= '   {type: "combo", comboType: "custom_checkbox", filtering: true, filtering_mode: "between", name: "group3", label: "Tag 3", width: 230, options: "", position:"label-top", offsetLeft: 10},'. "\n";
                $html_string .= '   {type: "newcolumn"},'. "\n";
                $html_string .= '   {type: "combo", comboType: "custom_checkbox", filtering: true, filtering_mode: "between", name: "group4", label: "Tag 4", width: 230, options: "", position:"label-top", offsetLeft: 10},'. "\n";
                $html_string .= '];'. "\n"; 

                $tag_popup_toolbar_json = '[
                            {id:"ok", type:"button", text:"Ok", img:"tick.gif", title:"Ok"},
                            {id:"clear", type:"button", text:"Clear", img:"clear.gif", title:"Clear"},
                            {id:"close", type:"button", text:"Close", img:"close.gif", title:"Close"}
                        ]';

                $html_string .= $this->name_space . '.tag_popup = new dhtmlXPopup({'. "\n";
                $html_string .= '                           toolbar: ' . $this->name_space . '.book_toolbar,'. "\n";
                $html_string .= '                           id : "show_hide_filter"'. "\n";
                $html_string .= '});'. "\n";
                $html_string .= $this->name_space . '.tag_popup.show("show_hide_filter");'. "\n";
                $html_string .= $this->name_space . '.tag_popup_layout = ' . $this->name_space . '.tag_popup.attachLayout(250, 230, "1C");'. "\n";
                $html_string .= $this->name_space . '.tag_popup_layout.cells("a").hideHeader();'. "\n";
                $html_string .= $this->name_space . '.tag_popup_toolbar = ' . $this->name_space . '.tag_popup_layout.cells("a").attachToolbar();'. "\n";
                $html_string .= $this->name_space . '.tag_popup_toolbar.setIconsPath("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/themes/'.$theme_selected.'/imgs/dhxtoolbar_web/");';
                $html_string .= $this->name_space . '.tag_popup_toolbar.loadStruct(' . $tag_popup_toolbar_json . ');'. "\n";
                $html_string .= $this->name_space .'.filter_form =' . $this->name_space . '.tag_popup_layout.cells("a").attachForm(form_json);'. "\n";
                $html_string .= $this->name_space . '.tag_popup.hide("show_hide_filter");'. "\n";
                $html_string .= $this->name_space . '.tag_popup.attachEvent("onBeforeHide", function(type, ev, id){;'. "\n";
                $html_string .= '    if(type == "click") {;'. "\n";
                //this condition is applied to handle the popup hide whin check box on dropdown option is checked.
                $html_string .= '        if(popup_hide_show_status == 1) {;'. "\n";
                $html_string .= '            popup_hide_show_status = 0;'. "\n";
                $html_string .= '            return;'. "\n";
                $html_string .= '        };'. "\n";

                $html_string .= '    ' . $this->name_space .'.tag_popup.hide();'. "\n";
                $html_string .= '    };'. "\n";
                $html_string .= '});'. "\n";

                $html_string .= $this->name_space . '.tag_popup_toolbar.attachEvent("onClick", function(id){'. "\n";
                $html_string .= '   if(id == "ok") {' . "\n";
                $html_string .= '       ' . $this->name_space . '.tag_popup.hide("show_hide_filter");'. "\n";
                $html_string .= '       ' . $this->name_space . '.get_filtered_data();' . "\n";
                
                $html_string .= '   } else if(id == "clear") {'. "\n";
                $html_string .= '       ' . $this->name_space .'.filter_form.getCombo("group1").modes.custom_checkbox.topImageClick(null, ' . $this->name_space .'.filter_form.getCombo("group1"), false);'. "\n";
                $html_string .= '        ' . $this->name_space .'.filter_form.getCombo("group2").modes.custom_checkbox.topImageClick(null, ' . $this->name_space .'.filter_form.getCombo("group2"), false);'. "\n";
                $html_string .= '         ' . $this->name_space .'.filter_form.getCombo("group3").modes.custom_checkbox.topImageClick(null, ' . $this->name_space .'.filter_form.getCombo("group3"), false);'. "\n";
                $html_string .= '         ' . $this->name_space .'.filter_form.getCombo("group4").modes.custom_checkbox.topImageClick(null, ' . $this->name_space .'.filter_form.getCombo("group4"), false);'. "\n";
                $html_string .= '   } else if(id == "close") {'. "\n";
                $html_string .= '       ' . $this->name_space . '.tag_popup.hide("show_hide_filter");'. "\n";
                $html_string .= '   }'. "\n";

                $html_string .= '});'. "\n";
                        // Group1
                $html_string .= 'var cm_param_grp1 = {'. "\n";
                $html_string .= '   "action": "spa_source_book_maintain",'. "\n"; 
                $html_string .= '   "flag": "x",'. "\n";
                $html_string .= '   "source_system_book_type_value_id": 50'. "\n";
                $html_string .= '};'. "\n";
                $html_string .= 'cm_param_grp1 = $.param(cm_param_grp1);'. "\n";
                $html_string .= 'var url = js_dropdown_connector_url + "&" + cm_param_grp1;'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group1 = ' . $this->name_space .'.filter_form.getCombo("group1");'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group1.load(url);'. "\n";
                 //Group2
                $html_string .= 'var cm_param_grp2 = {'. "\n";
                $html_string .= '   "action": "spa_source_book_maintain",'. "\n";
                $html_string .= '   "flag": "x",'. "\n";
                $html_string .= '   "source_system_book_type_value_id": 51'. "\n";
                $html_string .= '};'. "\n";
                $html_string .= 'cm_param_grp2 = $.param(cm_param_grp2);'. "\n";
                $html_string .= 'var url = js_dropdown_connector_url + "&" + cm_param_grp2;'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group2 = ' . $this->name_space .'.filter_form.getCombo("group2");'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group2.load(url);'. "\n";


                //Group3
                $html_string .= 'var cm_param_grp3 = {'. "\n";
                $html_string .= '   "action": "spa_source_book_maintain",'. "\n"; 
                $html_string .= '   "flag": "x",'. "\n";
                $html_string .= '   "source_system_book_type_value_id": 52'. "\n";
                $html_string .= '};'. "\n";

                $html_string .= 'cm_param_grp3 = $.param(cm_param_grp3);'. "\n";
                $html_string .= 'var url = js_dropdown_connector_url + "&" + cm_param_grp3;'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group3 = ' . $this->name_space .'.filter_form.getCombo("group3");'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group3.load(url);'. "\n";

                //Group4
                $html_string .= 'var cm_param_grp4 = {'. "\n";
                $html_string .= '   "action": "spa_source_book_maintain",'. "\n";
                $html_string .= '   "flag": "x",'. "\n";
                $html_string .= '   "source_system_book_type_value_id": 53'. "\n";
                $html_string .= '};'. "\n";

                $html_string .= 'cm_param_grp4 = $.param(cm_param_grp4);'. "\n";
                $html_string .= 'var url = js_dropdown_connector_url + "&" + cm_param_grp4;'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group4 = ' . $this->name_space .'.filter_form.getCombo("group4");'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group4.load(url);'. "\n";
                $html_string .= $this->name_space .'.combo_obj_group1.attachEvent("onCheck", function(value, state) {'. "\n";
                $html_string .= '   popup_hide_show_status = 1;'. "\n";
                $html_string .= '});'. "\n";

                $html_string .= $this->name_space .'.combo_obj_group2.attachEvent("onCheck", function(value, state) {'. "\n";
                $html_string .= '   popup_hide_show_status = 1;'. "\n";
                $html_string .= '});'. "\n";

                $html_string .= $this->name_space .'.combo_obj_group3.attachEvent("onCheck", function(value, state) {'. "\n";
                $html_string .= '   popup_hide_show_status = 1;'. "\n";
                $html_string .= '});'. "\n";

                $html_string .= $this->name_space .'.combo_obj_group4.attachEvent("onCheck", function(value, state) {'. "\n";
                $html_string .= '   popup_hide_show_status = 1;'. "\n";
                $html_string .= '});'. "\n";

            }
            $html_string .= 'search_obj = ' . $this->name_space . '.book_toolbar.getInput("search_text");'. "\n";
            $html_string .= 'dhtmlxEvent(search_obj, "focus", function(ev){'. "\n";
            $html_string .= '   if (search_obj.value == "Search...") {' . "\n";
            $html_string .= '    search_obj.value = "";'. "\n";
            $html_string .= '   }' . "\n";
            $html_string .= '});'. "\n";

            $html_string .= 'dhtmlxEvent(search_obj, "blur", function(ev){'. "\n";
            $html_string .= '    if(search_obj.value == "") {'. "\n";
            $html_string .= '        book_structure_search();'. "\n";
            $html_string .=          $this->tree_name.'.clearSelection()'. "\n";
            $html_string .= '        search_obj.value = "Search...";'. "\n";
            $html_string .= '    }'. "\n";
            $html_string .= '});'. "\n";

            $html_string .= 'dhtmlxEvent(search_obj, "keyup", function(ev){'. "\n";
            $html_string .= '   book_structure_search();'. "\n";
            $html_string .=     $this->tree_name.'.findItem(search_obj.value,0,1)'. "\n";
            $html_string .= '    if(search_obj.value == "") {'. "\n";
            $html_string .=          $this->tree_name.'.clearSelection()'. "\n";
            $html_string .= '    }'. "\n";
            $html_string .= '});'. "\n";
            
            $html_string .= $this->name_space . '.book_toolbar.attachEvent("onClick", function(id){'. "\n";

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

            $html_string .= '   if (search_obj.value != "Search..." &&  search_obj.value != "" && id != "exp_coll") {'. "\n";            
            $html_string .= '       if(id == "next") {'. "\n";
            $html_string .=             $this->tree_name.'.findItem(search_obj.value)'. "\n";
            $html_string .= '       } else {'. "\n";
            $html_string .=             $this->tree_name.'.findItem(search_obj.value, 1)'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .= '       hide_after_next_prev();'. "\n";
            $html_string .= '   }'. "\n";
            $html_string .= '});'. "\n";

            $html_string .= $this->name_space . '.get_filtered_data = function () {' . "\n";
            $html_string .= '   ' . $layout_name. '.cells("' . $layout_cell . '").progressOn();'. "\n";
            $html_string .= '   var tag1 = ' . $this->name_space .'.filter_form.getCombo("group1").getChecked().join(",");'. "\n";
            $html_string .= '   var tag2 = ' . $this->name_space .'.filter_form.getCombo("group2").getChecked().join(",");'. "\n";
            $html_string .= '   var tag3 = ' . $this->name_space .'.filter_form.getCombo("group3").getChecked().join(",");'. "\n";
            $html_string .= '   var tag4 = ' . $this->name_space .'.filter_form.getCombo("group4").getChecked().join(",");'. "\n";
            $html_string .= '   data = {'. "\n";
            $html_string .= '       "action": "spa_getPortfolioHierarchy",'. "\n";
            $html_string .= '       "function_id": "' . $this->function_id . '",'. "\n";
            $html_string .= '       "add_save_function_id" : "' . $this->add_save_function_id . '",'. "\n";
            $html_string .= '       "delete_function_id" : "' . $this->delete_function_id . '",'. "\n";
            $html_string .= '       "flag": "y",'. "\n";
            $html_string .= '       "tag1": tag1,'. "\n";
            $html_string .= '       "tag2": tag2,'. "\n";
            $html_string .= '       "tag3": tag3,'. "\n";
            $html_string .= '       "tag4": tag4'. "\n";
            $html_string .= '   };'. "\n";
            $html_string .= '   adiha_post_data("return_array", data, "", "", "' . $this->name_space . '.refresh_bookstructure_callback");'. "\n";
            $html_string .= '}'. "\n";

            $html_string .= $this->name_space . '.refresh_bookstructure_callback = function(result) {'. "\n";
            $html_string .= '    xml_string = result[0][0];'. "\n";
            $html_string .= '    node_level = result[0][1];'. "\n";
            $html_string .= '    subisidary_level_data = result[0][2];'. "\n";
            $html_string .= '    strategy_level_data = result[0][3];'. "\n";
            $html_string .= '    ' . $this->tree_name .'.deleteItem("x_1");'. "\n";
            $html_string .= '    ' . $this->tree_name .'.loadXMLString(xml_string.replace(/!colon!/g, "\'"),function () {'. "\n";
                  //hide_unwanted_node_level();
            $html_string .= '    });'. "\n";

            $html_string .= '    ' . $this->tree_name .'.openAllItems("x_1");'. "\n";
            $html_string .= '    ' . $layout_name. '.cells("' . $layout_cell . '").progressOff();'. "\n";
            $html_string .= '}'. "\n";
            
            return $html_string;
        }

        /**
         * Double Click Event - Attach Event to open the book property window ion the left layout when double clicked on the tree.
         * @param String $function_name Function name
         */
        public function define_doubleclick_events($function_name){
           $this->double_click_function = $function_name;
        }

        /**
         * Load the event functions.
         * @return String html.
         */
        public function load_bookstructure_events() {
            /**
             * [Double Click Event - Attach Event to open the book property window when double clicked on the tree]
             * Open Subsidiary Propery window if double clicked on subsidiary
             * Open Strategy Propery window if double clicked on Strategy
             * Open Book Propery window if double clicked on Book
             * Open Source book mapping IU window if double clicked on Subbook
             */
            $html_string =      $this->tree_name . '.attachEvent("onDblClick", function(id){'. "\n";
            
            if($this->double_click_function != NULL){
                $html_string .= $this->double_click_function. '(id);'."\n";
           } else{
                $html_string .= '       var level = ' . $this->tree_name . '.getLevel(id);'. "\n";
                $html_string .= '       var book_window = new dhtmlXWindows();'. "\n";
                $html_string .= '       var param;'. "\n";            
                $html_string .= '       if (level == 1) {'. "\n";
                $html_string .= '         param = app_form_path + "_setup/setup_book_structure/book.structure.property.php?entity_id=a_-1";'. "\n";
                $html_string .= '           w1 = book_window.createWindow("w1", 20, 10, 800, 630);'. "\n";
                $html_string .= '           w1.maximize();'. "\n";
                $html_string .= '           w1.setText("Subsidiary Property");'. "\n";
                $html_string .= '       } else if (level == 2) {'. "\n";
                $html_string .= '         param = app_form_path + "_setup/setup_book_structure/book.structure.property.php?call_from=' . $this->name_space . '&entity_id=" + id ;'. "\n";
                $html_string .= '           w1 = book_window.createWindow("w1", 20, 10, 800, 630);'. "\n";
                $html_string .= '           w1.maximize();'. "\n";
                $html_string .= '           w1.setText("Subsidiary Property");'. "\n";
                $html_string .= '       } else if (level == 3) {'. "\n";
                $html_string .= '           param = app_form_path + "_setup/setup_book_structure/book.structure.property.php?entity_id=" + id;'. "\n";
                $html_string .= '           w1 = book_window.createWindow("w1", 20, 10, 800, 230);'. "\n";
                $html_string .= '           w1.maximize();'. "\n";                
                $html_string .= '           w1.setText("Strategy Property");'. "\n";
                $html_string .= '       } else if (level == 4) {'. "\n";
                $html_string .= '           param = app_form_path + "_setup/setup_book_structure/book.structure.property.php?entity_id=" + id;'. "\n";
                $html_string .= '           w1 = book_window.createWindow("w1", 20, 10, 800, 230);'. "\n";
                $html_string .= '           w1.maximize();'. "\n";                
                $html_string .= '           w1.setText("Book Property");'. "\n";
                $html_string .= '       } else if (level == 5) {'. "\n";
                $html_string .= '           param = app_form_path + "_setup/setup_book_structure/book.structure.property.php?entity_id=" + id;'. "\n";
                $html_string .= '           w1 = book_window.createWindow("w1", 20, 10, 800, 230);'. "\n";
                $html_string .= '           w1.maximize();'. "\n";                                
                $html_string .= '           w1.setText("Source Book Mapping Detail");'. "\n";
                $html_string .= '       }'. "\n";
                $html_string .= '       w1.attachURL(param, false, true);'. "\n";
            }
            $html_string .= '   });'. "\n";
            
            /**
             * [Onload Event - Attach Event to hide checkbox if option is set to 0(disable checkbox)]
             */
            $html_string .=     $this->tree_name . '.attachEvent("onXLE", function(id){'. "\n";
            $html_string .= '       var all_items = '. $this->tree_name . '.getAllSubItems(0);'. "\n";
            $html_string .= '       var splited_value = all_items.split(",");'. "\n";
            $html_string .= '       for(var i = 0; i <= splited_value.length; i++) {'. "\n";
            $html_string .= '           var item_level = '. $this->tree_name . '.getLevel(splited_value[i]);'. "\n";
            $html_string .= '           if (item_level == 1) {'. "\n";
            if($this->portfolio_option == 0) {
                $html_string .=             $this->tree_name . '.showItemCheckbox(splited_value[i], false);'. "\n";
            }
            $html_string .= '           } else if (item_level == 2) {'. "\n";
            if($this->subsidiary_option == 0) {
                $html_string .=             $this->tree_name . '.showItemCheckbox(splited_value[i], false);'. "\n";
            }
            $html_string .= '           } else if (item_level == 3) {'. "\n";
            if($this->strategy_option == 0) {
                    $html_string .=         $this->tree_name . '.showItemCheckbox(splited_value[i], false);'. "\n";
            }
            $html_string .= '           } else if (item_level == 4) {'. "\n";
            if($this->book_option == 0) {
                $html_string .=             $this->tree_name . '.showItemCheckbox(splited_value[i], false);'. "\n";
            }
            $html_string .= '           } else if (item_level == 5) {'. "\n";
            if($this->subbook_option == 0) {
                $html_string .=             $this->tree_name . '.showItemCheckbox(splited_value[i], false);'. "\n";
            }
            $html_string .= '           }'. "\n";
            $html_string .= '       }'. "\n";      
            $html_string .= '   });'. "\n";

            /**
             * [Oncheck Event - Attach Event to set multiple selection if option is set to 1(single selection)]
             */
            $html_string .=     $this->tree_name . '.attachEvent("onCheck", function(id){'. "\n";
            $html_string .= '       var checked_item_level = '. $this->tree_name . '.getLevel(id);'. "\n";
            $html_string .= '       var all_items = '. $this->tree_name . '.getAllSubItems(0);'. "\n";
            $html_string .= '       var splited_value = all_items.split(",");'. "\n";
            $html_string .= '       for(var i = 0; i <= splited_value.length; i++) {'. "\n";
            $html_string .= '           var item_level = '. $this->tree_name . '.getLevel(splited_value[i]);'. "\n";
            $html_string .= '           if (item_level == checked_item_level && item_level == 2) {'. "\n";
            if($this->subsidiary_option == 1) {
                $html_string .= '           if (splited_value[i] != id) {'. "\n";
                $html_string .=                 $this->tree_name . '.setCheck(splited_value[i], false);'. "\n";
                $html_string .= '           }'. "\n";
            }
            $html_string .= '           } else if (item_level == checked_item_level && item_level == 3) {'. "\n";     
            if($this->strategy_option == 1) {
                $html_string .= '           if (splited_value[i] != id) {'. "\n";
                $html_string .=                 $this->tree_name . '.setCheck(splited_value[i], false);'. "\n";
                $html_string .= '           }'. "\n";
            }
            $html_string .= '           } else if (item_level == checked_item_level && item_level == 4) {'. "\n";     
            if($this->book_option == 1) {
                $html_string .= '           if (splited_value[i] != id) {'. "\n";
                $html_string .=                 $this->tree_name . '.setCheck(splited_value[i], false);'. "\n";
                $html_string .= '           }'. "\n";
            }
            $html_string .= '           } else if (item_level == checked_item_level && item_level == 5) {'. "\n";     
            if($this->subbook_option == 1) {
                $html_string .= '           if (splited_value[i] != id) {'. "\n";
                $html_string .=                 $this->tree_name . '.setCheck(splited_value[i], false);'. "\n";
                $html_string .= '           }'. "\n";
            }
            $html_string .= '           }'. "\n";
            $html_string .= '       }'. "\n";      
            $html_string .= '   });'. "\n";

            return $html_string;
        }

        /**
         * Javascript Functions to load tree.
         * @return String html.
         */
        public function load_tree_functons() {
            $html_string = parent::load_tree_functions();
            $html_string .= 'hide_unwanted_level = function() {' . "\n";
            $html_string .= '   var level_to_show = ' . ($this->no_of_book_level - 1) . ';' . "\n";
            $html_string .= '   var subsidiary_hierarchy_json = ' . $this->subsidiary_hierarchy_json .  ';' ."\n";
            $html_string .= '   var strategy_hierarchy_json = ' . $this->strategy_hierarchy_json .  ';' ."\n";
            $html_string .=     'var strategy_ids = [];' . "\n";
            $html_string .=     'for (i = 0; i < strategy_hierarchy_json.length; i++){' . "\n";
            $html_string .=     '    strategy_ids.push(strategy_hierarchy_json[i].strategy_id);' . "\n";
            $html_string .=     '    var strategy_child = '. $this->tree_name . '.getAllSubItems(strategy_hierarchy_json[i].strategy_id);' . "\n";
            $html_string .=     '    var strategy_child_arr = strategy_child.split(",");' . "\n";
            $html_string .=     '    strategy_hierarchy_json[i].child = strategy_child_arr;' . "\n";
            $html_string .=     '    strategy_ids = strategy_ids.concat(strategy_child_arr);' . "\n";
            $html_string .=     '}' . "\n";
            $html_string .= '   var subsidiary_ids = []; '. "\n";
            $html_string .= '   for (var i = 0; i < subsidiary_hierarchy_json.length; i++){'. "\n";
            $html_string .= '      subsidiary_ids.push(subsidiary_hierarchy_json[i].subsidiary_id);'. "\n";
            $html_string .= '      var subsidiary_child = '. $this->tree_name . '.getAllSubItems(subsidiary_hierarchy_json[i].subsidiary_id);' . "\n";
            $html_string .= '      var subsidiary_child_arr = subsidiary_child.split(",");' . "\n";
            $html_string .= '      subsidiary_child_arr = subsidiary_child_arr.filter(function(obj) { return strategy_ids.indexOf(obj) == -1; });' . "\n";
            $html_string .= '      subsidiary_hierarchy_json[i].child = subsidiary_child_arr;' . "\n";
            $html_string .= '      subsidiary_ids = subsidiary_ids.concat(subsidiary_child_arr);' . "\n";
            $html_string .=     '} '. "\n";
            $html_string .= '   var first_child = ' . $this->tree_name  . '.getAllSubItems(0);' . "\n";
            $html_string .= '   var first_child_arr = first_child.split(",");' . "\n";
            $html_string .= '   first_child_arr = first_child_arr.filter(function(obj) { return subsidiary_ids.indexOf(obj) == -1; });'. "\n"; // Remove all child ids of subsidiary for which hierachy is defined
            $html_string .= '   first_child_arr = first_child_arr.filter(function(obj) { return strategy_ids.indexOf(obj) == -1; });'. "\n"; // Remove all child ids of subsidiary for which hierachy is defined

            // Hide according company level node definition
            $html_string .= '   for (i = 0; i < first_child_arr.length; i++) {' . "\n";
            $html_string .= '       var f_tree_level = ' . $this->tree_name  . '.getLevel(first_child_arr[i]);' . "\n";
            $html_string .= '       if (f_tree_level == level_to_show + 1) {'. "\n";
            $html_string .= '           var item = ' . $this->tree_name . '._idpull[first_child_arr[i]];' . "\n";

            // ## Hide expand/collapse icon
            $html_string .= '           item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;' . "\n";
            $html_string .= '       }' . "\n";
            $html_string .= '       if (f_tree_level > level_to_show + 1) {'. "\n";
            $html_string .= '           var item = ' . $this->tree_name . '._idpull[first_child_arr[i]];' . "\n";
            $html_string .= '           var itemRow = item.span.parentNode.parentNode;' . "\n";
            // ## Hide unwanted node rows
            $html_string .= '           itemRow.style.display = "none";' . "\n";
            $html_string .=             $this->tree_name  .'.setUserData(first_child_arr[i],"ishidden","1");' . "\n";
            $html_string .= '       }' . "\n";
            $html_string .= '   }' . "\n";

            // Hide according subsidiary level node definition
            $html_string .= '   for (i = 0; i < subsidiary_hierarchy_json.length; i++) {' . "\n";
            $html_string .= '       level_to_show = subsidiary_hierarchy_json[i].node_level;' . "\n";
            $html_string .= '       for (j = 0; j < subsidiary_hierarchy_json[i].child.length; j++) {' . "\n";
            $html_string .= '           f_tree_level = '. $this->tree_name . '.getLevel(subsidiary_hierarchy_json[i].child[j]);' . "\n";
            $html_string .= '           if (f_tree_level == level_to_show + 1) {' . "\n";
            $html_string .= '               item = '. $this->tree_name . '._idpull[subsidiary_hierarchy_json[i].child[j]];' . "\n";
            $html_string .= '               item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;' . "\n";
            $html_string .= '           }' . "\n";
            $html_string .= '           if (f_tree_level > level_to_show + 1) {' . "\n";
            $html_string .= '               item = '. $this->tree_name . '._idpull[subsidiary_hierarchy_json[i].child[j]];' . "\n";
            $html_string .= '               itemRow = item.span.parentNode.parentNode;' . "\n";
            $html_string .= '               itemRow.style.display = "none";' . "\n";
            $html_string .=                 $this->tree_name  .'.setUserData(subsidiary_hierarchy_json[i].child[j],"ishidden","1");' . "\n";
            $html_string .= '           }' . "\n";
            $html_string .= '       }' . "\n";
            $html_string .= '       f_tree_level = '. $this->tree_name . '.getLevel(subsidiary_hierarchy_json[i].subsidiary_id);' . "\n";
            $html_string .= '       if (f_tree_level == level_to_show + 1) {' . "\n";
            $html_string .= '           item = '. $this->tree_name . '._idpull[subsidiary_hierarchy_json[i].subsidiary_id];' . "\n";
            $html_string .= '           item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;' . "\n";
            $html_string .= '       }' . "\n";
            $html_string .= '   }' . "\n";

            $html_string .= 'for (i = 0; i < strategy_hierarchy_json.length; i++) {' . "\n";
            $html_string .= '    level_to_show = 1 + strategy_hierarchy_json[i].node_level;' . "\n";
            $html_string .= '    for (j = 0; j < strategy_hierarchy_json[i].child.length; j++) {' . "\n";
            $html_string .= '        f_tree_level = '. $this->tree_name . '.getLevel(strategy_hierarchy_json[i].child[j]);' . "\n";
            $html_string .= '        if (f_tree_level == level_to_show + 1) {' . "\n";
            $html_string .= '            item = '. $this->tree_name . '._idpull[strategy_hierarchy_json[i].child[j]];' . "\n";
            $html_string .= '            item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;' . "\n";
            $html_string .= '        }' . "\n";
            $html_string .= '        if (f_tree_level > level_to_show + 1) {' . "\n";
            $html_string .= '            item = '. $this->tree_name . '._idpull[strategy_hierarchy_json[i].child[j]];' . "\n";
            $html_string .= '            itemRow = item.span.parentNode.parentNode;' . "\n";
            $html_string .= '            itemRow.style.display = "none";' . "\n";
            $html_string .=             $this->tree_name  .'.setUserData(strategy_hierarchy_json[i].child[j],"ishidden","1");' . "\n";
            $html_string .= '        }' . "\n";
            $html_string .= '    }' . "\n";
            $html_string .= '    f_tree_level = '. $this->tree_name . '.getLevel(strategy_hierarchy_json[i].strategy_id);' . "\n";
            $html_string .= '    if (f_tree_level == level_to_show + 1) {' . "\n";
            $html_string .= '        item = '. $this->tree_name . '._idpull[strategy_hierarchy_json[i].strategy_id];' . "\n";
            $html_string .= '        item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;' . "\n";
            $html_string .= '    }' . "\n";
            $html_string .= '}' . "\n";
//
            $html_string .= '}' . "\n";
            /**
             * [Function to return the checked subsidiary]
             */
            $html_string .=    $this->name_space . '.get_subsidiary = function(call_from) {'. "\n";
            $html_string .= '       var subsidiary = ' . $this->name_space . '.get_tree_checked_value(2, call_from);'. "\n";
            $html_string .= '       subsidiary = subsidiary.toString();'. "\n";
            $html_string .= '       subsidiary = subsidiary.replace(/a_/g, "");'. "\n";
            $html_string .= '       return subsidiary;'. "\n";
            $html_string .= '  }'. "\n"; 

            /**
             * [Function to return the checked strategy]
             */
            $html_string .=    $this->name_space . '.get_strategy = function(call_from) {'. "\n";
            $html_string .= '       var strategy = ' . $this->name_space . '.get_tree_checked_value(3, call_from);'. "\n";
            $html_string .= '       strategy = strategy.toString();'. "\n";
            $html_string .= '       strategy = strategy.replace(/b_/g, "");'. "\n";
            $html_string .= '       return strategy;'. "\n";
            $html_string .= '  }'. "\n";  

            /**
             * [Function to return the checked book]
             */
            $html_string .=    $this->name_space . '.get_book = function(call_from) {'. "\n";
            $html_string .= '       var book = ' . $this->name_space . '.get_tree_checked_value(4, call_from);'. "\n";
            $html_string .= '       book = book.toString();'. "\n";
            $html_string .= '       book = book.replace(/c_/g, "");'. "\n";
            $html_string .= '       return unescapeXML(book);'. "\n";
            $html_string .= '  }'. "\n";  

            /**
             * [Function to return the checked subbook]
             */
            $html_string .=    $this->name_space . '.get_subbook = function() {'. "\n";
            $html_string .= '       var subbook = ' . $this->name_space . '.get_tree_checked_value(5);'. "\n";
            $html_string .= '       subbook = subbook.toString();'. "\n";
            $html_string .= '       subbook = subbook.replace(/d_/g, "");'. "\n";
            $html_string .= '       return unescapeXML(subbook);'. "\n";
            $html_string .= '  }'. "\n";  

            /**
             * [Function to return the checked subsidiary label]
             */
            $html_string .=    $this->name_space . '.get_subsidiary_label = function(call_from) {'. "\n";
            $html_string .= '       var subsidiary = ' . $this->name_space . '.get_tree_checked_label(2, call_from);'. "\n";
            $html_string .= '       subsidiary = subsidiary.toString();'. "\n";
            $html_string .= '       subsidiary = subsidiary.replace(/a_/g, "");'. "\n";
            $html_string .= '       return unescapeXML(subsidiary);'. "\n";
            $html_string .= '  }'. "\n"; 

            /**
             * [Function to return the checked strategy label]
             */
            $html_string .=    $this->name_space . '.get_strategy_label = function(call_from) {'. "\n";
            $html_string .= '       var strategy = ' . $this->name_space . '.get_tree_checked_label(3, call_from);'. "\n";
            $html_string .= '       strategy = strategy.toString();'. "\n";
            $html_string .= '       strategy = strategy.replace(/b_/g, "");'. "\n";
            $html_string .= '       return unescapeXML(strategy);'. "\n";
            $html_string .= '  }'. "\n";  

            /**
             * [Function to return the checked book label]
             */
            $html_string .=    $this->name_space . '.get_book_label = function(call_from) {'. "\n";
            $html_string .= '       var book = ' . $this->name_space . '.get_tree_checked_label(4, call_from);'. "\n";
            $html_string .= '       book = book.toString();'. "\n";
            $html_string .= '       book = book.replace(/c_/g, "");'. "\n";
            $html_string .= '       return book;'. "\n";
            $html_string .= '  }'. "\n";  

            /**
             * [Function to return the checked subbook label]
             */
            $html_string .=    $this->name_space . '.get_subbook_label = function() {'. "\n";
            $html_string .= '       var subbook = ' . $this->name_space . '.get_tree_checked_label(5);'. "\n";
            $html_string .= '       subbook = subbook.toString();'. "\n";
            $html_string .= '       subbook = subbook.replace(/d_/g, "");'. "\n";
            $html_string .= '       return subbook;'. "\n";
            $html_string .= '  }'. "\n";  
            
            /**
             * [Function to checked the specific node]
             * @param   [int]       node_id - id of the node
             * @param   [String]    node_type - subsidiary/strategy/book/subbook
             */
            $html_string .=    $this->name_space . '.set_book_structure_node = function(node_id, node_type) {'. "\n";
            $html_string .= '       var node = "";'. "\n";
            $html_string .= '       if (node_type == "subsidiary") {'. "\n";
            $html_string .= '           node = "a_" + node_id;'. "\n";
            $html_string .= '       } else if (node_type == "strategy") {'. "\n";
            $html_string .= '           node = "b_" + node_id;'. "\n";
            $html_string .= '       } else if (node_type == "book") {'. "\n";
            $html_string .= '           node = "c_" + node_id;'. "\n";
            $html_string .= '       } else if (node_type == "subbook") {'. "\n";
            $html_string .= '           node = "d_" + node_id;'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .=         $this->tree_name . '.setCheck(node, true);'. "\n";
            $html_string .= '  }'. "\n";  
            
            /**
             * [Function to set the checked subbook label]
             */
            $html_string .= 'update_tree_node_text = function(node_id, node_text) {'. "\n";
            $html_string .=     $this->tree_name . '.setItemText(node_id, node_text);'. "\n";
            $html_string .= '}'. "\n";
            
            /**
             * [Function to search item in book structure]
             */
            $html_string .= 'book_structure_search = function() {'. "\n";
            $html_string .= '   var search_value = search_obj.value;'. "\n";
            $html_string .= '   var first_child = ' . $this->tree_name  . '.getAllSubItems(0);'. "\n";
            $html_string .= '   var first_child_arr = first_child.split(",");'. "\n";
            
            $html_string .= '   for (i=0; i<first_child_arr.length; i++) {'. "\n";
            $html_string .= '       ' . $this->tree_name  . '._idpull[first_child_arr[i]].htmlNode.parentNode.parentNode.style.display="";'. "\n";
            $html_string .= '   }'. "\n";
            
            //Checking Subsidiary//
            $html_string .= '   for (i=0; i<first_child_arr.length; i++) {'. "\n";
            $html_string .= '       var f_tree_level = ' . $this->tree_name  . '.getLevel(first_child_arr[i]);'. "\n";
            $html_string .= '       if (f_tree_level == 2) { '. "\n";
            $html_string .= '           if (' . $this->tree_name  . '.getItemText(first_child_arr[i]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking Strategy//
            $html_string .= '               var second_child = ' . $this->tree_name  . '.getAllSubItems(first_child_arr[i]);'. "\n";
            $html_string .= '               var second_child_arr = second_child.split(",");'. "\n";
            $html_string .= '               var second_child_chk = 0;'. "\n";
            $html_string .= '               for (j=0; j<second_child_arr.length; j++) {'. "\n";
            $html_string .= '                   var s_tree_level = ' . $this->tree_name  . '.getLevel(second_child_arr[j]);'. "\n";
            $html_string .= '                   if (s_tree_level == 3) {'. "\n";
            $html_string .= '                       if (' . $this->tree_name  . '.getItemText(second_child_arr[j]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking book//
            $html_string .= '                           var third_child = ' . $this->tree_name  . '.getAllSubItems(second_child_arr[j]);'. "\n";
            $html_string .= '                           var third_child_arr = third_child.split(",");'. "\n";
            $html_string .= '                           var third_child_chk = 0;'. "\n";
            $html_string .= '                           for (k=0; k<third_child_arr.length; k++) {'. "\n";
            $html_string .= '                               var t_tree_level = ' . $this->tree_name  . '.getLevel(third_child_arr[k]);'. "\n";
            $html_string .= '                               if (t_tree_level == 4) {'. "\n";
            $html_string .= '                                   if (' . $this->tree_name  . '.getItemText(third_child_arr[k]).toString().toLowerCase().indexOf(search_value.toLowerCase()) == -1){'. "\n";
            //Checking Sub book//
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
            //Checking Sub book end//
            $html_string .= '                                       if (fourth_child_chk == 0) {'. "\n";
            $html_string .= '                                           ' . $this->tree_name  . '._idpull[third_child_arr[k]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '                                       }'. "\n";
            $html_string .= '                                   } else { third_child_chk = 1;}'. "\n";
            $html_string .= '                               }'. "\n";
            $html_string .= '                           }'. "\n";
            //Checking book end//
            $html_string .= '                           if (third_child_chk == 0) {'. "\n";
            $html_string .= '                               ' . $this->tree_name  . '._idpull[second_child_arr[j]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '                           } else { second_child_chk = 1; }'. "\n";
            $html_string .= '                       } else { second_child_chk = 1; }'. "\n";
            $html_string .= '                   }'. "\n";
            $html_string .= '               }'. "\n";
            //Checking strategy end//
            $html_string .= '               if (second_child_chk == 0) {'. "\n";
            $html_string .= '                   ' . $this->tree_name  . '._idpull[first_child_arr[i]].htmlNode.parentNode.parentNode.style.display="none";'. "\n";
            $html_string .= '               }'. "\n";
            $html_string .= '           }'. "\n";
            $html_string .= '       }'. "\n";
            $html_string .= '   }'. "\n";
            //Checking Subsidiary end//
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
         * [expand_level Expand the tree to certain level]
         * @param  string $expand_level [level]
         */
        public function expand_level($expand_level = 'root') {
            switch ($expand_level) {
                case 'root':
                    $level = 0;
                    break;
                case 'sub':
                    $level = 1;
                    break;
                case 'stra':
                    $level = 2;
                    break;
                case 'book':
                    $level = 3;
                    break;
                case 'all':
                    $level = 3;
                    break;
                default:
                    $level = 0;
                    break;
            }
            
            $html_string = '  var rootsAr = ' . $this->tree_name . '.getSubItems(0).split(",");'. "\n";
            $html_string .= ' for (var i=0;i<rootsAr.length;i++){'. "\n";
            
            if ($level < 3) {
                // shows subsidiaries
                $html_string .=  $this->tree_name . '.openItem(rootsAr[i]);'. "\n";

                // shows strategies
                if ($level > 0) {
                    $html_string .= '   var subsidiaries = ' . $this->tree_name . '.getSubItems(rootsAr[i]).split(",");'. "\n";
                    $html_string .= '   for(var j=0;j<subsidiaries.length;j++){'. "\n";
                    $html_string .=         $this->tree_name . '.openItem(subsidiaries[j])'. "\n";

                    // shows books
                    if ($level > 1) {
                        $html_string .= '   var strategies = ' . $this->tree_name . '.getSubItems(subsidiaries[i]).split(",");'. "\n";
                        $html_string .= '   for (var k=0;k<strategies.length;k++){'. "\n";
                        $html_string .=         $this->tree_name . '.openItem(strategies[k])'. "\n";                        
                        $html_string .= '   }'. "\n";
                    }
                    $html_string .= '   }'. "\n";
                }
            } else if ($level == 3) {
                $html_string .=     $this->tree_name . '.openAllItems(rootsAr[i])'. "\n";
            }

            $html_string .= ' }'. "\n";

            return $html_string; 
        }
    }
?>