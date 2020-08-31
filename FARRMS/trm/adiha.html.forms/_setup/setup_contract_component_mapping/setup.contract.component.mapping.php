<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    <?php
        $form_namespace = 'setup_contract_component_mapping';
        $form_obj = new AdihaStandardForm($form_namespace, 10104300);
        $form_obj->define_grid("contract_component_mapping", "", "g");
        echo $form_obj->init_form('Contract Component Mapping','Contract Component Mapping');
        echo $form_obj->close_form();
    ?>
<body>
</body>
</html>


