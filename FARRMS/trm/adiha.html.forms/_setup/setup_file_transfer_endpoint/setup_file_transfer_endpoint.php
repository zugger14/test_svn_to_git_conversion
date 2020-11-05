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
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>

<body>
    <?php
    $form_namespace = 'setup_file_transfer_endpoint';
    $function_id = 20017300;
    $rights_setup_certificate_iu = 20017301;
    $rights_setup_certificate_delete = 20017302;

    list(
        $has_rights_setup_certificate_iu,
        $has_rights_setup_certificate_del
    ) = build_security_rights(
        $rights_setup_certificate_iu,
        $rights_setup_certificate_delete
    );
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid("SetupFileTransferEndpoint");
    $form_obj->define_layout_width(350);
    $form_obj->define_custom_functions('save_function', '', '', 'form_load_complete');
    echo $form_obj->init_form('File Transfer Endpoint Detail', '', '');
    echo $form_obj->close_form();


    ?>
    <script type="text/javascript">
        $(function() {

            setup_file_transfer_endpoint.menu.addNewSibling('t2', 'process', 'Process', false, 'process.gif', 'process_dis.gif');
            setup_file_transfer_endpoint.menu.addNewChild('process', '0', 'test_connection', 'Test Connection', true, 'run.gif', 'run_dis.gif');

            setup_file_transfer_endpoint.grid.attachEvent('onRowSelect', function() {
                setup_file_transfer_endpoint.menu.setItemEnabled('test_connection');
            })

            setup_file_transfer_endpoint.grid.attachEvent('onXLE', function() {
                setup_file_transfer_endpoint.menu.setItemDisabled("test_connection");
            })

            setup_file_transfer_endpoint.menu.attachEvent('onClick', function(id) {
                switch (id) {
                    case 'test_connection':
                        setup_file_transfer_endpoint.layout.progressOn();
                        var select_id = setup_file_transfer_endpoint.grid.getSelectedRowId();
                        var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
                        if (count == 1 && select_id != null) {
                            var id_indx = setup_file_transfer_endpoint.grid.getColIndexById('file_transfer_endpoint_id');
                            var remote_directory_indx = setup_file_transfer_endpoint.grid.getColIndexById('remote_directory');
                            var id = setup_file_transfer_endpoint.grid.cells(select_id, id_indx).getValue();
                            var remote_directory = setup_file_transfer_endpoint.grid.cells(select_id, remote_directory_indx).getValue();

                            data = {
                                "action": "spa_file_transfer_endpoint",
                                "flag": "test_connection",
                                "file_transfer_endpoint_id": id,
                                "remote_directory": remote_directory
                            }
                            adiha_post_data("return_json", data, "", "", function(result) {
                                setup_file_transfer_endpoint.layout.progressOff();
                                result = JSON.parse(result);
                                show_messagebox(result[0].message);
                            });
                        } else if (count > 1 && select_id != null) {
                            show_messagebox('Please select only one row from grid.');
                        } else {
                            show_messagebox('Please select a row from grid.');
                        }
                        break;
                }
            })
        });

        setup_file_transfer_endpoint.form_load_complete = function(win, tab_id) {
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

                        if (form_obj.isItem('password')) {
                            data = {
                                'action': 'spa_file_transfer_endpoint',
                                'flag': 'p',
                                'file_transfer_endpoint_id': object_id
                            }

                            adiha_post_data('return_json', data, '', '', function(result) {
                                result = JSON.parse(result);
                                form_obj.setItemValue('password', result[0].password)
                            }, true);
                        }

                        if (flag == 'i' && form_obj.isItem('file_protocol')) {
                            form_obj.attachEvent('onChange', function(id) {
                                if (id == 'file_protocol') {
                                    var file_protocol = form_obj.getItemValue('file_protocol');
                                    if (file_protocol == 1) {
                                        form_obj.setItemValue('port_no', 21);
                                    } else if (file_protocol == 2) {
                                        form_obj.setItemValue('port_no', 22);
                                    } else {
                                        form_obj.setItemValue('port_no', 990);
                                    }
                                }
                            });
                        }
                    }
                });
            });
        }

        setup_file_transfer_endpoint.save_function = function(tab_id) {
            var win = setup_file_transfer_endpoint.tabbar.cells(tab_id);
            var valid_status = 1;
            var flag = (tab_id.indexOf("tab_") != -1) ? 'update' : 'insert';
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var form_xml = "<Root><FormXML ";
            var form_status = true;
            var first_err_tab;
            var tabsCount = tab_obj.getNumberOfTabs();

            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        form_status = form_status && status;
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = tab_obj.cells(value);
                        }
                        if (status) {
                            data = attached_obj.getFormData();
                            for (var a in data) {
                                field_label = a;
                                field_value = data[a];
                                if (field_label == 'password') {
                                    field_value = escapeXML(field_value);
                                }
                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else {
                            valid_status = 0;
                        }
                    }
                });
            });
            form_xml += "></FormXML></Root>";
            if (valid_status == 1) {
                // console.log(setup_file_transfer_endpoint.tabbar.cells(tab_id).getAttachedToolbar());
                setup_file_transfer_endpoint.tabbar.cells(tab_id).getAttachedToolbar().disableItem("save");
                data = {
                    "action": "spa_file_transfer_endpoint",
                    "flag": flag,
                    "xml": form_xml
                }
                result = adiha_post_data("alert", data, "", "", "setup_file_transfer_endpoint.post_callback");
            }

            if (!form_status) {
                generate_error_message(first_err_tab);
            }
        }
    </script>
</body>

</html>