
/*
Created By: Tara Nath Subedi
Created On:23 06 2010
Issue Against: 2935
Comments: This SP is used to import activity data(simpler logic). This will insert data in the table ems_gen_input
exec spa_import_activity_data_simplerlogic  'adiha_process.dbo.Activity_Data_New_farrms_admin_A08B2B34_B54D_4D3D_8D8D_0035AFD2053B','Activity_Data_New', 'importdata_5463_2F8F3A7F_BC1C_4E43_8759_7FCB835BB033', '2F8F3A7F_BC1C_4E43_8759_7FCB835BB033','farrms_admin'

*/

IF OBJECT_ID(N'[dbo].[spa_import_activity_data_simplerlogic]', N'P') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_import_activity_data_simplerlogic]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_activity_data_simplerlogic]
    @temp_table_name VARCHAR(100),
    @table_id VARCHAR(100),
    @job_name VARCHAR(100),
    @process_id VARCHAR(100),
    @user_login_id VARCHAR(50)
AS 
    BEGIN  

        DECLARE @sql VARCHAR(8000),
				@errorCount INT,
				@all_row_count INT

        BEGIN TRY
            SET @errorCount = 0
            SET @process_id = REPLACE(NEWID(), '-', '_')


            CREATE TABLE #temp_activity
                (
                  [id] INT IDENTITY(1, 1),
                  [FacilityID] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [input] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [month] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [year] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [value] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [uom] [varchar](250) COLLATE DATABASE_DEFAULT,
                  [price] [varchar](250) COLLATE DATABASE_DEFAULT
                )


            EXEC ( 'INSERT INTO
					 #temp_activity 
			 SELECT 
					NULLIF(ltrim(rtrim(FacilityID)),''NULL''),
					NULLIF(ltrim(rtrim(input)),''NULL''),
					NULLIF(ltrim(rtrim(month)),''NULL''),
					NULLIF(ltrim(rtrim(year)),''NULL''),
					NULLIF(ltrim(rtrim(value)),''NULL''),
					NULLIF(ltrim(rtrim(uom)),''NULL''),
					NULLIF(ltrim(rtrim(price)),''NULL'')
			 from
				' + @temp_table_name
                )

	-------########### delete the data whose facilityid is null
            DELETE  FROM #temp_activity
            WHERE   FacilityID IS NULL
	--#################
            CREATE TABLE #import_status_detail
                (
                  temp_id INT IDENTITY(1, 1),
                  process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  ErrorCode VARCHAR(50) COLLATE DATABASE_DEFAULT,
                  Module VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  Source VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  type VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  [description] VARCHAR(250) COLLATE DATABASE_DEFAULT,
                  [nextstep] VARCHAR(250) COLLATE DATABASE_DEFAULT,
                  [id] INT
                )

            CREATE TABLE #import_status
                (
                  temp_id INT IDENTITY(1, 1),
                  process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  ErrorCode VARCHAR(50) COLLATE DATABASE_DEFAULT,
                  Module VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  Source VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  type VARCHAR(100) COLLATE DATABASE_DEFAULT,
                  [description] VARCHAR(250) COLLATE DATABASE_DEFAULT,
                  [nextstep] VARCHAR(250) COLLATE DATABASE_DEFAULT
                )

--select * from #temp_activity 

	--** Log the errors fo the data that does not exists in the system
	--** check for Sources/Sinks
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Source/Sinks : ' + ( ta.facilityID )
                            + ' not found in the System.',
                            'Please Check Source to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                            LEFT JOIN rec_generator rg ON ta.facilityID = LTRIM(RTRIM(rg.id))
                    WHERE   rg.generator_id IS NULL


	--** check for Input/Outputs (_use)
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Input/Output : ' + ( ta.input )
                            + '_use not found in the System.',
                            'Please Check Input to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                            LEFT JOIN ems_source_input esi ON ta.input + '_use' = esi.input_name
                    WHERE   esi.ems_source_input_id IS NULL	

	--** check for Input/Outputs (_price)
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Input/Output : ' + ( ta.input )
                            + '_price not found in the System.',
                            'Please Check Input to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                            LEFT JOIN ems_source_input esi ON ta.input + '_price' = esi.input_name
                    WHERE   esi.ems_source_input_id IS NULL	

	--** check for month 
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Month : ' + ( ta.[month] ) + ' not valid.',
                            'Please Check month to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   NOT ( ( ISNUMERIC(ta.[month]) = 1
                                    AND ta.[month] BETWEEN 1 AND 12
                                  )
                                  OR ta.[month] IN ( 'Jan', 'Feb', 'Mar',
                                                     'Apr', 'May', 'Jun',
                                                     'Jul', 'Aug', 'Sep',
                                                     'Oct', 'Nov', 'Dec',
                                                     'January', 'February',
                                                     'March', 'April', 'May',
                                                     'June', 'July', 'August',
                                                     'September', 'October',
                                                     'November', 'December' )
                                )

	--** check for year 
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Year : ' + ( ta.[year] ) + ' not valid.',
                            'Please Check year to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   NOT ( ISNUMERIC(ta.[year]) = 1
                                  AND LEN(ta.[year]) = 4
                                )	 

--check for duplication on facilityid,input,year,month
--when there are no other errors. 
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Duplication on:: Source: ' + ta.facilityid
                            + ' Input: ' + ta.input + ' Year: ' + ta.[year]
                            + ' Month: ' + CASE WHEN ISNUMERIC(ta.[month]) = 1
															   THEN ta.[month]
															   ELSE CAST(dbo.FNAGetMonthAsInt(ta.[month]) AS VARCHAR)
															   END,
                            'Please check the data and re-import',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   ta.id IN (
                            SELECT  a.id
                            FROM    #temp_activity a
                                    INNER JOIN ( SELECT facilityid,
                                                        input,
                                                        [year],
                                                        + CASE WHEN ISNUMERIC([month]) = 1
															   THEN [month]
															   ELSE CAST(dbo.FNAGetMonthAsInt([month]) AS VARCHAR)
															   END AS [month]
                                                 FROM   #temp_activity
												 WHERE   id NOT IN (
												 		 SELECT DISTINCT
																id
														 FROM    #import_status_detail )
                                                 GROUP BY facilityid,
                                                        input,
                                                        [year], 
                                                        CASE WHEN ISNUMERIC([month]) = 1
															   THEN [month]
															   ELSE CAST(dbo.FNAGetMonthAsInt([month]) AS VARCHAR)
															   END 
                                                 HAVING COUNT(*) > 1
                                               ) b ON a.facilityid = b.facilityid
                                                      AND a.input = b.input
                                                      AND a.[year] = b.[year]
                                                      AND  CASE WHEN ISNUMERIC(a.[month]) = 1
															   THEN a.[month]
															   ELSE CAST(dbo.FNAGetMonthAsInt(a.[month]) AS VARCHAR)
															   END  = b.[month]
																
                            WHERE   a.id NOT IN (
                                    SELECT DISTINCT
                                            id
                                    FROM    #import_status_detail ))

	--** check for UOM
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'UOM : ' + ( ta.uom )
                            + ' not found in the System.',
                            'Please Check UOM to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                            LEFT JOIN source_uom su ON ta.uom = su.uom_id
                    WHERE   su.source_uom_id IS NULL	


	--** check for value 
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Value : ' + ( ISNULL(ta.[value],'NULL') ) + ' not valid.',
                            'Please Check value to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   ta.[value] IS NULL
							OR ta.[value] ='NULL'
                            OR ISNUMERIC(ta.[value]) <> 1 

	--** check for price
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Price : ' + ( ISNULL(ta.[price],'NULL') ) + ' not valid.',
                            'Please Check price to verify',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   ta.[price] = '0'
                            OR ta.[price] IS NULL
							OR ta.[price] ='NULL'
                            OR ISNUMERIC(ta.[price]) <> 1 
   


-- check if constant input have multiple activity data then give error
-- _use 
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Input/Output : ' + ( ta.input )
                            + '_use is a constant input and can have only one value.',
                            'Please check the data and re-import',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   ta.input IN (
                            SELECT  ta.input
                            FROM    #temp_activity ta
                                    LEFT JOIN ems_source_input esi ON ta.input + '_use' = esi.input_name
                            WHERE   ISNULL(esi.constant_value, 'n') = 'y'
                            GROUP BY ta.input
                            HAVING  COUNT(*) > 1 )

-- check if constant input have multiple activity data then give error
-- _price
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Input/Output : ' + ( ta.input )
                            + '_price is a constant input and can have only one value.',
                            'Please check the data and re-import',
                            ta.[id]
                    FROM    #temp_activity ta
                    WHERE   ta.input IN (
                            SELECT  ta.input
                            FROM    #temp_activity ta
                                    LEFT JOIN ems_source_input esi ON ta.input + '_price' = esi.input_name
                            WHERE   ISNULL(esi.constant_value, 'n') = 'y'
                            GROUP BY ta.input
                            HAVING  COUNT(*) > 1 )

--select * from #import_status_detail

--value (with _use)
            SELECT  rg.generator_id,
                    esi.ems_source_input_id,
                    'r' AS estimate_type,
                    CAST(ta.[year] + '-'
                    + CASE WHEN ISNUMERIC(ta.[month]) = 1 THEN ta.[month]
                           ELSE CAST(dbo.FNAGetMonthAsInt(ta.[month]) AS VARCHAR)
                      END + '-01' AS DATETIME) AS term_start,
                    DATEADD(month, 1,
                            CAST(ta.[year] + '-'
                            + CASE WHEN ISNUMERIC(ta.[month]) = 1
                                   THEN ta.[month]
                                   ELSE CAST(dbo.FNAGetMonthAsInt(ta.[month]) AS VARCHAR)
                              END + '-01' AS DATETIME)) - 1 AS term_end,
                    '703' frequency,
                    NULL AS char1,
                    NULL AS char2,
                    NULL AS char3,
                    NULL AS char4,
                    NULL AS char5,
                    NULL AS char6,
                    NULL AS char7,
                    NULL AS char8,
                    NULL AS char9,
                    NULL AS char10,
                    CASE WHEN ISNUMERIC(ta.[value])=1 THEN CAST(ta.[value] AS FLOAT) ELSE 0.00 END AS input_value,
                    su.source_uom_id AS uom_id,
                    NULL AS Forecast_type,
                    ISNULL(esi.constant_value, 'n') AS constant_value,
                    ta.[id],
                    rg.[name] generator_name
            INTO    #temp_generator
            FROM    #temp_activity ta
                    JOIN rec_generator rg ON LTRIM(RTRIM(rg.[id])) = ta.facilityid
                    JOIN ems_source_input esi ON esi.input_name = ta.input
                                                 + '_use'
                    LEFT JOIN source_uom su ON ta.UOM = su.uom_id
            WHERE   ta.id NOT IN ( SELECT DISTINCT
                                            id
                                   FROM     #import_status_detail ) --to filter erroroneas records.

--price (_price)
            INSERT  INTO #temp_generator
                    SELECT  rg.generator_id,
                            esi.ems_source_input_id,
                            'r' AS estimate_type,
                            CAST(ta.[year] + '-'
                            + CASE WHEN ISNUMERIC(ta.[month]) = 1
                                   THEN ta.[month]
                                   ELSE CAST(dbo.FNAGetMonthAsInt(ta.[month]) AS VARCHAR)
                              END + '-01' AS DATETIME) AS term_start,
                            DATEADD(month, 1,
                                    CAST(ta.[year] + '-'
                                    + CASE WHEN ISNUMERIC(ta.[month]) = 1
                                           THEN ta.[month]
                                           ELSE CAST(dbo.FNAGetMonthAsInt(ta.[month]) AS VARCHAR)
                                      END + '-01' AS DATETIME)) - 1 AS term_end,
                            '703' frequency,
                            NULL AS char1,
                            NULL AS char2,
                            NULL AS char3,
                            NULL AS char4,
                            NULL AS char5,
                            NULL AS char6,
                            NULL AS char7,
                            NULL AS char8,
                            NULL AS char9,
                            NULL AS char10,
                            CASE WHEN ISNUMERIC(ta.[price])=1 THEN CAST(ta.[price] AS FLOAT) ELSE 0.00 END AS input_value,
                            esi.uom_id AS uom_id,
                            NULL AS Forecast_type,
                            ISNULL(esi.constant_value, 'n') AS constant_value,
                            ta.[id],
                            rg.[name] generator_name
                    FROM    #temp_activity ta
                            JOIN rec_generator rg ON LTRIM(RTRIM(rg.[id])) = ta.facilityid
                            JOIN ems_source_input esi ON esi.input_name = ta.input
                                                         + '_price'                          
                    WHERE   ta.id NOT IN ( SELECT DISTINCT
                                                    id
                                           FROM     #import_status_detail ) --to filter erroroneas records.


--SELECT * FROM #temp_generator


----########## check for the input validations
            INSERT  INTO #import_status_detail
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      [type],
                      description,
                      nextstep,
                      [id]
                    )
                    SELECT  @process_id,
                            'Error',
                            'Import Data',
                            'Activity Data',
                            'Data Error',
                            'Inavalid Input value found for the source '
                            + rg.[name] + '. Input value for '
                            + dbo.FNAEmissionHyperlink(2, 12101300,
                                                       esi.input_name,
                                                       esi.ems_source_input_id,
                                                       NULL)
                            + ' should be between '
                            + CAST(ISNULL(min_value, '') AS VARCHAR) + ' and '
                            + CAST(ISNULL(max_value, '') AS VARCHAR) + '.',
                            'Please check the data and re-import',
                            ta.[id]
                    FROM    #temp_generator ta
                            INNER JOIN ems_input_valid_values eiv ON ta.ems_source_input_id = eiv.ems_source_input_id
                            INNER JOIN rec_generator rg ON rg.generator_id = ta.generator_id
                            INNER JOIN ems_source_input esi ON ta.ems_source_input_id = esi.ems_source_input_id
                    WHERE   ( ISNULL(ta.input_value, 0) < ISNULL(min_value, -999999999)
                              OR ISNULL(ta.input_value, 0) > ISNULL(max_value, 999999999)
                            )

	--** Now delete the data tha has errors
            DELETE  a
            FROM    #temp_generator a,
                    #import_status_detail b
            WHERE   a.[id] = b.[id]


---#########################################

            DELETE  egi
            FROM    ems_gen_input egi
                    INNER JOIN #temp_generator tg ON egi.generator_id = tg.generator_id
                                                     AND tg.ems_source_input_id = egi.ems_input_id
                                                     AND ( ( tg.constant_value = 'n'
                                                             AND tg.term_start = egi.term_start
                                                           )
                                                           OR tg.constant_value = 'y'
                                                         )

            INSERT  INTO ems_gen_input
                    (
                      generator_id,
                      ems_input_id,
                      estimate_type,
                      term_start,
                      term_end,
                      char1,
                      char2,
                      char3,
                      char4,
                      char5,
                      char6,
                      char7,
                      char8,
                      char9,
                      char10,
                      frequency,
                      input_value,
                      uom_id
                    )
                    SELECT DISTINCT
                            tg.generator_id,
                            ems_source_input_id AS ems_input_id,
                            estimate_type,
                            term_start,
                            term_end,
                            char1,
                            char2,
                            char3,
                            char4,
                            char5,
                            char6,
                            char7,
                            char8,
                            char9,
                            char10,
                            MAX(frequency),
                            MAX(CASE WHEN input_value < 0
                                          AND esme.ems_source_model_id NOT IN (
                                          134, 135 ) THEN 0
                                     ELSE input_value
                                END),
                            MAX(uom_id)
                    FROM    #temp_generator tg
                            INNER JOIN dbo.ems_source_model_effective esme ON esme.generator_id = tg.generator_id
                            INNER JOIN ( SELECT MAX(ISNULL(effective_date,
                                                           '1900-01-01')) effective_date,
                                                generator_id
                                         FROM   dbo.ems_source_model_effective
                                         WHERE  1 = 1
                                         GROUP BY generator_id
                                       ) ab ON esme.generator_id = ab.generator_id
                                               AND ISNULL(esme.effective_date,
                                                          '1900-01-01') = ab.effective_date
                    GROUP BY tg.generator_id,
                            ems_source_input_id,
                            estimate_type,
                            term_start,
                            term_end,
                            char1,
                            char2,
                            char3,
                            char4,
                            char5,
                            char6,
                            char7,
                            char8,
                            char9,
                            char10


-----###########################################

            SET @all_row_count = ( SELECT   COUNT(*)
                                   FROM     #temp_activity
                                 )

--			 INSERT INTO #import_status
--					(
--					  process_id,
--					  ErrorCode,
--					  Module,
--					  Source,
--					  type,
--					  [description],
--					  [nextstep]
--					)
--					SELECT  @process_id,
--							'Success',
--							'Import Data',
--							'Activity Data',
--							'Activity Data',
--							'Source: ''' + rg.[name] + ''' Imported.',
--							''
--					FROM    #temp_generator tg
--							JOIN rec_generator rg ON rg.generator_id = tg.generator_id
--					GROUP BY rg.[name]

            INSERT  INTO #import_status
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      type,
                      [description],
                      [nextstep]
                    )
                    SELECT  @process_id,
                            'Success',
                            'Import Data',
                            'Activity Data',
                            'Activity Data',
                            'Source: ''' + rg.[name] + ''' Input:'''
                            + esi.input_name + ''' Imported.',
                            ''
                    FROM    #temp_generator tg
                            JOIN rec_generator rg ON rg.generator_id = tg.generator_id
                            JOIN ems_source_input esi ON tg.ems_source_input_id = esi.ems_source_input_id
                    GROUP BY rg.[name],
                            esi.[input_name]


            DECLARE @msg_rec VARCHAR(1000),
                @url VARCHAR(5000),
                @desc VARCHAR(5000),
                @errorcode VARCHAR(10),
                @totalcount INT

            INSERT  INTO #import_status
                    (
                      process_id,
                      ErrorCode,
                      Module,
                      Source,
                      type,
                      [description],
                      [nextstep]
                    )
                    SELECT DISTINCT
                            process_id,
                            ErrorCode,
                            Module,
                            Source,
                            type,
                            '<a target="_blank" href="'
                            + '../dev/spa_html.php?__user_name__='
                            + @user_login_id
                            + '&spa=exec spa_get_import_process_status_detail '''
                            + @process_id + '''">' + 'Some errors found',
                            'Please check the Data'
                    FROM    #import_status_detail

	-----###########################################

            INSERT  INTO source_system_data_import_status
                    (
                      process_id,
                      code,
                      module,
                      source,
                      type,
                      [description],
                      recommendation
                    )
                    SELECT DISTINCT
                            process_id,
                            ErrorCode,
                            Module,
                            Source,
                            type,
                            [description],
                            [nextstep]
                    FROM    #import_status



            INSERT  INTO source_system_data_import_status_detail
                    (
                      process_id,
                      source,
                      type,
                      [description]
                    )
                    SELECT DISTINCT
                            process_id,
                            source,
                            type,
                            [description]
                    FROM    #import_status_detail

	-----###########################################

            SET @totalcount = ( SELECT  COUNT(*)
                                FROM    #temp_generator
                              ) /2 
            IF @totalcount <= 0 
                SET @msg_rec = 'No Data Found to import.'
            ELSE 
                SET @msg_rec = CAST(@totalcount AS VARCHAR) + '/' + CAST(@all_row_count AS VARCHAR)
                    + ' data imported.'



            IF EXISTS ( SELECT  ErrorCode
                        FROM    #import_status
                        WHERE   ErrorCode = 'Error' ) 
                SET @errorcode = 'e'
            ELSE 
                SET @errorcode = 's'


            SELECT  @url = './dev/spa_html.php?__user_name__='
                    + @user_login_id
                    + '&spa=exec spa_get_import_process_status '''
                    + @process_id + ''',''' + @user_login_id + ''''  
	   
            SELECT  @desc = '<a target="_blank" href="' + @url + '">'
                    + 'Activity Import process Completed:' + @msg_rec
                    + CASE WHEN ( @errorcode = 'e' ) THEN ' (ERRORS found)'
                           ELSE ''
                      END + '.</a>'  
	   
            EXEC spa_message_board 'i', @user_login_id, NULL,
                'Import.Activity', @desc, '', '', @errorcode,
                'Activity Import'  

	-----###########################################	   

        END TRY
        BEGIN CATCH

            SET @desc = 'Error Found in Catch: ' + ERROR_MESSAGE()

            SET @desc = 'Import Activity Data did not complete.'
                + ' (ERRORS found: ' + @desc + ')'
				
            EXEC spa_message_board 'i', @user_login_id, NULL,
                'Import.Activity', @desc, '', '', 'e', @job_name

        END CATCH

    END
