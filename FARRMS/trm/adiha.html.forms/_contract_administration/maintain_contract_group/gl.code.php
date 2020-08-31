<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<?php
    $contract_detail_id = isset($_GET['contract_detail_id']) ? $_GET['contract_detail_id'] : 'NULL';
        $checked_status = isset($_GET['checked_status']) ? $_GET['checked_status'] : 'NULL';

    $function_id = 10211418;
    $rights_contract_gl_code = 10211418;
    list (
    $has_rights_contract_gl_code
    ) = build_security_rights(
        $rights_contract_gl_code            
    );
    $form_namespace = 'glcode';
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='glcode', @group_name='Accounting GL Code', @parse_xml = '<Root><PSRecordSet ID=\"" . $contract_detail_id . "\"></PSRecordSet></Root>'";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif",  imgdis:"save_dis.gif",  text:"Save", title: "Save"}]';

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
        if((!$has_rights_contract_gl_code) || ($checked_status == 'true')) {
        echo $toolbar_obj->disable_item('save');
        }
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'form_gl_code';
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
?>
<form name="<?php echo $form_name; ?>">
    <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
    <input type="hidden" id="dropdown" name="dropdown">
    <div id="layoutObj"></div>
</form>
<style type="text/css">
html, body {
    width: 100%;
    height: 100%;
    margin: 0px;
    overflow: hidden;
}
.dhx_item_editor{
    width:210px;
    height:113px;
}

img.book_icon {
    float: left;
    margin-right: 10px;
}


div.select_button {
    width: 50px;
    height: 17px;
    float: left;
    background-image: url('../../../adiha.php.scripts/adiha_pm_html/process_controls/button_img/edit.jpg');
    padding-left: 30px;
    padding-top: 4px;
}
</style>
<script>
    var contract_detail_id = <?php echo $contract_detail_id;?>;
    var session = "<?php echo $session_id; ?>";
    
    /**
     * gl_code.save_click [this function is triggered when glocode toolbar is triggered.]
     * @param [int] id id of the button.[add,save and delete]
     */
    glcode.save_click = function(id) {

        switch (id) {
            case 'save':
                attached_obj=glcode.form_gl_code;
                var status = validate_form(attached_obj);
                if (status) {
                    form_data = glcode.form_gl_code.getFormData();
                    var xml = '<Root function_id="10211418" ><FormXML ';
                    for (var a in form_data) {
                        if (glcode.form_gl_code.getItemType(a) == 'calendar') {
                            value = glcode.form_gl_code.getItemValue(a, true);
                        } else {
                            value = form_data[a];
                        }
                        xml += ' ' + a + '="' + value + '"';
                    }
                    xml += ' ></FormXML></Root>';

                    var param = {
                        "flag": "s",
                        "action": "spa_process_form_data",
                        "xml": xml
                    };

                    var return_val = adiha_post_data('return_array', param, '', '', 'glcode.save_callback', '');
                }
            break;
        }
    }

    glcode.save_callback = function(result) {
        if (result[0][0] == 'Success') {
            dhtmlx.message({
                text: result[0][4],
                expire: 1000
            });
            setTimeout(function() {
                window.parent.dhxWins.window('w2').close();
            }, 1000);
        } else {
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: result[0][4]
            });
        }
    }
</script>
<div id="myToolbar1"></div>
