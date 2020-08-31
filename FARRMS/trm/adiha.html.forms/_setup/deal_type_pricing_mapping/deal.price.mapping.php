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
            $function_id =  20002300;
            $form_namespace = 'deal_price_mapping';
            $template_name = "DealTypePricingMapping";
            $form_obj = new AdihaStandardForm($form_namespace,  20002300);
            $form_obj->define_grid("deal_type_pricing_maping");
            $form_obj->define_layout_width(350);
            echo $form_obj->init_form('Deal Type Pricing Mapping');
            echo $form_obj->close_form();
        ?>
    </body>
    <script type="text/javascript">
       /* function refresh_grid_with_filter(filter_param, callback_function) {
            var callback_function = typeof callback_function !== 'undefined' ? callback_function : '';
            var grid_sp_json = {
                "action": "spa_production_location_index_maping",
                "flag": "s",
                "xml": filter_param
            };
            setup_fees.refresh_grid(grid_sp_json, callback_function);
            setup_fees.menu.setItemDisabled("delete");
        }*/

    </script>
</html>