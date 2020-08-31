<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<?php
global $app_adiha_loc, $app_php_script_loc;

$call_from = get_sanitized_value($_GET['call_from'] ?? '');

switch ($call_from) {
    case 'd':
        $title = 'Import Data ';
        $rights_import_data = 10131300;
        break;
    case 'p':
        $title = 'Import Price Data ';
        $rights_import_data = 10151100;
        break;
    case 'c':
        $title = 'Import Credit Data ';
        $rights_import_data = 10191100;
        break;
    case 'i':
    default:
        $title = 'Import Data ';
        $rights_import_data = 10232700;
        break;
}

list (
    $has_rights_import_data
) = build_security_rights (
    $rights_import_data
);

$import_button_state = empty($has_rights_import_data)?'true':'false';
$window_title = $title;

$namespace = 'import_data';
     
$layout_json = '[{id:"a", header: false}]';
    
//Creating Layout
$import_data_layout = new AdihaLayout();
echo $import_data_layout->init_layout('import_data_layout', '', '3E', $layout_json, $namespace);

// Attaching Toolbar 
$toolbar_obj = new AdihaToolbar();
$toolbar_name = 'toolbar_import_data';
$toolbar_namespace = 'toolbar_ns_import_data';
$toolbar_json = '[ {id:"import", type:"button", img:"import.gif", imgdis:"import_dis.gif", text:"Import", title:"Import", disabled:' . $import_button_state . '}]';
    
echo $import_data_layout->attach_toolbar_cell($toolbar_name, 'a');
echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
echo $toolbar_obj->load_toolbar($toolbar_json);
echo $toolbar_obj->attach_event('', 'onClick', 'import_data_click');
    
//for creating general form
$form_obj = new AdihaForm();
$form_import_option_name = 'form_import_option';
echo $import_data_layout->attach_form($form_import_option_name, 'b');

$form_import_option_structure = "[{type: 'settings',position:'label-top', offsetLeft: 10},
                    //{type: 'fieldset', inputWidth:580, label: 'Import Option', list:[
                         {type: 'radio', name: 'import_option', value:'def', label: 'Import From Source System', position:'label-right', checked: true},
                         {type: 'newcolumn'},
                         {type: 'radio', name: 'import_option', value:'data_file', label: 'Import From Data File', position:'label-right', offsetLeft: 50}
                    //]}
                   ]";

echo $form_obj->init_by_attach($form_import_option_name, $namespace);
echo $form_obj->load_form($form_import_option_structure);

$form_name = 'form_import';
echo $import_data_layout->attach_form($form_name, 'c');

$sp_source_system = "EXEC spa_source_system_description @flag='t', @function_id='" . $rights_import_data . "'";
$source_system_options = $form_obj->adiha_form_dropdown($sp_source_system, 0, 1);
$source_system_options = str_replace("[", "[{value:'0', text:''},", $source_system_options);
$sp_import_source = "EXEC spa_external_source_import @flag='t'";
$import_source_options = $form_obj->adiha_form_dropdown($sp_import_source, 1, 3);
$import_source_options = str_replace("[", "[{value:'0', text:''},", $import_source_options);
$sp_import_format = "EXEC spa_StaticDataValues @flag='x', @type_id=5450, @license_not_to_static_value_id='5457,5463,5458,5453,5454,5461,5456,5464,5466,5455,5459,5462,5460'";
$data_format_options = $form_obj->adiha_form_dropdown($sp_import_format, 0, 1);

$form_structure = "[{type: 'settings',position:'label-top', offsetLeft: 5},
                    {type: 'block', className: 'source_system', blockOffset:0, list: [
                        {type: 'block', blockOffset:0, list: [
                            {type: 'combo', name: 'source_system', width:'250', label: 'Source System', position:'label-top', options: " . $source_system_options . "},
                            {type: 'newcolumn'},
                            {type: 'combo', name: 'import_source', width:'250', label: 'Import Source', position:'label-top', offsetLeft: 60, options: " . $import_source_options . "}
                        ]},
                        {type: 'block', blockOffset:0, list: [
                            {type: 'calendar', name: 'date_from', width:'250', label: 'Date From', position:'label-top'},
                            {type: 'newcolumn'},
                            {type: 'calendar', name: 'date_to', width:'250', label: 'Date To', position:'label-top', offsetLeft: 60}
                        ]},
                        {type: 'block', blockOffset:0, list: [
                            {type: 'checkbox', name: 'date_from', width:'250', label: 'Process from Staging Table', position:'label-right'}
                        ]}
                    ]},
                    {type: 'block', className: 'data_file', blockOffset:0, list: [
                        {type: 'block', blockOffset:0, list: [
                            {type: 'combo', name: 'import_format', width:'250', label: 'Data Format', position:'label-top', options: " . $data_format_options . "},
                        ]},
                        {type: 'fieldset', label: 'Upload Data File', offsetLeft: 15, list: [
                            {type: 'upload', name: 'upload_data_file', inputWidth:'500', url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php', autoStart:true}
                        ]}
                    ]}
                   ]";

echo $form_obj->init_by_attach($form_name, $namespace);
echo $form_obj->load_form($form_structure);

$date_from = date('Y-m-t', strtotime("-1 month"));
$date_to = date('Y-m-d');

echo $form_obj->set_input_value($namespace . '.' . $form_name, 'date_from', $date_from);
echo $form_obj->set_input_value($namespace . '.' . $form_name, 'date_to', $date_to);

//Closing Layout
echo $import_data_layout->close_layout();
?>
    
<script type="text/javascript">
$(function () {
    import_data.import_data_layout.cells("a").setHeight(30);
    import_data.import_data_layout.cells("b").setHeight(63);
    import_data.import_data_layout.cells("b").setText("Import Option");
    import_data.import_data_layout.cells("c").setText("Source System");

    var form_import_obj = import_data.form_import.getForm();
    var combo_import_source_obj = form_import_obj.getCombo('import_source');
    var combo_import_format_obj = form_import_obj.getCombo('import_format');
    combo_import_source_obj.sort("asc");
    combo_import_format_obj.sort("asc");
    var selection_id = combo_import_format_obj.getIndexByValue('5468');
    combo_import_format_obj.selectOption(selection_id, false, false);

    $('.data_file').hide();

    import_data.form_import_option.attachEvent("onChange", function(name, value, is_checked){
        if (value == "data_file") {
            import_data.import_data_layout.cells("c").setText("Data File");

            $('.source_system').hide();
            $('.data_file').show();
        } else {
            import_data.import_data_layout.cells("c").setText("Source System");

            $('.source_system').show();
            $('.data_file').hide();
        }
    });    
});

function import_data_click() {
    alert(1);
}
</script>
</html>