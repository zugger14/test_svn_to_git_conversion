<?php
require_once 'farrms.client.config.ini.php';

$farrms_module_stack = array(
    'trm' => array(
        'product_id' => 10000000,
        'product_name' => 'TRMTracker'
    ),
    'set' => array(
        'product_id' => 15000000,
        'product_name' => 'SettlementTracker'
    ),
    'ems' => array(
        'product_id' => 12000000,
        'product_name' => 'EmissionsTracker'
    ),
    'fas' => array(
        'product_id' => 13000000,
        'product_name' => 'FASTracker'
    ),
    'rec' => array(
        'product_id' => 14000000,
        'product_name' => 'RECTracker'
    )
);

# Specifies the FARRMS product ID.
# Possible Values: 10000000 - TRMTracker | 12000000 - EmissionsTracker | 13000000 - FASTracker | 14000000 - RECTracker | 15000000 - SettlementTracker
$farrms_product_id = $farrms_module_stack[$module_type]['product_id'];

# Specifies the FARRMS product name.
# Possible Values: TRMTracker | EmissionsTracker | FASTracker | RECTracker | SettlementTracker
$farrms_product_name = $farrms_module_stack[$module_type]['product_name'];