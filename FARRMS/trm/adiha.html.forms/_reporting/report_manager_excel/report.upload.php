<?php
/**
* Report upload screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<style type="text/css">
.disabledbutton {
    pointer-events: none;
    opacity: 0.4;
}
</style>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';     
    global $app_adiha_loc, $app_php_script_loc;
    $form_name = 'form_rm_upload';
    $name_space = 'rm_upload';

    $file_id = get_sanitized_value($_GET['file_id'] ?? 'NULL');
    $sheet_id = get_sanitized_value($_GET['excel_sheet_id'] ?? 'NULL');
    $function_id = 10202600;
    $rights_rm_excel_iu = 10202610;
    $rights_rm_excel_batch = 10202614;
    list (
            $has_rights_rm_excel_iu,
            $has_rights_rm_excel_batch
         )
    = build_security_rights(
            $rights_rm_excel_iu,
            $rights_rm_excel_batch
        );
    $mode = get_sanitized_value($_GET['mode'] ?? 'i');

    if ($mode == 'u') {
        $xmlFile = "EXEC spa_excel_addin_report_manager 'c', @object_id='$file_id'";
        $recordsets = readXMLURL($xmlFile);
        $filename = $recordsets[0][0];
                    
    } else {
        $filename = NULL;
    }

    $param = '';
?>

<script type="text/javascript">
    var has_rights_rm_excel_iu = Boolean (<?php echo $has_rights_rm_excel_iu ?>);
    var has_rights_rm_excel_batch = Boolean (<?php echo $has_rights_rm_excel_batch ?>);
    var mode = '<?php echo $mode;?>';      
    var file_id = '<?php echo $file_id; ?>'; 
    var filename = '<?php echo $filename; ?>';           
    var sheet_id = '<?php echo $sheet_id; ?>';
    
    $(function(){
        load_layout();
    });

    rm_upload = {};
    var global_layout_object = {};
    var inner_tabs = {};
    var win_general_layout_a_form = {};
    var win_general_layout_b_grid = {};
    var win_paramsets_layout = {};
    var win_paramsets_layout_b = {};
    var win_paramsets_layout_b_grid= {};

    function load_layout() {
        rm_upload.rm_upload_layout = new dhtmlXLayoutObject({
            pattern: "1C",
            parent: document.body,
            offsets: {
                    top:    0,
                    right:  0,
                    bottom: 0,
                    left:   0
            },
            cells:[
                        {
                            id:             "a",
                            text:           "Report Manager Detail",
                            height:          150,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,true]
                        }
                ]
        });
         
        global_layout_object = rm_upload.rm_upload_layout;
        
        inner_tabs = global_layout_object.cells('a').attachTabbar({align: "left",mode: "bottom"});
        inner_tabs.addTab("general", "General", null, 0, true, false);

        inner_tabs_menu = inner_tabs.cells("a");
       
        inner_tabs_menu_json = [ {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title:"Save", enabled: has_rights_rm_excel_iu}];
        inner_tabs_menu = inner_tabs.attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : inner_tabs_menu_json
        });

        inner_tabs_menu.attachEvent("onClick", function call_back(id) {
            switch (id) {
                case "save" :
                    rm_upload_save();
                break;
            }
        });
  
         /**************** General tab Start *********************/
        var win_general = inner_tabs.cells("general");
        win_general_layout = win_general.attachLayout({
            pattern : '2E',
            cells   : [{id: "a", text: "Upload Addin Files", header: true, height: 200}, {id: "b", text: "Define Properties", header: true}]
        });

        win_general_layout_a = win_general_layout.cells("a");

        var hide_document_type = 'true';
        var param = '';
        var document_required = 'false';
        var win_general_a_form_json = [
                        {type: 'settings',position:'label-top', offsetLeft: 10},
                        {type: 'block', blockOffset:0, list: [
                            {type: 'fieldset', name:'fieldset', inputWidth:580, list:[
                                {type: 'upload', name: 'upload', mode:'html4', inputWidth:500, url:'excel.uploader.php', autoStart:true},
                                {type: 'label', label: '* Note: The permitted file formats are only Excel Addin Spreadsheets.'},
                                {type: 'hidden', name: 'uploaded_filename'}
                            ]}
                        ]}
                    ];

        win_general_layout_a_form = win_general_layout_a.attachForm(win_general_a_form_json);
         /**************** General tab End *********************/

        /**************** Paramsets tab Start *********************
            inner_tabs.addTab("paramsets", "Paramsets", null, 1, false, false);
            var win_paramsets = inner_tabs.cells("paramsets");
            win_paramsets_layout = win_paramsets.attachLayout({
                pattern : '2E',
                cells   : [{id: "a", text: "Define Parameters", header: true, height: 80}, {id: "b", text: "Parameters", header: false}]
            });
            win_paramsets_layout_a = win_paramsets_layout.cells("a");
            win_paramsets_layout_a_menu_json = [{id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif", title:"Batch", enabled:0}];
            win_paramsets_layout_a_menu = win_paramsets_layout_a.attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : win_paramsets_layout_a_menu_json
            });
            win_paramsets_layout_a_menu.attachEvent("onClick", function call_back(id){
                switch (id) {
                    case "batch" :
                        run_batch_report_manager();
                    break;
                }
            });
        **************** Paramsets tab End *********************/
        
        // if (mode == 'i'){
        win_general_layout_a_form.attachEvent("onUploadFile", function(realName, serverName) {
            var realName = realName.replace(/ /g,'_');
            load_grid_sheets(realName,'i');
            /*load_grid_paramsets(realName, 'i');*/
            win_general_layout_a_form.setItemValue('uploaded_filename', realName);

            var elList = document.getElementsByClassName("dhx_file_uploader_button button_browse");
            while(elList.length > 0) {
                // For each element, remove the class.
                elList[0].className = elList[0].className.replace(
                /\bdhx_file_uploader_button button_browse\b/,
                "" 
                );
            }
        });

        if (mode == 'u') {
            var real_name = filename;
            real_name = real_name.replace(' ','_');
            load_grid_sheets(real_name,'u');
            win_general_layout_a_form.setItemValue('uploaded_filename', real_name);
            /*--hidden because paramset tab was hidden
                load_grid_paramsets(real_name, 'u');
                if (has_rights_rm_excel_batch == true) {
                    win_paramsets_layout_a_menu.setItemEnabled('batch');     
                }            
            */
        }
            
        win_general_layout_a_form.attachEvent("onUploadFail", function(realName) {
                dhtmlx.alert({
                    type: "alert",
                    title:"Alert",
                    text:"The file already exists or the extension is invalid."
                });
            
                inner_tabs_menu.setItemDisabled('save');   
            
            });

        win_general_layout_a_form.attachEvent("onBeforeFileRemove",function(realName,serverName){
            load_layout();   
        });
    }

    function load_grid_sheets(realName,mode) {
        win_general_layout_b = win_general_layout.cells("b");
        win_general_layout_b_grid = win_general_layout_b.attachGrid();
        win_general_layout_b_grid.setImagePath(js_image_path  +'dhxgrid_web/');
        win_general_layout_b_grid.setHeader('Sheet Name, Alias, Description, Publish, Mobile, Report Category,Show Type,Sheet Type,Maintain History,Sheet Id,File ID,Paramset Hash, Document Type, Data Tabs');
        win_general_layout_b_grid.setColumnIds('sheet_name,alias,description,snapshot,publish_mobile,category_id,show_type,sheet_type,maintain_history,excel_sheet_id,excel_file_id,paramset_hash,document_type,show_data_tabs');
        win_general_layout_b_grid.setColTypes('ro,ed,ed,ch,ch,combo,ro,ro,ro,ro,ro,ro,combo,ch');
        win_general_layout_b_grid.setColumnsVisibility("false,true,false,false,false,false,true,true,true,true,true,true,false, false");
        // win_general_layout_b_grid.setColumnHidden('show_type',true);
        win_general_layout_b_grid.setInitWidths('200,150,200,200,200,200,150,150,150,150,150,200,150,200');
        win_general_layout_b_grid.init();
        var sp_url_param = {                    
                    "flag": 's',
                    "filename": realName,
                    "mode": mode,
                    "action": "spa_excel_addin_report_manager"
        };
        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        

        var report_category = win_general_layout_b_grid.getColumnCombo(5);
        var report_category_sql = {"action":"spa_StaticDataValues", "flag":"e", "type_id":10008};

        var document_type = win_general_layout_b_grid.getColumnCombo(12);
        var document_type_sql = {"action":"spa_StaticDataValues", "flag":"e", "type_id":106700};

        load_grid_combo(sp_url, report_category, report_category_sql);
        load_grid_combo(sp_url, document_type, document_type_sql);
    }

    function load_grid_combo(sp_url, combo, sql) {
        var data = $.param(sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo.load(url, function() {
            win_general_layout_b_grid.clearAndLoad(sp_url, gridAfterLoad);
        });
    }

    function gridAfterLoad() {
        win_general_layout_b_grid.forEachRow(function(id){
            if (this.cells(id,6).getValue() == 'h' || this.cells(id,6).getValue() == 'd')
                this.setRowHidden(id, true);
        }); 
    }

    function rm_upload_save() {
        var filename = win_general_layout_a_form.getItemValue('uploaded_filename');
        var valid_status = 1;
        var detail_tabs = inner_tabs.getAllTabs();
        var grid_xml = "<GridGroup>";
        var form_xml = "<FormXML ";
        $.each(detail_tabs, function(index,value) {
         layout_obj = inner_tabs.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    var ids = attached_obj.getAllRowIds();
                    grid_id = attached_obj.getUserData("","grid_id");
                    grid_label = attached_obj.getUserData("","Grid_label");

                    if(ids != "") {
                        var grid_node = index == 1 ? 'ParamsetGrid' : 'SheetGrid';
                        grid_xml += "<" + grid_node + " grid_id=\"" + grid_id + "\">";
                        var changed_ids = new Array();
                        changed_ids = ids.split(",");
                        $.each(changed_ids, function(index, value) {
                            attached_obj.setUserData(value,"row_status","new row");
                            grid_xml += "<GridRow ";
                            for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                                if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                    grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                    continue;
                                }
                                if (attached_obj.getColumnId(cellIndex) == 'override_type' && attached_obj.cells(value, cellIndex).getValue() == '') {
                                    grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "45610"';
                                    continue;
                                }
                                if (attached_obj.getColumnId(cellIndex) == 'category_id' && attached_obj.cells(value, cellIndex).getValue() == '') {
                                    grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "310367"';
                                    continue;
                                }
                                grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                            }
                            grid_xml += " ></GridRow> ";
                        });
                        grid_xml += "</" + grid_node + ">";
                    }
                } else if(attached_obj instanceof dhtmlXForm) {            
                    var status = validate_form(attached_obj);
                    if(status) {
                        data = attached_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            if(attached_obj.getItemType(field_label) == "calendar"){
                                field_value = attached_obj.getItemValue(field_label,true);
                            } else {
                                field_value = data[a]; 
                            }

                            if (!field_value)
                                field_value = '';
                            if (a == 'file_id')
                                applicant_id = field_value;
                            if (a == 'name')
                                applicant_name = field_value;

                            // form_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    } else {
                        valid_status = 0;
                    }                    
                }                          
            });
        });

        form_xml += "></FormXML>";
        grid_xml += "</GridGroup>";
        var xml = "<Root function_id=\"10202600\" >";
        xml += form_xml;
        xml += grid_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");

        if(filename == 'NULL') {
            dhtmlx.alert({
                title:"Error!",
                type:"alert-error",
                text:'Please upload only 1 file.'
            });
            return;
        }

        /* checks the uploaded file types */
        var name_ext_array = filename.split('.');
        var len_file_name = name_ext_array.length - 1 ;
        var ext = name_ext_array[len_file_name];//this.getFileExtension(file.name);
        var allowed_types = [ "xls", "xlsx"];
        
        if (mode != 'u' && allowed_types.indexOf(ext) < 0) {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:'The file type is invalid. Please check and reupload.'
            });
            return;
        }

        if(valid_status == 1) {
            data = {"action": "spa_excel_addin_report_manager", flag: mode, "filename" : filename, "object_id" : file_id, "xml": xml};
            result = adiha_post_data("return_array", data, "", "", "save_callback");
        } 
    }

    function save_callback(result) {
        var filename = win_general_layout_a_form.getItemValue('uploaded_filename');
        if(result[0][0] == "Success"){
            url = "excel.uploader.php";
            $.ajax({
            type: "POST",
            url: url,
            data: {call_from: "save", filename: filename },
                success: function(data) {
                    if (data == "Success"){
                        success_messsage = result[0][4];
                         dhtmlx.message({
                                text:success_messsage,
                                expire:1000
                            });
                        var tab_id =  parent.rm_excel.getActiveTab();
                        if (mode == 'i') {
                            parent.rm_excel.load_form(result[0][5],filename);
                            parent.rm_excel.tab_close(tab_id);
                        } else {
                            parent.rm_excel.rm_excel_tabbar.cells(tab_id).setText(filename);
                            parent.rm_excel.excel_file_sheet_grid(id);
                            return;
                        }
                        var id = result[0].errorcode;  
                        parent.rm_excel.excel_file_sheet_grid(id);
                    } else if (result[0][0] == "Success") { 
                        success_messsage = result[0][4];
                         dhtmlx.message({
                                text:success_messsage,
                                expire:1000
                            });
                        var tab_id =  parent.rm_excel.getActiveTab();
                        if (mode == 'i') {
                            parent.rm_excel.load_form(result[0][5],filename);
                            parent.rm_excel.tab_close(tab_id);
                        } else {
                            parent.rm_excel.rm_excel_tabbar.cells(tab_id).setText(filename);
                            parent.rm_excel.excel_file_sheet_grid(id);
                            return;
                        }
                        var id = result[0].errorcode;  
                        parent.rm_excel.excel_file_sheet_grid(id);
                    } 
                }
            });
        } else {
                error_messsage = result[0][4];
                dhtmlx.alert({
                    type: "alert",
                    title:'Alert',
                    text:error_messsage
                });
                load_layout();
        }   
    }
</script>