<?php
/**
* Manage alert workflow import export screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
include '../../../adiha.php.scripts/components/include.file.v3.php';
global $app_adiha_loc, $app_php_script_loc;
$php_script_loc = $app_php_script_loc;

$rights_manage_import_iu = 20013701;
list (
    $has_rights_manage_import_iu
    ) = build_security_rights (
    $rights_manage_import_iu
);

$button_state = (!$has_rights_manage_import_iu)?'true':'false';

$form_name = 'form_alert_workflow_import_iu';
$rights_form_alert_workflow_import = 20013700;
$layout_json = '[{id:"a", header: false}]';

//Creating Layout
$alert_workflow_import_iu_layout = new AdihaLayout();
echo $alert_workflow_import_iu_layout->init_layout('alert_workflow_import_iu', '', '1C', $layout_json, $form_name);

// Attaching Toolbar
$toolbar_obj = new AdihaToolbar();
$toolbar_name = 'toolbar_import';
$toolbar_namespace = 'toolbar_ns_import';
$tree_toolbar_json = '[ {id:"ok", type:"button", img:"tick.png", text:"OK", title:"ok", disabled:' . $button_state . '}]';

echo $alert_workflow_import_iu_layout->attach_toolbar_cell($toolbar_name, 'a');
echo $toolbar_obj->init_by_attach($toolbar_name, $form_name);
echo $toolbar_obj->load_toolbar($tree_toolbar_json);
echo $toolbar_obj->attach_event('', 'onClick', 'save_form');

$copy_field_req = (isset($_REQUEST['copy_field_req']  ) ? $_REQUEST['copy_field_req'] : 0); //field lable for copy as name for import


//for creating dropdown json data for general form
$form_obj = new AdihaForm();
$form_name_inner = 'form_add';
echo $alert_workflow_import_iu_layout->attach_form($form_name_inner, 'a');

$param = '&call_form=alert_workflow_import';

$general_form_structure = "[{type: 'settings',position:'label-top', offsetLeft: 10}, ";

if ($copy_field_req == 1) {
    $general_form_structure = $general_form_structure . "
                            {type: 'block', blockOffset:0, list: [
                             {type: 'input', name: 'copy_as', label: 'Import As', 'required':true, id: 'copy_as'},     
                            {type: 'newcolumn'}]},"; 
}                            

$general_form_structure = $general_form_structure . " {type: 'block', blockOffset:0, list: [
								    {type: 'fieldset', inputWidth:580, label: 'File Attachment', list:[
										{type: 'upload', name: 'upload', inputWidth:500, url: js_file_uploader_url + '" . $param . "', autoStart:true},
										{type: 'label', label: '* Note: The permitted file formats are text document.'}
									]},
									{type: 'newcolumn'},
									{type: 'hidden', value:'', name:'file_attachment'}
							    ]}
							    ]";

$form_obj->init_by_attach($form_name_inner, $form_name);
echo $form_obj->load_form($general_form_structure);
echo $form_obj->attach_event('', 'onButtonClick', 'save_form');
echo $form_obj->attach_event('', 'onUploadFile', 'upload_doc');
echo $form_obj->attach_event('', 'onFileRemove', 'remove_doc');

echo $alert_workflow_import_iu_layout->close_layout();
?>

<script type="text/javascript">
    upload_doc = function(realName,serverName) {
        var get_pre_name = form_alert_workflow_import_iu.form_add.getItemValue('file_attachment');

        if (get_pre_name == '') {
            final_name = serverName;
        } else {
            final_name = get_pre_name + ', ' + serverName;
        }

        form_alert_workflow_import_iu.form_add.setItemValue('file_attachment', final_name);
    }

    /**
     * [remove_doc Remove document]
     * @param  {[type]} realName   [description]
     * @param  {[type]} serverName [description]
     */
    remove_doc = function(realName,serverName){
        var file_name_list = form_alert_workflow_import_iu.form_add.getItemValue('file_attachment');
        file_name_list = remove_file_name(file_name_list, realName);
        form_alert_workflow_import_iu.form_add.setItemValue('file_attachment', file_name_list);
    }

    /**
     * [remove_file_name Remove file name from list]
     * @param  {[type]} list  [list]
     * @param  {[type]} value [matching value]
     */
    remove_file_name = function(list, value) {
        var elements = list.split(", ");
        var remove_index = elements.indexOf(value);

        elements.splice(remove_index,1);
        var result = elements.join(", ");
        return result;
    }

    function save_form() {
        var copy_field_req = '<?php echo $copy_field_req; ?>';
        var file_attachment = form_alert_workflow_import_iu.form_add.getItemValue('file_attachment');
        var copy_as = ''; 

        if (copy_field_req == 1) {
            copy_as = form_alert_workflow_import_iu.form_add.getItemValue('copy_as');

            if (copy_as == '' || copy_as == null) {
                show_messagebox('Please enter Import As.');
                return;
            }
        }

        if(!file_attachment || file_attachment == '' || file_attachment == null) {
            show_messagebox('Please upload a file.');
            return;
        }


        if(file_attachment.indexOf(',') >= 0) {
            show_messagebox('Please upload only 1 file.');
            return;
        }

        /* checks the uploaded file types */
        var name_ext_array = file_attachment.split('.');
        var len_file_name = name_ext_array.length - 1 ;
        var ext = name_ext_array[len_file_name];//this.getFileExtension(file.name);
        var allowed_types = ["txt"];
        if (allowed_types.indexOf(ext) < 0) {
            show_messagebox('The file type is invalid. Please check and reupload.');
            return;
        }

        var doc_type = 'NULL';
        var doc_type_file_unique_name = file_attachment;
        var file_name = doc_type_file_unique_name;

        if (copy_field_req == 1) {
            
            parent.import_from_file(file_name, copy_as);   
        } else {
            parent.import_from_file(file_name);    
        }
        
    }
</script>