IF OBJECT_ID(N'[dbo].[spa_trayport_deal_term_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_trayport_deal_term_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Used to generate term_end and term start for given value as defined in term mapping.
	Also used for splitting deal into multiple terms

	Parameters
	@process_table	:	Process table containing import data of deal.
*/

CREATE PROCEDURE [dbo].[spa_trayport_deal_term_mapping]
	@process_table VARCHAR(200)
AS


SET NOCOUNT ON;

DECLARE @sql VARCHAR(MAX)

IF OBJECT_ID('tempdb..#temp_import_term_data') IS NOT NULL
			DROP TABLE #temp_import_term_data
CREATE TABLE #temp_import_term_data(
	deal_id NVARCHAR(2000),
	term_code NVARCHAR(1000)
)

SET @sql = 'IF OBJECT_ID(''tempdb..#temp_import_data'') IS NOT NULL
			DROP TABLE #temp_import_data

		DECLARE @counter INT = 0
		SELECT temp.*, tbl.n row_num, tbl.m [date_sep]
		, CASE WHEN tbl.n = 2 THEN CASE WHEN buy_sell_flag = ''Buy'' THEN ''Sell'' ELSE ''Buy'' END ELSE buy_sell_flag END mod_buy_sell_flag
		INTO #temp_import_data
		FROM ' + @process_table + ' temp
		OUTER APPLY(
			SELECT CASE WHEN CHARINDEX(''/'',temp.curve_id) <> 0 AND NULLIF(temp.term_start,''NULL'') IS NOT NULL AND NULLIF(temp.term_end,''NULL'') IS NOT NULL THEN 
								CASE WHEN [n] <=2 THEN 1 ELSE 2 END
				   ELSE [n] END [n],
				   CASE WHEN n%2 <> 0 THEN 1 ELSE 2 END [m]
				   
			from seq
			WHERE n <= CASE WHEN CHARINDEX(''/'',temp.curve_id) <> 0 AND NULLIF(temp.term_start,''NULL'') IS NOT NULL AND NULLIF(temp.term_end,''NULL'') IS NOT NULL THEN 4
							WHEN CHARINDEX(''/'',temp.curve_id) <> 0 OR (NULLIF(temp.term_start,''NULL'') IS NOT NULL AND NULLIF(temp.term_end,''NULL'') IS NOT NULL) THEN 2
					ELSE 0 END
		) tbl

		UPDATE #temp_import_data
		SET term_start = CASE WHEN temp.[date_sep] = 1 THEN ISNULL(NULLIF(temp.term_start,''NULL''),temp.term_end) ELSE ISNULL(NULLIF(temp.term_end,''NULL''),temp.term_start) END 
			,term_end = NULL
			,curve_id = CASE WHEN CHARINDEX(''/'',temp.curve_id) <> 0 AND  temp.row_num = 1 THEN SUBSTRING(temp.curve_id,0, CHARINDEX(''/'',temp.curve_id))
						WHEN CHARINDEX(''/'',temp.curve_id) <> 0 AND  temp.row_num = 2 THEN SUBSTRING(temp.curve_id, CHARINDEX(''/'', temp.curve_id) + 1, LEN(temp.curve_id))
						ELSE temp.curve_id
						END
			,leg = CASE WHEN  CHARINDEX(''/'',temp.curve_id) <> 0 THEN temp.row_num ELSE temp.leg END
			,buy_sell_flag = CASE WHEN CHARINDEX(''/'',temp.curve_id) <> 0 AND  temp.date_sep = 2 AND temp.term_end IS NOT NULL THEN CASE WHEN mod_buy_sell_flag = ''Buy'' THEN ''Sell'' ELSE ''Buy'' END ELSE mod_buy_sell_flag END
			,fixed_price = CASE WHEN  CHARINDEX(''/'',temp.curve_id) <> 0 THEN ''0'' ELSE temp.fixed_price END
			, @counter = ixp_source_unique_id = @counter + 1
			, deal_date = CASE WHEN  CASE WHEN temp.[date_sep] = 1 THEN ISNULL(NULLIF(temp.term_start,''NULL''),temp.term_end) ELSE ISNULL(NULLIF(temp.term_end,''NULL''),temp.term_start) END = ''WD'' THEN deal_date ELSE dbo.FNAGetLOCALTime(deal_date, 15) END
		FROM #temp_import_data temp

		ALTER TABLE #temp_import_data
		DROP COLUMN row_num

		ALTER TABLE #temp_import_data
		DROP COLUMN [date_sep]

		ALTER TABLE #temp_import_data
		DROP COLUMN [mod_buy_sell_flag]

		DELETE FROM ' + @process_table + '

		INSERT INTO ' + @process_table + '
		SELECT *
		FROM #temp_import_data

		INSERT INTO #temp_import_term_data
		SELECT deal_id,term_start
		FROM #temp_import_data
'
EXEC(@sql)

IF OBJECT_ID('tempdb..#week_more') IS NOT NULL
	DROP TABLE #week_more
IF OBJECT_ID('tempdb..#temp_term') IS NOT NULL
	DROP TABLE #temp_term

CREATE TABLE #week_more(
		block_value_id INT,
		weekday INT,
		val INT
	)

INSERT #week_more(weekday, val)
	SELECT 8, 0
	UNION
	SELECT 9, 0
	UNION
	SELECT 10, 0
	UNION
	SELECT 11, 0

CREATE TABLE #temp_term(  
		sno INT IDENTITY(1, 1),
		[Terms] [DATETIME] NULL,  
		[active_date] [INT] NOT NULL,  
		[relative_term_start] [DATETIME] NULL,  
		[relative_term_end] [DATETIME] NULL,  
		[term_start] [DATETIME] NULL,  
		[term_end] [DATETIME] NULL,  
		[deal_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL ,  
		[date_or_block] [char](1) NULL,
		no_of_days INT NULL ,
		old_term_date NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	) ON [PRIMARY]  
					    
	SET @sql = '    
		INSERT #temp_term([Terms]  
				,[active_date]  
				,[relative_term_start]  
				,[relative_term_end]  
				,[term_start]  
				,[term_end]  
				,[deal_id]  
				,[date_or_block]
				,no_of_days 
				,old_term_date)
		SELECT CASE WHEN t.date_or_block=''b'' THEN   
			DATEADD(d, CASE WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date))<0 THEN  
			(weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)))  
			ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)) END,DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date))  
			ELSE NULL END Terms,  
			ISNULL(CASE WHEN hg.hol_date IS NOT NULL THEN   
			CASE WHEN ISNULL(t.holiday_include_exclude, ''i'')=''i'' THEN 1 ELSE 0 END   
			ELSE val END,1) active_date,  
			CASE WHEN t.date_or_block=''r'' THEN DATEADD(d,ISNULL(t.relative_days,0),ts.deal_date) ELSE NULL END relative_term_start,  
			CASE WHEN t.date_or_block=''r'' THEN  DATEADD(d,ISNULL(t.no_of_days,0),DATEADD(d,ISNULL(t.relative_days,0),ts.deal_date)) ELSE NULL END relative_term_end,  
			CASE WHEN t.date_or_block=''m'' THEN  dbo.FNAGetNextAvailDate(CAST(DATEADD(d,ISNULL(t.relative_days,1),ts.deal_date) AS DATE),1,t.holiday_calendar_id )
				ELSE  dbo.FNAGetNextAvailDate(t.term_start,1,t.holiday_calendar_id )  END term_start,
			CASE WHEN t.date_or_block=''m'' THEN  dbo.FNAGetTermEndDate(''m'',ts.deal_date,0) ELSE t.term_end END term_end,
			ts.deal_id,t.date_or_block,t.no_of_days,ts.term_start    
		FROM ' + @process_table + '  ts JOIN term_map_detail t   
		ON ts.term_start = t.term_code 
		OUTER  apply (
						SELECT  block_value_id,weekday,val FROM (
							SELECT w.block_value_id,tw.weekday AS weekday,w.val FROM #week_more tw JOIN working_days w
							ON tw.weekday-7=w.weekday AND w.block_value_id=t.working_day_id
							UNION ALL 
							SELECT block_value_id,weekday,val FROM dbo.working_days 
							WHERE block_value_id=t.working_day_id
						) a
		)wd 
		LEFT OUTER JOIN dbo.holiday_group hg  
			ON CAST(DATEADD(d, CASE 
	 			WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date))<0 
	 				THEN  (weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)))  
					ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)) END, DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)) AS DATE) = hg.hol_date   
			AND hol_group_value_id=t.holiday_calendar_id  
		WHERE CASE WHEN t.date_or_block=''b'' THEN  DATEADD(d, CASE WHEN weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date))<0 THEN  
			(weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)))  
			ELSE weekday-dbo.FNARWeekDay(DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date)) END,DATEADD(wk,ISNULL(t.relative_days,0),ts.deal_date))  
			ELSE DATEADD(d,1,ts.deal_date)  END > ts.deal_date 
		ORDER BY terms  
	'  
	--PRINT(@sql)  

	EXEC (@sql)  
	--SELECT * FROM #temp_term
	/*BOM Term start = Trade date + 2 days	
	UNLESS Trade date + 2 days = sunday, IN that CASE Term start = Trade date + 3 days (= monday)
	*/	
										
	UPDATE #temp_term
	SET term_start = CASE WHEN DATEPART(w, term_start) = 1 THEN DATEADD(d, 1, term_start) ELSE term_start END
	WHERE date_or_block = 'm'		
					 					
	DECLARE @first_1 INT, @last_0 INT, @no_of_days INT, @deal_id VARCHAR(100)
	
	DECLARE  cur1 cursor FOR
		SELECT DISTINCT deal_id 
		FROM #temp_term 
	OPEN cur1	
	FETCH NEXT FROM cur1 INTO @deal_id
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT TOP 1 @first_1 = sno, 
					@no_of_days=no_of_days  
		FROM #temp_term t 
		WHERE deal_id = @deal_id 
			AND active_date = 1 
		ORDER BY sno 
		
		SELECT TOP 1 @last_0 = sno 
		FROM #temp_term t 
		WHERE deal_id = @deal_id 
			AND  active_date = 0 
			AND sno > @first_1 
		ORDER BY sno 

		IF @last_0 IS NULL 
			SELECT @last_0 = MAX(sno) + 1 
			FROM #temp_term t 
			WHERE deal_id = @deal_id 
				AND  sno > @first_1
									
		DELETE #temp_term 
		WHERE sno NOT IN (
							SELECT sno  
							FROM #temp_term 
							WHERE deal_id = @deal_id 
								AND  (sno >= @first_1 AND sno < isNUll(@last_0, @first_1))
						) 
		AND EXISTS(SELECT * FROM #temp_term  WHERE deal_id = @deal_id AND  (sno >=@first_1 AND sno <isNUll(@last_0, @first_1)))
		AND terms IS NOT NULL AND deal_id = @deal_id
					
					
		IF ISNULL(@no_of_days, 0) > 0
		BEGIN
			EXEC('DELETE  #temp_term WHERE sno not IN (SELECT TOP ' + @no_of_days +' sno FROM #temp_term WHERE  deal_id = ''' + @deal_id+''' ORDER by active_date DESC,terms) AND   deal_id = ''' + @deal_id+'''')
		END 
				
	FETCH NEXT FROM cur1 INTO @deal_id	
	END
	CLOSE cur1
	DEALLOCATE cur1
	 				
	SET @sql = '  
		UPDATE ' + @process_table + ' 
			SET term_start = CONVERT(VARCHAR,ht.term_start,120) , 
				term_end = CONVERT(VARCHAR,ht.term_end,120),
				deal_date = CASE WHEN titd.term_code = ''WD'' THEN dbo.FNAGetLOCALTime(deal_date, 15) ELSE deal_date END
		FROM ' + @process_table + ' t 
		INNER JOIN #temp_import_term_data titd
			ON titd.deal_id = t.deal_id
		INNER JOIN (SELECT deal_id
					,MIN(CASE WHEN date_or_block=''b'' THEN terms  
							  WHEN date_or_block=''r'' THEN relative_term_start   
							  WHEN date_or_block IN (''d'', ''m'') THEN term_start   
						 ELSE NULL  
						END ) term_start
					,MAX(CASE WHEN date_or_block=''b'' THEN terms  
							  WHEN date_or_block=''r'' THEN relative_term_end  
							  WHEN date_or_block IN (''d'', ''m'') THEN term_end  ELSE NULL  
					END) term_end
					,old_term_date 
			FROM #temp_term 
			WHERE [active_date]=1 
			GROUP BY deal_id,old_term_date
			) ht ON t.deal_id=ht.deal_id  AND ht.old_term_date = t.term_start 
		--WHERE  t.action IN (''INSERT'', ''UPDATE'')  
		'   
	--PRINT(@sql)  
EXEC (@sql)  