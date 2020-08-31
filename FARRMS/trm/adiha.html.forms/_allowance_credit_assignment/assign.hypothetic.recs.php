<?php
/**
* Assign hypothetical RECs screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
<body>
<?php
    require('../../adiha.php.scripts/components/include.file.v3.php'); 

    $form_name = 'form_finalize_committed_recs';
    $name_space = 'finalize_committed_recs';
    
    $rights_finalize_committed_recs = 12121600;
    
    list(
        $has_rights_finalize_committed_recs
    ) = build_security_rights(
        $rights_finalize_committed_recs
    );

    $layout_json = '[
                        {id: "a", text: "Compliance Group", width: 300, header: "true"},
                        {id: "b", text: "Filters", header: "true", height: 200},  
                        {id: "c", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Deals"}
                    ]';

    $finalize_committed_recs_layout = new AdihaLayout();
    echo $finalize_committed_recs_layout->init_layout('finalize_committed_recs_layout', '', '3L', $layout_json, $name_space);

    $grid_name = 'grd_finalize_committed_recs';
    echo $finalize_committed_recs_layout->attach_grid_cell($grid_name, 'a');
    $grid_finalize_committed_recs = new AdihaGrid();
    echo $finalize_committed_recs_layout->attach_status_bar("a", true);
    echo $grid_finalize_committed_recs->init_by_attach($grid_name, $name_space);
    echo $grid_finalize_committed_recs->set_header("Compliance Group ID,Logical Name,Assignment Type,Assigned State,Compliance Year,Commit Type,Assignment Type,Assigned State,Compliance Year,Commit Type");
    echo $grid_finalize_committed_recs->set_columns_ids("compliance_group_id,logical_name,assignment_type_name,assigned_state_name,compliance_year_name,commit_type_name,assignment_type,assigned_state,compliance_year,commit_type");
    echo $grid_finalize_committed_recs->set_widths("150,150,150,150,150,150,150,150,150,150");
    echo $grid_finalize_committed_recs->set_column_types("ro_int,ro,ro,ro,ro_int,ro,ro_int,ro_int,ro_int,ro");
    echo $grid_finalize_committed_recs->set_column_visibility("true,false,false,false,false,false,true,true,true,true");
    echo $grid_finalize_committed_recs->set_sorting_preference('int,str,str,str,int,str,int,int,int,str');
     echo $grid_finalize_committed_recs->split_grid(2);
    echo $grid_finalize_committed_recs->load_grid_data("EXEC spa_compliance_group @flag = 'x'");    
    echo $grid_finalize_committed_recs->attach_event('', 'onRowSelect', 'grd_finalize_committed_recs_click');
    echo $grid_finalize_committed_recs->set_search_filter(true);
    echo $grid_finalize_committed_recs->enable_column_move('true,true,true,true,true,true,true,true,true,true');
    echo $grid_finalize_committed_recs->return_init();
    echo $grid_finalize_committed_recs->enable_header_menu();

    $filter_form_obj = new AdihaForm();
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='12121600', @template_name='FinalizeCommittedRECs'";
    $filter_arr = readXMLURL($filter_sql);    
    $form_json = $filter_arr[0][2];
    echo $finalize_committed_recs_layout->attach_form('filter_form', 'b');    
    $filter_form_obj->init_by_attach('filter_form', $name_space);
    echo $filter_form_obj->load_form($form_json);

    $menu_name = 'finalize_committed_recs_menu';
    $menu_json = "[
    		{id:'save', text:'Save', img:'save.gif', imgdis:'save_dis.gif', enabled: 'false'},
            {id:'refresh', text:'Refresh', img:'refresh.gif', imgdis:'refresh_dis.gif'},
            {id:'t', text:'Process', img:'action.gif', items:[
                {id:'finalize', text:'Finalize', img:'Approve.gif', imgdis: 'Approve_dis.gif'},
                //{id:'run_target_report', text:'Run Target Position Report', img:'report.gif', imgdis:'test_dis.gif', enabled:'true'},
                //{id:'post', text:'Post', img:'Approve.gif', imgdis:'Approve_dis.gif'}
            ]},
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]}
        ]";

    $finalize_committed_recs_obj = new AdihaMenu();
	echo $finalize_committed_recs_layout->attach_menu_cell($menu_name, "c"); 
	echo $finalize_committed_recs_obj->init_by_attach($menu_name, $name_space);
    echo $finalize_committed_recs_obj->load_menu($menu_json);
    echo $finalize_committed_recs_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

    echo $finalize_committed_recs_layout->close_layout();             
?>
</body>
<script type="text/javascript">
	var theme_selected = 'dhtmlx_' + default_theme;
	
	$(function() {
        var function_id  = 12121600;

        attach_browse_event('finalize_committed_recs.filter_form', function_id);        
    });

	function refresh_export_toolbar_click(args) {
		if (args == 'refresh') {
			var row_id = finalize_committed_recs.grd_finalize_committed_recs.getSelectedRowId();

			var assignment_type = (row_id != null) ? finalize_committed_recs.grd_finalize_committed_recs.cells(row_id, 6).getValue() : 'NULL';
	        var assign_state = (row_id != null) ? finalize_committed_recs.grd_finalize_committed_recs.cells(row_id, 7).getValue() : 'NULL';
	        var compliance_year = (row_id != null) ? finalize_committed_recs.grd_finalize_committed_recs.cells(row_id, 4).getValue() : 'NULL';
	        var aggregate_detail = (row_id != null) ? finalize_committed_recs.grd_finalize_committed_recs.cells(row_id, 9).getValue() : 'NULL';
	        var compliance_group_id = (row_id != null) ? finalize_committed_recs.grd_finalize_committed_recs.cells(row_id, 0).getValue() : 'NULL';

	        finalize_committed_recs.finalize_committed_recs_layout.cells('c').attachStatusBar({height: 30, text: '<div id="pagingArea_b"></div>'});
			transaction_grid = new dhtmlXGridObject();
	        transaction_grid = finalize_committed_recs.finalize_committed_recs_layout.cells("c").attachGrid();
	        transaction_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");
	        transaction_grid.setHeader('Deal ID,Reference ID,Technology,Generator,Vintage,Deal Volume,Available Volume,Committed Volume,Subsidiary,Strategy,Book,Sub Book,Generator State,Assignment Type,Compliance Year,Subsidiary,Strategy,Book,Initial Committed Volume,Previously Committed Volume,Row No,Unckeck Row No,Assignment Type ID,Gen State ID',null,['text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:right;','text-align:right;','text-align:right;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:left;','text-align:right;','text-align:right;','text-align:left;','text-align:left;','text-align:left;','text-align:left;']);
	        transaction_grid.setColumnIds('Deal_ID,Reference_ID,Technology,Generator,Vintage,Deal_Volume,Available_Vol,Committed_Vol,Subsidiary,Strategy,Book,Sub_Book,Gen_State,Assignment_Type,Compliance_Year,Subsidiary_id,Strategy_id,Book_id,Initial_Committed_Vol,Previously_Committed_Vol,row_num,uncheck_row_num,assignment_type_id,gen_state_value_id');
	        transaction_grid.setColTypes('ro_int,ro,ro,ro,ro,ro_v,ro_v,ro_v,ro,ro,ro,ro,ro,ro,ro_int,ro,ro,ro,ro_v,ro_v,ro_int,ro_int,ro,ro');
	        transaction_grid.setInitWidths('150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,200,200,150,150,150,150');
	        transaction_grid.attachHeader('#numeric_filter,#numeric_filter,#text_filter,#numeric_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter ,#numeric_filter,#text_filter,#text_filter');
            transaction_grid.setColAlign('left,left,left,left,left,right,right,right,left,left,left,left,left,left,left,left,left,left,right,right,left,left,left,left,');
	        transaction_grid.setColumnsVisibility('false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,false,false,true,true,true,true'); 
            transaction_grid.enableColumnMove(true);
	        transaction_grid.enableMultiselect(true);
	        transaction_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            transaction_grid.splitAt(2);
	        transaction_grid.enablePaging(true, 50, 0, 'pagingArea_b');
	        transaction_grid.i18n.decimal_separator = '.';
	        transaction_grid.i18n.group_separator = ',';
	        transaction_grid.setPagingSkin('toolbar');
	        transaction_grid.init();
	        transaction_grid.enableHeaderMenu();
			var sp_url_param = {                    
	                        'flag': 'a',
	                        'assign_type': assignment_type,
	                        'assign_state': assign_state,
	                        'compliance_yr': compliance_year,
	                        'commit_type': aggregate_detail,
	                        'commit_group_id': compliance_group_id,
	                        'action': 'spa_assign_hypothetical_assignment'
	        };

	        sp_url_param  = $.param(sp_url_param);
	        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
	        transaction_grid.clearAll();
	        transaction_grid.loadXML(sp_url);
        } else if (args == 'finalize') {
        	var table_row_id = transaction_grid.getSelectedRowId();

        	if (table_row_id == null) {
        		show_messagebox('Please select data from the grid.');
                return;
        	}

        	dhtmlx.message({
                type: "confirm-warning",
                text: 'Are you sure to finalize committed RECs?',
                title: "Warning",
                callback: function(result) {                         
                    if (result) {
                        finalize_committed_recs();
                    }                           
                } 
            });
        }
	}

	function finalize_committed_recs() {
	 	var display = finalize_committed_recs.filter_form.getItemValue('display');        
        var commit_type = finalize_committed_recs.filter_form.getItemValue('type');

        if (transaction_grid.getSelectedRowId() != null) {
	        var table_row_id = transaction_grid.getSelectedRowId();
	        var selected_row_array_d = table_row_id.split(',');
	        
	        for(var i = 0; i < selected_row_array_d.length; i++) {	    
	            if (i == 0) {
	                deal_id = transaction_grid.cells(selected_row_array_d[i], 0).getValue();
	                assignment_type = transaction_grid.cells(selected_row_array_d[i], 22).getValue();
	                assign_state = transaction_grid.cells(selected_row_array_d[i], 23).getValue();
	                compliance_year = transaction_grid.cells(selected_row_array_d[i], 14).getValue();
	            } else {
	                deal_id = deal_id + ',' + transaction_grid.cells(selected_row_array_d[i], 0).getValue();
	                assignment_type = assignment_type + ',' + transaction_grid.cells(selected_row_array_d[i], 22).getValue();
	                assign_state = assign_state + ',' + transaction_grid.cells(selected_row_array_d[i], 23).getValue();
	                compliance_year = compliance_year + ',' + transaction_grid.cells(selected_row_array_d[i], 14).getValue();
	            }
	        }
	    } else {
	        deal_id = '';
	    }
        
        var sp_url_param = {
            "flag": 'f',
            "deal_id": deal_id,
            "commit_type": commit_type,
            "action": "spa_assign_hypothetical_assignment"
        };

        adiha_post_data('alert', sp_url_param, '', '', 'grd_finalize_committed_recs_click');                                                                                              
	}

	function grd_finalize_committed_recs_click() {
		refresh_export_toolbar_click('refresh');
	}
</script>