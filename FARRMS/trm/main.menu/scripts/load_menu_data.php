<?php

    /**
     * @author rajiv@pioneersolutionsglobal.com
     * @copyright 2014
     * @modified_by nkhadgi@pioneersolutiosnglobal.com
     * @modified_date May 3, 2019
     */
    
    $config_file = '../../../' . $farrms_client_dir . '/product.global.vars.php';
    require_once $config_file;

    function load_all_menu_data($role_id, $user_name) {
        global $farrms_product_id, $main_menu_stack, $main_menu_stack_labels_text;
        /* Load prepare Menu essential variables */
        
        if ($role_id == -1 || $role_id == -100) {
            $menu_list = menu_builder_ul($farrms_product_id);
        } else {
            $menu_list = workflow_bulider_ul($role_id, $user_name);
        }

        return $menu_list;
    }

    function workflow_bulider_ul($role_id, $user_name) {
        $xml_workflow = "EXEC spa_workflow @flag='w', @role_id=" . $role_id;
        $recordsets = readXMLURL2($xml_workflow);
        $html_string = get_menu_list($recordsets, '');
        return $html_string;
    }
   
    function get_user_info() {
        global $app_user_name;
        $xml_user = "EXEC spa_message_board 'w', '" . $app_user_name . "'";
        $recordsets = readXMLURL($xml_user);
        return $recordsets;
    }

    function filter_array_by_level($recordsets, $level) {
        $final_array = array();

        foreach ($recordsets as $c_key => $item) {
            if ($item['level'] == $level) {
                array_push($final_array, $item);
            }
        }

        return $final_array;
    }
    
    function filter_array_by_parent($recordsets, $parent_id) {
        $final_array = array();

        foreach ($recordsets as $c_key => $item) {
            if ($item['parent_menu_id'] == $parent_id) {
                array_push($final_array, $item);
            }
        }

        return $final_array;
    }

    function menu_builder_ul($product_id) {
        $xml_menu = "EXEC spa_setup_menu @flag='k', @pre_flag='s', @product_category=" . $product_id;
        $key_prefix = 'MM';    //Application Main Menu identifier
        $key_suffx = 'k';
        $recordsets = readXMLURLCached($xml_menu,false,$key_prefix,$key_suffx);

        $html_string = '';
        $sections = filter_array_by_level($recordsets, 0);
        $modules = filter_array_by_level($recordsets, 1);

        foreach ($sections as $section) {
            $html_string .= '<li>';
            $html_string .= '<a href="#" class="dropdown-toggle nano-menu-list" title="' . get_locale_value($section['display_name']) . '">';
            $html_string .= $section['menu_image'];
            $html_string .= '<span>' . get_locale_value($section['display_name']) . '</span>';
            $html_string .= '<i class="fa fa-chevron-circle-right drop-icon"></i>';
            $html_string .= '</a>';

            $html_string .= '<ul class="submenu menu-list-content">';
            foreach ($modules as $module) {
                if ($section['function_id'] == $module['parent_menu_id']) {
                    $html_string .= '<li>';
                    $html_string .= '<a href="#" class="dropdown-toggle">' . get_locale_value($module['display_name']);
                    $html_string .= '<i class="fa fa-chevron-circle-right drop-icon"></i>';
                    $html_string .= '</a>';
                    $html_string .= '<ul class="submenu">';
                    $html_string .= get_menu_list($recordsets, $module['function_id']);
                    $html_string .= '</ul>';
                    $html_string .= '</li>';
                }               
            }
            $html_string .= '</ul>';
            $html_string .= '</li>';
        }
        
        return $html_string;
    }

    function get_menu_list($recordsets, $parent_id) {
        $html_string = '';
        $children = filter_array_by_parent($recordsets, $parent_id);

        foreach ($children as $child) {
            if ($child['parent_menu_id'] == $parent_id) {
                $html_string .= '<li>';
                if ($child['menu_type'] == 0 || $child['file_path'] != null) {
                    
                    if ($child['function_id'] == 20006300) {
                        $html_string .= '<a href="#" onclick="open_setup_application_theme();">' . get_locale_value($child['display_name']) .'</a>';
                    } else if ($child['function_id'] == 20006200) {
                        $html_string .= '<a href="#" onclick="return open_configuration_manager_auth(&quot;' . $child['file_path'] . '&quot;, &quot;' . $child['window_name'] . '&quot;, &quot;' . $child['display_name'] . '&quot;,&quot;' . $child['function_id'] . '&quot;);">'. get_locale_value($child['display_name']) .'</a>';
                    } else {
                        $html_string .= '<a href="#" onclick="return open_menu_window(&quot;' . $child['file_path'] . '&quot;, &quot;' . $child['window_name'] . '&quot;, &quot;' . $child['display_name'] . '&quot;,&quot;' . $child['function_id'] . '&quot;);">' . get_locale_value($child['display_name']) .'</a>';
                    }
                } else {
                    if ($parent_id == '') {
                        $html_string .= '<a href="#" class="dropdown-toggle nano-menu-list">';
                        $html_string .= '    <i class="fa fa-bars" style="padding-top: 2%;"></i>';
                        $html_string .= '    <span>' . get_locale_value($child['display_name']) . '</span>';
                        $html_string .= '    <i class="fa fa-chevron-circle-right drop-icon"></i>';
                        $html_string .= '</a>';
                    } else {
                        $html_string .= '<a href="#" class="dropdown-toggle">' . get_locale_value($child['display_name']);
                        $html_string .= '<i class="fa fa-chevron-circle-right drop-icon"></i>';
                        $html_string .= '</a>';
                    }
                    
                    $recursive_menu_list = get_menu_list($recordsets, $child['function_id']);
                    if ($recursive_menu_list != '') {
                        $html_string .= '<ul class="submenu">';
                        $html_string .= $recursive_menu_list;
                        $html_string .= '</ul>';
                    }
                }
                $html_string .= '</li>';
            }
        }

        return $html_string;
    }

?>