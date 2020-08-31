IF OBJECT_ID(N'spa_inventory_calc_adjusted_rec_deals', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_inventory_calc_adjusted_rec_deals]
GO
 
--exec spa_inventory_calc_adjusted_rec_deals  '2006-02-28', 62, 'urbaral', null 

CREATE PROCEDURE [dbo].[spa_inventory_calc_adjusted_rec_deals] 
(
	@contract_month varchar(20), 
	@counterparty_id int,
	@user_id varchar(50), 
	@deal_id varchar(50) = null -- not used now.. we might  need in  the  future
)
AS

DECLARE @process_id  VARCHAR(50)
DECLARE @job_name    VARCHAR(100)


SET @process_id = REPLACE(NEWID(), '-', '_')
SET @job_name = 'adjust_' + REPLACE(NEWID(), '-', '_')


-- EXEC spa_print 	@contract_month
-- EXEC spa_print 	@process_id
-- EXEC spa_print 	@job_name
-- EXEC spa_print 	@user_id
-- EXEC spa_print 	@counterparty_id



 EXEC 	spa_calc_inventory_accounting_entries
 	NULL,
 	NULL,
 	NULl,
 	NULL,
 	NULL,
 	@contract_month,
 	@process_id,
 	@job_name,
 	@user_id,
 	@counterparty_id
-- 
-- If @@ERROR <> 0
-- BEGIN
-- 	Exec spa_ErrorHandler @@ERROR, 'Inventory Calc', 
-- 			'spa_inventory_calc_adjusted_rec_deals', 'Error', 
-- 			'Failed to  calc inventory', ''
-- 
-- END
-- Else
-- 	Exec spa_ErrorHandler 0, 'Inventory Calc', 
-- 			'spa_inventory_calc_adjusted_rec_deals', 'Success', 
-- 			'Selected Accounting calc inventory adjusted. Please review the results.', ''
-- 








