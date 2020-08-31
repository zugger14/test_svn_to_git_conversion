<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
<body>
<?php
	$name_space = 'ns_assignment_percent';
    $form_name = 'form_assignment_percent';
    $generator_id = get_sanitized_value($_GET['generator_id'] ?? $generator_id);

    $rights_assignment_form = 12101720;
    $rights_assignment_form_iu = 12101721;
    $rights_assignment_form_del = 12101722;

    list(
        $has_rights_assignment_form,
        $has_rights_assignment_form_iu,
        $has_rights_assignment_form_del
    ) = build_security_rights(
        $rights_assignment_form,
        $rights_assignment_form_iu,
        $rights_assignment_form_del
    );

    $has_rights_assignment_form_iu = ($has_rights_assignment_form_iu != '') ? "true" : "false";
    $has_rights_assignment_form_del =  ($has_rights_assignment_form_del != '') ? "true" : "false";

    $layout_json = '[   
                        {id: "a", text: "", header: "false"},
                        
                    ]';
    $assignment_percent_layout = new AdihaLayout();


    echo $assignment_percent_layout->init_layout('assignment_percent_layout', '', '1C', $layout_json, $name_space);

	$menu_name = 'assignment_percent_menu';
    $menu_json = "[
    		{id:'t', text:'Edit', img:'edit.gif', imgdis:'edit_dis.gif', items:[
            	{id:'add', text:'Add', img:'add.gif', imgdis: 'add_dis.gif', enabled:'$has_rights_assignment_form_iu'},
                {id:'delete', text:'Delete', img:'delete.gif', imgdis:'trash_dis.gif', enabled:'false'}
            ]},
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]}
        ]";

    $assignment_percent_toolbar = new AdihaMenu();
    echo $assignment_percent_layout->attach_menu_cell($menu_name, "a"); 
    echo $assignment_percent_toolbar->init_by_attach($menu_name, $name_space);
    echo $assignment_percent_toolbar->load_menu($menu_json);
    echo $assignment_percent_toolbar->attach_event('', 'onClick', 'assignment_percent_menu_click');
    
    //grid definition
    $grid_name = 'grd_deal_settlement';
    echo $assignment_percent_layout->attach_grid_cell($grid_name, 'a');
    $assignment_percent_grid = new AdihaGrid();
    echo $assignment_percent_layout->attach_status_bar("a", true);
    echo $assignment_percent_grid->init_by_attach($grid_name, $name_space);
    echo $assignment_percent_grid->set_header("ID,Generator ID,Allocation,Offset,Term Start,Term End,Assignment Type,Assignment Percent, Max Volume Assign,UOM,Counterparty Name,Trader Name,Sold Price,Contract,Use Market Price,Exclude From Inventory,Use Deal Price");
    echo $assignment_percent_grid->set_columns_ids("generator_assignment_id,generator_id,allocation,offset,term_start,term_end,assignment_type,assignment_percent,max_volume,uom_name,counterparty_name,trader_name,sold_price,contract_name,use_market_price,exclude_inventory,use_deal_price");
    echo $assignment_percent_grid->set_widths("200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200");
    echo $assignment_percent_grid->set_column_types("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
    echo $assignment_percent_grid->set_column_visibility("false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false");
    echo $assignment_percent_grid->enable_column_move('true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true');
    echo $assignment_percent_grid->set_sorting_preference('str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str');
    echo $assignment_percent_grid->load_grid_data("EXEC spa_rec_generator_assignment @flag = 's', @generator_id = '$generator_id'");
    echo $assignment_percent_grid->attach_event('', 'onRowDblClicked', 'update_assignment_percent');
    echo $assignment_percent_grid->attach_event('', 'onRowSelect', 'grd_assignment_click');
    echo $assignment_percent_grid->set_search_filter(true);
    echo $assignment_percent_grid->split_grid(2);
    echo $assignment_percent_grid->return_init();
    echo $assignment_percent_grid->enable_header_menu();

    echo $assignment_percent_layout->close_layout();
?>
<script type="text/javascript">
	var generator_id = '<?php echo $generator_id; ?>';
    var has_rights_assignment_form = '<?php echo $has_rights_assignment_form; ?>';
    var has_rights_assignment_form_iu = '<?php echo $has_rights_assignment_form_iu; ?>';
    var has_rights_assignment_form_del = '<?php echo $has_rights_assignment_form_del; ?>';

	function grd_assignment_click() {
        if (has_rights_assignment_form_del)
		  ns_assignment_percent.assignment_percent_menu.setItemEnabled('delete');
	}

	function assignment_percent_menu_click(args) {
		switch(args) {
			case 'add':
				assignment_percent_iu_window = new dhtmlXWindows();
	            var src = 'assignment.percent.details.php?generator_id=' + generator_id;// + '&generator_assignment_id=' + generator_assignment_id;

                new_assignment_percent_iu = assignment_percent_iu_window.createWindow('w1', 0, 0, 900, 500);
                new_assignment_percent_iu.setText("Assignment Form Detail");
                new_assignment_percent_iu.centerOnScreen();
                new_assignment_percent_iu.setModal(true);
                new_assignment_percent_iu.attachURL(src, false);
			break;
			case 'delete':
				var row_id =  ns_assignment_percent.grd_deal_settlement.getSelectedRowId();
        		var generator_assignment_id =  ns_assignment_percent.grd_deal_settlement.cells(row_id, 0).getValue();

        		data = {
	                'action': 'spa_rec_generator_assignment',
	                'flag': 'd',
	                'generator_assignment_id': generator_assignment_id
	            }

	            adiha_post_data('confirm', data, '', '', 'refresh_grid');
			break;
			case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                ns_assignment_percent.grd_deal_settlement.toExcel(path);
                
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                ns_assignment_percent.grd_deal_settlement.toPDF(path);
                
                break;
		}
	}

	function update_assignment_percent() {
		assignment_percent_iu_window = new dhtmlXWindows();
		var row_id =  ns_assignment_percent.grd_deal_settlement.getSelectedRowId();
        var generator_assignment_id =  ns_assignment_percent.grd_deal_settlement.cells(row_id, 0).getValue();

        var src = 'assignment.percent.details.php?generator_id=' + generator_id + '&generator_assignment_id=' + generator_assignment_id;

        new_assignment_percent_iu = assignment_percent_iu_window.createWindow('w1', 0, 0, 900, 500);
        new_assignment_percent_iu.setText("Assignment Form Detail");
        new_assignment_percent_iu.centerOnScreen();
        new_assignment_percent_iu.setModal(true);
        new_assignment_percent_iu.attachURL(src, false);
	}

	function refresh_grid() {
       var sp_url_param = {                    
                    "flag": 's',
                    "generator_id": generator_id,
                    "action": "spa_rec_generator_assignment"
        };
    
        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        ns_assignment_percent.grd_deal_settlement.clearAll();
        ns_assignment_percent.grd_deal_settlement.loadXML(sp_url);
    }
</script>
</body>
</html>