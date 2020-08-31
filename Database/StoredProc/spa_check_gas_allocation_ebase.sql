
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_check_gas_allocation_ebase]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_check_gas_allocation_ebase]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_check_gas_allocation_ebase]
@temp_header_table VARCHAR(255),
@gas_data_table VARCHAR(255),
@is_empty BIT = 0
	
	AS 

/*
		 drop table #gas_missing_data
		declare @temp_header_table VARCHAR(255) = 'adiha_process.dbo.stage_ebase_mv90_data_header_farrms_admin_20120608_125311',
		@gas_data_table VARCHAR(255) = 'adiha_process.dbo.mv90_data_hour_farrms_admin_20120608_125311',
		@is_empty BIT = 1
*/	
				
		-- 0 vol sum for meter prior from last allocation month  for GAS data
		DECLARE @query_str VARCHAR(5000) 
		 
		 
 	    CREATE TABLE #gas_missing_data(meter_id INT, prod_date VARCHAR(30) COLLATE DATABASE_DEFAULT)
 	    
	    -- logic to update first day of the month ( [Hr 7 to 24] to NULL since Hr 1 to 6 will have data of previous month)
		EXEC('INSERT INTO #gas_missing_data(meter_id, prod_date) 
			  SELECT DISTINCT mi.meter_id, (CONVERT(VARCHAR(8),DATEADD(m, ISNULL(g.last_allocation_month, 0) * (-1) , GETDATE() ), 120) + ''01'')
			  FROM meter_id mi
			  INNER JOIN static_data_value sdv ON sdv.value_id = mi.country_id
			  INNER JOIN source_commodity sc ON sc.source_commodity_id = mi.commodity_id
			  LEFT JOIN gas_allocation_map_ebase g ON g.source_commodity_id = mi.commodity_id AND g.country = sdv.value_id  
			  WHERE mi.commodity_id = -1 AND sdv.type_id = 14000 ')
		

			SET @query_str = '
				SELECT DISTINCT mi.meter_id, g.prod_date gen_date, g.prod_date from_date, 
				dbo.FNALastDayInDate(g.prod_date) to_date, 1 channel, 0 volume, rp.uom_id uom_id, NULL descriptions
				FROM #gas_missing_data g
				INNER JOIN meter_id mi ON g.meter_id = mi.meter_id
				INNER JOIN recorder_properties rp ON rp.meter_id = g.meter_id
				INNER JOIN static_data_value sdv ON sdv.value_id = mi.country_id
				LEFT JOIN mv90_data mv ON mv.meter_id = mi.meter_id AND mv.from_date = g.prod_date WHERE  mi.commodity_id = -1 AND  
				mv.meter_data_id IS NULL AND sdv.[type_id] = 14000 
				
				UNION ALL
				
				SELECT DISTINCT mi.meter_id, DATEADD(m, 1, g.prod_date) gen_date, DATEADD(m, 1, g.prod_date) from_date, 
				dbo.FNALastDayInDate(DATEADD(m, 1, g.prod_date)) to_date, 1 channel, 0 volume, rp.uom_id uom_id, NULL descriptions
				FROM #gas_missing_data g
				INNER JOIN meter_id mi ON g.meter_id = mi.meter_id
				INNER JOIN recorder_properties rp ON rp.meter_id = g.meter_id
				INNER JOIN static_data_value sdv ON sdv.value_id = mi.country_id
				LEFT JOIN mv90_data mv ON mv.meter_id = mi.meter_id AND mv.from_date = DATEADD(m, 1, g.prod_date)
				WHERE  mi.commodity_id = -1 AND mv.meter_data_id IS NULL AND sdv.[type_id] = 14000 AND (mi.granularity = ''H'' OR mi.granularity IS NULL) 	'

			--exec (@query_str)
			EXEC ('INSERT INTO mv90_data (meter_id, gen_date, from_date, to_date, channel, volume, uom_id, descriptions) ' + @query_str)

		
			-- insert 2nd day to last day of month if not exists
			INSERT INTO mv90_data_hour(meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, 
										 Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)					
			SELECT mv.meter_data_id, d.day_date,
				  0 Hr1, 0 Hr2, 0 Hr3, 0 Hr4, 0 Hr5 ,0 Hr6, 0 Hr7, 0 Hr8, 0 Hr9, 0 Hr10, 0 Hr11, 0 Hr12, 0 Hr13, 0 Hr14, 0 Hr15, 0 Hr16, 
				  0 Hr17, 0 Hr18, 0 Hr19, 0 Hr20, 0 Hr21, 0 Hr22, 0 Hr23, 0 Hr24, 0 Hr25, rp.uom_id uom_id				
				FROM meter_id mi
				INNER JOIN #gas_missing_data g ON g.meter_id = mi.meter_id
				INNER JOIN recorder_properties rp ON rp.meter_id = g.meter_id
				INNER JOIN static_data_value sdv ON sdv.value_id = mi.country_id
				INNER JOIN mv90_data mv ON mv.meter_id = mi.meter_id AND mv.from_date = g.prod_date
				CROSS APPLY dbo.fnagetdaywisedate(mv.from_date,DATEADD(m,1,mv.from_date)-1) d
				LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = mv.meter_data_id AND mdh.prod_date = d.day_date
				WHERE  mi.commodity_id = -1 AND mdh.recid IS NULL AND sdv.[type_id] = 14000 AND DAY(d.day_date) <> 1 AND ISNULL(mi.granularity,'H') <> 'M'


			-- insert 1st day of month, Hr 7 to 25
			INSERT INTO mv90_data_hour(meter_data_id, prod_date, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, 
										 Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)
			SELECT  mv.meter_data_id, g.[prod_date], 0 Hr7, 0 Hr8, 0 Hr9, 0 Hr10, 0 Hr11, 0 Hr12, 0 Hr13, 0 Hr14, 0 Hr15, 0 Hr16, 
				  0 Hr17, 0 Hr18, 0 Hr19, 0 Hr20, 0 Hr21, 0 Hr22, 0 Hr23, 0 Hr24, 0 Hr25, rp.uom_id
					FROM meter_id  mi
					INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
					INNER JOIN [mv90_data] mv ON mv.[meter_id] = mi.[meter_id]
					INNER JOIN #gas_missing_data g ON g.meter_id = mv.meter_id AND mv.[from_date] = g.[prod_date]		
					LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = mv.meter_data_id AND mdh.prod_date = g.prod_date
					WHERE DAY(g.prod_date) = 1  AND mdh.recid IS NULL AND ISNULL(mi.granularity,'H') <> 'M'


			-- insert next month 1st day, 1-6 hour
			INSERT INTO mv90_data_hour(meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, uom_id)
			SELECT  mv.meter_data_id, DATEADD(mm, 1, g.[prod_date]), 0 Hr1, 0 Hr2, 0 Hr3, 0 Hr4, 0 Hr5 ,0 Hr6, rp.uom_id
					FROM [mv90_data] mv
					INNER JOIN meter_id  mi ON mv.[meter_id] = mi.[meter_id]
					LEFT JOIN recorder_properties rp ON rp.meter_id = mi.meter_id					
					INNER JOIN #gas_missing_data g ON g.meter_id = mv.meter_id AND mv.[from_date] = DATEADD(mm, 1, g.[prod_date])
					LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = mv.meter_data_id AND mdh.[prod_date] = DATEADD(mm, 1, g.[prod_date])
					WHERE mdh.recid IS NULL AND ISNULL(mi.granularity,'H') <> 'M'


			
			UPDATE mdh SET mdh.Hr7 = ISNULL(mdh.Hr7, 0), mdh.Hr8 = ISNULL(mdh.Hr8, 0), mdh.Hr9 = ISNULL(mdh.Hr9, 0), mdh.Hr10 = ISNULL(mdh.Hr10, 0), mdh.Hr11 = ISNULL(mdh.Hr11, 0), mdh.Hr12 = ISNULL(mdh.Hr12, 0), mdh.Hr13 = ISNULL(mdh.Hr13, 0),
						   mdh.Hr14 = ISNULL(mdh.Hr14, 0), mdh.Hr15 = ISNULL(mdh.Hr15, 0), mdh.Hr16 = ISNULL(mdh.Hr16, 0), mdh.Hr17 = ISNULL(mdh.Hr17, 0), mdh.Hr18 = ISNULL(mdh.Hr18, 0), mdh.Hr19 = ISNULL(mdh.Hr19, 0), mdh.Hr20 = ISNULL(mdh.Hr20, 0),
						   mdh.Hr21 = ISNULL(mdh.Hr21, 0), mdh.Hr22 = ISNULL(mdh.Hr22, 0), mdh.Hr23 = ISNULL(mdh.Hr23, 0), mdh.Hr24 = ISNULL(mdh.Hr24, 0), mdh.Hr25 = ISNULL(mdh.Hr25, 0)  
			FROM mv90_data_hour mdh
			INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id] AND md.from_date = mdh.prod_date
			INNER JOIN #gas_missing_data g ON g.meter_id = md.meter_id AND mdh.[prod_date] = g.[prod_date] 
			

			UPDATE mdh SET mdh.Hr1 = ISNULL(mdh.Hr1, 0), mdh.Hr2 = ISNULL(mdh.Hr2, 0), mdh.Hr3 = ISNULL(mdh.Hr3, 0), mdh.Hr4 = ISNULL(mdh.Hr4, 0), mdh.Hr5 = ISNULL(mdh.Hr5, 0), mdh.Hr6 = ISNULL(mdh.Hr6, 0)
			FROM mv90_data_hour mdh
				INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id] AND md.from_date = mdh.prod_date
				INNER JOIN #gas_missing_data g ON g.meter_id = md.meter_id AND mdh.[prod_date] =  DATEADD(mm, 1, g.[prod_date])

			
			UPDATE mv set mv.volume = a.vol	
			FROM
			mv90_data mv INNER JOIN		
			(select md.meter_id,md.from_date,mvh.vol
			FROM 
				mv90_data md
				INNER JOIN #gas_missing_data g ON g.[meter_id] = md.[meter_id]
					AND CAST(md.from_date AS DATETIME)  BETWEEN CAST(g.prod_date AS DATETIME) AND  DATEADD(m,1,CAST(g.prod_date AS DATETIME))
				CROSS APPLY(
					SELECT SUM(
						CASE WHEN COALESCE(mdh.Hr1,mdh.Hr2,mdh.Hr3,mdh.Hr4,mdh.Hr5,mdh.Hr6,mdh.Hr7,mdh.Hr8,mdh.Hr9,mdh.Hr10,mdh.Hr11,mdh.Hr12,mdh.Hr13,
								 mdh.Hr14,mdh.Hr15,mdh.Hr16,mdh.Hr17,mdh.Hr18,mdh.Hr19,mdh.Hr20,mdh.Hr21,mdh.Hr22,mdh.Hr23,mdh.Hr24) IS NULL THEN NULL
							 ELSE 	 
							ISNULL(mdh.Hr1,0) + ISNULL(mdh.Hr2,0) + ISNULL(mdh.Hr3,0) + ISNULL(mdh.Hr4,0) + ISNULL(mdh.Hr5,0) + ISNULL(mdh.Hr6,0) + ISNULL(mdh.Hr7,0) + ISNULL(mdh.Hr8,0) + ISNULL(mdh.Hr9,0) + ISNULL(mdh.Hr10,0)+
							ISNULL(mdh.Hr11,0) + ISNULL(mdh.Hr12,0) + ISNULL(mdh.Hr13,0) + ISNULL(mdh.Hr14,0) + ISNULL(mdh.Hr15,0) + ISNULL(mdh.Hr16,0) + ISNULL(mdh.Hr17,0) + ISNULL(mdh.Hr18,0) + ISNULL(mdh.Hr19,0) + ISNULL(mdh.Hr20,0) + ISNULL(mdh.Hr21,0)+
							ISNULL(mdh.Hr22,0) + ISNULL(mdh.Hr23,0) + ISNULL(mdh.Hr24,0) END
						) vol
					FROM 
						 mv90_data_hour mdh 
					WHERE
						mdh.meter_data_id = md.meter_data_id		
				) mvh
			)a ON mv.meter_id =a.meter_id AND mv.from_date = a.from_date
			INNER JOIN meter_id mi ON mi.meter_id = mv.meter_id
			WHERE ISNULL(mi.granularity,'H') <> 'M'
	
		-- data can't be null for any hour except that of 1st day of month
		UPDATE mdh SET mdh.Hr1 = ISNULL(mdh.Hr1, 0), mdh.Hr2 = ISNULL(mdh.Hr2, 0), mdh.Hr3 = ISNULL(mdh.Hr3, 0), mdh.Hr4 = ISNULL(mdh.Hr4, 0), mdh.Hr5 = ISNULL(mdh.Hr5, 0), 
					   mdh.Hr6 = ISNULL(mdh.Hr6, 0), mdh.Hr7 = ISNULL(mdh.Hr7, 0), mdh.Hr8 = ISNULL(mdh.Hr8, 0), mdh.Hr9 = ISNULL(mdh.Hr9, 0), mdh.Hr10 = ISNULL(mdh.Hr10, 0), 
					   mdh.Hr11 = ISNULL(mdh.Hr11, 0), mdh.Hr12 = ISNULL(mdh.Hr12, 0), mdh.Hr13 = ISNULL(mdh.Hr13, 0), mdh.Hr14 = ISNULL(mdh.Hr14, 0), mdh.Hr15 = ISNULL(mdh.Hr15, 0), 
					   mdh.Hr16 = ISNULL(mdh.Hr16, 0), mdh.Hr17 = ISNULL(mdh.Hr17, 0), mdh.Hr18 = ISNULL(mdh.Hr18, 0), mdh.Hr19 = ISNULL(mdh.Hr19, 0), mdh.Hr20 = ISNULL(mdh.Hr20, 0),
					   mdh.Hr21 = ISNULL(mdh.Hr21, 0), mdh.Hr22 = ISNULL(mdh.Hr22, 0), mdh.Hr23 = ISNULL(mdh.Hr23, 0), mdh.Hr24 = ISNULL(mdh.Hr24, 0), mdh.Hr25 = ISNULL(mdh.Hr25, 0)  
		FROM mv90_data_hour mdh
		INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
		INNER JOIN #gas_missing_data g ON g.meter_id = md.meter_id AND YEAR(mdh.[prod_date]) = YEAR(g.[prod_date]) AND MONTH(mdh.[prod_date]) = MONTH(g.[prod_date]) 
		WHERE 
		DAY(mdh.prod_date) <> 1	
		
		
