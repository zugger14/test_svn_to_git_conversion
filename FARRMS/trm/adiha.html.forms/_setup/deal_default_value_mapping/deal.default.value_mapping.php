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
            $function_id =  20002500;
            $form_namespace = 'deal_default_value_mapping';
            $template_name = "DealDefaultValueMapping";
            $form_obj = new AdihaStandardForm($form_namespace,  20002500);
            $form_obj->define_grid("DealDefaultValueMapping");
            $form_obj->define_layout_width(350);
            echo $form_obj->init_form('Deal Default Value Mapping');
            echo $form_obj->close_form();
        ?>
    </body>
    <script type="text/javascript">
    </script>
</html>