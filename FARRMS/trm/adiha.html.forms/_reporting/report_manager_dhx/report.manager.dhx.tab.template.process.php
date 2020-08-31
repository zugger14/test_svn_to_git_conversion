<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
    <?php
        $template_id = get_sanitized_value($_GET['template_id'] ?? '');
        $file_name = get_sanitized_value($_GET['file_name'] ?? '');
        $report_name = get_sanitized_value($_GET['report_name'] ?? '');
		
		
		$layout = new AdihaLayout();
        $json = '[
                {
                    id:             "a",
                    text:           "PowerBI Report Template Deploy",
                    header:         false,
                    width:          400,
                    height:         250,
                    collapse:       false,
                    fix_size:       [false,null]
                }
            ]';
            
        $layout_name = 'layout_deploy';
        $name_space = 'form_report_template';
        $form_name = 'form_report_template';
        echo $layout->init_layout($layout_name, '', '1C', $json, $name_space);
        
        // Attaching Form
        $form_object = new AdihaForm();
		$general_form_structure = "[
			{type: 'upload', multiple: false, mode: 'html5', autoStart: true, name: 'report_files', url: 'report.manager.dhx.tab.template.process.upload.php?mode=upload&report_name=" . $report_name . "&filename=" . $file_name . "&paramset_id=" . $template_id . "', label: '', width: 300, position: 'absolute', inputLeft: 5, inputTop: 50, labelLeft: 5, labelTop: 130, labelWidth: 160, className: 'combo_source_system_css'}
        ]";        
		 
        echo $layout->attach_form($form_name, 'a');    
        echo $form_object->init_by_attach($form_name, $name_space);
        echo $form_object->load_form($general_form_structure);
        
        echo $layout->close_layout();
    ?>
    <script>
        $(function(){
            //var file_uploader = form_report_template.form_report_template.getUploader('report_files');
            //file_uploader.clear();  
            
            
            form_report_template.form_report_template.attachEvent("onUploadFile",function(realName,serverName){
                custom_report_upload_callback(true);
                var custom_report_uploader = form_report_template.form_report_template.getUploader('report_files');
                custom_report_uploader.clear();
            });
            
            form_report_template.form_report_template.attachEvent("onUploadFail", function(realName, extra) {
                dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text:extra.msg
                        });

                var custom_report_uploader = form_report_template.form_report_template.getUploader('report_files');
                custom_report_uploader.clear();
                
            });
        });
        
        function custom_report_upload_callback(bool_val) {
            parent.custom_report_upload_callback(bool_val);
        }
        
    </script>
    
    </body>
</html>