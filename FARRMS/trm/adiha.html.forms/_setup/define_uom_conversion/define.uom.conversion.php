<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
$form_namespace = 'define_uom_conversion';
$form_obj = new AdihaStandardForm($form_namespace, 10101182);
$form_obj->define_layout_width('420');
$transport_layout = new AdihaLayout();
$grid_a = new AdihaGrid();
$form_obj->define_grid("define_uom_conversion", "");
echo $form_obj->init_form('UOM Conversions', 'Setup UOM Conversion');
echo $form_obj->close_form();
?>
<body>


