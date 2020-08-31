IF OBJECT_ID('spa_save_xml_grid_data','p') IS NOT NULL
	DROP PROC spa_save_xml_grid_data
GO
/*
Author : Vishwas Khanal
Description : View Price Save SP re-written.
Dated : Sep.16.2009
*/
CREATE PROC spa_save_xml_grid_data
	@xml_st				VARCHAR(MAX),
	@col_st				VARCHAR(1000),
	@curve_id			VARCHAR(50),
	@curve_type			INT,				
	@curve_source		INT,
	@from_date			VARCHAR(20),
	@to_date			VARCHAR(20) = NULL,
	@tenor_from			VARCHAR(20) = NULL,
	@tenor_to			VARCHAR(20) = NULL,
	@ind_con_month		VARCHAR(1) = NULL,
	@differential		VARCHAR(1) = NULL,
	@bid_ask			VARCHAR(1) = NULL
AS
/*

declare 
	@xml_st				VARCHAR(MAX),
	@col_st				VARCHAR(1000),
	@curve_id			VARCHAR (50),
	@curve_type			INT,				
	@curve_source		INT,
	@from_date			VARCHAR(20),
	@to_date			VARCHAR(20),
	@tenor_from			VARCHAR(20) ,
	@tenor_to			VARCHAR(20) ,
	@ind_con_month		VARCHAR(1) ,
	@differential		VARCHAR(1) ,
	@bid_ask			VARCHAR(1)

select 	@xml_st	='<PSRecordSet>
<record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 00:00</MATURITY_DATE>   <min15.Essent>1</min15.Essent> </record> 
<record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 00:15</MATURITY_DATE>   <min15.Essent/> </record> 
<record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 00:30</MATURITY_DATE>   <min15.Essent/> </record> 
<record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 00:45</MATURITY_DATE>   <min15.Essent/> </record>
 <record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 01:00</MATURITY_DATE>   <min15.Essent/> </record> 
 <record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 01:15</MATURITY_DATE>   <min15.Essent/> </record> 
 <record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 01:30</MATURITY_DATE>   <min15.Essent/> </record> 
 <record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 01:45</MATURITY_DATE>   <min15.Essent/> </record> 
 <record>   <AS_OF_DATE>06/11/2010</AS_OF_DATE>   <MATURITY_DATE>07/01/2010 02:00</MATURITY_DATE>   <min15.Essent/> </record> 
</PSRecordSet>'
,
	@col_st	=null,
	@curve_id	='99',
	@curve_type	=77,				
	@curve_source	=4500,
	@from_date		='2010-06-11',
	@to_date		='2010-04-11',
	@tenor_from			 = null,
	@tenor_to			 = null,
	@ind_con_month		 = null,
	@differential		 = null,
	@bid_ask			 = null
	
	DROP TABLE #tmp

--exec spa_save_xml_grid_data '<PSRecordSet><record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-04-2010</MATURITY_DATE>   <CIG.Essent>2.5</CIG.Essent> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-05-2010</MATURITY_DATE>   <CIG.Essent>3</CIG.Essent> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-06-2010</MATURITY_DATE>   <CIG.Essent>3.5</CIG.Essent> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-07-2010</MATURITY_DATE>   <CIG.Essent>1111</CIG.Essent> </record></PSRecordSet>'
--,NULL,'22',  77,  4500,  '2010-03-28',  '2010-03-28',  NULL,  NULL, NULL, NULL, NULL
--


--exec spa_save_xml_grid_data '<PSRecordSet><record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>  
-- <MATURITY_DATE>01-04-2010</MATURITY_DATE>   <CIG.Essent_BIDVALUE>1</CIG.Essent_BIDVALUE>  
--  <CIG.Essent_ASKVALUE>2</CIG.Essent_ASKVALUE>   <CIG.Essent_MIDVALUE>1.5</CIG.Essent_MIDVALUE>
--   </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-05-2010</MATURITY_DATE> 
--     <CIG.Essent_MIDVALUE>2</CIG.Essent_MIDVALUE>   <CIG.Essent_BIDVALUE>2</CIG.Essent_BIDVALUE>  
--      <CIG.Essent_ASKVALUE>2</CIG.Essent_ASKVALUE> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE> 
--        <MATURITY_DATE>01-06-2010</MATURITY_DATE>   <CIG.Essent_MIDVALUE>2.5</CIG.Essent_MIDVALUE>  
--         <CIG.Essent_BIDVALUE>2</CIG.Essent_BIDVALUE>   <CIG.Essent_ASKVALUE>3</CIG.Essent_ASKVALUE> </record> <record> 
--           <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-07-2010</MATURITY_DATE>  
--            <CIG.Essent_MIDVALUE>1</CIG.Essent_MIDVALUE>   <CIG.Essent_BIDVALUE>1</CIG.Essent_BIDVALUE>   
--            <CIG.Essent_ASKVALUE>1</CIG.Essent_ASKVALUE> </record></PSRecordSet>'
--            ,NULL,'22',  77,  4500,  '2010-03-28',  '2010-03-28',  NULL,  NULL, NULL, NULL, 'b'



--
--
--'<PSRecordSet><record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-04-2010</MATURITY_DATE>  
-- <CIG_IF.Essent>1</CIG_IF.Essent>   <CIG.Essent>1.5</CIG.Essent> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE> 
--   <MATURITY_DATE>01-05-2010</MATURITY_DATE>   <CIG_IF.Essent>1</CIG_IF.Essent>   <CIG.Essent>2</CIG.Essent> </record> <record> 
--     <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-06-2010</MATURITY_DATE>   <CIG_IF.Essent>1</CIG_IF.Essent>  
--      <CIG.Essent>2.5</CIG.Essent> </record> <record>   <AS_OF_DATE>28-03-2010</AS_OF_DATE>   <MATURITY_DATE>01-07-2010</MATURITY_DATE> 
--        <CIG_IF.Essent>1</CIG_IF.Essent>   <CIG.Essent>1</CIG.Essent> </record></PSRecordSet>'
--        ,NULL,'35,22',  77,  4500,  '2010-03-28',  '2010-03-28',  NULL,  NULL, NULL, 'd', NULL
--





--*/

	/*******************for dynamic calc start******************************/
	DECLARE @process_id VARCHAR(100)
	SET @process_id = dbo.FNAGETNEWID()
	DECLARE @job_name VARCHAR(MAX)
	SET @job_name = 'Calc_Dynamic_Limit_' + @process_id
	/*******************for dynamic calc end******************************/
	
	
	BEGIN TRY
		BEGIN TRAN
		DECLARE @hdoc INT,@nodes  VARCHAR(MAX),@sql VARCHAR(MAX),@topCurveId INT,@error VARCHAR(8000)	

		IF OBJECT_ID('tempdb..##priceDetail') IS NOT NULL
		    DROP TABLE ##priceDetail
		
		IF OBJECT_ID('tempdb..##normal') IS NOT NULL
		    DROP TABLE ##normal
		
		IF OBJECT_ID('tempdb..##bid_and_ask') IS NOT NULL
		    DROP TABLE ##bid_and_ask
		
		IF OBJECT_ID('tempdb..##unpivot') IS NOT NULL
		    DROP TABLE ##unpivot
		
		IF OBJECT_ID('tempdb..##differential') IS NOT NULL
		    DROP TABLE ##differential
		
		EXEC spa_print ';1'
		EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml_st
				
		SELECT MIN(id) 'id',localname INTO #tmp FROM OPENXML(@hdoc, '/PSRecordSet/record')							
		WHERE nodetype = 1 AND parentid<>0
		GROUP BY localname			
		
		EXEC sp_xml_removedocument @hdoc

		SELECT @nodes = ISNULL(@nodes+',','') + '[' + localname + ']' + ' VARCHAR(100)'  
						FROM #tmp ORDER BY id ASC


		SELECT @sql = 'DECLARE @hdoc INT
		               EXEC sp_xml_preparedocument @hdoc OUTPUT, '''+ @xml_st +'''
		               
		               SELECT IDENTITY(INT, 1, 1) ''sno'', * INTO ##priceDetail
		               FROM   OPENXML(@hdoc, '' / PSRecordSet / record'', 2) WITH ('+@nodes+')
		               
		               EXEC sp_xml_removedocument @hdoc '

		EXEC spa_print @sql		
		EXEC(@sql)

		IF EXISTS(SELECT 1 FROM ##priceDetail pd
					INNER JOIN lock_as_of_date laod ON laod.close_date = pd.as_of_date)
		BEGIN
			DECLARE @msg VARCHAR(100)
			DECLARE @close_date DATETIME
			
			SELECT TOP 1 @close_date  = as_of_date FROM ##priceDetail
			SET @msg = 'As of Date ' + dbo.FNADateFormat(@close_date) + ' has been locked. Please unlock first to proceed.'
	
			EXEC spa_ErrorHandler -1
				, 'lock_as_of_date' 
				, 'spa_lock_as_of_date'
				, 'Error'          
				, @msg
				, '' 
				ROLLBACK TRAN
			RETURN
		END
		
		IF @bid_ask IS NULL AND @differential IS NULL
		BEGIN
			SELECT @nodes = NULL
			SELECT @nodes = '[' + localname + ']' FROM #tmp 
			WHERE localname <> 'IS_DST' 
			ORDER BY id ASC

			SELECT @sql = 'SELECT curve, as_of_date ''as_of_date'', maturity_date ''maturity_date'', is_dst, curve_value   
							INTO ##normal
			               FROM   (
			                          SELECT dbo.FNACovertToSTDDate(as_of_date) 
			                                 as_of_date,
			                                 dbo.FNAStdDate(maturity_date) 
			                                 maturity_date,
			                                 is_dst,
			                                 '+@nodes +'
			                          FROM   ##priceDetail
			                      ) p
			                      UNPIVOT(curve_value FOR curve IN ('+@nodes+')) AS unpvt'
			
			EXEC spa_print @sql	
			EXEC (@sql)
			
			-- Delete and Insert the Price  
			DELETE s FROM source_price_curve s
			INNER JOIN ##normal n ON s.as_of_date = n.as_of_date
				AND s.maturity_date = n.maturity_date		
			WHERE  s.source_curve_def_id = @curve_id				
				AND Assessment_curve_type_value_id = @curve_type
				AND curve_source_value_id = @curve_source

			INSERT INTO source_price_curve(source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id,
						maturity_date, curve_value, bid_value, ask_value,is_dst)
			SELECT @curve_id, n.as_of_date, @curve_type, @curve_source, 
					n.maturity_date, n.curve_value, n.curve_value, n.curve_value, is_dst
			FROM   ##normal n
			WHERE  ISNULL(curve_value, '') <> '' OR  ISNULL(curve_value, ' ') <> ' '
	 						
			DROP TABLE ##normal
		END
		ELSE IF @bid_ask = 'b' AND @differential IS NULL
		BEGIN
			EXEC spa_print 'bid'
			SELECT @nodes = NULL
			
			SELECT @nodes = SUBSTRING(localname, 1, LEN(localname) -9)
			FROM   #tmp
			WHERE localname <> 'IS_DST' -- IS_DST filtered as it comes at the end and messes up @nodes
			ORDER BY id ASC
			
			SELECT @nodes = '[' + @nodes + '_bidvalue],[' + @nodes + '_askvalue],[' + @nodes + '_midvalue]' 

			SELECT @sql = 'SELECT curve_name, CAST(NULL AS VARCHAR) ''mode'', as_of_date, maturity_date, curve_value INTO ##unpivot
			               FROM   (
								  SELECT dbo.FNACovertToSTDDate(as_of_date) 
										 as_of_date,
										 dbo.FNAStdDate(maturity_date) 
										 maturity_date,
										 '+@nodes+'
								  FROM   ##priceDetail
							  ) p
							  UNPIVOT(curve_value FOR curve_name IN ('+@nodes+')) AS unpvt'
		
			EXEC spa_print @sql
			EXEC (@sql)
			
			UPDATE t
			SET    mode = CAST(RIGHT(curve_name, 8) AS VARCHAR),
			       curve_name = SUBSTRING(curve_name, 1, LEN(curve_name) -9)
			FROM   ##unpivot t
			
			SELECT @sql = ' SELECT as_of_date ''as_of_date'',
			                       maturity_date ''maturity_date'',
			                       bidvalue ''bid_value'',
			                       askvalue ''ask_value'',
			                       midvalue ''curve_value'' 
			                   INTO ##bid_and_ask
			                FROM   ##unpivot
			                PIVOT(MAX(curve_value) FOR mode IN (bidvalue, midvalue, askvalue)) AS pvt'	
			
			--PRINT @sql
			EXEC (@sql)

			-- Delete and Insert the Price  
			DELETE s FROM source_price_curve s
			INNER JOIN ##bid_and_ask n ON s.as_of_date = n.as_of_date
				AND s.maturity_date = n.maturity_date		
			WHERE  s.source_curve_def_id = @curve_id
				AND	Assessment_curve_type_value_id = @curve_type
				AND curve_source_value_id = @curve_source
					
			INSERT INTO source_price_curve(source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id,
			    maturity_date, curve_value, bid_value, ask_value, is_dst)
			SELECT @curve_id, n.as_of_date, @curve_type, @curve_source,
			       n.maturity_date, n.curve_value, n.bid_value, n.ask_value, 0
			FROM   ##bid_and_ask n
			WHERE  n.curve_value != ''

			DROP TABLE ##unpivot
			DROP TABLE ##bid_and_ask		
		END
		ELSE IF @bid_ask IS NULL AND @differential = 'd'
		BEGIN
			EXEC spa_print 'diff'
		
			SELECT @nodes = NULL
			SELECT @nodes = ISNULL(@nodes+',','') + '['+localname +']'  FROM #tmp WHERE localname NOT IN ('AS_OF_DATE','MATURITY_DATE') ORDER BY id ASC			

			SELECT @sql = 'SELECT IDENTITY(INT, 1, 1) ''sno'', curve_name ''curve'', as_of_date, maturity_date, curve_value INTO ##differential
			               FROM   (
		                          SELECT dbo.FNACovertToSTDDate(as_of_date) 
		                                 as_of_date,
		                                 dbo.FNAStdDate(maturity_date) 
		                                 maturity_date,
		                                 '+@nodes+'
		                          FROM   ##priceDetail
		                      ) p
		                      UNPIVOT(curve_value FOR curve_name IN ('+@nodes+')) AS unpvt'
			EXEC spa_print @sql
			EXEC (@sql)
		
			-- Update the curve name with the corresponding Ids.
			SELECT MIN(sno) 'sno',curve INTO #tmp1 FROM ##differential GROUP BY curve ORDER BY MIN(sno) ASC
			SELECT IDENTITY(INT,1,1) 'sno' ,item INTO #tmp2 FROM dbo.splitcommaSeperatedValues(@curve_id)
			
			UPDATE d SET d.curve = t2.item
			FROM #tmp2 t2 
			INNER JOIN #tmp1 t1 ON t1.sno = t2.sno
			INNER JOIN ##differential d ON t1.curve = d.curve
						
			-- When differential is checked, the value has to be added to the root curve in the hierarchy.
			SELECT TOP 1 @topCurveId = curve FROM ##differential						
			
			UPDATE s
			SET    s.curve_value = CAST(ISNULL(CASE f.curve_value WHEN '' THEN NULL ELSE f.curve_value END, 0) AS FLOAT)
			       + CAST(CASE s.curve_value WHEN '' THEN NULL ELSE s.curve_value END AS FLOAT)
			FROM   (SELECT * FROM   ##differential WHERE  curve = @topCurveId) f
			INNER JOIN ##differential s ON  f.as_of_date = s.as_of_date
	            AND f.maturity_date = s.maturity_date
	            AND f.curve <> s.curve
					
			-- Delete and Insert the Price  
			DELETE s FROM source_price_curve s
			INNER JOIN ##differential d ON s.as_of_date = d.as_of_date
				AND s.maturity_date = d.maturity_date		
				AND s.source_curve_def_id = d.curve
			WHERE Assessment_curve_type_value_id = @curve_type
				AND curve_source_value_id = @curve_source

			INSERT INTO source_price_curve(source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id,
			    maturity_date, curve_value, bid_value, ask_value, is_dst)
			SELECT d.curve, d.as_of_date, @curve_type, @curve_source,
			       d.maturity_date, d.curve_value, d.curve_value, d.curve_value, 0
			FROM   ##differential d
			WHERE  d.curve_value != ''
			
			DROP TABLE #tmp1
			DROP TABLE #tmp2
			DROP TABLE ##differential						
		END

		DROP TABLE ##priceDetail
		----------------for dynamic calc start-----------------------------------
		IF EXISTS(SELECT 1 FROM  source_price_curve_def spcd WHERE spcd.source_curve_def_id = @curve_id AND spcd.curve_name = 'Markdown %')
		BEGIN
			DECLARE @today VARCHAR(10)
			SET @today = dbo.FNAGetSQLStandardDate(GETDATE())
			
			DECLARE @user_login_id VARCHAR(MAX)
			SET @user_login_id = dbo.FNADBUser()
			
			SET @sql = 'spa_calc_dynamic_limit ''' + @today + ''', ''c'''
			
			EXEC spa_run_sp_as_job @job_name, @sql, 'Dynamic Limit', @user_login_id, NULL, NULL, NULL
		END
		----------------for dynamic calc end-----------------------------------	
		COMMIT TRAN
		
		SELECT 	'Success' ErrorCode, 'spa_save_xml_grid_data' Module, 'Price Curve' Area,  'Success' STATUS, 'Price Curve successfully saved.' [Message], '' Recommendation
	END TRY
	BEGIN CATCH
		SELECT @error = ERROR_MESSAGE()	
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SELECT 	'Error' ErrorCode, 'spa_save_xml_grid_data' Module, 'Price Curve' Area, 'Error' STATUS, @error [Message], '' Recommendation		
	END CATCH	