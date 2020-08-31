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
    $php_script_loc = $app_php_script_loc;
    $application_function_id = 20007403; 
    $form_namespace = 'Run_Wacog_Process';

    //To get ID for deleting data
    if (isset($_POST['wacog_grp_name'])) {
        $wacog_group_name = $_POST['wacog_grp_name'];
    } else {
        foreach($_GET as $key => $value)
           $get_url = "$key: $value";
        list($param, $wacog_group_name) = split('[/.-]', $get_url);
    }
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.png", img_disabled: "tick_dis.png", text:"Ok", title: "Ok"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();
    
    /*$xml_file = "EXEC spa_default_asofdate 'c'";
    $return_value = readXMLURL($xml_file);
    $default_as_of_date = $return_value[0][0];

    $xml_user = "EXEC spa_get_regions @user_login_id= '" . $app_user_name . "'";
    $def = readXMLURL2($xml_user);
    $date_format = $def[0][date_format];*/
    $date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $date_format)));
    $default_as_of_date = date('Y-m-d');
    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:200},
                   {type:"input", position: "label-top", name:"wacog_group_name", label:"Wacog Group Name", offsetLeft:20, inputWidth:200, value:"' . $wacog_group_name . '", required:false, disabled:true},
                   {"type":"newcolumn"},
                   {type:"calendar", position: "label-top", name:"as_of_date", label:"As of Date", offsetLeft:20, inputWidth:200, dateFormat:"'.$date_format.'", serverDateFormat:"%Y-%m-%d", value:"' . $default_as_of_date . '", required:true},
                   {"type":"newcolumn"},
                   {type:"calendar", position: "label-top", name:"term_start", label:"Term Start", offsetLeft:20, inputWidth:200, required:true, dateFormat:"'.$date_format.'", serverDateFormat:"%Y-%m-%d"},
                   {"type":"newcolumn"},
                   {type:"calendar", position: "label-top", name:"term_end", label:"Term End", offsetLeft:20, inputWidth:200, required:true, dateFormat:"'.$date_format.'", serverDateFormat:"%Y-%m-%d"},
                  ]';
    echo $layout_obj->init_layout('run_wacog_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('run_wacog_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('run_wacog_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
?>
</body>
<script type="text/javascript">

    Run_Wacog_Process.toolbar_click = function(id) {        
        switch(id) {
            case "ok":
                var as_of_date = Run_Wacog_Process.run_wacog_form.getItemValue('as_of_date', true);
                var term_start = Run_Wacog_Process.run_wacog_form.getItemValue('term_start', true);
                var term_end = Run_Wacog_Process.run_wacog_form.getItemValue('term_end', true);
                parent.Setup_Wacog_Process.close_window(as_of_date, term_start, term_end);
                break;
        }
    }

</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>