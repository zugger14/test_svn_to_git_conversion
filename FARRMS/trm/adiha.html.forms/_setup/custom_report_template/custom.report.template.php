<?php
/**
* Custom report template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    <?php
    
    $rights_report_template_setup = 10211213;
    $rights_report_template_setup_iu = 10211214;
    $rights_report_template_setup_del = 10211215;
    $rights_contract_report_template_deploy = 10211216;
        
    list (  
            $has_rights_contract_report_template_iu,
            $has_rights_contract_report_template_del,
            $has_rights_contract_report_template_deploy
        ) = build_security_rights(
            $rights_report_template_setup_iu,
            $rights_report_template_setup_del,
            $rights_contract_report_template_deploy
    );
        
    $layout = new AdihaLayout();
    $json = '[
            {
                id:             "a",
                text:           "<div><a class=\'undock_cell_a undock_custom\' style=\'float:right;cursor:pointer\' title=\'Undock\'  onClick=\'form_custom_report_template.undock_cell_a();\'><!--&#8599;--></a>Custom Report Templates</div>",
                header:         true,
                width:          300,
                height:         500,
                collapse:       false,
                fix_size:       [false,null]
            },
            {
                id:             "b",
                text:           "Detail",
                height:         60,
                header:         true,
                height:         500,
                collapse:       false,
                fix_size:       [false,null]
            }
        ]';
        
    $layout_name = 'layout_manage_document';
    $form_name = 'form_custom_report_template';
    echo $layout->init_layout($layout_name, '', '2U', $json, $form_name);
    echo $layout->attach_event('', 'onDock', $form_name . '.on_dock_event');
    echo $layout->attach_event('', 'onUnDock', $form_name . '.on_undock_event');

    //Attaching Grid 
    
    $notes_category_grid = new AdihaGrid();
    $grid_name = 'grd_custom_report_template';
    echo $layout->attach_grid_cell($grid_name, 'a');
    $sp_url = "EXEC spa_contract_report_template 'x'";
    
    echo $notes_category_grid->init_by_attach($grid_name, $form_name);
    echo $notes_category_grid->set_header('ID,Template Type,Template Name,Template Type ID,Filename,Default,Document Type,XML Map Filename, Template Category, Data Source, Excel Sheet');
    echo $notes_category_grid->set_widths('100,180,180,180,100,100,180,180,180,100, 100');
    echo $notes_category_grid->set_search_filter(false, "#numeric_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#numeric_filter");
    echo $notes_category_grid->set_column_types('ro_int,ro,ro,ro_int,ro,ro,ro,ro,ro,ro,ro');
    echo $notes_category_grid->set_columns_ids('template_id,template_type,template_name,template_type_id,filename,default_template,document_type,xml_map_filename,template_category,data_source, excel_sheet_id');
    echo $notes_category_grid->set_column_visibility("true,false,false,true,true,true,true,true,false,false, true");    
    echo $notes_category_grid->attach_event('', 'onRowDblClicked', 'fx_grd_dbclick');
    echo $notes_category_grid->set_sorting_preference('int,str,str,int,str,str,str,str,int,str, int');
    echo $notes_category_grid->return_init();
    echo $notes_category_grid->enable_multi_select();
    echo $notes_category_grid->load_grid_data($sp_url);
    
    // Attaching Menu
    $menu_name = 'custom_report_template_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif"},
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"add.gif"},
                {id:"delete", text:"Delete", img:"trash.gif"}
            ]},
            {id:"deploy", text:"Deploy", img:"deploy.gif"},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]}
            ]';
    
    echo $layout->attach_menu_layout_cell($menu_name, 'a', $menu_json, 'custom_template_menu_click');
       
    $tab_name1 = 'cell_a_tab';
    $json_tab1 = '[]';
    
    echo $layout->attach_tab_cell($tab_name1, 'b', $json_tab1);
   
    echo $layout->close_layout();
    
    
    $filename_template_in_arr = array();
    $filename_template_tkt_arr = array();
    $filename_template_dcr_arr = array();
    $filename_template_mcr_arr = array();
    $filename_template_hedging_arr = array();   
    $filename_template_cc_arr = array(); 
        
    
    for($i = 1; $i < 16; $i++) {
        $filename_template_in_arr[$i-1] = "{text:'I" . $i . "',value:'I" . $i . "'}";
    }
    $filename_template_in_arr[16] = "{text:'Invoice Report Collection',value:'Invoice Report Collection'}";
    
    for($i = 1; $i < 7; $i++) {
        $filename_template_tkt_arr[$i-1] = "{text:'TT" . $i . "',value:'TT" . $i . "'}";
        $filename_template_dcr_arr[$i-1] = "{text:'DCR" . $i . "',value:'DCR" . $i . "'}";
        $filename_template_mcr_arr[$i-1] = "{text:'MCR" . $i . "',value:'MCR" . $i . "'}";
        $filename_template_cc_arr[$i-1] = "{text:'CC" . $i . "',value:'CC" . $i . "'}";
    }
    
    $filename_template_tkt_arr[6] = "{text:'Trade Ticket Collection',value:'Trade Ticket Collection'}";
    $filename_template_dcr_arr[6] = "{text:'Confirm Replacement Report Collection',value:'Confirm Replacement Report Collection'}";
	$filename_template_mcr_arr[6] = "{text:'Margin Call Collection',value:'Margin Call Collection'}";

    
    $filename_template_hedging_arr[0] = "{text:'Hedging Template',value:'Hedging Template'}";
    $filename_template_hedging_arr[1] = "{text:'Hedging Template - RSQ',value:'Hedging Template - RSQ'}";
    $filename_template_hedging_arr[2] = "{text:'Hedge Documentation Collection',value:'Hedge Documentation Collection'}";
    
    $json_invoice_filenames = "[".implode($filename_template_in_arr, ',')."]";
    $json_tkt_filenames = "[".implode($filename_template_tkt_arr, ',')."]";
    $json_dcr_filenames = "[".implode($filename_template_dcr_arr, ',')."]";
	$json_mcr_filenames = "[".implode($filename_template_mcr_arr, ',')."]";
    $json_hedge_filenames = "[".implode($filename_template_hedging_arr, ',')."]";
    $json_cc_filenames = "[".implode($filename_template_cc_arr, ',')."]";
    
    $form_object = new AdihaForm();
    //$sp_url_template_type = "EXEC spa_contract_report_template @flag = 'y'";
	$sp_url_template_type = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 25";
    
    $template_type_dropdown = $form_object->adiha_form_dropdown($sp_url_template_type, 0, 1, '', '', 2);
    
    $sp_url_data_source = "EXEC('SELECT data_source_id, name FROM data_source')";
    $data_source_dropdown = $form_object->adiha_form_dropdown($sp_url_data_source, 0, 1, 'false');

    $sp_url_excel_file = "EXEC spa_contract_report_template @flag = 'b'";
    $data_excel_file = $form_object->adiha_form_dropdown($sp_url_excel_file, 0, 1, 'false');

    
    
    $general_form_structure = "[
                                {type: 'settings', 'position': 'label-top', 'offsetLeft': ".$ui_settings['offset_left'].",'labelWidth':130, 'inputWidth':260},
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'template_type', required: true, label: 'Template Type',className: 'combo_source_system_css', options: " . $template_type_dropdown . ",
                                 width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", 'userdata':{'validation_message':'Invalid Selection'}},     
                                {'type':'newcolumn'},
                                {type: 'input', name: 'template_name', required: true, label: 'Template Name', className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", 'userdata':{'validation_message':'Required Field'}},                                
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'file_name', required: false, label: 'File Name', options: '', className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'data_source','comboType':'custom_checkbox', label: 'Data Source', options: " . $data_source_dropdown . ", className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", filtering:'true'},                                
                                {'type':'newcolumn'},
                                {type: 'hidden', name: 'hidden_template_id', value: 'NULL', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
								{'type':'newcolumn'},        
								{type: 'combo', name: 'template_category', required: false, label: 'Category', options: [], className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'document_type', required: true, label: 'Document Type', options: [{'value':'r','text':'RDL'}, {'value':'w','text':'Word Document'}, {'value':'e','text':'Excel'} ], className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", 'userdata':{'validation_message':'Invalid Selection'}},
                                {'type':'newcolumn'},
								{type: 'input', name: 'xml_map_filename', label: 'XML Map Filename', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left']."},
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'excel_file_id', required: false, label: 'Excel File', options: " . $data_excel_file . ", className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", 'userdata':{'validation_message':'Invalid Selection'}},
                                {'type':'newcolumn'},
                                {type: 'combo', name: 'excel_sheet_id', required: false, label: 'Excel Sheet', options: [], className: 'combo_source_system_css', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", 'userdata':{'validation_message':'Invalid Selection'}},
                                {'type':'newcolumn'},
                                {type:'checkbox', name:'default_template', label:'Default Template', position:'label-right', width: ".$ui_settings['field_size'].", offsetLeft:".$ui_settings['offset_left'].", offsetTop:".$ui_settings['checkbox_offset_top']."}
                            ]"; 
    
    
    //save button toolbar
    $save_btn_toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled: "'.$has_rights_contract_report_template_iu.'"},
        {id:"preview", type:"button", img:"preview.gif", imgdis:"save_dis.gif", text:"Preview", title:"Preview", enabled: "'.$has_rights_contract_report_template_iu.'"}
    ]';
    
    
    ?>
    <script type="text/javascript">
        /**Privilege listing**/
        //var has_rights_contract_report_template_iu = '<?php echo $has_rights_contract_report_template_iu;?>';
		var has_rights_contract_report_template_iu = <?php echo (($has_rights_contract_report_template_iu) ? $has_rights_contract_report_template_iu : '0'); ?>;
        var has_rights_contract_report_template_del = '<?php echo $has_rights_contract_report_template_del;?>';
        var has_rights_contract_report_template_deploy = '<?php echo $has_rights_contract_report_template_deploy; ?>';
		
        $(function () {
            dhxWins = new dhtmlXWindows();
            
            form_custom_report_template.custom_report_template_menu.setItemImage('add', 'new.gif', 'new_dis.gif');
            form_custom_report_template.custom_report_template_menu.setItemImage('delete', 'trash.gif', 'trash_dis.gif');
            form_custom_report_template.custom_report_template_menu.setItemImage('deploy', 'deploy.gif', 'deploy_dis.gif');
           			
            set_custom_report_template_menu_disabled('add', has_rights_contract_report_template_iu);
            set_custom_report_template_menu_disabled('delete', false);
            set_custom_report_template_menu_disabled('deploy', false);
            
            
            form_custom_report_template.grd_custom_report_template.attachEvent("onRowSelect", function(id,ind){
                var template_type_id = form_custom_report_template.grd_custom_report_template.cellById(id, 8).getValue();
                if (template_type_id == 42022 || template_type_id == 42023 || template_type_id == 42024) {
                    set_custom_report_template_menu_disabled('delete', false);
                } else {
                    set_custom_report_template_menu_disabled('delete', has_rights_contract_report_template_del);    
                }
                
                set_custom_report_template_menu_disabled('deploy', has_rights_contract_report_template_deploy);
            })
        });
        
        /**
        * Function called when the button of the menu is clicked
        */ 
        function custom_template_menu_click(id) {			
			switch (id) {
				case "add":
					//Addition codes here
                    add_edit_del_document('i');
				break;
				    
				case "edit":
					//Update codes here
                    add_edit_del_document('u');
				break;
                
				case "delete":
					//Deletion codes here
                    add_edit_del_document('d');
				break;
                
				case "deploy":
					//Deployment codes here
                    deploy_report_template();
				break;
                
                case "refresh":
					//Refresh codes here
                    load_grid();
				break;
                
                case "excel":
					//Excel Export codes here
                    form_custom_report_template.grd_custom_report_template.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
				break;
                
                case "pdf":
					//PDF Export codes here
                    form_custom_report_template.grd_custom_report_template.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
				break;
                
                default:
                    dhtmlx.alert({
                        title:'Alert',
                        type:"alert",
                        text:"Under Maintainence! We will be back soon!"
                    });
                break;
			}
        }
        
        
        /**
        * Function to create Add Window
        * @param [mode] - i for insert mode and u for update mode.
        */
        function add_edit_del_document(mode) {
            var default_exists = 0;

            if (mode == 'i' || mode == 'u') {
                var tab_id_array = form_custom_report_template.cell_a_tab.getAllTabs();
                var tab_id_array_cnt = (tab_id_array == 0) ? '0' : tab_id_array.length;
                    
                    if (mode == 'u') {
                        
                        var selected_row_id = form_custom_report_template.grd_custom_report_template.getSelectedRowId();
                        var selected_item_id = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 0).getValue();
                        var selected_item = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 2).getValue();
                        var template_type_id = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 8).getValue();
                        
                        if (template_type_id == 42022 || template_type_id == 42023 || template_type_id == 42024) {
                            return false;
                        }
                        
                        var selected_item_label = selected_item;
						var tab_label = selected_item_label;
                        
                        
                        for (var i=0;i<tab_id_array_cnt;i++) {                            
                            if (tab_label == form_custom_report_template.cell_a_tab.tabs(tab_id_array[i]).getText()) {
                                form_custom_report_template.cell_a_tab.cells(tab_id_array[i]).setActive();
                                return;
                            }    
                        }
                        
                    } else {
                        var selected_item_id = 'NULL'; 
                        var selected_item = 'New' + tab_id_array_cnt;
                        var selected_item_label = 'New';
                    }
                    
                    form_custom_report_template.cell_a_tab.addTab(selected_item, selected_item_label, null, null, true, true);
                    var formStructure  = <?php echo $general_form_structure; ?>;                    
                    
                    var my_tool_bar = form_custom_report_template.cell_a_tab.tabs(selected_item).attachToolbar();                    

                    my_tool_bar.setIconsPath(js_image_path+"dhxtoolbar_web/");
                    my_tool_bar.loadStruct(<?php echo $save_btn_toolbar_json;?>);
                    
                     my_tool_bar.attachEvent('onClick', function(id) {
                 	var xml_map_filename = grd_inner_obj.getForm().getItemValue('xml_map_filename');
                     var file_name_val = grd_inner_obj.getForm().getItemValue('file_name');
                     var template_category = grd_inner_obj.getForm().getItemValue('template_category');
                    if(id =="save"){
                        //var validate_return = grd_inner_obj.getForm().validate();
                        var  validate_return = validate_form(grd_inner_obj)
                        if (validate_return == false) {
                            generate_error_message();
                            return false;
                        }
                        
                        var template_type_val = grd_inner_obj.getForm().getItemValue('template_type');
                        var template_name_val = grd_inner_obj.getForm().getItemValue('template_name');
                     //   var file_name_val = grd_inner_obj.getForm().getItemValue('file_name');
                        var template_default_val = grd_inner_obj.getForm().getItemValue('default_template');
                        var hidden_template_id = grd_inner_obj.getForm().getItemValue('hidden_template_id');
						var document_type = grd_inner_obj.getForm().getItemValue('document_type');
					//	var xml_map_filename = grd_inner_obj.getForm().getItemValue('xml_map_filename');
                      //  var template_category = grd_inner_obj.getForm().getItemValue('template_category');
                        var data_source_cmb = grd_inner_obj.getForm().getCombo('data_source');
                        var data_source = data_source_cmb.getChecked().join(',');
                        var excel_sheet = grd_inner_obj.getForm().getItemValue('excel_sheet_id');

                        if (hidden_template_id != 'NULL') {
                            mode = 'u';
                            selected_item_id = hidden_template_id; 
                        }
                        /*
                        if (template_type_val == 0) {
                            var message = get_message('VALIDATE_TEMPLATE_TYPE');
                            show_messagebox(message);
                            return;
                        } 
                        if (template_name_val == '') {
                            var message = get_message('VALIDATE_TEMPLATE_NAME');
                            show_messagebox(message);
                            return;
                        }
                        */
                        grd_inner_obj.getForm().attachEvent("onChange", 
                            function(name, value) {
                               if (name == 'template_type') grd_inner_obj.getForm().clearNote('file_name');
                            }
                        );
                        
                        if (file_name_val == '' && document_type == 'r' && (template_category == 42018 || template_category == 42019 || template_type_val == 38)) {
                            var message = get_message('VALIDATE_TEMPLATE_FILENAME');
                            grd_inner_obj.getForm().setNote('file_name', {text:message,width:200});
                            grd_inner_obj.getForm().attachEvent("onChange", 
                                function(name, value) {
                                   if (name == 'file_name') grd_inner_obj.getForm().clearNote(name);
                                }
                            );
                            return;
                        }
                        
                        var grid_xml = '<Grid>';
                        form_custom_report_template['grid_' + selected_item].forEachRow(function(id){
                            grid_xml += '<GridRow ';
                            form_custom_report_template['grid_' + selected_item].forEachCell(id,function(cellObj,ind){
                                grid_xml += form_custom_report_template['grid_' + selected_item].getColumnId(ind) + ' = " ' + form_custom_report_template['grid_' + selected_item].cells(id,ind).getValue() + '" ';
                            });
                            grid_xml += ' />';
                        });
                        grid_xml += '</Grid>';
                        
                        if (default_exists == 1 && template_default_val == 1) {
                            var confirm_msg = get_message('DEFAULT_CONFIRM');
                            dhtmlx.message({
                                title: "Warning",
                                type: "confirm-warning",
                                ok: "Confirm",
                                text: confirm_msg,
                                callback: function(result) {
                                    if (result) {
                                        default_exists = 0;
                                        template_default_val = 1;
                                        var sp_string = "EXEC spa_contract_report_template " + mode + "," + selected_item_id + ",'" + 
                                                                    template_name_val + "','" + 
                                                                    template_name_val + "', null, '" +
                                                                    file_name_val + "', null, " + 
                                                                    template_type_val + ", " +
                                                                    template_default_val + ", '" +
																	document_type + "', '" +
																	xml_map_filename + "', '" +
																	template_category + "', " +
																	data_source + "', " +
																	grid_xml + "', '"+
                                                                    excel_sheet + "'";
                                        var data_for_post = {"sp_string": sp_string};                                        
                                        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'add_edit_del_document_post');
                                        
                                    } else {
                                        template_default_val = 0;
                                        //var sp_string = "EXEC spa_contract_report_template " + mode + "," + selected_item_id + ",'" + 
//                                                                    template_name_val + "','" + 
//                                                                    template_name_val + "', null, '" +
//                                                                    file_name_val + "', null, " + 
//                                                                    template_type_val + ", " +
//                                                                    template_default_val;
//																	
//                                        var data_for_post = {"sp_string": sp_string};  
//                                        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'add_edit_del_document_post');
                                        return;
                                    }

                                }
                            });
                        } else {
                            var sp_string = "EXEC spa_contract_report_template " + mode + "," + selected_item_id + ",'" + 
                                                                    template_name_val + "','" + 
                                                                    template_name_val + "', null, '" +
                                                                    file_name_val + "', null, " + 
                                                                    template_type_val + ", " +
                                                                    template_default_val + ", '" +
																	document_type + "', '" +
																	xml_map_filename + "', '" +
																	template_category + "', '" +
																	data_source + "', '" +
																	grid_xml + "', '"+
                                                                    excel_sheet + "'";
																	
                            var data_for_post = {"sp_string": sp_string};                                        
                            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'add_edit_del_document_post');
                        }
                    } else if(id=='preview'){
                                          
                        var lastIndex = xml_map_filename.lastIndexOf("_");
                        var file_name;  
                        file_name = xml_map_filename.substring(0, lastIndex);
                        file_name = file_name +".docx";
                        if(template_category =="42018")
                        {
                            file_name= "/dev/shared_docs/attach_docs/Deal/"+file_name;
                        }
                        
                            window.location = js_php_path + 'force_download.php?path=' + file_name;
                        window.open(window.location);

                    }
                    
                                      
                    });
                    
                    var inner_layout = form_custom_report_template.cell_a_tab.tabs(selected_item).attachLayout({
                                        pattern: "2E",
                                        cells: [
                                            {id: "a", text: "Template", height: 200, header: false},
                                            {id: "b", text: "XML Mapping"}
                                        ]
                                    });
                    
                
                    var xml_map_menu =   [
                                            {id:"t1", text:"Edit", img:"edit.gif", items:[
                                                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_contract_report_template_iu},
                                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
                                            ]},
                                            {id:"t2", text:"Export", img:"export.gif", items:[
                                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                            ]}
                                        ];
                    form_custom_report_template['menu_' + selected_item] = inner_layout.cells('b').attachMenu();
                    form_custom_report_template['menu_' + selected_item].setIconsPath(js_image_path + 'dhxmenu_web/');
                    form_custom_report_template['menu_' + selected_item].loadStruct(xml_map_menu);
                    form_custom_report_template['menu_' + selected_item].attachEvent('onClick', function(id){
                        switch(id) {
                            case "add":
                                var new_id = (new Date()).valueOf();
                                form_custom_report_template['grid_' + selected_item].addRow(new_id,'');
                                break;
                            case "delete":
                                var row_id = form_custom_report_template['grid_' + selected_item].getSelectedRowId();
                                var row_id_array = row_id.split(",");
                                for (count = 0; count < row_id_array.length; count++) {
                                    if (form_custom_report_template['grid_' + selected_item].cells(row_id_array[count],0).getValue() != '') {
                                        cons_flag = 1;
                                    }
                                    form_custom_report_template['grid_' + selected_item].deleteRow(row_id_array[count]);
                                }
                                break;
                            case "excel":
                                form_custom_report_template['grid_' + selected_item].toExcel('<?php echo $app_php_script_loc; ?>' + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                                break;
                            case "pdf":
                                form_custom_report_template['grid_' + selected_item].toPDF('<?php echo $app_php_script_loc; ?>' +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                                break;
                        }
                    }); 
                
                    form_custom_report_template['grid_' + selected_item] = inner_layout.cells('b').attachGrid();
                    form_custom_report_template['grid_' + selected_item].setHeader(get_locale_value('Mapping ID, Data Source,Data source Column, Mapping Column,Data source column ID,Data source ID', true)); 
                    form_custom_report_template['grid_' + selected_item].setColumnIds("mapping_id,name,data_source_column,mapping_column,data_source_column_id,data_source_id");
                    form_custom_report_template['grid_' + selected_item].setColTypes("ro,ro,ro,ro,ed,ro,"); 
                    form_custom_report_template['grid_' + selected_item].setColumnMinWidth("200,200,200,200,200,200");
                    form_custom_report_template['grid_' + selected_item].setInitWidths('200,200,250,250,150,150'); 
                    form_custom_report_template['grid_' + selected_item].setColSorting("int,,str,str,str,int,int");
                    form_custom_report_template['grid_' + selected_item].init(); 
                    form_custom_report_template['grid_' + selected_item].setColumnsVisibility('true,false,false,false,true,true'); 
                    form_custom_report_template['grid_' + selected_item].enableMultiselect(true);

                    form_custom_report_template['grid_' + selected_item].attachEvent("onRowSelect", function(id,ind){
						if(has_rights_contract_report_template_iu){
							form_custom_report_template['menu_' + selected_item].setItemEnabled('delete');
						}
                    });
                    
                   

                    var grd_inner_obj = inner_layout.cells('a').attachForm(get_form_json_locale(formStructure));

                    form_custom_report_template['frm_' + selected_item] = grd_inner_obj.getForm(); 
                
                    form_custom_report_template['frm_' + selected_item].attachEvent("onChange", function (name, value){

                         if (name == 'template_type') {
                            reload_template_category(selected_item, '');
                         } 

                         if (name == 'excel_file_id') {
                            reload_excel_sheet(selected_item, '');
                         }
                         
                    });

                    var template_name_obj = grd_inner_obj.getForm().getCombo('template_type');
                    template_name_obj.enableFilteringMode(true);

                    var file_name_obj = grd_inner_obj.getForm().getCombo('file_name');
                    file_name_obj.enableFilteringMode(true);

                     /*Validation msg*/
                     form_custom_report_template['frm_' + selected_item].attachEvent("onValidateError", function(name,value,res){
                		var message = form_custom_report_template['frm_' + selected_item].getUserData(name,"validation_message");
                		item_type = form_custom_report_template['frm_' + selected_item].getItemType(name);
                		if(item_type != 'combo'){
                			form_custom_report_template['frm_' + selected_item].setNote(name, {text:message});
                			form_custom_report_template['frm_' + selected_item].attachEvent("onFocus", 
                				function(name, value){
                					form_custom_report_template['frm_' + selected_item].setNote(name,{text:""});
                				}
                			);
                		}	
                	})
                    /*Validation msg END*/
                    
                    //grd_inner_obj.getForm().disableItem('file_name');
                    
                    grd_inner_obj.getForm().getCombo('template_type').attachEvent('onChange', function() {
                        var template_type_val = grd_inner_obj.getForm().getItemValue('template_type');
                        
                        if (template_type_val != 0 && mode == 'i') {
                            grd_inner_obj.getForm().enableItem('file_name');
                        } else if (mode == 'i') {                            
                            grd_inner_obj.getForm().disableItem('file_name');
                        }
                        
                        grd_inner_obj.getForm().getCombo('file_name').clearAll();
                        grd_inner_obj.getForm().getCombo('file_name').unSelectOption();
                        grd_inner_obj.getForm().setItemValue('template_name', '');
                        
                        if (template_type_val == 38 || template_type_val == 10000283) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_invoice_filenames;?>);    
                        } 

                        else if (template_type_val == 48) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_hedge_filenames; ?>);
                        }  else {
                            grd_inner_obj.getForm().setItemValue('file_name', ''); 
                        }
                        
                        grd_inner_obj.getForm().getCombo('file_name').allowFreeText(false);
                        
                        /*removing used filename from file_name Combo*/
                        /*Checking default exists for template type selected*/     
                            default_exists = 0;                   
                            form_custom_report_template.grd_custom_report_template.forEachRow(function(id){
                                var exists_filename = form_custom_report_template.grd_custom_report_template.cellById(id, 4).getValue();
                                var template_type_row = form_custom_report_template.grd_custom_report_template.cellById(id, 3).getValue();
                                var default_row = form_custom_report_template.grd_custom_report_template.cellById(id, 5).getValue();
                        if (mode == 'i') {
                                    grd_inner_obj.getForm().getCombo('file_name').deleteOption(exists_filename);
                                }
                                if (template_type_val == template_type_row && default_row == 'yes' && id != selected_row_id) {
                                    default_exists = 1;
                                }
                                
                            });  
                        /*removing used filename from file_name Combo END*/
                        /*Checking default exists for template type selected END*/
                    });
                
                    grd_inner_obj.getForm().getCombo('template_category').attachEvent('onChange', function() {
                        var template_type_val = grd_inner_obj.getForm().getItemValue('template_type');
                        var template_category = grd_inner_obj.getForm().getItemValue('template_category');
                        
                        if (template_type_val != 0 && mode == 'i') {
                            grd_inner_obj.getForm().enableItem('file_name');
                        } else if (mode == 'i') {                            
                            grd_inner_obj.getForm().disableItem('file_name');
                        }
                        
                        var file_name_val = grd_inner_obj.getForm().getItemValue('file_name');
                        grd_inner_obj.getForm().getCombo('file_name').clearAll();
                        grd_inner_obj.getForm().getCombo('file_name').unSelectOption();
                        
                        if (template_type_val == 33 && template_category == 42018) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_dcr_filenames;?>);
                        } else if (template_type_val == 33 && template_category == 42019) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_tkt_filenames;?>);
                        } else if (template_type_val == -27 && template_category == 42044) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_mcr_filenames;?>);
                        } else if (template_type_val == 10000330 && template_category == 42048) {
                            grd_inner_obj.getForm().getCombo('file_name').addOption(<?php echo $json_cc_filenames;?>);
                        }
                        
                        grd_inner_obj.getForm().getCombo('file_name').allowFreeText(false);
                        if (file_name_val != '')
                            grd_inner_obj.getForm().setItemValue('file_name', file_name_val);
                        
                        /*removing used filename from file_name Combo*/
                        /*Checking default exists for template type selected*/     
                        default_exists = 0;                   
                        form_custom_report_template.grd_custom_report_template.forEachRow(function(id){
                            var exists_filename = form_custom_report_template.grd_custom_report_template.cellById(id, 4).getValue();
                            var template_type_row = form_custom_report_template.grd_custom_report_template.cellById(id, 3).getValue();
                            var default_row = form_custom_report_template.grd_custom_report_template.cellById(id, 5).getValue();
                            if (mode == 'i') {
                                grd_inner_obj.getForm().getCombo('file_name').deleteOption(exists_filename);
                            }
                            if (template_type_val == template_type_row && default_row == 'yes' && id != selected_row_id) {
                                default_exists = 1;
                            }

                        });  
                        /*removing used filename from file_name Combo END*/
                        /*Checking default exists for template type selected END*/
                    });

                    grd_inner_obj.hideItem('excel_sheet_id');
                    grd_inner_obj.hideItem('excel_file_id');
                    grd_inner_obj.hideItem('xml_map_filename');

                    grd_inner_obj.getForm().getCombo('document_type').attachEvent('onChange', function() {
                        var document_type = grd_inner_obj.getForm().getItemValue('document_type');
                        
                        //For excel document type
                        if (document_type == 'e') {
                            grd_inner_obj.getForm().disableItem('file_name');
                            grd_inner_obj.showItem('excel_sheet_id');
                            grd_inner_obj.showItem('excel_file_id');
                            grd_inner_obj.setRequired('excel_sheet_id',true);
                            grd_inner_obj.setRequired('excel_file_id',true);
                            grd_inner_obj.hideItem('xml_map_filename');
                        } else {
                            grd_inner_obj.getForm().enableItem('file_name');
                            grd_inner_obj.hideItem('excel_sheet_id');
                            grd_inner_obj.hideItem('excel_file_id');
                            grd_inner_obj.setRequired('excel_sheet_id',false);
                            grd_inner_obj.setRequired('excel_file_id',false);
                            grd_inner_obj.showItem('xml_map_filename');
                        }

                        if (document_type == 'w') {
                            grd_inner_obj.getForm().enableItem('data_source');
                            grd_inner_obj.getForm().enableItem('xml_map_filename');
                            grd_inner_obj.showItem('xml_map_filename');
                            inner_layout.cells('b').expand();
							reload_xml_mapping(selected_item);
                        } else {
                            grd_inner_obj.getForm().disableItem('data_source');
                            grd_inner_obj.getForm().disableItem('xml_map_filename');
                            grd_inner_obj.hideItem('xml_map_filename');
                            inner_layout.cells('b').collapse();
                            form_custom_report_template['grid_' + selected_item].clearAll();
                        }
                    });
                
                    var data_source_cmb = grd_inner_obj.getForm().getCombo('data_source');
                    data_source_cmb.attachEvent("onClose", function() {
                        reload_xml_mapping(selected_item);
                    });
                      
                    if (mode == 'u') {
                        var template_name = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 2).getValue();
                        var template_type_id = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 3).getValue();
                        var template_filename = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 4).getValue();
                        var template_default = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 5).getValue();
						var document_type = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 6).getValue();
						var xml_map_filename = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 7).getValue();
                        var template_category = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 8).getValue();
                        var data_source = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 9).getValue();
                        var excel_sheet_val = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 10).getValue();
                       
                        var template_default_value = (template_default == 'No' ? 0 : 1);
						                                    
                        grd_inner_obj.getForm().setItemValue('template_type', template_type_id);
                        grd_inner_obj.getForm().setItemValue('template_name', template_name);
                        grd_inner_obj.getForm().setItemValue('file_name', template_filename);
                        grd_inner_obj.getForm().setItemValue('default_template', template_default_value);
                        grd_inner_obj.getForm().setItemValue('hidden_template_id', selected_item_id);
						grd_inner_obj.getForm().setItemValue('document_type', document_type);
						grd_inner_obj.getForm().setItemValue('xml_map_filename', xml_map_filename);
                        var excel_file_id = grd_inner_obj.getForm().setItemValue('excel_file_id', excel_sheet_val);
						var data_source_obj = grd_inner_obj.getForm().getCombo('data_source');
                        reload_template_category(selected_item, template_category);
                        reload_excel_sheet(selected_item, excel_sheet_val);
                        
                        if (data_source != '' && data_source.indexOf(',') > -1) {
                            data_source_arr = data_source.split(',');

                            for (cnt = 0; cnt < data_source_arr.length; cnt++) {
                                if (cnt == 0) { data_source_obj.setComboValue(data_source_arr[cnt]); }
                                var ind = data_source_obj.getIndexByValue(data_source_arr[cnt]);
                                data_source_obj.setChecked(ind, true);
                            }
                        } else if (data_source.indexOf(',') == -1) {
                            var ind = data_source_obj.getIndexByValue(data_source);
                            data_source_obj.setChecked(ind, true);
                        }
                        
                        grd_inner_obj.getForm().disableItem('template_type');
                        grd_inner_obj.getForm().disableItem('template_category');
                        grd_inner_obj.getForm().disableItem('file_name');
                        
                        if (template_default == 'Yes') {
                            grd_inner_obj.getForm().disableItem('default_template');
                        }
                        
                        /*Checking default exists for template type selected*/    
                            var template_type_val = grd_inner_obj.getForm().getItemValue('template_type');
                            default_exists = 0;                   
                            form_custom_report_template.grd_custom_report_template.forEachRow(function(id){
                                var exists_filename = form_custom_report_template.grd_custom_report_template.cellById(id, 4).getValue();
                                var template_type_row = form_custom_report_template.grd_custom_report_template.cellById(id, 3).getValue();
                                var default_row = form_custom_report_template.grd_custom_report_template.cellById(id, 5).getValue();                                
                                if (template_type_val == template_type_row && default_row == 'Yes' && id != selected_row_id && template_default == 'No') {
                                    default_exists = 1;
                                }
                                //alert(template_type_val + '==' + template_type_row +'&&'+ default_row +'=='+ 1 +'&&'+ id +'!='+ selected_row_id);
                            }); 
                        /*Checking default exists for template type selected END*/
                    }
                    
                    document_type = grd_inner_obj.getForm().getItemValue('document_type');
                    if (document_type == 'r') {
                        grd_inner_obj.getForm().disableItem('data_source');
                        grd_inner_obj.getForm().disableItem('xml_map_filename');
                        inner_layout.cells('b').collapse();
                    } else {
                        reload_xml_mapping(selected_item);
                    }
            }
            
            if (mode == 'd') {
                var sel_value = [];
                var template_id_index = form_custom_report_template.grd_custom_report_template.getColIndexById('template_id');
                var selected_row_id = form_custom_report_template.grd_custom_report_template.getSelectedRowId();
                
                if(selected_row_id == undefined) {
                    var message = get_message('VALIDATE_GRID');
                    show_messagebox(message);
                    return;
                }
                
                selected_row_id = selected_row_id.split(',');
                selected_row_id.forEach(function(val) {
                    var selected_item_id = form_custom_report_template.grd_custom_report_template.cellById(val, template_id_index).getValue();
                    sel_value.push(selected_item_id);
                });
                sel_value = sel_value.toString();

                var sp_string = "EXEC spa_contract_report_template @flag = '" + mode + "', @del_template_id = '" + sel_value + "'";
                                                                                    
                var data_for_post = {"sp_string": sp_string};
                
                var confirm_msg = get_message('DELETE_CONFIRM');
                
                    dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    text: confirm_msg,
                    ok: "Confirm",
                    callback: function(result) {
                        if (result)
                            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'del_document_post');
                    }
                });
            }	
        }
        
        function del_document_post(return_arr) {
            var template_name_index = form_custom_report_template.grd_custom_report_template.getColIndexById('template_name');
            var all_tabs = form_custom_report_template.cell_a_tab.getAllTabs();
            var template_name_arr = [];

            var return_data = JSON.parse(return_arr);
            if (return_data[0].errorcode == 'Success') {
                success_call(return_data[0].message);
                
                /*tab close*/
                var selected_row = form_custom_report_template.grd_custom_report_template.getSelectedRowId();
                selected_row = selected_row.split(',');

                selected_row.forEach(function(vals) {
                    template_name_arr.push(form_custom_report_template.grd_custom_report_template.cells(vals, template_name_index).getValue());
                });

                var del_tab_ids = _.intersection(all_tabs, template_name_arr);

                if (del_tab_ids.length > 0) {
                    del_tab_ids.forEach(function(val) {
                        if (form_custom_report_template.cell_a_tab.cells(val) !== null)
                            form_custom_report_template.cell_a_tab.cells(val).close();
                    });
                }
                /*tab close END*/

                load_grid();
            } else {
                show_messagebox(return_data[0].message);
            }
        } 
        
        function add_edit_del_document_post(return_arr) {
            var selected_tab_id = form_custom_report_template.cell_a_tab.getActiveTab();
            if(has_rights_contract_report_template_iu) {
                form_custom_report_template.cell_a_tab.tabs(selected_tab_id).getAttachedToolbar().enableItem('save');
                 }
            var return_data = JSON.parse(return_arr);
            if (return_data[0].errorcode == 'Success') {
                load_grid();
                dhtmlx.message({
                            text:return_data[0].message,
                            expire:1000
                        });
                        
               
                var active_frm = form_custom_report_template['frm_' + selected_tab_id];
                
                var hidden_template_id = active_frm.getItemValue('hidden_template_id');
                
                if (hidden_template_id == 'NULL') { //if NULL implies insert form else update form
                    var hidden_template_id = return_data[0].recommendation;    //fetch template_id
                }
                
                var template_name = active_frm.getItemValue('template_name');
                var template_default = active_frm.getItemValue('default_template');
                                
                active_frm.setItemValue('hidden_template_id', hidden_template_id);
                
                form_custom_report_template.cell_a_tab.tabs(selected_tab_id).setText(template_name);
                active_frm.disableItem('template_type');
                active_frm.disableItem('file_name');
                
                if (template_default == 'yes') {
                    active_frm.disableItem('default_template');
                }
            } else {
                dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text:return_data[0].message
                        });
            } 
        }
        
        function deploy_report_template() {
            var selected_row_id = form_custom_report_template.grd_custom_report_template.getSelectedRowId();
            
            if(selected_row_id == undefined) {
                var message = get_message('VALIDATE_GRID');
                show_messagebox(message);
                return;   
            }
            
            var selected_item_id = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 0).getValue();
            var template_name = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 2).getValue();
            var template_type_id = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 3).getValue();
            var template_filename = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 4).getValue();
			var document_type = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 6).getValue();
			
             var param = 'custom.report.template.deploy.php?mode=i&template_id=' + selected_item_id +
                        '&template_type=' + template_type_id +
                        '&file_name=' + template_filename +
                        '&template_name=' + template_name +
						'&document_type=' + document_type +
                        '&call_from=contract_report_template&is_pop=true'; 
            
            var is_win = dhxWins.isWindow('w1');
            
            if (is_win == true) {
                w1.close();
            } 
            
            w1 = dhxWins.createWindow("w1", 0, 0, 500, 250);
            w1.setText('Deploy');
            w1.centerOnScreen();
            w1.attachURL(param, false, true);
        }
        
        function load_grid() {
            // load grid
			var template_param = {
				"flag": "x",
				"action": "spa_contract_report_template"
			};
			
			template_param = $.param(template_param);
			var data_url = js_data_collector_url + "&" + template_param; 
			form_custom_report_template.grd_custom_report_template.clearAll();
			form_custom_report_template.grd_custom_report_template.loadXML(data_url, function(){
                form_custom_report_template.grd_custom_report_template.filterByAll();
            });
            
            set_custom_report_template_menu_disabled('delete', false);
            set_custom_report_template_menu_disabled('deploy', false);
			// load grid END
            
            //Clear the filter value 
            // $('div.dhx_cell_layout:first').find('div.filter input').val('');
        }
        
        /**
        * Function called when the grid on panel 'a' is double clicked
        */
        function fx_grd_dbclick() {
            //if (has_rights_contract_report_template_iu == true)
                add_edit_del_document('u');            
        }      
        
        function get_message(message_code) {
    		switch (message_code) {
    			case 'VALIDATE_TEMPLATE_TYPE':
    				return 'Please select template type.';
    			case 'VALIDATE_TEMPLATE_NAME':
    				return 'Please enter template name.';
    			case 'VALIDATE_TEMPLATE_FILENAME':
    				return 'Please select filename.';
    			case 'VALIDATE_GRID':
    				return 'Please select data.';
    			case 'DELETE_CONFIRM':
    				return 'Are you sure you want to delete?';
                case 'DEFAULT_CONFIRM':
                    return 'Default Template already exists. Are you sure you want to overwrite default template?'
    		}
    	}
        
       function custom_report_deploy_callback(bool_val) {
            var selected_row_id = form_custom_report_template.grd_custom_report_template.getSelectedRowId();
            var template_name = form_custom_report_template.grd_custom_report_template.cellById(selected_row_id, 2).getValue();
            if (bool_val) {                
                show_messagebox(template_name + ' has been deployed successfully.');
                dhxWins.window('w1').close();
            } else {
                dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text:template_name + ' deployed failed.'
                        });
            }
       }
       
    form_custom_report_template.undock_cell_a = function() {
        form_custom_report_template.layout_manage_document.cells("a").undock(300, 300, 900, 700);
        form_custom_report_template.layout_manage_document.dhxWins.window("a").button("park").hide();
        form_custom_report_template.layout_manage_document.dhxWins.window("a").maximize();
        form_custom_report_template.layout_manage_document.dhxWins.window("a").centerOnScreen();
    }
    
    form_custom_report_template.on_dock_event = function(name) {
        $(".undock_cell_a").show();
    }
    
   form_custom_report_template.on_undock_event = function(name) {
        $(".undock_cell_a").hide();
    }
       
       /**
        * Function enable/disable menu.
        */
        function set_custom_report_template_menu_disabled(item_id, bool) {
            if (bool == false) {
                form_custom_report_template.custom_report_template_menu.setItemDisabled(item_id);    
            } else {
                form_custom_report_template.custom_report_template_menu.setItemEnabled(item_id);
            }
        }
        
    reload_template_category = function(selected_item, set_value) {
        var document_type = form_custom_report_template['frm_' + selected_item].getItemValue('template_type');

        var doc_cat_cmb = form_custom_report_template['frm_' + selected_item].getCombo('template_category');
        document_type = (document_type == 10000283) ? 38 : document_type;
        var cm_param = {
                            "action": "spa_StaticDataValues", 
                            "flag":"h", 
                            "type_id":42000,
                            "category_id": document_type,
                            "license_not_to_static_value_id": "42022,42023,42024",
                            "call_from": "form",
                            "has_blank_option": false
                        };



        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        doc_cat_cmb.clearAll();
        doc_cat_cmb.load(url, function() {
            doc_cat_cmb.setComboText('');
            if (cm_param == '') {
                doc_cat_cmb.selectOption(0);
            } else {
                form_custom_report_template['frm_' + selected_item].setItemValue('template_category', set_value);
            }
        });
    }
   
    reload_excel_sheet = function(selected_item, set_value) {
        var excel_file_id = form_custom_report_template['frm_' + selected_item].getItemValue('excel_file_id');
        var excel_sheet_cmb = form_custom_report_template['frm_' + selected_item].getCombo('excel_sheet_id');
        var cm_param = {
                            "action": "spa_contract_report_template", 
                            "flag":"f", 
                            "excel_sheet_id":excel_file_id,
                            "call_from": "form",
                            "has_blank_option": false
                        };
                        
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        excel_sheet_cmb.clearAll();
        excel_sheet_cmb.load(url, function() {
            excel_sheet_cmb.setComboText('');
            if (cm_param == '') {
                excel_sheet_cmb.selectOption(0);
            } else {
                form_custom_report_template['frm_' + selected_item].setItemValue('excel_sheet_id', set_value);
            }
        });
    }
    
    reload_xml_mapping = function(selected_item) {
        var data_source_cmb = form_custom_report_template['frm_' + selected_item].getCombo('data_source');
        var data_source = data_source_cmb.getChecked().join(',');
        
        if (data_source == '') 
            return;
        
        var xml_map_param = {
            "flag": "z",
            "action": "spa_contract_report_template",
            "data_source": data_source
        };

        xml_map_param = $.param(xml_map_param);
        var data_url = js_data_collector_url + "&" + xml_map_param; 
        form_custom_report_template['grid_' + selected_item].clearAll();
        form_custom_report_template['grid_' + selected_item].loadXML(data_url, function(){
			form_custom_report_template['grid_' + selected_item].forEachRow(function(id){
			
				if (form_custom_report_template['grid_' + selected_item].cells(id,0).getValue() == '' ) {
					form_custom_report_template['grid_' + selected_item].setRowColor(id,'#BCE7F5');
				} else {
					form_custom_report_template['grid_' + selected_item].setRowColor(id,'white');
				}
			});
		});
     
    }
        
       
     </script>
</html>
