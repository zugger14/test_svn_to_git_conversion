<?php
/**
* Formula builder screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body class = "bfix">
    <?php
        $rights_formula_builder = 10102400;
        $rights_formula_builder_ui = 10211017;
        $rights_formula_builder_delete = 10102410; 

        list (
            $has_rights_formula_builder,
            $has_rights_formula_builder_ui,
            $has_rights_formula_builder_delete
        )  = build_security_rights(
            $rights_formula_builder,
            $rights_formula_builder_ui,
            $rights_formula_builder_delete
        );
        
        $php_script_loc = $app_php_script_loc;
		
		$formula_id = get_sanitized_value($_GET['formula_id'] ?? 'NULL'); 
		
		if ($formula_id != 'NULL') {
			$has_rights_formula_builder_ui = false;
			$has_rights_formula_builder_delete = false;
		}
        
        //JSON for Layout
        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Formula",
                                width:          720,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            }
                        ]';

        $formula_toolbar_json = '[
                                    {id:"t1", text:"Edit", img:"edit.gif", items:[
                                        {id:"insert", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: "' . $has_rights_formula_builder_ui . '"},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled: true}
                                    ]},
                                    {id:"t2", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}
                             ]';

        $name_space = 'formula_builder';

        //Creating Layout
        $formula_builder_layout = new AdihaLayout();
        echo $formula_builder_layout->init_layout('formula_builder_layout', '', '1C', $layout_json, $name_space);

        $toolbar_formula_obj = new AdihaMenu();
        echo $formula_builder_layout->attach_menu_cell("formula_toolbar", "a"); 
        echo $toolbar_formula_obj->init_by_attach("formula_toolbar", $name_space);
        echo $toolbar_formula_obj->load_menu($formula_toolbar_json);
        echo $toolbar_formula_obj->attach_event('', 'onClick', $name_space . '.formula_toolbar_click');

        $grid_name='grd_formula_builder';
        echo $formula_builder_layout->attach_grid_cell($grid_name, 'a');
        echo $formula_builder_layout->attach_status_bar('a', true, '');
        $grid_formula_obj = new GridTable('formula_editor');
        echo $grid_formula_obj->init_grid_table($grid_name, $name_space);
        echo $grid_formula_obj->set_widths('150,250,*,150,150');
        echo $grid_formula_obj->set_search_filter(true);
        echo $grid_formula_obj->enable_paging('25', 'pagingArea_a', true);
        echo $grid_formula_obj->enable_multi_select(true);
        echo $grid_formula_obj->return_init();
        if ($formula_id == 'NULL') echo $grid_formula_obj->load_grid_data();        
		echo $grid_formula_obj->attach_event('', 'onRowSelect', $name_space . '.grd_formula_builder_onclick');
        echo $grid_formula_obj->attach_event('', 'onRowDblClicked', $name_space . '.grd_formula_builder_ondbclick');
        echo $grid_formula_obj->load_grid_functions();

        //Closing Layout
        echo $formula_builder_layout->close_layout();
    ?>
</body> 
    
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
    
    <script type="text/javascript">
        var php_script_loc = '<?php echo $php_script_loc; ?>';
        var rights_formula_builder_delete = <?php echo (($has_rights_formula_builder_delete) ? $has_rights_formula_builder_delete : '0'); ?>;
        
        dhxWins = new dhtmlXWindows();
		formula_id = '<?php echo $formula_id; ?>';

        
        /**
        * Function to refresh the formula grid
        */
        function refresh_formula_grid() {
            var formula_type = 't' //the grid will always show template formula only
            
            data = {"action": "spa_formula_editor",
                        "flag": "s",
                        "formula_type": formula_type,
						"formula_id": formula_id
                    };
            
            formula_builder.refresh_grid(data);
        }
		
		$(function() { refresh_formula_grid()});
        
        formula_builder.grd_formula_builder_ondbclick = function(r_id, col_id) {
            var mode = 'u';
            var formula_id = formula_builder.grd_formula_builder.cells(r_id, 0).getValue();
            var formula_name = formula_builder.grd_formula_builder.cells(r_id, 1).getValue();
            build_formula_editor_window(formula_id, formula_name);
        }
        
        /**
        * Function to enable the update and delete button when row is selected else disable
        */ 
        formula_builder.grd_formula_builder_onclick = function() {
            var selected = formula_builder.get_grid_selected_row();
           
            if (selected == null) {
                formula_builder.formula_toolbar.setItemDisabled('delete');
            } else {
                if (rights_formula_builder_delete) {
                    formula_builder.formula_toolbar.setItemEnabled('delete');
                }
            }
        }
        
        /**
        * Function called when the button of the toolbar is clicked
        */ 
        formula_builder.formula_toolbar_click = function(id) {
            if (id == 'insert') {
                var mode = 'i';
                build_formula_editor_window(-1, 'New');
            } else if (id == 'delete') {
                var is_win = dhxWins.isWindow('w1');
            
                if (is_win == true) {
                    //alert(w1.formula_form.getItemValue('formula_id'));
                }   
                
                btn_delete_click();
            } else if (id == 'excel') {
                formula_builder.grd_formula_builder.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (id == 'pdf') {
                formula_builder.grd_formula_builder.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            }
         }
        
        /**
        * Function to create Formula Editor Window
        * @param [mode] - i for insert mode and u for update mode.
        */  
        function build_formula_editor_window(formula_id, formula_name) {
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            
            param = js_path_trm +  'adiha.html.forms/_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=formula_builder'; 
            
            var is_win = dhxWins.isWindow('w1');
            
            if (is_win == true) {
                w1.close();
            }    
            
            w1 = dhxWins.createWindow("w1", 10, 10, 700, 500);
            w1.setText(get_locale_value("Formula Editor") + " - " + get_locale_value(formula_name));
            w1.maximize();
            w1.attachURL(param, false, true);
            
            dhxWins.attachEvent("onParkUp", function(win){
				dhxWins.window('w1').button('park').hide();
			});
            
            dhxWins.attachEvent("onMaximize", function(win){
                dhxWins.window('w1').button('park').show();
			});
            
            dhxWins.attachEvent("onMinimize", function(win){
                dhxWins.window('w1').button('park').show();
			});
        }
        
        /**
        * Callback function called after the formula is saved in formula editor. Function called from formula editor window.
        */ 
        function formula_editor_callback(return_value) {
            refresh_formula_grid();
            dhtmlx.message({
                text:'Changes have been saved successfully.',
                expire:1000
            });
        }
        
        /**
        * Delete the selected formula
        */
        function btn_delete_click() {
            var formula_id = formula_builder.get_grid_cell_value(0);
            
            data = {"action": "spa_formula_editor",
                        "flag": "d",
                        "del_formula_ids": formula_id
                    };
            var confirm_msg = 'Are you sure you want to delete?';
                
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: confirm_msg,
                callback: function(result) {
                    if (result)
                        adiha_post_data('alert', data, '', '', 'delete_success_callback', '');
                }
            });
        }

        /**
        * Callback function after deleting formula to refresh the grid.
        */
        function delete_success_callback(result) {
            refresh_formula_grid();
        }
       
        
    </script>
