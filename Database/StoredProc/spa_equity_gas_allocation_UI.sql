
IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_equity_gas_allocation_UI]')
       AND   TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_equity_gas_allocation_UI]
GO
-- ===============================================================================================================
-- Author: vsshrestha@pioneersolutionsglobal.com
-- Create date: 2015-04-23
-- Description: Description of the functionality in brief.Volume Split Logic for Questar
  
-- Params:
-- @flag char -- flag of the spa. 'h':header detial 'b': body detail 't':hard coded data 'i': insert data
-- @location_id INT -- Gathering Location
-- @del_location_id INT -- Delievery Location
-- @start_date DATETIME -- Date From
-- @volume INT -- Rec. Volume
-- @split_percentage INT --Split Ratio
-- @xml XML  -- XML for saving logic
-- @start_date DATETIME -- Date To
-- @filter_type char--'a':Show All, 's':Show with split, 'n':Show without split
-- spa_equity_gas_allocation_UI @flag = 'h', @start_date = '2015-09-01', @end_date = '2015-09-30', @filter_type = 'n'
-- ===============================================================================================================
CREATE PROC [dbo].[spa_equity_gas_allocation_UI] 
	@flag AS char(1),
	@location_id AS VARCHAR(MAX) = NULL,
	@del_location_id AS int = NULL,
	@start_date AS datetime = NULL,
	@volume int = NULL,
	@split_percentage int = NULL,
	@xml xml = NULL,
	@end_date AS datetime = NULL,
	@filter_type AS char(1)=NULL

AS
SET NOCOUNT ON
DECLARE @date_xml       varchar(max),
        @idoc           int,
        @term_start     datetime

IF @filter_type IS NULL
	SET @filter_type='a'

IF @flag = 'i'
BEGIN
BEGIN TRY
    DECLARE @group_by CHAR(1)
	/*
	declare @xml XML
	declare @idoc int
	declare @start_date datetime,
	@end_date datetime,
	@location_id VARCHAR(200)
	SET @xml = '<Root><PSDate date_from="2015-05-01" date_to="2015-05-31" group_by="b"></PSDate><PSRecordSet gathering_loc_id="304829" type="Primary" delivery_location_id="5610" volume="60736" split="0.99927607765712"></PSRecordSet><PSRecordSet gathering_loc_id="304829" type="Secondary" delivery_location_id="5933" volume="44" split="0.00072392234287595"></PSRecordSet><PSRecordSet gathering_loc_id="304829" type="Secondary" delivery_location_id="5944" volume="0" split="0"></PSRecordSet></Root>'
    */
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
    
    IF OBJECT_ID('tempdb..#temp_date') IS NOT NULL
        DROP TABLE #temp_date
    
    IF OBJECT_ID('tempdb..#temp_data') IS NOT NULL
        DROP TABLE #temp_data
    
    IF OBJECT_ID('tempdb..#temp_split_nom') IS NOT NULL
        DROP TABLE #temp_split_nom
    
    CREATE TABLE #temp_split_nom(
    	[date]					datetime,
    	gathering_loc_id		INT,
		route_id				INT,
    	[type]					varchar(10) COLLATE DATABASE_DEFAULT,
    	delivery_location_id    INT,
    	volume					NUMERIC(38, 20),
    	split					FLOAT,
		[contract_id]			int
    )
    
    -- Execute a SELECT statement that uses the OPENXML rowset provider.
    SELECT @start_date = date_from ,
           @end_date = date_to,
		   @group_by = group_by,
		   @location_id = NULLIF(location_id, 'NULL')
    FROM   OPENXML(@idoc, '/Root/PSDate', 1)
    WITH (date_from varchar(10), date_to varchar(10), group_by CHAR(1), location_id VARCHAR(2000))

    -- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT gathering_loc_id [gathering_loc_id],
		   route_id [route_id],
           [type] [type],
           delivery_location_id [delivery_location_id],
           volume [volume],
           split [split],
		   [contract_id] 
    INTO #temp_data
    FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
    WITH (
        gathering_loc_id INT,
		route_id INT,
        [type] varchar(10),
        delivery_location_id INT,
        volume NUMERIC(38,20),
        split NUMERIC(38,20),
		[contract_id] int
    )
           
    IF NOT EXISTS (SELECT 1 FROM #temp_data)
    BEGIN
    	 EXEC spa_ErrorHandler -1,
			 'Equity Gas Allocation',
			 'spa_equity_gas_allocation_UI',
			 'Error',
			 'Please insert the splitted volume.',
			 ''
    END

	IF @group_by = 'b'
	BEGIN
		IF OBJECT_ID('tempdb..#temp_split') IS NOT NULL
			DROP TABLE #temp_split

		IF OBJECT_ID('tempdb..#temp_primary_location_volume') IS NOT NULL
			DROP TABLE #temp_primary_location_volume

		CREATE TABLE #temp_split (
    		gathering_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    		delievery_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    		[primary_secondary]     varchar(10) COLLATE DATABASE_DEFAULT,
			route_id				INT,
			nomination_group		INT,
    		Volume                  NUMERIC(38,20),
    		split					NUMERIC(38,20),
			contract_id				int
		)

		INSERT INTO #temp_split (route_id, gathering_loc, delievery_loc, [primary_secondary], nomination_group, Volume, contract_id)
		EXEC spa_split_nom_volume 's',
			 NULL,
			 NULL,
			 NULL,
			 @start_date,
			 @location_id

		UPDATE temp
		SET split = temp2.split
		FROM #temp_split temp
		INNER JOIN #temp_data temp2 
			ON temp2.delivery_location_id = temp.delievery_loc
			AND temp.nomination_group = temp2.gathering_loc_id
			AND temp.route_id = temp2.route_id
			AND temp.contract_id = temp2.contract_id
		
		DELETE temp
		FROM #temp_split temp
		LEFT JOIN #temp_data temp2 
			ON temp2.delivery_location_id = temp.delievery_loc
			AND temp.nomination_group = temp2.gathering_loc_id
			AND temp.route_id = temp2.route_id
			AND temp.contract_id = temp2.contract_id
		WHERE temp2.delivery_location_id IS NULL
			
		SELECT *
		INTO #temp_primary_location_volume 
		FROM #temp_split ts
				
		SELECT *, NULL nomination_group INTO #temp_split_data FROM #temp_data WHERE 1 = 2

		INSERT INTO #temp_split_data([gathering_loc_id], [type], [delivery_location_id], [volume], [split], [contract_id], [nomination_group], route_id)
		SELECT ts.gathering_loc,  CASE WHEN ts.[primary_secondary] = 'p' THEN 'Primary' ELSE 'Secondary' END, ts.delievery_loc, pri.pri_vol*ts.split, ts.split, ts.contract_id, ts.nomination_group, ts.route_id
		FROM #temp_split ts
		OUTER APPLY (
			SELECT Volume pri_vol
			FROM #temp_primary_location_volume pri_vol
			WHERE pri_vol.gathering_loc = ts.gathering_loc 
			AND pri_vol.[primary_secondary] = 'p'
		) pri
		where ts.nomination_group IS NOT NULL
		/*
		;WITH cte_update_sec_vol AS (
			SELECT *, ROW_NUMBER() OVER(PARTITION BY nomination_group, route_id, [delivery_location_id], contract_id ORDER BY [delivery_location_id]) row_id 
			FROM #temp_split_data tsd 
			WHERE [type] <> 'Primary'
		)
		update cte
		SET [volume] = [volume] + a.diff_vol
		FROM cte_update_sec_vol cte 
		INNER JOIN (
			SELECT nomination_group, tsd.route_id, tsd.delivery_location_id, tsd.contract_id, (tod.volume - tsd.volume) diff_vol
			FROM  (
				SELECT nomination_group, ts.route_id, ts.delivery_location_id, ts.contract_id, SUM(CAST(volume AS INT)) volume FROM #temp_split_data ts
				WHERE [type] <> 'Primary'
				GROUP BY ts.nomination_group, ts.route_id, ts.delivery_location_id, ts.contract_id
			) tsd
			INNER JOIN (
				SELECT [gathering_loc_id], ts.route_id, delivery_location_id, ts.contract_id, SUM(CAST(volume AS INT)) volume FROM #temp_data ts
				WHERE [type] <> 'Primary'
				GROUP BY ts.[gathering_loc_id], ts.route_id, ts.delivery_location_id, ts.contract_id
			) tod ON tod.[gathering_loc_id] = tsd.nomination_group  AND tod.route_id = tsd.route_id AND tod.delivery_location_id = tsd.delivery_location_id AND tsd.contract_id = tod.contract_id
		) a 
		ON a.nomination_group = cte.nomination_group
		AND a.route_id = cte.route_id
		AND a.delivery_location_id = cte.delivery_location_id
		AND a.contract_id = cte.contract_id
		WHERE row_id = 1
		*/
		
		;With cte_update_pri_vol AS (
			SELECT gathering_loc_id, route_id, SUM(volume) volume FROM #temp_split_data
			WHERE [type] <> 'Primary'
			GROUP BY gathering_loc_id, route_id
		)
		UPDATE #temp_split_data
		SET volume = pri.pri_vol - cte.volume
		FROM #temp_split_data td
		INNER JOIN cte_update_pri_vol cte ON cte.gathering_loc_id = td.gathering_loc_id AND td.route_id = cte.route_id
		OUTER APPLY (
			SELECT Volume pri_vol
			FROM #temp_primary_location_volume pri_vol
			WHERE pri_vol.gathering_loc = td.gathering_loc_id 
			AND pri_vol.route_id = td.route_id 
			AND pri_vol.[primary_secondary] = 'p'
		) pri
		WHERE td.type = 'Primary'	
		
		--SELECT * FROM #temp_data
		;WITH cte AS (
			SELECT @start_date [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split ,contract_id FROM #temp_split_data
	
			UNION ALL 
			SELECT DATEADD(dd, 1, [term_start]) [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split ,contract_id FROM cte WHERE DATEADD(dd, 1, [term_start]) <= @end_date
		)
		INSERT INTO #temp_split_nom ([date], gathering_loc_id, route_id, [type], delivery_location_id, volume, split,contract_id)
		SELECT [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split,contract_id FROM cte	
	END
	ELSE 
	BEGIN
		;WITH cte AS (
			SELECT @start_date [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split ,contract_id FROM #temp_data
	
			UNION ALL 
			SELECT DATEADD(dd, 1, [term_start]) [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split ,contract_id FROM cte WHERE DATEADD(dd, 1, [term_start]) <= @end_date
		)
		INSERT INTO #temp_split_nom ([date], gathering_loc_id, route_id, [type], delivery_location_id, volume, split,contract_id)
		SELECT [term_start], gathering_loc_id, route_id, [type], delivery_location_id, volume, split, contract_id FROM cte	
	END	
	
	--SELECT * FROM #temp_split_nom
	--return
	UPDATE ega
	SET volume = ISNULL ( tsn.volume , 0),
		split_percentage = ISNULL (split, 0)
	FROM equity_gas_allocation ega
    INNER JOIN #temp_split_nom tsn
    	ON  ega.location_id = tsn.gathering_loc_id
		AND  ega.route_id = tsn.route_id
		AND ega.del_location_id = tsn.delivery_location_id
		AND ega.term_start = tsn.[date]
		AND ega.contract_id=tsn.[contract_id]
   
    --insert into equity_gas_allocation table.
    INSERT INTO equity_gas_allocation
      (
        location_id,
        [del_location_id],
        [term_start],
        [volume],
        [split_percentage],
        [primary_secondary],
		[contract_id],
		route_id
      )
    SELECT tsn.gathering_loc_id,
           tsn.delivery_location_id,
           tsn.[date],
           ISNULL ( tsn.volume , 0),
           ISNULL (tsn.split, 0),
           CASE WHEN tsn.[type] = 'Primary' THEN 'p' ELSE 's' END,
		   tsn.contract_id,
		   tsn.route_id
    FROM   #temp_split_nom tsn
    LEFT JOIN equity_gas_allocation ega 
    	ON  ega.location_id = tsn.gathering_loc_id
    	AND ega.del_location_id = tsn.delivery_location_id
    	AND ega.term_start = tsn.[date]
		AND ega.contract_id = tsn.[contract_id]
		AND ega.route_id = tsn.route_id
	WHERE ega.equity_gas_allocation_id IS NULL
 
     EXEC spa_ErrorHandler 0,
         'Equity Gas Allocation',
         'spa_equity_gas_allocation_UI',
         'Success',
         'Data saved successfully.',
         ''
END TRY

BEGIN CATCH
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler -1,
	         'Equity Gas Allocation',
	         'spa_equity_gas_allocation_UI',
	         "DB Error",
	         "Error on Updating Split Volume of Equity Gas.",
	         ''
END CATCH
END
--hard coded data	
  ELSE 
IF (@flag = 't')
BEGIN
    SELECT 'Texas Gas Z1' [gathering_loc],
           'PJM RT' [delievery_loc],
           'Primary' [primary_secondary],
           9000 [Volume]
    UNION ALL
    SELECT 'Texas Gas Z1' [gathering_loc],
           'PJM Onpeak' [delievery_loc],
           'Secondary' [primary_secondary],
           0 [Volume]
    UNION ALL
    SELECT 'Texas Gas Z1' [gathering_loc],
           'PJM Offpeak' [delievery_loc],
           'Secondary' [primary_secondary],
           0 [Volume]
    UNION ALL
    SELECT 'Nymex' [gathering_loc],
           'PJM' [delievery_loc],
           'Primary' [primary_secondary],
           5000 [Volume]
    UNION ALL
    SELECT 'Nymex' [gathering_loc],
           'PJM-15 Mins' [delievery_loc],
           'Secondary' [primary_secondary],
           0 [Volume]
END--Header information of UI
ELSE IF @flag IN ('h', 'b')
BEGIN
	--DECLARE @start_date DATETIME = '2015-05-01'
	--DECLARE @end_date DATETIME = '2015-05-31'
	--DECLARE @location_id VARCHAR(20) = NULL
	--DECLARE @filter_type CHAR(1) = 's'

	IF OBJECT_ID('tempdb..#temp_split_volume') IS NOT NULL
        DROP TABLE #temp_split_volume

	IF OBJECT_ID('tempdb..#temp_existing_split_volume') IS NOT NULL
        DROP TABLE #temp_existing_split_volume
    
    CREATE TABLE #temp_split_volume (
    	gathering_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    	delievery_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    	[primary_secondary]     varchar(10) COLLATE DATABASE_DEFAULT,
		route_id				INT,
		group_id			    INT,
    	Volume                  FLOAT,
    	per_split               NUMERIC(38,20),
		contract_id				int,
		do_exists				CHAR(1) COLLATE DATABASE_DEFAULT
    )

	INSERT INTO #temp_split_volume (route_id, gathering_loc, delievery_loc, [primary_secondary], group_id, Volume,contract_id)
    EXEC spa_split_nom_volume 's',
         NULL,
         NULL,
         NULL,
         @start_date,
		 @location_id
	
	UPDATE #temp_split_volume
    SET per_split = CASE WHEN primary_secondary = 'p' THEN 1 ELSE 0 END
    WHERE per_split IS NULL
	
	IF @filter_type <> 'n'
	BEGIN
		SELECT sml.source_minor_location_id [group_loc],
			   sml2.source_minor_location_id [loc],
			   MAX(ega.volume) [volume],
			   MAX(ega.split_percentage) [sp] ,
			   temp.contract_id [contract_id],
			   temp.route_id
		INTO #temp_existing_split_volume
		FROM #temp_split_volume temp
		INNER JOIN source_minor_location sml ON  temp.gathering_loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml2 ON  sml2.source_minor_location_id = temp.delievery_loc
		INNER JOIN equity_gas_allocation ega 
    		ON  ega.location_id = sml.source_minor_location_id
    		AND ega.del_location_id = sml2.source_minor_location_id
			AND ega.contract_id = temp.contract_id
			AND ega.route_id = temp.route_id
			AND ega.primary_secondary = temp.primary_secondary
		WHERE ega.term_start BETWEEN @start_date AND @end_date
		GROUP BY sml.source_minor_location_id, temp.route_id, sml2.source_minor_location_id, temp.contract_id	

		UPDATE temp
		SET Volume = temp2.[volume],
			per_split = temp2.[sp],
			do_exists = 'y'
		FROM #temp_split_volume temp
		INNER JOIN #temp_existing_split_volume temp2
			ON  temp2.group_loc = temp.gathering_loc
			AND temp2.[loc] = temp.delievery_loc
			AND temp2.contract_id =temp.contract_id
			AND temp2.route_id = temp.route_id	
			
	END
		
	IF @filter_type = 's'
	BEGIN
		DELETE temp
		FROM #temp_split_volume temp
		LEFT JOIN (
			SELECT DISTINCT ega.location_id,  ega.route_id, ega.del_location_id, ega.contract_id
			FROM equity_gas_allocation ega 
			WHERE ega.term_start BETWEEN @start_date AND @end_date
		) ega
    	ON  ega.location_id = temp.gathering_loc
		AND ega.route_id = temp.route_id
    	AND ega.del_location_id = temp.delievery_loc
		AND ega.contract_id = temp.contract_id
		WHERE ega.location_id IS NULL
	END	

	IF @filter_type = 'n'
	BEGIN
		DELETE temp
		FROM #temp_split_volume temp
		INNER JOIN (
			SELECT DISTINCT ega.location_id, ega.route_id, ega.del_location_id, ega.contract_id
			FROM equity_gas_allocation ega 
			WHERE ega.term_start BETWEEN @start_date AND @end_date
		) ega
    	ON  ega.location_id = temp.gathering_loc
		AND ega.route_id = temp.route_id
    	AND ega.del_location_id = temp.delievery_loc
		AND ega.contract_id = temp.contract_id
		
	END	
		

	--UPDATE temp
	--SET do_exists = 'y'
	--FROM #temp_split_volume temp
	--INNER JOIN (
	--	SELECT DISTINCT ega.location_id, ega.route_id, ega.del_location_id, ega.contract_id
	--	FROM equity_gas_allocation ega 
	--	where ega.term_start BETWEEN @start_date AND @end_date
	--) a
	--ON  a.location_id = temp.gathering_loc
	--AND a.route_id = temp.route_id
 --   AND a.del_location_id = temp.delievery_loc
	--AND a.contract_id = temp.contract_id 

	IF OBJECT_ID('tempdb..#temp_final_data') IS NOT NULL
		DROP TABLE #temp_final_data

	CREATE TABLE #temp_final_data (
		route_id INT,
		route_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		group_id INT,
		group_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		gathering_location VARCHAR(500) COLLATE DATABASE_DEFAULT,
		gathering_location_id INT,
		group_volume FLOAT,
		total_volume FLOAT,
		primary_secondary VARCHAR(50) COLLATE DATABASE_DEFAULT,
		delivery_location_name VARCHAR(500) COLLATE DATABASE_DEFAULT,
		delivery_location_id INT,
		delivery_volume FLOAT,
		split_percentage	NUMERIC(38,20),
		[contract_name]		VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[contract_id]		INT
	)

	
	DECLARE @sql NVARCHAR(MAX)
	IF @flag = 'b'
	BEGIN
		SET @sql = 'INSERT INTO #temp_final_data(group_id, group_name, group_volume)
					SELECT  temp.group_id,
							sdv.description,
							SUM(temp.Volume)   AS group_volume
					FROM #temp_split_volume temp
					INNER JOIN static_data_value sdv ON sdv.value_id = temp.group_id
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.group_id, sdv.description'
		exec spa_print @sql
		EXEC(@sql)

		SET @sql = 'INSERT INTO #temp_final_data(group_id, group_name, route_id, route_name, total_volume)
					SELECT  temp.group_id,
							sdv.description,
							temp.route_id,
							mlr.route_name,
							SUM(temp.Volume)   AS total_volume
					FROM #temp_split_volume temp
					INNER JOIN static_data_value sdv ON sdv.value_id = temp.group_id
					INNER JOIN maintain_location_routes mlr ON mlr.maintain_location_routes_id = temp.route_id
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.group_id, sdv.description, temp.route_id, mlr.route_name'
		exec spa_print @sql
		EXEC(@sql)


		SET @sql = 'INSERT INTO #temp_final_data(group_id, group_name, route_id, route_name, primary_secondary, delivery_location_name, delivery_location_id, delivery_volume, split_percentage,contract_name,contract_id)
					SELECT temp.group_id,
						   sdv.description,
						   temp.route_id,
						   mlr.route_name,
						   CASE 
								WHEN temp.primary_secondary = ''p'' THEN ''Primary''
								ELSE ''Secondary''
						   END,
						   sml_del.location_id + '' - '' + sml_del.location_name,
						   temp.delievery_loc,
						   SUM(temp.Volume),
						   MAX(temp.per_split),
						   cg.contract_name,
						   cg.contract_id
					FROM #temp_split_volume temp
					INNER JOIN static_data_value sdv ON sdv.value_id = temp.group_id
					INNER JOIN maintain_location_routes mlr ON mlr.maintain_location_routes_id = temp.route_id
					INNER JOIN source_minor_location sml_del ON  temp.delievery_loc = sml_del.source_minor_location_id
					INNER JOIN contract_group cg ON cg.contract_id=temp.contract_id
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.group_id, sdv.description, temp.route_id, mlr.route_name, temp.primary_secondary, temp.delievery_loc, sml_del.location_name, sml_del.location_id, cg.contract_name, cg.contract_id
					'
		exec spa_print @sql
		EXEC(@sql)
	END
	ELSE 
	BEGIN
		SET @sql = 'INSERT INTO #temp_final_data(gathering_location_id, gathering_location, group_volume)
					SELECT  temp.gathering_loc,
							sml.location_id + '' - '' + sml.location_name,
							SUM(temp.Volume)   AS group_volume
					FROM #temp_split_volume temp
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = temp.gathering_loc
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.gathering_loc, sml.location_name, sml.location_id'
		exec spa_print @sql
		EXEC(@sql)

		SET @sql = 'INSERT INTO #temp_final_data(gathering_location_id, gathering_location, route_id, route_name, total_volume)
					SELECT  temp.gathering_loc,
							sml.location_id + '' - '' + sml.location_name,
							temp.route_id,
							mlr.route_name,
							SUM(temp.Volume)   AS total_volume
					FROM #temp_split_volume temp
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = temp.gathering_loc					
					INNER JOIN maintain_location_routes mlr ON mlr.maintain_location_routes_id = temp.route_id
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.gathering_loc, sml.location_name, sml.location_id, temp.route_id, mlr.route_name'
		exec spa_print @sql
		EXEC(@sql)

		SET @sql = 'INSERT INTO #temp_final_data(gathering_location_id, gathering_location, route_id, route_name, primary_secondary, delivery_location_name, delivery_location_id, delivery_volume, split_percentage,contract_name,contract_id)
					SELECT temp.gathering_loc,
						   sml.location_id + '' - '' + sml.location_name,
						   temp.route_id,
						   mlr.route_name,
						   CASE 
								WHEN temp.primary_secondary = ''p'' THEN ''Primary''
								ELSE ''Secondary''
						   END,
						   sml_del.location_id + '' - '' + sml_del.location_name,
						   temp.delievery_loc,
						   SUM(temp.Volume),
						   MAX(temp.per_split),
						   cg.contract_name,
						   cg.contract_id
					FROM #temp_split_volume temp
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = temp.gathering_loc
					INNER JOIN maintain_location_routes mlr ON mlr.maintain_location_routes_id = temp.route_id
					INNER JOIN source_minor_location sml_del ON  temp.delievery_loc = sml_del.source_minor_location_id
					INNER JOIN contract_group cg ON cg.contract_id=temp.contract_id
					WHERE 1 = 1
					' + CASE WHEN @filter_type = 's' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''y''' WHEN @filter_type = 'n' THEN ' AND ISNULL(temp.do_exists, ''n'') = ''n''' ELSE '' END + '
					GROUP BY temp.gathering_loc, sml.location_name, sml.location_id, temp.route_id, mlr.route_name, temp.primary_secondary, temp.delievery_loc, sml_del.location_name, sml_del.location_id, cg.contract_name, cg.contract_id
					'
		exec spa_print @sql
		EXEC(@sql)

	END

	IF NOT EXISTS(SELECT 1 FROM #temp_final_data)
	BEGIN
		SELECT 'Either there is no volume uploaded or Auto Nom has already been run.' gathering_location, 
			   NULL gathering_location_id, 			   
			   '' group_volume,
			   NULL route_id,
			   NULL route_name,
			   '' total_volume, 
			   NULL primary_secondary, 
			   NULL delivery_location_name, 
			   NULL delivery_location_id,
			   NULL [contract_name],
			   NULL delivery_volume,
			   NULL split_percentage,
			   NULL contract_id
			   

		RETURN
	END

	IF @flag = 'h'
	BEGIN
		SELECT gathering_location, 
			   gathering_location_id, 
			   group_volume,
			   route_name,
			   route_id,
			   total_volume, 
			   primary_secondary, 
			   delivery_location_name, 
			   delivery_location_id,
			   [contract_name],
			   dbo.FNARemoveTrailingZero(dbo.FNAPipelineRound(1, delivery_volume, 0)) delivery_volume,
			   dbo.FNARemoveTrailingZeroes(split_percentage) split_percentage,
			   contract_id
		FROM #temp_final_data 
		ORDER BY gathering_location, route_name, primary_secondary
	END
	ELSE IF @flag = 'b'
	BEGIN
		SELECT group_name [gathering_location], 
			   group_id [gathering_location_id], 
			   group_volume,			   
			   route_name,
			   route_id,
			   total_volume, 
			   primary_secondary, 
			   delivery_location_name, 
			   delivery_location_id,
			   [contract_name],
			   dbo.FNARemoveTrailingZero(dbo.FNAPipelineRound(1, delivery_volume, 0)) delivery_volume,
			   dbo.FNARemoveTrailingZeroes(split_percentage) split_percentage,
			   contract_id
		FROM #temp_final_data 
		ORDER BY group_name, route_name, primary_secondary
	END
END
/*
--Body information of UI
ELSE 
IF (@flag = 'b')
BEGIN
    IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
        DROP TABLE #tmp1
    
    CREATE TABLE #tmp1(
    	gathering_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    	delievery_loc           varchar(100) COLLATE DATABASE_DEFAULT,
    	[primary_secondary]     varchar(10) COLLATE DATABASE_DEFAULT,
    	Volume                  int,
    	per_split               varchar(10) COLLATE DATABASE_DEFAULT
    )
    IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
        DROP TABLE #temp3
	IF OBJECT_ID('tempdb..#temp4') IS NOT NULL
        DROP TABLE #temp4
	IF OBJECT_ID('tempdb..#temp5') IS NOT NULL
        DROP TABLE #temp5
    
    INSERT INTO #tmp1
      (
        gathering_loc,
        delievery_loc,
        [primary_secondary],
        Volume
      )
    EXEC spa_split_nom_volume 's',
         NULL,
         NULL,
         NULL,
         @start_date,
		 @location_id,
		 @group_by
    --EXEC spa_equity_gas_allocation_UI 't'
    
    UPDATE #tmp1
    SET    per_split = CASE 
                            WHEN primary_secondary = 'p' THEN 1
                            ELSE 0
                       END,
           primary_secondary = CASE 
                                    WHEN primary_secondary = 'p' THEN 'Primary'
                                    ELSE 'Secondary'
                               END
    WHERE  per_split IS NULL
    
    --select * from #tmp1
    IF @filter_type='a' 
	BEGIN
		SELECT sml.source_minor_location_id [group_loc],
			   sml2.source_minor_location_id [loc],
			   MAX(ega.volume) [volume],
			   MAX(ega.split_percentage) [sp] 
		INTO #temp3
		FROM   #tmp1 temp
		INNER JOIN source_minor_location sml 
    		ON  temp.gathering_loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml2 
    		ON  sml2.source_minor_location_id = temp.delievery_loc
		INNER JOIN equity_gas_allocation ega 
    		ON  ega.location_id = sml.source_minor_location_id
    		AND ega.del_location_id = sml2.source_minor_location_id
		WHERE ega.term_start BETWEEN @start_date AND @end_date
		GROUP BY
			   sml.source_minor_location_id,
			   sml2.source_minor_location_id
    
    
    --select * from #temp3
	
		UPDATE temp
		SET    Volume = #temp3.[volume],
			   per_split = #temp3.[sp]
		FROM   #tmp1 temp
			   INNER JOIN #temp3
					ON  #temp3.group_loc = temp.gathering_loc
		AND             #temp3.[loc] = temp.delievery_loc
    
		SELECT [primary_secondary]  AS [type],
			   sml.Location_Name    AS [del_location],
			   temp.Volume          AS [rec_volume],
			   per_split            AS [per_split],
			   '1' [lid],
			   sml1.Location_Name   AS [gathering_location]
		FROM   #tmp1 temp
		INNER JOIN source_minor_location sml  ON  temp.delievery_loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml1 ON  temp.gathering_loc = sml1.source_minor_location_id
		ORDER BY sml1.Location_Name, [primary_secondary], sml.Location_Name

	END
	ELSE IF @filter_type='s'
	BEGIN
	 SELECT sml.source_minor_location_id [group_loc],
           sml2.source_minor_location_id [loc],
           MAX(ega.volume) [volume],
           MAX(ega.split_percentage) [sp],
		   ega.primary_secondary 
    INTO #temp4
    FROM   #tmp1 temp
    INNER JOIN source_minor_location sml 
    	ON  temp.gathering_loc = sml.source_minor_location_id
    INNER JOIN source_minor_location sml2 
    	ON  sml2.source_minor_location_id = temp.delievery_loc
    INNER JOIN equity_gas_allocation ega 
    	ON  ega.location_id = sml.source_minor_location_id
    	AND ega.del_location_id = sml2.source_minor_location_id
    WHERE ega.term_start BETWEEN @start_date AND @end_date
    GROUP BY
           sml.source_minor_location_id,
           sml2.source_minor_location_id,
		   ega.primary_secondary 
	
		SELECT temp.[primary_secondary]  AS [type],
			   sml.Location_Name    AS [del_location],
			   temp.Volume          AS [rec_volume],
			   temp.sp            AS [per_split],
			   '1' [lid],
			   sml1.Location_Name   AS [gathering_location]
		FROM   #temp4 temp
		INNER JOIN source_minor_location sml  ON  temp.loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml1 ON  temp.group_loc = sml1.source_minor_location_id
		ORDER BY sml1.Location_Name, temp.[primary_secondary], sml.Location_Name
	END
	ELSE IF @filter_type='n'
	BEGIN
	SELECT sml.source_minor_location_id [group_loc],
			   sml2.source_minor_location_id [loc],
			   MAX(ega.volume) [volume],
			   MAX(ega.split_percentage) [sp],
			   ega.primary_secondary 
			   INTO #temp5
		FROM   #tmp1 temp
		INNER JOIN source_minor_location sml 
    		ON  temp.gathering_loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml2 
    		ON  sml2.source_minor_location_id = temp.delievery_loc
		INNER JOIN equity_gas_allocation ega 
    		ON  ega.location_id = sml.source_minor_location_id
    		AND ega.del_location_id = sml2.source_minor_location_id
		WHERE ega.term_start BETWEEN @start_date AND @end_date
		GROUP BY
			   sml.source_minor_location_id,
			   sml2.source_minor_location_id,
			   ega.primary_secondary 
    
    
    --select * from #temp5
	
		UPDATE temp
		SET    Volume = #temp5.[volume],
			   per_split = #temp5.[sp]
		FROM   #tmp1 temp
			   INNER JOIN #temp5
					ON  #temp5.group_loc = temp.gathering_loc
		AND             #temp5.[loc] = temp.delievery_loc
    
		SELECT [primary_secondary]  AS [type],
			   sml.Location_Name    AS [del_location],
			   temp.Volume          AS [rec_volume],
			   per_split            AS [per_split],
			   '1' [lid],
			   sml1.Location_Name   AS [gathering_location]
		FROM   #tmp1 temp
		INNER JOIN source_minor_location sml  ON  temp.delievery_loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml1 ON  temp.gathering_loc = sml1.source_minor_location_id
		except(
		SELECT t1.[primary_secondary]  AS [type],
			   sml.Location_Name    AS [del_location],
			   t1.Volume          AS [rec_volume],
			   t1.sp            AS [per_split],
			   '1' [lid],
			   sml1.Location_Name   AS [gathering_location]
		FROM   #temp5 t1
		INNER JOIN source_minor_location sml  ON  t1.loc = sml.source_minor_location_id
		INNER JOIN source_minor_location sml1 ON  t1.group_loc = sml1.source_minor_location_id
		)
		ORDER BY [gathering_location],[type],[del_location]
		--ORDER BY sml1.Location_Name, [primary_secondary], sml.Location_Name
	END
END--Hard coded DATA
   -- IF @flag = 'h'
   --BEGIN
   --  SELECT
   --    'Texas Gas Z1' [gathering_location],
   --    1 [tid],
   --    --'' [type],
   --    --'' [del_location],
   --    9000 [rec_volume]
   --  -- '' [per_split]
   --  UNION ALL
   --  SELECT
   --    'Nymex' [gathering_location],
   --    2 [tid],
   --    --'' [type],
   --    --'' [del_location],
   --    5000 [rec_volume]
   ----'' [per_split]
   --END
   --ELSE
   --IF (@flag = 'b')
   --BEGIN
   --  SELECT
   --    'Primary' [type],
   --    'PJM RT' [del_location],
   --    9000 [rec_volume],
   --    '1' [per_split],
   --    '1' [lid],
   --    'Texas Gas Z1' [gathering_location]
   --  UNION ALL
   --  SELECT
   --    'Secondary' [type],
   --    'PJM Onpeak' [del_location],
   --    0 [rec_volume],
   --    '0' [per_split],
   --    '1' [lid],
   --    'Texas Gas Z1' [gathering_location]
   --  UNION ALL
   --  SELECT
   --    'Secondary' [type],
   --    'PJM Offpeak' [del_location],
   --    0 [rec_volume],
   --    '0' [per_split],
   --    '1' [lid],
   --    'Texas Gas Z1' [gathering_location]
   --  UNION ALL
   --  SELECT
   --    'Primary' [type],
   --    'PJM' [del_location],
   --    5000 [rec_volume],
   --    '1' [per_split],
   --    '2' [lid],
   --    'Nymex' [gathering_location]
   --  UNION ALL
   --  SELECT
   --    'Secondary' [type],
   --    'PJM-15 Mins' [del_location],
   --    0 [rec_volume],
   --    '0' [per_split],
   --    '2' [lid],
   --    'Nymex' [gathering_location]
   --END
   --ELSE

*/
