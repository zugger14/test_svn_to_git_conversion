<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
  
include "../../../adiha.php.scripts/components/include.file.v3.php";
$form_namespace = 'ns_split_deal_detail_volume';
$form_name = 'frm_match';
$function_id = 10163730;


$spilt_deal_detail_id = isset($_REQUEST['spilt_deal_detail_id']) ? $_REQUEST['spilt_deal_detail_id'] : 'NULL';
$total_split_volume = isset($_REQUEST['total_split_volume']) ? $_REQUEST['total_split_volume'] : '0';
$process_id = isset($_REQUEST['process_id']) ? $process_id : 'NULL';
$process_id = isset($_REQUEST['process_id']) ? $process_id : 'NULL';
$split_deal_detail_volume_id = isset($_REQUEST['split_deal_detail_volume_id']) ? $_REQUEST['split_deal_detail_volume_id'] : 'NULL';
//

$filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163730', @template_name='DealDetailSplitVolume', @group_name='Filters'";
$filter_arr = readXMLURL2($filter_sql);
$tab_id = $filter_arr[0][tab_id];
$form_json = $filter_arr[0][form_json];

$layout_json = '[{id: "a", header:false, height: 150},
                {id: "b", text: "Grids", header:true}]';


$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('deal_layout', '', '2E', $layout_json, $form_namespace);                
echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');
echo $layout_obj->attach_form('form', 'a');
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach('form', $form_namespace);
echo $filter_form_obj->load_form($form_json);
echo $filter_form_obj->set_input_value($form_namespace.'.form', 'total_quantity', $total_split_volume);

echo $filter_form_obj->disable_item('total_quantity');
echo $layout_obj->attach_menu_cell('ns_split_deal_detail_volume_menu', 'b');

$save_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save"}]';
$save_object = new AdihaToolbar();
echo $layout_obj->attach_toolbar_cell('save_menu', 'a');
echo $save_object->init_by_attach('save_menu', $form_namespace);
echo $save_object->load_toolbar($save_json);
echo $save_object->attach_event('', 'onClick', $form_namespace . '.save_split_deal_detail_volume');


$menu_object = new AdihaMenu();
$menu_json = '[  
                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                {id:"t3", text:"Edit", img:"edit.gif", items:[
                    
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add.gif", title: "Add", enabled:true},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete.gif", title: "Delete", enabled:false}
                ]}                      
                ]';
echo $menu_object->init_by_attach('ns_split_deal_detail_volume_menu', $form_namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.ns_split_deal_detail_volume_menu_click');
    
$split_deal_detail_volume_name = 'split_deal_detail_volume_grd';
echo $layout_obj->attach_grid_cell($split_deal_detail_volume_name, 'b');

$split_deal_detail_volume = new GridTable($split_deal_detail_volume_name);        
echo $split_deal_detail_volume->init_grid_table($split_deal_detail_volume_name, $form_namespace);
echo $split_deal_detail_volume->set_columns_ids('id,Quantity,finilized,is_parent');
echo $split_deal_detail_volume->set_header('Sequence,Quantity,Finilized,IsParent');
echo $split_deal_detail_volume->set_column_types('ro,ed,combo,ro');
echo $split_deal_detail_volume->set_sorting_preference('str,str,str,str');
echo $split_deal_detail_volume->set_column_visibility('false,false,false,true');
echo $split_deal_detail_volume->set_widths('150,150,150,150');
echo $split_deal_detail_volume->set_search_filter(true, "");      
echo $split_deal_detail_volume->return_init();
echo $split_deal_detail_volume->enable_header_menu();
echo $split_deal_detail_volume->attach_event('', 'onClick', $form_namespace . '.split_deal_detail_volume_grd_click');
echo $layout_obj->close_layout();
?>


<script type="text/javascript">

    $(function() {
        //load avaiable volume here
    });
    
    //switch case for buttons
    ns_split_deal_detail_volume.ns_split_deal_detail_volume_menu_click = function (id) {
        switch(id) {
    		case 'refresh':
                ns_split_deal_detail_volume.refresh_grid_split_deal_detail_volume();
                break;
            case 'add':
                var newId = (new Date()).valueOf();
                ns_split_deal_detail_volume.split_deal_detail_volume_grd.addRow(newId, '');
                break;
            case 'delete':
                split_deal_detail_volume_grd.deleteSelectedRows();
                break;
        }
    }
    
    
    //refresh grid
    ns_split_deal_detail_volume.refresh_grid_split_deal_detail_volume = function () {
        var percentage = ns_split_deal_detail_volume.form.getItemValue('percentage');
        var split_quantity = ns_split_deal_detail_volume.form.getItemValue('split_quantity');
        var no_of_rows = ns_split_deal_detail_volume.form.getItemValue('no_of_row');
        var total_quantity = ns_split_deal_detail_volume.form.getItemValue('total_quantity');
        var spilt_deal_detail_id = '<?php echo $spilt_deal_detail_id; ?>';
        var process_id = '<?php echo $process_id; ?>';
        
        if (no_of_rows != '' && split_quantity == '' && percentage == '') {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text: 'Please Enter Quantity.'
                    });
            return;
        } 
        
        if (no_of_rows == '' && split_quantity != '' && percentage == '') {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text: 'Please Enter No. of Rows.'
                    });
            return;
        } 
        
        if (percentage == '' && split_quantity == '' && no_of_rows == '') {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text: 'Please enter Percentage or Quantity.'
                    });
            return;
        }
        
        var data = {
                    "action" : "spa_scheduling_workbench",
                    "flag" : "n",
                    "process_id" : process_id,
                    "no_of_rows" : no_of_rows,
                    "total_quantity":total_quantity,
                    "percentage":percentage,
                    "spilt_deal_detail_id":spilt_deal_detail_id,
                    "split_quantity":split_quantity
                  };
    
        var sql_param = $.param(data);
        var sql_url = js_php_path + "data.collector.php?" + sql_param;

        ns_split_deal_detail_volume.split_deal_detail_volume_grd.clearAll();
		ns_split_deal_detail_volume.split_deal_detail_volume_grd.loadXML(sql_url);  
    }
    
    //save split volumes
    ns_split_deal_detail_volume.save_split_deal_detail_volume = function() {
        var spilt_deal_detail_id = '<?php echo $spilt_deal_detail_id; ?>';
        var split_deal_detail_volume_id = '<?php echo $split_deal_detail_volume_id; ?>';
        var xml_grid = '<gridXml>';
        ns_split_deal_detail_volume.split_deal_detail_volume_grd.forEachRow(function (id) {
            xml_grid = xml_grid + '<GridRow ';
            ns_split_deal_detail_volume.split_deal_detail_volume_grd.forEachCell(id, function (cellObj, ind) {                    
                grid_index = ns_split_deal_detail_volume.split_deal_detail_volume_grd.getColumnId(ind);
                value = cellObj.getValue(ind);   
                	xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                })  
                	xml_grid = xml_grid + '></GridRow>';                      
            });
       	xml_grid = xml_grid + '</gridXml>'; 
        
        var data = {
                    "action" : "spa_scheduling_workbench",
                    "flag" : "g",
                    "spilt_deal_detail_id":spilt_deal_detail_id,
                    "split_deal_detail_volume_id": split_deal_detail_volume_id,
                    "xml_value" : xml_grid
                    
                  };
   
        adiha_post_data('return_array', data, '', '', 'ns_split_deal_detail_volume.save_split_deal_detail_volume_callback'); 
    }
    
    ns_split_deal_detail_volume.split_deal_detail_volume_grd_click = function () {
        //alert('')
        ns_split_deal_detail_volume.ns_split_deal_detail_volume_menu.setItemEnabled('delete');
    }
    
    //save callback
    ns_split_deal_detail_volume.save_split_deal_detail_volume_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });
            
            setTimeout('ns_split_deal_detail_volume.close_window()', 1000);   
        } else {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text: msg
                    });
            return;
        }  
    }
    
    //close window
    ns_split_deal_detail_volume.close_window = function () {
        parent.reload_all_grids();
        var win_obj = parent.deal_detail_spilt_window.window("w2");
        win_obj.close();
    }
    
</script>