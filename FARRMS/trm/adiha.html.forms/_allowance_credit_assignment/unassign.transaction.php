<?php
/**
* Unassign transaction screen
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

$form_name = 'form_unassign_transaction';
$name_space = 'unassign_transaction';

$rights_unassign_transaction = 14121500;

list(
    $has_rights_unassign_transaction
    ) = build_security_rights(
    $rights_unassign_transaction
);

$layout_json = '[
                        {id: "a", text: "", header: "true", height: 275},  
                        {id: "b", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Transactions"}
                    ]';

$unassign_transaction_layout = new AdihaLayout();
echo $unassign_transaction_layout->init_layout('unassign_transaction_layout', '', '2E', $layout_json, $name_space);

$menu_name = 'assign_unassign_menu';
$menu_json = "[
            {id:'refresh', text:'Refresh', img:'refresh.gif', imgdis:'refresh_dis.gif'},
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]},
            {id:'t', text:'Process', img:'action.gif', items:[
                {id:'unassign', text:'Unassign', img:'process.gif', imgdis: 'process_dis.gif', enabled: false},
                
            ]},
            {id:'select_unselect', text:'Select/Unselect All', img:'select_unselect.gif', imgdis:'select_unselect_dis.gif', enabled: 0}
        ]";

$assign_unassign_obj = new AdihaMenu();
echo $unassign_transaction_layout->attach_menu_cell($menu_name, "b");
echo $assign_unassign_obj->init_by_attach($menu_name, $name_space);
echo $assign_unassign_obj->load_menu($menu_json);
echo $assign_unassign_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

echo $unassign_transaction_layout->close_layout();
?>
</body>
<script type="text/javascript">
    var select_all = 0;
    var has_rights_unassign_transaction = Boolean('<?php echo $has_rights_unassign_transaction; ?>');
    var unassign_transaction_ui = {};
    var active_object_id = 'NULL';
    var default_date = new Date();
    var default_date_year = default_date.getFullYear();
    var unassign_transaction_grid = {};
    var ununassign_transaction_grid = {};
    var theme_selected = 'dhtmlx_' + default_theme;
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';

    $(function() {
        load_filter_components();
        var form_obj = unassign_transaction_ui["form_0"].getForm(); 
        form_obj.attachEvent('onInputChange', function(name, value, form) {
            var vintage_to = form_obj.getItemValue('vintage_to');               
            var vintage_from = form_obj.getItemValue('vintage_from');             
            var assign_date_to = form_obj.getItemValue('assign_date_to');               
            var assign_date_from = form_obj.getItemValue('assign_date_from'); 

            if (value && name == 'vintage_to' || name == 'vintage_from') {
                if(vintage_to && vintage_to <= vintage_from) {
                    show_messagebox("Vintage To is less than Vintage From.");
                    form_obj.setItemValue(name, null); 
                } 
            }

            if (value && name == 'assign_date_to' || name == 'assign_date_from') {
                if(assign_date_to && assign_date_to <= assign_date_from) {
                    show_messagebox("Assign Date To is less than Assign Date From.");
                    form_obj.setItemValue(name, null); 
                } 
            } 
            return false; 
        });

    });

    function undock_window() {
        unassign_transaction.unassign_transaction_layout.cells('b').undock(300, 300, 900, 700);
        unassign_transaction.unassign_transaction_layout.dhxWins.window('b').button('park').hide();
        unassign_transaction.unassign_transaction_layout.dhxWins.window('b').maximize();
    }

    function load_filter_components() {
        var data = {"action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id" : 14121500, 
            "template_name": 'UnassignTransaction',
            "group_name": "General" };
        result = adiha_post_data('return_array', data, '', '', 'load_filter_form_data', false);

    }

    function load_filter_form_data(result) {
        var result_length = result.length;
        var tab_json = '';

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        unassign_transaction_ui["unassign_transaction_tabs" + active_object_id] = unassign_transaction.unassign_transaction_layout.cells("a").attachTabbar();
        unassign_transaction_ui["unassign_transaction_tabs" + active_object_id].loadStruct(tab_json);

        var first_tab = '';

        for (j = 0; j < result_length; j++) {
            first_tab = 'detail_tab_' + result[0][0];
            tab_id = 'detail_tab_' + result[j][0];
            unassign_transaction_ui["form_" + j] = unassign_transaction_ui["unassign_transaction_tabs" + active_object_id].cells(tab_id).attachForm();

            if (result[j][2]) {
                unassign_transaction_ui["form_" + j].loadStruct(result[j][2]);
                var form_name = 'unassign_transaction_ui["form_" + ' + j + ']';
                attach_browse_event(form_name, 14121400, '', '');
            }

        }

        unassign_transaction_ui["unassign_transaction_tabs" + active_object_id].tabs(first_tab).setActive();
    }

    function refresh_export_toolbar_click(args) {
        switch(args) {
            case 'refresh':
                refresh_grid_assign();
                break;
            case 'unassign':
                var row_id = unassign_transaction_grid.getSelectedRowId();  
                dhtmlx.message({
                    type: "confirm",
                    text: 'Are you sure want to unassign the selected deal?',
                    title: "Warning",
                    callback: function(result) {                         
                        if (result) {
                            do_transaction(0, 'NULL');
                        }                           
                    } 
                });
                break;
            case 'excel':
                unassign_transaction_grid.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                unassign_transaction_grid.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;        
            case 'select_unselect':
                select_rows = unassign_transaction_grid.getSelectedRowId(); 
                if (select_rows == null) {
                    unassign_transaction_grid.selectAll();
                    select_all = 1;             
                    unassign_transaction.assign_unassign_menu.setItemEnabled('unassign');    
                } else {
                    unassign_transaction_grid.clearSelection();
                    select_all = 0;
                    unassign_transaction.assign_unassign_menu.setItemDisabled('unassign'); 
                }
            break;
        }
    }

    function do_transaction(committed, compliance_group_id) {
        var form_data = unassign_transaction_ui["form_0"].getFormData();
        for (var a in form_data) {
            if (unassign_transaction_ui["form_0"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (unassign_transaction_ui["form_0"].getItemValue("' + a + '", true) == "") ? "NULL" : unassign_transaction_ui["form_0"].getItemValue("' + a + '", true);');
            } else {
                eval('var ' + a + ' = (unassign_transaction_ui["form_0"].getItemValue("' + a + '") == "") ? "NULL" : unassign_transaction_ui["form_0"].getItemValue("' + a + '");');
            }
        }

        var row_id = unassign_transaction_grid.getSelectedRowId();
        row_id_arr = row_id.split(',')
        
        for (var i=0; i<row_id_arr.length; i++) {
            row_id_arr[i] = parseInt(row_id_arr[i]) + 1;
        }

        var selected_row_unique_ids = row_id_arr.toString();
        
        var table_name = '';
        var selected_row_unique_ids = '';
        var volume_available = ''; 

        if (row_id != null) {
            var table_row_id = row_id;
            var selected_row_array_d = table_row_id.split(',');
            
            for(var i = 0; i < selected_row_array_d.length; i++) {
        
                if (i == 0) {
                    table_name = unassign_transaction_grid.cells(selected_row_array_d[i], 0).getValue();
                    assign_id = unassign_transaction_grid.cells(selected_row_array_d[i], 1).getValue(); 
                    selected_row_unique_ids = unassign_transaction_grid.cells(selected_row_array_d[i], 2).getValue(); 
                } else { 
                    table_name = table_name + ',' + unassign_transaction_grid.cells(selected_row_array_d[i], 0).getValue();
                    assign_id = assign_id + ',' + unassign_transaction_grid.cells(selected_row_array_d[i], 1).getValue(); 
                    selected_row_unique_ids = selected_row_unique_ids + ',' + unassign_transaction_grid.cells(selected_row_array_d[i], 2).getValue(); 
                }
            }
        }   

        var table_name_array = table_name.split(",");
        table_name = table_name_array[0]; 

        var sp_url_param = {
            "assignment_type": assignment_type,
            "assigned_state": assigned_jurisdication, 
            "compliance_year": compliance_year, 
            "table_name": table_name,  
            "select_all_deals": select_all,
            "selected_row_ids": selected_row_unique_ids, 
            "assign_id": assign_id,
            "unassign": '1',
            "action": "spa_assign_transaction"
        }; 
       
        adiha_post_data('alert', sp_url_param, '', '', unassign_transaction_grid.destructor());
 
    }    
    function refresh_grid_assign() {
        unassign_transaction.assign_unassign_menu.setItemDisabled('unassign');
        var form_data = unassign_transaction_ui["form_0"].getFormData();
        for (var a in form_data) {
            if (unassign_transaction_ui["form_0"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (unassign_transaction_ui["form_0"].getItemValue("' + a + '", true) == "") ? "NULL" : unassign_transaction_ui["form_0"].getItemValue("' + a + '", true);');
            } else {
                eval('var ' + a + ' = (unassign_transaction_ui["form_0"].getItemValue("' + a + '") == "") ? "NULL" : unassign_transaction_ui["form_0"].getItemValue("' + a + '");');
            }
        }

        var flag = 'u';
        var action = 'spa_find_unassign_transation';

        var sp_url_param = {  
                        'flag': flag,       
                        'fas_sub_id': subsidiary_id,       
                        'fas_strategy_id': strategy_id,
                        'fas_book_id': book_id,
                        'assignment_type': assignment_type, 
                        'assigned_state': assigned_jurisdication,
                        'tier_value_id': tier_type,
                        'compliance_year': compliance_year, 
                        'assigned_dt_from': assign_date_from,
                        'assigned_dt_to': assign_date_to,
                        'volume': volume,
                        'deal_id': deal_id,
                        'counterparty_id':counterparty,
                        'gen_date_from': vintage_from,
                        'gen_date_to': vintage_to,
                        'action': action
        }; 

        unassign_transaction.unassign_transaction_layout.cells('b').attachStatusBar({height: 30, text: '<div id="pagingArea_b"></div>'});
 
        // if (assign_unassign == 'a') {
        unassign_transaction_grid = unassign_transaction.unassign_transaction_layout.cells("b").attachGrid();
        unassign_transaction_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");

        unassign_transaction_grid.setHeader('Process ID,Assign ID,Row Unique ID,Detail ID,Deal ID, Vintage ,Jurisdiction,Tier, Generator, Counterparty,Volume,UOM,Price',null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:left;"]);
        unassign_transaction_grid.setColumnIds('Process ID,Assign_id,row_unique_id,Detail ID,Deal ID, Vintage,Jurisdiction,tier_type,Generator,Counterparty,Volume Assigned,UOM,Price');
        unassign_transaction_grid.setColAlign("left,left,left,left,left,left,left,left,left,left,right,right,right");
        unassign_transaction_grid.setColTypes('ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro_v,ro,ro_p');
        unassign_transaction_grid.setInitWidths('150,150,150,150,150,150,150,150,150,150,150,150,150');
        unassign_transaction_grid.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter');
        unassign_transaction_grid.setColumnsVisibility('true,false,true,false,false,false,false,false,false,false,false,false,false');
        unassign_transaction_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        unassign_transaction_grid.enablePaging(true, 50, 0, 'pagingArea_b');
        unassign_transaction_grid.i18n.decimal_separator = '.';
        unassign_transaction_grid.i18n.group_separator = ',';
        unassign_transaction_grid.enableMultiselect(true);
        unassign_transaction_grid.enableColumnMove(true);
        unassign_transaction_grid.setPagingSkin('toolbar');
        unassign_transaction_grid.init();
        unassign_transaction_grid.enableHeaderMenu();
         unassign_transaction_grid.attachEvent('onRowSelect', function(){
               unassign_transaction.assign_unassign_menu.setItemEnabled('unassign');
            });
        //unassign_transaction_grid.splitAt(2);    

        sp_url_param  = $.param(sp_url_param);
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        unassign_transaction_grid.clearAll();
        unassign_transaction_grid.load(sp_url, function(){
            unassign_transaction_grid.filterByAll();
        });
        unassign_transaction.assign_unassign_menu.setItemEnabled('select_unselect');
    }

</script>
</html>