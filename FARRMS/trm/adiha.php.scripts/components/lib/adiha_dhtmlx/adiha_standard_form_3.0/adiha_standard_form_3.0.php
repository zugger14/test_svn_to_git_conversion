<?php
/** 
 *  @brief AdihaStandardForm Standrad for class
 *  @note From now on, on this document templateTables will refers to application_ui... tables and adiha_grid_.. tables 
 * 
 *  @par Description
 *  This class is used to generate a simple form according to the template defined in templateTables.
 *  Basic definition required to create a form should be present in templateTables prior to the use of this class.
 *  
 *  @par Usage:
 *  <pre> 
 *  {@code 
 *  $form_namespace = 'meter_data';
 *  $form_obj = new AdihaStandardForm($form_namespace, 10103000);
 *  $form_obj->define_grid("meter_id", "EXEC spa_meter_id 't'");
 *  echo $form_obj->init_form('Meters', 'Meter Details');
 *  echo $form_obj->close_form();
 *  }
 *  </pre>
 *  @author    Rajiv Basnet <rajiv@pioneersolutionsglobal.com>
 *  @version   3.0
 *  @date      2015-01-21
 *  @copyright Pioneer Solutions.
 */
class AdihaStandardForm {
    public $layout;
    public $menu;
    public $grid;
    public $grid_name = '';
    public $grid_sp;
    public $tabbar;
    public $details_tabbar;
    public $template_name;
    public $primary_field;
    public $name_space;
    public $function_id;
    public $form_load_function = "";
    public $save_function = "";
    public $delete_function = "";
    public $form_load_complete_function = "";
    public $grid_type = "";
    public $report_status = false;
    public $grid_menu_json = null;
    public $hide_edit_menu = false;
    public $hide_save = false;
    private $edit_permission;
    private $delete_permission;
    private $sorting_preference = '';
    private $hide_originals = null;
    private $left_width = 0;
    private $auto_adjust;
    private $selected_id;
	private $multiple_select = false;
	private $pivot_menu = false;
    
    private $define_apply_filters = false;
    private $show_apply_filter = true;
    private $filter_form_obj;
    private $filter_function_id;
    private $filter_template_name;
    private $filter_group_name;
    
    private $privilege_rights = false;
    private $add_privilege_menu = false;
    private $win_close_callback = '';
    private $value_col_ind = 1;
    
    
    /**
     * [__construct constructor function]
     * @param [type] $namespace   [Namespace for form]
     * @param [type] $function_id [Function id]
     */
    public function __construct($namespace, $function_id) {
        $this->name_space = $namespace;  
        $this->function_id = $function_id;
    }

    /**
     * [define_grid Define grid for left side of the form, that is defined in adiha_grid_definition]
     * @param  [type] $grid_name [Grid Name]
     * @param  [type] $grid_sp   [Grid SP]
     * @param  [type] $grid_type [type o grid - 'a' for accordion grid, else grid/treegrid]
     * @param  [Boolean] true if accordian grid used for Report else false
     */
    public function define_grid($grid_name, $grid_sp, $grid_type = '', $report_status=false, $sorting_preference = '', $auto_adjust = false) {
        $this->grid_name = $grid_name;
        $this->grid_sp = $grid_sp;
        $this->grid_type = $grid_type;
        $this->report_status = $report_status;
        $this->sorting_preference = $sorting_preference;
        $this->auto_adjust = $auto_adjust;
    }

    /**
     * [define_layout_widht Define width for layout cells]
     * @param  [int] $left_width  [Cell a width]
     */
    public function define_layout_width($left_width) {
        $this->left_width = $left_width;
    }

    /**
     * [define_custom_functions Define custom functions for save and form load]
     * @param  [type] $save_function      [Name of save function]
     * @param  [type] $form_load_function [Name of form load function]
     * @param  [type] $delete_function [Name of left tree delete function]
     * @param  [type] $form_load_complete_function [Name of function that is returned to after form load by standard form]
     */
    public function define_custom_functions($save_function, $form_load_function, $delete_function,$form_load_complete_function, $before_save_validation, $after_save_function) {
        $this->save_function = $save_function;
        $this->form_load_function = $form_load_function;
        $this->delete_function = $delete_function;
        $this->form_load_complete_function = $form_load_complete_function;
        $this->before_save_validation = $before_save_validation;
        $this->after_save_function = $after_save_function;
    
    }
    
    /**
     * [define_custom_setting Controls to modify the default standard form]
     * @param  [type] $hide_save      [Control to hide the default save button in form]
     */
    public function define_custom_setting($hide_save) {
        $this->hide_save = $hide_save;
        
    }
    
    /**
     * [define_apply_filters Controls to add apply filters in standard form]
     * @param  [type] $enable      [Control to enable filter form]
     */
    public function define_apply_filters($filter_enable, $filter_function_id = '', $filter_template_name = '', $filter_group_name = '') {
        $this->define_apply_filters = $filter_enable;
        $this->filter_function_id = $filter_function_id;
        $this->filter_template_name = $filter_template_name;
        $this->filter_group_name = $filter_group_name;
    }
    
    /**
     * [show_apply_filter ]
     * @param  [type] $enable      [False - just create the layout, donot load the apply filter]
     */
    public function show_apply_filter($enable) {
        $this->show_apply_filter = $enable;
    }
    
    
    public function add_privilege_menu($privilege_rights, $win_close_callback, $value_col_ind) {
        $this->add_privilege_menu = true;
        $this->privilege_rights = ($privilege_rights == '' || $privilege_rights == 0) ? 'false' : 'true';
        $this->win_close_callback = $win_close_callback;
        $this->value_col_ind = ($value_col_ind == '') ? 1 : $value_col_ind;
    }
    
    /**
     * [init Initialize the form]
     * @param  [type] $first_cell_label  [Label for first cell]
     * @param  [type] $second_cell_label [Label for second cell]
     */
    public function init_form($first_cell_label, $second_cell_label, $selected_id = '', $farrms_product_id = '') {
        $this->selected_id = $selected_id;
        $sp_form = "EXEC spa_create_application_ui_json @flag = 'a', @application_function_id = '" . $this->function_id . "'";
        $form_def = readXMLURL2($sp_form);

        $this->template_name = $form_def[0][template_name];
        $this->primary_field = $form_def[0][primary_field];  
 
        $this->edit_permission = ($form_def[0][edit_permission] == 'y') ? "true": "false";
        $this->delete_permission = ($form_def[0][delete_permission] == 'y') ? "true": "false";  
        
        $this->layout = new AdihaLayout();
        $this->menu = new AdihaMenu();

        if ($this->grid_type == 'a') {
            $this->grid = new AccordionGrid($this->grid_name);
        } else {
            $this->grid = new GridTable($this->grid_name);
        }
        $this->filter_form_obj = new AdihaForm();
        $this->tabbar = new AdihaTab();
        $cell_a_width = ($this->left_width == 0) ? 350 : $this->left_width;
        
        $grid_cell = 'a';
        $tab_cell = 'b';
        if($this->define_apply_filters) {
            $filter_cell = 'b';
            $grid_cell = 'c';
            $tab_cell = 'd';
        }
        
        $layout_json = '[
                        {
                            id:             "'.$grid_cell.'",
                            text:           "<div><a class=\"undock_cell_a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\"' . $this->name_space .'.undock_cell_a_standard_form(\''.$grid_cell.'\');\"><!--&#8599;--></a>' . $first_cell_label . '</div>",
                            header:         true,
                            width:          ' . $cell_a_width . ', 
                            collapse:       false,
                            fix_size:       [false,null] 
                        },
                        {
                            id:             "'.$tab_cell.'",
                            text:           "' . $second_cell_label . '",
                            header:         true,
                            collapse:       false, 
                            fix_size:       [false,null]
                        }
                        ';
        if ($this->define_apply_filters)               
            $layout_json .= ',
                            {
                                id:             "a",
                                text:           "Filters",
                                header:         true,
                                collapse:       false,
                                height:         100, 
                                fix_size:       [false,null]
                            },
                            {
                                id:             "'.$filter_cell.'",
                                text:           "Filters Criteria",
                                header:         true,
                                collapse:       false,
                                height:         220, 
                                fix_size:       [false,null]
                            }';
        
        $layout_json .= ']';
        
        $menu_name = $this->name_space . 'menu';
        $menu_json = '[';
        
        if ($this->define_apply_filters && $this->show_apply_filter)
            $menu_json .= '{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},';
        
        if ($this->hide_edit_menu == false){
        $menu_json .='  
                        {id:"t1", text:"Edit", img:"edit.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $this->edit_permission . '"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                        ]},';
        }
        $menu_json .='  
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]}';
        if ($this->pivot_menu) {
            $menu_json .=',{id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", title: "Pivot"}';
        }
        
        if ($this->add_privilege_menu) {
            $menu_json .=',{id:"process", text:"Process", img:"process.gif", items:[
                            {id:"activate", text:"Activate Privilege", enabled: false, img:"lock.gif", imgdis:"lock_dis.gif", title: "Activate Privilege"},
                            {id:"deactivate", text:"Deactivate Privilege", enabled: false, img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Deactivate Privilege"},
                            {id:"privilege", text:"Maintain Privilege", enabled: false, img:"privilege.gif", imgdis:"privilege_dis.gif", title: "Maintain Privilege"}
                        ]}';
        }
                       
        $menu_json .='  ]';
        if ($this->define_apply_filters)
            $layout_pattern = '4G';
        else
            $layout_pattern = '2U';
        
        $return_string =  $this->layout->init_layout('layout', '', $layout_pattern, $layout_json, $this->name_space);
        
        if ($this->grid_type == 'a') {
            if (!$this->report_status) {
                $inner_acc_json = '[
                                        {
                                            id: "a",
                                            text: "button",
                                            header: false,
                                            collapse: false,
                                            fix_size: [true, null]
                                        }
                                    ]';
                
                $return_string .=  $this->layout->attach_layout_cell("accordion", "$grid_cell", "1C", $inner_acc_json);
                $accordion_layout = new AdihaLayout();
                $return_string .= $accordion_layout->init_by_attach("accordion", $this->name_space);
                $return_string .= $accordion_layout->attach_menu_cell("menu", "a"); 
                $return_string .= $accordion_layout->attach_accordion_cell("acc_grid", "a");
            } else {
                $return_string .=  $this->layout->attach_accordion_cell("acc_grid", "$grid_cell");
            }

            $return_string .=  $this->grid->onsingle_click_function($this->name_space.'.enable_menu_item');
            $return_string .=  $this->grid->ondouble_click_function($this->name_space.'.create_tab');
            $return_string .=  $this->grid->init_accordion_grid("acc_grid", $this->name_space);
            $return_string .=  $this->grid->attach_search_textbox('layout', "$grid_cell");

        } else {
            $return_string .= $this->layout->attach_menu_cell("menu", "$grid_cell"); 
            $return_string .=  $this->layout->attach_event('', 'onDock', $this->name_space.'.on_dock_event');
            $return_string .=  $this->layout->attach_event('', 'onUnDock', $this->name_space.'.on_undock_event');

            $return_string .=  $this->layout->attach_grid_cell("grid", "$grid_cell");
            $return_string .=  $this->layout->attach_status_bar("$grid_cell", true);

            $return_string .=  $this->grid->init_grid_table('grid', $this->name_space);
            $return_string .=  $this->grid->set_column_auto_size();
            $return_string .=  $this->grid->set_search_filter(true, "");
            $return_string .=  $this->grid->enable_paging(100, 'pagingArea_'.$grid_cell, 'true');

			if ($this->multiple_select == true) {
				$return_string .= $this->grid->enable_multi_select();
			}
						
            if ($this->sorting_preference != '') {
                $return_string .=  $this->grid->set_sorting_preference($this->sorting_preference);
            }

            $return_string .=  $this->grid->return_init();
            if ($this->selected_id != '') {
                $return_string .=  $this->grid->load_grid_data($this->grid_sp, '', $this->auto_adjust, $this->name_space . '.open_tab'); 
            } else {
                $return_string .=  $this->grid->load_grid_data($this->grid_sp, '', $this->auto_adjust); 
            }
            $return_string .=  $this->grid->attach_event('', 'onRowSelect', $this->name_space.'.enable_menu_item');           
            $return_string .=  $this->grid->attach_event('', 'onRowDblClicked', $this->name_space.'.create_tab');            
        }

        if (!$this->report_status) {
            $return_string .= $this->menu->init_by_attach("menu", $this->name_space);
            $return_string .= $this->menu->load_menu($menu_json);
            $return_string .= $this->menu->attach_event('', 'onClick', $this->name_space . '.grid_menu_click');
        }
        
        $return_string .=  $this->layout->attach_tab_cell('tabbar', "$tab_cell");
        $return_string .=  $this->tabbar->init_by_attach('tabbar', $this->name_space);
        $return_string .=  $this->tabbar->enable_tab_close();
        $return_string .=  $this->tabbar->attach_close_tab_event();
        
        if ($this->define_apply_filters  && $this->show_apply_filter) {
            $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$this->filter_function_id', @template_name='$this->filter_template_name', @group_name='$this->filter_group_name', @template_type='Filter'";
            $return_value = readXMLURL($xml_file);
            $form_json = $return_value[0][2];

            $return_string .= $this->layout->attach_form('apply_filter', "a");
            $return_string .= $this->layout->attach_form('filter_form', "$filter_cell");
            $return_string .= $this->filter_form_obj->init_by_attach('filter_form', $this->name_space);
            $return_string .= $this->filter_form_obj->load_form($form_json, $callback_function);
            $return_string .= $this->filter_form_obj->load_form_filter($this->name_space, 'apply_filter', 'layout', 
                "$filter_cell", $this->filter_function_id, 2);
            
            $callback_function = ' load_dependent_combo("' . $return_value[0][6] . '"  , 0 , '. $this->name_space . '.filter_form);'; 
            $return_string .= $this->layout->collapse_cell("a");
            $return_string .= $this->layout->collapse_cell("$filter_cell");
        }
        return $return_string;
    }

    /**
     * [generate_hex_tab_id Returns PHP equivalent of ord - used in this class to create a numeric tabid for string data]
     */
    private function generate_hex_tab_id() {
        $return_string .= 'function ord(string) {'. "\n";
        $return_string .= ' var str = string + "",'. "\n";
        $return_string .= '     code = str.charCodeAt(0);'. "\n";
        $return_string .= ' if (0xD800 <= code && code <= 0xDBFF) {'. "\n";
        // High surrogate (could change last hex to 0xDB7F to treat high private surrogates as single characters)
        $return_string .= '     var hi = code;'. "\n";
        $return_string .= '     if (str.length === 1) {'. "\n";
        // This is just a high surrogate with no following low surrogate, so we return its value;
        $return_string .= '         return code;'. "\n";
        // we could also throw an error as it is not a complete character, but someone may want to know';
        $return_string .= '     }'. "\n";
        $return_string .= '     var low = str.charCodeAt(1);'. "\n";
        $return_string .= '     return ((hi - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;'. "\n";
        $return_string .= ' }'. "\n";
        $return_string .= ' if (0xDC00 <= code && code <= 0xDFFF) {'. "\n";
        // Low surrogate
        // This is just a low surrogate with no preceding high surrogate, so we return its value;';
        $return_string .= '     return code;'. "\n";
        // we could also throw an error as it is not a complete character, but someone may want to know';
        $return_string .= ' }'. "\n";
        $return_string .= ' return code;'. "\n";
        $return_string .= '}'. "\n";
        return $return_string;
    }

    /**
     * [close_form Close form - also includes all necessary functions with it]
     */
    public function close_form() {
        $return_string .= $this->layout->close_layout();
        $return_string .= $this->attach_function();
        return $return_string;
    }

    /**
     * [attach_function Attach necessary functions]
     */
    private function attach_function() {
        $return_string  = '<script type="text/javascript">'. "\n";
        if ($this->grid_type != 'a') {
            $return_string .= $this->grid->load_grid_functions();
        }
        $return_string .= $this->create_tab();
        $return_string .= $this->create_id();
        $return_string .= $this->open_tab();
        $return_string .= $this->refresh_tab_properties();
        $return_string .= $this->get_id();
        $return_string .= $this->get_text();
        $return_string .= $this->click_grid_menu();
        $return_string .= $this->click_tab_toolbar();
        $return_string .= $this->set_form_data();
        $return_string .= $this->generate_hex_tab_id();
        $return_string .= $this->undock_cell();
        $return_string .= $this->clear_delete_xml();
        $return_string .= $this->enable_menu_item();
        $return_string .= '</script>' . "\n";

        return $return_string;
    }

    /**
     * [click_grid_menu Grid Menu click functions]
     */
    private function click_grid_menu() {
        global $app_php_script_loc;

        $return_string  = $this->name_space . '.grid_menu_click = function(id, zoneId, cas) {'. "\n";
        $return_string .= ' switch(id) {' . "\n";
        $return_string .= '        case "add":'  . "\n";

        if ($this->report_status == false && $this->grid_type == 'a') {

            $return_string .=           $this->name_space .'.acc_grid.forEachItem(function(cell){';
            $return_string .= '             var open_cell = cell.isOpened();';
            $return_string .= '             if(open_cell == true) {';
            $return_string .= '                 cell_id = cell.getId();';
            $return_string .= '             }';
            $return_string .= '         });';

            if (cell_id != null) {
                $return_string .= '         var grid_obj = ' . $this->name_space . '.acc_grid.cells(cell_id).getAttachedObject();'. "\n";
                $return_string .=       $this->name_space.'.create_tab(-1,0,grid_obj,cell_id);'. "\n";
            }

        } else {
            $return_string .=               $this->name_space.'.create_tab(-1,0,0,0);'. "\n";
        }

        $return_string .= '             break;'. "\n";
        
        // delete clicked
        $return_string .= '        case "delete":'. "\n";

        if ($this->delete_function != "") {
            // for accordion
            if ($this->grid_type == "a") {
                $return_string .= '         var grid_obj;';
                $return_string .=           $this->name_space .'.acc_grid.forEachItem(function(cell){';
                $return_string .= '             var open_cell = cell.isOpened();';
                $return_string .= '             if(open_cell == true) {';
                $return_string .= '                 grid_obj = cell.getAttachedObject();';
                $return_string .= '             }';
                $return_string .= '         });';
                $return_string .=           $this->name_space . '.' . $this->delete_function.'(grid_obj);'. "\n";  
            } else {
                $return_string .=           $this->name_space . '.' . $this->delete_function.'();'. "\n";  
            }

        // for grid and tree grid
        } else {
            $return_string .= '         var select_id = ' . $this->name_space .   '.grid.getSelectedRowId();'. "\n";
            $return_string .= '         if (select_id != null) {'. "\n";
            $return_string .= '             dhtmlx.message({'. "\n";
            $return_string .= '                type: "confirm",'. "\n";
            $return_string .= '                title: "Confirmation",'. "\n";
            $return_string .= '                ok: "Confirm",'. "\n";
            $return_string .= '                text: "Are you sure you want to delete?",'. "\n";
            $return_string .= '                callback: function(result) {'. "\n";
            $return_string .= '                    if (result) {'. "\n";            
            $return_string .= '                         var full_id = ' . $this->name_space . '.get_id(' . $this->name_space . '.grid, select_id);'. "\n";
            $return_string .= '                         var full_id_split = full_id.split("_");  full_id_split.splice(0,1); var get_id_only = full_id_split.join("_");' . "\n";
            $return_string .= '                         var xml = "<Root function_id=\"' . $this->function_id . '\" object_id=\"" + get_id_only + "\">";' . "\n";
            $return_string .= '                         xml += "<GridDelete grid_id=\""+ get_id_only + "\">";' . "\n";
            $return_string .= '                         xml += get_id_only;' . "\n";
            $return_string .= '                         xml += "</GridDelete>";' . "\n";
            $return_string .= '                         xml += "</Root>";' . "\n";    
            $return_string .= '                         xml = xml.replace(/\'/g, "\"");' . "\n";             
            $return_string .= '                         data = {"action": "spa_process_form_data", "xml":xml, "flag": "d"}'. "\n";
            $return_string .= '                         result = adiha_post_data("return_array", data, "", "","' . $this->name_space . '.post_delete_callback");'. "\n";                           
            $return_string .= '                    }'. "\n";
            $return_string .= '                }'. "\n";
            $return_string .= '             });'. "\n";            
            $return_string .= '         } else {'. "\n";            
            $return_string .= '             dhtmlx.alert({'. "\n";
            $return_string .= '                 title:"Alert",'. "\n";
            $return_string .= '                 type:"alert",'. "\n";
            $return_string .= '                 text:"Please select a row from grid."'. "\n";
            $return_string .= '             });'. "\n";
            $return_string .= '         }'. "\n";
        }
        
        $return_string .= '             break;'. "\n";

        //excel export
        $return_string .= '        case "excel":'. "\n";
        $return_string .=               $this->name_space .   '.grid.toExcel("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php");'. "\n";
        $return_string .= '             break;'. "\n";
        
        // pdf export
        $return_string .= '        case "pdf":'. "\n";
        $return_string .=               $this->name_space .   '.grid.toPDF("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");'. "\n";
        $return_string .= '             break;'. "\n";
        // Refresh Grid
        $return_string .= '        case "refresh":'. "\n";
        $return_string .= '             var filter_param = ' . $this->name_space . '.get_filter_parameters();' . "\n";
        $return_string .=               $this->name_space . '.refresh_grid("",' . $this->name_space . '.enable_menu_item, filter_param);' . "\n";
        $return_string .=               $this->name_space.'.layout.cells("a").collapse();' . "\n";
        $return_string .=               $this->name_space.'.layout.cells("b").collapse();' . "\n";
        $return_string .= '             break;'. "\n";
        // Grid Pivot
        $return_string .= '        case "pivot":'. "\n";
        $return_string .= '             var grid_obj = ' . $this->name_space .   '.grid;' . "\n";
        $return_string .= '             var grid_name = "' . $this->grid_name .   '";' . "\n";
        $return_string .= '             var grid_sp = "' . $this->grid_sp .   '";' . "\n";
        
        $return_string .= '             open_grid_pivot(grid_obj, grid_name, -1, grid_sp);' . "\n";
        $return_string .= '             break;'. "\n";
        // Privilege Menu
        if ($this->add_privilege_menu) {
            $return_string .= ' case "privilege":' . "\n";
            $return_string .= '     var col_type = ' . $this->name_space . '.grid.getColType(0);' . "\n";
            $return_string .= '     if(col_type == "tree") {var value_col_index = ' . $this->value_col_ind . ';} else {var value_col_index = 0;}' . "\n";
            $return_string .= '     var selected_row = ' . $this->name_space . '.grid.getSelectedRowId();' . "\n";
            $return_string .= '     var selected_row_arr = selected_row.split(",");' . "\n";
            $return_string .= '     var value_id = ""; ' . "\n";
            $return_string .= '     var type_id = ""; ' . "\n";
            $return_string .= '     value_id = ' . $this->name_space . '.grid.cells(selected_row_arr[0], value_col_index).getValue();' . "\n"; 
            $return_string .= '     type_id = ' . $this->name_space . '.grid.cells(selected_row_arr[0], ' . $this->name_space . '.grid.getColIndexById("type_id")).getValue(); ' . "\n";
            $return_string .= '     for(i = 1; i < selected_row_arr.length; i++) {' . "\n";
            $return_string .= '         value_id = value_id + "," + ' . $this->name_space . '.grid.cells(selected_row_arr[i], value_col_index).getValue();' . "\n";
            $return_string .= '         type_id = type_id + "," + ' . $this->name_space . '.grid.cells(selected_row_arr[i], ' . $this->name_space . '.grid.getColIndexById("type_id")).getValue();' . "\n";
            $return_string .= '     }' . "\n";
            $return_string .= '     open_static_data_privilege_window(type_id, value_id); ' . "\n";
            $return_string .= '     break;' . "\n";
            $return_string .= ' case "activate":' . "\n";
            $return_string .= '     var col_type = ' . $this->name_space . '.grid.getColType(0);' . "\n";
            $return_string .= '     var selected_row = ' . $this->name_space . '.grid.getSelectedRowId();' . "\n";
            $return_string .= '     var selected_row_arr = selected_row.split(",");' . "\n";
            $return_string .= '     var level;' . "\n";
            $return_string .= '     if (col_type == "tree") { ' . "\n";
            $return_string .= '         for(i = 0; i < selected_row_arr.length; i++) {' . "\n";
            $return_string .= '             level = ' . $this->name_space . '.grid.getLevel(selected_row_arr[i])' . "\n";
            $return_string .= '             if (level == 1) { ' . "\n";
            $return_string .= '                 var selected_row = selected_row_arr[i];' . "\n";
            $return_string .= '                 break;' . "\n";
            $return_string .= '             }' . "\n";
            $return_string .= '         }' . "\n";
            $return_string .= '     } else { ' . "\n";
            $return_string .= '         var selected_row = selected_row_arr[0];' . "\n";
            $return_string .= '     }' . "\n";
            $return_string .= '     if (col_type == "tree" && level == 0) { ' . "\n";
            $return_string .= '         var call_from = 0; var type_id = ' . $this->name_space . '.grid.getItemText(selected_row, 0);' . "\n";
            $return_string .= '     } else {' . "\n";
            $return_string .= '         var call_from = 1; var type_id = ' . $this->name_space . '.grid.cells(selected_row, ' . $this->name_space . '.grid.getColIndexById("type_id")).getValue();' . "\n"; 
            $return_string .= '     }' . "\n";
            $return_string .= '     dhtmlx.message({type: "confirm", title: "Confirmation", ok: "Confirm", text: "Are you sure you want to Activate ?",' . "\n"; 
            $return_string .= '          callback: function(result) {' . "\n"; 
            $return_string .= '              if (result) {      ' . "\n"; 
            $return_string .= '                  var data = {"action": "spa_static_data_privilege", "type_id": type_id, "flag" : "a", "call_from": call_from};' . "\n"; 
            $return_string .= '                  adiha_post_data("return_array", data, "", "", "' . $this->name_space . '.activate_callback");' . "\n"; 
            $return_string .= '              }' . "\n"; 
            $return_string .= '         }' . "\n";
            $return_string .= '     }); ' . "\n";
            $return_string .= '     break;' . "\n";
            $return_string .= ' case "deactivate":' . "\n";
            $return_string .= '     var col_type = ' . $this->name_space . '.grid.getColType(0);' . "\n";
            $return_string .= '     var selected_row = ' . $this->name_space . '.grid.getSelectedRowId();' . "\n";
            $return_string .= '     var selected_row_arr = selected_row.split(",");' . "\n";
            $return_string .= '     var level;' . "\n";
            $return_string .= '     if (col_type == "tree") { ' . "\n";
            $return_string .= '         for(i = 0; i < selected_row_arr.length; i++) {' . "\n";
            $return_string .= '             level = ' . $this->name_space . '.grid.getLevel(selected_row_arr[i])' . "\n";
            $return_string .= '             if (level == 1) { ' . "\n";
            $return_string .= '                 var selected_row = selected_row_arr[i];' . "\n";
            $return_string .= '                 break;' . "\n";
            $return_string .= '             }' . "\n";
            $return_string .= '         }' . "\n";       
            $return_string .= '     } else { ' . "\n";
            $return_string .= '         var selected_row = selected_row_arr[0];' . "\n";
            $return_string .= '     }' . "\n";
            $return_string .= '     if (col_type == "tree" && level == 0) { ' . "\n";
            $return_string .= '         var call_from = 0; var type_id = ' . $this->name_space . '.grid.getItemText(selected_row, 0);' . "\n";
            $return_string .= '     } else {' . "\n";
            $return_string .= '         var call_from = 1; var type_id = ' . $this->name_space . '.grid.cells(selected_row, ' . $this->name_space . '.grid.getColIndexById("type_id")).getValue();' . "\n"; 
            $return_string .= '     }' . "\n";
            $return_string .= '      dhtmlx.message({type: "confirm", title: "Confirmation", ok: "Confirm", text: "Are you sure you want to Deactivate ?",' . "\n"; 
            $return_string .= '          callback: function(result) {' . "\n"; 
            $return_string .= '              if (result) {      ' . "\n"; 
            $return_string .= '                  var data = {"action": "spa_static_data_privilege", "type_id": type_id, "flag" : "d", "call_from": call_from};' . "\n"; 
            $return_string .= '                  adiha_post_data("return_array", data, "", "", "' . $this->name_space . '.deactivate_callback");' . "\n"; 
            $return_string .= '              }' . "\n"; 
            $return_string .= '         }' . "\n";
            $return_string .= '     }); ' . "\n";
            $return_string .= '     break;' . "\n";
        }
        $return_string .= '   }' . "\n";
        $return_string .= '};' . "\n";
        
        $return_string .= $this->name_space . '.deactivate_callback = function (return_value) {' . "\n";
        $return_string .= '         if (return_value[0][0] == "Success") {' . "\n";
        $return_string .= '             dhtmlx.message({' . "\n";
        $return_string .= '                 text:return_value[0][4] ' . "\n";
        $return_string .= '             });' . "\n";
        $return_string .= $this->name_space . '.refresh_grid("", ' . $this->name_space . '.enable_menu_item);' . "\n";
        $return_string .= '         } else {' . "\n";
        $return_string .= '             dhtmlx.message({' . "\n";
        $return_string .= '                 title:"Alert",' . "\n";
        $return_string .= '                 type:"alert",' . "\n";
        $return_string .= '                 text:return_value[0][4]' . "\n";
        $return_string .= '             });' . "\n";
        $return_string .= '             return;' . "\n";
        $return_string .= '         } ' . "\n";
        $return_string .= ' }' . "\n";
        
        $return_string .= $this->name_space . '.activate_callback = function (return_value) {' . "\n";
        $return_string .= '         if (return_value[0][0] == "Success") {' . "\n";
        $return_string .= '             var value_id = "NULL";' . "\n";
        $return_string .= '             var type_id = return_value[0][5];' . "\n";
        $return_string .= '             open_static_data_privilege_window(type_id, value_id);' . "\n";
        $return_string .= '         } else {' . "\n";
        $return_string .= '             dhtmlx.message({' . "\n";
        $return_string .= '                 title:"Alert",' . "\n";
        $return_string .= '                 type:"alert",' . "\n";
        $return_string .= '                 text:return_value[0][4]' . "\n";
        $return_string .= '             });' . "\n";
        $return_string .= '             return;' . "\n";
        $return_string .= '         } ' . "\n";
        $return_string .= ' }' . "\n";
        
        $return_string .= ' var static_data_privilege;' . "\n";
        $return_string .= ' function open_static_data_privilege_window(type_id, value_id) {' . "\n";
        $return_string .= '     var params = "?value_id=" + value_id + "&type_id=" + type_id + "&call_from=1&namespace=' . $this->name_space . '&callback=' . $this->win_close_callback . '";' . "\n";
                            
        $return_string .= '     if (static_data_privilege != null && static_data_privilege.unload != null) {' . "\n";
        $return_string .= '         static_data_privilege.unload();' . "\n";
        $return_string .= '         static_data_privilege = w2 = null;' . "\n";
        $return_string .= '     }' . "\n";
                                
        $return_string .= '     if (!static_data_privilege) {' . "\n";
        $return_string .= '         static_data_privilege = new dhtmlXWindows();' . "\n";
        $return_string .= '     }' . "\n";
                
        $return_string .= '     var new_win = static_data_privilege.createWindow("w2", 0, 0, 800, 560);' . "\n";
        $return_string .= '     url = "' . $app_php_script_loc . '../adiha.html.forms/_setup/maintain_static_data/maintain.static.data.privileges.grid.php" + params; ' . "\n"; 
        $return_string .= '     new_win.setText("Maintain Privilege");  ' . "\n";
        $return_string .= '     new_win.centerOnScreen();' . "\n";
        $return_string .= '     new_win.setModal(true); ' . "\n";
        $return_string .= '     new_win.attachURL(url, false, true); ' . "\n";
        $return_string .= ' }' . "\n";
        
        $return_string .= $this->name_space . '.get_filter_parameters = function() {';
        $return_string .= '             filter_data = '.$this->name_space.'.filter_form.getFormData();' . "\n";
        $return_string .= '             console.log(filter_data);var filter_param = "<FormXML";' . "\n";
        $return_string .= '             for (var a in filter_data) {' . "\n";
        $return_string .= '                 if (filter_data[a] != "" && filter_data[a] != null) {' . "\n";
        $return_string .= '                     if ('.$this->name_space.'.filter_form.getItemType(a) == "calendar") {' . "\n";
        $return_string .= '                         var value = '.$this->name_space.'.filter_form.getItemValue(a, true);' . "\n";
        $return_string .= '                     } else {' . "\n";
        $return_string .= '                         var value = filter_data[a];' . "\n";
        $return_string .= '                     }' . "\n";
        $return_string .= '                     if (a != "apply_filters") {' . "\n";
        $return_string .= '                         filter_param += " " + a + "=\"" + value + "\"";' . "\n";
        $return_string .= '                     }' . "\n";
        $return_string .= '                 }' . "\n";
        $return_string .= '             }' . "\n";
        $return_string .= '             filter_param += "></FormXML>";' . "\n";
        $return_string .= '             return filter_param;' . "\n";
        $return_string .= '};' . "\n";
        
        $return_string .= $this->name_space . '.post_delete_callback = function(result) {';
        $return_string .= ' if (result[0][0] == "Success") { ';
        $return_string .= '     var select_id = ' . $this->name_space .   '.grid.getSelectedRowId();'. "\n";
        $return_string .= '     var full_id = ' . $this->name_space . '.get_id(' . $this->name_space . '.grid, select_id);'. "\n";
        $return_string .= '     if (' . $this->name_space . '.pages[full_id]) {' . "\n";
        $return_string .=           $this->name_space . '.tabbar.cells(full_id).close();'. "\n";
        $return_string .= '     }' . "\n";
        $return_string .=       $this->name_space . '.menu.setItemDisabled("delete");'. "\n";   
        $return_string .= '     dhtmlx.message({'. "\n";
        $return_string .= '         text:result[0][4],'. "\n";
        $return_string .= '         expire:1000'. "\n";
        $return_string .= '     });'. "\n";
        // calls the grid refresh function from Grid Class
        $return_string .= '    var col_type = '. $this->name_space . '.grid.getColType(0);' . "\n"; 
        $return_string .= '    if (col_type == "tree") {' . "\n"; 
        $return_string .=           $this->name_space . '.grid.saveOpenStates();' . "\n";
        $return_string .= '    }' . "\n"; 

        $return_string .= '    var page_no = ' . $this->name_space . '.grid.currentPage;' . "\n";         
        $return_string .=      $this->name_space . '.refresh_grid("", function(){' . "\n";
		$return_string .=           $this->name_space . '.grid.filterByAll(); ' . "\n";
        $return_string .= '         if (col_type == "tree") {' . "\n"; 
        $return_string .=               $this->name_space . '.grid.loadOpenStates();' . "\n";
        $return_string .= '         };' . "\n";
        $return_string .=           $this->name_space . '.grid.changePage(page_no);' . "\n";
        $return_string .= '    });' . "\n";
        $return_string .= ' } else {' . "\n";
        $return_string .= '     dhtmlx.message({'. "\n";
        $return_string .= '         title:"Alert",'. "\n";
        $return_string .= '         type:"alert",'. "\n";
        $return_string .= '         text:result[0][4]'. "\n";
        $return_string .= '     });'. "\n";
        $return_string .= ' }' . "\n";
        $return_string .= '};' . "\n";

        return $return_string;
    }

    /**
     * [click_tab_toolbar Tab toolbar click function]
     */
    private function click_tab_toolbar() {
        $return_string  = 'var delete_grid_name = ""; ';
        $return_string .= $this->name_space . '.tab_toolbar_click = function(id) {' . "\n";
        $return_string .= ' var validation_status = 0;'. "\n";
        $return_string .= ' switch(id) {' . "\n";
        $return_string .= '        case "close":';
        $return_string .= '             var tab_id = ' . $this->name_space . '.tabbar.getActiveTab();' . "\n";
        $return_string .= '             delete ' . $this->name_space . '.pages[tab_id];' . "\n";
        $return_string .= '             ' . $this->name_space . '.tabbar.tabs(tab_id).close(true);' . "\n";
        $return_string .= '             break;' . "\n";
        $return_string .= '        case "save":' . "\n";
		$return_string .= '        		'. $this->name_space . '.layout.cells("a").expand();' . "\n";
		$return_string .= '             var tab_id = ' . $this->name_space . '.tabbar.getActiveTab();' . "\n";

        if ($this->save_function != "") {
            if ($this->before_save_validation != "") { 
                $return_string .= ' var is_validated = '. $this->name_space . '.' . $this->before_save_validation . '(); '. "\n";
                $return_string .= ' if (is_validated == 0) {return;}'. "\n";
            }
            
            //custom save function
            $return_string .= $this->name_space . '.' . $this->save_function . '(tab_id);' . "\n";
        } else {
            
            if ($this->before_save_validation != "") { 
                $return_string .= ' var is_validated = '. $this->name_space . '.' . $this->before_save_validation . '(); '. "\n";
                $return_string .= ' if (is_validated == 0) {return;}'. "\n";
            }
            // generic saving logic  
            $return_string .= '             var win = ' . $this->name_space . '.tabbar.cells(tab_id);' . "\n";
            $return_string .= '             var valid_status = 1;' . "\n";
            $return_string .= '             var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;' . "\n";
            $return_string .= '             object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));' . "\n";
            $return_string .= '             var tab_obj = win.tabbar[object_id];' . "\n";
            $return_string .= '             var detail_tabs = tab_obj.getAllTabs();' . "\n";
            $return_string .= '             var grid_xml = "<GridGroup>";' . "\n";
            $return_string .= '             var form_xml = "<FormXML ";' . "\n";
            $return_string .= '             var form_status = true;
            var first_err_tab;' . "\n";
            $return_string .= '             var first_err_tab;' . "\n";
             $return_string .= '            var tabsCount = tab_obj.getNumberOfTabs();' . "\n";
            $return_string .= '             $.each(detail_tabs, function(index,value) {' . "\n";
            $return_string .= '                 layout_obj = tab_obj.cells(value).getAttachedObject();' . "\n";
            $return_string .= '                 layout_obj.forEachItem(function(cell){' . "\n";
            $return_string .= '                     attached_obj = cell.getAttachedObject();' . "\n";
            $return_string .= '                     if (attached_obj instanceof dhtmlXGridObject) {' . "\n";
            $return_string .= '                         attached_obj.clearSelection();' . "\n";
            $return_string .= '                         var ids = attached_obj.getChangedRows(true);' . "\n";          
            $return_string .= '                         grid_id = attached_obj.getUserData("","grid_id");' . "\n";
            $return_string .= '                         grid_label = attached_obj.getUserData("","grid_label");' . "\n";
            $return_string .= '                         deleted_xml = attached_obj.getUserData("","deleted_xml");' . "\n";
            $return_string .= '                         if(deleted_xml != null && deleted_xml != "") {' . "\n";
            $return_string .= '                             grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";' . "\n";
            $return_string .= '                             grid_xml += deleted_xml;' . "\n";
            $return_string .= '                             grid_xml += "</GridDelete>";' . "\n";
            $return_string .= '                             if(delete_grid_name == ""){delete_grid_name = grid_label} else{ delete_grid_name += "," + grid_label};' . "\n";
            $return_string .= '                         };' . "\n";

            $return_string .= '                         if(ids != "") {' . "\n";
            $return_string .= '                             attached_obj.setSerializationLevel(false,false,true,true,true,true);' . "\n";
            $return_string .= '                              if(valid_status != 0){' . "\n";
            $return_string  .= '                            var grid_status = '. $this->name_space . '.validate_form_grid(attached_obj,grid_label);' . "\n";
            $return_string  .= '                            }' . "\n";  
            $return_string .= '                             grid_xml += "<Grid grid_id=\""+ grid_id + "\">";' . "\n";
            $return_string .= '                             var changed_ids = new Array();' . "\n";
            $return_string .= '                             changed_ids = ids.split(",");' . "\n";
            $return_string .= '                             if(grid_status){' . "\n";
            $return_string .= '                             $.each(changed_ids, function(index, value) {' . "\n";
            $return_string .= '                                 attached_obj.setUserData(value,"row_status","new row");' . "\n";
            $return_string .= '                                 grid_xml += "<GridRow ";' . "\n";
            $return_string .= '                                 for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){' . "\n";
            $return_string .= '                                     if (attached_obj.cells(value, cellIndex).getValue() == \'undefined\') { //Cannot use typeof because it returns string'. "\n";
            $return_string .= '                                         grid_xml += " " + attached_obj.getColumnId(cellIndex) + \'= "NULL"\';'. "\n";
            $return_string .= '                                         continue;' . "\n";
            $return_string .= '                                     }' . "\n";
            $return_string .= '                                     grid_xml += " " + attached_obj.getColumnId(cellIndex) + \'="\' + attached_obj.cells(value,cellIndex).getValue() + \'"\';' . "\n";
            $return_string .= '                                 }' . "\n";
            $return_string .= '                                 grid_xml += " ></GridRow> ";' . "\n";
            $return_string .= '                             });' . "\n";
            $return_string .= '                             grid_xml += "</Grid>";' . "\n";
            $return_string .= '                             } else { valid_status = 0; };' . "\n";
            $return_string .= '                         }' . "\n";
            $return_string .= '                     } else if(attached_obj instanceof dhtmlXForm) {' . "\n";
            $return_string .= '                          var status = validate_form(attached_obj); ' . "\n";
            $return_string .= 'form_status = form_status && status;' . "\n";
            
            $return_string .= 'if (tabsCount == 1 && !status) {' . "\n";
            $return_string .= 'first_err_tab = "";
                }' . "\n";

            $return_string .= 'else if ((!first_err_tab) && !status) {' . "\n";
            $return_string .= '     first_err_tab = tab_obj.cells(value);
                                }' . "\n";
            $return_string .= '         if(status) {
            ' . "\n";
            $return_string .= '                         data = attached_obj.getFormData();' . "\n";
            $return_string .= '                         for (var a in data) {' . "\n";
            $return_string .= '                             field_label = a;' . "\n";
            $return_string .= '                             if(attached_obj.getItemType(field_label) == "calendar"){' . "\n";
            $return_string .= '                                 field_value = attached_obj.getItemValue(field_label,true);'. "\n";
            $return_string .= '                             } else {' . "\n";
            $return_string .= '                             field_value = data[a];' . "\n";
            $return_string .= '                             }' . "\n";
            $return_string .= '                             form_xml += " " + field_label + "=\"" + field_value + "\"";' . "\n";
            $return_string .= '                             }';
            $return_string .= '                         } else { valid_status = 0;}';
            $return_string .= '                    }';
            $return_string .= '                 });' . "\n";
            $return_string .= '             });' . "\n";
            $return_string .= '             form_xml += "></FormXML>";' . "\n";
            $return_string .= '             grid_xml += "</GridGroup>";' . "\n";
            $return_string .= '             var xml = "<Root function_id=\"' . $this->function_id . '\" object_id=\"" + object_id + "\">";' . "\n";
            $return_string .= '             xml += form_xml;' . "\n";
            $return_string .= '             xml += grid_xml;' . "\n";
            $return_string .= '             xml += "</Root>";' . "\n";
            $return_string .= '             xml = xml.replace(/\'/g, "\"");' . "\n";
            $return_string .= '             if (!form_status) { 
                                                generate_error_message(first_err_tab);
                                            }' . "\n";
            $return_string .= '             if(valid_status == 1){' . "\n";  
            $return_string .= ' win.getAttachedToolbar().disableItem(\'save\');
            ' . "\n";

            $return_string .= '             data = {"action": "spa_process_form_data", "xml":xml}' . "\n";
            $return_string .= '                 if(delete_grid_name != ""){' . "\n";
            $return_string .= '                     del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";' . "\n";
            $return_string .= '                     result = adiha_post_data("confirm-warning", data, "", "", "' . $this->name_space . '.post_callback","",del_msg);' . "\n";
            // $return_string .= '                     dhtmlx.message({' . "\n";
            // $return_string .= '                         type: "confirm-warning",' . "\n";
            // $return_string .= '                         title: "Warning",' . "\n";
            // $return_string .= '                         text: del_msg,' . "\n";
            // $return_string .= '                         callback: function(result) {' . "\n";
            // $return_string .= '                             if (result)' . "\n";
            // $return_string .= '                                 result = adiha_post_data("alert", data, "", "", "' . $this->name_space . '.post_callback","",del_msg);' . "\n";
            // $return_string .= '                         }' . "\n";
            // $return_string .= '                     });' . "\n";
            $return_string .= '                 } else {' . "\n";
            $return_string .= '                     result = adiha_post_data("alert", data, "", "", "' . $this->name_space . '.post_callback");' . "\n";
            $return_string .= '                 }' . "\n";
            $return_string .= '                 delete_grid_name = "";' . "\n";
            $return_string .= '                 deleted_xml = attached_obj.setUserData("","deleted_xml", "");' . "\n";
            $return_string .= '             }'. "\n";
        }

        $return_string .= '             break;' . "\n";
        $return_string .= '        default:';
        //$return_string .= '             dhtmlx.alert({';
//        $return_string .= '                 title:"Error",';
//        $return_string .= '                 type:"alert-error",';
//        $return_string .= '                 text:"Not implemented"';
//        $return_string .= '             });';
        $return_string .= '         break;';
        $return_string .= '        }';
        $return_string .= '};'; 

        $return_string .= $this->name_space . '.post_callback = function(result) {  '. "\n";
        $return_string .= 'var tab_id = ' . $this->name_space . '.tabbar.getActiveTab(); ' . "\n";
        $return_string .= ' ' . $this->name_space . '.tabbar.cells(tab_id).getAttachedToolbar().enableItem(\'save\');';             
        $return_string .= '   if (result[0].errorcode == "Success") {'. "\n";
        $return_string .=       $this->name_space . '.clear_delete_xml();'. "\n";
        $return_string .= '     var col_type = '. $this->name_space . '.grid.getColType(0);' . "\n"; 
        $return_string .= '     if (col_type == "tree") {' . "\n"; 
        $return_string .=           $this->name_space . '.grid.saveOpenStates();' . "\n";
        $return_string .= '     }' . "\n"; 
        $return_string .= '         if (result[0].recommendation != null) {';
        $return_string .= '             var tab_id = ' . $this->name_space . '.tabbar.getActiveTab();' . "\n";
        $return_string .= '             var previous_text = ' . $this->name_space . '.tabbar.tabs(tab_id).getText();' . "\n";        
        $return_string .= '             if (previous_text == "New") {' . "\n";
        $return_string .= '                 var tab_text = new Array();' . "\n";
        $return_string .= '                 if (result[0].recommendation.indexOf(",") != -1) { tab_text = result[0].recommendation.split(",") } else { tab_text.push(0, result[0].recommendation); }' . "\n";
        $return_string .=                   $this->name_space . '.tabbar.tabs(tab_id).setText(tab_text[1]);' . "\n";
        if ($this->define_apply_filters  && $this->show_apply_filter) {
            $return_string .= '             var filter_param = ' . $this->name_space . '.get_filter_parameters();' . "\n";
            $return_string .=               $this->name_space . '.refresh_grid("",' . $this->name_space . '.open_tab, filter_param);' . "\n";
        } else {
            $return_string .=               $this->name_space . '.refresh_grid("", ' . $this->name_space . '.open_tab);' . "\n";
        }
        $return_string .= '             } else {' . "\n";  
        if ($this->define_apply_filters  && $this->show_apply_filter) {
            $return_string .= '             var filter_param = ' . $this->name_space . '.get_filter_parameters();' . "\n";
            $return_string .=               $this->name_space . '.refresh_grid("",' . $this->name_space . '.refresh_tab_properties, filter_param);' . "\n";
        } else {
            $return_string .=                   $this->name_space . '.refresh_grid("", ' . $this->name_space . '.refresh_tab_properties);' . "\n";  
        }
        $return_string .= '             }' . "\n";
        $return_string .= '         }' . "\n";
        $return_string .=       $this->name_space.'.menu.setItemDisabled("delete");'. "\n";  
          if ($this->after_save_function != "") { 
               //custom after save function
               //custom operations after standard save function
                $return_string .=  $this->name_space . '.' . $this->after_save_function . '("");' . "\n";
        }
        $return_string .= '   }' . "\n";
        $return_string .= '};' . "\n";

        return $return_string;
    }

    

     /**
     * [clear_delete_xml clears wasChanged state for all cells in grid and clears delete_xml]
     */
    private function clear_delete_xml() {
        $return_string   = $this->name_space . '.clear_delete_xml = function() {' . "\n";
        $return_string  .= '    var tab_id = '. $this->name_space . '.tabbar.getActiveTab();'. "\n";
        $return_string  .= '    var win = ' . $this->name_space . '.tabbar.cells(tab_id);'. "\n";
        $return_string  .= '    var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;'. "\n";
        $return_string  .= '    object_id =  object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));' . "\n";
        $return_string  .= '    var tab_obj = win.tabbar[object_id];'. "\n";
        $return_string  .= '    var detail_tabs = tab_obj.getAllTabs();'. "\n";
        $return_string  .= '    $.each(detail_tabs, function(index,value) {'. "\n";
        $return_string  .= '     layout_obj = tab_obj.cells(value).getAttachedObject();'. "\n";
        $return_string  .= '     layout_obj.forEachItem(function(cell){'. "\n";
        $return_string  .= '         attached_obj = cell.getAttachedObject();'. "\n";
        $return_string  .= '         if (attached_obj instanceof dhtmlXGridObject) {'. "\n";
        $return_string  .= '             attached_obj.setUserData("","deleted_xml", "");'. "\n";
        $return_string  .= '              attached_obj.clearChangedState();'. "\n";
        $return_string  .= '              attached_obj.forEachRow(function(id){'. "\n";
        $return_string  .= '                     delete attached_obj.rowsAr[id]._added;'. "\n";
        $return_string  .= '                     attached_obj.setUserData(index,"row_status",null);'. "\n";
        $return_string  .= '                });'. "\n";
        $return_string  .= '             }'. "\n";
        $return_string  .= '         });'. "\n";
        $return_string  .= '    });'. "\n";
        $return_string  .= ' };'. "\n";
        
         return $return_string;
    }

    /**
     * [refresh_tab_properties Refresh tab property]
     */
    private function refresh_tab_properties() {
        $return_string  = $this->name_space . '.refresh_tab_properties = function() {' . "\n";
        $return_string .= ' var col_type = '. $this->name_space . '.grid.getColType(0);' . "\n";        

        $return_string .= ' var prev_id = ' . $this->name_space . '.tabbar.getActiveTab();' . "\n"; 
        $return_string .= ' var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;'. "\n";      
        $return_string .= ' if (col_type == "tree") {' . "\n";
        $return_string .=       $this->name_space . '.grid.loadOpenStates();' . "\n";
        $return_string .= '     var primary_value = '. $this->name_space . '.grid.findCell(system_id, 1, true, true);' . "\n";
        $return_string .= ' } else {' . "\n";
        $return_string .= '     var primary_value = '. $this->name_space . '.grid.findCell(system_id, 0, true, true);' . "\n";
        $return_string .= ' } ' . "\n";
        $return_string .= $this->name_space . '.grid.filterByAll(); ' . "\n";
        $return_string .= '  if (primary_value != "") {' . "\n";
        $return_string .= '     var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));' . "\n";
        $return_string .= '     var tab_text = ' . $this->name_space . '.get_text(' . $this->name_space . '.grid, r_id);' . "\n";
        $return_string .=       $this->name_space . '.tabbar.tabs(prev_id).setText(tab_text);' . "\n";
        $return_string .=       $this->name_space . '.grid.selectRowById(r_id,false,true,true);' . "\n";
        $return_string .= '  } ' . "\n";

        $return_string .= ' var win = ' . $this->name_space . '.tabbar.cells(prev_id);' . "\n";
        $return_string .= ' var tab_obj = win.tabbar[system_id];' . "\n";
        $return_string .= ' var detail_tabs = tab_obj.getAllTabs();' . "\n";
        $return_string .= ' var grid_xml = "<GridGroup>";' . "\n";
        $return_string .= ' var form_xml = "<FormXML ";' . "\n";
        $return_string .= ' $.each(detail_tabs, function(index,value) {' . "\n";
        $return_string .= '     layout_obj = tab_obj.cells(value).getAttachedObject();' . "\n";
        $return_string .= '     layout_obj.forEachItem(function(cell){' . "\n";
        $return_string .= '         attached_obj = cell.getAttachedObject();' . "\n";
        $return_string .= '         if (attached_obj instanceof dhtmlXGridObject) {' . "\n";
        $return_string .= '             attached_obj.clearSelection();' . "\n";
        $return_string .= '             var grid_obj = attached_obj.getUserData("","grid_obj");' . "\n";
        $return_string .= '             eval(grid_obj + ".refresh_grid()");' . "\n";
        $return_string .= '         }' . "\n";
        $return_string .= '     });' . "\n";
        $return_string .= ' });' . "\n";
        $return_string .= '}' . "\n";
        return $return_string;
    }

    /**
     * [open_tab Opens a tab after insert-save]
     */
    private function open_tab() {
        $return_string  = $this->name_space . '.open_tab = function() {' . "\n";
        $return_string .= '     var col_type = '. $this->name_space . '.grid.getColType(0);' . "\n";        

        if ($this->selected_id != '') {
            $return_string .= ' var system_id = "' . $this->selected_id . '";' . "\n";
            $return_string .= ' var prev_id = "";' . "\n";
        } else {
            $return_string .= ' var prev_id = ' . $this->name_space . '.tabbar.getActiveTab();' . "\n";
            $return_string .= ' var system_id = ' . $this->name_space . '.tabbar.tabs(prev_id).getText();' . "\n";
        }        
        $return_string .= '     var tab_index = (prev_id == "") ? null:'.$this->name_space . '.tabbar.tabs(prev_id).getIndex();' . "\n";
        $return_string .= '     system_id_array = new Array();' . "\n";
        $return_string .= '     system_id_array = system_id.split(",");' . "\n";
        $return_string .= '     for (var i = 0; i < system_id_array.length; i++) {' . "\n";
        $return_string .= '         if (col_type == "tree") {' . "\n";
        $return_string .=               $this->name_space . '.grid.loadOpenStates();' . "\n";
        $return_string .= '             var primary_value = '. $this->name_space . '.grid.findCell(system_id_array[i], 1, true, true);' . "\n";
        $return_string .= '         } else {' . "\n";
        $return_string .= '             var primary_value = '. $this->name_space . '.grid.findCell(system_id_array[i], 0, true, true);' . "\n";
        $return_string .= '         } ' . "\n";
        $return_string .=           $this->name_space . '.grid.filterByAll();' . "\n";
        $return_string .= '         if (primary_value != "") {' . "\n";
        $return_string .= '             if (' . $this->name_space . '.pages[prev_id]) {' . "\n";
        $return_string .= '                 delete ' . $this->name_space . '.pages[prev_id];' . "\n";
        $return_string .=                   $this->name_space . '.tabbar.cells(prev_id).close(false);'. "\n";
        $return_string .=                   $this->name_space . '.tabbar.tabs(prev_id).close(false);'. "\n";
        $return_string .= '             }' . "\n";  

        $return_string .= '             var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));' . "\n";
        $return_string .=               $this->name_space . '.grid.selectRowById(r_id,false,true,true);' . "\n";
        $return_string .=               $this->name_space . '.create_tab(r_id, 0, 0, 0,tab_index);' . "\n";
        $return_string .= '         } ' . "\n";
        $return_string .= '     } ' . "\n";
                                if ($this->after_save_function != "") { 
                                       //custom after save function
                                       //custom operations after standard save function
                                        $return_string .= $this->name_space . '.' . $this->after_save_function . '(system_id);' . "\n";
                                }
        
        
        
        $return_string .= '}' . "\n";
      
        return $return_string;
    }


    /**
     * [create_tab Create Tab function]
     */
    private function create_tab() {
        global $app_php_script_loc, $image_path;

        $return_string  = $this->name_space . '.create_tab = function(r_id, col_id, grid_obj, acc_id,tab_index) {'. "\n";
        $return_string .= '   if (r_id == -1 && col_id == 0) {'. "\n";
        $return_string .= '         full_id = ' .  $this->name_space . '.uid();'. "\n";
        $return_string .= '         full_id = full_id.toString();'. "\n";
        $return_string .= '         text = "New";'. "\n";
        $return_string .= '   } else { '. "\n";
        
        if($this->grid_type == 'a') {
            $return_string .= '     full_id = "tab_" + r_id;' . "\n";
            $return_string .= '     text = col_id;' . "\n";
        } else {
            $return_string .= '     full_id = ' . $this->name_space . '.get_id(' . $this->name_space . '.grid, r_id);' . "\n";
            $return_string .= '     text = ' . $this->name_space . '.get_text(' . $this->name_space . '.grid, r_id);' . "\n";
            $return_string .= '     if (full_id == "tab_"){ ' . "\n";
            $return_string .= '         var selected_row = '.$this->name_space.'.grid.getSelectedRowId();' . "\n";
            $return_string .= '         var state = '.$this->name_space.'.grid.getOpenState(selected_row);' . "\n";
            $return_string .= '         if (state)' . "\n";
            $return_string .= '             '.$this->name_space.'.grid.closeItem(selected_row);'. "\n";
            $return_string .= '          else '. "\n";
            $return_string .= '             '.$this->name_space.'.grid.openItem(selected_row);'. "\n";
            $return_string .= '         return false;' . "\n";
            $return_string .= '    }' . "\n";
        }

        $return_string .= '   }' . "\n";
        $return_string .= '   if (!' . $this->name_space . '.pages[full_id]) {' . "\n";
        $return_string .= '         var tab_context_menu = new dhtmlXMenuObject();' . "\n";
        $return_string .= '         tab_context_menu.setIconsPath("' . $image_path . 'dhxtoolbar_web/");' . "\n";
        $return_string .= '         tab_context_menu.renderAsContextMenu();' . "\n";
                                        
        $return_string .=           $this->name_space . '.tabbar.addTab(full_id,text, null, tab_index, true, true);' . "\n";
        $return_string .= '         //using window instead of tab' . "\n";
        $return_string .= '         var win = ' . $this->name_space . '.tabbar.cells(full_id);' . "\n";
        $return_string .=           $this->name_space . '.tabbar.t[full_id].tab.id = full_id;' . "\n";
        $return_string .= '         tab_context_menu.addContextZone(full_id);' . "\n";
        $return_string .= '         tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);' . "\n";        
        $return_string .= '         tab_context_menu.attachEvent("onContextMenu", function(zoneId){' . "\n";
        $return_string .=               $this->name_space . '.tabbar.tabs(zoneId).setActive();' . "\n";
        $return_string .= '         });' . "\n";
        
        $return_string .= '         tab_context_menu.attachEvent("onClick", function(id, zoneId){' . "\n";
        $return_string .= '             var ids = '. $this->name_space . '.tabbar.getAllTabs();' . "\n";
        $return_string .= '             switch(id) {' . "\n";
        $return_string .= '                 case "close_other":' . "\n";
        $return_string .= '                     ids.forEach(function(tab_id) {' . "\n";
        $return_string .= '                         if (tab_id != zoneId) {' . "\n";
        $return_string .= '                             delete ' . $this->name_space . '.pages[tab_id];' . "\n";
        $return_string .=                               $this->name_space . '.tabbar.tabs(tab_id).close();' . "\n";
        $return_string .= '                         }' . "\n";
        $return_string .= '                     })' . "\n";
        $return_string .= '                     break;' . "\n";
        $return_string .= '                 case "close_all":' . "\n";
        $return_string .= '                     ids.forEach(function(tab_id) {' . "\n";
        $return_string .= '                         delete ' . $this->name_space . '.pages[tab_id];' . "\n";
        $return_string .=                           $this->name_space . '.tabbar.tabs(tab_id).close();' . "\n";
        $return_string .= '                     })' . "\n";
        $return_string .= '                     break;' . "\n";
        $return_string .= '                 case "close":' . "\n";
        $return_string .= '                     ids.forEach(function(tab_id) {' . "\n";
        $return_string .= '                         if (tab_id == zoneId) {' . "\n";
        $return_string .= '                             delete ' . $this->name_space . '.pages[tab_id];' . "\n";
        $return_string .=                               $this->name_space . '.tabbar.tabs(tab_id).close();' . "\n";
        $return_string .= '                         }' . "\n";
        $return_string .= '                     })' . "\n";
        $return_string .= '                     break;' . "\n";
        $return_string .= '             }' . "\n";
        $return_string .= '         });' . "\n";
        
        
        if (!$this->report_status && !$this->hide_save) {
            $return_string .= '       var toolbar = win.attachToolbar();';
            $return_string .= '       toolbar.setIconsPath("' . $image_path . 'dhxtoolbar_web/");' . "\n";
            $return_string .= '       toolbar.attachEvent("onClick",' . $this->name_space . '.tab_toolbar_click);';
            $return_string .= '       toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]);' . "\n";
            
            if($this->edit_permission=='false')
                $return_string .=     'toolbar.disableItem("save");' . "\n";            
        }
        
 
        $return_string .=         $this->name_space . '.tabbar.cells(full_id).setText(text);' . "\n";
        $return_string .=         $this->name_space . '.tabbar.cells(full_id).setActive();' . "\n";
        $return_string .=         $this->name_space . '.tabbar.cells(full_id).setUserData("row_id", r_id);' . "\n";

                
        $return_string .= '           win.progressOn();' . "\n";

        if ($this->form_load_function != "") {
            // custom functions to load form
            $return_string .=         $this->name_space . '.' . $this->form_load_function . '(win,full_id,grid_obj,acc_id);'. "\n";
        } else {
            //generic function to load form as defined in database
            $return_string .= $this->name_space . '.set_tab_data(win,full_id);' . "\n";
            
        }
        $return_string .=       $this->name_space . '.pages[full_id] = win;' . "\n";

        $return_string .= '  }' . "\n";
        $return_string .= '   else {' . "\n";
        $return_string .=       $this->name_space . '.tabbar.cells(full_id).setActive();' . "\n";
        $return_string .= '   };' . "\n";
        $return_string .= '};' . "\n";        
        return $return_string;
    }

    /**
     * [set_form_data Set form data]
     */
    function set_form_data() {
        global $app_php_script_loc;
        $return_string = $this->name_space . '.set_tab_data = function(win,id) {' . "\n";
        $return_string .= 'id = id.toString();' . "\n";
        $return_string .= 'var object_id = (id.indexOf("tab_") != -1) ? id.replace("tab_", "") : id;' . "\n";
        $return_string .= 'var selected_row = '.$this->name_space.'.grid.getSelectedRowId();' . "\n";
        $return_string .= 'var privilege_active = false; var type_id = ""' . "\n";
        if ($this->add_privilege_menu) {
            $return_string .= 'if(selected_row != null) {' . "\n";
            $return_string .= '     privilege_active = ' . $this->name_space . '.grid.cells(selected_row, ' . $this->name_space . '.grid.getColIndexById("is_privilege_active")).getValue();' . "\n";
            $return_string .= '     type_id = ' . $this->name_space . '.grid.cells(selected_row, ' . $this->name_space . '.grid.getColIndexById("type_id")).getValue();' . "\n";
            $return_string .= '}' . "\n";
        }
        $return_string .= 'var url = "' . $app_php_script_loc . 'generic_template.php";' . "\n";
        $return_string .= 'var additional_data = {' . "\n";
        $return_string .= '     "function_id":"' . $this->function_id . '",' . "\n";
        $return_string .= '     "template_name": "' . $this->template_name . '",' . "\n";
        $return_string .= '     "primary_field": "' . $this->primary_field . '",' . "\n";
        $return_string .= '     "object_id": object_id,' . "\n";
        $return_string .= '     "parent_object": "win"' . "\n";

        if ($this->grid_menu_json) {
            $return_string .= '     ,"menu_json_array": ' . $this->grid_menu_json . "\n";
        }

        if ($this->hide_originals) {
            $return_string .= '     ,"hide_originals":"true"' .  "\n";
        }
        
        if ($this->pivot_menu) {
            $return_string .= '     ,"enable_pivot":"true"' .  "\n";
        }
        
        if ($this->add_privilege_menu) {
            $return_string .= '     ,"type_id": type_id' . "\n";
            $return_string .= '     ,"privilege_active": privilege_active' . "\n";
        }
        
        $return_string .= '};' . "\n";
        $return_string .= 'data = $.param(additional_data);' . "\n";

        $return_string .= '$.ajax({' . "\n";
        $return_string .= '     type: "POST",' . "\n";
        $return_string .= '     dataType: "text",' . "\n";
        $return_string .= '     url: url,' . "\n";
        $return_string .= '     data: data,' . "\n";
        $return_string .= '     success:function(data) {' . "\n";
        $return_string .= '         var script = $(data).filter(function(){ return $(this).is("script") });' . "\n";
        $return_string .= '         script.each(function() {' . "\n";
        $return_string .= '             if ($(this).hasClass("form_script")) {' . "\n";
        $return_string .= '                 win.progressOff();' . "\n";
        $return_string .= '                 eval($(this).text());' . "\n";
        $return_string .= '             }' . "\n";
        $return_string .= '         });' . "\n";
        if($this->form_load_complete_function != ""){
        $return_string .=         $this->name_space . '.' . $this->form_load_complete_function . '(win,id);'. "\n";
        }
        $return_string .= '     },' . "\n";
        $return_string .= '     error:function(data) {' . "\n";
        $return_string .= '         win.progressOff();' . "\n";
        $return_string .= '     }' . "\n";
        $return_string .= '});' . "\n";
        $return_string .= '}' . "\n";

        return $return_string;
    }

    /**
     * [create_id Create New Id for tab]
     */
    private function create_id() {
        $return_string = $this->name_space . '.uid = function() {' . "\n";
        $return_string .= '    return (new Date()).valueOf();' . "\n";
        $return_string .= '}' . "\n";

        return $return_string;
    }

    /**
     * [get_id Get Id for tab]
     */
    private function get_id() {
        $return_string .= $this->name_space . '.get_id = function(grid,r_id) {' . "\n";
        $return_string .= '     var col_type = grid.getColType(0);' . "\n";
        $return_string .= '     if (col_type == "tree") {' . "\n";
        $return_string .= '         var id = "tab_" + grid.cells(r_id,1).getValue();' . "\n";
        $return_string .= '     } else {' . "\n";
        $return_string .= '         var id = "tab_" + grid.cells(r_id,0).getValue();' . "\n";
        $return_string .= '     }' . "\n";
        $return_string .= '     return id;' . "\n";
        $return_string .= '}' . "\n";
        return $return_string;
    }

    /**
     * [get_text Get Text for tab]
     */
    private function get_text() {
        $return_string .= $this->name_space . '.get_text = function(grid,r_id) {' . "\n";
        $return_string .= '     var col_type = grid.getColType(0);' . "\n";
        $return_string .= '     if (col_type == "tree") {' . "\n";
        $return_string .= '         var name = grid.cells(r_id,0).getValue();' . "\n" . "\n";
        $return_string .= '     } else {' . "\n";
        $return_string .= '         var name = grid.cells(r_id,1).getValue();' . "\n" . "\n";
        $return_string .= '     }' . "\n";
        $return_string .= '     return name;' . "\n";
        $return_string .= '}' . "\n";

        return $return_string;
    }

    /**
     * [set_grid_menu_json Set json and onclick function for grid menu buttons]
     * @param [type] $json_array [Array consisting of json and onclick functions for menu button]
     * Array Format : Array (
     *                     [0] => Array
     *                             (
     *                                 [json] => JSON items for first grid
     *                                 [on_click] => Onclick function for first grid
     *                     [1]....               
     * )
     * @par Description
     * Whenever this function is used, developer should be aware of number of grid and provide arrray in given format for all grid. 
     * For example if there are three grid and custom button is only needed in one grid, we need to provide array for all three grid, 
     * two of these array should have blank values in json and on_click. Onclick function defined for additional buttons should expect three 
     * parameters button_id, grid_object, selected_row_id
     * <pre>
     * {@code 
     * $menu_json_array = array(
     *                          array(
     *                                  'json' => '',
     *                                   'on_click' => ''
     *                                ),
     *                          array(
     *                                   'json' => '{id: "Word3", img: "Word3.gif", text: "Word3", title: "Word3"},
     *                                                   {type: "separator" },
     *                                                   {id: "Word4", img: "Word4.gif", text: "Word4", title: "Word4"}',
     *                                    'on_click' => 'meter_data.second_grid_menu_click'
     *                                ),
     *                           array(
     *                                    'json' => '',
     *                                    'on_click' => ''
     *                                 )
     *                        );
     *  }
     * meter_data.second_grid_menu_click = function(btn_id, grid_obj, selected_ids) {
     *   alert(btn_id);
     *   val = grid_obj.cells(selected_ids,0).getValue(); for multiselect, selected_ids is comma seperated, should use loop to get any value. 0 is cell_index here.
     *   alert(val);
     *   alert(selected_ids);
     * }
     *  </pre>
     */
    public function set_grid_menu_json($json_array, $hide_originals) {
        $this->grid_menu_json = json_encode($json_array);
        $this->hide_originals = $hide_originals;
    }

    
     /**
     * [define_layout_widht Define width for layout cells]
     * @param  [int] $left_width  [Cell a width]
     */
    public function hide_edit_menu() {
        $this->hide_edit_menu = true;
    }
    
    /**
     * [undock_cell Dock/Undock of left cell]
     */
    private function undock_cell() {
        $return_string =  $this->name_space .'.undock_cell_a_standard_form = function(cell) {' . "\n";
        $return_string .=       $this->name_space . '.layout.cells(cell).undock(300, 300, 900, 700);' . "\n";
        $return_string .=       $this->name_space . '.layout.dhxWins.window(cell).button("park").hide();' . "\n";
        $return_string .=       $this->name_space . '.layout.dhxWins.window(cell).maximize();' . "\n";
        $return_string .=       $this->name_space . '.layout.dhxWins.window(cell).centerOnScreen();' . "\n";
        $return_string .= '}' . "\n";

        $return_string .=  $this->name_space .'.on_dock_event = function(name) {' . "\n";
        $return_string .= '     $(".undock_cell_a").show();' . "\n";
        $return_string .= '}' . "\n";

        $return_string .=  $this->name_space .'.on_undock_event = function(name) {' . "\n";
        $return_string .= '     $(".undock_cell_a").hide();' . "\n";
        $return_string .= '}' . "\n";

        return $return_string;
    }

    /**
     * [enable_menu_item Enable delete/edit menu item based on Users Privilege.]
     */  
    private function enable_menu_item() {
         $return_string  =  $this->name_space . '.enable_menu_item = function(id,ind) {' . "\n";
         $return_string .= '     var selected_rows = ' . $this->name_space . '.grid.getSelectedRowId();' . "\n";
         if (!$this->hide_edit_menu) {
             $return_string .= '     if("' . $this->delete_permission . '" == "true" && id != null && selected_rows.indexOf(",") == -1){' . "\n";  
             $return_string .=              $this->name_space . '.menu.setItemEnabled("delete");'. "\n";    
             $return_string .= '     } else {'. "\n";
             $return_string .=              $this->name_space . '.menu.setItemDisabled("delete");'. "\n";
             $return_string .= '     } ' . "\n";
         }
         if ($this->add_privilege_menu) {
             $return_string .= ' if(id != null) {' . "\n";
             $return_string .= '    var c_row = "null";' . "\n";
             $return_string .= '    var col_type = ' . $this->name_space . '.grid.getColType(0);' . "\n";
             $return_string .= '    if(col_type == "tree") {' . "\n";
             $return_string .= '        var c_row = ' . $this->name_space . '.grid.getChildItemIdByIndex(id, 0);' . "\n";
             $return_string .= '    }' ."\n";
             $return_string .= '    if(col_type == "tree" && c_row != null) {' . "\n";
             $return_string .= '        var is_active = -1;' . "\n";
             $return_string .= '    } else { ' ."\n";
             $return_string .= '        var is_active = ' . $this->name_space . '.grid.cells(id, ' . $this->name_space . '.grid.getColIndexById("is_privilege_active")).getValue();' . "\n";
             $return_string .= '    }' ."\n";
             $return_string .= ' } else {' . "\n";
             $return_string .= '    var is_active = -1'. "\n";
             $return_string .= ' }' . "\n";
             
             $return_string .= ' if (is_active == 0) {
                        			if (' . $this->privilege_rights . '){
                        				' . $this->name_space . '.menu.setItemEnabled("activate");
                        				' . $this->name_space . '.menu.setItemDisabled("deactivate");
                        				' . $this->name_space . '.menu.setItemDisabled("privilege");
                        			}
                        		 } else if (is_active == 1){
                        			if (' . $this->privilege_rights . '){
                        				' . $this->name_space . '.menu.setItemDisabled("activate");
                        				' . $this->name_space . '.menu.setItemEnabled("deactivate");
                        				' . $this->name_space . '.menu.setItemEnabled("privilege");
                        			}
                        		} else {
                        		    ' . $this->name_space . '.menu.setItemDisabled("activate");
                        			' . $this->name_space . '.menu.setItemDisabled("deactivate");
                        			' . $this->name_space . '.menu.setItemDisabled("privilege");
                        		} ' . "\n";
         }
         
         $return_string .= '  }'. "\n";    
         
         return $return_string; 
    }
	
	/**
     * [enable the multiple select in the left side grid]
     */ 
	public function enable_multiple_select() {
		$this->multiple_select = true;
	}
    
    /**
     * [enable the multiple select in the left side grid]
     */ 
	public function enable_grid_pivot() {
		$this->pivot_menu = true;
	}

}

?>