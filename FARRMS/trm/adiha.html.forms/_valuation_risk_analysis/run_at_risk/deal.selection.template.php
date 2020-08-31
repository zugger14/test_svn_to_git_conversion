<?php
/**
* Deal selection template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<body>
<?php
	$form_name = 'form_deal_selection';
    $query = $_POST['dataquery'];
    $call_from = isset($_GET['call_from']) ? get_sanitized_value($_GET['call_from']) : 0;
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            header:         false
                           //text:           "<a class=\"undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Deal Info"                           
                        }
                    ]';
    
    $cell_json = '[
                        {
                            id:             "a",
                            header:         false
                        },
                        {
                            id:             "b",
                            header:         false
                        }
                    ]';
    
    $name_space = 'deal_selection';
    $layout_obj = new AdihaLayout();

    echo $layout_obj->init_layout('deal_selection_layout', '', '1C', $layout_json, $name_space);

    // Default date value for date component
    $date = date('Y-m-d');
    $date_begin = date('Y-m-01');

    $form_object = new AdihaForm();
    
    $toolbar_json = '[  
                        {id:"Edit", img:"edit.gif", text:"Edit", items:[
                            {id:"add", img:"add.gif", imgdis:"add_dis.gif", title:"Add", text: "Add"},
                            {id:"delete", img:"delete.gif", imgdis:"delete_dis.gif", title:"Delete",text:"Delete", enabled:0}
                        ]},                               
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: true},
                    ]';

    $toolbar_formula_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("toolbar_deal_selection", "a"); 
    echo $toolbar_formula_obj->init_by_attach("toolbar_deal_selection", $name_space);
    echo $toolbar_formula_obj->load_menu($toolbar_json);
    echo $toolbar_formula_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

    //Attach grid to cell c
    $grid_obj = new AdihaGrid();
    $column_name = 'deal_id,id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id';
    $grid_name = 'grd_deal_selection';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    echo $grid_obj->init_by_attach($grid_name, $name_space);
    echo $grid_obj->set_header('Reference ID,Deal ID,Deal Date,Term Start,Term End,Index,Template,Currency,Deal Type,Deal Volume,UOM',',,,,,,,right,,right,right');
    echo $grid_obj->set_column_types('ro,ro,ro,ro,ro,ro,ro,ro,ro,ed_v,ro');
    echo $grid_obj->set_column_alignment(',,,,,,,right,,right,right');
    echo $grid_obj->set_widths('100,100,150,150,150,150,150,150,150,150,150');
    echo $grid_obj->set_columns_ids($column_name);
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->set_column_visibility('false,false,false,false,false,false,false,false,false,false,false');
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->load_grid_data($query,'g');
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
    echo $grid_obj->attach_event('', 'onRowSelect', $name_space . '.row_selected') ;
    echo $layout_obj->close_layout();
?>
</body>

<script type="text/javascript">
    var deal_win = null;
    var call_from = "<?php echo $call_from;?>";
    var delete_rows = new Array();
    //var result = new Array();
    var call_from_deal_ok = false;
    /**
     *
     */
    setTimeout(function() {
        $(function(){
            var row_count = deal_selection.grd_deal_selection.getRowsNum();
            if(row_count == 0) {
                deal_selection.toolbar_deal_selection.setItemDisabled('select_unselect');
            } else {
                deal_selection.toolbar_deal_selection.setItemEnabled('select_unselect');
            }
            parent.global_layout_object.cells('c').collapse();
        });
    }, 500);
    /**
     *
     */
    function refresh_export_toolbar_click(args) { 
        switch(args) {
            case 'add':
                var exists = (typeof parent.select_deal === 'function');
                if (exists) {
                    var col_list = '<?php echo $column_name; ?>'; 
                    parent.select_deal(col_list);
                } else {
                     deal_selection.select_deal();
                }                
            break;
            case 'delete':
                /*dhtmlx.message({
                    title:"Confirmation",
                    type:"confirm",
                    ok: "Confirm",
                    text: 'Are you sure you want to delete?',
                    callback: function(result) {
                        if (result) {*/
                            //populated deleted deal ids
                            if (deal_selection.grd_deal_selection.getSelectedRowId() != null) {
                                var row_id = deal_selection.grd_deal_selection.getSelectedRowId();
                                var selected_row_array_d = row_id.split(',');
                                
                                for(var i = 0; i < selected_row_array_d.length; i++) {                
                                    if (i == 0) {
                                        selected_deal = deal_selection.grd_deal_selection.cells(selected_row_array_d[i], 0).getValue();
                                    } else {
                                        selected_deal = selected_deal + ',' + deal_selection.grd_deal_selection.cells(selected_row_array_d[i], 0).getValue();
                                    }
                                }
                                delete_rows.push(selected_deal);
                                confirm_messagebox("Are you sure you want to delete?",function(){
                                    deal_selection.grd_deal_selection.deleteSelectedRows();
                                });
                                
                            } else {
                                selected_deal = '';
                            }
							deal_selection.toolbar_deal_selection.setItemDisabled('delete');
                            deal_selection.grd_deal_selection.setUserData("","deleted_xml", "deleted");
                        /*} else {
                            return;
                        }
                    }
                });*/
                var row_count = deal_selection.grd_deal_selection.getRowsNum();

                if(row_count == 0) {
                    deal_selection.toolbar_deal_selection.setItemDisabled('select_unselect');
                }
            break;
            case 'select_unselect':
                var select_rows = deal_selection.grd_deal_selection.getSelectedRowId();
                if (select_rows == null) {
                    deal_selection.grd_deal_selection.selectAll();                    
                    deal_selection.toolbar_deal_selection.setItemEnabled('delete');
                } else {
                    deal_selection.grd_deal_selection.clearSelection();
                    deal_selection.toolbar_deal_selection.setItemDisabled('delete');
                }
            break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                deal_selection.grd_deal_selection.toExcel(path);
                
            break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                deal_selection.grd_deal_selection.toPDF(path);
                
            break;  
            default:
                show_messagebox("Unhandled case occured.!");
            break; 
        }
    }
    /**
     *
     */
    deal_selection.get_delete_rows = function(){
        return delete_rows;
    }
    /**
     *
     */
    deal_selection.row_selected = function() { 
        deal_selection.toolbar_deal_selection.setItemEnabled('delete');
    }   
    /**
     *
     */
    deal_selection.select_deal = function() {
        parent.collapse_on();
        // Collect deals from create and view deals page.
        var col_list = '<?php echo $column_name; ?>';        
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'run_mtm_process.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 0, 0);
        deal_win.setModal(true);
        
        var win_title = 'Select Deal';
        var win_url = '../../_deal_capture/maintain_deals/maintain.deals.new.php';  
        /*
        read_only: Default value is false. Set this to true to opens deal page in read only mode. In this mode user are allowed to select existing deals only.
        col_list: List of columns to be listed in grid
        deal_select_completed: Callback function name
        Note: Beside these parameters if extra parameters are added then they should be properly handled in maintain.deals.php
        */      
        var params = {read_only:true,col_list:col_list,deal_select_completed:'deal_selection.callback_select_deal'};
        
        deal_win.setText(win_title);
        deal_win.maximize();
        deal_win.attachURL(win_url, false, params);
        deal_win.attachEvent("onClose", function(win){
            if (!call_from_deal_ok) {
                confirm_messagebox('Are you sure to exit without selecting any deals?',
                    function(){
                        parent.collapse_off();
                        call_from_deal_ok = true;
                        deal_win.close();
                    },
                    function(){
                        return false;
                    }
                );
            } else {
                call_from_deal_ok = false;
                return true;
            }
        });
    }
    /**
     *
     */
    deal_selection.callback_select_deal = function(result) {
        if (parent.deal_win != undefined) {
            console.log(parent.deal_win)
            deal_win = parent.deal_win;
            parent.call_from_deal_ok = true;
        }
        //close child window
        call_from_deal_ok = true;
        deal_win.close();
        
        var new_array = new Array();
        var pre_deals = new Array();
        var pre_deals_str = deal_selection.get_all_grid_cell_value(1);
        
        if (pre_deals_str.indexOf(',') != -1) {
            pre_deals = pre_deals_str.split(',');
        } else {
            pre_deals[0] = pre_deals_str;
        }

        if(pre_deals.length > 0) {
            var i = 0;
            $.each(result, function(index,value) {
                if (pre_deals.indexOf(value[1]) == -1) {
                    new_array[i] = value;
                    i++;
                }
            });
        } else {
            new_array = result;
        }
        
        deal_selection.grd_deal_selection.parse(new_array, "jsarray");
        
        if (result.length > 0) {
            deal_selection.toolbar_deal_selection.setItemEnabled('select_unselect'); 
        }
        
        parent.collapse_off();
    }
    /**
     *
     */
    function undock_window() {
        deal_selection.deal_selection_layout.cells('c').undock(300, 300, 900, 700);
        deal_selection.deal_selection_layout.dhxWins.window('c').maximize();
        deal_selection.deal_selection_layout.dhxWins.window('c').button("park").hide();
    }     
</script>