<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
        <?php
            $form_namespace = 'lock_as_of_date';
            $function_id = 10105200;
            $rights_lock_as_of_date_iu = 10105210;
            $rights_lock_as_of_date_del = 10105211;

            list (
                $has_rights_lock_as_of_date_iu,
                $has_rights_lock_as_of_date_del 
            ) = build_security_rights (
                $rights_lock_as_of_date_iu,
                $rights_lock_as_of_date_del
            );

            $layout_json = '[
                                {
                                    id:             "a",
                                    text:           "Lock As Of Date",
                                    height:          20,
                                    header:         false,
                                    collapse:       false,
                                    fix_size:       [true,null]
                                },
                                {
                                    id:             "b",
                                    text:           "Lock As Of Date",
                                    width:          200,
                                    height:         200,
                                    header:         false,
                                    collapse:       false,
                                    fix_size:       [false,null]
                                }
                            ]';

            $toolbar_json = '[
                                {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:"' . $has_rights_lock_as_of_date_iu . '"}
                             ]';

            $menu_json = '[
                              {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                  {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"' . $has_rights_lock_as_of_date_iu . '"},
                                  {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled:true}
                              ]},
                              {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                              ]}
                          ]';

             //Attaching Layout  
            $layout_obj = new AdihaLayout();
            echo $layout_obj->init_layout('lock_as_of_date_layout', '', '2E', $layout_json, $form_namespace);
            echo $layout_obj->attach_status_bar('b', true);

            //Attaching Toolbar 
            echo $layout_obj->attach_toolbar_cell('lock_as_of_date_toolbar', 'a');
            $toolbar_obj = new AdihaToolbar();
            echo $toolbar_obj->init_by_attach('lock_as_of_date_toolbar', $form_namespace);
            echo $toolbar_obj->load_toolbar($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

            //Attaching Menu  
            echo $layout_obj->attach_menu_cell('lock_as_of_date_menu', 'b');     
            $menu_obj = new AdihaMenu(); 
            echo $menu_obj->init_by_attach('lock_as_of_date_menu', $form_namespace);
            echo $menu_obj->load_menu($menu_json);
            echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

            //Attching Grid table
            echo $layout_obj->attach_grid_cell('LockAsOfDate', 'b');
            $grid_obj = new GridTable('LockAsOfDate');
            echo $grid_obj->init_grid_table('LockAsOfDate', $form_namespace,'n');
            echo $grid_obj->set_column_auto_size();
            echo $grid_obj->set_search_filter(true, "");
            echo $grid_obj->enable_multi_select(true);
			echo $grid_obj->return_init();
            echo $grid_obj->enable_paging(25, 'pagingArea_b');   
            echo $grid_obj->split_grid(2);
            echo $grid_obj->attach_event('', 'onRowSelect', 'grid_row_click');

            echo $layout_obj->close_layout();
        ?>
    </body>
    <script type="text/javascript">

        var has_rights_lock_as_of_date_iu = '<?php echo (($has_rights_lock_as_of_date_iu) ? $has_rights_lock_as_of_date_iu : '0'); ?>;'; 
        var has_rights_lock_as_of_date_del = '<?php echo (($has_rights_lock_as_of_date_del) ? $has_rights_lock_as_of_date_del : '0'); ?>;';

        $(function(){
            lock_as_of_date.lock_as_of_date_layout.cells("a").setHeight(1);
            lock_as_of_date.load_lock_as_of_date_grid();
        });

        lock_as_of_date.menu_click = function(id){
            switch(id) {
                case 'add':
                    var newId = (new Date()).valueOf();
                    lock_as_of_date.LockAsOfDate.addRow(newId,"");
                    lock_as_of_date.LockAsOfDate.selectRowById(newId);
                    lock_as_of_date.LockAsOfDate.forEachRow(function(row) {
                        lock_as_of_date.LockAsOfDate.forEachCell(row,function(cellObj,ind){
                            lock_as_of_date.LockAsOfDate.validateCell(row,ind)
                        });
                    });
                break;

                case 'delete' :
                    delete_lock_as_of_date();
                break;

                case 'excel':
                    lock_as_of_date.LockAsOfDate.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;

                case 'pdf':
                    lock_as_of_date.LockAsOfDate.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
                    
                default:
                break;
            }
        }

        lock_as_of_date.toolbar_click = function(id) {
            switch(id) {
                case "save":
                    save_lock_as_of_date();
                break;

                default:
                break;
            }
           
        }

        function grid_row_click(id) {

            if (has_rights_lock_as_of_date_iu) {
                lock_as_of_date.lock_as_of_date_menu.setItemEnabled('delete');
            }

        }

        function save_lock_as_of_date() {
            var grid_xml = "<Root><GridGroup><Grid>";
            var row_ids = lock_as_of_date.LockAsOfDate.getChangedRows();
            var grid_label = "Lock As Of Date"; 

            if (row_ids != "") {
                lock_as_of_date.LockAsOfDate.setSerializationLevel(false,false,true,true,true,true);
                attached_obj = lock_as_of_date.LockAsOfDate;
                var grid_status = lock_as_of_date.validate_form_grid(attached_obj,grid_label);

                if (grid_status) {
                    lock_as_of_date.LockAsOfDate.forEachRow(function(id) {
                        grid_xml += "<GridRow ";
                            for (var cellIndex = 0; cellIndex < lock_as_of_date.LockAsOfDate.getColumnsNum(); cellIndex++){
                            grid_xml += " " + lock_as_of_date.LockAsOfDate.getColumnId(cellIndex) + '="' + lock_as_of_date.LockAsOfDate.cells(id,cellIndex).getValue() + '"';
                            }
                        grid_xml += " ></GridRow> ";
                    });
                }

                grid_xml += "</Grid></GridGroup></Root>";

                if (grid_status) {
                    data = {
                        "action": "spa_lock_as_of_date",
                        "flag": "i",
                        "xml": grid_xml
                    };

                adiha_post_data("return_array", data, "", "", "save_lock_as_of_date_callback","");
                }  
            } else {
                show_messagebox("No change in the grid.");
            } 
        }

        function save_lock_as_of_date_callback(result) {

            if (result[0][0] == 'Success') {
                dhtmlx.message({
                    text:'Changes have been saved successfully.',
                    expire:1000
                });
                lock_as_of_date.load_lock_as_of_date_grid();
            } else if(result[0][0] == 'Error') {
                dhtmlx.message({
                    type: "alert-error",
                    title: "Error",
                    text:'Duplicate data in (<b>Subsidiary and Close Date</b>).',
                    expire:1000
                });
            }

        }

        lock_as_of_date.validate_form_grid = function(attached_obj,grid_label) {;
            var status = true;
            for (var i = 0;i < attached_obj.getRowsNum();i++){
                var row_id = attached_obj.getRowId(i);
                for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    if(validation_message != "" && validation_message != undefined){
                        var column_text = attached_obj.getColLabel(j);
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                        dhtmlx.alert({title:"Error",type:"alert-error",text: error_message});
                        status = false; break;
                    }
                }
                if(validation_message != "" && validation_message != undefined){ break;};
            } 
            return status;
        }

        function delete_lock_as_of_date() {
            var selected_id = lock_as_of_date.LockAsOfDate.getSelectedId();
            var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
            selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];
            var lock_as_of_date_id = '';
          
            if(selected_id == null) {
                show_messagebox('Please select the data you want to delete.');
                return;
            }

            for (var i = 0; i < selected_id.length; i++) {
                lock_as_of_date_id += lock_as_of_date.LockAsOfDate.cells(selected_id[i], 0).getValue();
                lock_as_of_date_id += ',';
            }
            lock_as_of_date_id = lock_as_of_date_id.slice(0, -1);

            var data = {
                "action": "spa_lock_as_of_date",
                "flag": "d",
                "del_ids": lock_as_of_date_id
            };
            var confirm_msg = 'Are you sure you want to delete?';

            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: confirm_msg,
                callback: function(result) {
                    if (result)
                        adiha_post_data("alert", data, "", "", "lock_as_of_date.load_lock_as_of_date_grid");
                }
            });
        }

        lock_as_of_date.load_lock_as_of_date_grid = function() {
            var param = {
                "action": "spa_lock_as_of_date",
                "flag": "g",
                "grid_type": "g"
            };
            
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            lock_as_of_date.LockAsOfDate.clearAll();
            lock_as_of_date.LockAsOfDate.loadXML(param_url);
            lock_as_of_date.lock_as_of_date_menu.setItemDisabled('delete');
        }

    </script>
</html>    