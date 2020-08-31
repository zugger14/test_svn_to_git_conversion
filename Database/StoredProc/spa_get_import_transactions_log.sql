IF OBJECT_ID(N'[dbo].[spa_get_import_transactions_log]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_import_transactions_log]
GO 

-- exec spa_get_import_transactions_log 'A6258AB5_BFCB_4DAB_BC96_43AA9A433AC2'

CREATE PROCEDURE [dbo].[spa_get_import_transactions_log]
	@process_id varchar(50)
AS

SELECT	CASE WHEN (code = 'Error') 
			THEN '<font color="red"><b>' + code +'</b></font>'
			ELSE code
		END AS Code, 
		[module] AS Module, source AS Source, 
	type AS Type, description AS Description, nextsteps AS NextSteps, process_id AS ProcessId
FROM         Import_Transactions_Log
WHERE process_id = @process_id
order by Import_Transaction_log_id









