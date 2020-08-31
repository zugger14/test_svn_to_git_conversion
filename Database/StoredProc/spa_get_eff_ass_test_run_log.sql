IF OBJECT_ID(N'[dbo].[spa_get_eff_ass_test_run_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_eff_ass_test_run_log]
GO 



--This procedure returns assessment test log to the client
--drop proc spa_get_eff_ass_test_run_log
-- exec spa_get_eff_ass_test_run_log '5FC8421D_4CFF_4319_95D6_A4A48CB7091D'

CREATE PROCEDURE [dbo].[spa_get_eff_ass_test_run_log]
	@process_id varchar(50)
AS

SELECT  code AS Code, 
		[module] AS Module, 
		source AS Source, 
		type AS Type, 
		description AS Description, 
		nextsteps AS NextSteps, 
		process_id AS ProcessId
FROM    fas_eff_ass_test_run_log
WHERE process_id = @process_id
ORDER BY fas_eff_ass_test_run_log_id



