<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php

//include "../../../adiha.php.scripts/components/include.file.v3.php";
$form_namespace = 'ns_create_injection_withdrawal';
$form_name = 'frm_create_injection_withdrawal';
$function_id = 10163740;

$location_name = isset($_REQUEST['location_name']) ? $_REQUEST['location_name'] : '';
$contract_name = isset($_REQUEST['contract_name']) ? $_REQUEST['contract_name'] : '';
$total_quantity = isset($_REQUEST['total_quantity']) ? $_REQUEST['total_quantity'] : '';
$term = isset($_REQUEST['term']) ? $_REQUEST['term'] : '';
$injection_withdrawal = isset($_REQUEST['injection_withdrawal']) ? $_REQUEST['injection_withdrawal'] : '';
$location_id = isset($_REQUEST['location_id']) ? $_REQUEST['location_id'] : '';
$contract_id = isset($_REQUEST['contract_id']) ? $_REQUEST['contract_id'] : '';
$wacog = isset($_REQUEST['wacog']) ? $_REQUEST['wacog'] : '';
$commodity = isset($_REQUEST['commodity']) ? $_REQUEST['commodity'] : '';

$xml_user = "EXEC spa_get_regions @user_login_id= '" . $app_user_name . "'";
$def = readXMLURL2($xml_user);
$date_format = $def[0][date_format];
$date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $date_format)));

$sql = "EXEC spa_getsourceuom @flag='s'";

$result_sql = readXMLURL2($sql);
$json_uom = json_encode($result_sql);
    
$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();
$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);

$form_json = '[{type: "settings", position: "label-top"},
				{type: "block", 
    				list: [
                        {type:"input",name:"Location",id:"location_name",label:"Location",value:"'.$location_name.'","position":"label-top","tooltip":"Location","inputWidth":"310","disabled":"true"}
                        ,
                        {type:"input",name:"Contract",id:"Contract_name",label:"Contract",value:"'.$contract_name.'","position":"label-top","tooltip":"Contract","inputWidth":"310","disabled":"true"}
                        ]},
                {type: "block", 
    				list: [
                            {"type":"input","name":"commodity","id":"commodity","label":"Commodity","disabled":"true",offsetLeft:"0","value":"'.$commodity.'","position":"label-top","labelWidth":"auto","inputWidth":"150","tooltip":"commodity"},
                            {"type":"newcolumn"},
                            {"type":"input","name":"total_quantity","id":"total_quantity","label":"Inventory Balance","disabled":"true",offsetLeft:"10","value":"'.$total_quantity.'","position":"label-top","labelWidth":"auto","inputWidth":"150","tooltip":"Inventory Balance"}
                            ]},
                        {"type":"newcolumn"},
                {type: "block", 
    				list: [    
                        {"type": "combo","id":"cmb_uom", "label": "UOM", "name": "cmb_uom", "width": "150","options": '.$json_uom.',"disabled":"false",offsetLeft:"0","tooltip":"UOM"},
                        {"type":"newcolumn"},                
                        {"type":"input","name":"quantity","id":"quantity","label":"Quantity","disabled":"false","value":"","position":"label-top",offsetLeft:"10","labelWidth":"auto","inputWidth":"150","tooltip":"Quantity","validate":"NotEmpty,ValidNumeric","required":true}
                        ]},
                {type: "block", 
    				list: [    
                        {"type":"calendar","id":"term_start","name":"term_start","label":"Est. Movement Date", "serverDateFormat":"%Y-%m-%d","validate":"NotEmpty","hidden":"false","disabled":"false","value":"","position":"label-top","labelWidth":"auto","inputWidth":"150","tooltip":"Est. Movement Date","dateFormat":"' .$date_format.'","calendarPosition":"bottom","required":true}
                        ]}
                ]
                ';

$menu_json = '[{id:"save", text:"Create", img: "save.gif", imgdis: "save_dis.gif", title: "Create"}]';


echo $layout_obj->attach_form($form_name, 'a');
echo $form_obj->init_by_attach($form_name, $form_namespace);
echo $form_obj->load_form($form_json);

echo $layout_obj->attach_menu_cell('create_injection_withdrawal_menu', 'a');
$menu_object = new AdihaMenu();
echo $menu_object->init_by_attach('create_injection_withdrawal_menu', $form_namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.create_injection_withdrawal_click');
/* add export end */
	
echo $layout_obj->close_layout();

?>
</body>
<script type="text/javascript">

    ns_create_injection_withdrawal.create_injection_withdrawal_click = function() {
        ns_create_injection_withdrawal.layout.cells('a').progressOn();
        var injection_withdrawal = '<?php echo $injection_withdrawal; ?>';
        var quantity = ns_create_injection_withdrawal.frm_create_injection_withdrawal.getItemValue('quantity');
        var term_start = ns_create_injection_withdrawal.frm_create_injection_withdrawal.getItemValue('term_start', true);
        var uom = ns_create_injection_withdrawal.frm_create_injection_withdrawal.getItemValue('cmb_uom', true);
        var commodity_name = ns_create_injection_withdrawal.frm_create_injection_withdrawal.getItemValue('commodity', true);
        var location_id = '<?php echo $location_id; ?>';
        var contract_id = '<?php echo $contract_id; ?>'; 
        var wacog = '<?php echo $wacog; ?>'; 
        
        
        if (quantity == '') {
            dhtmlx.message({
                        title: 'Error',
                        type: "alert-error",
                        text: 'Quantity cannot be blank.'
                    });
            
            ns_create_injection_withdrawal.layout.cells('a').progressOff();
            return;
        }
        
        if (isNaN(quantity)) {
            dhtmlx.message({
                        title: 'Error',
                        type: "alert-error",
                        text: 'Quantity must be Numeric.'
                    });
            
            ns_create_injection_withdrawal.layout.cells('a').progressOff();
            return;
        }
        
        if (term_start == '') {
            dhtmlx.message({
                        title: 'Error',
                        type: "alert-error",
                        text: 'Est. Movement Date cannot be blank.'
                    });
            
            ns_create_injection_withdrawal.layout.cells('a').progressOff();
            return;
        }

        var data = {
                    "action" : "spa_scheduling_workbench",
                    "flag" : "k",
                    "injection_withdrawal" : injection_withdrawal,
                    "merge_quantity" : quantity,
                    "location_id" : location_id,
                    "contract_id" : contract_id,
                    "wacog" : wacog,
                    "term_start" : term_start,
                    "convert_uom" : uom,
                    "commodity_name" : commodity_name
                    };
        adiha_post_data('return_array', data, '', '', 'ns_create_injection_withdrawal.create_injection_withdrawal_click_callback', '', '');
    }

    
    ns_create_injection_withdrawal.create_injection_withdrawal_click_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:5000
            });
            
            ns_create_injection_withdrawal.close_window();   
        } else {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:return_value[0][4]
                    });
            return;
        }
    }
    
    ns_create_injection_withdrawal.close_window = function () {
        ns_create_injection_withdrawal.layout.cells('a').progressOff();
        setTimeout('redirect()', 3000);
        
    }
    
    function redirect() {
        parent.reload_all_grids();
        var win_obj = parent.create_deal_window.window("w2");
        win_obj.close();
    }
</script>