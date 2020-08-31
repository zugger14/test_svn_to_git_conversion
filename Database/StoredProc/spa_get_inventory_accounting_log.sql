IF OBJECT_ID(N'[dbo].[spa_get_inventory_accounting_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_inventory_accounting_log]
GO 

--exec spa_get_inventory_accounting_log '10101'

CREATE PROCEDURE [dbo].[spa_get_inventory_accounting_log]
	@process_id varchar(50)
AS

SELECT     code AS Code, [module] AS Module, source AS Source, 
	type AS Type, description AS Description, nextsteps AS NextSteps, process_id AS ProcessId
FROM         inventory_accounting_log
WHERE process_id = @process_id
order by mtm_test_run_log_id










