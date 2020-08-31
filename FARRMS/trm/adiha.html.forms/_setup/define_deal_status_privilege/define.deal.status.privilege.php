<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />       
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "save",
                            header:         false,
                            height:         40,
                            fix_size:       [null,true]                    

                        },
                        {
                            id:             "b",
                            header:         false,
                            text:           "Define deal status privilege",
                            header:         false                          
                        }
 
                    ]';
    $rights_status_privilege = 10104000;
    $rights_status_privilege_add_save_delete = 10104010;
    $rights_status_privilege_privilege = 10104011;
    
    list (
            $has_rights_status_privilege,
            $has_rights_status_privilege_add_save_delete,
            $has_rights_status_privilege_privilege
            
        ) = build_security_rights(
            $rights_status_privilege,
            $rights_status_privilege_add_save_delete,
            $rights_status_privilege_privilege
        );
    $toolbar_json = '[{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:"'.$has_rights_status_privilege_add_save_delete.'"}]';

    $name_space = 'status_privilege';
    
    /* JSON for grid toolbar */
    $button_grid_json = '[
          {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
              {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"'.$has_rights_status_privilege_add_save_delete.'"},
              {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:0}
          ]},
          {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
              {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
              {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
          ]},
          {id:"privilege", text:"Privilege", img:"privilege.gif", imgdis:"privilege_dis.gif", enabled:0}
          ]';
    /* END */

    //Creating Layout
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('status_privilege_layout', '', '2E', $layout_json, $name_space);

    //added for grid menu
    echo 'logical_menu = status_privilege.status_privilege_layout.cells("b").attachMenu();';
    echo 'logical_menu.setIconsPath("'.$image_path.'/dhxmenu_web/");';
    echo 'logical_menu.loadStruct('.$button_grid_json.');';
    echo 'logical_menu.attachEvent("onClick", function(id){
        grid_toolbar_click(id);
    });';
    //end
    
    //Attaching toolbar
    $toolbar = 'status_privilege_button';
    echo $layout_obj->attach_toolbar_cell($toolbar, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar, $name_space);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'function_toolbar_click');

    $grid_name='define_deal_status_privilege';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');
    $tbl_grd_name = 'define_deal_status_privilege';
    $load_grid_sql = "SELECT deal_status_privilege_mapping_id,from_status_value_id, to_status_value_id from deal_status_privilege_mapping";

    $grid_table_obj = new GridTable($tbl_grd_name);
    echo $grid_table_obj->init_grid_table($grid_name, $name_space);
    echo $grid_table_obj->enable_header_menu(); 
    echo $grid_table_obj->enable_paging(25, 'pagingArea_a',true);
    echo $grid_table_obj->return_init();    
    echo $grid_table_obj->load_grid_data($load_grid_sql); 
    echo $grid_table_obj->set_search_filter(true,"#text_filter,#text_filter");
    echo $grid_table_obj->enable_multi_select(); 
    echo 'status_privilege.define_deal_status_privilege.setColValidators("NotEmpty,ValidInteger,ValidInteger,ValidInteger");';
    echo $grid_table_obj->load_grid_functions();
    echo $grid_table_obj->attach_event('','onRowSelect','on_grid_select');
    // echo $grid_table_obj->attach_event('','onRowDblClicked','on_grid_select');
    echo $grid_table_obj->attach_event('','onAfterRowDeleted','on_after_row_deleted');
    echo $layout_obj->close_layout();       
?>
<style type="text/css">
    .dhtmlx-dhtmlx_message_a{  
        position:absolute;!important;
        top: 0px;
        right: 0px; 
        width: 208px;
        /*color: red;*/
    }
</style>    

<div id="pagingArea_a"></div>
<script type="text/javascript">
    var php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var data_deleted = 0;
    var delete_check = false;
    var add_status = false;
    var data_changed_status = false;

    var has_rights_status_privilege_privilege =<?php echo (($has_rights_status_privilege_privilege) ? $has_rights_status_privilege_privilege : '0'); ?>;
    var has_rights_status_privilege_add_save_delete =<?php echo (($has_rights_status_privilege_add_save_delete) ? $has_rights_status_privilege_add_save_delete : '0'); ?>;
    
    dhxWins = new dhtmlXWindows();  
    $(function(){
        status_privilege.status_privilege_layout.cells('a').setHeight(30);
       // status_privilege.status_privilege_layout.cells("a").hideFooter();
        // status_privilege.status_privilege_layout.cells("a").setHeight(10);          
        // status_privilege.status_privilege_layout.cells('a').attachStatusBar();
    });  

    function grid_toolbar_click(id){

        switch(id){
            case 'add':
                add_status = true;
                var newId = (new Date()).valueOf();
                status_privilege.define_deal_status_privilege.addRow(newId,"");
                status_privilege.define_deal_status_privilege.selectRowById(newId);
            break;
            case 'delete':
                delete_check = true;
                var ps_xml = '<Root>';               
                for (var row_index=0; row_index < status_privilege.define_deal_status_privilege.getRowsNum(); row_index++) {
                    ps_xml = ps_xml + "<PSRecordset ";                  
                    
                    for (var cellIndex = 0; cellIndex < status_privilege.define_deal_status_privilege.getColumnsNum(); cellIndex++) {
                        if(status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue() != '') {
                            var dhxCombo = status_privilege.define_deal_status_privilege.getColumnCombo(cellIndex);
                            var selected_option = dhxCombo.getOption(status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue());
                        }
                        var column_id = status_privilege.define_deal_status_privilege.getColumnId(cellIndex);
                        var cell_values = status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue();
                        cell_values = cell_values.replace(/'/g, "''");                        
                            ps_xml = ps_xml + " " + column_id + '="' + cell_values + '"';
                                           }
                    ps_xml = ps_xml + " ></PSRecordset> ";                                
                }
                ps_xml += "</Root>";
                        data = {"action": "spa_deal_status_privilege_mapping",
                            "flag": "d",
                            "xml": ps_xml
                            };
                        status_privilege.define_deal_status_privilege.deleteSelectedRows();  
            break;
            case 'pdf':
                status_privilege.define_deal_status_privilege.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
            case 'excel':
                status_privilege.define_deal_status_privilege.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;

            case 'privilege':
                status_privilege.set_privilege();
            break;

            default:

            break;
        }
    }
  
    function function_toolbar_click(id) {
        var check_empty_fields = false;
        var save_empty_label = '';
        var empty_column_label = new Array;
        var ps_xml = '<Root>';       
        for (var row_index=0; row_index < status_privilege.define_deal_status_privilege.getRowsNum(); row_index++) {
            ps_xml = ps_xml + "<PSRecordset ";          
            
            for (var cellIndex = 0; cellIndex < status_privilege.define_deal_status_privilege.getColumnsNum(); cellIndex++) {
                if(status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue() != '') {
                    var dhxCombo = status_privilege.define_deal_status_privilege.getColumnCombo(cellIndex);
                    var selected_option = dhxCombo.getOption(status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue());
                }
                var column_id = status_privilege.define_deal_status_privilege.getColumnId(cellIndex);
                var column_label = status_privilege.define_deal_status_privilege.getColLabel(cellIndex);
                var cell_values = status_privilege.define_deal_status_privilege.cells2(row_index,cellIndex).getValue();

                if (cell_values == '' && column_id != 'deal_status_privilege_mapping_id'){

                    if ($.inArray(column_label, empty_column_label) == -1){
                        empty_column_label.push(column_label);
                        save_empty_label = save_empty_label +', '+column_label;
                    }
                    check_empty_fields = true;
                }

                cell_values = cell_values.replace(/'/g, "''");               
                    ps_xml = ps_xml + " " + column_id + '="' + cell_values + '"';                
            }
            ps_xml = ps_xml + " ></PSRecordset> ";                                
        }

        if(check_empty_fields) {
            save_empty_label = save_empty_label.replace(",", "");
            error_message = "Data Error in grid. Please check the data in column <strong>"+ save_empty_label +"</strong> and resave.";
            dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
            return
        }

        ps_xml += "</Root>";
        console.log(ps_xml);
        data = { "action": "spa_deal_status_privilege_mapping", 
                         "flag": "i", 
                         "xml": ps_xml
               }

        if(delete_check == true) {
            delete_check = false;    
            dhtmlx.message({
                type: "confirm-warning",
                title: "Warning",
                ok: "Confirm",
                text: "Some data has been deleted from grid. Are you sure you want to save?",
                callback: function(result) {
                    if (result) {      
                       adiha_post_data('alert', data, '', ''); 
                    }
                }
            }); 
        } else {
                // adiha_post_data('alert', data, '', '');
                result = adiha_post_data("return_array", data, "", "", "status_privilege.callback_check_parameter", false);
        }
    }
   
    status_privilege.save_callback = function(result){
        alert('success');

    }
    
    status_privilege.delete_callback = function(){
        alert('success');
    }

    function set_privilege_10104000(role_id, user_id) {

        var selectedID = status_privilege.define_deal_status_privilege.getSelectedRowId();
        var row_index = status_privilege.define_deal_status_privilege.getRowIndex(selectedID);
        var ixp_id = status_privilege.define_deal_status_privilege.cells2(row_index, 0).getValue();
        
        data = {    "action": "spa_deal_status_privileges",
                    "flag": "i",
                    "user_id": user_id,
                    "role_id": role_id,
                    "deal_status_id": ixp_id
                };
        
        adiha_post_data('alert', data, '', '', '');
        privilege.window('p1').close();

    }

    function on_grid_select (id, ind) {
        myCombo = status_privilege.define_deal_status_privilege.getColumnCombo(ind);
        myCombo.attachEvent("onOpen", function(){
           data_changed_status = true; 
        });
        // console.log(myCombo);
        if (has_rights_status_privilege_privilege) {
            logical_menu.setItemEnabled('privilege');
        }
        if (has_rights_status_privilege_add_save_delete) {
            logical_menu.setItemEnabled('delete');
        }
    }

    function on_after_row_deleted (id, ind) {
        status_privilege.define_deal_status_privilege.clearSelection();
        logical_menu.setItemDisabled('privilege');
        logical_menu.setItemDisabled('delete');
    }


   status_privilege.set_privilege = function() {
        var selectedID = status_privilege.define_deal_status_privilege.getSelectedRowId();
        var row_index = status_privilege.define_deal_status_privilege.getRowIndex(selectedID);
        var ixp_id = status_privilege.define_deal_status_privilege.cells2(row_index, 0).getValue();

        data = {    "action": "spa_deal_status_privileges",
                    "flag": "a",
                    "deal_status_id": ixp_id
                };

        adiha_post_data('return_array', data, '', '', 'define_deal_status_privilege_callback');
    }
    
    function define_deal_status_privilege_callback(result) {
        var users = result[0][0];
        if (users != null)
            users = users.substring(0,users.length-1);
        var roles = result[0][1];
        if (roles != null)
            roles = roles.substring(0,roles.length-1);
        open_privilege('set_privilege_10104000', users, roles);
    }

    status_privilege.callback_check_parameter = function(result) {
        if (result[0][0] == "Error") {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            }); 
        } else {
            if ((add_status) || (data_changed_status)) {
                dhtmlx.message({
                    text:result[0][4],
                    expire:1000
                });
                add_status = false;
                data_changed_status = false;
            } else {
                dhtmlx.message({ type:"dhtmlx_message_a", text:"No changes in the Deal Status grid." ,expire:"700"});
            }
        }
    }

</script>