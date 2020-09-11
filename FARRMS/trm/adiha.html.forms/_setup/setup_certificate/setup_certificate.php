<?php

/**
 * Setup Certificate Screen
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <style>
        .dhxform_control > .dhxform_textarea[name='file_name'] {
            background: #ddd;
        }
        .dhxform_control > .close-icon{
            position: absolute;
            top: -5px;
            bottom: 0;
            right: 5px;
            font-size: 2em;
            height: 100%;
            z-index: 1;
            cursor: pointer;
        }
    </style>
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>

<body>
    <?php
    $form_namespace = 'setup_certificate';
    $function_id = 20017200;
    $rights_setup_certificate_iu = 20017201;
    $rights_setup_certificate_delete = 20017202;

    list(
        $has_rights_setup_certificate_iu,
        $has_rights_setup_certificate_del
    ) = build_security_rights(
        $rights_setup_certificate_iu,
        $rights_setup_certificate_delete
    );
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid("SetupCertificate");
    $form_obj->define_layout_width(300);
    $form_obj->define_custom_functions('save_function', '', '', 'form_load_complete');
    echo $form_obj->init_form('Certificate Detail', '', '');
    echo $form_obj->close_form();


    ?>
    <script type="text/javascript">
        dhxWins = new dhtmlXWindows();

        setup_certificate.save_function = function(){
            var tab_id = setup_certificate.tabbar.getActiveTab();
            var win = setup_certificate.tabbar.cells(tab_id);
            var tab_obj = win.getAttachedObject();
            var detail_tabs = tab_obj.getAllTabs();
            var form_status = true;
            var form_xml = "<Root><FormXML ";
            var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';

            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        form_status = form_status && status;

                        if(status){
                            data = attached_obj.getFormData();
                            for (var a in data) {
	                            var field_value = data[a];                        
	                            form_xml += " " + a + "=\"" + field_value + "\"";     
				            }
                        }
                        
                    }
                });
            });
            form_xml += "></FormXML></Root>";

            data = {
                'action': 'spa_setup_certificate',
                'flag': flag,
                'xml_value': form_xml
            }
            result = adiha_post_data("alert", data, "", "", "setup_certificate.post_callback");
        }

        setup_certificate.form_load_complete = function() {
            var tab_id = setup_certificate.tabbar.getActiveTab();
            var win = setup_certificate.tabbar.cells(tab_id);
            var tabbar_cell = setup_certificate.tabbar.tabs(tab_id);
            var toolbar_obj = tabbar_cell.getAttachedToolbar();
            var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];

            tab_obj.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;
                        setup_certificate.form = form_obj;
                        if (form_obj.isItem('file_name')) {
                            form_obj.getInput('file_name').readOnly = true

                            form_obj.getInput('file_name').addEventListener('dblclick', function() {

                                var is_win = dhxWins.isWindow('w11');
                                if (is_win == true) {
                                    w11.close();
                                }

                                var file_path = app_form_path + '_setup/setup_certificate/upload_document.php'
                                w11 = dhxWins.createWindow('w11', 600, 60, 690, 280);
                                w11.setText("Upload File");
                                w11.attachURL(file_path);
                                w11.centerOnScreen();

                            })

                            form_obj.attachEvent("onChange",function(name, old_Value, new_value) {
                                if(name == 'file_name') {
                                    if(new_value === '') {
                                        $(form_obj.getInput('file_name')).next().hide()
                                    } else {
                                        $(form_obj.getInput('file_name')).next().show()
                                    }
                                }
                            })

                            $(form_obj.getInput('file_name'))
                                .parent()
                                .append('<div class="close-icon">×</div>')
                                .find('.close-icon')
                                .on("click", function(e){
                                    e.stopPropagation();
                                    form_obj.setItemValue('file_name', '')
                                    form_obj.callEvent('onChange', ['file_name', '', ''])
                                })

                            form_obj.getItemValue('file_name') === '' 
                                ? $('.dhxform_control > .close-icon').hide()
                                : $('.dhxform_control > .close-icon').show()
                        }
                    }
                });
            });
        }

        setup_certificate.set_file_name = function($file_name) {
            var tab_id = setup_certificate.tabbar.getActiveTab();
            var win = setup_certificate.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];

            tab_obj.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;
                        if (form_obj.isItem('file_name')) {
                            form_obj.setItemValue('file_name', $file_name)
                            form_obj.callEvent('onChange', ['file_name', '', $file_name])
                        }
                    }
                });
            });
            dhxWins.window('w11').close();
        }
    </script>
</body>

</html>