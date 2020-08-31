<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    <?php
        $form_namespace = 'default_glcode';
        $form_obj = new AdihaStandardForm($form_namespace, 10103400);
        $form_obj->define_grid("default_glcode", "EXEC spa_invoice_lineitem_default_glcode 'g'");
        echo $form_obj->init_form('Default GL Group', 'Default GL Group');
        echo $form_obj->close_form();
    ?>
<body>
</body>
</html>	