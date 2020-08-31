IF OBJECT_ID('spa_resolve_best_available_pos') IS NOT NULL
    DROP PROC [dbo].[spa_resolve_best_available_pos]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Retrieve resolve best available Position of deals in portfolio

	Parameters : 
	@deal_id : Deal Id filter to process
	@term_start : Term Start filter to process
	@term_end : Term End filter to process
	@block_defin_id : Block Defin Id filter to process
	@deal_process_table :Deal Process Table filter to process

  */


CREATE PROC [dbo].[spa_resolve_best_available_pos] 
	@deal_id VARCHAR(100) = NULL, --'62733',
	@term_start	VARCHAR(100) = NULL, --  '2018-10-01',
	@term_end VARCHAR(100) = NULL, -- '2018-10-31',
	@block_defin_id INT = 304625,
	@deal_process_table VARCHAR(500) = NULL

AS

SET NOCOUNT ON

--declare
--@deal_id VARCHAR(100) = 62774, --'62733',
--	@term_start	VARCHAR(100) = '2018-01-01', --  '2018-10-01',
--	@term_end VARCHAR(100) = '2018-01-31', -- '2018-10-31'
--	@block_defin_id INT = NULL,
--	@deal_process_table VARCHAR(500)

--SET @deal_id = 220949
--SET @term_start = '2018-01-01'
--SET @term_end = '2018-01-31' 

DECLARE @sql VARCHAR(MAX)
IF OBJECT_ID('tempdb..#meter_in_deal') IS NOT NULL DROP TABLE #meter_in_deal
IF OBJECT_ID('tempdb..#meter_in_location') IS NOT NULL DROP TABLE #meter_in_location
IF OBJECT_ID('tempdb..#actual_schedule_vol') IS NOT NULL DROP TABLE #actual_schedule_vol
IF OBJECT_ID('tempdb..#deal_detail_hour') IS NOT NULL DROP TABLE #deal_detail_hour
IF OBJECT_ID('tempdb..#deal_position') IS NOT NULL DROP TABLE #deal_position
IF OBJECT_ID('tempdb..#hour_block') IS NOT NULL DROP TABLE #hour_block
IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL DROP TABLE #temp_deals

CREATE TABLE #temp_deals(source_deal_header_id INT,source_deal_detail_id INT)

IF @term_end IS NULL
	SET @term_end = DATEADD(m,1,@term_start)-1

IF @deal_process_table IS NOT NULL
	BEGIN
	SET @sql = 'INSERT INTO #temp_deals
				SELECT DISTINCT source_deal_header_id,source_deal_detail_id FROM '+@deal_process_table

	EXEC(@sql)
	END

DECLARE @baseload_block_define_id INT
SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'
SELECT DISTINCT
	block_define_id,term_date,CAST(REPLACE([hour],'hr','') AS INT) hour,add_dst_hour,[Volume]
INTO
	#hour_block
FROM
	(
		SELECT  block_define_id,term_date,Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, add_dst_hour
		FROM hour_block_term WHERE block_define_id = ISNULL(@block_defin_id,@baseload_block_define_id) AND term_start BETWEEN @term_start AND @term_end
	) P
	UNPIVOT
	([Volume] FOR Hour IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24)
	) unpvt


SELECT unpvt.source_deal_detail_id, unpvt.prod_date, REPLACE(unpvt.[hour],'hr','') [hour],  unpvt.Volume * CASE WHEN unpvt.buy_sell_flag = 'b' THEN 1 ELSE -1 END Volume 
INTO #meter_in_deal
FROM 
(SELECT
	   mv.meter_id, mdh.prod_date, sdd.source_deal_detail_id, sdd.buy_sell_flag,
	  Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, mv.channel
FROM
    source_deal_header sdh
    INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
    INNER JOIN mv90_data mv ON mv.meter_id = sdd.meter_id --AND mv.from_date BETWEEN @term_start AND @term_end
    INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = mv.meter_data_id 
		AND mdh.prod_date BETWEEN sdd.term_start AND sdd.term_end
	WHERE sdd.source_deal_header_id = @deal_id 
		AND sdd.term_start between @term_start  AND  @term_end
  )p
UNPIVOT
    ([Volume] FOR [Hour] IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25))  unpvt  
   --WHERE unpvt.prod_date BETWEEN @term_start AND @term_end

 
SELECT unpvt.source_deal_detail_id, unpvt.prod_date, REPLACE(unpvt.[hour],'Hr','') [hour],  unpvt.Volume * CASE WHEN unpvt.buy_sell_flag = 'b' THEN 1 ELSE -1 END  Volume 
INTO #meter_in_location
  FROM 
(SELECT
	   mv.meter_id, mdh.prod_date, sdd.source_deal_detail_id, sdd.buy_sell_flag,
	  Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, mv.channel
FROM
    source_deal_header sdh
    INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
    INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id
    INNER JOIN mv90_data mv ON mv.meter_id = smlm.meter_id
    INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = mv.meter_data_id 
		AND mdh.prod_date BETWEEN sdd.term_start AND sdd.term_end
	WHERE sdd.source_deal_header_id = @deal_id 
		AND sdd.term_start between @term_start  AND  @term_end
  )p
UNPIVOT
    ([Volume] FOR [Hour] IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25))  unpvt  
   --WHERE unpvt.prod_date BETWEEN @term_start AND @term_end
 
 SELECT  sdd.source_deal_detail_id,
		 sddh.term_date prod_date,
		 sddh.hr [hour],
		 sddh.actual_volume actual_hourly_volume,
		 sddh.schedule_volume schedule_hourly_volume,
		 sdd.actual_volume actual_deal_detail_volume,
		 sdd.schedule_volume schedule_deal_detail_volume
INTO #actual_schedule_vol
FROM source_deal_detail sdd 
INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
WHERE sdd.source_deal_header_id = @deal_id AND sdd.term_start = @term_start  AND sdd.term_end = @term_end


SELECT unpvt.source_Deal_detail_id,  unpvt.term_date prod_date, REPLACE(unpvt.[hour],'Hr','') [hour],  unpvt.Volume * CASE WHEN unpvt.buy_sell_flag = 'b' THEN 1 ELSE -1 END Volume 
INTO #deal_detail_hour
  FROM 
(SELECT
	   ddh.term_date, sdd.buy_sell_flag, sdd.source_Deal_detail_id,
	  Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
FROM
    source_deal_detail sdd
	INNER JOIN deal_detail_hour ddh ON ddh.profile_id = sdd.profile_id  AND ddh.term_date between sdd.term_start and  sdd.term_end 
WHERE sdd.source_deal_header_id = @deal_id AND sdd.term_start between @term_start  AND   @term_end
  )p
UNPIVOT
    ([Volume] FOR [Hour] IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)) unpvt  
 

 ------------------
 --position
 CREATE TABLE #deal_position(source_deal_detail_id INT, prod_date datetime, [hour] INT, Volume NUMERIC(38,20))
 
 INSERT INTO #deal_position(source_deal_detail_id, prod_Date, [hour], Volume)
 SELECT unpvt.source_deal_detail_id, unpvt.term_start prod_date, REPLACE(unpvt.[hour],'Hr','') [hour],  unpvt.Volume Volume 
 FROM 
(
	SELECT sdd.source_deal_detail_id, ddh.term_start, Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
	FROM
		dbo.report_hourly_position_deal ddh
		INNER JOIN source_deal_detail sdd ON ddh.term_start BETWEEN sdd.term_start AND sdd.term_end 
			AND ddh.source_deal_detail_id=sdd.source_deal_detail_id
		WHERE sdd.source_deal_header_id = @deal_id AND ddh.term_start BETWEEN  @term_start AND @term_end
   )p
UNPIVOT
    ([Volume] FOR [Hour] IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)) unpvt  
UNION ALL
 SELECT  unpvt.source_deal_detail_id, unpvt.term_start prod_date, REPLACE(unpvt.[hour],'Hr','') [hour],  unpvt.Volume Volume 
 FROM 
   (
	SELECT sdd.source_deal_detail_id, rhpp.term_start, Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
	FROM
		dbo.report_hourly_position_profile rhpp
		INNER JOIN source_deal_detail sdd ON rhpp.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND rhpp.source_deal_detail_id=sdd.source_deal_detail_id
		WHERE sdd.source_deal_header_id = @deal_id AND sdd.term_start = @term_start
   )p
UNPIVOT
    ([Volume] FOR [Hour] IN(Hr1, Hr2, Hr3, Hr4, Hr5 ,Hr6 ,Hr7 ,Hr8 ,Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17,Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)) unpvt  
 
 
 --return
 --select * from #meter_in_deal
 --select * from #meter_in_location
 --select * from #actual_schedule_vol
 --select * from #deal_detail_hour
 --select * from #deal_position

 ------------------
 

	SELECT 
	sdd.source_deal_header_id source_deal_header_id,
	sdd.source_deal_detail_id,
	sdh.counterparty_id,
	sdh.contract_id,
	CAST(hbt.term_date AS DATE) prod_date,
	hbt.hour [hour],
	0 [mins], 
	COALESCE(mid.Volume, mil.Volume, asv.actual_hourly_volume, asv.actual_deal_detail_volume, asv.schedule_hourly_volume, asv.schedule_deal_detail_volume, ddh.Volume, dp.Volume,0)*hbt.volume [value]
FROM source_deal_detail sdd
	INNER JOIN #temp_deals td ON td.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #hour_block hbt ON hbt.term_date BETWEEN sdd.term_start AND sdd.term_end
	LEFT JOIN #meter_in_deal mid ON mid.prod_date = hbt.term_date AND mid.hour = hbt.hour
	LEFT JOIN #meter_in_location mil ON mil.prod_date = hbt.term_date AND mil.hour = hbt.hour
	LEFT JOIN #actual_schedule_vol asv ON asv.prod_date = hbt.term_date AND asv.hour = hbt.hour
	LEFT JOIN #deal_detail_hour ddh ON ddh.prod_date = hbt.term_date AND ddh.hour = hbt.hour
	LEFT JOIN #deal_position dp ON dp.prod_date = hbt.term_date AND dp.hour = hbt.hour	
WHERE sdd.term_start BETWEEN @term_start AND @term_end
	
--WHERE sdd.source_deal_header_id =  @deal_id 
GO

