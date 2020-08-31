IF OBJECT_ID(N'[dbo].[spa_deal_schedule_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_schedule_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2013-12-05
-- Description: Deal Schedule Report
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @phy_deal_id INT = physical deal (parent deal)
-- @term - term of scheduled deal
--EXEC spa_deal_schedule_report 't', 40548	--Schedule Summary Report
--EXEC spa_deal_schedule_report 'd', 36782, '1/1/2014', '1/31/2014'	--Schedule Summary Report

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_schedule_report]
    @flag				CHAR(1),
    @phy_deal_id		INT,
    @term_start			DATETIME = NULL,
    @term_end			DATETIME = NULL,
    @process_table		VARCHAR(100) = NULL,
	@source_deal_detail_id INT = NULL
	
    
AS
SET NOCOUNT ON

/*
	DECLARE @flag				CHAR(1)
    DECLARE @phy_deal_id		INT
    DECLARE @term_start			DATETIME
    DECLARE @term_end			DATETIME
    DECLARE @process_table		VARCHAR(100)
	DECLARE @source_deal_detail_id INT 
	DECLARE @user_login_id VARCHAR(100)
	
	SET @user_login_id = dbo.fnadbuser()
	SET @process_table = dbo.FNAProcessTableName('volume_summary', @user_login_id, dbo.FNAGetNewID())

	SELECT @flag	= 't'		
		   ,@phy_deal_id	= 36593
		   ,@term_start	= NULL
		   ,@term_end = NULL		
		 -- ,@process_table = @process_table



--*/

DECLARE  @sdv_from_deal						INT
		, @internal_deal_subtype_value_id	VARCHAR(50) = 'Transportation'
		, @round_by							INT = 0
		, @term_frequency					CHAR(1)
		, @sql								VARCHAR(8000)

IF OBJECT_ID ('tempdb..#total_scheduled_deals') IS NOT NULL 
	DROP TABLE #total_scheduled_deals

IF OBJECT_ID ('tempdb..#list_template') IS NOT NULL 
	DROP TABLE #list_template

SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

CREATE TABLE #list_template (template_type_id INT
						, template_id	INT
		)

SET @sql = 'INSERT INTO #list_template(template_type_id, template_id)
			SELECT gmv.clm1_value [type id],
				sdht.template_id
			FROM generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id 
				AND gmh.mapping_name = ''Imbalance Report''
			LEFT JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
			WHERE gmv.clm1_value IN (''1'', ''5'')'
	
EXEC(@sql)

SELECT @term_frequency = sdht.term_frequency_type
FROM source_deal_header_template sdht
INNER JOIN #list_template lt ON lt.template_id = sdht.template_id 
	AND lt.template_type_id = 1	--Transportation template type id defined in mapping table.


SELECT * 
INTO #total_scheduled_deals
FROM (
	SELECT sdh.source_deal_header_id			
			, uddft_sch.Field_label
			, uddf_sch.udf_value [udf_value]
			, sdh.template_id
	FROM [user_defined_deal_fields_template] uddft
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
	INNER JOIN #list_template lt ON lt.template_id = sdht.template_id
	INNER JOIN  user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id 
		AND uddft.field_name = @sdv_from_deal 
		AND uddf.udf_value = CAST(@phy_deal_id AS VARCHAR(10))
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft_sch ON sdh.template_id = uddft_sch.template_id
	INNER JOIN user_defined_deal_fields uddf_sch ON uddf_sch.udf_template_id = uddft_sch.udf_template_id 
		AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id
) s1
PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID], [Path Detail ID])) AS a	

--List all scheduled deals.
--SELECT * FROM  #total_scheduled_deals
--RETURN
		
IF @flag IN('t')
BEGIN
	IF OBJECT_ID('tempdb..#phy_deal_vol') IS NOT NULL DROP TABLE #phy_deal_vol
	IF OBJECT_ID('tempdb..#scheduled_deal_vol') IS NOT NULL DROP TABLE  #scheduled_deal_vol
	IF OBJECT_ID('tempdb..#available_deal_vol') IS NOT NULL DROP TABLE  #available_deal_vol
	
	CREATE TABLE #phy_deal_vol (
			term_start		DATETIME
			, term_end		DATETIME
			, phy_deal_volume	NUMERIC(38, 20)	
			)
			
	SET @sql = '
			INSERT INTO #phy_deal_vol (term_start, term_end, phy_deal_volume)
			SELECT MIN(rhpd.term_start) term_start, MAX(rhpd.term_start) term_end, (ISNULL(SUM(rhpd.hr1), 0) + ISNULL(SUM(rhpd.hr2), 0) + ISNULL(SUM(rhpd.hr3), 0) + ISNULL(SUM(rhpd.hr4), 0) + ISNULL(SUM(rhpd.hr5), 0) 
			+ ISNULL(SUM(rhpd.hr6), 0) + ISNULL(SUM(rhpd.hr7), 0) + ISNULL(SUM(rhpd.hr8), 0) + ISNULL(SUM(rhpd.hr9), 0) + ISNULL(SUM(rhpd.hr10), 0) 
			+ ISNULL(SUM(rhpd.hr11), 0) + ISNULL(SUM(rhpd.hr12), 0) + ISNULL(SUM(rhpd.hr13), 0) + ISNULL(SUM(rhpd.hr14), 0) + ISNULL(SUM(rhpd.hr15), 0) 
			+ ISNULL(SUM(rhpd.hr16), 0) + ISNULL(SUM(rhpd.hr17), 0) + ISNULL(SUM(rhpd.hr18), 0) + ISNULL(SUM(rhpd.hr19), 0) + ISNULL(SUM(rhpd.hr20), 0) 
			+ ISNULL(SUM(rhpd.hr21), 0) + ISNULL(SUM(rhpd.hr22), 0) + ISNULL(SUM(rhpd.hr23), 0) + ISNULL(SUM(rhpd.hr24), 0) + ISNULL(SUM(rhpd.hr25), 0)) deal_volume
	FROM report_hourly_position_deal rhpd
	WHERE rhpd.source_deal_header_id = ' + CAST(@phy_deal_id AS VARCHAR(20)) + ' 
	GROUP BY ' + CASE @term_frequency WHEN 'm' THEN 'YEAR(rhpd.term_start), MONTH(rhpd.term_start)' 
								ELSE 'rhpd.term_start' END

		
		--SET @sql = '
		--	INSERT INTO #phy_deal_vol (term_start, term_end, phy_deal_volume)
		--	SELECT MIN(term_start), MAX(term_end), SUM(deal_volume)  
		--	FROM source_deal_detail sdd			
		--	WHERE 1 = 1 '

		--IF @source_deal_detail_id IS NOT NULL
		--BEGIN
		--	SET @sql = @sql + ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20)) + '  GROUP BY source_deal_detail_id'
		--END
		--ELSE IF @phy_deal_id IS NOT NULL
		--BEGIN
		--	SET @sql = @sql + ' AND sdd.source_deal_header_id = ' + CAST(@phy_deal_id AS VARCHAR(20)) + ' GROUP BY  ' + CASE @term_frequency WHEN 'm' THEN 'YEAR(term_start), MONTH(term_start)' 
		--						ELSE 'term_start' END
		--END	
		


	--PRINT ISNULL(@sql, '@sql IS NULL')
	EXEC(@sql)
	
	SELECT 
		sdd.term_start term_start,
		sdd.term_end term_end,
		SUM(sdd.deal_volume) scheduled_deal_volume
		, MAX(sdh.counterparty_id) counterparty_id
		, MAX(sdh.trader_id) trader_id
		--, MAX(sdd.deal_volume_uom_id) volume_uom
	INTO #scheduled_deal_vol
	FROM (
		SELECT tsd_inner.[Scheduled ID] scheduled_id
						, ISNULL(MIN(tsd_inner.[Path Detail ID]), -1) path_detail_id
					FROM #total_scheduled_deals tsd_inner
					GROUP BY tsd_inner.[Scheduled ID]
	) sch_deals
	INNER JOIN #total_scheduled_deals tsd ON tsd.[Scheduled ID] = sch_deals.scheduled_id
		AND ISNULL(tsd.[Path Detail ID], -1) = sch_deals.path_detail_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id AND sdd.leg = 1
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	GROUP BY sdd.term_start, sdd.term_end
	ORDER BY term_start
				
	--Scheduled volume
	--SELECT * FROM #scheduled_deal_vol
	
	SELECT	pdv.term_start
			, pdv.term_end
			, MAX(sc.counterparty_id) [Counterparty]
			, MAX(st.trader_name) [Trader]
			, MAX(pdv.phy_deal_volume) [Volume]
			, SUM(ISNULL(sdv.scheduled_deal_volume, 0)) scheduled_deal_volume
			, (MAX(pdv.phy_deal_volume) - SUM(ISNULL(sdv.scheduled_deal_volume, 0))) [available_volume]	
			--, MAX(su.uom_name) [UOM]
	INTO #available_deal_vol
	FROM #phy_deal_vol pdv
	LEFT JOIN #scheduled_deal_vol sdv ON sdv.term_start BETWEEN  pdv.term_start AND pdv.term_end
	LEFT JOIN source_counterparty sc ON sdv.counterparty_id = sc.source_counterparty_id
	LEFT JOIN source_traders st ON st.source_trader_id = sdv.trader_id
	--LEFT JOIN source_uom su ON su.source_uom_id = sdv.volume_uom
	GROUP BY pdv.term_start, pdv.term_end
	ORDER BY pdv.term_start
	
	SET @sql = '
				SELECT  dbo.FNATrmHyperlink(''b'', 10131010,' + CAST(@phy_deal_id AS VARCHAR(20)) +' ,' + CAST(@phy_deal_id AS VARCHAR(20)) + ', ''n'',
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT) [Deal ID]'
						+ CASE WHEN @process_table IS NULL 
							THEN ', dbo.FNADateFormat(term_start) [Flow Date From], dbo.FNADateFormat(term_end) [Flow Date To]' 
							ELSE ', term_start [Flow Date From], term_end [Flow Date To]' 
						  END  + '
						, [Counterparty]  Pipeline
						, [Trader]
						, dbo.FNARemoveTrailingZeroes(ROUND([Volume], ' + CAST(@round_by AS VARCHAR(2)) + ')) [Volume]
						, dbo.FNARemoveTrailingZeroes(ROUND(scheduled_deal_volume, ' + CAST(@round_by AS VARCHAR(2)) + ')) [Scheduled Volume]
						, dbo.FNARemoveTrailingZeroes(ROUND(available_volume, ' + CAST(@round_by AS VARCHAR(2)) + ')) [Available Volume]
						, phy_uom.[UOM]
				'
				+ CASE WHEN @process_table IS NULL THEN '' ELSE ' INTO ' + @process_table  END +
				'
				FROM #available_deal_vol	
				OUTER APPLY (
					SELECT MAX(su.uom_name) [UOM]
					FROM source_deal_detail sdd 
					LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
					WHERE sdd.source_deal_header_id = ' + CAST(@phy_deal_id AS VARCHAR(20)) + '
				) phy_uom
				WHERE 1 = 1 				
				' +
				CASE WHEN @term_start IS NOT NULL THEN ' AND term_start >= ''' + CAST(@term_start AS VARCHAR) + '''' ELSE '' END
				+ CASE WHEN @term_end IS NOT NULL THEN 'AND term_end <= ''' + CAST(@term_end AS VARCHAR) + '''' ELSE '' END
				+ ' ORDER BY [Deal ID], [Flow Date From],[Flow Date To]' 
	--PRINT @sql
	EXEC(@sql)
	
END
ELSE IF @flag = 'd'
BEGIN	
	--10131010 function id for deal update page.
	
	SELECT tsd.source_deal_header_id
		, dp.path_code
		, dp.path_id 
		, CASE WHEN sdd.leg = 1 THEN sm1.Location_Name ELSE NULL END receipt_location
		, CASE WHEN sdd.leg = 2 THEN sm1.Location_Name ELSE NULL END delivery_location
		, CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END receipt_volume
		, CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END delivery_volume
		, sdd.term_start
		, sdd.term_end
		, sdd.deal_volume_uom_id
	INTO #deal_detail
	FROM  #total_scheduled_deals tsd 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id
		INNER JOIN deal_schedule ds ON ds.deal_schedule_id = tsd.[Scheduled ID]	
		INNER JOIN delivery_path dp ON dp.path_id = ds.path_id
		LEFT JOIN source_minor_location sm1 ON sm1.source_minor_location_id = sdd.location_id
	WHERE sdd.term_start BETWEEN @term_start AND @term_end
	
	--Final query
	SELECT 
		dbo.FNATrmHyperlink('b', 10131010, @phy_deal_id , @phy_deal_id , 'n',
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT) [Deal ID],
		dbo.FNADateFormat(term_start) [Flow Date From],
		dbo.FNADateFormat(term_end) [Flow Date To],
		dbo.FNATrmHyperlink('b', 10131010,dd.source_deal_header_id , dd.source_deal_header_id, 'n',
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT,
									DEFAULT) [Schedule ID]
			, dbo.FNAHyperLink(10161100, MAX(path_code), MAX(path_id), -1) [Path]
			, MAX(receipt_location) [Receipt Location]	
			, MAX(delivery_location)[Delivery Location]
			, dbo.FNARemoveTrailingZeroes(ROUND(SUM(receipt_volume), @round_by)) [Receipt Volume]
			, dbo.FNARemoveTrailingZeroes(ROUND(SUM(delivery_volume), @round_by)) [Delivery Volume] 
			, MAX(su.uom_name) [UOM]
	FROM  #deal_detail dd
	LEFT JOIN source_uom su ON su.source_uom_id = dd.deal_volume_uom_id
	GROUP BY term_start, term_end, dd.source_deal_header_id	
	ORDER BY term_start
END

