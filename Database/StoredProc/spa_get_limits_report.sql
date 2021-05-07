
IF EXISTS ( SELECT  * FROM sys.objects WHERE   OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_limits_report]') AND TYPE IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_get_limits_report]
GO
/**
	
	Script to get limit report.

	Parameters 
	@as_of_date				: As of Date
    @limit_for				: 
    @limit_type				: 
    @limit_id				: 
    @show_exception_only	: 
    @trader_id				: 
    @commodity_id			: 
    @role_id				: 
    @counterparty_id		: 
    @var_crit_det_id		: 
    @curve_id				: 
    @drillID				: 
    @drillIDFor				: 
    @drillCurveID			: 
	@drillPosLimitType		: 
	@drillflag				: 
	@drillTenorLimit		: 
	@deal_level				: 
*/

CREATE PROC [dbo].[spa_get_limits_report]
    @as_of_date DATETIME,
	@limit_for VARCHAR(MAX)=NULL,-- 'l' for limit, 'b' book,'a' all
	@limit_type VARCHAR(MAX) = null,
	@limit_id VARCHAR(MAX) = NULL,
	@show_exception_only CHAR(1) = 'n',
	@trader_id INT = NULL,
	@commodity_id INT = NULL,
	@role_id INT=NULL,
	@counterparty_id INT = NULL,
	@var_crit_det_id INT=NULL,
	@curve_id INT=NULL,
	@drillID INT = NULL,
    @drillIDFor VARCHAR(15) = NULL,
    @drillCurveID VARCHAR(100) = NULL,
    @drillPosLimitType VARCHAR(10) = NULL,
    @drillflag VARCHAR(1) = NULL,
    @drillTenorLimit FLOAT = NULL,
	@deal_level CHAR(1) = 'n',
	@source_deal_header_id  VARCHAR(MAX) = NULL
 AS

/** * DEBUG QUERY START *
DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @_contextinfo
SET NOCOUNT off
	
	--EXEC spa_get_limits_report '2013-02-06', NULL, 1581, '2', 'n', NULL, NULL, NULL

DECLARE   @as_of_date DATETIME='2021-04-26',
	@limit_for int=null,-- 'l' for limit, 'b' book,'a' all
    @limit_type INT = 1588,
    @limit_id VARCHAR(MAX) = 94,
	@show_exception_only CHAR(1) = NULL,
	@trader_id INT = NULL,
	@commodity_id INT = NULL,
	@role_id int=null,
	@counterparty_id INT = NULL,
	@var_crit_det_id int=null,
	@curve_id int=null,
	@drillID INT = NULL,
    @drillIDFor VARCHAR(15) = NULL,
    @drillCurveID VARCHAR(100) = NULL,
    @drillPosLimitType VARCHAR(10) = NULL,
    @drillflag VARCHAR(1) = NULL,
    @drillTenorLimit FLOAT = NULL,
	@deal_level CHAR(1) = 'n'
   , @source_deal_header_id  VARCHAR(MAX) = NULL
    
--select @as_of_date='2012-06-22', @limit_for=NULL, @limit_type=NULL, @limit_id=8, @show_exception_only='n', @trader_id=NULL, @commodity_id=NULL, @role_id=NULL

EXEC spa_drop_all_temp_table

-- * DEBUG QUERY END * */

DECLARE @sql_str VARCHAR(8000)
DECLARE @sql_where VARCHAR(MAX)
SELECT  @sql_where = ''
DECLARE @sql_str1 VARCHAR(MAX)
DECLARE @process_id VARCHAR(500), @user_name VARCHAR(500), @std_deal_table VARCHAR(100)

SET @process_id = dbo.FNAGetNewID()
SET @user_name = dbo.FNADBUser()
SET @std_deal_table = dbo.FNAProcessTableName('std_limit_deals', @user_name, @process_id)


--select * FROM static_data_value WHERE type_id=20200

--select * FROM static_data_value WHERE type_id=20200
CREATE TABLE #limit_ids(limit_id INT, limit_name VARCHAR(250) COLLATE DATABASE_DEFAULT , [LIMIT FOR] VARCHAR(30) COLLATE DATABASE_DEFAULT ,		
		[Trader Name] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		[commodity] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		[ROLE] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		[book_id] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
		[Counterparty] VARCHAR(250) COLLATE DATABASE_DEFAULT ,book1 INT,book2 INT,book3 INT,book4 INT,deal_type VARCHAR(250) COLLATE DATABASE_DEFAULT 
)		

--SELECT @limit_id RETURN

IF @limit_id IS NULL
BEGIN
	

	--insert into #limit_ids
	--exec [dbo].spa_limit_header	@flag ='s',					
	--	@limit_id =NULL,				
	--	@limit_name =NULL,
	--	@limit_for =@limit_for,
	--	@trader_id =@trader_id,
	--	@commodity=null,
	--	@role=null,
	--	@book_id=null,
	--	@counterparty_id =@counterparty_id,
	--	@book1=null,
	--	@book2=null,
	--	@book3=null,
	--	@book4=null,
	--	@deal_type	=NULL
	SET @sql_str = '
	INSERT INTO #limit_ids(limit_id)
	SELECT lh.limit_id FROM limit_header lh 
	WHERE 1 = 1 
	' 
	IF @limit_for IS NOT NULL
		SET @sql_str += ' AND lh.limit_for IN (' + CAST(@limit_for AS VARCHAR) + ')'
	IF @trader_id IS NOT NULL
		SET @sql_str += ' AND lh.trader_id = ' + CAST(@trader_id AS VARCHAR)
	IF @counterparty_id IS NOT NULL
		SET @sql_str += ' AND lh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
	exec spa_print @sql_str
	EXEC(@sql_str)

END		
		
ELSE
 	INSERT INTO #limit_ids(limit_id ) SELECT item FROM dbo.SplitCommaSeperatedValues(@limit_id)
    
   
CREATE TABLE #limit_info (maintain_limit_id INT,book_id VARCHAR(1000) COLLATE DATABASE_DEFAULT  ,limit_type INT,limit_for INT,party_id INT 
	,limit_value NUMERIC(26,10),var_criteria_id INT,deal_type INT,curve_id INT,limit_uom INT,limit_currency INT
	,tenor_granularity INT,tenor_month_from INT,tenor_month_to INT,effective_date DATETIME, deal_subtype INT, book1 INT,book2 INT,book3 INT,book4 INT, limit_id INT, curve_source_value_id INT, trader_id INT
	,term_start date, term_end date
	
	)

SET @sql_str='insert into  #limit_info (maintain_limit_id,limit_type,limit_for,party_id ,book_id ,var_criteria_id,book1,book2,book3,book4,deal_type,curve_id
	,limit_uom,limit_currency,tenor_granularity,tenor_month_from,tenor_month_to, effective_date, deal_subtype, limit_value, limit_id, curve_source_value_id, trader_id,term_start , term_end )
	select lt.maintain_limit_id,
		lt.limit_type,
		lh.limit_for,
		CASE lh.limit_for 
			WHEN 20201 THEN lh.trader_id 
			WHEN 20204 THEN lh.counterparty_id 
			WHEN 20203 THEN lh.commodity 
			WHEN 20202 THEN lh.role 
			WHEN 20200 THEN lh.commodity
		ELSE 
			NULL 
		END party_id,
		lh.book_id,
		lt.var_criteria_det_id,
		lh.book1,
		lh.book2,
		lh.book3,
		lh.book4,
		lt.deal_type,
		lt.curve_id,
		lt.limit_uom,
		lt.limit_currency,
		lt.tenor_granularity,
		lt.tenor_month_from,
		lt.tenor_month_to,
		lt.effective_date,
		lt.deal_subtype,
		lt.limit_value, 
		lt.limit_id, 
		lh.curve_source,
		CASE lh.limit_for WHEN 20200 THEN lh.trader_id
		ELSE NULL END trader_id
		,dbo.[FNAGetTermStartDate](
			CASE lt.tenor_granularity 
				WHEN 980 THEN ''m''
				WHEN 981 THEN ''d''
				WHEN 990 THEN ''w''
				WHEN 991 THEN ''q''
				WHEN 992 THEN ''s''
				WHEN 993 THEN ''a''
				WHEN 982 THEN ''h''
			ELSE 
				''m'' 
			END,
		''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''',ISNULL(lt.tenor_month_from,
			CASE lt.tenor_granularity 
				WHEN 980 THEN -3000 
				WHEN 981 THEN -7000
				WHEN 990 THEN -6000
				WHEN 991 THEN -3000
				WHEN 992 THEN -2000
				WHEN 993 THEN -1000	
				WHEN 982 THEN -10000
			ELSE 
				-3000 
			END-1) ) term_start,
		 dbo.FNAGetTermEndDate(
			CASE lt.tenor_granularity 
				WHEN 980 THEN ''m''
				WHEN 981 THEN ''d''
				WHEN 990 THEN ''w''
				WHEN 991 THEN ''q''
				WHEN 992 THEN ''s''
				WHEN 993 THEN ''a''
				WHEN 982 THEN ''h''
			ELSE 
				''m'' 
			END,
		''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''',ISNULL(lt.tenor_month_to,
			CASE lt.tenor_granularity 
				WHEN 980 THEN 3000 
				WHEN 981 THEN 7000
				WHEN 990 THEN 6000
				WHEN 991 THEN 3000
				WHEN 992 THEN 2000
				WHEN 993 THEN 1000
				WHEN 982 THEN 10000	
			ELSE 
				3000 
			END)) term_end
	FROM maintain_limit lt 
	INNER JOIN limit_header lh on lh.limit_id = lt.limit_id
		AND lh.active = ''y'' 
	INNER JOIN #limit_ids li on li.limit_id = lh.limit_id '  
	+ CASE WHEN @limit_for IS NULL THEN '' ELSE ' AND lh.limit_for IN (' + CAST(@limit_for AS VARCHAR) + ')' END 
	+ CASE WHEN @limit_type IS NULL THEN '' ELSE ' AND lt.limit_type IN ('+ CAST(@limit_type as VARCHAR) + ')' END 
	+ CASE WHEN @trader_id IS NULL THEN '' ELSE ' AND lh.trader_id='+ CAST(@trader_id AS VARCHAR)  END 
	+ CASE WHEN @commodity_id IS NULL THEN '' ELSE ' AND lh.commodity='+ CAST(@commodity_id AS VARCHAR)  END 
	+ CASE WHEN @counterparty_id IS NULL THEN '' ELSE ' AND lh.counterparty_id='+ CAST(@counterparty_id AS VARCHAR)  END 
	+ CASE WHEN @role_id IS NULL THEN '' ELSE ' AND lh.role='+ CAST(@role_id AS VARCHAR)  END 
	+ CASE WHEN @var_crit_det_id IS NULL THEN '' ELSE   ' AND lt.var_crit_det_id ='+ CAST(@var_crit_det_id AS VARCHAR)  END 
	+ CASE WHEN @curve_id IS NULL THEN '' ELSE   ' AND lt.curve_id ='+ CAST(@curve_id AS VARCHAR)  END + '
	WHERE lt.is_active = ''y'''


EXEC spa_print @sql_str
EXEC(@sql_str)		

/*		
select * FROM maintain_limit

select * FROM static_data_value WHERE type_id= 1580

20203	20200	Commodity
20204	20200	Counterparty
20200	20200	Others
20201	20200	Trader
20202	20200	Trading Role
	*/	
DECLARE @term_start	DATETIME, @term_end DATETIME, @tenor_from INT, @tenor_to INT
CREATE TABLE #collect_deals (maintain_limit_id INT, source_deal_header_id INT,deal_date DATETIME,term_start DATETIME, term_end DATETIME)

DECLARE @maintain_limit_id INT,@c_limit_for INT,@c_party_id INT ,@c_book_id VARCHAR(1000) ,@c_var_criteria_id INT
	,@c_book1 INT,@c_book2 INT,@c_book3 INT,@c_book4 INT,@c_deal_type INT,@c_curve_id INT, @c_limit_id INT, @c_effective_date DATETIME, @c_deal_subtype INT

DECLARE cur_collect_deals CURSOR FOR 
	SELECT maintain_limit_id,limit_for,party_id ,book_id ,var_criteria_id,book1,book2,book3,book4,deal_type,curve_id, limit_id, effective_date, deal_subtype FROM #limit_info
	WHERE limit_type IN (1580, 1581, 1587, 1588, 1596, 1598, 1599, 1597) --mtm & position
OPEN cur_collect_deals
FETCH NEXT FROM cur_collect_deals INTO @maintain_limit_id ,@c_limit_for ,@c_party_id ,@c_book_id ,@c_var_criteria_id 
	,@c_book1 ,@c_book2 ,@c_book3 ,@c_book4 ,@c_deal_type ,@c_curve_id , @c_limit_id, @c_effective_date, @c_deal_subtype
WHILE @@FETCH_STATUS = 0
BEGIN	
	IF OBJECT_ID(@std_deal_table) IS NOT NULL
		EXEC('DROP TABLE ' + @std_deal_table)
		
	EXEC spa_collect_mapping_deals @as_of_date, 23200, @c_limit_id, @std_deal_table
	
--select @maintain_limit_id ,@c_limit_for ,@c_party_id ,@c_book_id ,@c_var_criteria_id 
--	,@c_book1 ,@c_book2 ,@c_book3 ,@c_book4 ,@c_deal_type ,@c_curve_id 
--SELECT @maintain_limit_id
	SET @sql_str='insert into #collect_deals (maintain_limit_id , source_deal_header_id,deal_date ,term_start , term_end  )
		select '+CAST(@maintain_limit_id AS VARCHAR)+' , sdh.source_deal_header_id,sdh.deal_date,min(sdd.term_start) term_start,max(sdd.term_end) term_end   
		FROM source_deal_header sdh 
		INNER JOIN ' + @std_deal_table + ' sdt ON sdt.source_deal_header_id = sdh.source_deal_header_id 
		INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
		INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
			 AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
			 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
			 AND sdh.source_system_book_id4 = ssbm.source_system_book_id4 '
		--'+ CASE WHEN  @c_book1 is null THEN '' ELSE ' AND sdh.source_system_book_id1 = '+ cast(ISNULL(@c_book1,-1) AS VARCHAR) END +'
		--'+ CASE WHEN  @c_book2 is null THEN '' ELSE ' AND sdh.source_system_book_id2 = '+ cast(ISNULL(@c_book2,-2) AS VARCHAR) END+'			
		--'+ CASE WHEN  @c_book3 is null THEN '' ELSE ' AND sdh.source_system_book_id3 = '+ cast(ISNULL(@c_book3,-3) AS VARCHAR) END+'
		--'+ CASE WHEN  @c_book4 is null THEN '' ELSE ' AND sdh.source_system_book_id4 = '+ cast(ISNULL(@c_book4,-4) AS VARCHAR) END+	
		--CASE WHEN @c_book_id is not null THEN ' AND ssbm.fas_book_id in ('+@c_book_id+')' ELSE '' END
	
		+ ' WHERE 1 = 1 '
		+ CASE WHEN @source_deal_header_id IS NOT NULL AND @deal_level= 'y' THEN ' AND sdh.source_deal_header_id  IN ('+CAST(@source_deal_header_id AS VARCHAR(MAX) )+')' ELSE '' END
		+CASE WHEN @c_deal_type IS NOT NULL THEN ' AND sdh.source_deal_type_id ='+CAST(@c_deal_type AS VARCHAR) ELSE '' END
		+CASE WHEN @c_deal_subtype IS NOT NULL THEN ' AND sdh.deal_sub_type_type_id ='+CAST(@c_deal_subtype AS VARCHAR(20)) ELSE '' END
		+CASE WHEN @c_party_id IS NOT NULL THEN 
			CASE @c_limit_for WHEN  20201 THEN ' AND sdh.trader_id='+CAST(@c_party_id AS VARCHAR) WHEN 20204 THEN ' AND sdh.counterparty_id=' +CAST(@c_party_id AS VARCHAR)
					--WHEN 20203 THEN ' AND spcd.commodity_id=' WHEN 20202 THEN null 
			ELSE '' END 
		
		ELSE '' END
		+ CASE WHEN @c_effective_date IS NOT NULL THEN ' AND ''' + CONVERT(VARCHAR(10), @c_effective_date, 120) + ''' <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''  ELSE '' END

		+' GROUP BY sdh.source_deal_header_id,sdh.deal_date '
		--+CASE WHEN @c_curve_id is not null THEN ' AND sdd.curve_id ='+cast(@c_curve_id AS VARCHAR) ELSE '' END
	
	exec spa_print @sql_str
	EXEC(@sql_str)

	SELECT 
		@term_start = pmt.term_start,
		@term_end = pmt.term_end,
		@tenor_from = pmt.starting_month,
		@tenor_to = pmt.no_of_month
	FROM portfolio_mapping_source pms
	INNER JOIN portfolio_mapping_tenor pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	WHERE pms.mapping_source_usage_id = @c_limit_id
		AND pms.mapping_source_value_id = 23200

	SET @term_start = dbo.FNAGetContractMonth(ISNULL(@term_start, DATEADD (MONTH, CAST(@tenor_from AS INT), @as_of_date)))
	SET @term_end = dbo.FNALastDayInDate(ISNULL(@term_end, DATEADD (MONTH, CAST(@tenor_to AS INT), @as_of_date)))

	UPDATE cd SET term_start = @term_start, term_end = @term_end
	FROM #collect_deals cd
	INNER JOIN maintain_limit ml ON ml.maintain_limit_id = cd.maintain_limit_id
	WHERE cd.maintain_limit_id = @maintain_limit_id
	AND ml.limit_id = @c_limit_id

	FETCH NEXT FROM cur_collect_deals INTO @maintain_limit_id ,@c_limit_for ,@c_party_id ,@c_book_id ,@c_var_criteria_id 
		,@c_book1 ,@c_book2 ,@c_book3 ,@c_book4 ,@c_deal_type ,@c_curve_id , @c_limit_id, @c_effective_date, @c_deal_subtype
	
	EXEC('DELETE FROM ' + @std_deal_table)
			
END
CLOSE cur_collect_deals
DEALLOCATE cur_collect_deals

--SELECT * FROM #limit_info
--RETURN

 /*
 
 1585	1580	Default VaR limit
1586	1580	Integrated VaR limit
1580	1580	MTM Limit
1581	1580	Position AND Tenor limit
1583	1580	RAROC Integrated limit
1582	1580	RAROC limit
1584	1580	VaR limit
1587	1580	Tenor limit
1588	1580	Position limit
1596	1580	Notional Value limit
1598	1580	Trade Duration Limit
 
980 978	Monthly	Monthly
981	978	Daily	Daily
982	978	Hourly	Hourly
990	978	Weekly	Weekly
991	978	Quarterly	Quarterly
992	978	Semi-Annually	Semi-Annually
993	978	Annually	Annually
989	978	30Min	30Min
987	978	15Min	15Min
 
 select * FROM cur_collect_deals
 
 select * FROM   #limit_info
 
 
 select * FROM  maintain_limit
 select * FROM  limit_header
 
 
	
20203	20200	Commodity
20204	20200	Counterparty
20200	20200	Others
20201	20200	Trader
20202	20200	Trading Role


 
 */
 --declare   @as_of_date DATETIME='2012-11-27'
 CREATE TABLE #limit_info_value (maintain_limit_id INT, total_value NUMERIC(38,2), unit VARCHAR(100) COLLATE DATABASE_DEFAULT, source_deal_header_id INT, value2 FLOAT)
 CREATE TABLE #limit_info_value_reserve (maintain_limit_id INT, total_value NUMERIC(38,2), unit VARCHAR(100) COLLATE DATABASE_DEFAULT, source_deal_header_id INT, value2 FLOAT,source_counterparty_id int, contract_id int)
SET @sql_str1 = '
INSERT INTO #limit_info_value (maintain_limit_id, total_value, unit, source_deal_header_id)
SELECT li.maintain_limit_id, SUM(ISNULL(vol.vol, 0)) total_value, MAX(su.uom_name) unit, ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'cd.source_deal_header_id ' ELSE 'NULL' END + '
FROM #limit_info li 
INNER JOIN (SELECT DISTINCT * FROM #collect_deals) cd ON li.maintain_limit_id = cd.maintain_limit_id 
	AND limit_type IN (1581, 1588) 
	AND ISNULL(li.limit_value, 0) <> 0
OUTER APPLY
(
	SELECT SUM(
		(CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg, -1) = 1 THEN sdpdo.DELTA WHEN ISNULL(sdd.leg, -1) = 2 THEN sdpdo.DELTA2 ELSE 0 END ELSE 1 END) *
		ISNULL(conv.conversion_factor,1)*(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24)) vol
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
	INNER JOIN report_hourly_position_profile r ON r.term_start BETWEEN coalesce(cd.term_start,li.term_start, sdd.term_start) AND coalesce(cd.term_end,li.term_end, sdd.term_end)
		AND r.source_deal_detail_id=sdd.source_deal_detail_id
		AND ISNULL(li.party_id, r.commodity_id) = CASE WHEN li.limit_for IN(20203, 20200) THEN ISNULL(r.commodity_id, li.party_id) ELSE ISNULL(li.party_id, r.commodity_id) END
		AND sdd.curve_id = ISNULL(li.curve_id, r.curve_id) 
		AND r.source_deal_header_id = cd.source_deal_header_id 
	inner JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status 
	LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = r.deal_volume_uom_id
		AND conv.to_source_uom_id = li.limit_uom
	OUTER APPLY(
		SELECT TOP(1) delta, delta2 
		FROM source_deal_pnl_detail_options sdpdo
		WHERE sdpdo.as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
			AND sdpdo.source_deal_header_id = sdh.source_deal_header_id	
			AND sdpdo.term_start = CASE WHEN ISNULL(sdh.internal_deal_subtype_value_id, 1) = 101 THEN sdpdo.term_start ELSE sdd.term_start END
		)sdpdo	
	WHERE r.term_start > ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
		AND expiration_date >= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''  
		AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
		--AND r.term_start BETWEEN li.term_start AND  li.term_end
		AND li.limit_type IN (1581, 1588)
		AND sdh.trader_id = CASE WHEN li.limit_for = 20200 THEN ISNULL(li.trader_id, sdh.trader_id) ELSE sdh.trader_id END 
		AND sdh.counterparty_id = CASE WHEN li.limit_for = 20204 THEN ISNULL(li.party_id, sdh.counterparty_id) ELSE sdh.counterparty_id END 
	UNION ALL	
	SELECT  SUM(
		(CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg, -1) = 1 THEN sdpdo.DELTA WHEN ISNULL(sdd.leg, -1) = 2 THEN sdpdo.DELTA2 ELSE 0 END ELSE 1 END) *
		ISNULL(conv.conversion_factor,1)*(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24)) vol
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
	INNER JOIN  report_hourly_position_deal r ON r.term_start BETWEEN coalesce(cd.term_start,li.term_start, sdd.term_start) AND coalesce(cd.term_end,li.term_end, sdd.term_end) 
		AND r.source_deal_detail_id=sdd.source_deal_detail_id
		AND ISNULL(li.party_id, r.commodity_id) = CASE WHEN li.limit_for IN(20203, 20200) THEN ISNULL(r.commodity_id, li.party_id) ELSE ISNULL(li.party_id, r.commodity_id) END
		AND sdd.curve_id = ISNULL(li.curve_id, r.curve_id)
		AND r.source_deal_header_id = cd.source_deal_header_id
	inner JOIN deal_status_group dsg ON dsg.status_value_id = sdh.deal_status 
	LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id = r.deal_volume_uom_id
		AND conv.to_source_uom_id = li.limit_uom
	OUTER APPLY(
		SELECT TOP(1) delta, delta2 
		FROM source_deal_pnl_detail_options sdpdo
		WHERE sdpdo.as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
			AND sdpdo.source_deal_header_id = sdh.source_deal_header_id	
			AND sdpdo.term_start = CASE WHEN ISNULL(sdh.internal_deal_subtype_value_id, 1) = 101 THEN sdpdo.term_start ELSE sdd.term_start END
		)sdpdo 	
	WHERE r.term_start > ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
		AND expiration_date >= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''  
		AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
		--AND r.term_start >= CASE WHEN li.limit_type <> 1588 THEN li.term_start ELSE r.term_start END							
		--AND  r.term_start <= CASE WHEN li.limit_type <> 1588 THEN li.term_end ELSE  r.term_start  END
		AND sdh.trader_id = CASE WHEN li.limit_for = 20200 THEN ISNULL(li.trader_id, sdh.trader_id) ELSE sdh.trader_id END
		AND sdh.counterparty_id = CASE WHEN li.limit_for = 20204 THEN ISNULL(li.party_id, sdh.counterparty_id) ELSE sdh.counterparty_id END 
) 	vol	
LEFT JOIN source_uom su ON su.source_uom_id = li.limit_uom
GROUP BY li.maintain_limit_id '  + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ',cd.source_deal_header_id ' ELSE '' END 

EXEC spa_print @sql_str1
EXEC(@sql_str1)
 
  
--alter table #limit_info_value add tenor_violation bit
CREATE TABLE  #limit_info_tenor
(maintain_limit_id INT,min_tenor INT,max_tenor INT, source_deal_header_id INT)

DECLARE @st VARCHAR(MAX)
SET @st='insert into #limit_info_tenor (maintain_limit_id ,min_tenor ,max_tenor, source_deal_header_id)
select  li.maintain_limit_id,
min( 
	 CASE WHEN 
		CASE li.tenor_granularity 
			WHEN 980 THEN datediff(month, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('m',@as_of_date,0),120)+''', sdd.term_start) 
			WHEN 981 THEN datediff(day, ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''', sdd.term_start) 
			WHEN 990 THEN datediff(week, ''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''', sdd.term_start) 
			WHEN 991 THEN datediff(quarter, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('q', @as_of_date, 0), 120) + ''', sdd.term_start) 
			WHEN 992 THEN datediff(month, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('s', @as_of_date, 0), 120) + ''', dbo.[FNAGetTermEndDate](''s'', sdd.term_start, 0)) / 6
			WHEN 993 THEN datediff(year, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('a', @as_of_date, 0), 120) + ''', sdd.term_start) 
		ELSE  datediff(month, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('m', @as_of_date, 0), 120) + ''', sdd.term_start)  END
		< 0 THEN null 
	ELSE 	
		CASE li.tenor_granularity WHEN 980 THEN datediff(month, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('m', @as_of_date, 0), 120) + ''', sdd.term_start) 
			WHEN 981 THEN datediff(day, ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''', sdd.term_start) 
			WHEN 990 THEN datediff(week, ''' + CONVERT(VARCHAR(10), @as_of_date, 120)+''', sdd.term_start) 
			WHEN 991 THEN datediff(quarter, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('q', @as_of_date, 0), 120) + ''', sdd.term_start) 
			WHEN 992 THEN datediff(month, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('s', @as_of_date, 0), 120) + ''', dbo.[FNAGetTermEndDate](''s'', sdd.term_start, 0)) / 6 
			WHEN 993 THEN datediff(year,''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('a', @as_of_date, 0), 120) + ''', sdd.term_start) 
			ELSE  datediff(month,''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('m', @as_of_date, 0), 120) + ''', sdd.term_start)  END
	END		
) min_tenor
,max(CASE li.tenor_granularity WHEN 980 THEN datediff(month, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('m', @as_of_date, 0), 120) + ''', sdd.term_end) 
		WHEN 981 THEN datediff(day, ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''', sdd.term_end) 
		WHEN 990 THEN datediff(week, ''' + CONVERT(VARCHAR(10), @as_of_date,120) + ''', sdd.term_end) 
		WHEN 991 THEN datediff(quarter, ''' + CONVERT(VARCHAR(10), dbo.[FNAGetTermEndDate]('q', @as_of_date, 0), 120) + ''', sdd.term_end) 
		WHEN 992 THEN datediff(month, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('s', @as_of_date,0),120)+''', dbo.[FNAGetTermEndDate](''s'', sdd.term_end, 0)) / 6 
		WHEN 993 THEN datediff(year, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('a', @as_of_date,0),120)+''', sdd.term_end) 
		ELSE  datediff(month, ''' + CONVERT(VARCHAR(10),dbo.[FNAGetTermEndDate]('m', @as_of_date, 0),120)+''', sdd.term_end)  END)
  max_tenor
, ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id
FROM #limit_info li 
INNER JOIN #collect_deals cd on li.maintain_limit_id=cd.maintain_limit_id 
	AND limit_type=1587 
	AND ISNULL(li.limit_value ,0)=0
INNER JOIN source_deal_header sdh ON cd.source_deal_header_id = sdh.source_deal_header_id
	AND sdh.deal_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
	AND (sdh.trader_id = CASE WHEN li.limit_for = 20200 THEN ISNULL(li.trader_id, sdh.trader_id) ELSE sdh.trader_id END	 OR
	sdh.counterparty_id = CASE WHEN li.limit_for = 20204 THEN ISNULL(li.party_id, sdh.counterparty_id) ELSE sdh.counterparty_id END
	)
INNER JOIN  dbo.source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	AND	 ISNULL(li.party_id, spcd.commodity_id)= CASE WHEN li.limit_for IN (20203, 20200) THEN ISNULL(spcd.commodity_id,ISNULL(li.party_id,-9999999)) ELSE ISNULL(li.party_id, spcd.commodity_id) END
	AND sdd.curve_id = ISNULL(li.curve_id, sdd.curve_id) -- AND sdd.term_start > @as_of_date
group by li.maintain_limit_id  ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', sdh.source_deal_header_id ' ELSE '' END


EXEC spa_print @st
EXEC(@st)
 

-- select * from #limit_info li  where maintain_limit_id = 57
 --select * from #collect_deals where maintain_limit_id = 57

-- Trade Duration Limit
SET @st=' insert into #limit_info_tenor (maintain_limit_id ,min_tenor ,max_tenor, source_deal_header_id)
  select  li.maintain_limit_id, 
min( 
	 CASE WHEN 
		CASE li.tenor_granularity 
			WHEN 980 THEN datediff(month, sdh.entire_term_start, sdh.entire_term_end)+1 
			WHEN 981 THEN datediff(day, sdh.entire_term_start, sdh.entire_term_end) +1
			WHEN 990 THEN datediff(week, sdh.entire_term_start, sdh.entire_term_end) +1
			WHEN 993 THEN datediff(year, sdh.entire_term_start, sdh.entire_term_end) +1
		ELSE  datediff(month, sdh.entire_term_start, sdh.entire_term_end)+1  END
		< 0 THEN NULL 
		ELSE 	
			CASE li.tenor_granularity 
				WHEN 980 THEN datediff(month, sdh.entire_term_start, sdh.entire_term_end) +1
				WHEN 981 THEN datediff(day, sdh.entire_term_start, sdh.entire_term_end) +1
				WHEN 990 THEN datediff(week, sdh.entire_term_start, sdh.entire_term_end) +1
				WHEN 993 THEN datediff(year, sdh.entire_term_start, sdh.entire_term_end) +1
			ELSE  datediff(month, sdh.entire_term_start, sdh.entire_term_end) +1 END
	END		
) min_tenor
,max( CASE WHEN 
		CASE li.tenor_granularity 
			WHEN 980 THEN datediff(month, sdh.deal_date, sdh.entire_term_end)  +1
			WHEN 981 THEN datediff(day, sdh.deal_date, sdh.entire_term_end)  +1
			WHEN 990 THEN datediff(week, sdh.deal_date, sdh.entire_term_end)  +1
			WHEN 993 THEN datediff(year, sdh.deal_date, sdh.entire_term_end)  +1
		ELSE  datediff(month, sdh.deal_date, sdh.entire_term_end)  +1 END
		< 0 THEN NULL 
		ELSE 	
			CASE li.tenor_granularity 
				WHEN 980 THEN datediff(month, sdh.deal_date, sdh.entire_term_end)  +1
				WHEN 981 THEN datediff(day, sdh.deal_date, sdh.entire_term_end)  +1
				WHEN 990 THEN datediff(week, sdh.deal_date, sdh.entire_term_end)  +1
				WHEN 993 THEN datediff(year, sdh.deal_date, sdh.entire_term_end)  +1
			ELSE  datediff(month, sdh.deal_date, sdh.entire_term_end)  +1 END
	END	
 ) max_tenor
 , ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id

FROM #limit_info li 
INNER JOIN #collect_deals cd on li.maintain_limit_id=cd.maintain_limit_id
INNER JOIN source_deal_header sdh ON cd.source_deal_header_id = sdh.source_deal_header_id
	AND sdh.deal_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
	AND (sdh.trader_id = CASE WHEN li.limit_for = 20200 THEN ISNULL(li.trader_id, sdh.trader_id) ELSE sdh.trader_id END	 OR
	sdh.counterparty_id = CASE WHEN li.limit_for = 20204 THEN ISNULL(li.party_id, sdh.counterparty_id) ELSE sdh.counterparty_id END	)
INNER JOIN  dbo.source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id AND sdd.term_start >= ''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01''
INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	AND	 ISNULL(li.party_id, spcd.commodity_id)= CASE WHEN li.limit_for IN (20203, 20200) THEN ISNULL(spcd.commodity_id,ISNULL(li.party_id,-9999999)) ELSE ISNULL(li.party_id, spcd.commodity_id) END
	AND sdd.curve_id = ISNULL(li.curve_id, sdd.curve_id)
WHERE li.limit_type=1598 AND ISNULL(li.limit_value ,0)=0
 group by li.maintain_limit_id ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', sdh.source_deal_header_id ' ELSE '' END 


EXEC spa_print @st
EXEC(@st)



UPDATE #limit_info_tenor SET min_tenor = NULL WHERE min_tenor < 0

SET @sql_str='INSERT INTO #limit_info_value(maintain_limit_id,total_value, unit, source_deal_header_id)
	SELECT maintain_limit_id, SUM(total_value), MAX(unit), ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'source_deal_header_id ' ELSE 'NULL ' END + ' FROM (
		SELECT  
			li.maintain_limit_id, 
			sdpd.und_pnl * COALESCE(spc.curve_value, 1/spc1.curve_value, 1) total_value,	 
			sc.currency_name unit,
			' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id
		FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl_detail') + ' sdpd 
		INNER JOIN #collect_deals cd ON sdpd.source_deal_header_id = cd.source_deal_header_id
			AND (cd.term_start IS NULL OR sdpd.term_start >= cd.term_start)
			AND (cd.term_end IS NULL OR sdpd.term_end <= cd.term_end)
		INNER JOIN #limit_info li ON cd.maintain_limit_id = li.maintain_limit_id
			AND li.limit_type = 1580 and li.curve_source_value_id = sdpd.pnl_source_value_id
		--INNER JOIN source_price_curve_def spcd on sdpd.curve_id = spcd.source_curve_def_id
		--	AND ISNULL(spcd.commodity_id, -9999999) = CASE WHEN li.limit_for = 20200 THEN COALESCE(li.party_id, spcd.commodity_id, -9999999) ELSE ISNULL(spcd.commodity_id, -9999999) END 	
		INNER JOIN maintain_limit ml ON cd.maintain_limit_id = ml.maintain_limit_id	
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdpd.source_deal_header_id
			AND sdh.source_deal_header_id = cd.source_deal_header_id
			AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			AND ISNULL(sdh.trader_id, -9999999) = CASE WHEN li.limit_for = 20200 THEN COALESCE(li.trader_id, sdh.trader_id, -9999999) ELSE ISNULL(sdh.trader_id, -9999999) END 
			AND sdpd.pnl_as_of_date >= sdh.deal_date
			AND sdpd.pnl_as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
			AND sdpd.term_start >= ''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01''
			AND sdh.source_deal_header_id IN (
				SELECT DISTINCT sdh.source_deal_header_id
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id
				WHERE  spcd.commodity_id = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN 
						li.party_id  ELSE spcd.commodity_id  END
					AND sdd.Leg = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN 1 ELSE sdd.Leg END)
		LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_currency_id = sdpd.pnl_currency_id
			AND spcd1.source_currency_to_id = ml.limit_currency
			AND spcd1.Granularity = 980
		LEFT JOIN source_price_curve spc ON spcd1.source_curve_def_id = spc.source_curve_def_id
			AND spc.as_of_date = sdpd.pnl_as_of_date --term, source 
			AND spc.maturity_date = CONVERT(VARCHAR(7), sdpd.term_start, 120) + ''-01''
			AND spc.curve_source_value_id = li.curve_source_value_id
		LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_currency_id = ml.limit_currency
			AND spcd2.source_currency_to_id = sdpd.pnl_currency_id
			AND spcd2.Granularity = 980
		LEFT JOIN source_price_curve spc1 ON spcd2.source_curve_def_id = spc1.source_curve_def_id
			AND spc1.as_of_date = sdpd.pnl_as_of_date
			AND spc1.maturity_date = CONVERT(VARCHAR(7), sdpd.term_start, 120) + ''-01''
			AND spc1.curve_source_value_id = li.curve_source_value_id 
		LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency
		WHERE sdpd.pnl_source_value_id = li.curve_source_value_id
	) mtm GROUP BY maintain_limit_id ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', source_deal_header_id ' ELSE '' END

exec spa_print @sql_str
EXEC(@sql_str)


-- Price Corridor
SET @sql_str='
 INSERT INTO #limit_info_value(maintain_limit_id,total_value, unit, source_deal_header_id, value2)
SELECT maintain_limit_id, SUM(und_pnl) und_pnl, MAX(unit) [unit], ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id, ((AVG(curve_value) - AVG(fixed_price + ISNULL(formula_value, 0) + ISNULL(price_adder, 0) ))/NULLIF(AVG(curve_value),0)) * 100 limit_percentage
FROM (
	SELECT li.maintain_limit_id,  sdpd.und_pnl, sc.currency_name unit, 
	' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id,
	sdpd.curve_value, sdpd.fixed_price, sdpd.formula_value, sdpd.price_adder
 	FROM #collect_deals cd 
	INNER JOIN maintain_limit ml ON ml.maintain_limit_id = cd.maintain_limit_id
	LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency
	INNER JOIN #limit_info li ON li.maintain_limit_id = cd.maintain_limit_id AND li.limit_type = 1597
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cd.source_deal_header_id AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
	AND ISNULL(sdh.trader_id, -9999999) = CASE WHEN li.limit_for = 20200 THEN COALESCE(li.trader_id, sdh.trader_id, -9999999) ELSE ISNULL(sdh.trader_id, -9999999) END 
	AND sdh.source_deal_header_id IN (
		SELECT DISTINCT sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id
		WHERE  spcd.commodity_id = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN li.party_id ELSE spcd.commodity_id END
			AND sdd.Leg = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN 1 ELSE sdd.Leg END
	)
	LEFT JOIN ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl_detail') + ' sdpd ON sdpd.source_deal_header_id = sdh.source_deal_header_id
	AND (cd.term_start IS NULL OR sdpd.term_start >= cd.term_start) AND (cd.term_end IS NULL OR sdpd.term_end <= cd.term_end)
	AND sdpd.pnl_as_of_date >= sdh.deal_date
	AND sdpd.term_start >= ''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01''
	AND sdpd.pnl_as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 

WHERE li.maintain_limit_id IS NOT NULL
) mtm GROUP BY maintain_limit_id ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', source_deal_header_id ' ELSE '' END
	 
EXEC(@sql_str)

-- Notional Value 
SET @sql_str='
 INSERT INTO #limit_info_value(maintain_limit_id,total_value, unit, source_deal_header_id)
		 SELECT li.maintain_limit_id,  ISNULL(SUM(ABS(pd.contract_value)), SUM(dd.total_value)) total_value, MAX(sc.currency_name) unit,
		 ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id
 		 FROM #collect_deals cd 
		 INNER JOIN maintain_limit ml ON ml.maintain_limit_id = cd.maintain_limit_id
		 LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency
		 INNER JOIN #limit_info li ON li.maintain_limit_id = cd.maintain_limit_id AND li.limit_type = 1596
		 INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = cd.source_deal_header_id AND sdh.deal_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			AND ISNULL(sdh.trader_id, -9999999) = CASE WHEN li.limit_for = 20200 THEN COALESCE(li.trader_id, sdh.trader_id, -9999999) ELSE ISNULL(sdh.trader_id, -9999999) END 
			AND sdh.source_deal_header_id IN (
				SELECT DISTINCT sdh.source_deal_header_id
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id
				WHERE  spcd.commodity_id = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN li.party_id ELSE spcd.commodity_id END
					AND sdd.Leg = CASE WHEN li.limit_for IN(20200, 20203) AND li.party_id IS NOT NULL THEN 1 ELSE sdd.Leg END
			)
		 OUTER APPLY(SELECT SUM(ABS(sdpd.contract_value)) contract_value,
			 ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id
			 FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl_detail') + ' sdpd WHERE 
			 sdpd.source_deal_header_id = sdh.source_deal_header_id
			 AND (cd.term_start IS NULL OR sdpd.term_start >= cd.term_start) AND (cd.term_end IS NULL OR sdpd.term_end <= cd.term_end)
			 AND sdpd.pnl_as_of_date >= sdh.deal_date
			 AND sdpd.term_start >= ''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01''
			 AND sdpd.pnl_as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' 
			 AND li.maintain_limit_id IS NOT NULL
		) pd
		OUTER APPLY(SELECT SUM(sdd.total_volume * sdd.fixed_price) total_value, 
			' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'sdh.source_deal_header_id ' ELSE 'NULL ' END + ' source_deal_header_id
			FROM source_deal_detail sdd WHERE sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.term_start >= ''' + CONVERT(VARCHAR(7), @as_of_date, 120) + '-01''
			AND sdd.term_start >= ISNULL(cd.term_start, sdd.term_start) AND sdd.term_end <= ISNULL(cd.term_end, sdd.term_end)
		) dd
		GROUP BY li.maintain_limit_id ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', sdh.source_deal_header_id ' ELSE '' END
	 
--print(@sql_str)
EXEC(@sql_str)

-- Reserve Limit
SET @sql_str='
		INSERT INTO #limit_info_value_reserve(maintain_limit_id,total_value, unit, source_deal_header_id,source_counterparty_id, contract_id)
		SELECT maintain_limit_id, CASE WHEN SUM(total_value) < 0 THEN 0 ELSE SUM(total_value) END , MAX(unit), ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN 'source_deal_header_id ' ELSE 'NULL ' END + ' 
		,source_counterparty_id, contract_id FROM (

		 SELECT li.maintain_limit_id,  (ced.effective_exposure_to_us * ISNULL((1-dbo.FNAGetRecoveryRate(ced.risk_rating_id, DATEDIFF(month,ced.term_start, ced.as_of_date), ced.as_of_date)), 1)*
			ISNULL(dbo.FNAGetProbabilityDefault(ced.risk_rating_id, DATEDIFF(month,ced.term_start, ced.as_of_date), ced.as_of_date), 1)
        ) total_value, 
		sc.currency_name unit, 
		 NULL source_deal_header_id
		 ,sc1.source_counterparty_id
		 ,ced.contract_id
		 
		FROM source_counterparty sc1
		INNER JOIN credit_exposure_detail ced ON ced.source_counterparty_id = sc1.source_counterparty_id	 
  		 INNER JOIN maintain_limit ml ON ml.limit_type = 1599
		 INNER JOIN #limit_info li ON li.maintain_limit_id = ml.maintain_limit_id AND li.limit_type = 1599
  		 LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency

		WHERE ced.as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''' AND li.maintain_limit_id IS NOT NULL
 	  ) mtm GROUP BY maintain_limit_id ,source_counterparty_id,contract_id 	  
	  ' + CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', source_deal_header_id ' ELSE '' END + '

	   INSERT INTO #limit_info_value(maintain_limit_id,total_value, unit, source_deal_header_id)
		select maintain_limit_id, SUM(total_value), max(unit), NULL from  #limit_info_value_reserve
		Group BY maintain_limit_id

		'
--PRINT(@sql_str)	 
EXEC(@sql_str)

--select * from #limit_info_value_reserve where source_counterparty_id = 205
--select * from #limit_info_value
 

--SET @sql_str=' 
--	insert into  #limit_info_value ( maintain_limit_id,total_value, unit) 
--	select distinct li.maintain_limit_id,ISNULL(mtm.value,0) total_value,mtm.cur_name unit 
--	FROM #limit_info li
--	outer apply
--	(
--	select SUM(und_pnl) value  ,  MAX(sc.currency_name) cur_name              
--	 FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl') + ' sdp 
--	 INNER JOIN #collect_deals cd on sdp.source_deal_header_id=cd.source_deal_header_id 
--				AND cd.maintain_limit_id =li.maintain_limit_id
--	 --INNER JOIN source_price_curve_def spcd  on spcd.source_curve_def_id=sdp.curve_id
--	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id AND sdp.pnl_as_of_date >= sdh.deal_date
--		AND  sdp.pnl_as_of_date ='''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND sdh.deal_date<= '''+CONVERT(VARCHAR(10),@as_of_date,120) +''' AND sdp.term_start >='''+CONVERT(VARCHAR(7),@as_of_date,120) +'-01'' 
--		AND sdh.source_deal_header_id=cd.source_deal_header_id
--		--AND li.party_id=CASE WHEN li.limit_for=20203 THEN ISNULL(spcd.commodity_id,li.party_id) ELSE li.party_id END
--		--AND r.curve_id=ISNULL(li.curve_id,r.curve_id)
--	LEFT JOIN source_currency sc ON sc.source_currency_id = sdp.pnl_currency_id
--	WHERE sdp.pnl_source_value_id = li.curve_source_value_id
--	) mtm	WHERE li.limit_type=1580
--	'
	
--PRINT(@sql_str)
--EXEC(@sql_str)
 

INSERT INTO  #limit_info_value (maintain_limit_id,total_value, unit) 
SELECT DISTINCT li.maintain_limit_id,
	CASE li.limit_type WHEN 1582 THEN  crv.value 
		WHEN 1583 THEN  crv2.value
		WHEN 1584 THEN ISNULL(cvv.value,cvv_pfe.value) 
		WHEN 1585 THEN cvcv.value	
		WHEN 1586 THEN cviv.value 
	ELSE 
		NULL	
	END VALUE,
	CASE li.limit_type WHEN 1582 THEN crv.cur_name 
		WHEN 1583 THEN  crv2.cur_name 
		WHEN 1584 THEN ISNULL(cvv.cur_name, cvv_pfe.cur_name)
		WHEN 1585 THEN cvcv.cur_name	
		WHEN 1586 THEN cviv.cur_name 
	ELSE 
		NULL	
	END cur_name 
 FROM #limit_info li 
OUTER APPLY
(
SELECT DISTINCT [VAR] * COALESCE(spc.curve_value, 1/spc1.curve_value, 1) VALUE, sc.currency_name cur_name
FROM var_results vr
	INNER JOIN maintain_limit ml ON li.maintain_limit_id = ml.maintain_limit_id	
	INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.var_criteria_id
	--INNER JOIN var_measurement_criteria vmc ON vmc.var_criteria_id = vmcd.[id]
	LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = vr.currency_id
		AND spcd.source_currency_to_id = ml.limit_currency
		AND spcd.Granularity = 980
	LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id
		AND spc.as_of_date = vr.as_of_date 
		AND spc.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc.curve_source_value_id = li.curve_source_value_id
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_currency_id = ml.limit_currency
		AND spcd1.source_currency_to_id = vr.currency_id
		AND spcd1.Granularity = 980
	LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id = spc1.source_curve_def_id
		AND spc1.as_of_date = vr.as_of_date 
		AND spc1.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd1.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc1.curve_source_value_id = li.curve_source_value_id	
WHERE vr.as_of_date = @as_of_date
	AND li.limit_type = 1584 
	AND vr.var_criteria_id = li.var_criteria_id
)	cvv

OUTER APPLY
(
SELECT DISTINCT vr.pfe * COALESCE(spc.curve_value, 1/spc1.curve_value, 1) VALUE, sc.currency_name cur_name
FROM pfe_results vr
	INNER JOIN maintain_limit ml ON li.maintain_limit_id = ml.maintain_limit_id
	INNER JOIN limit_header lh on lh.limit_id = ml.limit_id
		AND vr.counterparty_id = lh.counterparty_id	
	INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.criteria_id
	LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = vr.currency_id
		AND spcd.source_currency_to_id = ml.limit_currency
		AND spcd.Granularity = 980
	LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id
		AND spc.as_of_date = vr.as_of_date 
		AND spc.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc.curve_source_value_id = li.curve_source_value_id
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_currency_id = ml.limit_currency
		AND spcd1.source_currency_to_id = vr.currency_id
		AND spcd1.Granularity = 980
	LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id = spc1.source_curve_def_id
		AND spc1.as_of_date = vr.as_of_date 
		AND spc1.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd1.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc1.curve_source_value_id = li.curve_source_value_id	
WHERE vr.as_of_date = @as_of_date
	AND li.limit_type = 1584 
	AND vr.criteria_id = li.var_criteria_id
)	cvv_pfe

OUTER APPLY
(
SELECT DISTINCT [VaRI] * COALESCE(spc.curve_value, 1/spc1.curve_value, 1) VALUE,  sc.currency_name cur_name
FROM var_results vr
	INNER JOIN maintain_limit ml ON li.maintain_limit_id = ml.maintain_limit_id	
	INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.var_criteria_id
	--INNER JOIN var_measurement_criteria vmc ON vmc.var_criteria_id = vmcd.[id]
	LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = vr.currency_id
		AND spcd.source_currency_to_id = ml.limit_currency
		AND spcd.Granularity = 980
	LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id
		AND spc.as_of_date = vr.as_of_date 
		AND spc.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc.curve_source_value_id = li.curve_source_value_id
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_currency_id = ml.limit_currency
		AND spcd1.source_currency_to_id = vr.currency_id
		AND spcd1.Granularity = 980
	LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id = spc1.source_curve_def_id
		AND spc1.as_of_date = vr.as_of_date 
		AND spc1.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd1.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc1.curve_source_value_id = li.curve_source_value_id
WHERE vr.as_of_date = @as_of_date
	AND li.limit_type = 1586 
	AND vr.var_criteria_id = li.var_criteria_id
)	cviv
OUTER APPLY
(
SELECT DISTINCT [VaRC] * COALESCE(spc.curve_value, 1/spc1.curve_value, 1) VALUE, sc.currency_name cur_name
FROM var_results vr
	INNER JOIN maintain_limit ml ON li.maintain_limit_id = ml.maintain_limit_id
	INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.var_criteria_id
	--INNER JOIN var_measurement_criteria vmc ON vmc.var_criteria_id = vmcd.[id]
	LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_currency_id = vr.currency_id
		AND spcd.source_currency_to_id = ml.limit_currency
		AND spcd.Granularity = 980
	LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id
		AND spc.as_of_date = vr.as_of_date 
		AND spc.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc.curve_source_value_id = li.curve_source_value_id
	LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_currency_id = ml.limit_currency
		AND spcd1.source_currency_to_id = vr.currency_id
		AND spcd1.Granularity = 980
	LEFT JOIN source_price_curve spc1 ON spcd1.source_curve_def_id = spc1.source_curve_def_id
		AND spc1.as_of_date = vr.as_of_date 
		AND spc1.maturity_date = (
		                            SELECT TOP 1 maturity_date
		                            FROM   source_price_curve
		                            WHERE  as_of_date = vr.as_of_date
		                                   AND curve_source_value_id = li.curve_source_value_id
		                                   AND source_curve_def_id = spcd1.source_curve_def_id 
		                            ORDER BY maturity_date ASC        
		                        )
		AND spc1.curve_source_value_id = li.curve_source_value_id
WHERE vr.as_of_date = @as_of_date
	AND li.limit_type = 1585 
	AND vr.var_criteria_id = li.var_criteria_id
)	cvcv
OUTER APPLY
(
SELECT  DISTINCT [RAROC1] VALUE,  '%' cur_name
FROM var_results vr
INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.var_criteria_id
--INNER JOIN var_measurement_criteria vmc ON vmc.var_criteria_id = vmcd.[id]
LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
WHERE   vr.as_of_date = @as_of_date
	AND li.limit_type = 1582  
	AND vr.var_criteria_id = li.var_criteria_id
)	crv
OUTER APPLY
(
SELECT DISTINCT [RAROC2] VALUE, '%' cur_name
FROM var_results vr
    INNER JOIN var_measurement_criteria_detail vmcd ON vmcd.[id] = vr.var_criteria_id
    --INNER JOIN var_measurement_criteria vmc ON vmc.var_criteria_id = vmcd.[id]
    LEFT JOIN source_currency sc ON sc.source_currency_id = vr.currency_id
WHERE vr.as_of_date = @as_of_date
	AND li.limit_type=1583  
	AND vr.var_criteria_id=li.var_criteria_id
)	crv2

WHERE li.limit_type NOT IN (1580,1581, 1587, 1588, 1599)


 
 --inserted into #temp_limit_report for generating limit report view in Report manager
SET @sql_str = CASE WHEN OBJECT_ID('tempdb..#temp_limit_report') IS NOT NULL THEN 'INSERT INTO #temp_limit_report ' ELSE '' END + '
	SELECT dbo.FNAHyperLinkText(10181310, lh.limit_name, lh.limit_id) [Limit Group Name],
		dbo.FNAHyperLinkText(10181311, ml.logical_description, ml.maintain_limit_id) [Limit Name],
		sdv2.[code] [Limit For],
		CASE lh.limit_for WHEN 20203 THEN scom.commodity_name 
			WHEN 20204 THEN sc.counterparty_name 
			WHEN 20201 THEN st.trader_name 
		END [Name],
		sdv3.[code] [Limit Type],
		CASE WHEN li.limit_type IN (1587, 1598) AND ISNULL(ml.limit_value, 0) = 0 THEN 
				cast(ISNULL(li.tenor_month_from, 0) AS VARCHAR(50)) + '' ~ '' + cast(li.tenor_month_to AS VARCHAR(50))
			WHEN li.limit_type = 1597 THEN
				CAST(dbo.FNANumberFormat(ISNULL(ml.limit_percentage, 0), ''n'') AS VARCHAR(50)) + '' ~ '' + CAST(dbo.FNANumberFormat(ISNULL(ml.limit_value, 0), ''n'') AS VARCHAR(50))
			ELSE CAST(ISNULL(ml.limit_value, 0) AS VARCHAR(50))		
		END Limit,
		CASE WHEN li.limit_type IN (1587, 1598) AND ISNULL(ml.limit_value, 0) = 0 THEN 
				CASE WHEN lit.min_tenor is null THEN cast(lit.max_tenor AS VARCHAR(50)) 
					ELSE  cast(lit.min_tenor AS VARCHAR) + '' ~ '' + cast(lit.max_tenor AS VARCHAR)  
				END
			WHEN li.limit_type = 1597 THEN
					CAST(dbo.FNANumberFormat(ISNULL(liv.value2, 0), ''n'') AS VARCHAR(50)) + '' ~ '' + CAST(dbo.FNANumberFormat(ISNULL(liv.total_value, 0), ''n'') AS VARCHAR(50))
		ELSE
			CAST(ISNULL(liv.total_value, 0) AS VARCHAR(50))
		END [Total Value],
		CASE WHEN li.limit_type IN (1587, 1598) AND ISNULL(ml.limit_value,0) = 0 THEN NULL
			 WHEN li.limit_type = 1597 THEN NULL
		ELSE ' 
		  + CASE WHEN ISNULL(@deal_level, 'n') = 'n' THEN ' 
				CASE WHEN (ISNULL(ml.limit_value, 0) - ISNULL(liv.total_value, 0)) < (ISNULL(liv.total_value, 0) - ISNULL(ml.min_limit_value, 0)) OR ml.min_limit_value IS NULL THEN 
				(ISNULL(ml.limit_value, 0) - ISNULL(liv.total_value, 0)) ELSE (ISNULL(liv.total_value, 0) - ISNULL(ml.min_limit_value, 0)) END ' 
			ELSE '(ISNULL(ml.limit_value, 0) - ISNULL(liv.total_value, 0))' END + '
		END [Available / Exceed Value],
		CASE li.limit_type 
			WHEN 1587 THEN CASE WHEN ISNULL(ml.limit_value,0)= 0 THEN sdv1.[description] ELSE su.uom_name END
			WHEN 1598 THEN CASE WHEN ISNULL(ml.limit_value,0)= 0 THEN sdv1.[description] ELSE su.uom_name END
			WHEN 1580 THEN scu.currency_name
			WHEN 1585 THEN scu.currency_name
			WHEN 1586 THEN scu.currency_name
			--WHEN 1583 THEN scu.currency_name
			--WHEN 1582 THEN scu.currency_name
			WHEN 1584 THEN scu.currency_name
			ELSE liv.unit
		END [Unit],
		CASE WHEN li.limit_type IN (1587, 1598) AND ISNULL(ml.limit_value, 0) = 0 THEN 
				CASE WHEN lit.min_tenor > ISNULL(ml.tenor_month_from, 0) OR  lit.max_tenor > ISNULL(ml.tenor_month_to, 999999)
				THEN ''Yes'' ELSE ''No'' END
			WHEN li.limit_type = 1597 THEN
				CASE WHEN (liv.value2 > ml.limit_percentage OR liv.value2 < (-1*ml.limit_percentage) ) OR (liv.total_value > ml.limit_value OR liv.total_value < (-1*ml.limit_value) )
				THEN ''Yes'' ELSE ''No'' END
			WHEN li.limit_type IN (1584,1596,1599,1588) AND 1 = ' + CASE WHEN ISNULL(@deal_level, 'n') = 'n' THEN '1' ELSE '2' END + ' THEN	
				CASE WHEN (ISNULL(liv.total_value, 0) >= ISNULL(ml.limit_value, 0))
				THEN ''Yes'' ELSE ''No'' END
		ELSE
			CASE WHEN (ISNULL(ml.limit_value, 0) < 0 AND  ISNULL(liv.total_value, 0) < 0) OR (ISNULL(ml.limit_value, 0) > 0 AND ISNULL(liv.total_value, 0) > 0) THEN 
				CASE WHEN ABS(ISNULL(liv.total_value, 0)) <= ABS(ISNULL(ml.limit_value, 0)) THEN ''No'' ELSE ''Yes'' END
				ELSE ''No'' 
			END 
		END [Limit Exceed],
		ISNULL(ml.min_limit_value, 0) min_limit_value,
		CASE WHEN li.limit_type IN (1580,1584,1596,1599,1588) AND ml.min_limit_value IS NOT NULL AND 1 = ' + CASE WHEN ISNULL(@deal_level, 'n') = 'n' THEN '1' ELSE '2' END + ' THEN	
				CASE WHEN (ISNULL(liv.total_value, 0) <= ISNULL(ml.min_limit_value, -99999999))
				THEN ''Yes'' ELSE ''No'' END
		ELSE NULL
		END [Min Limit Exceed]

		' +  CASE WHEN ISNULL(@deal_level, 'n') = 'y' THEN ', ISNULL(liv.source_deal_header_id, lit.source_deal_header_id) source_deal_header_id ' ELSE '' END + '
		 
		
	 FROM limit_header lh  
		INNER JOIN maintain_limit ml on lh.limit_id = ml.limit_id 
		INNER JOIN #limit_info li on li.maintain_limit_id = ml.maintain_limit_id
		LEFT JOIN #limit_info_value liv on liv.maintain_limit_id = ml.maintain_limit_id AND (liv.total_value IS NOT NULL OR liv.unit IS NOT NULL)
		LEFT JOIN static_data_value sdv1 on sdv1.value_id = ml.tenor_granularity 
			AND ml.limit_type IN (1587, 1598)
		LEFT JOIN source_commodity scom on scom.source_commodity_id = lh.commodity
		LEFT JOIN source_counterparty sc on sc.source_counterparty_id = lh.counterparty_id
		LEFT JOIN source_traders st on st.source_trader_id = lh.trader_id
		LEFT JOIN static_data_value sdv2 on sdv2.value_id = lh.limit_for
		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id = ml.curve_id
		LEFT JOIN source_uom su on su.source_uom_id = ml.limit_uom
		LEFT JOIN source_currency scu on scu.source_currency_id = ml.limit_currency
		LEFT JOIN static_data_value sdv3 on sdv3.value_id = ml.limit_type
		LEFT JOIN #limit_info_tenor lit on lit.maintain_limit_id = li.maintain_limit_id
	' + CASE WHEN ISNULL(NULLIF(@show_exception_only, ''), 'n') = 'n' THEN '' ELSE ' 
	WHERE CASE WHEN li.limit_type IN(1581, 1587, 1588, 1598) AND ISNULL(ml.limit_value,0)= 0 THEN 
		CASE WHEN lit.min_tenor > ISNULL(ml.tenor_month_from, 0) OR  lit.max_tenor > ISNULL(ml.tenor_month_to, 999999)
		THEN ''Yes'' ELSE ''No'' END
		WHEN li.limit_type IN(1597) THEN
			CASE WHEN (liv.value2 > ml.limit_percentage OR liv.value2 < (-1*ml.limit_percentage) ) OR (liv.total_value > ml.limit_value OR liv.total_value < (-1*ml.limit_value) )
				THEN ''Yes'' ELSE ''No'' END
		WHEN li.limit_type IN (1580,1584,1596,1599,1588) AND 1 = ' + CASE WHEN ISNULL(@deal_level, 'n') = 'n' THEN '1' ELSE '2' END + ' THEN	
				CASE WHEN (ISNULL(liv.total_value, 0) >= ISNULL(ml.limit_value, 0)) OR (ISNULL(liv.total_value, 0) <= ISNULL(ml.min_limit_value, -99999999))
				THEN ''Yes'' ELSE ''No'' END
	ELSE
		CASE WHEN (ISNULL(ml.limit_value,0) < 0 AND  ISNULL(liv.total_value, 0) < 0) OR (ISNULL(ml.limit_value, 0) > 0 AND  ISNULL(liv.total_value, 0) > 0) THEN 
			CASE WHEN ABS(ISNULL(liv.total_value, 0)) <= ABS(ISNULL(ml.limit_value, 0)) THEN ''No'' ELSE ''Yes'' END
		ELSE ''No'' END 
	END = ''Yes'''
	END
exec spa_print @sql_str
EXEC(@sql_str)
