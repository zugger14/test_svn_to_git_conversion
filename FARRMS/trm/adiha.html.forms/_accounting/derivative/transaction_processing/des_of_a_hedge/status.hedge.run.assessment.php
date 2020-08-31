<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php require('../../../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $xml = get_sanitized_value($_GET["xml"] ?? '');
    $form_namespace = 'rusAssessment';
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "ok", type: "button", img: "save.gif", text:"OK", title: "Save"}]';

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('run_assessment', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'run_assessment_form';
    
    $form_json = '[  
                    {  
                      "type":"settings",
                      "position":"label-top"
                    },
                    {  
                      type:"block",
                      blockOffset:10,
                      list:[  
                         {  
                            "type":"calendar",
                            "name":"as_date_of",
                            "label":"As Date of",
                            "value":"",
                            "position":"label-top",
                            "offsetLeft":"10",
                            "labelWidth":"130",
                            "inputWidth":"120",
                            "tooltip":"Invoice Status",
                         },
                         {  
                            "type":"newcolumn"
                         },
                         {  "type":"combo",
                            "name":"sort_order",
                            "label":"Sort By","validate":"",
                            "hidden":"false",
                            "disabled":"false",                            
                            "options":[{"value":"i","text":"Inception"}, {"value":"o","text":"Ongoing"} ],
                            "inputWidth":"120",
                        },     
                 
                         
                      ]
                    }
                ]';
                
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var client_date_format = '<?php echo $date_format; ?>';
    //rusAssessment.run_assessment_form.setDateFormat(client_date_format.replace("n", "m").replace("j", "d"));
    rusAssessment.save_click = function(id) {
        if (id == 'ok') {
            var link_id = '<?php echo get_sanitized_value($_POST['link_id']); ?>';
            var subsidiary ='<?php echo get_sanitized_value($_POST['subsidiary_id']); ?>';
            var strategy = '<?php echo get_sanitized_value($_POST['strategy_id']); ?>';
            var book = '<?php echo get_sanitized_value($_POST['book_id']); ?>';
            var inception = rusAssessment.run_assessment_form.getCheckedValue("Inception");
            var as_of_date = rusAssessment.run_assessment_form.getItemValue("as_date_of", true);             
            parent.call_run_assessment(inception,as_of_date);
            parent.win.close(); // close a window
                 
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