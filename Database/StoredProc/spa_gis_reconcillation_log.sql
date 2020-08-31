IF OBJECT_ID(N'spa_gis_reconcillation_log', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_gis_reconcillation_log]
GO 

--exec spa_gis_reconcillation_log 'xdsdfsd'

CREATE PROC [dbo].[spa_gis_reconcillation_log] 
	@process_id VARCHAR(100)
AS


SELECT process_id ProcessID,
       code Code,
       module Module,
       source Source,
       TYPE TYPE,
       DESCRIPTION,
       nextsteps Recommendation
FROM   gis_reconcillation_log
WHERE  process_id = @process_id