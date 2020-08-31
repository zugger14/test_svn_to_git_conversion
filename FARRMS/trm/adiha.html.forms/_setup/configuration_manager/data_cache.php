<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style>
        div#objectId {
            position: relative;
            width: 100%;
            height: 100%;
            overflow: auto;
            padding: 10px;
            background-color: #F3F2F2;
        }
    </style>
</head>
<body>
    <?php 
        // ini_set('display_errors', 1);
        // ini_set('display_startup_errors', 1);
        // error_reporting(E_ALL);
        
        $instance_cache = new DataCache();
        $version = $instance_cache->get_cache_version();
        $listkeys = $instance_cache->list_key('');

    ?>
     <div id="objectId" style="display: none;">
        <?php 
            if ($instance_cache->is_cache_server_exists()): ?>
                Cache Server Connected.
                <?php echo "<br>Version: ".($version ? $version : 'Cache server not responding.');
                ?>
        <?php else: ?>
            <p>Cache Server Connection Failed. Please Contact System Administrator.</p>
        <?php endif ?>
        
    </div>
   
<?php

  
    $theme_selected = 'js_dhtmlx_theme';
    $full_path = $app_php_script_loc . 'components/lib/adiha_dhtmlx/themes/' . $theme_selected . '/imgs/dhxform_web/';
    $php_script_loc = $app_php_script_loc;
    
    $layout = new AdihaLayout();
    $json = '[
        {
            id:             "a", 
            text:           "Cache Info",
            header: true,
            height: 85,
            collapse: false
        },
        {
            id:             "b", 
            text:           "List of Keys",
            header: true,
            collapse: false
        }
    ]';

    $key_source_data = "EXEC spa_manage_memcache @flag = 'e', @product_id = " . $farrms_product_id;
    $result_array = readXMLURL($key_source_data);
    $layout_name = 'layout_cache_details';
    $namespace = 'form_cache_details';
    echo $layout->init_layout($layout_name, '', '2E', $json, $namespace); 
    $cache_grid = new AdihaGrid();
    $grid_name = 'list_of_keys_grid';
    echo $layout->attach_grid_cell($grid_name, 'b');
    echo $layout->attach_status_bar("b", true);
    echo $cache_grid->init_by_attach($grid_name, $namespace);
    echo $cache_grid->set_header('SN,Key,Source');
    echo $cache_grid->set_widths(100,'');
    echo $cache_grid->set_column_types('ro,ro,ro');
    echo $cache_grid->enable_multi_select();
    echo $cache_grid->enable_paging(25,'pagingArea_b', true);
    echo $cache_grid->set_search_filter(true,true, "");
    echo $cache_grid->set_sorting_preference("str,str,str");
    echo $cache_grid->set_columns_ids('sn_id,key_id,source_id');
    echo $cache_grid->return_init();
    $menu_obj = new AdihaMenu();
    $menu_name = 'toolbar_manage_cache';
    echo $layout->close_layout();

?>
    <script>
        $(function() {
            var listkeys = '<?php echo json_encode($listkeys); ?>'
            var listkeys_arr = JSON.parse(listkeys);
            var key_source_data = '<?php echo json_encode($result_array); ?>'
            var key_source_data_arr = JSON.parse(key_source_data);
            var db_name = ('<?php echo $database_name;?>').toLowerCase();
            var row_num = 1;
            var grid = form_cache_details.layout_cache_details.cells('b').getAttachedObject();
            var source = '';
            var row_num = 1;

            // To include additional item in data cache grid, add key:source in below format
            var include_key_source = {
                10131000 : "Book Structure - Create and View Deal"
            };

            key_source_data_arr.forEach(function(e,r) {
                for(i= 0; i<listkeys_arr.length; i++) {
                    var has_prefix = (listkeys_arr[i].indexOf(e[1]) >= 0);
                    var has_suffix = (e[2] == listkeys_arr[i].substr(listkeys_arr[i].length - e[2].length));

                    Object.keys(include_key_source).forEach(function (key) {
                        if (e[1].indexOf(key) > 1) {
                            var is_exists = listkeys_arr[i].indexOf(key);
                            if (is_exists > 0) {
                                source = include_key_source[key];
                                grid.addRow(row_num, row_num + ',' + listkeys_arr[i] + ',' + source, grid.getRowsNum());
                                row_num++
                            }
                        }
                    });

                    if( has_suffix && has_prefix ) {
                        source = e[0];
                        grid.addRow(row_num, row_num +','+ listkeys_arr[i] + ',' + source, grid.getRowsNum());
                        row_num++ 
                    } else if(e[2] == '') {
                        var has_no_suffix1 =  (listkeys_arr[i].substr(listkeys_arr[i].length - e[2].length) != listkeys_arr[i].match(/[\d]+_[a-z]$/i));
                        var has_no_suffix2 =  (listkeys_arr[i].substr(listkeys_arr[i].length - e[2].length) != listkeys_arr[i].match(/_[a-z]$/i));

                        if(has_prefix && has_no_suffix1 && has_no_suffix2) {
                            source = e[0];
                           grid.addRow(row_num, row_num +','+ listkeys_arr[i] + ',' + source, grid.getRowsNum());
                            row_num++
                       }
                    }
                }
            });

            var ids=grid.getAllRowIds();
            if(ids) {
                var keys_with_sources = ids.split(',').reduce(function(acc, curr) {
                    key = grid.cells(curr,1).getValue();
                    acc.push(key); 
                    return acc;
                },[]);
                var keys_with_no_source = listkeys_arr.filter(function (e) {  //add keys with no source in the grid
                    return keys_with_sources.indexOf(e) == -1;
                    });  
                keys_with_no_source.forEach(function(e) {
                   var has_db_name = e.indexOf(db_name)!=-1;
                   var has_PH_ = e.indexOf('_PH_') != -1;
                   var has_RPTRM_ = e.indexOf('_RPTRM_') != -1;
                    if(has_db_name && has_PH_ ) { 
                        source = 'Book Structure';
                        grid.addRow(row_num, row_num +','+ e + ',' + source, grid.getRowsNum());
                        row_num++
                    }else  if (has_db_name && has_RPTRM_) {
                        source = 'Non Std Report';
                        grid.addRow(row_num, row_num +','+ e + ',' + source, grid.getRowsNum());
                        row_num++
                    } else if(has_db_name) {
                        source = 'N/A';
                        grid.addRow(row_num, row_num +','+ e + ',' + source, grid.getRowsNum());
                        row_num++
                    }
                });
            }

            var theme_selected = js_dhtmlx_theme;
            form_cache_details.layout_cache_details.cells('a').attachObject("objectId");
            var grid_menu = form_cache_details.layout_cache_details.cells('b').attachMenu({
               icons_path: js_image_path + "dhxmenu_web/"
            });

            var menu_json = [
                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                {id:"edit", text:"Edit", img:"edit.gif", items:[
                    /*{id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", title: "Add", disabled:false},*/
                     {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete", disabled:false},
                     {id:"reset", text:"Reset", img:"reset.png", imgdis:"reset_dis.png", title: "Reset Cache", disabled:false},
                ]},
                {id:"process", text:"Process", img:"process.gif", items:[
                    {id:"view", text:"View", img:"view.gif", imgdis:"view_dis.gif", title: "View", disabled:false},
                     
                ]},
            ]
            grid_menu.loadStruct(menu_json); 

            grid_menu.attachEvent('onClick', form_cache_details.grid_menu_click);
            form_cache_details.layout_cache_details.cells('b').attachStatusBar({
                height : 30,
                text : '<div id="pagingArea_c"></div>'
            });
                
        });

        form_cache_details.grid_menu_click = function(id) {
            switch(id) {
                case 'refresh':
                form_cache_details.refresh_keys_grid();
                break;

                case 'delete':
                form_cache_details.delete_grid_rows();
                break;

                case 'reset':
                form_cache_details.reset_all();
                break;

                case 'view':
                form_cache_details.view_source();
            }
        }

        form_cache_details.refresh_keys_grid = function() {
            location.reload();
        }

        form_cache_details.delete_grid_rows = function() {
            var grid = form_cache_details.layout_cache_details.cells('b').getAttachedObject();
            var selectedId = grid.getSelectedRowId();
            var prefixes = selectedId.split(',').reduce(function(acc, curr){
                key = grid.cells(curr,1).getValue();
                acc.push(key); 
                return acc;
            },[]).join(',');

            $.post(js_php_path + 'components/process_cached_data.php', {'prefix': prefixes,'farrms_client_dir':'<?php echo $farrms_client_dir; ?>'}, function(data, textStatus, xhr) {
                grid.deleteSelectedRows();
            });
            form_cache_details.refresh_keys_grid();
            dhtmlx.message("Selected Keys have been deleted successfully!");
        }

        form_cache_details.reset_all = function() {
            var grid = form_cache_details.layout_cache_details.cells('b').getAttachedObject();
            $.post(js_php_path + 'components/process_cached_data.php', {'delete_all': 1,'farrms_client_dir':'<?php echo $farrms_client_dir; ?>'}, function(data, textStatus, xhr) {
            });
            grid.clearAll();
            setTimeout(function() { 
                form_cache_details.refresh_keys_grid();
                dhtmlx.message("All Keys have been deleted successfully!");
             }, 3000);
            
        }

        form_cache_details.view_source = function() {
            var grid = form_cache_details.layout_cache_details.cells('b').getAttachedObject();
            var selectedId = grid.getSelectedRowId();
            var key = grid.cells(selectedId,1).getValue();
            $.post(js_php_path + 'components/process_cached_data.php', {'key': key,'farrms_client_dir':'<?php echo $farrms_client_dir; ?>'}, function(data, textStatus, xhr) {
                source_data_window = new dhtmlXWindows();
                win = source_data_window.createWindow('w1', 10, 10, 830, 500);
                win.setText('View Source Data');
                win.maximize();
                win.centerOnScreen();
                win.setModal(true);

                var view_source_element = document.querySelector('#view_source');
                // create div of id view_source and add it to DOM after div of objectId
                if(!view_source_element) {
                    view_source_element = document.createElement('div');
                    view_source_element.id = 'view_source';
                    view_source_element.setAttribute('style', 'height: 100%');

                    div_text_element = document.createElement('div');
                    div_text_element.id = 'text';
                    div_text_element.setAttribute('style', 'overflow:auto; height:100% ');

                    view_source_element.appendChild(div_text_element);
                    var objectId_element = document.querySelector('#objectId');

                    objectId_element.parentNode.insertBefore(view_source_element, objectId_element.nextSibling);
                }
                document.getElementById("text").innerHTML = data;
                source_data_window.window('w1').attachObject("view_source");
            });
        }
    </script>
</body>