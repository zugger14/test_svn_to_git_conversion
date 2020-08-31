
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_position_report_sch_n_delivery]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_position_report_sch_n_delivery]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_position_report_sch_n_delivery]
    @sub VARCHAR(500) = NULL,
    @str VARCHAR(500) = NULL,
    @book VARCHAR(500) = NULL,
    @commodity INT = NULL,
    @delivery_path VARCHAR(500)=NULL,
    @frequency VARCHAR(1) = NULL,	--NOT USED
    @term_start DATETIME = NULL,
    @term_end DATETIME = NULL,
	@counterparty VARCHAR(500) = NULL,
    @location_optional INT = NULL,
    @daily_rolling CHAR(1) = NULL,		--d:daily, m:monthly, r:daily rolling
    @round	TINYINT = 0,
    @drill_Counterparty VARCHAR(250) = NULL,
    @drill_Location VARCHAR(250) = NULL,
    @drill_Meter VARCHAR(250) = NULL,
    @drill_LocationType VARCHAR(250) = NULL,
    @b_s_flag VARCHAR(10) = NULL,
    @drill_vol FLOAT = NULL,
    @drill_term DATETIME = NULL,
	@group_by	varchar(20) = NULL,

	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL,
	
	@location_type INT = NULL,
	@major_location VARCHAR(250) = NULL,
	@minor_location VARCHAR(250) = NULL,
	@pipeline_counterparty VARCHAR(250) = NULL,
	@book_deal_type_map_id  VARCHAR(500) = NULL
	

AS 
/*

DECLARE 
	@sub VARCHAR(500) = '30',
    @str VARCHAR(500) = '130',--'351',
    @book VARCHAR(500) = '134',
    @commodity INT = 50,
    @delivery_path VARCHAR(500)=NULL,
    @frequency VARCHAR(1) = NULL,	--'d',
    @term_start DATETIME = '2014-02-01',
    @term_end DATETIME = '2014-02-28',
	@counterparty VARCHAR(500) = NULL,
    @location_optional INT = NULL,
    @daily_rolling CHAR(1) = 'd',
    @round	TINYINT = 0,
    @drill_Counterparty VARCHAR(250) = NULL,
    @drill_Location VARCHAR(250) = 42922,	--'Plant >> Luna Plant',
    @drill_Meter VARCHAR(250) = NULL,
    @drill_LocationType VARCHAR(250) = NULL,	--'Plant',
    @b_s_flag VARCHAR(10) = 'net',	--'net',
    @drill_vol FLOAT = NULL,
    @drill_term DATETIME = '2014-02-01',	--'2012-07-03',
	@group_by	VARCHAR(20) = 'deal',

	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL,
	
	@location_type INT = NULL,
	@major_location VARCHAR(250) = NULL,
	@minor_location VARCHAR(250) = NULL,
	@pipeline_counterparty VARCHAR(250) = NULL,
	@book_deal_type_map_id  VARCHAR(500) = NULL




--SELECT * FROM #tmp_sdd WHERE source_deal_header_id IN (40350,42842)
--SELECT * FROM #schedule_deals WHERE source_deal_header_id=40350

--SELECT * FROM  #deal_filter_for_deal_drill WHERE deal_header_id IN (40350,42842)



IF OBJECT_ID(N'tempdb..#tmp_deals', N'U') IS NOT NULL
	DROP TABLE #tmp_deals

IF OBJECT_ID(N'tempdb..#tmp_trans_deal', N'U') IS NOT NULL
	DROP TABLE #tmp_trans_deal

IF OBJECT_ID(N'tempdb..#tmp_deal_final', N'U') IS NOT NULL
	DROP TABLE #tmp_deal_final
	
IF OBJECT_ID(N'tempdb..#tmp_sdd', N'U') IS NOT NULL
	DROP TABLE #tmp_sdd
	
IF OBJECT_ID(N'tempdb..#tmp_delivery_path', N'U') IS NOT NULL
	DROP TABLE #tmp_delivery_path

IF OBJECT_ID(N'tempdb..#imbalance_deals', N'U') IS NOT NULL
	DROP TABLE #imbalance_deals


IF OBJECT_ID(N'tempdb..#deal_filter_for_deal_drill', N'U') IS NOT NULL
	DROP TABLE #deal_filter_for_deal_drill

DROP TABLE #sch_group_deals
DROP TABLE #exclude_sch_deals
DROP TABLE  #schedule_deals
DROP TABLE #transport_deals
DROP TABLE #schedule_template
----*/



	
SET NOCOUNT ON
SET @frequency='d'

DECLARE @internal_deal_subtype_value_id VARCHAR(30)
SET @internal_deal_subtype_value_id='Transportation'

DECLARE @Dcounterparty_value_id  VARCHAR(400),  @Rcounterparty_value_id  VARCHAR(400)
SELECT @Rcounterparty_value_id=value_id  FROM static_data_value WHERE code='Receiving Counterparty'
SELECT @Dcounterparty_value_id=value_id  FROM static_data_value WHERE code='Shipping Counterparty'

DECLARE @rnd_var AS VARCHAR(2),@drill_deal_id INT

SET @rnd_var = CAST(ISNULL(@round, 0) AS VARCHAR(2))

CREATE TABLE #tmp_trans_deal (
 source_deal_header_id INT,
 leg INT,
 Counterparty INT
)

CREATE table #imbalance_deals(counterparty_id INT,contract_id int ,location_id INT,meter_id INT,template_id INT,off_template_id INT,closeout_template_id INT)

 
INSERT into #imbalance_deals (contract_id  ,counterparty_id ,location_id ,meter_id,template_id ,off_template_id,closeout_template_id )
SELECT clm1_value,clm2_value,clm3_value ,clm4_value,clm5_value,clm6_value,clm7_value FROM generic_mapping_values g 
INNER JOIN generic_mapping_header h ON g.mapping_table_id=h.mapping_table_id
 AND h.mapping_name= 'Imbalance Deal' --AND clm1_value='y'


SELECT CAST(clm3_value AS INT) template_id INTO #schedule_template FROM generic_mapping_values g 
INNER JOIN generic_mapping_header h ON g.mapping_table_id=h.mapping_table_id
 AND h.mapping_name= 'Imbalance Report' --AND clm1_value='y'
 AND clm1_value IN ('1','5')


--SELECT * FROM #tmp_trans_deal
--SELECT * FROM #tmp_trans_deal

DECLARE @sql_counterparty VARCHAR(MAX)
SET @sql_counterparty = 
	'SELECT sdh.source_deal_header_id,sdd.Leg,MAX(CASE WHEN ISNULL([udf_value],''NULL'')=''NULL'' THEN NULL ELSE [udf_value] END) Counterparty
	FROM source_deal_header sdh 
	INNER JOIN [default_deal_post_values] d ON sdh.[template_id] = d.[template_id]
	INNER JOIN internal_deal_type_subtype_types i ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
			AND i.internal_deal_type_subtype_type=''' + @internal_deal_subtype_value_id + '''
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id  
	inner JOIN [dbo].[user_defined_deal_fields] uddf ON sdh.source_deal_header_id=uddf.source_deal_header_id 
	inner JOIN [dbo].[user_defined_deal_fields_template] uddft ON uddf.udf_template_id=uddft.udf_template_id 
		AND sdd.Leg=CASE uddft.field_name WHEN ' + @Dcounterparty_value_id + ' then  1 WHEN ' + @Rcounterparty_value_id + ' then  2 end  
	 WHERE 1=1 '
		+ CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND (sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id2 IS NOT NULL THEN ' AND (sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id3 IS NOT NULL THEN ' AND (sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id4 IS NOT NULL THEN ' AND (sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR)+ ')) ' ELSE '' END+ '
	GROUP BY  sdh.source_deal_header_id,sdd.Leg'
	
EXEC spa_print @sql_counterparty

INSERT INTO #tmp_trans_deal (
	source_deal_header_id,
	leg ,
	Counterparty 
)
EXEC(@sql_counterparty)

CREATE TABLE #tmp_sdd
(
	source_deal_header_id       INT,
	leg                         TINYINT,
	physical_financial_flag     VARCHAR(1) COLLATE DATABASE_DEFAULT,
	meter_id                    INT,
	term_start                  DATETIME,
	curve_id                    INT,
	buy_sell_flag               VARCHAR(1) COLLATE DATABASE_DEFAULT,
	location_id                 INT,
	deal_sub_type				VARCHAR(250) COLLATE DATABASE_DEFAULT,
	deal_volume                 NUMERIC(38, 20),
	actual_volume               NUMERIC(38, 20),
	resulting_volume            NUMERIC(38, 20),
	deal_volume_uom				VARCHAR(100) COLLATE DATABASE_DEFAULT,
	source_deal_detail_id       INT,
	location                    VARCHAR(250) COLLATE DATABASE_DEFAULT,
	location_type               VARCHAR(250) COLLATE DATABASE_DEFAULT,
	counterparty_name           VARCHAR(250) COLLATE DATABASE_DEFAULT,
	contract_name				VARCHAR(250) COLLATE DATABASE_DEFAULT,
	recorderid                  VARCHAR(250) COLLATE DATABASE_DEFAULT,
	counterparty_id             INT,
	deal_id                     VARCHAR(150) COLLATE DATABASE_DEFAULT,
	booked                      VARCHAR(1) COLLATE DATABASE_DEFAULT,
	is_pool                     VARCHAR(1) COLLATE DATABASE_DEFAULT,
	[counter_f_sub]             INT,
	pipeline_counterparty_name  VARCHAR(250) COLLATE DATABASE_DEFAULT,
	pipeline_counterparty_id    INT,
	udf_source_deal_header_id int
)

DECLARE @sql VARCHAR(MAX),
    @sqlwhere VARCHAR(MAX),
    @sqlGroupBy VARCHAR(MAX),
    @sqlFlds VARCHAR(MAX),
    @sqlFrom VARCHAR(MAX)
DECLARE @from_location_id INT,
    @to_location_id INT,
    @meter_from INT,
    @meter_to INT,
    @sqlwhere1 VARCHAR(MAX)
DECLARE @sqlFields1 VARCHAR(MAX)
DECLARE @spa VARCHAR(5000)
--DECLARE @internal_deal_subtype_value_id varchar(30)
--SET @internal_deal_subtype_value_id='Transportation'

SET @spa = '''EXEC spa_position_report_sch_n_delivery '
    + CASE WHEN @sub IS NULL THEN 'NULL' ELSE '''''' + @sub + '''''' END + ',' 
    + CASE WHEN @str IS NULL THEN 'NULL' ELSE '''''' + @str + '''''' END + ',' 
    + CASE WHEN @book IS NULL THEN 'NULL' ELSE '''''' + @book + '''''' END + ','
    + CASE WHEN @commodity IS NULL THEN 'NULL' ELSE CAST(@commodity AS VARCHAR) END + ',' 
    + CASE WHEN @delivery_path IS NULL THEN 'NULL' ELSE '''''' + @delivery_path + '''''' END + ',' 
    + CASE WHEN @frequency IS NULL THEN 'NULL' ELSE '''''' + @frequency + '''''' END + ','
    + CASE WHEN @term_start IS NULL THEN 'NULL' ELSE '''''' + CAST(@term_start AS VARCHAR) + '''''' END + ',' 
    + CASE WHEN @term_end IS NULL THEN 'NULL' ELSE '''''' + CAST(@term_end AS VARCHAR) + '''''' END + ',' 
    + CASE WHEN @counterparty IS NULL THEN 'NULL' ELSE '''''' + @counterparty + '''''' END + ','
    + CASE WHEN @location_optional IS NULL THEN 'NULL' ELSE CAST(@location_optional AS VARCHAR) END + ',' 
    + CASE WHEN @daily_rolling IS NULL THEN 'NULL' ELSE '''''' + @daily_rolling + '''''' END + ',' 
    + CASE WHEN @round IS NULL THEN 'NULL' ELSE CAST(@round AS VARCHAR(2)) END + ''

EXEC spa_print @spa

CREATE TABLE #deal_filter_for_deal_drill(deal_header_id INT,sch_deal VARCHAR(1) COLLATE DATABASE_DEFAULT)

IF @group_by='Deal' AND @drill_Location IS NOT NULL
BEGIN 
	
	SET @drill_deal_id=@drill_Location
	SET @drill_Location=NULL

END 
	
SET @sqlwhere = 'INSERT INTO #deal_filter_for_deal_drill(deal_header_id,sch_deal)
	SELECT sdh.source_deal_header_id ,''n''	FROM source_deal_header sdh 
	LEFT JOIN #imbalance_deals ids ON ids.template_id=sdh.template_id
	WHERE ids.template_id IS NULL '  
	+ CASE WHEN  @source_system_book_id1 IS NOT NULL THEN ' AND sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ') ' ELSE '' END
	+ CASE WHEN  @source_system_book_id2 IS NOT NULL THEN ' AND sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR)+ ') ' ELSE '' END
	+ CASE WHEN  @source_system_book_id3 IS NOT NULL THEN ' AND sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR)+ ') ' ELSE '' END
	+ CASE WHEN  @source_system_book_id4 IS NOT NULL THEN ' AND sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR)+ ') ' ELSE '' END
	+ CASE WHEN  @drill_deal_id IS NOT NULL THEN ' 
			AND sdh.source_deal_header_id= ' + CAST(@drill_deal_id AS VARCHAR)+ '
		UNION --FROM deal
		SELECT f.source_deal_header_id udf_value,''y'' FROM  user_defined_deal_fields f INNER JOIN  source_deal_header sdh ON sdh.source_deal_header_id=f.source_deal_header_id
		INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_label=''From Deal''
		AND ISNUMERIC(f.udf_value)=1 AND CAST(f.udf_value as float)='+CAST(@drill_deal_id AS VARCHAR)+'  
		LEFT JOIN #imbalance_deals ids ON ids.template_id=sdh.template_id
			WHERE ids.template_id IS NULL 
		UNION -- to deal
		SELECT f.source_deal_header_id udf_value,''x'' FROM  user_defined_deal_fields f INNER JOIN  source_deal_header sdh ON sdh.source_deal_header_id=f.source_deal_header_id
		INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_label=''To Deal''
		AND ISNUMERIC(f.udf_value)=1 AND CAST(f.udf_value as float)='+CAST(@drill_deal_id AS VARCHAR)+'  
		LEFT JOIN #imbalance_deals ids ON ids.template_id=sdh.template_id
			WHERE ids.template_id IS NULL  

			'  
	ELSE '' END
	
EXEC spa_print @sqlwhere	
EXEC(@sqlwhere)	
	
	
CREATE TABLE #tmp_deals ( term_start DATETIME )
CREATE TABLE #tmp_delivery_path
(
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[path_id] INT NULL,
	[meter_id] INT NULL,
	[location_id] INT NULL,
	[pipeline_counterparty] INT NULL									
)                
DECLARE @sql_delivery_path VARCHAR(1000)	

SET @sqlwhere = ' WHERE sdd.physical_financial_flag=''p'' AND isnull(sdd.booked,''n'')<>''y'''

IF @sub IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' str.parent_entity_id in (' + @sub + ')'

IF @str IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' str.entity_id in (' + @str+ ')'

IF @book IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' book.entity_id in (' + @book+ ')'
        
IF @book_deal_type_map_id IS NOT NULL 
	SET @sqlwhere = @sqlwhere + ' AND ' + ' sbmp.book_deal_type_map_id in (' + @book_deal_type_map_id + ')'

IF @commodity IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' sc.source_commodity_id=' + CAST(@commodity AS VARCHAR)

INSERT INTO #tmp_delivery_path
SELECT MAX(path_id),MeterID,LocationID, MAX(counterparty) FROM
	(SELECT path_id,
	CASE n
		WHEN 1 THEN meter_from
		WHEN 2 THEN meter_to
	END AS MeterID,
	CASE n
		WHEN 1 THEN from_location
		WHEN 2 THEN to_location
	END AS LocationID,
	 counterparty
	FROM delivery_path AS S 
	CROSS JOIN
	(
		SELECT 1 UNION
		SELECT 2 
	) AS Nums(n)
	)a
WHERE  counterparty IS NOT NULL	
GROUP BY MeterID,LocationID


SET @sqlwhere1 = ''

--IF @frequency IS NOT NULL 
--    SET @sqlwhere = @sqlwhere + ' AND ' + ' sdh.term_frequency='''
--        + @frequency + ''''

IF @term_start IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' r.term_start>='''
        + CAST(@term_start AS VARCHAR) + ''''

IF @term_end IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' r.term_start<='''
        + CAST(@term_end AS VARCHAR) + ''''

IF @counterparty IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' sdh.counterparty_id IN ('
        + @counterparty + ')'

IF @location_optional IS NOT NULL 
    SET @sqlwhere = @sqlwhere + ' AND ' + ' sml.source_minor_location_id='
        + CAST(@location_optional AS VARCHAR)

DELETE FROM #tmp_delivery_path WHERE ID NOT IN
(
	SELECT MAX(ID)
	FROM #tmp_delivery_path
	GROUP BY [path_id],[meter_id],location_id
)
--SELECT * FROM #tmp_delivery_path

--FIX: hardcoding Transportation deal subtype for demo purpose.


SELECT DISTINCT sdh.source_deal_header_id,sdh.entire_term_start term_start INTO #schedule_deals
FROM   source_deal_header sdh 
INNER JOIN #schedule_template st ON sdh.template_id=st.template_id
INNER JOIN #deal_filter_for_deal_drill df ON df.deal_header_id= sdh.source_deal_header_id   

SELECT sch_id.udf_value sch_id,MIN(sd.source_deal_header_id) from_deal_id,MAX(sd.source_deal_header_id) to_deal_id,sd.term_start INTO #sch_group_deals FROM (		
			SELECT DISTINCT uddf.udf_value
			FROM   user_defined_deal_fields uddf
			INNER JOIN user_defined_deal_fields_template uddft
				ON  uddft.udf_template_id = uddf.udf_template_id AND uddft.Field_label='Scheduled ID'
			-- AND uddf.source_deal_header_id =@source_deal_header_id  
			  AND ISNUMERIC(uddf.udf_value)=1
		  
) sch_id
INNER JOIN user_defined_deal_fields uddf_d ON ISNUMERIC(uddf_d.udf_value)=1 AND uddf_d.udf_value=sch_id.udf_value
INNER JOIN #schedule_deals sd ON sd.source_deal_header_id=uddf_d.source_deal_header_id
CROSS APPLY(
		SELECT CAST(f.udf_value as float) grp_path_id FROM  user_defined_deal_fields f
			INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_name=-5606
				AND f.source_deal_header_id=uddf_d.source_deal_header_id  AND ISNUMERIC(f.udf_value)=1
		) grp_path
GROUP BY sch_id.udf_value,sd.term_start




CREATE TABLE #exclude_sch_deals (source_deal_header_id INT,term_start datetime)

DELETE d OUTPUT DELETED.source_deal_header_id,DELETED.term_start into #exclude_sch_deals
FROM #sch_group_deals sgd INNER join #schedule_deals d ON d.source_deal_header_id>from_deal_id AND d.source_deal_header_id<to_deal_id
	 AND sgd.term_start=d.term_start
	 
DELETE d FROM #deal_filter_for_deal_drill	d INNER JOIN  #exclude_sch_deals e ON d.deal_header_id=e.source_deal_header_id
	 
	 
SET @sqlFrom = '
	FROM source_deal_header sdh INNER JOIN #deal_filter_for_deal_drill df ON sdh.source_deal_header_id=df.deal_header_id
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
	OUTER APPLY ( 
		SELECT d.term_start , isnull(d.hr1,0)+isnull(d.hr2,0)+isnull(d.hr3,0)+isnull(d.hr4,0)+isnull(d.hr5,0)+isnull(d.hr6,0)+isnull(d.hr7,0)+isnull(d.hr8,0)
			+isnull(d.hr9,0)+isnull(d.hr10,0)+isnull(d.hr11,0)+isnull(d.hr12,0)+isnull(d.hr13,0)+isnull(d.hr14,0)+isnull(d.hr15,0)+isnull(d.hr16,0)
			+isnull(d.hr17,0)+isnull(d.hr18,0)+isnull(d.hr19,0)+isnull(d.hr20,0)+isnull(d.hr21,0)+isnull(d.hr22,0)+isnull(d.hr23,0)+isnull(d.hr24,0) as deal_volume
		FROM report_hourly_position_deal d  '
		+
			CASE WHEN @group_by ='Deal'  THEN 
				' LEFT JOIN #schedule_deals sd ON sd.source_deal_header_id=d.source_deal_header_id '	
			ELSE '' END  
			+'
			WHERE  d.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND d.source_deal_detail_id=sdd.source_deal_detail_id '
			+ CASE WHEN @group_by ='Deal' THEN ' AND sd.source_deal_header_id IS NULL' ELSE '' END +
			'

		UNION all
		SELECT d.term_start , isnull(d.hr1,0)+isnull(d.hr2,0)+isnull(d.hr3,0)+isnull(d.hr4,0)+isnull(d.hr5,0)+isnull(d.hr6,0)+isnull(d.hr7,0)+isnull(d.hr8,0)
			+isnull(d.hr9,0)+isnull(d.hr10,0)+isnull(d.hr11,0)+isnull(d.hr12,0)+isnull(d.hr13,0)+isnull(d.hr14,0)+isnull(d.hr15,0)+isnull(d.hr16,0)
			+isnull(d.hr17,0)+isnull(d.hr18,0)+isnull(d.hr19,0)+isnull(d.hr20,0)+isnull(d.hr21,0)+isnull(d.hr22,0)+isnull(d.hr23,0)+isnull(d.hr24,0) as deal_volume
		FROM report_hourly_position_profile d  '
		+
			CASE WHEN @group_by ='Deal'  THEN 
				' LEFT JOIN #schedule_deals sd ON sd.source_deal_header_id=d.source_deal_header_id '	
			ELSE '' END  
			+'
			WHERE  d.term_start BETWEEN sdd.term_start AND sdd.term_end 
				AND d.source_deal_detail_id=sdd.source_deal_detail_id '
			+ CASE WHEN @group_by ='Deal'  THEN ' AND sd.source_deal_header_id IS NULL' ELSE '' END 	
			+
			CASE WHEN @group_by ='Deal'  THEN 
				' 
				UNION all
					SELECT sdd.term_start ,case when leg=1 then -1 else 1 end * sdd.deal_volume	FROM #schedule_deals sd WHERE sd.source_deal_header_id=sdd.source_deal_header_id '
			ELSE '' END  +'				
	) r
	INNER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id
	INNER JOIN source_commodity sc ON spcd.commodity_id=sc.source_commodity_id
	inner JOIN source_system_book_map sbmp ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
	sdh.source_system_book_id2 = sbmp.source_system_book_id2 AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 AND
	sdh.source_system_book_id4 = sbmp.source_system_book_id4
	INNER JOIN portfolio_hierarchy book (nolock) ON sbmp.fas_book_id = book.entity_id
	INNER JOIN Portfolio_hierarchy str (nolock) ON book.parent_entity_id = str.entity_id 
	INNER JOIN fas_subsidiaries f_sub ON str.parent_entity_id = f_sub.fas_subsidiary_id	
	LEFT JOIN source_minor_location sml ON sdd.location_id=sml.source_minor_location_id
	' + CASE WHEN @group_by ='PipelineCounterparty' THEN ' INNER JOIN ' ELSE ' LEFT JOIN ' END+ '
	(
	    SELECT pipeline_counterparty, MAX(path_id) path_id, MAX(meter_id) meter_id, MAX(location_id) location_id
	    FROM   #tmp_delivery_path GROUP BY pipeline_counterparty
	) tdp_meter 
	ON tdp_meter.pipeline_counterparty = sdh.counterparty_id 
	LEFT JOIN source_counterparty tdp2 ON tdp_meter.pipeline_counterparty = tdp2.source_counterparty_id
	LEFT JOIN meter_id mi ON mi.meter_id=sdd.meter_id
	LEFT JOIN static_data_value loctype ON loctype.value_id=sml.location_type
	LEFT JOIN source_major_location smjl ON smjl.source_major_location_id=sml.source_major_location_id
	LEFT join source_counterparty scp ON scp.source_counterparty_id=sdh.counterparty_id
	LEFT JOIN source_uom su_deal_vol ON su_deal_vol.source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id'
	+
	CASE WHEN @group_by ='Deal'  THEN 
		' LEFT JOIN #schedule_deals schd ON schd.source_deal_header_id=sdd.source_deal_header_id 
			LEFT JOIN #sch_group_deals sgd_from ON sdd.source_deal_header_id=sgd_from.from_deal_id	AND sdd.term_start=sgd_from.term_start 
			LEFT JOIN #sch_group_deals sgd_to ON sdd.source_deal_header_id=sgd_to.to_deal_id	AND sdd.term_start=sgd_to.term_start
		'	
	ELSE '' END  +'
	 outer apply(
				SELECT f.udf_value FROM  user_defined_deal_fields f
				INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_label=''From Deal''
				AND  f.source_deal_header_id=sdh.source_deal_header_id  AND ISNUMERIC(f.udf_value)=1 AND sdd.leg=1 '+CASE WHEN @drill_deal_id IS not NULL THEN ' AND 2=1' ELSE '' END +'
			--	LEFT JOIN #sch_group_deals ss ON sdh.source_deal_header_id=ss.from_deal_id
			--	WHERE ss.from_deal_id IS NULL or ( ss.to_deal_id <> sdh.source_deal_header_id AND ss.from_deal_id IS not NULL)
			) uddf_from
			
	 outer apply(
				SELECT f.udf_value FROM  user_defined_deal_fields f
				INNER JOIN  user_defined_deal_fields_template uddft ON f.udf_template_id=uddft.udf_template_id  AND uddft.field_label=''To Deal''
				AND  f.source_deal_header_id=sdh.source_deal_header_id  AND ISNUMERIC(f.udf_value)=1 AND sdd.leg=2 '+CASE WHEN @drill_deal_id IS not NULL THEN ' AND 2=1' ELSE '' END +'
			) uddf_to
			
			'
	
EXEC spa_print '*****************************************************************'
SET @sqlwhere = @sqlwhere 
	+ CASE WHEN  @location_type IS NOT NULL THEN ' AND (sml.location_type IN (' + CAST(@location_type AS VARCHAR)+ ')) ' ELSE '' END
	+ CASE WHEN  @major_location IS NOT NULL THEN ' AND (smjl.source_major_location_id IN (' + @major_location + ')) ' ELSE '' END
	+ CASE WHEN  @minor_location IS NOT NULL THEN ' AND (sml.source_minor_location_id IN (' + @minor_location + ')) ' ELSE '' END
	+ CASE WHEN  @pipeline_counterparty IS NOT NULL THEN ' AND (ISNULL(tdp_meter.pipeline_counterparty,tdp_location.pipeline_counterparty) IN (' + @pipeline_counterparty + ')) ' ELSE '' END
	--+ CASE WHEN  @pipeline_counterparty IS NOT NULL THEN ' AND (tdp_meter.pipeline_counterparty IN (' + @pipeline_counterparty + ')) ' ELSE '' END
	+ CASE WHEN  @delivery_path IS NOT NULL THEN ' AND (tdp_meter.path_id IN (' + @delivery_path + ')) ' ELSE '' END
	+CASE WHEN @group_by ='Deal' AND @drill_deal_id IS NULL  THEN 
				'  AND (( schd.source_deal_header_id IS not NULL AND isnull(uddf_to.udf_value,uddf_from.udf_value) IS not NULL  ) OR schd.source_deal_header_id IS  NULL)  
				AND	( sgd_from.from_deal_id IS NULL or (sgd_from.from_deal_id IS not NULL AND	sdd.leg=1) )
				AND	( sgd_to.to_deal_id IS NULL or (sgd_to.to_deal_id IS not NULL AND	sdd.leg=2))'	
			ELSE '' END  
	+CASE WHEN @group_by ='deal' AND @drill_deal_id IS NOT NULL THEN 
		 ' AND (df.sch_deal=''n'' or  (df.sch_deal=''y'' AND sdd.leg=1) or  (df.sch_deal=''x'' AND sdd.leg=2)) '
	ELSE '' END
	
SET @sqlFlds = 
    '
	INSERT INTO #tmp_sdd(
		source_deal_header_id ,leg ,physical_financial_flag ,meter_id  ,term_start ,curve_id ,buy_sell_flag,location_id, deal_volume, actual_volume, resulting_volume, deal_volume_uom
		,source_deal_detail_id,	location ,location_type,counterparty_name, contract_name, recorderid,counterparty_id,deal_id,booked,is_pool,[counter_f_sub],pipeline_counterparty_name,pipeline_counterparty_id
	)
	SELECT '+CASE WHEN @group_by ='Deal' AND @drill_deal_id IS  NULL THEN  'COALESCE(uddf_to.udf_value,uddf_from.udf_value,sdd.source_deal_header_id)'   ELSE ' sdd.source_deal_header_id' END +',
		sdd.Leg,sdd.physical_financial_flag,tdp_meter.meter_id,r.term_start,sdd.curve_id
		,sdd.buy_sell_flag,sdd.location_id,  r.deal_volume deal_volume
		, r.deal_volume actual_volume,  r.deal_volume resulting_volume, su_deal_vol.uom_name
		, sdd.source_deal_detail_id, sml.location_name ,smjl.location_name,scp.counterparty_name, cg.contract_name, mi.recorderid,
		sdh.counterparty_id,sdh.deal_id,sdd.booked ,sml.is_pool,f_sub.counterparty_id as [counter_f_sub],tdp2.counterparty_name,tdp2.source_counterparty_id'
	
EXEC spa_print @sqlFlds
EXEC spa_print @sqlFrom
EXEC spa_print @sqlwhere

EXEC( @sqlFlds+ @sqlFrom+ @sqlwhere)


--SELECT * FROM  #sch_group_deals
DELETE d FROM #tmp_sdd d INNER JOIN #sch_group_deals sgd ON d.source_deal_header_id=sgd.from_deal_id AND d.leg=2 AND sgd.to_deal_id<>sgd.from_deal_id

DELETE d FROM #tmp_sdd d INNER JOIN #sch_group_deals sgd ON d.source_deal_header_id=sgd.to_deal_id AND d.leg=1 AND sgd.to_deal_id<>sgd.from_deal_id



if  @drill_Location IS NULL AND @group_by='Deal' 
	update #tmp_sdd set deal_id=sdh.deal_id  FROM #tmp_sdd d INNER JOIN source_deal_header sdh ON d.source_deal_header_id=sdh.source_deal_header_id

	
SET @sqlFrom=' FROM  #tmp_sdd sdd '

INSERT INTO #tmp_deals (term_start)
	SELECT  DISTINCT CASE WHEN @daily_rolling = 'm' THEN dbo.FNAGetContractMonth(sdd.term_start) ELSE sdd.term_start END
FROM #tmp_sdd sdd


IF @drill_term IS NOT NULL 
BEGIN
	SET @sqlwhere= ' WHERE 1=1 '
	SET @sqlwhere = @sqlwhere + ' AND ' + CASE @daily_rolling 
											WHEN 'r' THEN ' sdd.term_start <= ''' + CAST(@drill_term AS VARCHAR) + ''''
											WHEN 'd' THEN ' sdd.term_start = ''' + CAST(@drill_term AS VARCHAR) + ''''
											WHEN 'm' THEN ' YEAR(sdd.term_start) = YEAR(''' + CAST(@drill_term AS VARCHAR) + ''') AND MONTH(sdd.term_start) = MONTH(''' + CAST(@drill_term AS VARCHAR) + ''')'
										 END    											    			
            
            
	IF @drill_Counterparty IS NOT NULL   
		 SET @sqlwhere = @sqlwhere + ' AND ' + ' sdd.counterparty_name='''
				+ @drill_Counterparty + ''''
	IF @drill_Location IS NOT NULL
			SET @sqlwhere = @sqlwhere + ' AND ' + ' sdd.Location '
				+ CASE WHEN @drill_Location IS NULL THEN ' IS NULL '
					   ELSE '=''' + @drill_Location + ''''
				  END
	IF @drill_Meter IS NOT NULL
			SET @sqlwhere = @sqlwhere + ' AND ' + ' sdd.recorderid '
				+ CASE WHEN @drill_Meter IS NULL THEN ' IS NULL '
					   ELSE '=''' + @drill_Meter + ''''
				  END
	IF @drill_LocationType IS NOT NULL
			SET @sqlwhere = @sqlwhere + ' AND ' + ' sdd.location_type '
				+ CASE WHEN @drill_LocationType IS NULL THEN ' IS NULL '
					   ELSE '=''' + @drill_LocationType + ''''
				  END 
     SET @sqlwhere = @sqlwhere + CASE WHEN @b_s_flag = 'net' THEN ''   ELSE ' AND  sdd.buy_sell_flag ='''    + @b_s_flag + ''''      END 

	SET @sqlFlds =	'SELECT  sdd.counterparty_name [Counterparty], sdd.location Location, ' +
						'sdd.recorderid Meter, sdd.location_type [Location Type]' + 
						', dbo.FNAHyperLinkText(10131010, sdd.source_deal_header_id, sdd.source_deal_header_id) DealID, sdd.deal_id [Ref ID]
						, sdd.contract_name [Contract], dbo.FNADateFormat(sdd.term_start) [Date], dbo.FNARemoveTrailingZero(ROUND(sdd.resulting_volume, ' + @rnd_var + ')) Position, sdd.deal_volume_uom [UOM] '

	SET @sql = @sqlFlds + @sqlFrom + @sqlwhere 
	
	EXEC spa_print 'Drillthrough SQL'
	EXEC spa_print @sqlFlds
	EXEC spa_print @sqlFrom
	EXEC spa_print @sqlwhere 
	
    EXEC ( @sql)
    return
END


IF (@group_by='Counterparty') 
BEGIN
	SET @sqlFlds =	'SELECT sdd.counterparty_name [Counterparty]
					,max(sdd.location) Location 
					,max(sdd.location_type) LocationType'
					+ ', sum(sdd.resulting_volume) vol
					,max(sdd.location_id) location_id
					--,max(sdd.counterparty_id) counterparty_id
					'
					+ ',' +@spa
					+ ''' + '',''+ 
					case when sdd.counterparty_name IS NULL then ''NULL'' else '''''''' + sdd.counterparty_name + '''''''' end 
					+ '','' +
					 ''NULL''
					+ '','' + ''NULL''
					+ '','' +
					case when max(sdd.location_type) IS NULL then ''NULL'' else '''''''' + max(sdd.location_type) + '''''''' end + '','''''' 
					+  case when max(sdd.is_pool)<>''y'' then  max(sdd.buy_sell_flag) else ''net'' end + '''''''' spa'

END
ELSE IF (@group_by='Location') 
BEGIN
	SET @sqlFlds =	'SELECT sdd.location Location ,sdd.location_type LocationType'
					+ ',sum(
					sdd.resulting_volume) vol,max(sdd.location_id) location_id'
					+ ',' +@spa
					+ ''' + '',''+ ''NULL'' 
					+ '','' +
					case when sdd.location IS NULL then ''NULL'' else '''''''' + sdd.location + '''''''' end 
					+ '','' + ''NULL'' 
					+ '','' +
					case when sdd.location_type IS NULL then ''NULL'' else '''''''' + sdd.location_type + '''''''' end + '','''''' +  case when sdd.is_pool<>''y'' then  sdd.buy_sell_flag else ''net'' end + '''''''' spa'


END
ELSE IF (@group_by='Deal') 
BEGIN
	SET @sqlFlds =	'SELECT sdd.source_deal_header_id [Deal ID], sdd.deal_id [Deal Ref ID], max(sdd.location) Location ,max(sdd.location_type) LocationType'
					+ ',sum(sdd.resulting_volume) vol,max(sdd.location_id) location_id'
					+ ',' +@spa
					+ ''' + '',''+ ''NULL'' + '','' +CAST(sdd.source_deal_header_id as varchar) + '','' + ''NULL'' + '','' +
					case when max(sdd.location_type) IS NULL then ''NULL'' else '''''''' + max(sdd.location_type) + '''''''' end + '','''''' +  case when max(sdd.is_pool)<>''y'' then  max(sdd.buy_sell_flag) else ''net'' end + '''''''' spa'


END
ELSE IF (@group_by='PipelineCounterparty') 
BEGIN
	SET @sqlFlds =	'SELECT sdd.pipeline_counterparty_name [Pipeline Counterparty]
					,sdd.counterparty_name [Counterparty]
					,max(sdd.location) Location 
					,max(sdd.location_type) LocationType
					,sum(sdd.resulting_volume) vol
					,max(sdd.location_id) location_id'
					+ ',' +@spa
					+ ''' + '',''+ 
					case when sdd.pipeline_counterparty_name IS NULL then ''NULL'' else '''''''' + sdd.pipeline_counterparty_name + '''''''' end 
					+ '','' +
					''NULL'' 
					+ '','' + ''NULL''+ '','' +
					case when max(sdd.location_type) IS NULL then ''NULL'' else '''''''' + max(sdd.location_type) + '''''''' end 
					+ '','''''' +  case when max(sdd.is_pool)<>''y'' then  max(sdd.buy_sell_flag) else ''net'' end + '''''''' spa'
END
ELSE 
BEGIN
	SET @sqlFlds =	'SELECT max(sdd.counterparty_name) [Counterparty],max(sdd.location) Location ,sdd.recorderid Meter,max(sdd.location_type) LocationType'
					+ ', case when max(sdd.is_pool)<>''y'' then  max(sdd.buy_sell_flag) else ''net'' end [Buy/Sale],sum(sdd.resulting_volume) vol,max(sdd.meter_id) meter_id
					,max(sdd.location_id) location_id'+ ',' +@spa+ ''' + '',''+ 
					case when max(sdd.counterparty_name) IS NULL then ''NULL'' else '''''''' + max(sdd.counterparty_name) + '''''''' end + '','' +
					case when max(sdd.location) IS NULL then ''NULL'' else '''''''' + max(sdd.location) + '''''''' end 
					+ '','' +case when sdd.recorderid IS NULL then ''NULL'' else '''''''' + sdd.recorderid + '''''''' end 
					+ '','' +case when max(sdd.location_type) IS NULL then ''NULL'' else '''''''' + max(sdd.location_type) + '''''''' end + '','''''' 
					+  case when max(sdd.is_pool)<>''y'' then  max(sdd.buy_sell_flag) else ''net'' end + '''''''' spa'
				
END

DECLARE @sql_grp_heads VARCHAR(MAX)
SET @sql_grp_heads = ''

SELECT  @sqlFlds = @sqlFlds + ',SUM(case when '+CASE WHEN @daily_rolling = 'm' THEN 'dbo.FNAGetContractMonth(sdd.term_start)' ELSE 'sdd.term_start' END
        + CASE WHEN @daily_rolling = 'd' THEN '='
               ELSE '<='
          END + '''' + CONVERT(VARCHAR(10), term_start, 120)
        --+ ''' then isnull(sdd.deal_volume,0) else 0 end) ['
        + ''' then  CONVERT(FLOAT, dbo.FNARemoveTrailingZero(ROUND(ISNULL(sdd.resulting_volume, 0),' + @rnd_var + '))) else 0 end) ['
        + CONVERT(VARCHAR(10), term_start, 120) + ']',
		@sql_grp_heads = @sql_grp_heads + ',dbo.FNARemoveTrailingZero(ROUND(SUM([' +  CONVERT(VARCHAR(10), term_start, 120) + ']), ' + @rnd_var + ')) [' +  CONVERT(VARCHAR(10), term_start, 120) + ']'
FROM    #tmp_deals 

IF (@group_by='Counterparty') BEGIN
	SET @sqlGroupBy = ' group by sdd.counterparty_name,
						sdd.counterparty_id
						'
    SET @sqlFields1 = 'SELECT [Counterparty], 
						'

END
ELSE IF (@group_by='Location') BEGIN
	SET @sqlGroupBy = ' group by sdd.location ,sdd.location_type,sdd.counterparty_id,
						case when sdd.is_pool<>''y'' then  sdd.buy_sell_flag else ''net'' end'
    SET @sqlFields1 = 'SELECT Location , LocationType,'


END
ELSE IF (@group_by='Deal') BEGIN
	SET @sqlGroupBy = ' group by sdd.source_deal_header_id,sdd.deal_id '
    SET @sqlFields1 = 'SELECT [Location], [LocationType], [Deal ID], [Deal Ref ID],'


END

ELSE IF (@group_by='PipelineCounterparty') BEGIN
	SET @sqlGroupBy = ' group by sdd.pipeline_counterparty_name, sdd.counterparty_name,sdd.counterparty_id'
    SET @sqlFields1 = 'SELECT [Pipeline Counterparty],'

END

ELSE BEGIN
	SET @sqlGroupBy = ' group by sdd.recorderid '
	SET @sqlFields1 = 'SELECT Meter,'

END

 SET @sqlFields1 =	@sqlFields1 + ' case when Vol < 0 then ''<span><font color=#FF0000>'' + convert(varchar(100), dbo.FNARemoveTrailingZero(ROUND(Vol, ' + @rnd_var + '))) + ''</font></span>'' 
					when Vol = 0 then ''<span><font color=#0000CC>'' + dbo.FNARemoveTrailingZero(ROUND(Vol, ' + @rnd_var + ')) + ''</font></span>'' 
					else ''<span><font color=#000000>'' + dbo.FNARemoveTrailingZero(ROUND(Vol, ' + @rnd_var + ')) + ''</font></span>'' end [TotalPosition] '

DECLARE @func_id VARCHAR(8)

SET @func_id = '10161210'

IF @group_by = 'Deal'
BEGIN
	SET @func_id = '10161220'
END	

SELECT  @sqlFields1 = @sqlFields1	 
			--+ ',[dbo].[FNAHyperLinkText2](' + @func_id + ', dbo.FNARemoveTrailingZero(CONVERT(NUMERIC(30,' + @rnd_var + '), ['
			--+ CONVERT(VARCHAR(10), term_start, 120) + '])), dbo.FNARemoveTrailingZero(ROUND(['+ CONVERT(VARCHAR(10), term_start, 120)  + '], ' + @rnd_var + ')),''"'' + CAST(isnull([Location_id],0) as varchar) +'';'' + '
			--+ CASE WHEN @group_by NOT IN ('Location','Counterparty','PipelineCounterparty','Deal') THEN 'CAST(isnull([Meter_id],0) as varchar)' ELSE  '''0''' END	
			--+ ' + '';'' + '
			--+ CASE WHEN @group_by NOT IN ('Location','Counterparty','PipelineCounterparty','Deal') THEN 'isnull(dbo.FNAURLEncode(meter),'''')' ELSE '''0'''  END					
			--+ ' + '';'' + '''
			--+ CONVERT(VARCHAR(10), term_start, 120) + ''' +'';'' + '
			--+ 'CAST(isnull(counterparty_id,0) as varchar)'+
			--+ ' + '';'' +CAST(source_deal_detail_id as varchar)+'	
			--+ ' + '';'' +CAST(ISNULL(primary_counterparty_id, 0) AS varchar(50))+' 
			--+ ' + '';'' + '''+ @group_by + ''' +' 

			--+ ',''<span style="cursor: pointer;" onclick="parent.fx_open_deal_schedule('' + CAST([Deal ID] as varchar(20)) + '')"><font color="#0000ff">'' + dbo.FNARemoveTrailingZero(CONVERT(NUMERIC(30,' + @rnd_var + '), [' + CONVERT(VARCHAR(10), term_start, 120) + '])) + ''</font></span>'''
			+ case when @group_by = 'Deal' then ',''<span style="cursor: pointer;" onclick="parent.fx_open_deal_schedule('' + CAST([Deal ID] as varchar(20)) + '')"><font color="#0000ff">'' + dbo.FNARemoveTrailingZero(CONVERT(NUMERIC(30,' + @rnd_var + '), [' + CONVERT(VARCHAR(10), term_start, 120) + '])) + ''</font></span>'''
			else ',dbo.FNARemoveTrailingZero(CONVERT(NUMERIC(30,' + @rnd_var + '), [' + CONVERT(VARCHAR(10), term_start, 120) + ']))' end
			--+ '+''"'') + ''   '' +  [dbo].[FNAHyperHTML](spa+'',NULL,'''''
			+ ' + ''   '' +  [dbo].[FNAHyperHTML](spa+'',NULL,'''''
			+ CONVERT(VARCHAR(10), term_start, 120) + ''''','''''+@group_by+''''''',''....'') ['
			+ CONVERT(VARCHAR(10), term_start, 120) + ']'	 
	FROM  #tmp_deals ORDER BY term_start ASC
EXEC spa_print 'tmp_deals ------- sqlfields1-----------------------'
--SELECT * FROM #tmp_deals
EXEC spa_print '###', @sqlFields1
DECLARE @sql_tmp_fields VARCHAR(MAX)
DECLARE @sql_tmp_groups VARCHAR(MAX)


IF(@group_by ='Counterparty') BEGIN
	SET	@sql_tmp_fields = 'SELECT [Counterparty],
	 max(Location) Location ,max(Location_id) Location_id, max(LocationType) LocationType, max(vol) vol'
	SET	@sql_tmp_groups = '[Counterparty],counterparty_id'
END

ELSE IF(@group_by ='Location') BEGIN
	SET	@sql_tmp_fields = 'SELECT  Location ,Location_id, LocationType,SUM(vol) as vol'
	SET	@sql_tmp_groups = 'Location ,Location_id, LocationType'
END
ELSE IF(@group_by ='Deal') BEGIN
	SET	@sql_tmp_fields = 'SELECT  [Deal ID],[Deal Ref ID],max(Location) Location ,max(Location_id) Location_id, max(LocationType) LocationType,SUM(vol) as vol'
	SET	@sql_tmp_groups = '[Deal ID],[Deal Ref ID]'
END

IF(@group_by ='PipelineCounterparty') BEGIN
	SET	@sql_tmp_fields = 'SELECT [Pipeline Counterparty]
						,[Counterparty]
						, Location 
						,Location_id
						, LocationType
						,SUM(vol) as vol'
	SET	@sql_tmp_groups = '[Pipeline Counterparty]
					,[Counterparty]
					,counterparty_id
					, Location 
					,Location_id
					, LocationType
					'
END


SET @sql =	@sqlFlds	+',min(source_deal_detail_id) source_deal_detail_id,MAX([counter_f_sub]) primary_counterparty_id,'+case when @group_by  IN ('Deal','Meter') then 'max' else '' end +'(counterparty_id) counterparty_id into #tmp_deal_final ' + @sqlFrom +
			@sqlGroupBy + ' having round(isnull(sum(sdd.resulting_volume),0),0)<>0;' 




EXEC spa_print '---------------------------------------------'
EXEC spa_print @sql


EXEC spa_print '---------------------------------------------'



EXEC spa_print @sqlFields1

EXEC spa_print '---------------------------------------------'

EXEC spa_print '@group_by:', @group_by

EXEC spa_print @sqlGroupBy

IF(@group_by IN ('Location','Counterparty','PipelineCounterparty'))
BEGIN
	EXEC spa_print '@sql'
	EXEC spa_print @sql
	EXEC spa_print '@sql_tmp_fields' 
	EXEC spa_print  @sql_tmp_fields 
	EXEC spa_print '@sql_grp_heads'
	EXEC spa_print @sql_grp_heads 
	--PRINT ',spa,MAX(source_deal_detail_id) source_deal_detail_id'+' INTO #tmp  FROM #tmp_deal_final ' +   'GROUP BY ' + @sql_tmp_groups +',spa' + ';' +  '' + ' '
	EXEC spa_print '@sqlFields1'	 
	--EXEC spa_print @sqlFields1-- + ' FROM #tmp'

	SET @sql= @sql+	@sql_tmp_fields + @sql_grp_heads +  ',spa'+',MAX(source_deal_detail_id)source_deal_detail_id, MAX(primary_counterparty_id) primary_counterparty_id, MAX(counterparty_id) counterparty_id '+' INTO #tmp  FROM #tmp_deal_final ' +   'GROUP BY 
' + @sql_tmp_groups +	',spa' 			
			+ ';' +  '' + ' ' + @sqlFields1 + ' FROM #tmp'

END
ELSE 
BEGIN
	EXEC spa_print '----Deal, Meter'
	EXEC spa_print @sql 
	--PRINT ';' + ' ' + @sqlFields1 + ' FROM #tmp_deal_final'
	SET @sql= @sql +  ';' + ' ' + @sqlFields1 + ' FROM #tmp_deal_final'

END

EXEC spa_print 'Final @sql'
--EXEC spa_print SUBSTRING(@sql, 0, 7500)
--EXEC spa_print SUBSTRING(@sql, 7500, 7500)
--EXEC spa_print SUBSTRING(@sql, 15000, 7500)
--EXEC spa_print SUBSTRING(@sql, 22500, 7500)

EXEC (@sql)
