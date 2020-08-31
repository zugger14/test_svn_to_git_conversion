
IF OBJECT_ID(N'[dbo].[spa_credit_exposure_calculation_log]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_credit_exposure_calculation_log]
GO 

CREATE PROCEDURE [dbo].[spa_credit_exposure_calculation_log]
	@process_id VARCHAR(50)
AS
	SELECT code AS Code,
	       [module] AS Module,
	       source AS Source,
	       [type] AS [Type],
	       [description] AS [Description],
	       nextsteps AS NextSteps,
	       process_id AS ProcessID
	FROM   credit_exposure_calculation_log
	WHERE  process_id = @process_id --'71400582_9619_4997_B68D_926F14B469D1_50ec30803eb17'--
	GROUP BY
	       code, module, source, [Type],
	      [Description], nextsteps,[process_id],calculation_log_log_id
	ORDER BY calculation_log_log_id








