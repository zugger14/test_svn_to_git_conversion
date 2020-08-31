<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<?php 
$application_function_id = 20004800;

$rights_compliance_group_iu = 20004801;
$rights_compliance_group_delete = 20004802;

list (
    $has_rights_compliance_group_iu,
    $has_rights_compliance_group_delete
    ) = build_security_rights (
    $rights_compliance_group_iu,
    $rights_compliance_group_delete
);

$form_namespace = 'compliance_group';
$form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
$form_obj->define_grid('ComplianceGroup', '', 'g');
$form_obj->define_layout_width(355); 
echo $form_obj->init_form('Compliance Group', 'Compliance Group Details'); 
echo $form_obj->close_form();
?>
 
<script type="text/javascript">  
   

</script>