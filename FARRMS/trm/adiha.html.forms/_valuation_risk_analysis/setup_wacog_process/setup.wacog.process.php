<?php
/**
* Setup wacog process screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>

    <body>
        <?php
            $php_script_loc = $app_php_script_loc;
            $form_namespace = 'Setup_Wacog_Process';
            $rights_setup_wacog_process_iu = 20007401;
            $rights_setup_wacog_process_del = 20007402;
            $rights_setup_wacog_process_run = 20007403;
            $application_function_id = 20007400;

            $has_right_setup_wacog_process_iu = false;
            $has_right_setup_wacog_process_del = false;

            list(
                $has_right_setup_wacog_process_iu,
                $has_right_setup_wacog_process_del,
                $has_rights_setup_wacog_process_run
                ) = build_security_rights (
                $rights_setup_wacog_process_iu,
                $rights_setup_wacog_process_del,
                $rights_setup_wacog_process_run
            );

            $setup_wacog_process = get_sanitized_value($_GET['setup_wacog_process'] ?? '');

            $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
            $form_obj->define_grid("SetupWacogProcess");
            $form_obj->define_layout_width(350);
            $form_obj->define_custom_functions('', '', '', 'resolve_dropdown');
            echo $form_obj->init_form('WACOG Group Grid', 'WACOG Group Grid Details', $setup_wacog_process);
            echo $form_obj->close_form();
        ?>

        <script type="text/javascript">
            var has_right_setup_wacog_process_iu = '<?php echo $has_right_setup_wacog_process_iu ? $has_right_setup_wacog_process_iu : '0'; ?>';
            var has_rights_setup_wacog_process_del = '<?php echo $has_right_setup_wacog_process_del ? $has_right_setup_wacog_process_del : '0'; ?>';
            var has_rights_setup_wacog_process_run = '<?php echo $has_rights_setup_wacog_process_run ? $has_rights_setup_wacog_process_run : '0'; ?>';

            Setup_Wacog_Process.tabbarcell_data = {}

            $(function() {
                if (!has_right_setup_wacog_process_iu) {
                    Setup_Wacog_Process.menu.setItemDisabled('add');
                }
                Setup_Wacog_Process.menu.addNewSibling('t2', 'run', 'Run', true, 'run.gif', 'run_dis.gif');

                Setup_Wacog_Process.grid.attachEvent("onRowSelect", function (id, ind) {
                    if (!has_rights_setup_wacog_process_run) {
                        Setup_Wacog_Process.menu.setItemDisabled('run');
                    } else {
                        Setup_Wacog_Process.menu.setItemEnabled('run');
                    }
                    if (!has_rights_setup_wacog_process_del) {
                        Setup_Wacog_Process.menu.setItemDisabled('delete');
                    }
                });

                Setup_Wacog_Process.menu.attachEvent("onClick", function (id, zoneId, cas) {
                    if (id == 'run') {
                        Setup_Wacog_Process.run_wacog_process();
                    }
                });
            });

            /**
             * Remove blank values from array
             * @return  {Array} Filtered Array
             */
            function filter_array(arr) {
                var index = -1,
                    arr_length = arr ? arr.length : 0,
                    resIndex = -1,
                    result = [];

                while (++index < arr_length) {
                    var value = arr[index];
                    if (value) {
                        result[++resIndex] = value;
                    }
                }
                return result;
            }

            /**
             * Get data of every inner tabs inside of tabbar cell.
             * @param   {Object}    tabbarcell   Tabbar Cell
             * @return  {Object}    Data of Every tabs within Tabbar Cell
             */
            Setup_Wacog_Process.get_tabbarcell_data = function(tabbarcell) {
                var tab_obj = tabbarcell.getAttachedObject();

                var form_grid_objects = tab_obj.getAllTabs().reduce(function(obj, tab_id){
                    var tabbar_cell = tab_obj.tabs(tab_id);
                    var tab_text = tabbar_cell.getText();
                    var layout_obj = tab_obj.tabs(tab_id).getAttachedObject();

                    obj[tab_text] = {};

                    obj[tab_text]['tabbarcell'] = tabbar_cell;
                    obj[tab_text]['cells'] = layout_obj.items.reduce(function(data, cell){
                        data[cell._idd] = layout_obj.cells(cell._idd);
                        return data
                    }, {})

                    return obj;
                }, {})

                return form_grid_objects;
            }

            /**
             * Show/Hide Environmental tab
             * @param    {boolean}   state   Flag (show: true, hide: false)
             */
            Setup_Wacog_Process.hide_show_environmental_tab = function(state) {
                var environmental_tabbar_cell = Setup_Wacog_Process.tabbarcell_data['Environmental'].tabbarcell;
                if (state) {
                    environmental_tabbar_cell.show();
                } else {
                    environmental_tabbar_cell.hide();
                }
            }

            /**
             * General Tab form changed event callback
             */
            Setup_Wacog_Process.general_form_changed = function(name, value, state) {
                if (name == 'template_id') {
                    var field_name = 'deal_type';

                    if (this.getItemValue(name)) {
                        
                        if (temp != null) {
                            this.setItemValue(field_name, temp);
                        }

                        this.enableItem(field_name);
                    } else {
                        temp = this.getItemValue(field_name);
                        this.getCombo(field_name).unSelectOption();
                        this.disableItem(field_name);
                    }

                } else if (name == 'enable_environmental') {
                    Setup_Wacog_Process.hide_show_environmental_tab(state);
                }
            }
			
            /**
             * Changed event of Grid cell
             *
             *  @param   Integer    rId   row ID
             *  @param   Integer    cId   Column ID
             *  @param   Integer    nValue   Value
             */
            Setup_Wacog_Process.environmental_grid_cell_changed = function(rId, cInd, nValue) {
                var jurisdiction_index = this.grid.getColIndexById('jurisdiction');
                var default_jurisdiction_index = this.grid.getColIndexById('default_jurisdiction');
                var tier_index = this.grid.getColIndexById('tier');
                
                if (default_jurisdiction_index == cInd) {
                    jurisdiction_index = default_jurisdiction_index;
                    tier_index = this.grid.getColIndexById('default_tier');
                }
                
                if (jurisdiction_index == cInd) {
                    var patt = /^[0-9]/g;
                    var is_num = patt.test(nValue);

                    var ind_combo = this.grid.cells(rId, tier_index).getCellCombo();

                    var state_value = (is_num == false) 
                        ? this.grid.cells(rId, cInd).getValue() 
                        : nValue;
                    
                    ind_combo.clearAll();
                        
                    if(nValue == '&nbsp;'){
                        return
                    }
                    
                    this.layout_cell.progressOn();
                    
                    var cm_params = {
                        'action' : 'spa_wacog_group',
                        'flag' : 'j',
                        'jurisdiction_id' : state_value,
                        'has_blank_option' : 'true'
                    };

                    cm_params = $.param(cm_params);
                    
                    var urls = js_dropdown_connector_url + '&' + cm_params;
                    
                    var that = this;
                    ind_combo.load(urls, function() {
                        var depending_cell = that.grid.cells(rId, tier_index)
                        
                        var tier_value = (is_num == false) 
                            ? depending_cell.getValue()
                            : '';

                        ind_combo.show();
                        depending_cell.setValue(tier_value);
                        
                        that.layout_cell.progressOff();
                    });
                }
            }
            
            /**
             * Resolved Dropdown option selection
             *
             *  @param   Object    win  Windows
             *  @param   Integer    id   ID
             */
            Setup_Wacog_Process.resolve_dropdown = function(win, id) {
                Setup_Wacog_Process.tabbarcell_data = Setup_Wacog_Process.get_tabbarcell_data(win);

                var general_form_obj = Setup_Wacog_Process.tabbarcell_data['General'].cells.a.getAttachedObject();
                var environmental_cell = Setup_Wacog_Process.tabbarcell_data['Environmental'].cells.a
                var environmental_grid = environmental_cell.getAttachedObject();

                var counterparty_combo = general_form_obj.getCombo('source_counterparty_id');
                var contract_combo = general_form_obj.getCombo('contract_id');
				var cpty_vals = counterparty_combo.getCheckedComboValues();
				var ctr_vals = contract_combo.getCheckedComboValues();

				cpty_vals = filter_array(cpty_vals);
				$.each(cpty_vals, function(cpty_idx, cpty_val) {
					var cpty_ind = counterparty_combo.getIndexByValue(cpty_val);
					counterparty_combo.selectOption(cpty_ind);
					counterparty_combo.setChecked(cpty_ind, true);
				});

				ctr_vals = filter_array(ctr_vals);
				$.each(ctr_vals, function(ctr_idx, ctr_val) {
					var ctr_ind = contract_combo.getIndexByValue(ctr_val);
					contract_combo.selectOption(ctr_ind);
					contract_combo.setChecked(ctr_ind, true);
				});

                if(general_form_obj.getItemValue('template_id') == '' || general_form_obj.getItemValue('deal_type') == '') {
                    general_form_obj.disableItem('deal_type');
                }
                var show_hide_flag = general_form_obj.isItemChecked('enable_environmental');
                Setup_Wacog_Process.hide_show_environmental_tab(show_hide_flag);

                general_form_obj.attachEvent('onChange', function(name, value, state) {
                    Setup_Wacog_Process.general_form_changed(name, value, state);
                }.bind(general_form_obj))

                environmental_grid.attachEvent("onCellChanged", function(rId, cInd, nValue) {
                    Setup_Wacog_Process.environmental_grid_cell_changed.call({
                        grid: environmental_grid,
                        layout_cell: environmental_cell
                    },rId, cInd, nValue);
                });
            }

            /**
             * Run Wacog process
             */
            Setup_Wacog_Process.run_wacog_process = function() {
                dhxWins = new dhtmlXWindows();
                var grid = Setup_Wacog_Process.grid;

                var wacog_grp_name = grid.getSelectedRowId()
                    .split(',')
                    .map(function(row_id) {
                        var idx_wacog_group_name = grid.getColIndexById('wacog_group_name')
                        return grid.cells(row_id, idx_wacog_group_name).getValue();
                    })
                    .join(',');
                    
                param = 'run.wacog.process.php?is_pop=true';
                var post_param = {wacog_grp_name: wacog_grp_name}

                if (dhxWins.isWindow('w1')) {
                    w1.close();
                }

                w1 = dhxWins.createWindow("w1", 0, 0, 720, 420);
                w1.centerOnScreen();
                w1.setText('Run WACOG Group');
                w1.setModal(true);
                w1.denyMove();
                w1.denyResize();
                w1.button('minmax').hide();
                w1.button('park').hide();
                w1.attachURL(param, false, post_param);
            }

            /**
             * Close Window
             *
             *  @param   Date    as_of_date   As of Date
             *  @param   Date    term_start   Term Start
             *  @param   Date    term_end     Term End
             */
            Setup_Wacog_Process.close_window = function(as_of_date, term_start, term_end) {
                var grid = Setup_Wacog_Process.grid; 

                var wacog_grp_id = grid.getSelectedRowId()
                    .split(',')
                    .map(function(row_id) {
                        var idx_wacog_group_id = grid.getColIndexById('wacog_group_id');
                        return grid.cells(row_id, idx_wacog_group_id).getValue();
                    })
                    .join(',');

                if (as_of_date != null) {
                    data = {
                        "action": "spa_wacog_group",
                        "flag": "r",
                        "wacog_group_id": wacog_grp_id,
                        "as_of_date": as_of_date,
                        "term_start": term_start,
                        "term_end": term_end
                    }
                    result = adiha_post_data("alert", data, "", "", "");
                }

                if (dhxWins.isWindow('w1') == true) {
                    w1.close();
                }
            }
        </script>
    </body>
</html>