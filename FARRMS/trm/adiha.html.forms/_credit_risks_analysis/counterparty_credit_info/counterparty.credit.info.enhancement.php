<?php
/**
* Counterparty credit info enhancement screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php'; 
    ?>
</head>
<?php
$object_id = get_sanitized_value($_REQUEST["object_id"] ?? '');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? '');
$function_id = 10101125;
$rights_counterparty_credit_info_enhancement_iu = 10101126;
$rights_counterparty_credit_info_enhancement_delete = 10101127;

list (
    $has_rights_counterparty_credit_info_enhancement_iu,
    $has_rights_counterparty_credit_info_enhancement_delete
) = build_security_rights(
    $rights_counterparty_credit_info_enhancement_iu,
    $rights_counterparty_credit_info_enhancement_delete
);

$filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10101184', @template_name='CounterpartyCreditInfoEnhancementFilter', @group_name='General'";
$filter_arr = readXMLURL2($filter_sql);
$form_json = $filter_arr[0]['form_json'];

$form_namespace = 'ccie_enhancement';
$layout = new AdihaLayout();

$layout_json = '[   
                        {id: "a", text: "Apply Filter",collapse: false, height: 100},
                        {id: "b", text: "Filters", height:200},
                        {id: "c", text: "Counterparty Credit Enhancement"},
                        {id: "d", text: "Counterparty Credit Enhancement Details"}
                    ]';
$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('ccie_layout', '', '4G', $layout_json, $form_namespace);
echo $layout_obj->set_text("c", "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Counterparty Credit Enhancement");

$menu_name = 'ccie_menu';
$menu_json ='[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", disabled:false, items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                {id:"delete", text:"Delete", img:"delete.gif"}
            ]},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
			{id:"change_Status", text:"Change Status", img:"report.gif", imgdis:"report_dis.gif",  enabled: 1},
            {id:"workflow_status", text:"Workflow Status", img:"report.gif", imgdis:"report_dis.gif", enabled: 1}
            ]';

echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.menu_click');

// attach filter form
$filter_form_name = 'filter_form';
echo $layout_obj->attach_form($filter_form_name, 'b');
$filter_form_obj = new AdihaForm();
$filter_form_obj->init_by_attach($filter_form_name, $form_namespace);
echo $filter_form_obj->load_form($form_json);

//attach grid
$enhancement_grid_name = 'enhancement_grid';
echo $layout_obj->attach_grid_cell($enhancement_grid_name, 'c');
$enhancement_grid_obj = new AdihaGrid();
echo $layout_obj->attach_status_bar("c", true);
echo $enhancement_grid_obj->init_by_attach($enhancement_grid_name, $form_namespace);
echo $enhancement_grid_obj->set_header("Internal Counterparty/Enhancement ID,System ID,Contract,Deal ID,Enhance Type,Guarantee Counterparty,Effective Date,Expiration Date,Amount,Currency,Approved By,Collateral Status,Comment,Receive,Auto Renewal,Do Not Use Credit Collateral,Blocked,Transfer,Primary",",,,,,,,right,right,,,,,,,,,,,right,,,,,,,,,,,,,");
echo $enhancement_grid_obj->set_columns_ids("enhancement_id,system_id,contract,deal_id,enhance_type,guarantee_counterparty,effective_date,expiration_date,amount,currency,approved_by,collateral_status,comment,margin,auto_renewal,exclude_collateral,transferred,is_primary");
echo $enhancement_grid_obj->set_widths("300,150,150,150,150,150,150,150,150,150,150,150,150,150,150,300,150,150,150");
echo $enhancement_grid_obj->set_column_types("tree,ro,ro,link,ro,ro,ro,ro,ro_a,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
echo $enhancement_grid_obj->set_column_alignment(",,,,,,,,,right,right,,,,,,,,,,,,right,,,,,,,,,,,");
echo $enhancement_grid_obj->enable_multi_select();
echo $enhancement_grid_obj->set_column_visibility("false,true,false,true,false,false,false,false,false,false,true,false,true,false,false,false,false,false,false");
echo $enhancement_grid_obj->enable_paging(100, 'pagingArea_c', 'true');
echo $enhancement_grid_obj->enable_column_move('false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true');
echo $enhancement_grid_obj->set_sorting_preference('str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str');
echo $enhancement_grid_obj->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
echo $enhancement_grid_obj->split_grid('1');
echo $enhancement_grid_obj->return_init();
echo $enhancement_grid_obj->enable_header_menu();
echo $enhancement_grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.create_new_tab');

$tabbar_name = 'ccie_enhancement_details';
echo $layout_obj->attach_tab_cell($tabbar_name, 'd');
$tabbar_obj = new AdihaTab();
echo $tabbar_obj->init_by_attach($tabbar_name, $form_namespace);
echo $tabbar_obj->enable_tab_close();
echo $tabbar_obj->attach_event('', "onTabClose", 'ccie_enhancement.ccie_enhancement_details_close');


echo $layout_obj->close_layout();
?>

<script type="text/javascript">

enhancementDetails          = {};
enhancementDetails.toolbar  = {};   
enhancementDetails.layout   = {};
enhancementDetails.form     = {};
enhancementDetails.pages    = {};
var expand_state = 0;
var source_deal_header_id = "<?php echo $source_deal_header_id ?>";
var is_new_tab = '';

$(function() {
    ccie_enhancement.on_refresh();

    //adding filter
    var filter_function_id  = 10101184;
    var filter_obj = ccie_enhancement.ccie_layout.cells("a").attachForm();
    var layout_b_obj = ccie_enhancement.ccie_layout.cells("b");
    load_form_filter(filter_obj, layout_b_obj, filter_function_id, 2);
    ccie_enhancement.ccie_layout.cells("a").collapse();
    if (source_deal_header_id && source_deal_header_id != '') {
        ccie_enhancement.create_new_tab(-1, -1);
    }
})

ccie_enhancement.menu_click = function(id) {
    switch(id) {
        case 'refresh':
            ccie_enhancement.on_refresh();
        break;
        case 'add':
            ccie_enhancement.create_new_tab(-1, -1);
        break;
        case 'delete':
            var selectedId = ccie_enhancement.enhancement_grid.getSelectedRowId();
            var selected_row_array_delete_enhancement = selectedId.split(',');
            var selected_item_id_delete_enhancement = '';
            for(var i = 0; i < selected_row_array_delete_enhancement.length; i++) {
                if (i == 0) {
                    selected_item_id_delete_enhancement =  ccie_enhancement.enhancement_grid.cells(selected_row_array_delete_enhancement[i], 0).getValue();
                } else {
                    selected_item_id_delete_enhancement = selected_item_id_delete_enhancement + ',' + ccie_enhancement.enhancement_grid.cells(selected_row_array_delete_enhancement[i], 0).getValue();
                }
            }                         
            
            data = {"action": "spa_counterparty_credit_enhancements",
                    "flag": "d",
                    "counterparty_credit_enhancement_id": selected_item_id_delete_enhancement
            };
            adiha_post_data('confirm', data, '', '', 'ccie_enhancement.on_refresh');
        break;
        case 'expand_collapse':
            if (expand_state == 0) 
                ccie_enhancement.openAllEnhancement();
            else
                ccie_enhancement.closeAllEnhancement();
        break;
        case 'workflow_status':
            var selectedId = ccie_enhancement.enhancement_grid.getSelectedRowId();
            if (selectedId != null)
                enhancement_id = ccie_enhancement.enhancement_grid.cells(selectedId, 0).getValue();
            
            var workflow_report = new dhtmlXWindows();
            workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
            workflow_report_win.setText("Workflow Status");
            workflow_report_win.centerOnScreen();
            workflow_report_win.setModal(true);
            workflow_report_win.maximize();

            var filter_string = '';
            var process_table_xml = 'counterparty_credit_enhancement_id:' + enhancement_id;
            var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + enhancement_id + '&source_column=counterparty_credit_enhancement_id&module_id=20618&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
            workflow_report_win.attachURL(page_url, false, null);
            
        break;
		case 'change_Status':
            var selectedId = ccie_enhancement.enhancement_grid.getSelectedRowId();
            if (selectedId != null)
                enhancement_id = ccie_enhancement.enhancement_grid.cells(selectedId, 0).getValue();
			var param = 'counterparty.credit.info.change.status.php?&is_pop=true&enhancement_id=' + enhancement_id;  
			var change_satatus = new dhtmlXWindows();
			var width = 400;
			var height = 300;
            change_satatus_win = change_satatus.createWindow('w1', 0, 0, width, height);
            change_satatus_win.setText("Collateral Status");
			change_satatus_win.attachURL(param, false, null);
            change_satatus_win.centerOnScreen();
            change_satatus_win.setModal(true);
            change_satatus_win.maximize(); 		
			ccie_enhancement.on_refresh();
			change_satatus_win.attachEvent('onClose', function(w) {	
			var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var success_status = $('textarea[name="success_status"]', ifrDocument).val();
			if (success_status == 'Success') {
				if (!enhancementDetails.pages[enhancement_id]) {
					ccie_enhancement.on_refresh();
				}
            }
			if ((enhancementDetails.pages[enhancement_id]) && success_status == 'Success') {
				callback_enhancement_grid_refresh(enhancement_id,'Changes have been saved successfully');
			}			
            return true;
			});
		
        break;
        default:
        break;
    }
}

ccie_enhancement.openAllEnhancement = function() {
   ccie_enhancement.enhancement_grid.expandAll();
   expand_state = 1;
}

ccie_enhancement.closeAllEnhancement = function() {
   ccie_enhancement.enhancement_grid.collapseAll();
   expand_state = 0;
}

ccie_enhancement.on_refresh = function() {
    var filter_data = ccie_enhancement.filter_form.getFormData();
    var filter_effective_date_from = ccie_enhancement.filter_form.getItemValue('effective_date_from', true);
    var filter_effective_date_to = ccie_enhancement.filter_form.getItemValue('effective_date_to', true);

    var filter_xml = '<Root><FilterXML ';
    for(var a in  filter_data) {
        if(a == 'effective_date_from') {
            filter_xml += " " + a + "=\"" + filter_effective_date_from + "\""; 
        } else if(a == 'effective_date_to') {
            filter_xml += " " + a + "=\"" + filter_effective_date_to + "\""; 
        } else {
            filter_xml += " " + a + "=\"" + filter_data[a] + "\""; 
        }
    }
    
    filter_xml += ' /></Root>'

    var param = {
        "flag": "g",
        "action":"spa_counterparty_credit_enhancements",
        "Counterparty_id": "<?php echo $object_id; ?>",
        "filter_xml": filter_xml,
        "grid_type":"tg",
        "grouping_column":"internal_counterparty,enhancement_id",
        "grouping_type": 5,
        "deal_id" :source_deal_header_id
    };

    param = $.param(param);
    var param_url = js_data_collector_url + "&" + param;    
    ccie_enhancement.enhancement_grid.clearAndLoad(param_url);
}

ccie_enhancement.ccie_enhancement_details_close = function(id) {
    delete enhancementDetails.pages[id];
    delete enhancementDetails.layout[id];
    
    return true;
}

ccie_enhancement.create_new_tab = function(r_id, col_id) {

    if(r_id == -1 && col_id == -1) {
        ccie_enhancement.add_detail_tab(-1);
        return;
    }

    var tree_level = ccie_enhancement.enhancement_grid.getLevel(r_id);
    var enhancement_id_col = ccie_enhancement.enhancement_grid.getColIndexById('system_id');
    var enhancement_id_value = ccie_enhancement.enhancement_grid.cells(r_id, enhancement_id_col).getValue();
    var has_children = ccie_enhancement.enhancement_grid.getAllSubItems(r_id);

    if (tree_level == 2 || !has_children) {
        ccie_enhancement.add_detail_tab(enhancement_id_value);
    }
}

callback_enhancement_grid_refresh = function(id, message){

    success_call(message);

    var active_tab = ccie_enhancement.ccie_enhancement_details.getActiveTab();
    ccie_enhancement.ccie_enhancement_details_close(active_tab);
    ccie_enhancement.ccie_enhancement_details.cells(active_tab).close(false);       
    ccie_enhancement.ccie_enhancement_details.tabs(active_tab).close(true);  
    
    ccie_enhancement.on_refresh();
    ccie_enhancement.add_detail_tab(id);
}

function undock_window() {
        ccie_enhancement.ccie_layout.cells('c').undock(300, 300, 900, 700);
        ccie_enhancement.ccie_layout.dhxWins.window('c').maximize();
        ccie_enhancement.ccie_layout.dhxWins.window("c").button("park").hide();
    }

ccie_enhancement.add_detail_tab = function(enhancement_id) {
    if (!enhancementDetails.pages[enhancement_id]) {
        ccie_enhancement.ccie_layout.cells('d').progressOn();       

        // add tab
        ccie_enhancement.ccie_enhancement_details.addTab(enhancement_id, (enhancement_id != -1)?enhancement_id:'New');        
        ccie_enhancement.ccie_enhancement_details.cells(enhancement_id).setActive();

        // treat tab cell as window
        win = ccie_enhancement.ccie_enhancement_details.cells(enhancement_id);
        enhancementDetails.pages[enhancement_id] = win;

        enhancementDetails.layout[enhancement_id] = ccie_enhancement.ccie_enhancement_details.cells(enhancement_id).attachLayout({
            pattern: '1C',
            cells: [
                {id: "a", text: "'" + enhancement_id + "'", header: "false"}
            ]
        });

        var counterparty_id = '<?php echo $object_id; ?>';
        var counterparty_credit_enhancement_id = enhancement_id;

        if(enhancement_id == '' || enhancement_id == null || enhancement_id == -1) { 
            is_new_tab = 'y';
            var sql = {
                "action": "spa_counterparty_credit_info",
                "flag": "g",
                "Counterparty_id": counterparty_id
            }

            adiha_post_data('', sql, '', '', function(result) {
                enhancementDetails.layout[enhancement_id].cells('a').attachURL('credit.enhancement.php?counterparty_id='+counterparty_id+'&counterparty_credit_info_id='+result[0]['counterparty_credit_info_id']+'&mode=i&is_pop=false&deal_id='+source_deal_header_id + '&is_new_tab='+is_new_tab);
            })
        } else { 
            enhancementDetails.layout[enhancement_id].cells('a').attachURL('credit.enhancement.php?counterparty_id='+counterparty_id+'&counterparty_credit_enhancement_id='+counterparty_credit_enhancement_id+'&mode=u&is_pop=false&deal_id='+source_deal_header_id);
        }
        
    } else {
        ccie_enhancement.ccie_enhancement_details.cells(enhancement_id).setActive();
    }

    ccie_enhancement.ccie_layout.cells('d').progressOff();
}
</script>
</html>