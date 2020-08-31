<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    <?php
        $popup_obj = new AdihaPopup();
        $application_function_id = 10103300;        
        $form_namespace = 'invoice_glcode';
        
        $rights_gl_group_detail_insert = 10103310;
        $rights_gl_group_detail_delete = 10103311;
        
        
        list (            
            $has_rights_gl_group_detail_insert,
            $has_rights_gl_group_detail_delete
        ) = build_security_rights(
            $rights_gl_group_detail_insert, 
            $rights_gl_group_detail_delete   
        );
        
        
        $enable_gl_group_detail_insert = ($has_rights_gl_group_detail_insert) ? 'false' : 'true';
        $enable_gl_group_detail_delete = ($has_rights_gl_group_detail_delete) ? 'false' : 'true';
               
        $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
        $form_obj->define_grid("invoice_glcode", "EXEC spa_get_adjustment_defaultGLCode 'f'");
        $form_obj->define_custom_functions('', '', '', 'invoice_glcode_cmplt_form_load');
        echo $form_obj->init_form('GL Group', 'Setup GL Group');
       
        $toolbar_json_array = array(
                                array(
                                    'json' => '
                                    {id:"t1", text:"Edit", img:"edit.gif", 
                                        items:[
                                                {id: "new", img: "new.gif", imgdis:"new_dis.gif", text: "Add", title: "Add", disabled: ' . $enable_gl_group_detail_insert . '},
                                                {id: "delete", img: "trash.gif", imgdis:"trash_dis.gif", text: "Delete", title: "Delete", disabled: true},
                                                
                                            ]
                                    },
                                    {id:"t2", text:"Export", img:"export.gif", 
                                        items:[
                                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                         ]
                                    }',
                                    'on_click' => 'invoice_glcode.invoice_grid_toolbar_click'
                                    ,'on_select' => "delete|$enable_gl_group_detail_insert,edit|$enable_gl_group_detail_insert"
                                    
                                                                        
                                 )
                         );
        echo $form_obj->set_grid_menu_json($toolbar_json_array, true);
        echo $form_obj->close_form();
    ?>
    <body>
    </body>
    <script type="text/javascript">  
        var cc_detail_window;        
        var changed_row_ids = '';
        var invoice_grid_id = '';
		
        var right = '<?= $enable_gl_group_detail_insert ?>';
		var has_rights_gl_group_detail_insert = '<?php echo $has_rights_gl_group_detail_insert;?>';
        var has_rights_gl_group_detail_delete = '<?php echo $has_rights_gl_group_detail_delete;?>';

        invoice_glcode.invoice_glcode_cmplt_form_load = function(win, tab_id) {
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var tab_name = win.tabbar.tabs(tab_id).getText();

            if (tab_name != 'New') { 
                $.each(detail_tabs, function(index,value) {
                    var tab_name = tab_obj.tabs(value).getText();
                    layout_obj = tab_obj.cells(value).getAttachedObject();

                    layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_id = attached_obj.getUserData("", "grid_id");

                            if (grid_id == 'adjustment_default_gl_codes_detail') {
                                attached_obj.attachEvent("onRowDblClicked", function(id,ind) {
                                    if (has_rights_gl_group_detail_insert) {
                                        invoice_glcode_detail();
                                    }
                                });
                            }

                        }

                    });

                });
            
            }

        }

        function invoice_glcode_detail() {
            unload_window();
            var row_data = new Array();                                        
            row_data = invoice_glcode.get_seleted_row_data();
            //detail_id = row_data[0];
            var param = 
                        '&detail_id=' + row_data[0] +  
                        '&default_gl_id=' + row_data[1] +
                        '&term_start=' + row_data[2] +   
                        '&term_end=' + row_data[3] +   
                        '&debit_gl_number=' + row_data[4] +   
                        '&credit_gl_number=' + row_data[5] +   
                        '&netting_debit_gl_number=' + row_data[6] +   
                        '&netting_credit_gl_number=' + row_data[7] +   
                        '&debit_gl_number_minus=' + row_data[8] +  
                        '&credit_gl_number_minus=' + row_data[9] +      
                        '&netting_debit_gl_number_minus=' + row_data[10] +  
                        '&netting_credit_gl_number_minus=' + row_data[11] +  
                        '&debit_volume_multiplier=' + row_data[12] +  
                        '&credit_volume_multiplier=' + row_data[13] +  
                        '&debit_remark=' + row_data[14] +  
                        '&credit_remark=' + row_data[15] +  
                        '&uom_id=' + row_data[16];   

            cc_detail_window = new dhtmlXWindows();

            new_win = cc_detail_window.createWindow('w1', 0, 0,'', '', '', 500, 1200);
            var text = "Detail";
            new_win.setText(text);
            new_win.maximize();
            new_win.setModal(true);
            var url = 'define.invoice.glcode.detail.iu.php?flag=u' + param + '&right='+ right;
            new_win.attachURL(url, false, true);
        }
        
        invoice_glcode.invoice_grid_toolbar_click = function(id) {
            var tab_id = new Array();
            var default_gl_id = '';
            var active_tab_id = invoice_glcode.tabbar.getActiveTab();
            tab_id = active_tab_id.split('_');
     
            default_gl_id = tab_id[1];
                              
            switch(id) {
                case 'new':
                     unload_window();
                    
                    cc_detail_window = new dhtmlXWindows();
                    
                    new_win = cc_detail_window.createWindow('w1', 0, 0,'', '', '', 500,1200);
                    var text = "Detail";
                    new_win.setText(text);
                    new_win.maximize();
                    new_win.setModal(true);
        	        var url = 'define.invoice.glcode.detail.iu.php?flag=i&default_gl_id=' + default_gl_id + '&right='+ right;
                    new_win.attachURL(url, false, true);
                                   
                break;
                case 'delete':  
                    
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: "Are you sure you want to delete?",
                        callback: function(result) {
                            if (result) {
                                var cc_grid_obj = new dhtmlXGridObject;
                                cc_grid_obj = invoice_glcode.get_grid_obj();  
                                       
                                var del_ids = cc_grid_obj.getSelectedRowId();
                                var previously_xml = cc_grid_obj.getUserData("", "deleted_xml");
                                var grid_xml = "";
                                if (previously_xml != null) {
                                    grid_xml += previously_xml
                                }
                                var del_array = new Array();
                                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();
                                $.each(del_array, function(index, value) {
                                    if ((cc_grid_obj.cells(value, 0).getValue() != "") || (cc_grid_obj.getUserData(value, "row_status") != "")) {
                                        grid_xml += "<GridRow ";
                                        for (var cellIndex = 0; cellIndex < cc_grid_obj.getColumnsNum(); cellIndex++) {
                                            grid_xml += " " + cc_grid_obj.getColumnId(cellIndex) + '="' + cc_grid_obj.cells(value, cellIndex).getValue() + '"';
                                        }
                                        grid_xml += " ></GridRow> ";
                                    }
                                });
                                cc_grid_obj.setUserData("", "deleted_xml", grid_xml);
                                cc_grid_obj.deleteSelectedRows();
                            }                     
        	           }
                 });    
                    
                break;
                case "excel":
                    var cc_grid_obj = new dhtmlXGridObject;
                    cc_grid_obj = invoice_glcode.get_grid_obj();         
                    cc_grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                  
                    break;
                case "pdf":
                    
                    var cc_grid_obj = new dhtmlXGridObject;
                    cc_grid_obj = invoice_glcode.get_grid_obj();         
                    cc_grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            
                    break;
                default:
                    show_messagebox(id);                    
            }
        }
        
        /**
         * [unload_window Window unload function]
         */
        function unload_window() {
            if (cc_detail_window != null && cc_detail_window.unload != null) {
                cc_detail_window.unload();
                cc_detail_window = w1 = null;
            }
        }
                
        invoice_glcode.get_seleted_row_data = function (){
            var cc_grid_obj = new dhtmlXGridObject;
            var row_data = new Array();
            cc_grid_obj = invoice_glcode.get_grid_obj();
            
            var selected_row = cc_grid_obj.getSelectedRowId();
            
            if (selected_row == null) {                               
                show_messagebox('Please select a row from grid!');
                return;
            }
            
            
            cc_grid_obj.forEachCell(selected_row, function(cellObj, ind){                                
                row_data[ind] = cellObj.getValue();                
                                         
            });
            
            return row_data;
        } 
        
        
        invoice_glcode.get_grid_obj = function (){
            var cc_grid_obj = new dhtmlXGridObject;
            var tab_id = invoice_glcode.tabbar.getActiveTab();
            var win = invoice_glcode.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
                      
            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
    
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        cc_grid_obj = attached_obj;
                    }
                  
                });
            });
            
            return cc_grid_obj;            
        }
        
        
         invoice_glcode.get_tab_name = function (){
            var tab_name = '';
            var tab_id = invoice_glcode.tabbar.getActiveTab();
            var win = invoice_glcode.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
                      
            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
    
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                       tab_name = attached_obj.getCombo('adjustment_type_id').getComboText();
                    }
                });
            });
            return tab_name;
        }
           
        invoice_glcode.refresh_grid_invoice = function (){
            var selected_row = invoice_glcode.grid.getSelectedRowId();
            var default_gl_id = invoice_glcode.grid.cells(selected_row, 0).getValue();  
            sp_url = {"sp_string":"exec [spa_get_adjustment_defaultGLCode_detail] @flag='g',@default_gl_id='" + default_gl_id + "'"}
            result = adiha_post_data("return_data", sp_url, "", "", "invoice_glcode.refresh_grid_invoice_callback");
        } 
         
        invoice_glcode.refresh_grid_invoice_callback = function(result) { 
            attached_obj.clearAll();
            attached_obj.parse(result, "js");
        }
        
        invoice_glcode.callback_modified_detail = function (flag, filter_param) {
         
            var tab_id = invoice_glcode.tabbar.getActiveTab();
            var win = invoice_glcode.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            //object_id = ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var new_id = (new Date()).valueOf();
            
            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        row_id = attached_obj.getSelectedRowId()
                        
                        //if (attached_obj.getUserData("", "changed_ids") !== null)
//                            changed_row_ids = attached_obj.getUserData("", "changed_ids");
                        
                        if (flag == 'u') {
                            
                            attached_obj.cells(row_id, 2).setValue(filter_param['term_start']);
                            attached_obj.cells(row_id, 3).setValue(filter_param['term_end']);
                            attached_obj.cells(row_id, 4).setValue(filter_param['debit_gl_number']);
                            attached_obj.cells(row_id, 5).setValue(filter_param['credit_gl_number']);
                            attached_obj.cells(row_id, 6).setValue(filter_param['netting_debit_gl_number']);
                            attached_obj.cells(row_id, 7).setValue(filter_param['netting_credit_gl_number']);
                            attached_obj.cells(row_id, 8).setValue(filter_param['debit_gl_number_minus']);
                            attached_obj.cells(row_id, 9).setValue(filter_param['credit_gl_number_minus']);
                            attached_obj.cells(row_id, 10).setValue(filter_param['netting_debit_gl_number_minus']);
                            attached_obj.cells(row_id, 11).setValue(filter_param['netting_credit_gl_number_minus']);
                            attached_obj.cells(row_id, 12).setValue((filter_param['debit_volume_multiplier'] == '')? 1 : filter_param['debit_volume_multiplier']);
                            attached_obj.cells(row_id, 13).setValue((filter_param['credit_volume_multiplier'] == '')? 1 : filter_param['credit_volume_multiplier']);
                            attached_obj.cells(row_id, 14).setValue(filter_param['debit_remark']);
                            attached_obj.cells(row_id, 15).setValue(filter_param['credit_remark']);
                            attached_obj.cells(row_id, 16).setValue(filter_param['uom_id']);                            
                            
                            attached_obj.cells(row_id, 2).cell.wasChanged = true;                  
                            
                        } else if (flag = 'i') {
                            attached_obj.addRow(new_id, [
                                                            filter_param['detail_id'],
                                                            filter_param['default_gl_id'],
                                                            filter_param['term_start'],
                                                            filter_param['term_end'],
                                                            filter_param['debit_gl_number'],
                                                            filter_param['credit_gl_number'],
                                                            filter_param['netting_debit_gl_number'],
                                                            filter_param['netting_credit_gl_number'],
                                                            filter_param['debit_gl_number_minus'],
                                                            filter_param['credit_gl_number_minus'],		
                                                            filter_param['netting_debit_gl_number_minus'],
                                                            filter_param['netting_credit_gl_number_minus'],
                                                            filter_param['debit_volume_multiplier'],
                                                            filter_param['credit_volume_multiplier'],
                                                            filter_param['debit_remark'],
                                                            filter_param['credit_remark'],
                                                            filter_param['uom_id'] 
                                                        ]
                                                    );
                                                  
                                                        
                        }
                        if (attached_obj.getUserData("","grid_id") !== null) {    
                            invoice_grid_id = attached_obj.getUserData("","grid_id");
                            
                        }   
                        attached_obj.setUserData('', 'grid_id', invoice_grid_id);
                        
                       // alert(attached_obj.getUserData("","grid_id"));
                                         
                        //alert (unique_changed_row_ids + "->" + changed_row_ids);
                    }
                });
            });
            //user_roles_popup.attachEvent("onHide", invoice_glcode.refresh_grid_invoice);
    
        }
            
    </script>
</html>