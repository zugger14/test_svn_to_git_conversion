IF OBJECT_ID(N'[dbo].[spa_get_break_deal]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_break_deal]
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Insert deals into process_deal_position_breakdown for position calculation from block hour and calendar
	
	Parameters
	@flag : Operation flag
		 - 'hourly block' - Calculate position of affected deals when changing hourly block.
	@block_define_id : Block_define_id from hourly block update/insert.
	@calendar_id : Calendar_id(static data value) from calendar update/insert.
	@curve_id : Curve ID(source price curve) from price curve update/insert.
*/

CREATE PROCEDURE [dbo].[spa_get_break_deal]
	@flag VARCHAR(20) = NULL,
	@block_define_id VARCHAR(200) = NULL, 
	@calendar_id VARCHAR(100) = NULL,
	@curve_id VARCHAR(100) = NULL
AS
SET NOCOUNT ON
/** * DEBUG QUERY START *

DECLARE @flag VARCHAR(20) = NULL,
		@block_define_id VARCHAR(200) = NULL, 
		@calendar_id VARCHAR(100) = NULL,
		@curve_id VARCHAR(100) = NULL

SET @flag = 'hourly block'
SET @calendar_id = '50002468'

-- * DEBUG QUERY END * */

IF @flag = 'hourly block' 
BEGIN 
	IF @curve_id IS NOT NULL
	BEGIN 
		IF (SELECT top 1 COALESCE(exp_calendar_id, block_define_id, holiday_calendar_id) 
			FROM source_Price_curve_def a
			INNER JOIN dbo.FNASplit(@curve_id, ',') b ON b.item = a.source_curve_def_id
			--WHERE source_curve_def_id = @curve_id
		) IS NOT NULL
		BEGIN	
			IF OBJECT_ID('tempdb..#tmps_effected_deals') IS NOT NULL
				DROP TABLE #tmps_effected_deals

			SELECT source_deal_header_id 
			INTO #tmps_effected_deals
			FROM source_deal_detail sdd
			INNER JOIN dbo.FNASplit(@curve_id, ',') b ON b.item = sdd.curve_id
			--WHERE curve_id = @curve_id

			INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id ,create_user,create_ts,process_status,insert_type ,deal_type ,commodity_id,fixation ,internal_deal_type_value_id)
    		SELECT DISTINCT sdh.source_deal_header_id,
				   dbo.FNADBUSER(),
				   GETDATE(),
				   3,
				   0,   ---- 0=incremental FROM front	; 1= partial import; 2=bulk import ; 12= import FROM load forecast file
           		   MAX(ISNULL(sdh.internal_desk_id,17300)) deal_type,    
				   MAX(ISNULL(spcd.commodity_id,-1)) commodity_id,
				   MAX(ISNULL(sdh.product_id,4101)) fixation,
				   MAX(ISNULL(sdh.internal_deal_type_value_id,-999999))
			FROM #tmps_effected_deals h 
			INNER JOIN source_deal_header sdh 
				ON h.source_deal_header_id=sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd 
				ON sdh.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN source_price_curve_def spcd 
				ON sdd.curve_id=spcd.source_curve_def_id 
				AND sdd.curve_id IS NOT NULL
			GROUP BY sdh.source_deal_header_id
			RETURN
		END 
		ELSE
			RETURN
	END
	ELSE
	BEGIN
		IF @block_define_id IS NULL AND @calendar_id IS NOT NULL --call from calendar
		BEGIN		
			--SELECT @block_define_id = block_value_id FROM hourly_block WHERE holiday_value_id = @calendar_id
			--SELECT block_value_id 
			--FROM hourly_block 
			--WHERE holiday_value_id IN (@calendar_id)

			SELECT TOP 1 @block_define_id = STUFF((SELECT ', ' + CAST(block_value_id AS VARCHAR(20))
														FROM hourly_block b 					   
														GROUP BY block_value_id
														FOR XML PATH('')), 1, 2, '')	 
			FROM hourly_block a
			INNER JOIN dbo.FNASplit(@calendar_id, ',') b ON b.item = a.holiday_value_id
			--WHERE holiday_value_id IN (select item from dbo.FNASplit(@calendar_id, ','))
			GROUP BY block_value_id	
		END

		IF OBJECT_ID('tempdb..#tmp_effected_deals') IS NOT NULL
			DROP TABLE #tmp_effected_deals

		SELECT sdh.source_deal_header_id 
		INTO #tmp_effected_deals
		FROM source_deal_header sdh
		INNER JOIN dbo.FNASplit(@block_define_id, ',') b 
			ON b.item = sdh.block_define_id
		GROUP BY sdh.source_deal_header_id

		CREATE TABLE #deal_to_calc(source_deal_header_id INT)

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
			OUTPUT INSERTED.source_deal_header_id INTO #deal_to_calc(source_deal_header_id)
		SELECT sdh.source_deal_header_id, MAX(sdh.create_user), GETDATE(), 9 process_status, 0 deal_type, MAX(ISNULL(sdh.internal_desk_id, 17300)) deal_type, 
		MAX(ISNULL(spcd.commodity_id, -1)) commodity_id, MAX(ISNULL(sdh.product_id, 4101)) fixation, MAX(ISNULL(sdh.internal_deal_type_value_id, -999999))
		FROM #tmp_effected_deals h 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = h.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id and sdd.curve_id IS NOT NULL
		GROUP BY sdh.source_deal_header_id

		IF EXISTS(SELECT 1 FROM #deal_to_calc)
			EXEC dbo.spa_calc_pending_deal_position @call_from = 1

		RETURN
	END
END
ELSE
	SELECT source_deal_type_id deal_id FROM source_deal_type WHERE break_individual_deal = 'y'




