<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $form_name = 'form_formula_existing';
    
    $rights_existing_formulas = 10211018;   // 419 

    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Formula Filter",
                            header:         true,
                            width:          720,
                            height:         105,
                            collapse:       true,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "Formula",
                            width:          720,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'formula_existing';
    //Creating Layout
    $formula_builder_layout = new AdihaLayout();
    echo $formula_builder_layout->init_layout('formula_builder_layout', '', '2E', $layout_json, $name_space);
	
	$toolbar_json = '[
                            {id:"ok", type:"button", img:"tick.png", text:"Ok", title:"Ok"}
                        ]';
						
	$toolbar_name = 'formula_existing_toolbar';
    echo $formula_builder_layout->attach_toolbar_cell($toolbar_name, 'b');
    $formula_existing_toolbar_obj = new AdihaToolbar();
    echo $formula_existing_toolbar_obj->init_by_attach($toolbar_name, $name_space);
    echo $formula_existing_toolbar_obj->load_toolbar($toolbar_json);
	echo $formula_existing_toolbar_obj->attach_event('', 'onClick', 'btn_ok_click');
	
    $grid_name='grd_formula_builder';
    echo $formula_builder_layout->attach_grid_cell($grid_name, 'b');
    $grid_formula_obj = new GridTable('formula_editor');
    echo $grid_formula_obj->init_grid_table($grid_name, $name_space);
	echo $grid_formula_obj->set_widths('100,152,300,150,150');
    echo $grid_formula_obj->set_search_filter(true); 
    echo $grid_formula_obj->return_init();
    echo $grid_formula_obj->load_grid_data("EXEC spa_formula_editor @flag='s',@formula_type='t'", '');
    echo $grid_formula_obj->attach_event('', 'onRowDblClicked', 'btn_ok_click');
    
    //echo $grid_formula_obj->attach_event('', 'onXLE', 'grd_formula_builder_onload');
    echo $grid_formula_obj->load_grid_functions();
    
    //Attaching Formula form 
    echo 'attach_formula_form();';
    
    //Closing Layout
    echo $formula_builder_layout->close_layout();
    
    ?>
    
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            overflow: hidden;
        }
    </style>
    
    <script type="text/javascript"> 
	
		$(function(){
			formula_existing.grd_formula_builder.setColumnHidden(0,true);
		})
        /**
        * Build the formula filter form and attach to the layout
        */ 
        function attach_formula_form() {
            form_data = [
                            {type: "settings", position: "label-right", labelWidth: 215},
                            {"type":"fieldset","label":"Formula Type", offsetLeft: ui_settings['offset_left'], width:435, "list":[
                                {type: "radio", name: "rdo_copy_reference", value: "c", label: "Copy Formula", position: "label-right"},
                                {type: "newcolumn"},
                                {type: "radio", name: "rdo_copy_reference", value: "r", label: "Reference", checked: true, position: "label-right"}
                            ]}
                        ];

            formula_existing.formula_form = formula_existing.formula_builder_layout.cells("a").attachForm(form_data);
        }
        
        /**
        * Grid onload function - Replace comma and enable/disable toolbar button onload.
        * 
        function grd_formula_builder_onload() {
            formula_existing.grid_grd_formula_builder.forEachRow(function(id){
                var test = formula_existing.grid_grd_formula_builder.cellById(id,2).getValue();
                test1 = test.replace(/&amp;comma;/g, ',');
                formula_existing.grid_grd_formula_builder.cellById(id,2).setValue(test1);
            });   
        }
        */

        function btn_ok_click() { 
            var formula_id = formula_existing.get_grid_cell_value(0);
            var formula_name = formula_existing.get_grid_cell_value(1);
            var formula_string = formula_existing.get_grid_cell_value(3);
            var copy_reference = formula_existing.formula_form.getItemValue('rdo_copy_reference');

            var return_value = new Array();
            
            return_value[0] = formula_id;
            return_value[1] = 'btnOk';
            return_value[2] = formula_name;
            return_value[3] = formula_string;
            return_value[4] = copy_reference;
            
            parent.open_formula_window_callback(return_value);
            parent.browse_window.window('w1').close();
        }
    </script>