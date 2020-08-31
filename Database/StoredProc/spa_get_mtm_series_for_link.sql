
IF OBJECT_ID('[dbo].[spa_get_mtm_series_for_link]') IS NOT null
	drop proc [dbo].[spa_get_mtm_series_for_link]
GO

-- EXEC spa_get_mtm_series_for_link 93,'2009-08-31'
CREATE PROCEDURE [dbo].[spa_get_mtm_series_for_link] 
	@rel_id INT, 
	@as_of_date VARCHAR(20),

	------- Batch Process -------
	@batch_process_id VARCHAR(50)=null,	
	@batch_report_param VARCHAR(1000)=NULL

AS
-------UNCOMMENT THE FOLLOWING TO TEST
/*

--???????? ssbm.effective_start_date
DROP TABLE #sdd
DROP TABLE #cum_pnl

DECLARE @rel_id int
DECLARE @as_of_date VARCHAR(20)

SET @rel_id = '202'
SET @as_of_date = '2006-01-31'

--*/
-------END OF TEST

--################## for batch process
	DECLARE @str_batch_table VARCHAR(MAX),@st_sql VARCHAR(MAX)
	SET @str_batch_table=''
	 
		IF @batch_process_id is not null      
			SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         
	
	--###################

CREATE TABLE #cum_pnl (
	link_id INT,
	source_deal_header_id INT,
	as_of_date DATETIME,
	und_PNL FLOAT,
	und_rel_PNL FLOAT,
	dis_PNL FLOAT,
	dis_rel_PNL FLOAT,
	hedge_or_item VARCHAR(1) COLLATE DATABASE_DEFAULT,
	link_effective_date DATETIME, 
	header_link_effective_date DATETIME, 
	detail_link_effective_date DATETIME,
	Source VARCHAR(30) COLLATE DATABASE_DEFAULT
)

--SELECT * FROM calcprocess_deals cd INNER JOIN #links l ON cd.

CREATE TABLE #sdd (
	link_id INT,
	source_deal_header_id INT, 
	hedge_or_item varchar(1) COLLATE DATABASE_DEFAULT,
	percentage_included float,
	link_effective_date datetime,
	deal_date DATETIME,
	header_link_effective_date DATETIME,
	detail_link_effective_date DATETIME
)

IF @rel_id<0 
BEGIN
	INSERT INTO #sdd (
		link_id ,source_deal_header_id,hedge_or_item ,percentage_included ,link_effective_date ,deal_date ,header_link_effective_date ,detail_link_effective_date )
	SELECT	@rel_id, sdh.source_deal_header_id,	CASE  ISNULL(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) WHEN 400 THEN 'h' 
			WHEN 401 THEN 'i' END 	hedge_or_item, 1 percentage_included, 
			dbo.FNAMaxDate(COALESCE(ssbm.effective_start_date, sdh.deal_date), sdh.deal_date) AS link_effective_date,
			sdh.deal_date, ssbm.effective_start_date header_link_effective_date, ISNULL(ssbm.effective_start_date, '1900-01-01') detail_link_effective_date

	FROM	fas_books fb  INNER join
			source_system_book_map ssbm ON ssbm.fas_book_id=fb.fas_book_id AND fb.fas_book_id=ABS(@rel_id)
			INNER JOIN source_deal_header sdh ON 
				ssbm.source_system_book_id1=sdh.source_system_book_id1
				AND ssbm.source_system_book_id2=sdh.source_system_book_id2
				AND ssbm.source_system_book_id3=sdh.source_system_book_id3
				AND ssbm.source_system_book_id4=sdh.source_system_book_id4
END
ELSE
BEGIN
	INSERT INTO #sdd (link_id ,source_deal_header_id,hedge_or_item ,percentage_included ,link_effective_date ,deal_date ,header_link_effective_date ,detail_link_effective_date )
	SELECT	l.link_id, fld.source_deal_header_id,hedge_or_item, percentage_included, 
			dbo.FNAMaxDate(COALESCE(fld.effective_date, l.link_effective_date, sdh.deal_date), sdh.deal_date) AS link_effective_date,
			sdh.deal_date, l.link_effective_date header_link_effective_date, ISNULL(fld.effective_date, '1900-01-01') detail_link_effective_date
	FROM	fas_link_header l inner join fas_link_detail fld ON l.link_id=fld.link_id AND fld.link_id=@rel_id
	    INNER JOIN	source_deal_header sdh ON sdh.source_deal_header_id = fld.source_deal_header_id 
END

DECLARE @first_day_month_Date  VARCHAR(10)
SET @first_day_month_Date=LEFT(@as_of_date,8)+'01'
SET @st_sql='
insert into #cum_pnl
(
	link_id,
	source_deal_header_id,
	as_of_date,
	und_PNL,
	und_rel_PNL,
	dis_PNL,
	dis_rel_PNL,
	hedge_or_item,
	link_effective_date, 
	header_link_effective_date , 
	detail_link_effective_date ,
	Source
)
SELECT '+ cast(@rel_id AS VARCHAR) + ' Link_id,cd.source_deal_header_id Deal_id,'''+ @as_of_date + ''' as_of_date,
	sum(CASE WHEN ((cd.link_effective_date <= cd.as_of_date) OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then cd.final_und_pnl_remaining else 0 end) und_PNL,
	sum(CASE WHEN ((cd.link_effective_date <= cd.as_of_date) OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then cd.final_und_pnl_remaining else 0 end*cd.percentage_included) und_rel_PNL,
	sum(CASE WHEN ((cd.link_effective_date <= cd.as_of_date) OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then cd.final_dis_pnl_remaining   else 0 end) dis_PNL,
	sum(CASE WHEN ((cd.link_effective_date <= cd.as_of_date) OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then cd.final_dis_pnl_remaining   else 0 end*cd.percentage_included) dis_rel_PNL,
	max(sdd.hedge_or_item) hedge_or_item ,max(cd.link_effective_date) link_effective_date,max(sdd.header_link_effective_date) header_link_effective_date , max(sdd.detail_link_effective_date) detail_link_effective_date,''Actual'' Source 
FROM ' + dbo.FNAGetProcessTableName(@first_day_month_Date, 'calcprocess_deals') + ' cd INNER JOIN #sdd sdd ON cd.source_deal_header_id=sdd.source_deal_header_id AND cd.as_of_date='''+@as_of_date+''' AND cd.term_start> '''+@as_of_date +'''
	 AND cd.link_id='+cast(@rel_id AS VARCHAR)+ ' 
GROUP BY cd.source_deal_header_id
'
EXEC spa_print @st_sql
EXEC(@st_sql)

SET @st_sql='
insert into #cum_pnl
(
	link_id,
	source_deal_header_id,
	as_of_date,
	und_PNL,
	und_rel_PNL,
	dis_PNL,
	dis_rel_PNL,
	hedge_or_item,
	link_effective_date, 
	header_link_effective_date , 
	detail_link_effective_date ,
	Source
)
SELECT ' + CAST(@rel_id  AS VARCHAR)+' link_id,sdp.source_deal_header_id,''' + cast(@as_of_date AS VARCHAR) +''' , 
	sum(CASE WHEN ((sdd.link_effective_date <= '''+CAST(@as_of_date AS VARCHAR) +''') OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then sdp.und_pnl else 0 end) und_PNL,
	sum(CASE WHEN ((sdd.link_effective_date <= '''+CAST(@as_of_date AS VARCHAR) +''') OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then sdp.und_pnl else 0 end*sdd.percentage_included) und_rel_PNL,
	sum(CASE WHEN ((sdd.link_effective_date <= '''+CAST(@as_of_date AS VARCHAR) +''') OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then sdp.dis_pnl else 0 end) dis_PNL,
	sum(CASE WHEN ((sdd.link_effective_date <= '''+CAST(@as_of_date AS VARCHAR) +''') OR (sdd.header_link_effective_date = sdd.detail_link_effective_date)) then sdp.dis_pnl else 0 end*sdd.percentage_included) dis_rel_PNL,
	max(sdd.hedge_or_item) hedge_or_item,
	max(sdd.link_effective_date) link_effective_date, 
	max(sdd.header_link_effective_date) header_link_effective_date, 
	max(sdd.detail_link_effective_date) detail_link_effective_date,
	''Recreated'' Source
FROM #sdd sdd INNER JOIN ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl') + ' sdp ON sdd.source_deal_header_id=sdp.source_deal_header_id 
		AND sdp.pnl_as_of_date='''+CAST(@as_of_date AS VARCHAR) +'''  AND sdp.term_start>'''+ CAST(@as_of_date AS VARCHAR) +''' AND (sdp.pnl_source_value_id=4500 OR sdp.pnl_source_value_id=775)
LEFT JOIN #cum_pnl cp ON sdd.source_deal_header_id =cp.source_deal_header_id
WHERE cp.source_deal_header_id IS null
GROUP BY sdp.source_deal_header_id
'

--SELECT sum(cd.final_und_pnl_remaining) und,sum(cd.final_dis_pnl_remaining) dis FROM calcprocess_deals cd where link_id=@rel_id AND cd.as_of_date=@as_of_date
--GROUP BY cd.source_deal_header_id
DECLARE @Sql_final VARCHAR(MAX)
SET @Sql_final= 'SELECT link_id [Link ID], dbo.fnadateformat(as_of_date) [As of Date], source_deal_header_id [Deal ID], round(und_PNL,2) [Und PNL],
				round(und_rel_PNL,2) [Und Rel PNL],
				round(dis_PNL,2) [Dis PNL],
				round(dis_rel_PNL,2) [Dis Rel PNL],
				hedge_or_item [Hedge/Item],
				dbo.fnadateformat(link_effective_date) [Link Eff Date], Source' 
				+ @str_batch_table +
				' FROM #cum_pnl '
--PRINT @Sql_final
EXEC (@Sql_final)

--SELECT * FROM source_deal_pnl

		--*****************FOR BATCH PROCESSING**********************************            
 		IF  @batch_process_id is not null        
		BEGIN
			DECLARE @report_name VARCHAR(100)        	
			
			SET @report_name='Detailed Cum PNL Series Report'
			

			SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
			EXEC(@str_batch_table)        
			
			SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_mtm_series_for_link',@report_name)         
			EXEC(@str_batch_table) 

		END        
		--******************************************************************** 