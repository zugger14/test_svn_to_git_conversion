<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    
    
    $json = '[
                {
                    id:             "a",
                    text:           "Config",
                    header:         false,
                    collapse:       false,
                    width:          390,
                    height:         170
                }
            ]';

    $namespace = 'ice_interface_config';
    $ice_interface_config_obj = new AdihaLayout();
    echo $ice_interface_config_obj->init_layout('ice_interface_config_layout', '', '1C', $json, $namespace);

    $exec_sql = "SELECT MAX(ID) id FROM ice_interface_settings";
    $sql_result = readXMLURL2($exec_sql);
    $id = $sql_result[0]['id'];
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20001101', @template_name='ice interface config', @parse_xml='<Root><PSRecordset ID=\"". $id . "\"></PSRecordset></Root>'";
    $form_arr = readXMLURL2($form_sql);
    $tab_id = $form_arr[0]['tab_id'];
    $form_json = $form_arr[0]['form_json'];
    
    echo $ice_interface_config_obj->attach_form('ice_interface_config_form', 'a');
    $ice_interface_config_form_obj = new AdihaForm();
    echo $ice_interface_config_form_obj->init_by_attach('ice_interface_config_form', $namespace);
    echo $ice_interface_config_form_obj->load_form($form_json);

    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text: "Save", title: "Save" }]';
    echo $ice_interface_config_obj->attach_toolbar_cell('ice_interface_config_toolbar', 'a');
    $ice_interface_config_toolbar_obj = new AdihaToolbar();
    echo $ice_interface_config_toolbar_obj->init_by_attach('ice_interface_config_toolbar', $namespace);
    echo $ice_interface_config_toolbar_obj->load_toolbar($toolbar_json);
    echo $ice_interface_config_toolbar_obj->attach_event('', 'onClick', 'ice_interface_config_toolbar_onclick');

    echo $ice_interface_config_obj->close_layout();
    ?>
    
    <script type="text/javascript">  
        var object_id = '<?php echo $id; ?>';
        ice_interface_config_toolbar_onclick = function(name, value) {
            if (name == 'save') {
                ice_interface_config_save();
            }
        }
        
        ice_interface_config_save = function() {
            var form_xml = "<FormXML ";
            var attached_obj = ice_interface_config.ice_interface_config_layout.cells('a').getAttachedObject();
            data = attached_obj.getFormData();
            for (var a in data) {
                field_label = a;
                if (attached_obj.getItemType(field_label) == "calendar") {
                    field_value = attached_obj.getItemValue(field_label, true);
                } else {
                    field_value = data[a];
                }
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }
            form_xml += ' />';
            
            var xml = "<Root>" + form_xml + "</Root>";
            data = {"action": "spa_ice_interface", "flag": "c", "xml": xml};
            result = adiha_post_data("alert", data, "", "", "");
        }
    </script>