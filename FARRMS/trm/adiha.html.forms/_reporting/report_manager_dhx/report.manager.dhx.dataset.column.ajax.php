<?php
/**
* Report manager dataset column ajax screen
* @copyright Pioneer Solutions
*/
?>
<?php
ob_start();
require_once('../../../adiha.php.scripts/components/include.file.v3.php');
require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
require_once('../report_manager_dhx/report.global.vars.php');
global $app_adiha_loc, $app_php_script_loc;
$rights_sql_save = 10201619;

$form_name = 'report_dataset_columns';
$process_id = get_sanitized_value($_GET['process_id'] ?? '');
$tsql = $_POST['tsql'];
$tsql = str_replace("'", "''", $tsql);
$tsql = "'" . $tsql . "'";

$source_id = get_sanitized_value($_GET['source_id'] ?? 'NULL');
$source_id = ($source_id == '' ? 'NULL' : $source_id); //added since issue when source_id='' is passed, previuosly handled and then removed when get_sanitized_value is used. :sligal,2019-11-15
$call_from = get_sanitized_value($_GET['call_from'] ?? 'NULL');
$criteria = $_GET['criteria'];
$with_criteria = $_GET['with_criteria'];
$require_parameters = array();
//var_dump($source_id);die();
$disabled_content = ($call_from == 'ds_view' || $call_from == 'ds_table') ? 'disabled' : '';

if ($with_criteria == 'n') {   
    $sql_query = "EXEC spa_rfx_grab_data_source_columns $source_id, '" . $process_id . "' , '', $tsql , 'n'";
    $sql_with_view = readXMLURL($sql_query);
    
    $criteria = prepare_sql_parameters($sql_with_view[0][0]);
    $return_required_param = $sql_with_view[0][1];// required params in the view 
}

function prepare_sql_parameters($tsql) {
    global $require_parameters;
    $parameter_string = '';
    $unesape_tsql = '"' . $tsql . '"'; //alert(unesape_tsql);    
    $test_array = array();

    if (preg_match_all('[@[^_]\w*]', $unesape_tsql, $parameter_array) > 0) {
        
        //remove invalid filters @', which is caused by optional param on view code
        $filter_columns = array_values(array_filter($parameter_array[0], function($v, $k) {
            return $v != "@'";
        }, ARRAY_FILTER_USE_BOTH));

        $sql_keywords = array(
            '@@FETCH_STATUS',
            '@@ROWCOUNT',
            '@@ERROR',
            '@@IDENTITY',
            '@@TRANCOUNT'
            //add others as required
        );
        //removed duplicate items in array and rejected sql keywords while formation of report filter.
        $filter_columns = array_values(array_filter(array_unique($filter_columns), function($val) {
            return !(in_array(strtoupper($val), $sql_keywords));
        }));
        //print '<pre>';print_r($filter_columns);print '</pre>';die();
        for ($j = 0; $j < count($filter_columns); $j++) {
            $filter_columns[$j] = preg_replace('[\@]', '', $filter_columns[$j]);
            $required_value = $filter_columns[$j];
            $filter_columns[$j] = $filter_columns[$j] . ' = 1900';

            if (!in_array($filter_columns[$j], $test_array)) { //prevent multiple data
                $test_array[$j] = $filter_columns[$j];
                array_push($require_parameters, $required_value);
            } else {
                continue;
            }
            
            $parameter_string = ($j == 0) ? $test_array[$j] : ($parameter_string . ", " . $test_array[$j]);
        }
    }

    return $parameter_string;
}

$temp_paramset = array();
$param_column_name = array();
$temp_paramset = explode(',', $criteria);
$counter = 0;

$open_window_set = array();
$open_window_set['browse_curve'] = 'Setup Price Curves';
$open_window_set['browse_location'] = 'Setup Location';
$open_window_set['BrowseMeter'] = 'Meter ID';
$open_window_set['browse_counterparty'] = 'Maintain Counterparty';
$open_window_set['browse_contract_counterparty'] = 'Contract';
$open_window_set['BrowseTrader'] = 'Trader';
$open_window_set['browse_curve_source'] = 'Curve Source';
$open_window_set['Browse_Risk_Measurement_Criteria'] = 'Risk Measurement Criteria';
$open_window_set['browse_view_shipment'] = 'View Shipment';
$open_window_set['browse_generator'] = 'Generator ';
$open_window_set['BrowseStorageAsset'] = 'Storage Asset';
$open_window_set['browseWacogGroup'] = 'Wacog Group';

foreach ($temp_paramset as $val) {
    $exploded_array = explode('=', trim($val));
    $param_column_name[$counter] = trim($exploded_array[0]);
    $counter++;
}

$sp_url = "EXEC spa_rfx_report_dataset_finalisesql @flag=w";
$report_widget = readXMLURL2($sp_url);

$sp_url = "EXEC spa_rfx_report_dataset_finalisesql @flag=d";
$report_datatype = readXMLURL2($sp_url);

ob_clean();

function get_default_template($datatype_id) {
    switch ($datatype_id) {
        case 3:case 4://INT
            return 2; //Number
            break;
        case 2://DATETIME
            return 4; //Date 
            break;
        case 1:case 5://VARCHAR
            return 0; //Text 
            break;
        default:
            return 0; //Text 
    }
}
?>
<form name= '<?php echo $form_name; ?>'>    
    <textarea id="xml_ds_columns" name="xml_ds_columns" style="display: none;"></textarea>
    <div id="ds_cols_div">
        <table id="datasource-region" class="data-table" width="100%">
            <thead>
                <tr class="ds_cols_th">
                    <th><?php echo get_locale_value('Name'); ?></th>
                    <th><?php echo get_locale_value('Alias'); ?></th>
                    <th><?php echo get_locale_value('Tooltip'); ?></th>
                    <!-- <th>Required Param</th> -->
                    <th><?php echo get_locale_value('Required Filter'); ?></th>
                    <!-- <th>Append in Filter</th> -->
                    <th><?php echo get_locale_value('Key Column'); ?></th>
                    <th><?php echo get_locale_value('Data Type'); ?></th> 
                    <th><?php echo get_locale_value('Render As'); ?></th> 
                    <th><?php echo get_locale_value('Widget Type'); ?></th>
                    <th><?php echo get_locale_value('Default Value'); ?></th>
                </tr>
            </thead>
            <tbody>
                <?php
                $sql = "EXEC spa_rfx_grab_data_source_columns  $source_id, '" . $process_id . "' , '$criteria', $tsql, 'y'";
                if($call_from == 'ds_view') {
                    $sql = "EXEC spa_rfx_grab_data_source_columns  @data_source_id=$source_id, @call_from='ds_view'";
                                    
                }                
                $column_list = readXMLURL($sql);
                
                if ($column_list[0][0] == 'Error') { //check if the query has errors
                    $missing_fields = array('check_query');
                    array_push($missing_fields, $column_list[0][1]);
					array_push($missing_fields, $column_list[0][2] -1);
                    ob_clean();
                    echo json_encode($missing_fields);
                    exit;
                } else {
                    $missing_fields = array('missing_parameters');
                }

                if (count($require_parameters) > 0) {
                    $selected_column_list = array(); 

                    for ($i = 0; $i < count($column_list); $i++) { //select all selected column list
                        array_push($selected_column_list, $column_list[$i][1]);
                    }

                    $missing_fields_list = array_diff($require_parameters, $selected_column_list); //find the fields that are missing

                    if (count($missing_fields_list) > 0) {
                        $split_return_required_param = explode(',', $return_required_param);

                        foreach ($missing_fields_list as $key => $value) {

                            if ($value != '') {

                                for ($j = 0; $j < count($split_return_required_param); $j++) {
                                    $test = explode('.', $split_return_required_param[$j]);

                                    if ($test[1] == $value) { //  checks if the value is same as that of the table column name                                              
                                        $value = $split_return_required_param[$j];
                                        $missing_string = ($missing_string == '') ? $value : ($missing_string . ', ' . $value);                                    
                                    }
                                }
                            }
                        }

                        $missing_fields[1] = $missing_string;
                    }
                }

                if (count($missing_fields) > 1 && $missing_string != '') {
                    ob_clean();
                    echo json_encode($missing_fields);
                    exit;
                }
                $row_count = 0;
                foreach ($column_list as $column):
                    $row_count ++;
                    $disabled = (in_array($column[1], $param_column_name)) ? 1 : 0;
                    ?>
                    <tr class =" clone" valign="top">
                        <td title="<?php echo $column[1]; ?>">
                            <input type="hidden" class="column-id" value="<?php echo $column[0]; ?>"/>
                            <input class="dataset-column" type="text" size="25" value="<?php echo $column[1]; ?>" disabled="1"/>
                        </td> 
                        <td> <input class="dataset-alias" type="text" size="25" value="<?php echo $column[2]; ?>" /> </td>
                        <td> <input class="dataset-tooltip" type="text" size="25" value="<?php echo $column[10]; ?>" /> </td>
                        <!-- <td>
                            <label>
                                <input type="checkbox" value="1" class="param-optional" 
                                <?php
                                if($call_from == 'ds_view') {
                                    echo ($column[3] == 1) ? 'checked' : '';
                                } else {
                                    echo ($disabled == 1) ? 'checked disabled="1"' : '';
                                    echo ($disabled == 0 && $column[3] == 1) ? 'checked' : '';
                                }
                                
                                ?> 
                                       /> 
                                       Yes
                            </label>
                        </td> -->
                        <td>
                            <label>
                                <input type="checkbox" value="1" class="required-filter"  
                                
                                <?php
                                if($disabled == 0) {
                                    echo 'disabled ';
                                }
                                if($column[13] == 1) {
                                    echo 'checked ';
                                }
                                ?>
                                 /> 
                                Yes
                            </label>
                        </td>
                        <!-- <td>
                            <label>
                                <input type="checkbox" value="1" class="append-filter" 
                                <?php 
                                if($call_from == 'ds_view') {
                                    echo ($column[4] == 1) ? 'checked' : '';
                                } else {
                                    echo ($disabled == 0) ? ($column[3] == 1 ? 'checked disabled="1"' : 'checked') : ' disabled="1"';
                                } 
                                ?> /> Yes
                            </label>
                        </td> -->
                        <td>
                            <label>
                                <input type="checkbox" value="1" class="key-column" <?php echo ($column[12] == 1 ) ? 'checked' : ''; ?> /> Yes
                            </label>
                        </td>
                        <td>
                            <select class="datatype-list" style="width:100px;" disabled="disabled">
                                <?php foreach ($report_datatype as $datatype): ?>
                                    <option value="<?php echo $datatype['report_datatype_id'] ?>" <?php echo ($column[6] == $datatype['report_datatype_id']) ? 'selected' : ''; ?>><?php echo $datatype['name'] ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td><?php
                            #custom map for defaulting
                            if ($column[11] == NULL) {
                                $column[11] = get_default_template($column[6]);
                            }
                                ?>
                            <select class="renderas-list" style="width:100px;" >
                                <?php foreach ($rdl_column_render_as_options as $renderas): ?>
                                    <option value="<?php echo $renderas[0] ?>" <?php echo ($column[11] == $renderas[0]) ? 'selected' : ''; ?>><?php echo $renderas[1] ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>
                        <td>
                            <select class=" datawidget-list" style="width:150px; vertical-align: top;" >
                                <?php foreach ($report_widget as $widget): ?>
                                    <option value="<?php echo $widget['report_widget_id'] ?>" 
                                    <?php
                                    //condition that provides the widget type according to the datatype and column name
                                    if ($column[7] != 'NULL' && $column[7] != NULL) {
                                        echo ($column[7] == $widget['report_widget_id']) ? 'selected' : '';
                                    } else {
                                        if ($column[6] == 2 && $widget['name'] == 'DATETIME') {
                                            echo 'selected';
                                        } else if (($column[1] == 'sub_id') && $widget['name'] == 'BSTREE-Subsidiary') {
                                            echo 'selected';
                                        } else if (($column[1] == 'strat_id' || $column[1] == 'stra_id') && $widget['name'] == 'BSTREE-Strategy') {
                                            echo 'selected';
                                        } else if (($column[1] == 'book_id') && $widget['name'] == 'BSTREE-Book') {
                                            echo 'selected';
                                        } else if (($column[1] == 'sub_book_id' || $column[1] == 'subbook_id') && $widget['name'] == 'BSTREE-SubBook') {
                                            echo 'selected';
                                        } else {										
                                            echo '';
                                        }
                                    }
                                    ?>
                                            >
                                                <?php echo $widget['name']; ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                            <span class="source-list-row" style="display:<?php echo($column[7] == '2' || $column[7] == '9') ? 'inline' : 'none' ?>;">
                                <?php $custom_sql = str_replace("_ADD_", "+", $column[9]); ?>
                                <textarea class="source-list" rows="4" cols="15"><?php echo $custom_sql; ?></textarea>&nbsp;
                            </span>                            
                            <span class="source-list-row-open-window" style="display:<?php echo($column[7] == '7') ? 'block' : 'none' ?>;">
                                <br />
                                <select class="source-list-open-window" style="width:150px; display: block; margin-top: 1px;" >
                                    <?php foreach ($open_window_set as $key => $val): ?>
                                        <option value="<?php echo $key; ?>" <?php echo ($column[9] == $key) ? 'selected' : ''; ?>><?php echo $val; ?></option>
                                    <?php endforeach; ?>
                                </select>                                
                            </span>
                        </td>
                        <td>
                            <input class="defult_value_list" type="text" size="15" value="<?php echo $column[8] ?>" /> 
                            <?php echo"<p id = '"; echo $row_count."error_mssg' style= 'margin-top: 0px;'></p>"?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>        
</form>
<script type="text/javascript">
    var disabled_content_gbl = '<?php echo $disabled_content; ?>';
    $(function() {
        //hideHourGlass();
        
        $('.datawidget-list').change(function() {
            var current_widget = $(this).val();
            
            if (current_widget == '2' || current_widget == '9') {
                $(this).parents('tr.clone').eq(0).find('.source-list-row').show();
                $(this).parents('tr.clone').eq(0).find('.source-list-row-open-window').hide();
                $(this).parents('tr.clone').eq(0).find('.source-list').val('');
            } else if (current_widget == '7') {
                $(this).parents('tr.clone').eq(0).find('.source-list-row-open-window').show();
                $(this).parents('tr.clone').eq(0).find('.source-list-row').hide();
            } else {
                $(this).parents('tr.clone').eq(0).find('.source-list-row').hide();
                $(this).parents('tr.clone').eq(0).find('.source-list-row-open-window').hide();
            }
        });
        
        $('.param-optional:checkbox').change(function () {
            if ($(this).is(':checked')) {
                $('.append-filter:checkbox', $(this).closest('tr')).prop('disabled', true);
                $('.append-filter:checkbox', $(this).closest('tr')).prop('checked', true);
            } else {
                $('.append-filter:checkbox', $(this).closest('tr')).prop('disabled', false);
                $('.append-filter:checkbox', $(this).closest('tr')).prop('checked', true);
            }
        });

        //disable contents when call from ds_view
        // add tbody in #ds_cols_div order to not disable thead
        if(disabled_content_gbl == 'disabled') {
            $('#ds_cols_div tbody').addClass('disabledArea');

        }
        
    });
</script>
<style type="text/css">

.disabledArea {
    pointer-events: none;
    opacity: 0.5;
}

</style>
