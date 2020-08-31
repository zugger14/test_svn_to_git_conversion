EXEC spa_ixp_rules @flag = 'f', @ixp_rules_name = 'Cash Apply', @show_delete_msg = 'n'

UPDATE ixp_rules SET ixp_rules_name = 'Cash Apply', is_active = 1 WHERE ixp_rules_name = 'Import Cash'

