IF OBJECT_ID(N'[dbo].[spa_get_finaliza_approved_test_run_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_finaliza_approved_test_run_log]
GO 
	
CREATE PROCEDURE [dbo].[spa_get_finaliza_approved_test_run_log]
	@process_id varchar(50)
AS

SELECT  code AS Code, 
	    [module] AS Module, 
	    source AS Source, 
		type AS Type, 
		description AS Description, 
		nextsteps AS NextSteps, 
		process_id AS ProcessId
FROM    finalize_approve_test_run_log
WHERE process_id = @process_id
ORDER BY finalize_test_run_log_id





