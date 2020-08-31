<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        ?>
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
        <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $contract_detail_id = get_sanitized_value($_GET['contract_detail_id'] ?? 'NULL');
        $tab_json = '';

        //Loads data for form from backend.
        /* START */
        //echo $xml_file = "EXEC spa_create_application_ui_json 'j','10211418','glcode','<Root><PSRecordset contract_id=" . '"'.$contract_detail_id.'"' . "></PSRecordset></Root>'";
        $xml_file = "EXEC spa_create_application_ui_json 'j','10211418','glcode','<Root><PSRecordset ID=" . '"'.$contract_detail_id.'"'. "></PSRecordset></Root>'";
       //$xml_file = "EXEC spa_create_application_ui_json 'j','10211200','contract_group','<Root><PSRecordset contract_id=" . '"0"' . "></PSRecordset></Root>'";
        
        $return_value1 = readXMLURL($xml_file);
     //  print_r($return_value1);
      // die();
        $i = 0;
        foreach ($return_value1 as $temp) {
            if ($i > 0)
                $tab_json = $tab_json . ',';
            $tab_json = $tab_json . $temp[1];
            $i++;
        }
        $tab_json = '[' . $tab_json . ']';
        /* END */

        /* start of main layout */
        $form_namespace = 'gl_code';
        $layout = new AdihaLayout();
        //json for main layout.
        /* start */
        $json = '[
            {
                id:             "a",
                text:           "Gl Code",
                header:         true,
                collapse:       false,
                width:          200,
                fix_size:       [true,null]
            }
            
           
        ]';
        /* end */

        //attach main layout to gl code screen
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

        //json for toolbar.
        /* start */
        $save_contract_json = '[
                        {id:"save", type:"button", img:"save.gif", text:"Save", title:"Save"}
                    ]';
        /* end */

        //Attaching a toolbar to save contract details
        /* start */
        $toolbar_contract = 'save_glcode_toolbar';
        echo $layout->attach_toolbar_cell($toolbar_contract, 'a');
        $toolbar_contract_obj = new AdihaToolbar();
        echo $toolbar_contract_obj->init_by_attach($toolbar_contract, $form_namespace);
        echo $toolbar_contract_obj->load_toolbar($save_contract_json);
        echo $toolbar_contract_obj->attach_event('', 'onClick', 'gl_code.glcode_toolbar_click');
        /* end */

        //attach tab to the main layout.
        /* start */
        $tab_name = 'tab_glcode';
        echo $layout->attach_tab_cell($tab_name, 'a', $tab_json);
        /* END */

        /* attach tabbar. */
        /* START */
        $tab_obj = new AdihaTab();
        echo $tab_obj->init_by_attach($tab_name, $form_namespace);
        foreach ($return_value1 as $temp1) {
            $form_json = $temp1[2];
            $tab_id = 'detail_tab_' . $temp1[0];
            $form_name = 'form_' . $temp1[0];
            if ($form_json) {
                echo $tab_obj->attach_form($form_name, $tab_id, $form_json, $form_namespace);
            }
        }
        /* END */
        echo $layout->close_layout();
        /* end of main layout */
        ?>
        <style>
            /*div#layoutObj {
                position: relative;
                width: 640px;
                height: 350px;
                display: inline-block;
            }*/
        </style>
        <form name="<?php echo $form_name; ?>">
            <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
            <input type="hidden" id="dropdown" name="dropdown">
                <div id="layoutObj"></div>
        </form>

        <script>
          //  var contract_detail_id = <?php //echo isset($_GET['contract_detail_id']) ? $_GET['contract_detail_id'] : 0;?>;
            
            var session = "<?php echo $session_id; ?>";
            /**
             * gl_code.glcode_toolbar_click [this function is triggered when glocode toolbar is triggered.]
             * @param [int] id id of the button.[add,save and delete]
             */
            gl_code.glcode_toolbar_click = function(id) {
                //  function glcode_toolbar_click(id) {
                if (id == 'save') {
                    var form_validation_status = 0;
<?php
foreach ($return_value1 as $temp1) {
    $form_json = $temp1[2];
    $tab_id = 'detail_tab_' . $temp1[0];
    $form_name = 'form_' . $temp1[0];
    if ($form_json) {
        echo 'var status_' . $form_name . '=' . $form_namespace . '.' . $form_name . '.validate(); if (!status_' . $form_name . '){form_validation_status=1;}';
    }
}
?>
                    if (!form_validation_status) {
                        var detail_tabs = gl_code.tab_glcode.getAllTabs();
                        var form_xml = '<Root function_id="10211418"><FormXML ';
                        $.each(detail_tabs, function(index, value) {
                            layout_obj = gl_code.tab_glcode.cells(value).getAttachedObject();
                            if (layout_obj instanceof dhtmlXForm) {
                                data = layout_obj.getFormData();
                                for (var a in data) {
                                    field_label = a;
                                    //field_value = data[a];
                                    if (layout_obj.getItemType(a) == "calendar") {
                                        field_value = layout_obj.getItemValue(a, true);
                                    }
                                    else {
                                        field_value = data[a];
                                    }
                                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                                }
                            }
                        });
                        form_xml += "></FormXML></Root>";
                      //  alert(form_xml);
                      //  return;
                        data = {"action": "spa_process_form_data", flag: "u", "xml": form_xml};
                        result = adiha_post_data("alert", data, "", "", "");
                    }
                }

            }
//            gl_code.post_callback = function(result) {
//                alert(result);
//            }
        </script>
        <div id="myToolbar1"></div>
