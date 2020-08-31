IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'dbo.[spa_extrapolate_price]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE dbo.[spa_extrapolate_price]  
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO  

-- ===============================================================================================================  
-- Author: padhikari@pioneersolutionsglobal.com  
-- Create date: 2012-01-25  
-- Description: Logic To Extrapolate Price Curve.  
  
-- Params:  
-- @type - 'h' = Hourly and 'm' = Monthly
-- @curve_id
-- @as_of_date
-- @maturity_date
-- ===============================================================================================================  
CREATE PROC dbo.[spa_extrapolate_price]
	@type CHAR(1),  
	@curve_id INT,
	@as_of_date DATETIME,
	@maturity_date DATETIME   
AS  

--SET @curveId =203
--SET @asOfDate = '2012-01-26'
--SET @maturityDate = '2030-01-01'

DECLARE @curveId       INT
DECLARE @asOfDate      DATETIME
DECLARE @maturityDate  DATETIME
DECLARE @sql           VARCHAR(8000)
DECLARE @tenorFrom     DATETIME
DECLARE @tenorTo       DATETIME

BEGIN TRY
	BEGIN TRANSACTION
	
	IF OBJECT_ID('tempdb..#spc') IS NOT NULL  
		DROP TABLE #spc  

	SELECT * INTO #spc FROM source_price_curve WHERE 1 = 2	

	IF @type = 'm'
	BEGIN
		
		 IF OBJECT_ID('tempdb..#temp_forward_table_m') IS NOT NULL  
			DROP TABLE #temp_forward_table_m

		 --DECLARE @copyFrom      DATETIME
		 --SELECT @copyFrom = MAX(maturity_date) FROM source_price_curve WHERE source_curve_def_id = @curveId
		 
		 IF @tenorFrom IS NULL
			  SELECT @tenorFrom = DATEADD(DAY, 1, DATEADD(YEAR, -1, MAX(maturity_date)))
			  FROM   source_price_curve
			  WHERE  source_curve_def_id = @curveId
					 AND as_of_date = @asOfDate
		 
		 IF @tenorTo IS NULL
			SELECT @tenorTo = @maturityDate
		  
		 ;WITH mycte_m AS
		 (
			  SELECT CAST(@tenorFrom AS DATETIME) DateValue

			  UNION ALL
			     
			  SELECT DateValue + 1
			  FROM   mycte_m
			  WHERE  DateValue + 1 <= @tenorTo
		 )
		 SELECT DateValue INTO #temp_forward_table_m FROM mycte_m OPTION(MAXRECURSION 0)
		      
		 SET @sql = '
		   INSERT INTO #SPC
			 (
				source_curve_def_id,
				as_of_date,
				Assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				curve_value,
				bid_value,
				ask_value,
				is_dst
			 )
			SELECT          
				source_curve_def_id,'+
				+ '''' + CONVERT(VARCHAR(10),@asOfDate,127) + ''''
				+',Assessment_curve_type_value_id,
				curve_source_value_id,
				f.DateValue AS [maturity_date],
				curve_value,
				bid_value,
				ask_value,
				is_dst       
			FROM source_price_curve spc
			INNER JOIN #temp_forward_table_m f ON MONTH(f.DateValue) = MONTH(spc.maturity_date)
				AND DAY(f.DateValue) = DAY(spc.maturity_date)
		   '

		IF @curveId IS NOT NULL 
			SET @sql = @sql + ' INNER JOIN dbo.SplitCommaSeperatedValues(' + CAST(@curveId AS VARCHAR(10)) + ') csv 
								ON csv.Item = spc.source_curve_def_id'

			SET @sql = @sql + ' WHERE 1=1 ' 

		IF @asOfDate IS NOT NULL 
			SET @sql = @sql + ' AND spc.as_of_date = ''' + CAST(@asOfDate AS VARCHAR) + ''''

		IF @tenorFrom IS NOT NULL 
			SET @sql = @sql + ' AND CONVERT(VARCHAR(10), spc.maturity_date, 127) >= ''' + CONVERT(VARCHAR(10), @tenorFrom, 127) + ''''

		IF @tenorTo IS NOT NULL 
			SET @sql = @sql + ' AND CONVERT(VARCHAR(10), spc.maturity_date, 127) <= ''' + CONVERT(VARCHAR(10), @tenorTo, 127) + ''''

		EXEC spa_print @sql 
		EXEC (@sql)	  
	 
		DELETE FROM #spc 
		WHERE  maturity_date IN (SELECT spc.maturity_date
		                         FROM   source_price_curve spc
		                         WHERE  spc.source_curve_def_id = @curveId
		                                AND spc.as_of_date = @asOfDate
		                                AND spc.maturity_date >= @tenorFrom)
		   
		INSERT INTO source_price_curve
		  (
		    source_curve_def_id,
		    as_of_date,
		    Assessment_curve_type_value_id,
		    curve_source_value_id,
		    maturity_date,
		    curve_value,
		    bid_value,
		    ask_value,
		    is_dst
		  )
		SELECT source_curve_def_id,
		       as_of_date,
		       Assessment_curve_type_value_id,
		       curve_source_value_id,
		       maturity_date,
		       curve_value,
		       bid_value,
		       ask_value,
		       is_dst
		FROM #SPC		
		
	END
	ELSE
	BEGIN
		
		 IF OBJECT_ID('tempdb..#temp_forward_table_h') IS NOT NULL  
			DROP TABLE #temp_forward_table_h
		  
		 IF @tenorFrom IS NULL
			  SELECT @tenorFrom = DATEADD(DAY, 1,DATEADD(YEAR,-1,MAX(maturity_date))) 
			  FROM source_price_curve WHERE source_curve_def_id = @curveId 
				AND as_of_date = @asOfDate
		 
		 --SELECT @copyFrom = MAX(maturity_date) FROM source_price_curve WHERE source_curve_def_id = @curveId

		 IF @tenorTo IS NULL
		  SELECT @tenorTo = @maturityDate
		   
		 ;WITH mycte_h AS
		 (
			  SELECT CAST(@tenorFrom AS DATETIME) DateValue

			  UNION ALL
			     
			  SELECT DateValue + 1
			  FROM   mycte_h
			  WHERE  DateValue + 1 <= @tenorTo
		 )
		 SELECT DateValue INTO #temp_forward_table_h FROM mycte_h OPTION(MAXRECURSION 0)

		 IF OBJECT_ID('tempdb..#hour_block') IS NOT NULL
			 DROP TABLE #hour_block  

		DECLARE @time_part DATETIME
		SET @time_part = CONVERT(TIME(0), @tenorFrom)

		SELECT @time_part AS [sel], * 
		INTO #hour_block FROM ( 
			SELECT '00:00:00.000' AS [HOUR] UNION ALL
			SELECT '01:00:00.000' UNION ALL
			SELECT '02:00:00.000' UNION ALL
			SELECT '03:00:00.000' UNION ALL
			SELECT '04:00:00.000' UNION ALL
			SELECT '05:00:00.000' UNION ALL
			SELECT '06:00:00.000' UNION ALL
			SELECT '07:00:00.000' UNION ALL
			SELECT '08:00:00.000' UNION ALL
			SELECT '09:00:00.000' UNION ALL
			SELECT '10:00:00.000' UNION ALL
			SELECT '11:00:00.000' UNION ALL
			SELECT '12:00:00.000' UNION ALL
			SELECT '13:00:00.000' UNION ALL
			SELECT '14:00:00.000' UNION ALL
			SELECT '15:00:00.000' UNION ALL
			SELECT '16:00:00.000' UNION ALL
			SELECT '17:00:00.000' UNION ALL
			SELECT '18:00:00.000' UNION ALL
			SELECT '19:00:00.000' UNION ALL
			SELECT '20:00:00.000' UNION ALL
			SELECT '21:00:00.000' UNION ALL
			SELECT '22:00:00.000' UNION 
			SELECT '23:00:00.000'
		)p

		 IF OBJECT_ID('tempdb..#forward_data_h') IS NOT NULL
			 DROP TABLE #forward_data_h
		 
		 SELECT CONVERT(VARCHAR(10), f.DateValue, 120) + ' ' + hb.[hour] AS [DateValue]
		 INTO #forward_data_h
		 FROM   #temp_forward_table_h f
			INNER JOIN #hour_block hb ON  CONVERT(TIME(0), hb.sel) = CONVERT(TIME(0), f.DateValue) 
			
		 SET @sql = '
		   INSERT INTO #SPC
		     (
				source_curve_def_id,
				as_of_date,
				Assessment_curve_type_value_id,
				curve_source_value_id,
				maturity_date,
				curve_value,
				bid_value,
				ask_value,
				is_dst
		     )
			SELECT          
				source_curve_def_id,'+
				+ '''' + CONVERT(VARCHAR(10),@asOfDate,127) + ''''
				+',Assessment_curve_type_value_id,
				curve_source_value_id,
				CONVERT(VARCHAR(10), f.DateValue, 120) + '' ''+ CONVERT(VARCHAR(10), maturity_date, 108) AS [maturity_date],
				curve_value,
				bid_value,
				ask_value,
				is_dst       
			FROM source_price_curve spc
			INNER JOIN #forward_data_h f ON MONTH(f.DateValue) = MONTH(spc.maturity_date)
				AND DAY(f.DateValue) = DAY(spc.maturity_date)
				AND DATEPART(hh,f.DateValue) = DATEPART(hh,spc.maturity_date) 
		   '

		   IF @curveId IS NOT NULL 
				SET @sql = @sql + ' INNER JOIN dbo.SplitCommaSeperatedValues(' + CAST(@curveId AS VARCHAR(10)) + ') csv 
									ON csv.Item = spc.source_curve_def_id'
		   
		   SET @sql = @sql + ' WHERE 1=1 ' 
		    
		   IF @asOfDate IS NOT NULL 
				SET @sql = @sql + ' AND spc.as_of_date = ''' + CAST(@asOfDate AS VARCHAR) + ''''
		    
		   IF @tenorFrom IS NOT NULL 
				SET @sql = @sql + ' AND CONVERT(VARCHAR(10), spc.maturity_date, 127) >= ''' + CONVERT(VARCHAR(10), @tenorFrom, 127) + ''''
		    
		   IF @tenorTo IS NOT NULL 
				SET @sql = @sql + ' AND CONVERT(VARCHAR(10), spc.maturity_date, 127) <= ''' + CONVERT(VARCHAR(10), @tenorTo, 127) + ''''
		       
		   SET @sql = @sql + 'ORDER BY maturity_date'
		   
		   
		EXEC spa_print @sql 
		EXEC (@sql)

		--START UPDATING DST VALUES IN DST DATES
		IF OBJECT_ID('tempdb..#dst_delete') IS NOT NULL  
			DROP TABLE #dst_delete

		SELECT * INTO #dst_delete FROM #spc WHERE 1=2

		DELETE #spc 
		OUTPUT DELETED.* INTO #dst_delete
		FROM #spc 
			INNER JOIN mv90_DST md ON md.date = CONVERT(DATE,maturity_date) 
				AND (md.hour-1) = DATEPART(hh,maturity_date)
				AND md.insert_delete = 'd'

		DECLARE @dst_shift_year INT
		SELECT @dst_shift_year = MIN(YEAR(maturity_date)) FROM #dst_delete

		INSERT INTO #spc
		SELECT 
			dd.source_curve_def_id,
			dd.as_of_date,
			dd.Assessment_curve_type_value_id,
			dd.curve_source_value_id,
			DATEADD(hh,m.hour-1,DATEADD(YEAR,YEAR(dd.maturity_date)-m.year,m.date))	[maturity_date],
			dd.curve_value,
			dd.create_user,
			dd.create_ts,
			dd.update_user,
			dd.update_ts,
			dd.bid_value,
			dd.ask_value,
			dd.is_dst
		FROM #dst_delete dd
			INNER JOIN mv90_DST m ON m.year = @dst_shift_year - 1
				AND m.insert_delete = 'd'

		INSERT INTO #spc
		SELECT s.source_curve_def_id,
			   s.as_of_date,
			   s.Assessment_curve_type_value_id,
			   s.curve_source_value_id,
			   s.maturity_date,
			   s.curve_value,
			   s.create_user,
			   s.create_ts,
			   s.update_user,
			   s.update_ts,
			   s.bid_value,
			   s.ask_value,
			   1 [is_dst]
		FROM #spc s
			INNER JOIN mv90_DST md ON md.[date] = CONVERT(DATE,s.maturity_date)
				AND md.insert_delete = 'i'
				AND (md.hour-1) = DATEPART(hh,s.maturity_date)
			INNER JOIN #dst_delete df ON YEAR(df.maturity_date) = md.year

		DECLARE @dst_remove DATETIME
		SELECT @dst_remove = MIN(m.date)
		FROM #dst_delete dd
		INNER JOIN mv90_DST m ON m.year = @dst_shift_year - 1
			AND m.insert_delete = 'i'

		DELETE FROM #spc WHERE MONTH(maturity_date) = MONTH(@dst_remove) AND DAY(maturity_date) = DAY(@dst_remove) AND is_dst = 1
		--END UPDATING DST VALUES IN DST DATES

		--START LEAP YEAR DATA SWAP 
		DELETE FROM #spc WHERE MONTH(maturity_date) = 2 AND DAY(maturity_date) = 29

		INSERT INTO #spc
		SELECT source_curve_def_id,
			   as_of_date,
			   Assessment_curve_type_value_id,
			   curve_source_value_id,
			   DATEADD(DAY, 1, maturity_date) [maturity_date],
			   curve_value,
			   create_user,
			   create_ts,
			   update_user,
			   update_ts,
			   bid_value,
			   ask_value,
			   is_dst
		FROM #spc s 
		WHERE MONTH(s.maturity_date) = 2 
			AND DAY(s.maturity_date) = 28
			AND dbo.FNAisLeapYear(YEAR(s.maturity_date)) = 1
		--END LEAP YEAR DATA SWAP 

		  DELETE FROM #spc WHERE maturity_date IN (
		  	SELECT spc.maturity_date
		    FROM   source_price_curve spc
		    WHERE  spc.source_curve_def_id = @curveId
				AND spc.as_of_date = @asOfDate
				AND CONVERT(DATE, spc.maturity_date) >= CONVERT(DATE, @tenorFrom)
		  ) 
		  
		  INSERT INTO source_price_curve
		    (
		      source_curve_def_id,
		      as_of_date,
		      Assessment_curve_type_value_id,
		      curve_source_value_id,
		      maturity_date,
		      curve_value,
		      bid_value,
		      ask_value,
		      is_dst
		    )
		  SELECT source_curve_def_id,
		         as_of_date,
		         Assessment_curve_type_value_id,
		         curve_source_value_id,
		         maturity_date,
		         curve_value,
		         bid_value,
		         ask_value,
		         is_dst
		  FROM   #SPC s
	END
	
	COMMIT
	
	EXEC spa_ErrorHandler @@ERROR,
	     'spa_extrapolate_price',
	     'Extrapolate/Copy Price Curve',
	     'Success',
	     'Price(s) copied successfully.',
	     ''
END TRY
BEGIN CATCH
	ROLLBACK
	EXEC spa_ErrorHandler @@ERROR,
	     'spa_extrapolate_price',
	     'Extrapolate/Copy Price Curve',
	     'DB Error',
	     'Error on Copying Price Curve',
	     ''
END CATCH



--Unit Test
--exec spa_extrapolate_price 'h', 101,'2012-01-26','2030-01-01' 