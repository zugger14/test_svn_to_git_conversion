<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>
</head>
<body>
<html> 
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $function_id = 10202201;
    $rights_post = 10221349;
	
    $calc_id = (isset($_REQUEST["calc_id"]) && $_REQUEST["calc_id"] != '') ? get_sanitized_value($_REQUEST["calc_id"]) : '';
	
	list (
    $has_rights_post
   ) = build_security_rights (
    $rights_post
	);
    
    if ($calc_id != '') {
        $invoice_no_sql = "SELECT civv.counterparty_id,civv.contract_id,cg.contract_name,sc.counterparty_name,civv.as_of_date,civv.settlement_date,CASE WHEN ISNULL(civv.finalized, 'n') = 'n' THEN 'e' ELSE 'f' END [calc_status] FROM calc_invoice_volume_variance civv left join contract_group cg ON cg.contract_id = civv.contract_id
left join source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id WHERE calc_id = " . $calc_id;
        $invoice_data = readXMLURL2($invoice_no_sql);
        $counterparty_id = $invoice_data[0]['counterparty_id'];
        $contract_id = $invoice_data[0]['contract_id'];
        $counterparty_name = $invoice_data[0]['counterparty_name'];
        $contract_name = $invoice_data[0]['contract_name'];
        $as_of_date = $invoice_data[0]['as_of_date'];
        $settlement_date = $invoice_data[0]['settlement_date'];
        $calc_status = $invoice_data[0]['calc_status'];
    }
    
    $namespace = 'sap_settlememt_export';
    $sap_settlememt_layout_obj = new AdihaLayout();

    $layout_json = '[
                        {id: "a", text: "Apply Filter", header: true, collapse:false, height:80},
                        {id: "b", text: "Filter Criteria", header: false}
                    ]';

    echo $sap_settlememt_layout_obj->init_layout('sap_settlememt_layout', '', '2E', $layout_json, $namespace);
    //Attaching Filter form 
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10202201', @template_name='sap_settlememt_export'";
    $header_data = readXMLURL2($xml_file);

    $tab_data = array();
    $form_data = array();
    $tab_id = $header_data[0]['tab_id'];
    if (is_array($header_data) && sizeof($header_data) > 0) {
        foreach ($header_data as $data) {
            $tab_id = 'detail_tab_' . $data[0];

            array_push($tab_data, $data['tab_json']);
            if (!is_array($form_data[$data['tab_id']]))
                $form_data[$data['tab_id']] = array();

            array_push($form_data[$data['tab_id']], $data['form_json']);
             
        }
    }

    $header_tab_data = '[' . implode(",", $tab_data) . ']';
 
    echo $sap_settlememt_layout_obj->attach_tab_cell('sap_settlemnt_tab', 'b', $header_tab_data);
    $tab_obj = new AdihaTab();
    echo $tab_obj->init_by_attach('sap_settlemnt_tab', $namespace);

    $menu_json = '[
                        { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { type: "separator" },
                        //{id:"t1", text:"Export",type: "buttonSelect", img:"export.gif", items:[
                            {id:"excel",type: "button", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", type: "button",text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
                        //]},
                        { type: "separator" },
                        { id: "post", type: "button", img: "process.gif", text: "Post", title: "Post", imgdis:"process_dis.gif", enabled:"'.$has_rights_post.'"},
                        { type: "separator" },
                        { id: "exception", type: "button", img: "action.gif", text: "View Exception", title: "View Exception"},
                        { id: "pivot", type: "button", text: "Pivot", img: "pivot.gif", imgdis: "pivot_dis.gif",enabled: 0}
                    ]';

    $menu_json1 = '[
                        { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { type: "separator" },
                        //{id:"t1", text:"Export", type: "button",img:"export.gif", items:[
                            {id:"excel", text:"Excel",type: "button", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", type: "button",img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
                            { id:"pivot", type: "button", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:0}
                       // ]},
                    ]';


    $menu_json2 = '[
                        { id: "refresh",  type: "button",img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { type: "separator" },
                       // {id:"t1", text:"Export",type: "button", img:"export.gif", items:[
                            {id:"excel",type: "button", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", type: "button",text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
                            { id:"pivot", type: "button", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:0}
                        //]},
                    ]';


    if (is_array($form_data) && sizeof($form_data) > 0) {
        $i=0;
        $j=1;

        foreach ($form_data as $tab_ids => $form_json) {
            $form_name = 'form_' . $tab_ids;
            if($j==1){
            $form_name1 =  $form_name ;  
            }
            $j++;
            
            $inner_layout_obj[$tab_ids] = new AdihaLayout();
            echo $inner_layout_obj[$tab_ids]->init_by_attach('export_layout',$namespace);
            if($i==0){
                //attach layout
                echo $tab_obj->attach_layout('export_layout', 'detail_tab_'.$tab_ids, '2E');
                $form_obj[$tab_id] = new AdihaForm();
                echo $inner_layout_obj[$tab_ids]->attach_form($form_name, 'a');
                echo $inner_layout_obj[$tab_ids]->hide_header('a');
                echo $inner_layout_obj[$tab_ids]->set_cell_height('a','110');
                echo $inner_layout_obj[$tab_ids]->hide_ribbon();
                echo $form_obj[$tab_id]->init_by_attach('form_' . $tab_ids, $namespace);
                echo $form_obj[$tab_id]->load_form($form_json[0]);
                echo $form_obj[$tab_id]->attach_event('', 'onChange', $namespace . '.form_change');
              /* echo $form_obj[$tab_id]->attach_event('', 'onCheckbox', $namespace . '.doOnCheckBoxSelected');
                */ 

                //attach menu
                $menu_object[$tab_id] = new AdihaToolbar();
                echo $inner_layout_obj[$tab_ids]->attach_toolbar_cell('sap_settlememt_toolbar','b');
                echo $menu_object[$tab_id]->init_by_attach('sap_settlememt_toolbar', $namespace);
                echo $menu_object[$tab_id]->load_toolbar($menu_json);
                echo $menu_object[$tab_id]->attach_event('', 'onClick', $namespace . '.sap_settlememt_menu_click');

                //attach grid
                echo $inner_layout_obj[$tab_ids]->attach_grid_cell('settlement_export_grid', 'b');
                echo $inner_layout_obj[$tab_ids]->hide_header('b');
                echo $inner_layout_obj[$tab_ids]->attach_status_bar("b", true);
                $grid_obj = new GridTable('settlement_export_grid');        
                echo $grid_obj->init_grid_table('settlement_export_grid', $namespace,'');
                echo $grid_obj->set_column_auto_size();
                //echo $grid_obj->set_search_filter(true, "");
                echo $grid_obj->enable_paging(50, 'pagingArea_b', 'true');       
                echo $grid_obj->enable_column_move();
                echo $grid_obj->enable_multi_select();
                echo $grid_obj->return_init();
             
            }else{
                //attach layout
                echo $tab_obj->attach_layout('export_layout', 'detail_tab_'.$tab_ids, '3E');
                echo $inner_layout_obj[$tab_ids]->attach_form($form_name, 'a');
                echo $inner_layout_obj[$tab_ids]->set_cell_height('a','110');
				echo $inner_layout_obj[$tab_ids]->set_cell_height('c','0');
                echo $inner_layout_obj[$tab_ids]->hide_header('a');
				echo $inner_layout_obj[$tab_ids]->hide_header('c');
                echo $form_obj[$tab_id]->init_by_attach('form_' . $tab_ids, $namespace);
                echo $form_obj[$tab_id]->load_form($form_json[0]);
                //echo $form_obj[$tab_id]->attach_event('', 'onChange', $namespace . '.form_changes');

                //attach menu 
                echo $inner_layout_obj[$tab_ids]->attach_toolbar_cell('sap_settlememt_toolbar1','b');
                echo $inner_layout_obj[$tab_ids]->set_text('b','History');
                /*echo $inner_layout_obj[$tab_ids]->set_cell_height('b','40');
                echo $inner_layout_obj[$tab_ids]->set_cell_height('c','40');*/
                echo $menu_object[$tab_id]->init_by_attach('sap_settlememt_toolbar1', $namespace);
                echo $menu_object[$tab_id]->load_toolbar($menu_json1);
                echo $menu_object[$tab_id]->attach_event('', 'onClick', $namespace . '.sap_settlememt_menu_click1'); 
				
				/*
                echo $inner_layout_obj[$tab_ids]->attach_toolbar_cell('sap_settlememt_toolbar2','c');
                echo $inner_layout_obj[$tab_ids]->set_text('c','Item');
                echo $menu_object[$tab_id]->init_by_attach('sap_settlememt_toolbar2', $namespace);
                echo $menu_object[$tab_id]->load_toolbar($menu_json2);
                echo $menu_object[$tab_id]->attach_event('', 'onClick', $namespace . '.sap_settlememt_menu_click2');
*/
                //attach grid
                echo $inner_layout_obj[$tab_ids]->attach_grid_cell('settlement_export_header', 'b');
                echo $inner_layout_obj[$tab_ids]->attach_status_bar("c", true);
                $grid_obj = new GridTable('settlement_export_header');        
                echo $grid_obj->init_grid_table('settlement_export_header', $namespace,''); 
                echo $grid_obj->set_column_auto_size();
                echo $grid_obj->enable_paging(50, 'pagingArea_c', 'true');       
                echo $grid_obj->enable_column_move();
                echo $grid_obj->enable_multi_select();
                echo $grid_obj->return_init();
				
				/*
                echo $inner_layout_obj[$tab_ids]->attach_grid_cell('settlement_export_history', 'c');
                echo $inner_layout_obj[$tab_ids]->attach_status_bar("c", true);
                $grid_obj = new GridTable('settlement_export_history');        
                echo $grid_obj->init_grid_table('settlement_export_history', $namespace,'');
                echo $grid_obj->set_column_auto_size();
                echo $grid_obj->enable_paging(50, 'pagingArea_c', 'true');       
                echo $grid_obj->enable_column_move();
                echo $grid_obj->enable_multi_select();
                echo $grid_obj->return_init();   
				*/
            }

            $i++;
        }

    }

    echo $sap_settlememt_layout_obj->close_layout();
    ?> 

</body>

    <script type="text/javascript">
		var initial_type_status = 0;
        $(function(){
			/*
			//var obj = sap_settlememt_export.sap_settlemnt_tab.cells('b').getAttachedObject();
			sap_settlememt_export.sap_settlemnt_tab.forEachTab(function(tab){
				var tab_name = tab.getText();
				if (tab_name == 'Export History') {
					var obj = tab.getAttachedObject();
					obj.cells('b').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_b"></div>'
                            });
				}
			});
			sap_settlememt_export.settlement_export_history.enablePaging(true,10,5,"pagingArea_b");
			*/
            var form_name = '<?php echo ($form_name1); ?>';
            var form_name1 = '<?php echo ($form_name); ?>';
            attach_browse_event('sap_settlememt_export.'+form_name);
            attach_browse_event('sap_settlememt_export.'+form_name1);
            sap_settlememt_export.sap_settlememt_toolbar.disableItem('exception');
          /*  sap_settlememt_export.sap_settlememt_toolbar2.disableItem('refresh');
            sap_settlememt_export.sap_settlememt_toolbar2.disableItem('excel');
            sap_settlememt_export.sap_settlememt_toolbar2.disableItem('pdf'); */
            
            var calc_id = '<?php echo $calc_id; ?>';
            if (calc_id != '') {
                var counterparty_id = '<?php echo $counterparty_id; ?>';
                var contract_id = '<?php echo $contract_id; ?>';
                var counterparty_name = '<?php echo $counterparty_name; ?>';
                var contract_name = '<?php echo $contract_name; ?>';
                var as_of_date = '<?php echo $as_of_date; ?>';
                var settlement_date = '<?php echo $settlement_date; ?>';
                var calc_status = '<?php echo $calc_status; ?>';
                
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('contract_id', contract_id);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('counterparty_id', counterparty_id);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('label_contract_id', contract_name);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('label_counterparty_id', counterparty_name);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('as_of_date', as_of_date);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('invoice_date', settlement_date);
                sap_settlememt_export.<?php echo ($form_name1); ?>.setItemValue('type', calc_status);
                
                refresh_sap_export_grid();
            }
            
            
            var myPop = new dhtmlXPopup({
                                            toolbar: sap_settlememt_export.sap_settlememt_toolbar,
                                            id: 'exception'
                                        });
                myPop.attachEvent("onShow",function(){
				
				var process_id = sap_settlememt_export.settlement_export_grid.cells2(1, 16).getValue();
                    var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
                    var value_name = type_name.getSelectedValue();
                    var counterparty_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('counterparty_id');
                    counterparty_id = counterparty_id.toString();
                    var contract_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('contract_id');
                    contract_id = contract_id.toString();
                    var as_of_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('as_of_date', true);
                    var invoice_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('invoice_date', true);
                    var myGrid = myPop.attachGrid(800,350);
                    myGrid.setHeader("Missing Column,Counterparty, Contract Name,Recommendation"); 
                    myGrid.init();
				
                    if (value_name == 'E'){
                        
                        var sql_param = {
                                            "action": "spa_SettlementExport_estimate",
                                            "flag":"h",
                                            "counterparty_id": counterparty_id,
                                            "contract_id": contract_id,
                                            "as_of_date": as_of_date,
                                            "invoice_date": invoice_date,
                                            "grid_type" : "g",
											"process_id" : process_id											
                                        };
                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                        myGrid.clearAndLoad(sql_url);

                    } else {

                        var sql_param = {
                                            "action": "spa_SettlementExport_final",
                                            "flag":"i",
                                            "counterparty_id": counterparty_id,
                                            "contract_id": contract_id,
                                            "as_of_date": as_of_date,
                                            "invoice_date": invoice_date,
                                            "grid_type" : "g",
											"process_id" : process_id
                                        };
                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param; 
                        myGrid.clearAndLoad(sql_url);
					
                    }
               });

            var filter_obj = sap_settlememt_export.sap_settlememt_layout.cells("a").attachForm();
            var layout_b_obj = sap_settlememt_export.sap_settlememt_layout.cells("b");
            load_form_filter(filter_obj, layout_b_obj, 10202201, 2);
            sap_settlememt_export.sap_settlememt_layout.cells("a").collapse();

        });

        sap_settlememt_export.sap_settlememt_menu_click = function(id){
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";  
            var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
            var value_name = type_name.getSelectedValue();
            var counterparty_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('counterparty_id');
            counterparty_id = counterparty_id.toString();
            var contract_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('contract_id');
            contract_id = contract_id.toString();
            var as_of_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('as_of_date', true);
            var invoice_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('invoice_date', true);
             var ready_to_send = sap_settlememt_export.<?php echo ($form_name1); ?>.isItemChecked('ready_to_send');
			 
               
            switch(id){
                case "refresh":
                    refresh_sap_export_grid();
                    break;
                case "post":
                    export_settlement_process();
                    break;
                case "excel":
                    sap_settlememt_export.settlement_export_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                
                break;

                case "pdf":
                    sap_settlememt_export.settlement_export_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                
                break;

                case "exception":

                 /*var exception_popup = new dhtmlXPopup();
                 exception_popup.attachHTML('<iframe style="width:700px;height:400px;" src="../../../adiha.html.forms/_settlement_billing/sap_export/sap.exception.php?counterparty_id= ' + counterparty_id +'"></iframe>');
                 exception_popup.show(300,150,50,50);
*/
                 
                   
                break;
                case 'pivot':
                    var grid_obj = sap_settlememt_export.settlement_export_grid;
                    open_grid_pivot(grid_obj, 'export_gl_entries_grid', 1, pivot_exec_spa, 'Export Gl Entries');
                break;

                default:
                    dhtmlx.alert({
                        title:'Sorry! <font size="5">&#x2639 </font>',
                        type:"alert-error",
                        text:"Under Maintainence! We will be back soon!"
                    });
                break;
            }
        }

        sap_settlememt_export.sap_settlememt_menu_click1 = function(id){  
		
            var type_names = sap_settlememt_export.<?php echo ($form_name); ?>.getCombo('type2');
            var counterparty = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('counterparty');
            counterparty = counterparty.toString();
            var contract = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('contract');
            contract= contract.toString();
            var as_of_date_from = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('as_of_date_from', true);
            var as_of_date_to = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('as_of_date_to', true);
            var invoice_date_history = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('invoice_date_history', true);
            
            switch(id){
                case "refresh":
				
/*
                if(counterparty == ''){
                    show_messagebox('Please select counterparty');
                    return;
                } else if(contract == ''){
                    show_messagebox('Please select Contract');
                    return;
                } else */
//				if(as_of_date_from == ''){
//                    show_messagebox('Please select As of Date');
//                    return;
//                } else if(invoice_date_history == ''){
//                    show_messagebox('Please select Invoice Date ');
//                    return;
//                }
                var status = validate_form(sap_settlememt_export.<?php echo ($form_name); ?>);
                if(!status) {
                    return;
                }

                grid_show(type_names.getSelectedValue());
                sap_settlememt_export.settlement_export_header.clearAll();

                break;

                case "excel":
                
                sap_settlememt_export.settlement_export_header.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
               
                break;

                case "pdf":
                sap_settlememt_export.settlement_export_header.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;

                case 'pivot':
                    var grid_obj = sap_settlememt_export.settlement_export_header;
                    open_grid_pivot(grid_obj, 'export_gl_entries_history_grid', 1, pivot_exec_spa, 'Export Gl Entries History');
                break;

                default:
                    dhtmlx.alert({
                        title:'Sorry! <font size="5">&#x2639 </font>',
                        type:"alert-error",
                        text:"Under Maintainence! We will be back soon!"
                    });
                break;

                
            }
        }

        sap_settlememt_export.sap_settlememt_menu_click2 = function(id){  
            var type_names = sap_settlememt_export.<?php echo ($form_name); ?>.getCombo('type2');
            switch(id){
                case "refresh":
                /*grid_show(type_names.getSelectedValue());
                sap_settlememt_export.settlement_export_history.clearAll();
                grid_show(type_names.getSelectedValue());*/

                break;

                case "excel":
                
      
                sap_settlememt_export.settlement_export_history.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;

                case "pdf":
               
                sap_settlememt_export.settlement_export_history.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;

                default:
                    dhtmlx.alert({
                        title:'Sorry! <font size="5">&#x2639 </font>',
                        type:"alert-error",
                        text:"Under Maintainence! We will be back soon!"
                    });
                break;

                
            }
        }

        sap_settlememt_export.form_change = function(name, value){
            if(name=='type'){
                var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
                var value_name = type_name.getSelectedValue();
                //grid_show(value);
                if (value_name == 'f'){
                    sap_settlememt_export.<?php echo ($form_name1); ?>.hideItem('ready_to_send');
                } else{
                    sap_settlememt_export.<?php echo ($form_name1); ?>.hideItem('ready_to_send');
                }
				
				if(initial_type_status == 1) {
					sap_settlememt_export.sap_settlememt_toolbar.disableItem('exception');
					sap_settlememt_export.settlement_export_grid.clearAll();
				}
            }
            initial_type_status = 1;

            
           
           
        }

        sap_settlememt_export.form_changes = function(name, value){
            if(name=='type2'){
                grid_show(value);
                sap_settlememt_export.settlement_export_header.clearAll();
                //sap_settlememt_export.settlement_export_history.clearAll();
            }
           
        }

         sap_settlememt_export.doOnCheckBoxSelected = function(rID, cInd, state){
     
             if (state=='1'){
        alert("date approved");
    }

        
         }

        function grid_show(value) {
			sap_settlememt_export.sap_settlemnt_tab.forEachTab(function(tab){
				var tab_name = tab.getText();
				var obj = tab.getAttachedObject();
				obj.progressOn();
			});
			var counterparty = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('counterparty');
            counterparty = counterparty.toString();
            var contract = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('contract');
            contract= contract.toString();
			
            var as_of_date_from = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('as_of_date_from', true);
            //v/ar as_of_date_to = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('as_of_date_to', true);
            var invoice_date_history = sap_settlememt_export.<?php echo ($form_name); ?>.getItemValue('invoice_date_history', true);
		
            if(value == "E") {
                var sql_param = {
                    "action": "spa_SettlementExport_history",
                    "flag": "s",
                    "counterparty_id": counterparty,
                    "contract_id": contract,
                    "as_of_date": as_of_date_from,
                    "invoice_date": invoice_date_history,
                    "grid_type" : "g"            
                };

                pivot_exec_spa = "EXEC spa_SettlementExport_history @flag='s', @counterparty_id='" +  counterparty 
                        + "', @contract_id='" +  contract
                        + "', @as_of_date='" +  as_of_date_from
                        + "', @invoice_date='" +  invoice_date_history + "'";

                sql_param = $.param(sql_param);
				var sql_url = js_data_collector_url + "&" + sql_param;  
                sap_settlememt_export.settlement_export_header.loadXML(sql_url, function() {
					close_progress();
				});
                
            } else {
				
                var sql_param = {
                    "action": "spa_SettlementExport_history",
                    "flag": "a",
                    "counterparty_id": counterparty,
                    "contract_id": contract,
                    "as_of_date": as_of_date_from,
                    "invoice_date": invoice_date_history,
                    "grid_type" : "g"            
                };

                pivot_exec_spa = "EXEC spa_SettlementExport_history @flag='a', @counterparty_id='" +  counterparty 
                        + "', @contract_id='" +  contract
                        + "', @as_of_date='" +  as_of_date_from
                        + "', @invoice_date='" +  invoice_date_history + "'";

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param; 
				sap_settlememt_export.settlement_export_header.loadXML(sql_url, function() {
					close_progress();
				});           
            }


            sap_settlememt_export.sap_settlememt_toolbar1.enableItem('pivot');

            sap_settlememt_export.settlement_export_header.attachEvent("onRowDblClicked", function(rId,cInd){            
                var selected_data = sap_settlememt_export.settlement_export_header.getSelectedRowId();
                sap_settlememt_export.sap_settlememt_toolbar2.enableItem('refresh');
                sap_settlememt_export.sap_settlememt_toolbar2.enableItem('excel');
                sap_settlememt_export.sap_settlememt_toolbar2.enableItem('pdf');
                
                    if(selected_data != null && value == "E"){
                        var sql_params = {
                            "action": "spa_SettlementExport_history",
                            "flag": "m",
                            "counterparty_id": counterparty,
                            "contract_id": contract,
                            "as_of_date": as_of_date_from,
                            "invoice_date": as_of_date_to,
                            "grid_type" : "g"            
                        };
                        sql_params = $.param(sql_params);
                        var sql_path = js_data_collector_url + "&" + sql_params;  
                        sap_settlememt_export.settlement_export_history.clearAndLoad(sql_path);
                        value = '';

                    } else if(selected_data != null && value == "f"){
                        var sql_paramse = {
                            "action": "spa_SettlementExport_history",
                            "flag": "n",
                            "counterparty_id": counterparty,
                            "contract_id": contract,
                            "as_of_date": as_of_date_from,
                            "invoice_date": invoice_date_history,
                            "grid_type" : "g"            
                        };
                        sql_paramse = $.param(sql_paramse);
                        var sql_path1 = js_data_collector_url + "&" + sql_paramse;  
                        sap_settlememt_export.settlement_export_history.clearAndLoad(sql_path1);
                        value = '';

                    } 
            }); 
			sap_settlememt_export.export_layout.cells('b').progressOff();
            
        }
		
		function close_progress() {
			sap_settlememt_export.sap_settlemnt_tab.forEachTab(function(tab){
				var tab_name = tab.getText();
				var obj = tab.getAttachedObject();
				obj.progressOff();
			});
		}
		
        function checked_grid(){
			var status;
		
			var process_id = sap_settlememt_export.settlement_export_grid.cells(1, 16).getValue();
			  var counterparty_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('counterparty_id');
                counterparty_id = counterparty_id.toString();
                var contract_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('contract_id');
                contract_id = contract_id.toString();
                var as_of_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('as_of_date', true);
                var invoice_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('invoice_date', true);
				var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
			var cmb_value = type_name.getSelectedValue();
			var sql_paramse;
			
			if(cmb_value == 'f'){
			 sql_paramse = {
								"action": "spa_SettlementExport_final",
								"flag": "p",
								"counterparty_id": counterparty_id,
								"contract_id": contract_id,
								"as_of_date":as_of_date,
								"invoice_date":invoice_date,
								"process_id": process_id
							};
							
							//adiha_post_data("return_json",sql_paramse,"","","check_grid_callback", "");
				}
				else{
					sql_paramse = {
								"action": "spa_SettlementExport_estimate",
								"flag": "p",
								"counterparty_id": counterparty_id,
								"contract_id": contract_id,
								"as_of_date":as_of_date,
								"invoice_date":invoice_date,
								"process_id": process_id
							};
							
				}
			
			$.ajax({
				type: "POST",
				dataType: "json",
				url: js_form_process_url,
				async: false,
				data: sql_paramse,
				success: function(result) { 
					return_data = result['json'];
					status = return_data[0].message;   
					
				}
			});
		        
			return status;
        }
		
		function check_grid_callback(result){
			 
			var return_data = JSON.parse(result);
			
		
		}

        function export_settlement_process() {
           
                var counterparty_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('counterparty_id');
                counterparty_id = counterparty_id.toString();
                var contract_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('contract_id');
                contract_id = contract_id.toString();
                var as_of_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('as_of_date', true);
                var invoice_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('invoice_date', true);
        
                //Check if there is data in grid
                var attach_grid = sap_settlememt_export.export_layout.cells('b').getAttachedObject();
                if (attach_grid == undefined) {
                    show_messagebox('No data in grid');
                    return;
                }
                
                var row_count = sap_settlememt_export.settlement_export_grid.getRowsNum();
                if (row_count == 0) {
                    show_messagebox('No data in grid');
                    return;
                }
            // for checking seleted rows in grid
                /*var selected_data = sap_settlememt_export.settlement_export_grid.getSelectedRowId();
                if(selected_data == null){
                    show_messagebox('Select Data in grid');
                    return;
                }*/
			var grid_result	= checked_grid();
			
            if(grid_result == "true") {
			
                if (sap_settlememt_export.settlement_export_grid != undefined) {
                    if (sap_settlememt_export.settlement_export_grid.getSelectedRowId() != null) {
                        var export_grid_row_id = sap_settlememt_export.settlement_export_grid.getSelectedRowId();
                        var selected_row_array_d = export_grid_row_id.split(',');
                        
                        for(var i = 0; i < selected_row_array_d.length; i++) {
                    
                            if (i == 0) {
                                grid_row_id = sap_settlememt_export.settlement_export_grid.cells(selected_row_array_d[i], 1).getValue();
                            } else {
                                grid_row_id = grid_row_id + ',' + sap_settlememt_export.settlement_export_grid.cells(selected_row_array_d[i], 1).getValue();
                            }
                        }
                    } else {
                        grid_row_id = '';
                    }
                }
                            
                var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
                var cmb_value = type_name.getSelectedValue();
				var process_id = sap_settlememt_export.settlement_export_grid.cells(1, 16).getValue();
                var param = 'call_from=sap_settlememt_export&gen_as_of_date=1&batch_type=r&as_of_date=' + as_of_date;
                var title = 'Post Settlement Export Report';
                if(cmb_value == 'f'){
                 var exec_call = "EXEC spa_SettlementExport_final " +
                                singleQuote('b') + ", " + 
                                singleQuote(counterparty_id) + ", " +
                                singleQuote(contract_id) + ", " +
                                singleQuote(as_of_date) + ", " +
                                singleQuote(invoice_date) + ", " +
                                singleQuote(cmb_value) + ","+
								singleQuote(process_id); 
                }
                else if(cmb_value == 'E'){
                    var exec_call = "EXEC spa_SettlementExport_estimate " + 
                                singleQuote('b') + ", " +
                                singleQuote(counterparty_id) + ", " +
                                singleQuote(contract_id) + ", " +
                                singleQuote(as_of_date) + ", " +
                                singleQuote(invoice_date) + ", " +
                                singleQuote(cmb_value)+ ","+
								singleQuote(process_id);

                }
                
               
                adiha_run_batch_process(exec_call, param, title);
            } else {
                show_messagebox(grid_result);
            }

        }
        
        function refresh_sap_export_grid() {
            var type_name = sap_settlememt_export.<?php echo ($form_name1); ?>.getCombo('type');
            var value_name = type_name.getSelectedValue();
            var counterparty_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('counterparty_id');
            counterparty_id = counterparty_id.toString();
            var contract_id = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('contract_id');
            contract_id = contract_id.toString();
            var as_of_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('as_of_date', true);
            var invoice_date = sap_settlememt_export.<?php echo ($form_name1); ?>.getItemValue('invoice_date', true);
            var ready_to_send = sap_settlememt_export.<?php echo ($form_name1); ?>.isItemChecked('ready_to_send');
            var calc_id = '<?php echo $calc_id; ?>';
            /*if(ready_to_send == true){
                    show_messagebox('Please ');
                    return;
                } */
              /*  if(counterparty_id == ''){
                    show_messagebox('Please select counterparty');
                    return;
                } else if(contract_id == ''){
                    show_messagebox('Please select Contract');
                    return;
                } else */

                var status = validate_form(sap_settlememt_export.<?php echo ($form_name1); ?>);
                if(!status) {
                    return;
                }
//				if(as_of_date == ''){
//                    show_messagebox('Please select As of Date');
//                    return;
//                } else if(invoice_date == ''){
//                    show_messagebox('Please select Invoice Date');
//                    return;
//                }

                sap_settlememt_export.sap_settlememt_toolbar.enableItem('exception');

                
                  /*  if (value_name == "E" && row_count == 0) {
                        show_messagebox('There is no data for Estimate');
                        return;
                    } else if (value_name == "f" && row_count == 0) {
                        show_messagebox('There is no data for Final');
                    }*/
				sap_settlememt_export.sap_settlemnt_tab.forEachTab(function(tab){
					var tab_name = tab.getText();
					var obj = tab.getAttachedObject();
					obj.progressOn();
				});
					
                if(value_name == "E") {
					//sap_settlememt_export.settlement_export_grid.setColumnHidden(14,true);
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(13,true); 
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(12,true);
                    var sql_param = {
                                    "action": "spa_SettlementExport_estimate",
                                    "flag":"s",
                                    "counterparty_id": counterparty_id,
                                    "contract_id": contract_id,
                                    "as_of_date": as_of_date,
                                    "invoice_date": invoice_date,
                                    "calc_id": calc_id,
                                    "grid_type" : "g"           
                                    };

                    pivot_exec_spa = "EXEC spa_SettlementExport_estimate @flag='s', @counterparty_id='" +  counterparty_id 
                            + "', @contract_id='" +  contract_id
                            + "', @as_of_date='" +  as_of_date
                            + "', @invoice_date='" +  invoice_date
                            + "', @calc_id='" +  calc_id + "'";

                    sap_settlememt_export.sap_settlememt_toolbar.enableItem('pivot');

                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param; 
                    sap_settlememt_export.settlement_export_grid.clearAndLoad(sql_url, function(){
						close_progress();
					});

                } else if(value_name == "f" && ready_to_send ==false ) {
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(14,true);
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(13,true); 
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(12,true);
                    var sql_param = {
                                    "action": "spa_SettlementExport_final",
                                    "flag":"s",
                                    "counterparty_id": counterparty_id,
                                    "contract_id": contract_id,
                                    "as_of_date": as_of_date,
                                    "invoice_date": invoice_date,
                                    "calc_id": calc_id,
                                    "grid_type" : "g"
									
                                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    sap_settlememt_export.settlement_export_grid.clearAndLoad(sql_url, function() {
						close_progress();
					});             
                } else if(value_name == "f" && ready_to_send ==true ) {
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(14,true);
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(13,true); 
                    //sap_settlememt_export.settlement_export_grid.setColumnHidden(12,true);
                    var sql_param = {
                                    "action": "spa_SettlementExport_final",
                                    "flag":"s",
                                    "counterparty_id": counterparty_id,
                                    "contract_id": contract_id,
                                    "as_of_date": as_of_date,
                                    "invoice_date": invoice_date,
                                    "calc_id": calc_id,
                                    "ready_to_send":"20706",
                                    "grid_type" : "g"  								
                                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    sap_settlememt_export.settlement_export_grid.clearAndLoad(sql_url, function() {
						close_progress();
					});          
                }      
 
                //grid_show(type_name.getSelectedValue());
        }

    </script> 
</html>

