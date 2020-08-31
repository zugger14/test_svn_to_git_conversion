
IF OBJECT_ID(N'[dbo].[spa_etag]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_etag]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: kcshrestha@pioneersolutionsglobal.com
-- Create date: 2014-03-14
-- Description: CRUD operations for table etag
 
-- Params:
-- @flag					CHAR(1) - Operation flag
-- @etag_id					INT - Etag ID
-- @control_areas			NVARCHAR(500) - Control Areas
-- @transmission_providers	NVARCHAR(500) - Transmission Providers
-- @pse						NVARCHAR(500) - PSE
-- @point_of_receipt		NVARCHAR(500) - Point of Receipt 
-- @point_of_delivery		NVARCHAR(500) - Point of Delivery
-- @scheduling_entity		NVARCHAR(500) - Scheduling Entity
-- @generator				NVARCHAR(500) - Generator
-- @as_of_date				DATE - As of Date
-- @tag_status				INT - Tag Status
-- @match_status			INT - Match Status
-- @etag_id					NVARCHAR(500) - Tag ID provided by OATI 
-- @deal_id					INT - Deal ID
-- @etag_detail_id			INT - Etag Detail ID
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_etag]
    @flag						CHAR(1),
    @etag_id					INT = NULL,
    @control_areas				INT = NULL,
    @transmission_providers		INT = NULL,
    @pse						INT = NULL,
    @receipt_point			INT = NULL,
    @delivery_point			INT = NULL,
	@scheduling_entity			INT = NULL,
	@generator					INT = NULL,
	@as_of_date					DATE = NULL, 
	@tag_status					INT = NULL,
	@match_status				INT = NULL,
	@etag_oati_id				NVARCHAR(500) = NULL,
	@deal_id					INT = NULL,
	@etag_detail_id				INT = NULL,
	@xml						XML = NULL,
	@location					INT=NULL,
	@type						CHAR(1)=NULL,
	@tag_id						VARCHAR(100) = NULl,
	@owner						INT = NULl
AS
SET NOCOUNT ON
DECLARE @sql NVARCHAR(MAX)
DECLARE @desc NVARCHAR(500)

IF @flag IN ('s', 'v')
BEGIN
	IF OBJECT_ID('tempdb..#temp_etag') IS NOT NULL
		DROP TABLE #temp_etag

	IF OBJECT_ID('tempdb..#temp_etag_detail') IS NOT NULL
		DROP TABLE #temp_etag_detail
	
	SELECT 
		CAST(etag_id AS VARCHAR(500)) etag_id,
		CAST(control_areas AS VARCHAR(500)) control_areas,
		CAST(control_area_type AS VARCHAR(500)) control_area_type,
		CAST(transmission_providers AS VARCHAR(500)) transmission_providers,
		CAST(pse AS VARCHAR(500)) pse,
		CAST(point_of_receipt AS VARCHAR(500)) point_of_receipt,
		CAST(point_of_delivery AS VARCHAR(500)) point_of_delivery,
		CAST(scheduling_entity AS VARCHAR(500)) scheduling_entity,
		CAST(generator AS VARCHAR(500)) generator,
		CAST(counterparty_id AS VARCHAR(500)) counterparty_id
	INTO #temp_etag_detail
	FROM 
		etag		

	UPDATE e
	SET 
		--e.control_areas = CASE WHEN e.control_areas IS NULL THEN e1.control_areas ELSE e.control_areas END,
		e.control_areas =  e.control_areas,
		e.control_area_type = CASE WHEN e.control_area_type IS NULL THEN e2.control_area_type ELSE e.control_area_type END,
		e.transmission_providers = CASE WHEN e.transmission_providers IS NULL THEN e3.transmission_providers ELSE e.transmission_providers END,
		e.pse = CASE WHEN e.pse IS NULL THEN e4.pse ELSE e.pse END,
		e.point_of_receipt = CASE WHEN e.point_of_receipt IS NULL THEN e5.point_of_receipt ELSE e.point_of_receipt END,
		e.point_of_delivery = CASE WHEN e.point_of_delivery IS NULL THEN e6.point_of_delivery ELSE e.point_of_delivery END,
		e.scheduling_entity = CASE WHEN e.scheduling_entity IS NULL THEN e7.scheduling_entity ELSE e.scheduling_entity END,
		e.generator = CASE WHEN e.generator IS NULL THEN e8.generator ELSE e.generator END,
		--e.counterparty_id = CASE WHEN e.counterparty_id IS NULL THEN e9.counterparty_id ELSE e.counterparty_id END
		e.counterparty_id = e.counterparty_id 
	FROM
		#temp_etag_detail e
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(control_areas AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS control_areas) e1
		OUTER APPLY(SELECT MAX(control_area_type) control_area_type FROM etag  WHERE etag_id=e.etag_id) e2
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(transmission_providers AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS transmission_providers) e3
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(pse AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS pse) e4
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(point_of_receipt AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS point_of_receipt) e5
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(point_of_delivery AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS point_of_delivery) e6
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(scheduling_entity AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS scheduling_entity) e7
		OUTER APPLY(SELECT MAX(generator) generator FROM etag  WHERE etag_id=e.etag_id) e8
		OUTER APPLY(SELECT (Stuff((SELECT ', ' + CAST(counterparty_id AS VARCHAR) FROM etag  WHERE etag_id=e.etag_id FOR XML PATH('')  ), 1, 2, '')) AS counterparty_id) e9
	WHERE 1=1
	



				
	CREATE TABLE #temp_etag (etag_id INT, tag_id VARCHAR(100) COLLATE DATABASE_DEFAULT, oati_tag_id NVARCHAR(500) COLLATE DATABASE_DEFAULT, term DATETIME, hrs INT, etag_value FLOAT, matched_deal NVARCHAR(200) COLLATE DATABASE_DEFAULT)
	
	SET @sql = 'INSERT INTO #temp_etag (etag_id, tag_id, oati_tag_id, term, hrs, etag_value, matched_deal)
				SELECT DISTINCT et.etag_id,
					   et.tag_id,
					   et.oati_tag_id,
					   ed.term, 
					   ed.hrs,
					   ed.etag_value,
					   CASE WHEN et.source_deal_header_id IS NOT NULL THEN et.source_deal_header_id ELSE '''' END
				FROM etag_header AS et
				INNER JOIN etag_detail AS ed ON ed.etag_id = et.etag_id
				LEFT JOIN #temp_etag_detail e ON e.etag_id = et.etag_id
				WHERE 1 =1 '	
		
	IF (@control_areas IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.control_areas	LIKE ''%' + CAST(@control_areas AS VARCHAR(10)) +'%'''
		IF (@type IS NOT NULL) 
		BEGIN
			SET @sql = @sql + ' AND e.control_area_type		LIKE ''%' + CASE WHEN @type='1' THEN 'Source' ELSE 'Sink' END++'%'''
		END
	END
	
	IF (@transmission_providers IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.transmission_providers 	LIKE ''%' + CAST(@transmission_providers AS VARCHAR(10))+'%'''
	END
	
	IF (@pse IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.pse 	LIKE ''%' + CAST(@pse AS VARCHAR(10))+'%'''
	END
	
	IF (@receipt_point IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.point_of_receipt 	LIKE ''%' + CAST(@receipt_point AS VARCHAR(10))+'%'''

		IF (@generator IS NOT NULL) 
		BEGIN
			SET @sql = @sql + ' AND e.generator = '''+CASE WHEN @generator=1 THEN 'Generator' ELSE 'Sink' END +''''
		END
	END
	
	IF (@delivery_point IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.point_of_delivery		LIKE ''%' + CAST(@delivery_point AS VARCHAR(10))+'%'''

		IF (@generator IS NOT NULL) 
		BEGIN
			SET @sql = @sql + ' AND e.generator = '''+CASE WHEN @generator=1 THEN 'Generator' ELSE 'Sink' END +''''
		END
	END
	
	IF (@scheduling_entity IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.scheduling_entity		LIKE ''%' + CAST(@scheduling_entity AS VARCHAR(10))+'%'''
	END
		
	IF (@as_of_date IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND ed.term = ''' + CAST(@as_of_date AS NVARCHAR(10)) + ''''
	END
	
	IF (@etag_oati_id IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND et.oati_tag_id LIKE ''' + CAST(@etag_oati_id AS NVARCHAR(100)) + '%'''
	END
	
	IF (@tag_id IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND et.tag_id LIKE ''' + CAST(@tag_id AS NVARCHAR(100)) + '%'''
	END
	
	
	IF (@etag_id IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND et.etag_id = ' + CAST(@etag_id AS NVARCHAR(100)) 
	END
		
	IF (@match_status IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND ISNULL(et.match_status,27202)	= ' + CAST(@match_status AS NVARCHAR(100)) 
	END
	

	
	IF (@owner IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND e.counterparty_id 	LIKE ''%' + CAST(@owner AS NVARCHAR(100)) +'%'''

		IF (@generator IS NOT NULL) 
		BEGIN
			SET @sql = @sql + ' AND e.generator = '''+CASE WHEN @generator=1 THEN 'Generator' ELSE 'Sink' END +''''
		END
	END


	

	
	exec spa_print @sql		
	EXEC (@sql)	
	
	IF @flag = 's'
	BEGIN
		SELECT oati_tag_id,
			   '<span style="cursor:pointer" onClick="TRMWinHyperlink(10163110,'+cast(etag_id AS NVARCHAR(100))+','''+cast(oati_tag_id AS NVARCHAR(100))+''')"><font color=#0000ff><u><l>'+ tag_id +'<l></u></font></span>' etag_id,
			   etag_id id,
			   matched_deal,
			   ISNULL([1], '') Hr1, ISNULL([2], '') Hr2, ISNULL([3], '') Hr3, ISNULL([4], '') Hr4, ISNULL([5], '') Hr5, 
			   ISNULL([6], '') Hr6, ISNULL([7], '') Hr7, ISNULL([8], '') Hr8, ISNULL([9], '') Hr9, ISNULL([10], '') Hr10, 
			   ISNULL([11], '') Hr11, ISNULL([12], '') Hr12, ISNULL([13], '') Hr13, ISNULL([14], '') Hr14, ISNULL([15], '') Hr15, 
			   ISNULL([16], '') Hr16, ISNULL([17], '') Hr17, ISNULL([18], '') Hr18, ISNULL([19], '') Hr19, ISNULL([20], '') Hr20, 
			   ISNULL([21], '') Hr21, ISNULL([22], '') Hr22, ISNULL([23], '') Hr23, ISNULL([24], '') Hr24, ISNULL([25], '') Hr25
		FROM   #temp_etag p
		PIVOT
		(SUM(etag_value)
 				FOR [hrs] IN 
 				([1], [2], [3], [4], [5], [6], 
 				[7], [8], [9], [10], [11], [12], 
 				[13], [14], [15], [16], [17], [18], 
 				[19], [20], [21], [22], [23], [24], [25])
		) pvt
	END
	ELSE
	BEGIN
		SELECT etag_id [Id],
			   dbo.FNAHyperLinkText(10163110, tag_id, cast(etag_id AS NVARCHAR(100))) [Oati Id],
			   [1] Hr1, [2] Hr2, [3] Hr3, [4] Hr4, [5] Hr5, 
			   [6] Hr6, [7] Hr7, [8] Hr8, [9] Hr9, [10] Hr10, 
			   [11] Hr11, [12] Hr12, [13] Hr13, [14] Hr14, [15] Hr15, 
			   [16] Hr16, [17] Hr17, [18] Hr18, [19] Hr19, [20] Hr20, 
			   [21] Hr21, [22] Hr22, [23] Hr23, [24] Hr24, [25] Hr25
		FROM   #temp_etag p
		PIVOT
		(SUM(etag_value)
 				FOR [hrs] IN 
 				([1], [2], [3], [4], [5], [6], 
 				[7], [8], [9], [10], [11], [12], 
 				[13], [14], [15], [16], [17], [18], 
 				[19], [20], [21], [22], [23], [24], [25])
		) pvt
	END
END
ELSE IF @flag IN ('t', 'w')
BEGIN
	IF OBJECT_ID('tempdb..#temp_position_etag') IS NOT NULL
		DROP TABLE #temp_position_etag
		
	CREATE TABLE #temp_position_etag (
		[Deal] NVARCHAR(2000) COLLATE DATABASE_DEFAULT, [tag_id] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, [id] NVARCHAR(1000) COLLATE DATABASE_DEFAULT, hr1 FLOAT, hr2 FLOAT, hr3 FLOAT, hr4 FLOAT, hr5 FLOAT, 
		hr6 FLOAT, hr7 FLOAT, hr8 FLOAT, hr9 FLOAT, hr10 FLOAT, 
		hr11 FLOAT, hr12 FLOAT, hr13 FLOAT, hr14 FLOAT, hr15 FLOAT, 
		hr16 FLOAT, hr17 FLOAT, hr18 FLOAT, hr19 FLOAT, hr20 FLOAT, 
		hr21 FLOAT, hr22 FLOAT, hr23 FLOAT, hr24 FLOAT, hr25 FLOAT,
		ordering_seq INT,
		match_status CHAR(1) COLLATE DATABASE_DEFAULT
	)
	
	SET @sql = 'INSERT INTO #temp_position_etag (
					[Deal], [tag_id], [id], hr1, hr2, hr3, hr4, hr5, 
					hr6, hr7, hr8, hr9, hr10, 
					hr11, hr12, hr13, hr14, hr15, 
					hr16, hr17, hr18, hr19, hr20, 
					hr21, hr22, hr23, hr24, hr25,
					ordering_seq
				)
				SELECT CAST(sdh.source_deal_header_id AS VARCHAR(10))
					   + '', Counterparty: '' + sc.counterparty_id + ''''
					   + ISNULL('', Trader: '' + st.trader_id  + '''', '''') 
					   + ISNULL('', Location: '' + sml.location_id  + '''', '''')
					   + ISNULL('', Block Definition: '' + sdv.code  + '''', '''') [Deal],
					   ''Deal'',
					   sdh.source_deal_header_id,
					   rhpd.hr1,
					   rhpd.hr2,
					   rhpd.hr3,
					   rhpd.hr4,
					   rhpd.hr5,
					   rhpd.hr6,
					   rhpd.hr7,
					   rhpd.hr8,
					   rhpd.hr9,
					   rhpd.hr10,
					   rhpd.hr11,
					   rhpd.hr12,
					   rhpd.hr13,
					   rhpd.hr14,
					   rhpd.hr15,
					   rhpd.hr16,
					   rhpd.hr17,
					   rhpd.hr18,
					   rhpd.hr19,
					   rhpd.hr20,
					   rhpd.hr21,
					   rhpd.hr22,
					   rhpd.hr23,
					   rhpd.hr24,
					   rhpd.hr25,
					   0
				FROM report_hourly_position_deal rhpd 
				INNER JOIN source_deal_header sdh ON rhpd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN (SELECT DISTINCT source_deal_header_id, location_id FROM source_deal_detail) sdd  ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_counterparty AS sc ON sc.source_counterparty_id = COALESCE(rhpd.counterparty_id, sdh.counterparty_id)
				LEFT JOIN source_traders AS st ON st.source_trader_id = sdh.trader_id
				LEFT JOIN source_minor_location AS sml ON sml.source_minor_location_id = COALESCE(rhpd.location_id, sdd.location_id) 
				LEFT JOIN static_data_value AS sdv ON sdv.value_id = sdh.block_define_id
				OUTER APPLY(select MAX(match_status) match_status FROM etag_header WHERE source_deal_header_id = sdh.source_deal_header_id) et
				LEFT JOIN source_commodity sc1 ON sc1.source_commodity_id = sdh.commodity_id	
				WHERE 1 = 1 AND sc1.commodity_id=''Power'' '
				+CASE WHEN @match_status IS NOT NULL THEN ' AND ISNULL(et.match_status,27202)='+CAST(@match_status AS VARCHAR) ELSE '' END
	
	IF @as_of_date IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND CONVERT(VARCHAR(10), rhpd.term_start, 120) = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''	
	END	
	
	IF @deal_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND rhpd.source_deal_header_id = ' + CAST(@deal_id AS VARCHAR(10))
	END
	


	IF @location IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sml.source_minor_location_id = ' + CAST(@location AS VARCHAR(10))
	END



	--PRINT(@sql)
	EXEC(@sql)

	IF OBJECT_ID('tempdb..#temp_etag_deals') IS NOT NULL
		DROP TABLE #temp_etag_deals
		
	CREATE TABLE #temp_etag_deals (deal_id NVARCHAR(2000) COLLATE DATABASE_DEFAULT, id NVARCHAR(50) COLLATE DATABASE_DEFAULT, etag_id INT,tag_id VARCHAR(100) COLLATE DATABASE_DEFAULT, oati_tag_id NVARCHAR(500) COLLATE DATABASE_DEFAULT, term DATETIME, hrs INT, etag_value FLOAT)
	
	SET @sql = 'INSERT INTO #temp_etag_deals (deal_id, id,etag_id, tag_id, oati_tag_id, term, hrs, etag_value)
				SELECT CAST(et.source_deal_header_id AS VARCHAR(10))
					   + '', Counterparty: '' + MAX(sc.counterparty_id) + ''''
					   + ISNULL('', Trader: '' + MAX(st.trader_id)  + '''', '''') 
					   + ISNULL('', Location: '' + MAX(sml.location_id)  + '''', '''')
					   + ISNULL('', Block Definition: '' + MAX(sdv.code)  + '''', ''''),
					   et.source_deal_header_id,					   
					   et.etag_id,
					   et.tag_id,
					   et.oati_tag_id,
					   MAX(ed.term) term, 
					   ed.hrs,
					   MAX(ed.etag_value)
				FROM etag_header AS et
				INNER JOIN etag_detail AS ed ON ed.etag_id = et.etag_id
				INNER JOIN source_deal_header sdh ON et.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN (SELECT DISTINCT source_deal_header_id, location_id FROM source_deal_detail) sdd  ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_counterparty AS sc ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN source_traders AS st ON st.source_trader_id = sdh.trader_id
				LEFT JOIN source_minor_location AS sml ON sml.source_minor_location_id = sdd.location_id
				LEFT JOIN static_data_value AS sdv ON sdv.value_id = sdh.block_define_id 
				INNER JOIN report_hourly_position_deal rhpd ON rhpd.source_deal_header_id = sdh.source_deal_header_id AND rhpd.term_start = ed.term 	
				LEFT JOIN source_commodity sc1 ON sc1.source_commodity_id = sdh.commodity_id			
				WHERE 1 =1 AND et.source_deal_header_id IS NOT NULL AND sc1.commodity_id=''Power'' '	
				+CASE WHEN @match_status IS NOT NULL THEN ' AND ISNULL(et.match_status,27202)='+CAST(@match_status AS VARCHAR) ELSE '' END
		
	IF (@as_of_date IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND ed.term = ''' + CAST(@as_of_date AS NVARCHAR(10)) + ''''
	END
	
	IF (@deal_id IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND et.source_deal_header_id	= ' + CAST(@deal_id AS VARCHAR(10))
	END

	IF (@location IS NOT NULL) 
	BEGIN
		SET @sql = @sql + ' AND sdd.location_id	= ' + CAST(@location AS VARCHAR(10))
	END
		
	SET @sql = @sql + ' GROUP BY et.source_deal_header_id, et.etag_id,et.tag_id, et.oati_tag_id, ed.hrs '
	
	--PRINT (@sql)		
	EXEC (@sql)	

	
	INSERT INTO #temp_position_etag (
		[Deal], [tag_id], [id], hr1, hr2, hr3, hr4, hr5, 
		hr6, hr7, hr8, hr9, hr10, 
		hr11, hr12, hr13, hr14, hr15, 
		hr16, hr17, hr18, hr19, hr20, 
		hr21, hr22, hr23, hr24, hr25,
		ordering_seq
	)
	SELECT deal_id,
		   dbo.FNAHyperLinkText(10163110, tag_id, CAST(etag_id AS NVARCHAR(100))) oati_tag_id,
		   etag_id,
		   [1] Hr1, [2] Hr2, [3] Hr3, [4] Hr4, [5] Hr5, 
		   [6] Hr6, [7] Hr7, [8] Hr8, [9] Hr9, [10] Hr10, 
		   [11] Hr11, [12] Hr12, [13] Hr13, [14] Hr14, [15] Hr15, 
		   [16] Hr16, [17] Hr17, [18] Hr18, [19] Hr19, [20] Hr20, 
		   [21] Hr21, [22] Hr22, [23] Hr23, [24] Hr24, [25] Hr25,
		   ROW_NUMBER() OVER (PARTITION BY id ORDER BY id)
	FROM #temp_etag_deals p	
	PIVOT
	(SUM(etag_value)
 			FOR [hrs] IN 
 			([1], [2], [3], [4], [5], [6], 
 			[7], [8], [9], [10], [11], [12], 
 			[13], [14], [15], [16], [17], [18], 
 			[19], [20], [21], [22], [23], [24], [25])
	) pvt


	
	-- matched_deal is necessary for drag n drop functionality of e-tag UI	
	IF @flag = 't'
	BEGIN
		SELECT [Deal],[id], et.[tag_id],  '' [matched_deal],
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr1,0)<> ISNULL(ted2.hr1,0) THEN  '<font color=red>' + CAST(et.hr1 AS VARCHAR)+'<font>' ELSE CAST(et.hr1 AS VARCHAR)  END hr1,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr2,0)<> ISNULL(ted2.hr2,0) THEN  '<font color=red>' + CAST(et.hr2 AS VARCHAR)+'<font>' ELSE CAST(et.hr2 AS VARCHAR) END hr2,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr3,0)<>ISNULL(ted2.hr3,0) THEN  '<font color=red>' + CAST(et.hr3 AS VARCHAR)+'<font>' ELSE CAST(et.hr3 AS VARCHAR) END hr3,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr4,0)<>ISNULL(ted2.hr4,0) THEN  '<font color=red>' + CAST(et.hr4 AS VARCHAR)+'<font>' ELSE CAST(et.hr4 AS VARCHAR) END hr4,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr5,0)<>ISNULL(ted2.hr5,0) THEN  '<font color=red>' + CAST(et.hr5 AS VARCHAR)+'<font>' ELSE CAST(et.hr5 AS VARCHAR) END hr5,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr6,0)<>ISNULL(ted2.hr6,0) THEN  '<font color=red>' + CAST(et.hr6 AS VARCHAR)+'<font>' ELSE CAST(et.hr6 AS VARCHAR) END hr6,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr7,0)<>ISNULL(ted2.hr7,0) THEN  '<font color=red>' + CAST(et.hr7 AS VARCHAR)+'<font>' ELSE  CAST(et.hr7 AS VARCHAR) END hr7,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr8,0)<>ISNULL(ted2.hr8,0) THEN  '<font color=red>' + CAST(et.hr8 AS VARCHAR)+'<font>' ELSE CAST(et.hr8 AS VARCHAR) END hr8,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr9,0)<>ISNULL(ted2.hr9,0) THEN  '<font color=red>' + CAST(et.hr9 AS VARCHAR)+'<font>' ELSE CAST(et.hr9 AS VARCHAR) END hr9,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr10,0)<>ISNULL(ted2.hr10,0) THEN  '<font color=red>' + CAST(et.hr10 AS VARCHAR)+'<font>' ELSE CAST(et.hr10 AS VARCHAR) END hr10,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr11,0)<>ISNULL(ted2.hr11,0) THEN  '<font color=red>' + CAST(et.hr11 AS VARCHAR)+'<font>' ELSE  CAST(et.hr11 AS VARCHAR) END hr11,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr12,0)<>ISNULL(ted2.hr12,0) THEN  '<font color=red>' + CAST(et.hr12 AS VARCHAR)+'<font>' ELSE  CAST(et.hr12 AS VARCHAR) END hr12,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr13,0)<>ISNULL(ted2.hr13,0) THEN  '<font color=red>' + CAST(et.hr13 AS VARCHAR)+'<font>' ELSE CAST(et.hr13 AS VARCHAR) END hr13,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr14,0)<>ISNULL(ted2.hr14,0) THEN  '<font color=red>' + CAST(et.hr14 AS VARCHAR)+'<font>' ELSE CAST(et.hr14 AS VARCHAR) END hr14,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr15,0)<>ISNULL(ted2.hr15,0) THEN  '<font color=red>' + CAST(et.hr15 AS VARCHAR)+'<font>' ELSE CAST(et.hr15 AS VARCHAR) END hr15,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr16,0)<>ISNULL(ted2.hr16,0) THEN  '<font color=red>' + CAST(et.hr16 AS VARCHAR)+'<font>' ELSE CAST(et.hr16 AS VARCHAR) END hr16,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr17,0)<>ISNULL(ted2.hr17,0) THEN  '<font color=red>' + CAST(et.hr17 AS VARCHAR)+'<font>' ELSE CAST(et.hr17 AS VARCHAR) END hr17,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr18,0)<>ISNULL(ted2.hr18,0) THEN  '<font color=red>' + CAST(et.hr18 AS VARCHAR)+'<font>' ELSE CAST(et.hr18 AS VARCHAR) END hr18,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr19,0)<>ISNULL(ted2.hr19,0) THEN  '<font color=red>' + CAST(et.hr19 AS VARCHAR)+'<font>' ELSE CAST(et.hr19 AS VARCHAR) END hr19,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr20,0)<>ISNULL(ted2.hr20,0) THEN  '<font color=red>' + CAST(et.hr20 AS VARCHAR)+'<font>' ELSE CAST(et.hr20 AS VARCHAR) END hr20,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr21,0)<>ISNULL(ted2.hr21,0) THEN  '<font color=red>' + CAST(et.hr21 AS VARCHAR)+'<font>' ELSE CAST(et.hr21 AS VARCHAR) END hr21,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr22,0)<>ISNULL(ted2.hr22,0) THEN  '<font color=red>' + CAST(et.hr22 AS VARCHAR)+'<font>' ELSE CAST(et.hr22 AS VARCHAR) END hr22,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr23,0)<>ISNULL(ted2.hr23,0) THEN  '<font color=red>' + CAST(et.hr23 AS VARCHAR)+'<font>' ELSE CAST(et.hr23 AS VARCHAR) END hr23,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr24,0)<>ISNULL(ted2.hr24,0) THEN  '<font color=red>' + CAST(et.hr24 AS VARCHAR)+'<font>' ELSE CAST(et.hr24 AS VARCHAR) END hr24,
			CASE WHEN et.tag_id='Deal' AND ted2.tag_id IS NOT NULL AND ISNULL(ted1.hr25,0)<>ISNULL(ted2.hr25,0) THEN  '<font color=red>' + CAST(et.hr25 AS VARCHAR)+'<font>' ELSE CAST(et.hr25 AS VARCHAR) END hr25		
		FROM #temp_position_etag et
		OUTER APPLY(SELECT SUM(hr1) hr1,SUM(hr2) hr2,SUM(hr3) hr3,SUM(hr4) hr4,SUM(hr5) hr5,SUM(hr6) hr6,SUM(hr7) hr7,
			SUM(hr8) hr8,SUM(hr9) hr9,SUM(hr10) hr10,SUM(hr11) hr11,SUM(hr12) hr12,SUM(hr13) hr13,SUM(hr14) hr14,SUM(hr15) hr15,
			SUM(hr16) hr16,SUM(hr17) hr17,SUM(hr18) hr18,SUM(hr19) hr19,SUM(hr20) hr20,SUM(hr21) hr21,SUM(hr22) hr22,SUM(hr23) hr23,SUM(hr24) hr24,SUM(hr25) hr25
		 FROM #temp_position_etag WHERE deal = et.deal AND tag_id='Deal'
		) ted1
			OUTER APPLY(SELECT MAX(tag_id) tag_id,SUM(hr1) hr1,SUM(hr2) hr2,SUM(hr3) hr3,SUM(hr4) hr4,SUM(hr5) hr5,SUM(hr6) hr6,SUM(hr7) hr7,
			SUM(hr8) hr8,SUM(hr9) hr9,SUM(hr10) hr10,SUM(hr11) hr11,SUM(hr12) hr12,SUM(hr13) hr13,SUM(hr14) hr14,SUM(hr15) hr15,
			SUM(hr16) hr16,SUM(hr17) hr17,SUM(hr18) hr18,SUM(hr19) hr19,SUM(hr20) hr20,SUM(hr21) hr21,SUM(hr22) hr22,SUM(hr23) hr23,SUM(hr24) hr24,SUM(hr25) hr25
		 FROM #temp_position_etag WHERE deal = et.deal AND tag_id <> 'Deal'
		) ted2
		
		ORDER BY Deal, ordering_seq
	END
	ELSE
	BEGIN
		SELECT [Deal], [tag_id] [Tag Id],
			hr1 [Hr1], hr2 [Hr2], hr3 [Hr3], hr4 [Hr4], hr5 [Hr5], 
			hr6 [Hr6], hr7 [Hr7], hr8 [Hr8], hr9 [Hr9], hr10 [Hr10], 
			hr11 [Hr11], hr12 [Hr12], hr13 [Hr13], hr14 [Hr14], hr15 [Hr15], 
			hr16 [Hr16], hr17 [Hr17], hr18 [Hr18], hr19 [Hr19], hr20 [Hr20], 
			hr21 [Hr21], hr22 [Hr22], hr23 [Hr23], hr24 [Hr24], hr25 [Hr25]  
		FROM #temp_position_etag ORDER BY Deal, ordering_seq
	END
	
END


ELSE IF @flag = 'a'
BEGIN	
	SET @sql = '
				SELECT e.etag_id,
					   e.oati_tag_id,
					   e.control_areas,
					   e.transmission_providers,
					   e.pse,
					   e.point_of_receipt,
					   e.point_of_delivery,
					   e.scheduling_entity '
	
	IF (@etag_detail_id IS NOT NULL)
	BEGIN
		SET @sql = @sql + ',ed.as_of_date			[As of Date] '
		SET @sql = @sql + ',ed.deal_id				[Deal ID] '
	END
	SET @sql = @sql + 'FROM etag e'
	IF (@etag_detail_id IS NOT NULL)
	BEGIN
		SET @sql = @sql + ' LEFT JOIN etag_detail ed ON ed.etag_id = e.etag_id'
	END
	SET @sql = @sql + ' WHERE 1 = 1'
	IF (@etag_detail_id IS NOT NULL)
	BEGIN
		SET @sql = @sql + ' AND ed.etag_detail_id = ' + CAST(@etag_detail_id AS VARCHAR)
	END
	ELSE IF (@etag_id IS NOT NULL)
	BEGIN	
		SET @sql = @sql + ' AND e.etag_id = ''' + CAST(@etag_id AS VARCHAR) + ''''
	END

	exec spa_print @sql
	EXEC (@sql)
END

ELSE IF @flag = 'u'
BEGIN	
	BEGIN TRY
		UPDATE etag
		SET
			control_areas = @control_areas,
			transmission_providers = @transmission_providers, 
			pse = @pse,
			point_of_receipt = @receipt_point,
			point_of_delivery = @delivery_point,
			scheduling_entity = @scheduling_entity		
		WHERE
			etag_id = @etag_id
		EXEC spa_ErrorHandler 0,
		     'etag',
		     'spa_etag',
		     'Success',
		     'Successfully updated data.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'etag',
		     'spa_etag',
		     'Error',
		     @desc,
		     ''
	END CATCH
END

ELSE IF @flag = 'm'
BEGIN	
	BEGIN TRY
		UPDATE etag_header
		SET source_deal_header_id = @deal_id
		WHERE etag_id = @etag_id

		
		UPDATE eh
			SET eh.match_status = CASE WHEN tag.etag_value IS NULL THEN NULL 
									   WHEN deal.total_volume = tag.etag_value THEN 27201
									   ELSE 27203
								  END   
		FROM 
			etag_header eh
			OUTER APPLY(SELECT SUM(total_volume) total_volume FROM source_deal_detail  WHERE source_deal_header_id=eh.source_deal_header_id) deal
			OUTER APPLY(SELECT SUM(etag_value) etag_value FROM etag_detail e inner join etag_header e1 ON e.etag_id = e1.etag_id WHERE e1.source_deal_header_id=eh.source_deal_header_id) tag
		WHERE
			etag_id = @etag_id
		

		UPDATE eh1
			SET eh1.match_status = eh.match_status  
		FROM 
			etag_header eh
			INNER JOIN etag_header eh1 ON eh.source_deal_header_id = eh1.source_deal_header_id
		WHERE
			eh.etag_id = @etag_id
		
		EXEC spa_ErrorHandler 0,
		     'etag',
		     'spa_etag',
		     'Success',
		     'Tag match sucessfully.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to match tag ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'etag',
		     'spa_etag',
		     'Error',
		     @desc,
		     ''
	END CATCH
END

ELSE IF @flag = 'n'
BEGIN	
	BEGIN TRY

		UPDATE eh1
			SET eh1.match_status = 27203  
		FROM 
			etag_header eh
			INNER JOIN etag_header eh1 ON eh.source_deal_header_id = eh1.source_deal_header_id
		WHERE
			eh.etag_id = @etag_id


		UPDATE etag_header
		SET source_deal_header_id = NULL,
			match_status = NULL
		WHERE etag_id = @etag_id
		
		EXEC spa_ErrorHandler 0,
		     'etag',
		     'spa_etag',
		     'Success',
		     'Tag unmatch sucessfully.',
		     ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to unmatch tag ( Errr Description:' + ERROR_MESSAGE() + ').'

		EXEC spa_ErrorHandler @@ERROR,
		     'etag',
		     'spa_etag',
		     'Error',
		     @desc,
		     ''
	END CATCH
END

ELSE IF @flag = 'x'
BEGIN	
	SELECT 
		sdv.code [control_areas],
		e.control_area_type [control_area_type],
		e.generator [generator_name],
		sc.counterparty_name [owner],
		sdv1.code [transmission_providers],
		sdv2.code [pse],
		sml.Location_Name [point_of_receipt],
		sml1.Location_Name [point_of_delivery]			

	FROM
		etag_header eh
		INNER JOIN etag e ON eh.etag_id = e.etag_id
		LEFT JOIN static_data_value sdv On sdv.value_id = e.control_areas
		LEFT JOIN static_data_value sdv1 On sdv1.value_id = e.transmission_providers
		LEFT JOIN static_data_value sdv2 On sdv2.value_id = e.pse
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = e.point_of_receipt
		LEFT JOIN source_minor_location sml1 ON sml1.source_minor_location_id = e.point_of_delivery
		LEFT JOIN rec_generator rg ON generator_id = e.generator
		LEFT JOIN source_counterparty sc On sc.source_counterparty_id=e.counterparty_id
	WHERE
		eh.etag_id= @etag_id		
	
END


/*
ELSE IF @flag = 'm'
BEGIN
	IF OBJECT_ID('tempdb..#hourly_position_deal') IS NOT NULL DROP TABLE #hourly_position_deal
	IF OBJECT_ID('tempdb..#etag') IS NOT NULL DROP TABLE #etag
	SET @sql = '		
			SELECT ''Trade''										[Type],
				CAST(source_deal_header_id AS NVARCHAR(MAX))		[ID],
				''''												[Match Status],
				SUM(hr1)											[1],
				SUM(hr2)											[2],
				SUM(hr3)											[3],
				SUM(hr4)											[4],
				SUM(hr5)											[5],
				SUM(hr6)											[6],
				SUM(hr7)											[7],
				SUM(hr8)											[8],
				SUM(hr9)											[9],
				SUM(hr10)											[10],
				SUM(hr11)											[11],
				SUM(hr12)											[12],
				SUM(hr13)											[13],
				SUM(hr14)											[14],
				SUM(hr15)											[15],
				SUM(hr16)											[16],
				SUM(hr17)											[17],
				SUM(hr18)											[18],
				SUM(hr19)											[19],
				SUM(hr20)											[20],
				SUM(hr21)											[21],
				SUM(hr22)											[22],
				SUM(hr23)											[23],
				SUM(hr24)											[24]
		INTO #hourly_position_deal
		FROM
			report_hourly_position_deal rhpd			
		WHERE  
			rhpd.term_start = ''' + CAST(@as_of_date AS NVARCHAR(MAX)) + ''' and rhpd.source_deal_header_id = ' + CAST(@deal_id AS NVARCHAR(MAX)) + '
		GROUP BY
			rhpd.source_deal_header_id, rhpd.term_start;
					
		SELECT ''Tag''					[Type],
			   e.oati_id				[ID],
			   sdv_match_status.code	[Match Status],
			   ed.Hr1					[1],
			   ed.Hr2					[2],
			   ed.Hr3					[3],
			   ed.Hr4					[4],
			   ed.Hr5					[5],
			   ed.Hr6					[6],
			   ed.Hr7					[7],
			   ed.Hr8					[8],
			   ed.Hr9					[9],
			   ed.Hr10					[10],
			   ed.Hr11					[11],
			   ed.Hr12					[12],
			   ed.Hr13					[13],
			   ed.Hr14					[14],
			   ed.Hr15					[15],
			   ed.Hr16					[16],
			   ed.Hr17					[17],
			   ed.Hr18					[18],
			   ed.Hr19					[19],
			   ed.Hr20					[20],
			   ed.Hr21					[21],
			   ed.Hr22					[22],
			   ed.Hr23					[23],
			   ed.Hr24					[24]
		INTO #etag
		FROM   etag e
		RIGHT JOIN etag_detail ed ON  ed.etag_id = e.etag_id
		LEFT JOIN static_data_value sdv_match_status ON  sdv_match_status.value_id = ed.match_status
		LEFT JOIN static_data_value sdv_tag_status ON  sdv_tag_status.value_id = ed.tag_status
		WHERE 
			e.oati_id = ''' + CAST(@etag_id AS NVARCHAR(MAX)) + '''
			AND ed.as_of_date = ''' + CAST(@as_of_date AS NVARCHAR(MAX)) + ''';
		SELECT * FROM #hourly_position_deal temp_hourly_position_deal 
		UNION ALL 
		SELECT * FROM #etag temp_etag
		UNION ALL
		SELECT
				''<b>Total</b>'', '''','''',
				CASE WHEN temp_hourly_position_deal.[1] = temp_etag.[1] THEN temp_etag.[1] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[2] = temp_etag.[2] THEN temp_etag.[2] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[3] = temp_etag.[3] THEN temp_etag.[3] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[4] = temp_etag.[4] THEN temp_etag.[4] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[5] = temp_etag.[5] THEN temp_etag.[5] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[6] = temp_etag.[6] THEN temp_etag.[6] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[7] = temp_etag.[7] THEN temp_etag.[7] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[8] = temp_etag.[8] THEN temp_etag.[8] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[9] = temp_etag.[9] THEN temp_etag.[9] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[10] = temp_etag.[10] THEN temp_etag.[10] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[11] = temp_etag.[11] THEN temp_etag.[11] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[12] = temp_etag.[12] THEN temp_etag.[12] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[13] = temp_etag.[13] THEN temp_etag.[13] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[14] = temp_etag.[14] THEN temp_etag.[14] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[15] = temp_etag.[15] THEN temp_etag.[15] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[16] = temp_etag.[16] THEN temp_etag.[16] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[17] = temp_etag.[17] THEN temp_etag.[17] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[18] = temp_etag.[18] THEN temp_etag.[18] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[19] = temp_etag.[19] THEN temp_etag.[19] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[20] = temp_etag.[20] THEN temp_etag.[20] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[21] = temp_etag.[21] THEN temp_etag.[21] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[22] = temp_etag.[22] THEN temp_etag.[22] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[23] = temp_etag.[23] THEN temp_etag.[23] ELSE 0 END,
				CASE WHEN temp_hourly_position_deal.[24] = temp_etag.[24] THEN temp_etag.[24] ELSE 0 END
		FROM
			#hourly_position_deal temp_hourly_position_deal 
		CROSS APPLY 
			#etag temp_etag '
	exec spa_print @sql		
	EXEC (@sql)		
END
*/
--ELSE IF @flag = 'g'
--BEGIN
--	BEGIN TRY
--		UPDATE etag_detail
--			SET
--				match_status = 27201,
--				deal_id = @deal_id
--			WHERE
--				etag_detail_id = @etag_detail_id
--			EXEC spa_ErrorHandler 0,
--				 'etag',
--				 'spa_etag',
--				 'Success',
--				 'Successfully matched deal.',
--				 ''
--	END TRY
--	BEGIN CATCH
--		IF @@TRANCOUNT > 0
--		   ROLLBACK
	 
--		SET @desc = 'Fail to match deal ( Errr Description:' + ERROR_MESSAGE() + ').'

--		EXEC spa_ErrorHandler @@ERROR,
--		     'etag',
--		     'spa_etag',
--		     'Error',
--		     @desc,
--		     ''
--	END CATCH	
--END
--ELSE IF @flag = 'h'
--BEGIN
--	BEGIN TRY
--		UPDATE etag_detail
--			SET
--				match_status = 27202,
--				deal_id = NULL
--			WHERE
--				etag_detail_id = @etag_detail_id
--			EXEC spa_ErrorHandler 0,
--				 'etag',
--				 'spa_etag',
--				 'Success',
--				 'Successfully un-matched deal.',
--				 ''
--	END TRY
--	BEGIN CATCH
--		IF @@TRANCOUNT > 0
--		   ROLLBACK
	 
--		SET @desc = 'Fail to un-match deal ( Errr Description:' + ERROR_MESSAGE() + ').'

--		EXEC spa_ErrorHandler @@ERROR,
--		     'etag',
--		     'spa_etag',
--		     'Error',
--		     @desc,
--		     ''
--	END CATCH	
--END
