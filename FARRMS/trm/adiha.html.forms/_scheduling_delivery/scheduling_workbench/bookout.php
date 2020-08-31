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
$namespace = 'ns_bookout';
$form_name = 'frm_bookout';

$receipt_detail_ids = isset($_REQUEST['receipt_detail_ids']) ? $receipt_detail_ids : 'NULL';
$delivery_detail_ids = isset($_REQUEST['delivery_detail_ids']) ? $delivery_detail_ids : 'NULL';
$process_id = isset($_REQUEST['process_id']) ? $process_id : 'NULL';
$convert_uom = isset($_REQUEST['convert_uom']) ? $_REQUEST['convert_uom'] : 'NULL';
$convert_frequency = isset($_REQUEST['convert_frequency']) ? $_REQUEST['convert_frequency'] : 'NULL';


$xml_user = "EXEC spa_get_regions @user_login_id= '" . $app_user_name . "'";
$def = readXMLURL2($xml_user);
$date_format = $def[0][date_format];
$date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $date_format)));

echo $ini_data = "EXEC spa_scheduling_workbench  @flag='v',@buy_deals='".$receipt_detail_ids."',@sell_deals='".$delivery_detail_ids
            ."',@process_id='".$process_id
            ."',@convert_uom='".$convert_uom
            ."',@convert_frequency='".$convert_frequency."'";
            
$data = readXMLURL2($ini_data);

//initial data for form
$ini_bookoutid = $data[0][bookoutid];
$ini_lineup = $data[0][lineup];
$ini_vol = $data[0][vol];



$term_start = date('Y-m-d');
$month_ini = new DateTime("now");
$today = $month_ini->format('Y-m-d');

$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);

$form_json = '[{type: "settings", position: "label-top"},
				{type: "block", 
    				list: [
                        {type:"input",name:"BookOutID",id:"bookout_id",label:"BookOut ID",value:"'.$ini_bookoutid.'","position":"label-top","tooltip":"BookOut ID","required":"true","inputWidth":"310","validate":"NotEmpty","userdata":{"validation_message":"Please enter BookoutID."}}
                        ]},
            {type: "block", 
    				list: [
                        {"type":"calendar","name":"bookout_date","label":"Bookout Date", "serverDateFormat":"%Y-%m-%d","validate":"NotEmpty","hidden":"false","disabled":"false","value":"'.$today.'","position":"label-top","labelWidth":"auto","inputWidth":"150","tooltip":"date_to","required":"true","dateFormat":"' .$date_format.'","calendarPosition":"bottom","userdata":{"validation_message":"Please select Bookout Date."}},
                        {"type":"newcolumn"},
                        {"type":"input","name":"quantity","id":"quantity","label":"Quantity","disabled":"false",offsetLeft:"10","value":"'.$ini_vol.'","required":"true","position":"label-top","labelWidth":"auto","inputWidth":"150","tooltip":"Quantity","validate":"NotEmpty","userdata":{"validation_message":"Please enter Volume."}}
                        ]},
                    {"type":"newcolumn"},
                {type: "block", 
    				list: [                    
                        {"type":"input","name":"lineup","id":"lineup","label":"Lineup","disabled":"false","value":"'.$ini_lineup.'","position":"label-top","labelWidth":"auto","inputWidth":"310","tooltip":"Lineup",rows:4}
                        ]}
                ]
                ';

$menu_json = '[{id:"save", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save"}]';


echo $layout_obj->attach_form($form_name, 'a');
echo $form_obj->init_by_attach($form_name, $namespace);
echo $form_obj->load_form($form_json);

echo $layout_obj->attach_menu_cell('bookout_menu', 'a');
$menu_object = new AdihaMenu();
echo $menu_object->init_by_attach('bookout_menu', $namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $namespace . '.refresh_export_click');
/* add export end */
	
echo $layout_obj->close_layout();
?>
<script type="text/javascript">	
    ns_bookout.refresh_export_click = function (id) {
        switch(id) {
            
			case 'save':
                var xml_data = '<Root><FormXML ';
                var form_data = ns_bookout.frm_bookout.getFormData();
                var receipt_detail_ids = '<?php echo $receipt_detail_ids; ?>';
                var delivery_detail_ids = '<?php echo $delivery_detail_ids; ?>';
                var process_id = '<?php echo $process_id; ?>';
                
                var bookout_id = ns_bookout.frm_bookout.getItemValue('BookOutID');
                var bookout_date = ns_bookout.frm_bookout.getItemValue('bookout_date', true);
                var quantity = ns_bookout.frm_bookout.getItemValue('quantity', true);
                var max_vol = '<?php echo $ini_vol; ?>';
                var convert_uom = '<?php echo $convert_uom; ?>';
                var convert_frequency = '<?php echo $convert_frequency; ?>';

                if (bookout_id == '' || bookout_id == 'NULL') {
                    dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:"BookoutID cannot be empty."
                    });
                    return;
                }
                
                if (bookout_date == '' || bookout_date == 'NULL') {
                    dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:"Bookout Date cannot be empty."
                    });
                    return;
                }
                
                if (quantity == '' || quantity == 'NULL') {
                    dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:"Quantity cannot be empty."
                    });
                    return;
                }
                
                if (quantity < 0) {
                    dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:"Quantity cannot be negetive."
                    });
                    return;
                }
                
                if (Number(quantity) > Number(max_vol)) {
                    var err_msg = 'Quantity cannot exceed ' + max_vol;
                    dhtmlx.message({
                        title: 'Error',
                        type: "alert-error",
                        text: err_msg
                    });
                    return;
                }
                
                for (var a in form_data) {
                    if (form_data[a] != '' && form_data[a] != null) {
        
                        if (ns_bookout.frm_bookout.getItemType(a) == 'calendar') {
                            value = ns_bookout.frm_bookout.getItemValue(a, true);
                        } else {
                            value = form_data[a];
                        }
                        xml_data +=  a + '="' + value + '" ';
                    }
                }
                
                xml_data += '></FormXML></Root>';
                //xml_data = escapeXML(xml_data);

                var data = {
                            "action" : "spa_scheduling_workbench",
                            "flag" : "b",
                            "process_id" : process_id,
                            "xml_value" : xml_data,
                            "buy_deals" : receipt_detail_ids,
                            "sell_deals" : delivery_detail_ids,
                            'convert_uom' : convert_uom,
                            'convert_frequency' : convert_frequency
                    };
    
                adiha_post_data('return_array', data, '', '', 'ns_bookout.bookout_save_callback', '', '');
                break;
        }
    }
    
    ns_bookout.bookout_save_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });
            
            setTimeout('ns_bookout.close_window()', 1000);   
        } else {
            dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:return_value[0][4]
                    });
            return;
        }
    }
    
    ns_bookout.close_window = function () {
        parent.reload_all_grids();
        var win_obj = parent.bookout_match_window.window("w1");
        win_obj.close();
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 615px;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>

