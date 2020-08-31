IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_power_outage_process]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_power_outage_process]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: kcshrestha@pioneersolutionsglobal.com
-- Create date: 2014-04-22
-- Description: Process power outage
 
-- Params:
-- @flag				CHAR(1) - Operation flag
-- @source_generator_id	INT - Generator ID
-- @dt_start			DATETIME - Term Start Date
-- @dt_end				DATETIME - Term End Date
-- @power_outage_id		INT - Power Outage ID
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_power_outage_process]
    @flag					CHAR(1), 
    @source_generator_id	INT, 
    @dt_start				DATETIME,
    @dt_end					DATETIME, 
    @power_outage_id		INT = NULL
AS
	DECLARE @source_deal_header_ids NVARCHAR(4000)
	DECLARE @desc NVARCHAR(100), @err_no NVARCHAR(100)

	SET @source_deal_header_ids = STUFF(
											(
             								SELECT DISTINCT
             									',' + CAST(sdd.source_deal_header_id AS NVARCHAR(100)) 
											FROM 
												source_deal_detail_hour sddh
											INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
											INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
											WHERE
												sdh.generator_id = @source_generator_id
												AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) >= @dt_start 
												AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) <= @dt_end
											FOR 
												XML PATH ('')
											), 1, 1, '')
											
    IF  @flag = 'u' OR @flag = 'd'  
    BEGIN
    	BEGIN TRY    		
			DECLARE @remove_dt_start DATETIME, @remove_dt_end DATETIME
			SELECT @remove_dt_start = @dt_start, @remove_dt_end = @dt_end
				
    		UPDATE 
				sddh			 
			SET 
				sddh.volume = posv.volume
			FROM source_deal_detail_hour sddh	
			INNER JOIN power_outage_shaped_volume posv ON
				posv.source_deal_detail_id = sddh.source_deal_detail_id
				AND posv.term_date = sddh.term_date
				AND posv.is_dst = sddh.is_dst
				AND posv.granularity = sddh.granularity
				AND posv.hr = sddh.hr   
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
			WHERE posv.power_outage_id = @power_outage_id				
			
			DELETE posv
			FROM 
				power_outage_shaped_volume posv	
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = posv.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
			WHERE posv.power_outage_id = @power_outage_id				
			
			UPDATE	
				ddh
			SET 
				ddh.Hr1 = CASE WHEN DATEADD(hour, 0, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 0, ddh.term_date) <= @remove_dt_end THEN pofv.Hr1 ELSE ddh.Hr1 END,
				ddh.Hr2 = CASE WHEN DATEADD(hour, 1, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 1, ddh.term_date) <= @remove_dt_end THEN pofv.Hr2 ELSE ddh.Hr2 END,
				ddh.Hr3 = CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 2, ddh.term_date) <= @remove_dt_end THEN pofv.Hr3 ELSE ddh.Hr3 END,
				ddh.Hr4 = CASE WHEN DATEADD(hour, 3, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 3, ddh.term_date) <= @remove_dt_end THEN pofv.Hr4 ELSE ddh.Hr4 END,
				ddh.Hr5 = CASE WHEN DATEADD(hour, 4, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 4, ddh.term_date) <= @remove_dt_end THEN pofv.Hr5 ELSE ddh.Hr5 END,
				ddh.Hr6 = CASE WHEN DATEADD(hour, 5, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 5, ddh.term_date) <= @remove_dt_end THEN pofv.Hr6 ELSE ddh.Hr6 END,
				ddh.Hr7 = CASE WHEN DATEADD(hour, 6, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 6, ddh.term_date) <= @remove_dt_end THEN pofv.Hr7 ELSE ddh.Hr7 END,
				ddh.Hr8 = CASE WHEN DATEADD(hour, 7, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 7, ddh.term_date) <= @remove_dt_end THEN pofv.Hr8 ELSE ddh.Hr8 END,
				ddh.Hr9 = CASE WHEN DATEADD(hour, 8, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 8, ddh.term_date) <= @remove_dt_end THEN pofv.Hr9 ELSE ddh.Hr9 END,
				ddh.Hr10 = CASE WHEN DATEADD(hour, 9, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 9,  ddh.term_date) <= @remove_dt_end THEN pofv.Hr10 ELSE ddh.Hr10 END,
				ddh.Hr11 = CASE WHEN DATEADD(hour, 10, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 10, ddh.term_date) <= @remove_dt_end THEN pofv.Hr11 ELSE ddh.Hr11 END,
				ddh.Hr12 = CASE WHEN DATEADD(hour, 11, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 11, ddh.term_date) <= @remove_dt_end THEN pofv.Hr12 ELSE ddh.Hr12 END,
				ddh.Hr13 = CASE WHEN DATEADD(hour, 12, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 12, ddh.term_date) <= @remove_dt_end THEN pofv.Hr13 ELSE ddh.Hr13 END,
				ddh.Hr14 = CASE WHEN DATEADD(hour, 13, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 13, ddh.term_date) <= @remove_dt_end THEN pofv.Hr14 ELSE ddh.Hr14 END,
				ddh.Hr15 = CASE WHEN DATEADD(hour, 14, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 14, ddh.term_date) <= @remove_dt_end THEN pofv.Hr15 ELSE ddh.Hr15 END,
				ddh.Hr16 = CASE WHEN DATEADD(hour, 15, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 15, ddh.term_date) <= @remove_dt_end THEN pofv.Hr16 ELSE ddh.Hr16 END,
				ddh.Hr17 = CASE WHEN DATEADD(hour, 16, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 16, ddh.term_date) <= @remove_dt_end THEN pofv.Hr17 ELSE ddh.Hr17 END,
				ddh.Hr18 = CASE WHEN DATEADD(hour, 17, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 17, ddh.term_date) <= @remove_dt_end THEN pofv.Hr18 ELSE ddh.Hr18 END,
				ddh.Hr19 = CASE WHEN DATEADD(hour, 18, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 18, ddh.term_date) <= @remove_dt_end THEN pofv.Hr19 ELSE ddh.Hr19 END,
				ddh.Hr20 = CASE WHEN DATEADD(hour, 19, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 19, ddh.term_date) <= @remove_dt_end THEN pofv.Hr20 ELSE ddh.Hr20 END,
				ddh.Hr21 = CASE WHEN DATEADD(hour, 20, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 20, ddh.term_date) <= @remove_dt_end THEN pofv.Hr21 ELSE ddh.Hr21 END,
				ddh.Hr22 = CASE WHEN DATEADD(hour, 21, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 21, ddh.term_date) <= @remove_dt_end THEN pofv.Hr22 ELSE ddh.Hr22 END,
				ddh.Hr23 = CASE WHEN DATEADD(hour, 22, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 22, ddh.term_date) <= @remove_dt_end THEN pofv.Hr23 ELSE ddh.Hr23 END,
				ddh.Hr24 = CASE WHEN DATEADD(hour, 23, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 23, ddh.term_date) <= @remove_dt_end THEN pofv.Hr24 ELSE ddh.Hr24 END,
				ddh.Hr25 = CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @remove_dt_start AND DATEADD(hour, 2, ddh.term_date) <= @remove_dt_end THEN pofv.Hr25 ELSE ddh.Hr25 END
			FROM 
				deal_detail_hour ddh
			INNER JOIN power_outage_forecasted_volume pofv ON pofv.term_date = ddh.term_date
				AND pofv.profile_id = ddh.profile_id
				AND pofv.partition_value = ddh.partition_value
			INNER JOIN forecast_profile fp ON fp.profile_id = ddh.profile_id
			INNER JOIN source_minor_location sml ON sml.profile_id = fp.profile_id
			INNER JOIN source_deal_detail sdd  ON sdd.location_id = sml.source_minor_location_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE pofv.power_outage_id = @power_outage_id			
		
			DELETE 
				pofv
			FROM 
				power_outage_forecasted_volume pofv	
			INNER JOIN forecast_profile fp ON fp.profile_id = pofv.profile_id
			INNER JOIN source_minor_location sml ON sml.profile_id = fp.profile_id
			INNER JOIN source_deal_detail sdd  ON sdd.location_id = sml.source_minor_location_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE pofv.power_outage_id = @power_outage_id
								
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
				   ROLLBACK
	 
				SET @desc = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
				SELECT @err_no = ERROR_NUMBER()
	 
				EXEC spa_ErrorHandler @err_no
				   , 'power_outage_shaped_volume'
				   , 'spa_power_outage_process'
				   , 'Error'
				   , @desc
				   , ''
			END CATCH	
	END         
	
    IF  @flag = 'i' OR @flag = 'u'
    BEGIN
    	BEGIN TRY
    		INSERT INTO power_outage_shaped_volume (source_deal_detail_id, term_date, hr, is_dst, volume, price, formula_id, granularity, power_outage_id)
			SELECT 
				sddh.source_deal_detail_id, term_date, hr, is_dst, volume, price, sddh.formula_id, granularity, @power_outage_id
			FROM 
				source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE
				sdh.generator_id = @source_generator_id
				AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) >= @dt_start 
				AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) <= @dt_end											
			
			UPDATE 
				sddh			 
			SET 
				volume = 0
			FROM source_deal_detail_hour sddh	
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE 
				  sdh.generator_id = @source_generator_id
				  AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) >= @dt_start 
				  AND DATEADD(MINUTE, CAST(LTRIM(DATEDIFF(MINUTE, 0, CASE WHEN CHARINDEX(':', sddh.hr) > 0 THEN RIGHT('00' + CAST((LEFT(sddh.hr, 2) - 1) AS VARCHAR(10)), 2) + RIGHT(sddh.hr, 3) ELSE RIGHT(('00' + (sddh.hr -1)), 2) + ':00' END)) AS INT), sddh.term_date) <= @dt_end											
		
			INSERT INTO power_outage_forecasted_volume (term_date, profile_id, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value, [FILE_NAME], power_outage_id)
			SELECT 
				[term_date], 
				ddh.profile_id,
				CASE WHEN DATEADD(hour, 0, ddh.term_date) >= @dt_start AND DATEADD(hour, 0, ddh.term_date) <= @dt_end THEN ddh.Hr1 ELSE 0 END, 
				CASE WHEN DATEADD(hour, 1, ddh.term_date) >= @dt_start AND DATEADD(hour, 1, ddh.term_date) <= @dt_end THEN ddh.Hr2 ELSE 0 END,
				CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @dt_start AND DATEADD(hour, 2, ddh.term_date) <= @dt_end THEN ddh.Hr3 ELSE 0 END,
				CASE WHEN DATEADD(hour, 3, ddh.term_date) >= @dt_start AND DATEADD(hour, 3, ddh.term_date) <= @dt_end THEN ddh.Hr4 ELSE 0 END,
				CASE WHEN DATEADD(hour, 4, ddh.term_date) >= @dt_start AND DATEADD(hour, 4, ddh.term_date) <= @dt_end THEN ddh.Hr5 ELSE 0 END,
				CASE WHEN DATEADD(hour, 5, ddh.term_date) >= @dt_start AND DATEADD(hour, 5, ddh.term_date) <= @dt_end THEN ddh.Hr6 ELSE 0 END,
				CASE WHEN DATEADD(hour, 6, ddh.term_date) >= @dt_start AND DATEADD(hour, 6, ddh.term_date) <= @dt_end THEN ddh.Hr7 ELSE 0 END,
				CASE WHEN DATEADD(hour, 7, ddh.term_date) >= @dt_start AND DATEADD(hour, 7, ddh.term_date) <= @dt_end THEN ddh.Hr8 ELSE 0 END,
				CASE WHEN DATEADD(hour, 8, ddh.term_date) >= @dt_start AND DATEADD(hour, 8, ddh.term_date) <= @dt_end THEN ddh.Hr9 ELSE 0 END,
				CASE WHEN DATEADD(hour, 9, ddh.term_date) >= @dt_start AND DATEADD(hour, 9, ddh.term_date) <= @dt_end THEN ddh.Hr10 ELSE 0 END,
				CASE WHEN DATEADD(hour, 10, ddh.term_date) >= @dt_start AND DATEADD(hour, 10, ddh.term_date) <= @dt_end THEN ddh.Hr11 ELSE 0 END,
				CASE WHEN DATEADD(hour, 11, ddh.term_date) >= @dt_start AND DATEADD(hour, 11, ddh.term_date) <= @dt_end THEN ddh.Hr12 ELSE 0 END,
				CASE WHEN DATEADD(hour, 12, ddh.term_date) >= @dt_start AND DATEADD(hour, 12, ddh.term_date) <= @dt_end THEN ddh.Hr13 ELSE 0 END,
				CASE WHEN DATEADD(hour, 13, ddh.term_date) >= @dt_start AND DATEADD(hour, 13, ddh.term_date) <= @dt_end THEN ddh.Hr14 ELSE 0 END,
				CASE WHEN DATEADD(hour, 14, ddh.term_date) >= @dt_start AND DATEADD(hour, 14, ddh.term_date) <= @dt_end THEN ddh.Hr15 ELSE 0 END,
				CASE WHEN DATEADD(hour, 15, ddh.term_date) >= @dt_start AND DATEADD(hour, 15, ddh.term_date) <= @dt_end THEN ddh.Hr16 ELSE 0 END,
				CASE WHEN DATEADD(hour, 16, ddh.term_date) >= @dt_start AND DATEADD(hour, 16, ddh.term_date) <= @dt_end THEN ddh.Hr17 ELSE 0 END,
				CASE WHEN DATEADD(hour, 17, ddh.term_date) >= @dt_start AND DATEADD(hour, 17, ddh.term_date) <= @dt_end THEN ddh.Hr18 ELSE 0 END,
				CASE WHEN DATEADD(hour, 18, ddh.term_date) >= @dt_start AND DATEADD(hour, 18, ddh.term_date) <= @dt_end THEN ddh.Hr19 ELSE 0 END,
				CASE WHEN DATEADD(hour, 19, ddh.term_date) >= @dt_start AND DATEADD(hour, 19, ddh.term_date) <= @dt_end THEN ddh.Hr20 ELSE 0 END,
				CASE WHEN DATEADD(hour, 20, ddh.term_date) >= @dt_start AND DATEADD(hour, 20, ddh.term_date) <= @dt_end THEN ddh.Hr21 ELSE 0 END,
				CASE WHEN DATEADD(hour, 21, ddh.term_date) >= @dt_start AND DATEADD(hour, 21, ddh.term_date) <= @dt_end THEN ddh.Hr22 ELSE 0 END,
				CASE WHEN DATEADD(hour, 22, ddh.term_date) >= @dt_start AND DATEADD(hour, 22, ddh.term_date) <= @dt_end THEN ddh.Hr23 ELSE 0 END,
				CASE WHEN DATEADD(hour, 23, ddh.term_date) >= @dt_start AND DATEADD(hour, 23, ddh.term_date) <= @dt_end THEN ddh.Hr24 ELSE 0 END,
				CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @dt_start AND DATEADD(hour, 2, ddh.term_date) <= @dt_end THEN ddh.Hr25 ELSE 0 END,
				[partition_value], 
				[FILE_NAME],
				@power_outage_id
			FROM 
				deal_detail_hour ddh
			INNER JOIN forecast_profile fp ON fp.profile_id = ddh.profile_id
			INNER JOIN source_minor_location sml ON sml.profile_id = fp.profile_id
			INNER JOIN source_deal_detail sdd ON sdd.location_id = sml.source_minor_location_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE
				sdh.generator_id = @source_generator_id				
				AND ddh.term_date >= convert(date, @dt_start) 
				AND ddh.term_date <= convert(date, @dt_end)
			
			UPDATE	
				ddh
			SET 
				ddh.Hr1 = CASE WHEN DATEADD(hour, 0, ddh.term_date) >= @dt_start AND DATEADD(hour, 0, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr1 END,
				ddh.Hr2 = CASE WHEN DATEADD(hour, 1, ddh.term_date) >= @dt_start AND DATEADD(hour, 1, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr2 END,
				ddh.Hr3 = CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @dt_start AND DATEADD(hour, 2, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr3 END,
				ddh.Hr4 = CASE WHEN DATEADD(hour, 3, ddh.term_date) >= @dt_start AND DATEADD(hour, 3, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr4 END,
				ddh.Hr5 = CASE WHEN DATEADD(hour, 4, ddh.term_date) >= @dt_start AND DATEADD(hour, 4, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr5 END,
				ddh.Hr6 = CASE WHEN DATEADD(hour, 5, ddh.term_date) >= @dt_start AND DATEADD(hour, 5, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr6 END,
				ddh.Hr7 = CASE WHEN DATEADD(hour, 6, ddh.term_date) >= @dt_start AND DATEADD(hour, 6, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr7 END,
				ddh.Hr8 = CASE WHEN DATEADD(hour, 7, ddh.term_date) >= @dt_start AND DATEADD(hour, 7, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr8 END,
				ddh.Hr9 = CASE WHEN DATEADD(hour, 8, ddh.term_date) >= @dt_start AND DATEADD(hour, 8, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr9 END,
				ddh.Hr10 = CASE WHEN DATEADD(hour, 9, ddh.term_date) >= @dt_start AND DATEADD(hour, 9, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr10 END,
				ddh.Hr11 = CASE WHEN DATEADD(hour, 10, ddh.term_date) >= @dt_start AND DATEADD(hour, 10, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr11 END,
				ddh.Hr12 = CASE WHEN DATEADD(hour, 11, ddh.term_date) >= @dt_start AND DATEADD(hour, 11, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr12 END,
				ddh.Hr13 = CASE WHEN DATEADD(hour, 12, ddh.term_date) >= @dt_start AND DATEADD(hour, 12, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr13 END,
				ddh.Hr14 = CASE WHEN DATEADD(hour, 13, ddh.term_date) >= @dt_start AND DATEADD(hour, 13, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr14 END,
				ddh.Hr15 = CASE WHEN DATEADD(hour, 14, ddh.term_date) >= @dt_start AND DATEADD(hour, 14, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr15 END,
				ddh.Hr16 = CASE WHEN DATEADD(hour, 15, ddh.term_date) >= @dt_start AND DATEADD(hour, 15, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr16 END,
				ddh.Hr17 = CASE WHEN DATEADD(hour, 16, ddh.term_date) >= @dt_start AND DATEADD(hour, 16, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr17 END,
				ddh.Hr18 = CASE WHEN DATEADD(hour, 17, ddh.term_date) >= @dt_start AND DATEADD(hour, 17, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr18 END,
				ddh.Hr19 = CASE WHEN DATEADD(hour, 18, ddh.term_date) >= @dt_start AND DATEADD(hour, 18, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr19 END,
				ddh.Hr20 = CASE WHEN DATEADD(hour, 19, ddh.term_date) >= @dt_start AND DATEADD(hour, 19, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr20 END,
				ddh.Hr21 = CASE WHEN DATEADD(hour, 20, ddh.term_date) >= @dt_start AND DATEADD(hour, 20, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr21 END,
				ddh.Hr22 = CASE WHEN DATEADD(hour, 21, ddh.term_date) >= @dt_start AND DATEADD(hour, 21, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr22 END,
				ddh.Hr23 = CASE WHEN DATEADD(hour, 22, ddh.term_date) >= @dt_start AND DATEADD(hour, 22, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr23 END,
				ddh.Hr24 = CASE WHEN DATEADD(hour, 23, ddh.term_date) >= @dt_start AND DATEADD(hour, 23, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr24 END,
				ddh.Hr25 = CASE WHEN DATEADD(hour, 2, ddh.term_date) >= @dt_start AND DATEADD(hour, 2, ddh.term_date) <= @dt_end THEN 0 ELSE ddh.Hr25 END
			FROM 
				deal_detail_hour ddh
			INNER JOIN forecast_profile fp ON fp.profile_id = ddh.profile_id
			INNER JOIN source_minor_location sml ON sml.profile_id = fp.profile_id
			INNER JOIN source_deal_detail sdd ON sdd.location_id = sml.source_minor_location_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE
				sdh.generator_id = @source_generator_id				
				AND ddh.term_date >= convert(date, @dt_start) 
				AND ddh.term_date <= convert(date, @dt_end)
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK
	 
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
			SELECT @err_no = ERROR_NUMBER()
	 
			EXEC spa_ErrorHandler @err_no
				, 'power_outage_shaped_volume'
				, 'spa_power_outage_process'
				, 'Error'
				, @desc
				, ''
		END CATCH
	END		
	EXEC spa_calc_deal_position_breakdown @source_deal_header_ids