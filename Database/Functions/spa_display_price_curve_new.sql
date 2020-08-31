IF OBJECT_ID(N'[dbo].[spa_display_price_curve]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_display_price_curve

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2015-07-12
-- EXEC spa_display_price_curve 's',NULL,'2556,2557,2559','4500,10639,4505,10638', '2014-01-01','2014-6-01', '2014-01-01','2014-06-01','y','s',4,'8DF98CDD_D6A5_4144_A8D1_B2FD0E578AAB'
-- EXEC spa_display_price_curve 'i','<Root object_id="51"><GridGroup><Grid grid_id=source_price_curve><GridRow  source_curve_def_id="" maturity_date = ""></GridRow></Grid></GridGroup></Root>'	
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_display_price_curve]
	@flag CHAR(1) = 's',
	@xml XML= NULL,
	@source_price_curve VARCHAR(max) = NULL,
	@curve_source_value VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(10) = NULL,
	@as_of_date_to VARCHAR(10) = NULL,
	@tenor_from VARCHAR(10) = NULL,
	@tenor_to VARCHAR(10) = NULL,
	@ask_bid CHAR(1) = 'y',
	@forward_settle CHAR(1) = NULL,
	@round_value VARCHAR(10) = 4,
	@process_id VARCHAR(200) = NULL
AS
BEGIN
SET NOCOUNT ON
/*TEST DATA -- 
DECLARE @flag CHAR(1) = 's'
DECLARE @xml XML = ''
DECLARE @source_price_curve VARCHAR(max) = '2556,2557,2559,2560,2563,2572,2615'
DECLARE @curve_source_value VARCHAR(1000) ='4500,10639,4505,10638'
DECLARE @as_of_date_from VARCHAR(10) = '2014-01-01'
DECLARE @as_of_date_to VARCHAR(10) = '2014-12-10'
DECLARE @tenor_from VARCHAR(10) = '2014-01-01'
DECLARE @tenor_to VARCHAR(10) = '2014-12-10'
DECLARE @ask_bid CHAR(1) = 'y'
DECLARE @forward_settle CHAR(1) = 's'
DECLARE @round_value VARCHAR(10)  = '2'
DECLARE @process_id VARCHAR(200) ='EB91D362_8CBC_4844_82F4_9F931866647A'--'56D40468_C2B2_43C8_BCD3_7A2972F06FC6'
SET  @xml = '<Root object_id="51"><GridGroup><Grid grid_id="source_price_curve"><GridRow  source_curve_def_id="" maturity_date = ""></GridRow></Grid></GridGroup></Root>'	
PRINT @source_price_curve
--*/

DECLARE @header_detail CHAR(1)
DECLARE @select_sql VARCHAR(MAX)
DECLARE @where_sql VARCHAR(MAX)
DECLARE @order_sql VARCHAR(1000)
IF @process_id IS NULL 
BEGIN 
	SET @header_detail = 'h' 
	SET @process_id = dbo.FNAGetNewID()
	print @process_id
END

DECLARE @curve_source_list VARCHAR(5000)  = ''
DECLARE @curve_source_column_list VARCHAR(max)  = ''
DECLARE @pivot_query_sql VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql1 VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql2 VARCHAR(MAX) = '' 
DECLARE @column_title_ask VARCHAR(MAX) = ''
DECLARE @column_title_bid VARCHAR(MAX) = '' 
DECLARE @column_title_mid VARCHAR(MAX) = ''
DECLARE @final_query VARCHAR(MAX) = ''
DECLARE @pivot_ask VARCHAR(MAX)=''
DECLARE @hourly_value CHAR(1)
DECLARE @colum_concat VARCHAR(MAX)
DECLARE @final_query_settle VARCHAR(MAX) = ''
DECLARE @process_table VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list',dbo.FNADBUser(),@process_id)
DECLARE @process_table_ask VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_ask',dbo.FNADBUser(),@process_id)
DECLARE @process_table_bid VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_bid',dbo.FNADBUser(),@process_id)
DECLARE @process_table_mid VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_mid',dbo.FNADBUser(),@process_id)
DECLARE @main_process_table VARCHAR(500) = dbo.FNAProcessTableName('Price_curve_main',dbo.FNADBUser(),@process_id)
DECLARE @grid_xml_table_name VARCHAR(500) = ''
SET @main_process_table = @main_process_table + '_forward'
DECLARE @table_name VARCHAR(1000) =''
DECLARE @settled_table_name VARCHAR(500) = dbo.FNAProcessTableName('Price_curve_main',dbo.FNADBUser(),@process_id)
SELECT @table_name =  'Price_curve_main'+'_'+CAST(dbo.FNADBUser() AS VARCHAR(200))+'_'+@process_id +'_forward'
SET @settled_table_name = @settled_table_name + '_settled'
DECLARE @table_name_settled VARCHAR(200)
SET @table_name_settled = 'Price_curve_main'+'_'+CAST(dbo.FNADBUser() AS VARCHAR(200))+'_'+@process_id +'_settled'

DECLARE @header_query VARCHAR(MAX) = ''
DECLARE @desc VARCHAR(500) = ''

IF OBJECT_ID(N'tempdb..#price_list') IS NOT NULL
					DROP TABLE #price_list
				IF OBJECT_ID(N'tempdb..#column_header_list') IS NOT NULL
					DROP TABLE #column_header_list
				IF OBJECT_ID(N'tempdb..#price_curve_column_header') IS NOT NULL
					DROP TABLE #price_curve_column_header
				IF OBJECT_ID(N'tempdb..#price_curve_pivt') IS NOT NULL
					DROP TABLE #price_curve_pivt
				IF OBJECT_ID(N'tempdb..#price_curve_ask') IS NOT NULL
					DROP TABLE #price_curve_ask
				IF OBJECT_ID(N'tempdb..#price_curve_bid') IS NOT NULL
					DROP TABLE #price_curve_bid
				IF OBJECT_ID(N'tempdb..#price_curve_mid') IS NOT NULL
					DROP TABLE #price_curve_mid
				IF OBJECT_ID(N'tempdb..#bid') IS NOT NULL
					DROP TABLE #bid
				IF OBJECT_ID(N'tempdb..#ask') IS NOT NULL
					DROP TABLE #ask
				IF OBJECT_ID(N'tempdb..#mid') IS NOT NULL
					DROP TABLE #mid
				IF OBJECT_ID(N'tempdb..#overall') IS NOT NULL
					DROP TABLE #overall
				IF OBJECT_ID(N'tempdb..#curve_source_value_list ') IS NOT NULL
					DROP TABLE #curve_source_value_list
				IF OBJECT_ID(N'tempdb..#source_price_curve_list ') IS NOT NULL
					DROP TABLE #source_price_curve_list
	

IF @flag = 's'
BEGIN
		IF @header_detail = 'h' 
		BEGIN
				SET @where_sql = ' WHERE 1 = 1'
				
		CREATE TABLE #source_price_curve_list(
			rowID int not null identity(1,1),
			price_curve_id INT,
			UNIQUE(price_curve_id) 
		)
				
		CREATE TABLE #curve_source_value_list(
		rowID int not null identity(1,1),
		curve_source_id INT
		UNIQUE(curve_source_id)
		)

		CREATE TABLE #overall( 
			value VARCHAR(1000),
			as_of_date VARCHAR(20),
			ask_bid VARCHAR(20),
			curve_name VARCHAR(50)
		)
		CREATE TABLE #price_curve_column_header(	
				row_id INT IDENTITY(1,1),
				source_curve_def_id INT,
				curve_name VARCHAR(100),
				curve_value FLOAT,
				as_of_date VARCHAR(12),
				maturity_date VARCHAR(12),
				curve_source_value_id INT,
				code VARCHAR(200),
				ask FLOAT,
				column_header_ask VARCHAR(500),
				bid Float,
				column_header_bid VARCHAR(500),
				mid FLOAT,
				column_header_mid VARCHAR(500),
				column_header varchar(500),
				granularity VARCHAR(100),
				hourly VARCHAR(20),
				forward_settle CHAR(1)
		)

		IF @source_price_curve IS NOT NULL
			BEGIN	
				INSERT INTO #source_price_curve_list(price_curve_id)
				SELECT CAST(Item AS INT) price_curve_id FROM  dbo.SplitCommaSeperatedValues(@source_price_curve)
			END
	 
		SELECT  @hourly_value = 1 
			FROM #source_price_curve_list s INNER JOIN source_price_curve_def spcd 
			ON spcd.source_curve_def_id = s.price_curve_id
		WHERE spcd.granularity  IN (982,989,987)

		IF @curve_source_value IS NOT NULL
			BEGIN	
				INSERT INTO #curve_source_value_list(curve_source_id)
				SELECT CAST(Item AS INT) price_curve_id FROM  dbo.SplitCommaSeperatedValues(@curve_source_value)
			END	

		Select @curve_source_list = @curve_source_list+CASE WHEN @curve_source_list = '' THEN '['+ CAST(code AS VARCHAR(100))+']' ELSE 
		','+'['+CAST(code AS VARCHAR(100))+']' END 
		FROM #curve_source_value_list csvl INNER JOIN static_data_value sdv 
		ON sdv.value_id = csvl.curve_source_id AND sdv.type_id = 10007

		SET @select_sql = ' INSERT INTO #price_curve_column_header(source_curve_def_id,curve_name,curve_value,as_of_date,maturity_date,curve_source_value_id,code'+CASE WHEN @ask_bid = 'y' THEN ',ask,column_header_ask,bid,column_header_bid,mid,column_header_mid' ELSE ''END+',column_header,granularity'+CASE WHEN ISNULL(@hourly_value,0)=1 THEN ',[hourly]' ELSE ''END +',forward_settle)
								SELECT spcd.source_curve_def_id,spcd.curve_name,ROUND(spc.curve_value,'+@round_value+') as curve_value,Convert(VARCHAR(12),spc.as_of_date,101),Convert(VARCHAR(12),spc.maturity_date,101)
								,spc.curve_source_value_id,sdv.code'
								+ CASE WHEN @ask_bid = 'y' THEN ',ROUND(spc.ask_value,'+@round_value+
								') As ask_value,Convert(VARCHAR(12),spc.as_of_date,101)'+'+'+''''+'::'+''''+'+'+'spcd.curve_name'+'+'+''''+'::'+''''+'+'+'sdv.code'+'+'+''''+'::'+''''+'+'+''''+'ask'+''''+
								' As column_header_ask,ROUND(spc.bid_value,'+@round_value+
								') As bid_value,Convert(VARCHAR(12),spc.as_of_date,101)'+'+'+''''+'::'+''''+'+'+'spcd.curve_name'+'+'+''''+'::'+''''+'+'+'sdv.code'+'+'+''''+'::'+''''+'+'+''''+'bid'+''''+
								'   As column_header_bid,ROUND((spc.ask_value+spc.bid_value)/2,'+@round_value+') mid_value' +
								',Convert(VARCHAR(12),spc.as_of_date,101)'+'+'+''''+'::'+''''+'+'+'spcd.curve_name'+'+'+''''+'::'+''''+'+'+'sdv.code'+'+'+''''+'::'+''''+'+'+''''+'mid'+''''
								ELSE '' END+
								',Convert(VARCHAR(12),spc.as_of_date,101)'+'+'+''''+'::'+''''+'+'+'spcd.curve_name'+'+'+''''+'::'+''''+'+'+'sdv.code 
								AS column_header,sdv1.code as granularity '+
								CASE WHEN ISNULL(@hourly_value,0)=1 THEN
									',Convert(VARCHAR(12),spc.maturity_date,108)  as hour'
								ELSE '' END +
									',spcd.forward_settle FROM source_price_curve_def spcd 
									INNER JOIN #source_price_curve_list spcl
										ON spcd.source_curve_def_id = spcl.price_curve_id
									INNER JOIN source_price_curve spc 
										ON spc.source_curve_def_id = spcl.price_curve_id
									INNER JOIN #curve_source_value_list csvl
										ON  csvl.curve_source_id = spc.curve_source_value_id
									LEFT JOIN static_data_value sdv ON spc.curve_source_value_id = sdv.value_id AND sdv.type_id = 10007
									LEFT JOIN static_data_value sdv1 ON spcd.Granularity = sdv1.value_id and sdv1.type_id = 978
								'
			SET @where_sql = @where_sql +CASE WHEN @as_of_date_from IS NOT NULL  THEN ' AND spc.as_of_date >= '+''''+ @as_of_date_from +'''' ELSE '' END
										+CASE  WHEN @as_of_date_to IS NOT NULL THEN ' AND spc.as_of_date <= '+''''+ @as_of_date_to +''''   ELSE '' END
										+CASE  WHEN @tenor_from IS NOT NULL THEN ' AND spc.maturity_date >= '+''''+ @tenor_from  +'''' ELSE '' END	  
										+CASE  WHEN @tenor_from IS NOT NULL THEN ' AND spc.maturity_date <= '+''''+ @tenor_to +''''  ELSE '' END
										--+CASE  WHEN @forward_settle IS NOT NULL THEN ' AND spcd.forward_settle = '+''''+ @forward_settle +''''  ELSE '' END
							
				SET @order_sql = ' ORDER BY source_curve_def_id ASC'
				
				EXEC (@select_sql + @where_sql + @order_sql)



				SELECT DISTINCT column_header,as_of_date INTO #column_header_list FROM #price_curve_column_header
				SELECT @curve_source_column_list = @curve_source_column_list + CASE WHEN  @curve_source_column_list = '' THEN  +'[' + column_header +']' ELSE ','+'[' + column_header +']'  END  
						FROM #column_header_list	

				

				SET @pivot_query_sql = 'SELECT *'
				--
				SET @pivot_query_sql1 = ' INTO '+ @process_table + ' FROM ( SELECT maturity_date as [Maturity Date],forward_settle '+ CASE WHEN ISNULL(@hourly_value,0)= 1 THEN ',hourly' ELSE '' END +',column_header,curve_value FROM #price_curve_column_header) up
				PIVOT (AVG(curve_value) FOR column_header IN ('
				SET @pivot_query_sql2 = @curve_source_column_list+')) AS PVT'
				

					


				EXEC (@pivot_query_sql+@pivot_query_sql1+@pivot_query_sql2)
				--EXEC('SELECT * FROM '+ @process_table) 
	
				---SET @hourly_value = 1
				IF @ask_bid = 'y'  
				BEGIN
					SELECT DISTINCT column_header_ask,as_of_date,'1' ask_bid,curve_name INTO #price_curve_ask 
					FROM #price_curve_column_header 
		
					SELECT @column_title_ask = @column_title_ask + CASE WHEN  @column_title_ask = '' THEN  +'[' + column_header_ask +']' ELSE ','+'[' + column_header_ask +']'  END  
					FROM #price_curve_ask

					--SELECT * FROM #price_curve_ask

					SELECT DISTINCT column_header_bid,as_of_date,'2' ask_bid,curve_name INTO #price_curve_bid 
					FROM #price_curve_column_header 

					SELECT @column_title_bid = @column_title_bid + CASE WHEN  @column_title_bid = '' THEN  +'[' + column_header_bid +']' ELSE ','+'[' + column_header_bid +']'  END  
					FROM #price_curve_bid

					SELECT DISTINCT column_header_mid,as_of_date,'3' ask_bid,curve_name INTO #price_curve_mid 
					FROM #price_curve_column_header 

					SELECT @column_title_mid = @column_title_mid + CASE WHEN  @column_title_mid = '' THEN  +'[' + column_header_mid +']' ELSE ','+'[' + column_header_mid +']'  END  
					FROM #price_curve_mid

					

					
					SET @pivot_ask = CASE WHEN ISNULL(@hourly_value,0)= 1 THEN ',hourly' ELSE '' END
					
					EXEC (@pivot_query_sql+ ' INTO '+ @process_table_ask +' FROM ( SELECT maturity_date [Maturity Date]' + @pivot_ask +',column_header_ask,ask,[forward_settle] FROM #price_curve_column_header) up
				PIVOT (AVG(ask) FOR column_header_ask IN ('+@column_title_ask+')) AS PVT1')

					EXEC (@pivot_query_sql+' INTO '+ @process_table_bid +' FROM ( SELECT maturity_date [Maturity Date]' + @pivot_ask+',column_header_bid,bid,[forward_settle] FROM #price_curve_column_header) up
				PIVOT (AVG(bid) FOR column_header_bid IN ('+@column_title_bid+')) AS PVT2')

					EXEC (@pivot_query_sql+ ' INTO '+ @process_table_mid +' FROM ( SELECT maturity_date [Maturity Date]' +@pivot_ask+',column_header_mid,mid,[forward_settle] FROM #price_curve_column_header) up
				PIVOT (AVG(mid) FOR column_header_mid IN ('+@column_title_mid+')) AS PVT3')



				--SELECT @process_table_ask,@process_table_bid,@process_table_mid
		
					INSERT INTO #overall(value,as_of_date,ask_bid,curve_name)
						Select * FROM #price_curve_mid
						UNION ALL 
						SELECT * FROM #price_curve_bid
						UNION ALL
						Select * FROM #price_curve_ask
	
	
				END

			
				DECLARE @c VARCHAR(MAX) = ''
				--
			
				SELECT @c =@c+',['+CAST(value as VARCHAR(200)) + ']'
				FROM #overall ORDER BY as_of_date asc,curve_name asc,ask_bid asc


			   --SELECT @process_table_ask,@process_table_bid,@process_table_mid
				SET @final_query = 'SELECT a.[Maturity Date],a.[forward_settle]'+CASE WHEN ISNULL(@hourly_value,0)=1 THEN ',a.[hourly]' ELSE ''END +CASE WHEN @ask_bid = 'y' THEN   @c ELSE +','+@curve_source_column_list END +' INTO '+@main_process_table+' FROM ' + 
										CASE WHEN @ask_bid = 'y' THEN 
											 @process_table_ask + ' a '+
											' INNER JOIN ' + @process_table_bid + ' c ON c.[maturity date] = a.[maturity date] AND ISNULL(a.[forward_settle],''f'') = ISNULL(c.[forward_settle],''f'')'+
											' INNER JOIN ' + @process_table_mid + ' d ON d.[maturity date] = a.[maturity date] AND ISNULL(a.[forward_settle],''f'') = ISNULL(c.[forward_settle],''f'')'
										ELSE 
											@process_table +' a ' 
										END
										+ ' WHERE ISNULL(a.[forward_settle],''f'')= ''f''
										 order by a.[maturity date] asc'
			
				--WHERE ISNULL(a.forward_settle,''f'')= ''f''
	
			
				EXEC (@final_query)
		
				
				SET @final_query_settle = 'SELECT a.[Maturity Date],a.[forward_settle] forward_settle'+CASE WHEN ISNULL(@hourly_value,0)=1 THEN ',a.[hourly]' ELSE ''END +','+@curve_source_column_list  +' INTO '+@settled_table_name+' FROM ' + 
									@process_table + ' a'
									+ ' WHERE ISNULL(a.[forward_settle],''s'')= ''s''
										order by [Maturity Date] asc'
				
				EXEC(@final_query_settle)

			SET @header_query =  'SELECT ROW_NUMBER() OVER (ORDER BY [forward settle],column_id) a  ,* FROM (SELECT c.name, '+''''+@process_id+'''' +' as process_id,''f'' AS [forward settle],c.column_id FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='+''''+@table_name+''''
	
			SET @header_query = @header_query + ' UNION ALL ' + 'SELECT c.name, '+''''+@process_id+'''' +' as process_id,''s'' AS [forward settle],c.column_id    FROM adiha_process.sys.[columns] c INNER JOIN adiha_process.sys.tables t on t.object_id = c.object_id   where t.name  ='+''''+@table_name_settled+'''' 
			SET @header_query= @header_query+ ') a1 order by a'
			PRINT(@header_query)
			EXEC(@header_query)
		END
	ELSE 
		BEGIN
			IF @forward_settle ='f'
			BEGIN
				EXEC('SELECT * FROM '+@main_process_table)
			END
			ELSE
			BEGIN
				EXEC('SELECT * FROM '+@settled_table_name)
			END
			
		END

END
ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY
			DECLARE @grid_xml  VARCHAR(MAX)
			DECLARE @object_id VARCHAR(100)

			SELECT @grid_xml = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
				FROM @xml.nodes('/Root/GridGroup') AS xmlData(col)
			SELECT @grid_xml
			-- parse the Object ID
			SELECT
				@object_id = xmlData.col.value('@object_id','VARCHAR(100)')
			FROM
				@xml.nodes('/Root') AS xmlData(Col)   

			IF @grid_xml IS NOT NULL
				BEGIN
					CREATE TABLE #grid_xml_process_table_name(table_name VARCHAR(200) )

					INSERT INTO #grid_xml_process_table_name EXEC spa_parse_xml_file 'b', NULL, @grid_xml
						SELECT @grid_xml_table_name = table_name FROM #grid_xml_process_table_name

						SELECT @grid_xml_table_name
						
				END

		END TRY
		BEGIN CATCH
			SET @desc = 'Error Occured.'--dbo.FNAHandleDBError(@function_id)
			EXEC spa_ErrorHandler -1, 'Process Form Data', 
						'spa_display_price_curve', 'Error', 
						@desc, ''
		END CATCH
	END
END


