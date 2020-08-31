IF OBJECT_ID(N'[dbo].[spa_eod_manual_intervention]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_manual_intervention]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-17 02:00AM
-- Description: EOD Process Manual Intervention.
--              
-- Params:
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_eod_manual_intervention]
	@eod_process_status_id INT = NULL,
	@as_of_date VARCHAR(10) = NULL,
	@process_step INT = NULL,
	@exec_single INT = 0
AS

DECLARE @master_process_id  VARCHAR(200),
        @process_id         VARCHAR(200)

SET @master_process_id = dbo.FNAGetNewID()
SET @process_id = dbo.FNAGetNewID()

BEGIN	
		
	EXEC spa_print 'Start EOD Process for ', @process_step
	EXEC spa_eod_process	     
			 @run_type = @process_step,
			 @master_process_id = @master_process_id,
			 @process_id = @process_id,
			 @date = @as_of_date,
			 @exec_only_this_step = @exec_single,
			 @manual_intervention = 'y' 
			 
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'EoD Manual Intervention', 'spa_eod_manual_intervention', 'DB ERROR', 'ERROR Starting EoD Manual Intervention.', ''
	ELSE
	    EXEC spa_ErrorHandler 0, 'EoD Manual Intervention', 'spa_eod_manual_intervention', 'Success', 'EoD Manual Intervention Started.', ''
END



--exec spa_eod_manual_intervention 19701, '2011-07-22', 19703
