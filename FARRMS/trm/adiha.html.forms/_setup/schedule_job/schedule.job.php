<?php
/**
* Schedule job screen
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
    </head>
    <body>
        <?php
            $form_name = 'form_view_scheduled_job';

            $rights_scheduled_job_edit = 10101601;
            $rights_scheduled_job_del = 10101610;
            $rights_scheduled_job_run = 10101611;

            list(
                $has_rights_scheduled_job_edit,
                $has_rights_scheduled_job_del,
                $has_rights_scheduled_job_run
            ) = build_security_rights(
                $rights_scheduled_job_edit,
                $rights_scheduled_job_del,
                $rights_scheduled_job_run
            );

            $sp_url = "EXEC spa_get_schedule_job @flag = 'h'"; 
            $sp_xml = readXMLURL($sp_url);
            $is_user_on_admin_group = isset($sp_xml[0][0]) ? $sp_xml[0][0] : 0;
            
            $layout_json = '[
                {
                    id: "a",
                    text: "View Scheduled Job",
                    header: false
                }
            ]';
            
            $name_space = 'view_scheduled_job';
            $view_scheduled_job_layout = new AdihaLayout();
            echo $view_scheduled_job_layout->init_layout('view_scheduled_job_layout', '', '1C', $layout_json, $name_space);
            
            $grid_name='grd_view_scheduled_job';
            echo $view_scheduled_job_layout->attach_grid_cell($grid_name, 'a');
            $grid_view_scheduled_job = new GridTable('view_scheduled_job');
            echo $grid_view_scheduled_job->init_grid_table($grid_name, $name_space);
            echo $grid_view_scheduled_job->set_search_filter(false, '#text_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#combo_filter,#text_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#text_filter');
            echo $grid_view_scheduled_job->enable_multi_select(true);
            echo $grid_view_scheduled_job->return_init();
            echo $grid_view_scheduled_job->load_grid_data("EXEC spa_get_schedule_job @flag='s'");
            echo $grid_view_scheduled_job->load_grid_functions();
            echo $grid_view_scheduled_job->attach_event('', 'onRowSelect', 'grd_scheduled_jobs_click');
            echo $grid_view_scheduled_job->attach_event('', 'onRowDblClicked', 'function() {
                run_toolbar_click("update");
            }');
            
            $toolbar_scheduled_jobs = 'jobs_toolbar';

            $toolbar_json = '[
                {id:"refresh", img:"refresh.gif", text:"Refresh", title:"Refresh"},
                {id: "process", text: "Process", img:"process.gif", items: [
                    {id:"run", img:"run.png", imgdis:"run_dis.png", text:"Run", title:"run", hidden: false},
                    {id:"run_as_copy", img:"run_as_copy.png", imgdis:"run_as_copy_dis.png", text:"Run as Copy", title:"Run as Copy", hidden: true},
                    {id:"enable", img:"enable.png", imgdis:"enable_dis.png", text:"Enable", title:"Enable", hidden: true},
                    {id:"disable", img:"disable.png", imgdis:"disable_dis.png", text:"Disable", title:"Disable", hidden: true},
                    {id:"stop", img:"stop.png", imgdis:"stop_dis.png", text:"Stop", title:"Stop", hidden: true}
                ]},    
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"update", img:"edit.gif", imgdis:"edit_dis.gif", text:"Update", title:"update", disabled: true},
                    {id:"delete", img:"trash.gif", imgdis:"trash_dis.gif", text:"Delete", title:"Delete", disabled: true},
                ]},
                {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                ]}
            ]';
            
            $toolbar_view_scheduled_job = new AdihaMenu();
            echo $view_scheduled_job_layout->attach_menu_cell($toolbar_scheduled_jobs, "a");
            echo $toolbar_view_scheduled_job->init_by_attach($toolbar_scheduled_jobs, $name_space);
            echo $toolbar_view_scheduled_job->load_menu($toolbar_json);
            echo $toolbar_view_scheduled_job->attach_event('', 'onClick', 'run_toolbar_click');
            
            echo $view_scheduled_job_layout->close_layout();         
        ?>

        <script type="text/javascript"> 
            var has_rights_scheduled_job_edit = Boolean(<?php echo $has_rights_scheduled_job_edit; ?>);
            var has_rights_scheduled_job_del = Boolean(<?php echo $has_rights_scheduled_job_del; ?>);
            var has_rights_scheduled_job_run = Boolean(<?php echo $has_rights_scheduled_job_run; ?>);
            var is_user_on_admin_group = '<?php echo $is_user_on_admin_group;?>';
            
            $(function(){
                view_scheduled_job.jobs_toolbar.setItemDisabled('enable');
                view_scheduled_job.jobs_toolbar.setItemDisabled('disable');
                view_scheduled_job.jobs_toolbar.setItemDisabled('stop');
                view_scheduled_job.jobs_toolbar.setItemDisabled('run');
                view_scheduled_job.jobs_toolbar.setItemDisabled('run_as_copy');
            })

            function grd_scheduled_jobs_click(row_id) {
                var run_status_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('run_status');
                var run_status = view_scheduled_job.grd_view_scheduled_job.cells(row_id, run_status_col_index).getValue().toLowerCase();
                var job_next_run_col_id = view_scheduled_job.grd_view_scheduled_job.getColIndexById('next_scheduled_run_date');
                var job_next_run = view_scheduled_job.grd_view_scheduled_job.cells(row_id, job_next_run_col_id).getValue();
                var is_enabled_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('is_enabled');
                var is_enabled = view_scheduled_job.grd_view_scheduled_job.cells(row_id, is_enabled_col_index).getValue().toLowerCase();
				var user_name_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('user_name');
                var user_name = view_scheduled_job.grd_view_scheduled_job.cells(row_id, user_name_col_index).getValue();
                var job_owner_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('owner_sid');
                var job_owner = view_scheduled_job.grd_view_scheduled_job.cells(row_id, job_owner_col_index).getValue().toLowerCase();

                // For system jobs
                if (job_owner == 'system job') {
                    if (is_user_on_admin_group == 1) {
                        if (run_status == 'in progress') view_scheduled_job.jobs_toolbar.setItemEnabled('stop');
                        else view_scheduled_job.jobs_toolbar.setItemDisabled('stop');    
                    
                        if (is_enabled == 'no') {
                            view_scheduled_job.jobs_toolbar.setItemEnabled('enable');
                            view_scheduled_job.jobs_toolbar.setItemDisabled('disable');
                        } else {
                            view_scheduled_job.jobs_toolbar.setItemEnabled('disable');
                            view_scheduled_job.jobs_toolbar.setItemDisabled('enable');
                        }

                        if (run_status !='in progress') view_scheduled_job.jobs_toolbar.setItemEnabled('run');
                        else view_scheduled_job.jobs_toolbar.setItemDisabled('run');

                        view_scheduled_job.jobs_toolbar.setItemEnabled('run_as_copy');
                    } else {
                        disable_menu_items();
                    }
                    view_scheduled_job.jobs_toolbar.setItemDisabled('update');
                    view_scheduled_job.jobs_toolbar.setItemDisabled('delete');
                }

                //For non system jobs
                if (user_name.toLowerCase() == js_user_name.toLowerCase() || job_owner != 'system job') {
                    if(has_rights_scheduled_job_edit) {
                        if (job_next_run != '') view_scheduled_job.jobs_toolbar.setItemEnabled('update');
                        else view_scheduled_job.jobs_toolbar.setItemDisabled('update');

                        if (run_status == 'in progress') view_scheduled_job.jobs_toolbar.setItemEnabled('stop');
                        else view_scheduled_job.jobs_toolbar.setItemDisabled('stop');    

                        if (is_enabled == 'no') {
                            view_scheduled_job.jobs_toolbar.setItemEnabled('enable');
                            view_scheduled_job.jobs_toolbar.setItemDisabled('disable');
                        } else {
                            view_scheduled_job.jobs_toolbar.setItemEnabled('disable');
                            view_scheduled_job.jobs_toolbar.setItemDisabled('enable');
                        }

                        if (run_status !='in progress') view_scheduled_job.jobs_toolbar.setItemEnabled('run');
                        else view_scheduled_job.jobs_toolbar.setItemDisabled('run');
                    } else {
                        view_scheduled_job.jobs_toolbar.setItemDisabled('update');
                        view_scheduled_job.jobs_toolbar.setItemDisabled('stop');
                        view_scheduled_job.jobs_toolbar.setItemDisabled('enable');
                        view_scheduled_job.jobs_toolbar.setItemDisabled('disable');
                        view_scheduled_job.jobs_toolbar.setItemDisabled('run');
                    }

                    if (has_rights_scheduled_job_del) view_scheduled_job.jobs_toolbar.setItemEnabled('delete');
                    else view_scheduled_job.jobs_toolbar.setItemDisabled('delete');
                    if (has_rights_scheduled_job_run) {
                        if(run_status != 'in progress') {
                            view_scheduled_job.jobs_toolbar.setItemEnabled('run');
                        } else {
                            view_scheduled_job.jobs_toolbar.setItemDisabled('run');
                        }
                        view_scheduled_job.jobs_toolbar.setItemEnabled('run_as_copy');
                    } else {
                        view_scheduled_job.jobs_toolbar.setItemDisabled('run_as_copy');
                    }   
                }
            }

            function run_toolbar_click(id) {    
                switch(id) {
                    case 'refresh':
                        view_scheduled_job.refresh_grid('', disable_menu_items);
                        break;
                    case 'update':
                        var row_id = view_scheduled_job.grd_view_scheduled_job.getSelectedRowId();
                        var batch_type_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('batch_type');
                        var batch_type = view_scheduled_job.grd_view_scheduled_job.cells(row_id, batch_type_col_index).getValue();
                        var job_row_id = view_scheduled_job.grd_view_scheduled_job.getSelectedRowId();
                        var job_next_run_col_id = view_scheduled_job.grd_view_scheduled_job.getColIndexById('next_scheduled_run_date');
                        var job_next_run = view_scheduled_job.grd_view_scheduled_job.cells(job_row_id, job_next_run_col_id).getValue();
                        var job_id_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('job_id');
                        var job_id = view_scheduled_job.grd_view_scheduled_job.cells(job_row_id, job_id_col_index).getValue();
                        var job_name_col_id = view_scheduled_job.grd_view_scheduled_job.getColIndexById('name');
                        var job_name = view_scheduled_job.grd_view_scheduled_job.cells(job_row_id, job_name_col_id).getValue();
                        var user_name_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('user_name');
                        var user_name = view_scheduled_job.grd_view_scheduled_job.cells(row_id, user_name_col_index).getValue();
                        var job_owner_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('owner_sid');
                        var job_owner = view_scheduled_job.grd_view_scheduled_job.cells(row_id, job_owner_col_index).getValue().toLowerCase();

                        if (job_next_run == '' || (user_name.toLowerCase() != js_user_name.toLowerCase() && is_user_on_admin_group == 0)  || !has_rights_scheduled_job_edit) {
                            return;
                        }

                        var title = 'Edit Job Schedule';
                        var job = (job_next_run != 'NULL') ? 's' : 'r';
                        var param = 'job_id=' + job_id + '&flag=u&job=' + job + '&job_name=' + job_name + '&batch_type=' + batch_type;
                        var exec_call = '';
                        
                        adiha_run_batch_process(exec_call, param, title);
                        break;
                    case 'run_as_copy':
                        var row_id = view_scheduled_job.grd_view_scheduled_job.getSelectedRowId();
                        var job_row_id = view_scheduled_job.grd_view_scheduled_job.getSelectedRowId();
                        var job_id_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('job_id');
                        var job_id = view_scheduled_job.grd_view_scheduled_job.cells(job_row_id, job_id_col_index).getValue();
                        var batch_type_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('batch_type');
                        var batch_type = view_scheduled_job.grd_view_scheduled_job.cells(row_id, batch_type_col_index).getValue();
                        var title = 'Run Job as Copy';          
                        var param = 'job_id=' + job_id + '&call_from=view_schedule&batch_type=' + batch_type;
                        var exec_call = '';
                        
                        adiha_run_batch_process(exec_call, param, title);            
                        break;                        
                    case 'delete':
                        var job_id = get_selected_job_id();
                        data = {
                            'action': 'batch_report_process',
                            'flag': 'd',
                            'jobId': job_id
                        }

                        adiha_post_data('confirm', data, '', '', 'continue_to_refresh');
                        break;
                    case 'excel':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                        view_scheduled_job.grd_view_scheduled_job.toExcel(path);
                        break;
                    case 'pdf':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                        view_scheduled_job.grd_view_scheduled_job.toPDF(path);
                        break;
                    case 'enable':
                        var job_id = get_selected_job_id();
                        data = {
                            'action': 'spa_get_schedule_job',
                            'flag': 'e',
                            'job_id': job_id,
                            'enable' : 'y'
                        }
                        adiha_post_data('confirm', data, '', '', 'continue_to_refresh', '', 'Are you sure you want to enable?');
                        break;
                    case 'disable':
                        var job_id = get_selected_job_id();
                        data = {
                            'action': 'spa_get_schedule_job',
                            'flag': 'e',
                            'job_id': job_id,
                            'enable' : 'n'
                        }
                        adiha_post_data('confirm', data, '', '', 'continue_to_refresh', '', 'Are you sure you want to disable?');
                        break;
                    case 'run':
                        var job_id = get_selected_job_id();
                        data = {
                            'action': 'spa_get_schedule_job',
                            'flag': 'g',
                            'job_id': job_id
                        }
                        adiha_post_data('confirm', data, '', '', 'continue_to_refresh', '', 'Are you sure you want to run?');
                        break;
                    case 'stop':
                        var job_id = get_selected_job_id();
                        data = {
                            'action': 'spa_get_schedule_job',
                            'flag': 'f',
                            'job_id': job_id
                        }
                        adiha_post_data('confirm', data, '', '', 'continue_to_refresh', '', 'Stopping a job may take some time. Job status will be updated in grid upon refresh. Are you sure you want to stop?');
                        break;
                }
            }

            function continue_to_refresh(result) {
                if (result[0].errorcode == 'Success') {
                    view_scheduled_job.refresh_grid('', disable_menu_items);
                }
            }

            function get_selected_job_id() {
                var job_row_id = view_scheduled_job.grd_view_scheduled_job.getSelectedRowId();
                job_row_id = job_row_id.indexOf(",") > -1 ? job_row_id.split(",") : [job_row_id];
                var job_id_col_index = view_scheduled_job.grd_view_scheduled_job.getColIndexById('job_id');
                var job_id = '';
                var count = job_row_id.length;
                for (var i = 0; i < count; i++) {
                    job_id += view_scheduled_job.grd_view_scheduled_job.cells(job_row_id[i], job_id_col_index).getValue();
                    job_id += ',';
                }
                job_id = job_id.slice(0, -1);
                return job_id;
            }
            
            function disable_menu_items() {
                view_scheduled_job.jobs_toolbar.setItemDisabled('run_as_copy');
                view_scheduled_job.jobs_toolbar.setItemDisabled('delete');
                view_scheduled_job.jobs_toolbar.setItemDisabled('update');
                view_scheduled_job.jobs_toolbar.setItemDisabled('enable');
                view_scheduled_job.jobs_toolbar.setItemDisabled('disable');
                view_scheduled_job.jobs_toolbar.setItemDisabled('stop');
                view_scheduled_job.jobs_toolbar.setItemDisabled('run');
            }

        </script>
    </body>
</html>