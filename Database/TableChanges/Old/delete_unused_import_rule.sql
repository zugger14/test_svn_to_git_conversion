 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Copy of Standard Price Import Rule') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Copy of Standard Price Import Rule', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Cum PNL Series Import') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Cum PNL Series Import', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Cumulative PnL Import - FAS') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Cumulative PnL Import - FAS', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Generic Volatility Import Rule') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Generic Volatility Import Rule', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Meter Allocation') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Meter Allocation', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'MTM Import - FAS') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'MTM Import - FAS', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'MTM Import Rule') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'MTM Import Rule', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Price Curve') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Price Curve', @show_delete_msg = 'n' END

 IF EXISTS(SELECT 1 FROM ixp_rules ir WHERE ir.ixp_rules_name = 'Price Hub Import') BEGIN 
			EXEC spa_ixp_rules @flag = 'd', @ixp_rules_name = 'Price Hub Import', @show_delete_msg = 'n' END
			 