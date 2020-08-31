<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>  
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>
</head>
<body> 
    <?php
    $report_dataset_id = get_sanitized_value($_POST['report_dataset_id']);
    $process_id = get_sanitized_value($_POST['process_id']);
    $source_ids = get_sanitized_value($_POST['source_ids']);
    //print_r($_POST);
    
    $form_namespace = 'rm_load_csv';
    $layout_json = '[    
                {
                    id:             "a",        
                    text:           "Dataset Filters",
                    header:         false
                }
            ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    
    // attach menu
    $menu_json = '[
            {id: "start_csv_load_job", text: "Generate", img: "gen_sample_data.gif", imgdis:"gen_sample_data_dis.gif", enabled: 1}
            
        ]';
    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("menu_csv", "a");  
    echo $menu_obj->init_by_attach("menu_csv", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.fx_menu_csv_click');
    
    $form_csv = new AdihaForm();
    $form_csv_name = 'form_csv';
    echo $layout_obj->attach_form($form_csv_name, 'a');
    $form_csv->init_by_attach($form_csv_name, $form_namespace);
    
    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'f', @process_id='$process_id', @report_dataset_id='$report_dataset_id'";
    $data_form_json = readXMLURL2($sp_url);
    echo $form_csv->load_form($data_form_json[0]['form_json']);
    
    echo $layout_obj->close_layout();
    ?>
</body>
  
<script type="text/javascript">
    //var rm_load_csv = {};
    var post_data = '';
    
    var process_id = '<?php echo $process_id; ?>';
    var report_dataset_id = '<?php echo $report_dataset_id; ?>';
    var source_ids = '<?php echo $source_ids; ?>';
    
    var win_load_csv = parent.dhx_wins.window('win_load_csv'); //parent means report.manager.dhx.php
        
    $(function() {
        var source_ids = '<?php echo $source_ids; ?>';
        //fx_init_layout_csv();
        //disable freetext on combo items.
        rm_load_csv.form_csv.forEachItem(function(name){
            var item_type = rm_load_csv.form_csv.getItemType(name);

            if(item_type == 'combo') {
                var cmb_obj = rm_load_csv.form_csv.getCombo(name);
                //console.log(name);
                //console.log(cmb_obj);
                cmb_obj.allowFreeText(false);
            }
        });
 
        var view_id_base_no =  100000000 + parseInt(source_ids);
        attach_browse_event('<?php echo $form_namespace . '.' . $form_csv_name; ?>', view_id_base_no);
    });
    
    rm_load_csv.fx_menu_csv_click = function(id) {
        switch(id) {
            case "start_csv_load_job":
                if(!validate_form(rm_load_csv.form_csv))
                    return;
                rm_load_csv.fx_start_load_csv_job();
                break;  
                       
        }
    };
    
    rm_load_csv.fx_start_load_csv_job = function() {
        var column_info_arr = [];
        rm_load_csv.form_csv.forEachItem(function(name){
            var item_type = rm_load_csv.form_csv.getItemType(name);
            //console.log(item_type);
            if (item_type != 'fieldset' && item_type != 'block' && item_type != 'button' && name!= 'book_structure' && name!='no_filters') {
                
               if (item_type == 'calendar') {
                    var date_obj = rm_load_csv.form_csv.getCalendar(name);
                    var value = date_obj.getFormatedDate("%Y-%m-%d");
                } else {
                    value = rm_load_csv.form_csv.getItemValue(name);
                    if (typeof(value) == 'object') {
                        value = (value.toString()).replace(/,/g, "!");
                    } else {
                        value = value.replace(/,/g, "!");
                    }   
                }
                
                if (name == 'subsidiary_id') { name = 'sub_id'; }
                if (name == 'strategy_id') { name = 'stra_id'; }
                if (name == 'subbook_id') { name = 'sub_book_id'; }
                
                if (name.indexOf('label_') == -1) {
                    if (value == '') { 
                        column_info_arr.push(name + '=NULL');
                    } else {
                        //if ((name == 'sub_id') || (name == 'stra_id') || (name == 'sub_book_id') || (name == 'book_id')) { value = "'" + value + "'";}
                        column_info_arr.push(name + '=' + value);
                    }
                }
            }
        });
        
        // var report_dataset_csv_path = js_config_file.replace(/\\\\/g,'\\').split('\\');
        // report_dataset_csv_path = report_dataset_csv_path.filter(function(data) {
        //     return (data != 'trmclient' && data != 'setclient' && data != 'fasclient' && data != 'recclient'&& data != 'adiha.config.ini.rec.php');
        // }).join('\\') + '\\trm\\adiha.php.scripts\\dev\\report_manager_views\\';
                
        //append timestamp to make every job unique when user tries to generate sample data multiple times on same report
        var timestamp = Date.now().toString();
        
        var sp_string = "EXEC spa_run_sp_as_job @run_job_name='RFX Generate Dataset Sample CSV (" + process_id + "^" + timestamp + ")'" +
                        ", @spa='spa_rfx_report_dataset_generate_csv_dhx @flag=''g''" + 
                                //", @csv_write_path=''" + report_dataset_csv_path + "''" + 
                                ", @process_id=''" + process_id + "''" + 
                                ", @parameter_values=''" + column_info_arr.join(',') + "'''" +
                        ", @proc_desc='Generate Dataset CSV files.'" +
                        ", @user_login_id='" + js_user_name + "'" +
                        ", @job_subsystem='TSQL'"
        //console.group(sp_string);return;
        post_data = { sp_string: sp_string };
                    
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            parent.success_call('Job for Generate sample CSV started.');
            win_load_csv.close();
        });
    }
    
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>
</html>
        
    