
<?php
/**
* shipper_code_mapping screen
* @copyright Pioneer Solutions
*/
?>
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
            $function_id =  20016500;
            $form_namespace = 'shipper_code_mapping';
            $template_name = "setup_shipper_code_mapping";
            $form_obj = new AdihaStandardForm($form_namespace,  20016500);
            $form_obj->define_grid('ShipperCodeMapping', '', 'g', false, '', false);
            $form_obj->define_layout_width(350);

            $form_obj->define_custom_functions('save', '', '', 'form_loaded');
    
            echo $form_obj->init_form('Shipper Code Mapping');
            echo $form_obj->close_form();
            ?>
    </body>

    <script>

        $(function(){
            shipper_code_mapping.menu.removeItem('t1');
        });

        function add_menu_item(menu, newItem) {
            menu.addNewSibling(null, newItem.id, newItem.label, newItem.disabled, newItem.icons.enabled, newItem.icons.disabled)
            
            menu.attachEvent('onclick', function(id) {
                if (id == newItem.id) {
                    newItem.onclick();
                }
            })
        }

        function get_grid_xml(grid, row_ids) {
            var grid_xml = grid.getUserData('', 'deleted_xml') || '';

            var grid_rows_xml = ''
            
            if (row_ids != '') {
                grid_rows_xml = row_ids.split(',')
                    .map(get_grid_row_xml.bind(grid))
                    .join(''); 
            }

            var xml = '<Root>';
            xml += '<GridDelete>' + grid_xml + '</GridDelete>';
            xml += grid_rows_xml
            xml += '</Root>'

            return xml;
        }

        function get_grid_row_xml(row_id) {
            var data = this.getRowData(row_id);
            
            var row_attributes = Object.keys(data)
                .map(function(key){
                    return key + '="' + data[key] + '"'
                })
                .join(' ');

            return '<GridRow ' + row_attributes + '></GridRow>';
        }

        function get_inner_tab_layout(tab_text) {
            var layout;

            var active_tab_id = shipper_code_mapping.tabbar.getActiveTab();
            
            var inner_tabbar = shipper_code_mapping.tabbar.tabs(active_tab_id).getAttachedObject()
            
            var tab_id = inner_tabbar.getAllTabs().filter(function(e) {
                return inner_tabbar.cells(e).getText() == get_locale_value(tab_text)
            })[0];

            return inner_tabbar.cells(tab_id).getAttachedObject();
        }

        function refresh_detail_grid(callback) {
            var detail_grid_layout_cell = get_inner_tab_layout('General').cells('a');
            var grid_object =  detail_grid_layout_cell.getAttachedObject();

            detail_grid_layout_cell.getAttachedMenu().setItemDisabled('delete');

            var sql_param = {
                "action": 'spa_counterparty_shipper_info',
                "flag": 'k',
                "source_counterparty_id": shipper_code_mapping.tabbar.getActiveTab().replace('tab_', '')
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_object.clearAll();
            grid_object.load(sql_url, callback.bind(grid_object));
        }
        
        shipper_code_mapping.enable_menu_item = function(id, ind) {}

        shipper_code_mapping.form_loaded = function() {
            var detail_grid_layout_cell = get_inner_tab_layout('General').cells('a');
            var detail_grid =  detail_grid_layout_cell.getAttachedObject();
            var menu = detail_grid_layout_cell.getAttachedMenu();

            detail_grid.detachHeader(1);
            detail_grid.attachHeader('#text_filter,#text_filter,#combo_filter,#daterange_filter,#text_filter,#text_filter,#combo_filter,#combo_filter,#combo_filter,#text_filter,#combo_filter');

            detail_grid.attachEvent()

            menu.setItemDisabled('delete');

            var newItem = {
                after: null,
                id: 'refresh',
                label: 'Refresh',
                disabled: false,
                icons: {
                    enabled: 'refresh.gif',
                    disabled: 'refresh_dis.gif'
                },
                onclick: function(){
                    refresh_detail_grid(function() {
                        this.setUserData('', 'deleted_xml', '');
                    });
                }
            }

            add_menu_item(menu, newItem);
        }

        shipper_code_mapping.save = function(tab_id) {
            var grid = get_inner_tab_layout('General').cells('a').getAttachedObject();
            var status = shipper_code_mapping.validate_form_grid(grid, 'Shipper Code Mapping Detail');

            if (status) {
                var xml = get_grid_xml(grid, grid.getChangedRows());
                
                var data = {
                    'action': 'spa_counterparty_shipper_info',
                    'flag': 'i',
                    'xml': xml,
                    'source_counterparty_id': tab_id.replace('tab_', '')
                };

                adiha_post_data('alert', data, '', '', 'shipper_code_mapping.save_callback', '', '');
            }
        }

        shipper_code_mapping.save_callback = function(result) {
            if (result[0]['errorcode'] == 'Success') {
                var grid = get_inner_tab_layout('General').cells('a').getAttachedObject();

                refresh_detail_grid(function(){
                    this.setUserData('', 'deleted_xml', '');
                })
            }
        }

    </script>
</html>
