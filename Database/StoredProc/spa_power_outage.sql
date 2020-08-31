/****** Object:  StoredProcedure [dbo].[spa_power_outage]    Script Date: 07/29/2009 18:34:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_power_outage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_power_outage]
/****** Object:  StoredProcedure [dbo].[spa_power_outage]    Script Date: 07/29/2009 18:34:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [spa_power_outage] 's'

CREATE PROCEDURE [dbo].[spa_power_outage]
	@flag CHAR(1),
	@power_outage_id INT = NULL,
	@source_generator_id INT = NULL,
	@planned_start DATETIME = NULL,
	@planned_end DATETIME = NULL,
	@actual_start DATETIME = NULL,
	@actual_end DATETIME = NULL,
	@granularity INT = NULL,
	@status CHAR(1) = NULL,
	@request_type CHAR(1) = NULL,
	@outage FLOAT = NULL
AS 
					
DECLARE @sql       VARCHAR(5000),
        @min_incr  INT,
        @dt_start  DATETIME,
        @dt_end    DATETIME,
        @msg_err   VARCHAR(2000),
		@user_login_id VARCHAR(100)

SET @user_login_id = dbo.FNADBUser();

SELECT @min_incr = CASE @granularity
                        WHEN 980 THEN 30 * 24 * 60 ----	Monthly
                        WHEN 981 THEN 24 * 60 -- Daily
                        WHEN 982 THEN 60 --	Hourly
                        WHEN 990 THEN 7 * 24 * 60 -- Weekly
                        WHEN 991 THEN 3 * 30 * 24 * 60 -- Quaterly
                        WHEN 992 THEN 6 * 30 * 24 * 60 -- Semi-Annually
                        WHEN 993 THEN 12 * 30 * 24 * 60 -- Annually
                        WHEN 989 THEN 30 --	30Min
                        WHEN 987 THEN 15 --	15Min
                   END
                   				
SET @dt_start = ISNULL(@actual_start, @planned_start) 
SET @dt_end = ISNULL(@actual_end, @planned_end) 
IF (DATEDIFF(mi, @dt_start, @dt_end)%@min_incr) <> 0
BEGIN
	SET @dt_end = DATEADD(Mi, @min_incr -(DATEDIFF(mi, @dt_start, @dt_end)%@min_incr), @dt_end);
END
--PRINT @dt_end			
BEGIN TRY
	IF @flag = 's' 
	BEGIN
		SELECT @sql = 'SELECT power_outage_id AS [Power Outage ID],
							  po.source_generator_id AS [Source Generator ID],
							  sml.[location_name] [Generator Name],
							  Outage,
							  planned_start [Planned Start],
							  planned_end [Planned End],
							  actual_start [Actual Start],
							  actual_end [Actual End],
							  granularity [Granularity ID],
							  sdv.code [Granularity],
							  CASE 
								   WHEN STATUS = ''a'' THEN ''Accepted''
								   WHEN STATUS = ''c'' THEN ''Cancelled''
								   ELSE ''Submitted''
							  END [Status],
							  CASE 
								   WHEN request_type = ''p'' THEN ''Planned''
								   WHEN request_type = ''e'' THEN ''EMERGENCY''
								   ELSE ''Informational''
							  END [Request Type]
					   FROM  power_outage po
					   LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = po.source_generator_id
					   --LEFT JOIN rec_generator rg ON  rg.generator_id = po.source_generator_id
					   LEFT JOIN dbo.static_data_value sdv ON  sdv.value_id = po.granularity
					   WHERE  1 = 1 '

	   If @source_generator_id is not NULL 
		   SET @sql = @sql + ' AND sg.source_generator_id ='+CAST(@source_generator_id AS VARCHAR)
           
		IF (@actual_start IS NOT NULL) 
			SET @sql = @sql+ ' AND actual_start  > ='''+ CAST(@actual_start AS VARCHAR) +''''
			
		IF (@actual_end IS NOT NULL) 
			SET @sql = @sql+ ' AND actual_start  < ='''+ CAST(@actual_end AS VARCHAR) + ''''
			
		--PRINT @sql
		EXEC(@sql)
	END 
	
	Else IF @flag = 'm' 
	BEGIN
		SELECT @sql = 'SELECT 
							 sml.[location_name] [Generator Name],
							-- po.source_generator_id [Generator ID],
							  CASE WHEN type_name = ''o'' THEN ''Outage'' ELSE ''Derate'' END [Derate/Outage],
							  power_outage_id AS [Power Outage ID],
							  dbo.FNADateTimeFormat(planned_start, '''') [Planned Start],
							  dbo.FNADateTimeFormat(planned_end, '''') [Planned End],
							  dbo.FNADateTimeFormat(actual_start, '''') [Actual Start],
							  dbo.FNADateTimeFormat(actual_end, '''') [Actual End],
							  granularity [Granularity ID],
							  sdv.code [Granularity],
							  CASE 
								   WHEN STATUS = ''a'' THEN ''Accepted''
								   WHEN STATUS = ''c'' THEN ''Cancelled''
								   ELSE ''Submitted''
							  END [Status],
							  CASE 
								   WHEN request_type = ''p'' THEN ''Planned''
								   WHEN request_type = ''e'' THEN ''EMERGENCY''
								   ELSE ''Informational''
							  END [Request Type],							  
							  derate_mw,
							  derate_percent, 
							  comments			
					   FROM  power_outage po
					   LEFT JOIN source_minor_location sml ON  sml.source_minor_location_id = po.source_generator_id					   
					   --LEFT JOIN rec_generator rg ON  rg.generator_id = po.source_generator_id
					   LEFT JOIN dbo.static_data_value sdv ON  sdv.value_id = po.granularity
					   WHERE  1 = 1 '

	   If @source_generator_id is not NULL 
		   SET @sql = @sql + ' AND sg.source_generator_id ='+CAST(@source_generator_id AS VARCHAR)
           
		IF (@actual_start IS NOT NULL) 
			SET @sql = @sql+ ' AND actual_start  > ='''+ CAST(@actual_start AS VARCHAR) +''''
			
		IF (@actual_end IS NOT NULL) 
			SET @sql = @sql+ ' AND actual_start  < ='''+ CAST(@actual_end AS VARCHAR) + ''''

		SET @sql = @sql + ' ORDER BY sml.[location_name]'
			
		--PRINT @sql
		EXEC(@sql)
	END 
    ELSE IF @flag = 'a' 
    BEGIN
        SELECT source_generator_id,
               dbo.FNADateFormat(planned_start),
               RIGHT('0' + CAST(DATEPART(hh, planned_start) AS VARCHAR), 2) planned_start_hour,
               RIGHT('0' + CAST(DATEPART(mi, planned_start) AS VARCHAR), 2) planned_start_min,
               dbo.FNADateFormat(planned_end),
               RIGHT('0' + CAST(DATEPART(hh, planned_end) AS VARCHAR), 2) planned_end_hour,
               RIGHT('0' + CAST(DATEPART(mi, planned_end) AS VARCHAR), 2) planned_end_min,
               dbo.FNADateFormat(actual_start),
               RIGHT('0' + CAST(DATEPART(hh, actual_start) AS VARCHAR), 2) actual_start_hour,
               RIGHT('0' + CAST(DATEPART(mi, actual_start) AS VARCHAR), 2) actual_start_min,
               dbo.FNADateFormat(actual_end),
               RIGHT('0' + CAST(DATEPART(hh, actual_end) AS VARCHAR), 2) actual_end_hour,
               RIGHT('0' + CAST(DATEPART(mi, actual_end) AS VARCHAR), 2) actual_end_min,
               granularity,
               STATUS,
               request_type,
               outage
        FROM   power_outage
        WHERE  power_outage_id = @power_outage_id       
    END 
    ELSE IF @flag ='i'
    BEGIN
		INSERT INTO power_outage (
			source_generator_id,
			planned_start,
			planned_end,
			actual_start,
			actual_end,
			granularity,
			STATUS,
			request_type,
			outage
		  )
		VALUES (
			@source_generator_id,
			@planned_start,
			CASE 
				 WHEN @planned_end IS NOT NULL THEN @dt_end
				 ELSE NULL
			END,
			@actual_start,
			CASE 
				 WHEN @actual_end IS NOT NULL THEN @dt_end
				 ELSE NULL
			END,
			@granularity,
			@status,
			@request_type,
			@outage
		  )
		SET @power_outage_id = SCOPE_IDENTITY();
		
		;WITH MIN_Data(dt, min_data) AS (
           SELECT @dt_start,
                  DATEDIFF(mi, CAST(CONVERT(VARCHAR(10), @dt_start, 120) AS DATETIME), @dt_start)
           UNION ALL
           SELECT DATEADD(mi, @min_incr, dt),
                  min_data + @min_incr
           FROM   MIN_Data
           WHERE  DATEADD(mi, @min_incr, dt) <= @dt_end
        )
		INSERT INTO power_outage_detail (power_outage_id, outage_date, outage_min)
		SELECT @power_outage_id, dt, min_data
		FROM   MIN_Data
		OPTION (maxrecursion 0)	
	END
	ELSE IF @flag = 'u'
	BEGIN						
		IF EXISTS(
		       SELECT *
		       FROM   power_outage
		       WHERE  (ISNULL(planned_start, '') <> ISNULL(@planned_start, '')
	                  OR ISNULL(planned_end, '') <> ISNULL(@planned_end, '')
	                  OR ISNULL(actual_start, '') <> ISNULL(@actual_start, '')
	                  OR ISNULL(actual_end, '') <> ISNULL(@actual_end, '')
	                  OR ISNULL(granularity, '') <> ISNULL(@granularity, '')
		              )
		      AND power_outage_id = @power_outage_id
		   )
		BEGIN					    
			DELETE power_outage_detail WHERE power_outage_id = @power_outage_id;
			
			;WITH MIN_Data(dt, min_data) AS (
				SELECT @dt_start,
					   DATEDIFF(mi, CAST(CONVERT(VARCHAR(10), @dt_start, 120) AS DATETIME), @dt_start)
				UNION ALL
				SELECT DATEADD(mi, @min_incr, dt),
					   min_data + @min_incr
				FROM   MIN_Data
				WHERE  DATEADD(mi, @min_incr, dt) <= @dt_end
			)
			INSERT INTO power_outage_detail(power_outage_id, outage_date, outage_min)
			SELECT @power_outage_id, dt,min_data FROM MIN_Data
			OPTION (maxrecursion 0)
		END					
		UPDATE power_outage
		SET    source_generator_id = @source_generator_id,
		       planned_start = @planned_start,
		       planned_end = CASE 
		                          WHEN @planned_end IS NOT NULL THEN @dt_end
		                          ELSE NULL
		                     END,
		       actual_start = @actual_start,
		       actual_end = CASE 
		                         WHEN @actual_end IS NOT NULL THEN @dt_end
		                         ELSE NULL
		                    END,
		       granularity = @granularity,
		       STATUS = @status,
		       request_type = @request_type,
		       outage = @outage
		WHERE  power_outage_id = @power_outage_id
	END        
	ELSE IF @flag = 'd'
	BEGIN 
		SELECT  @source_generator_id = source_generator_id,
				@actual_start = actual_start,
				@actual_end = actual_end,
				@planned_start = planned_start,
				@planned_end = planned_end
		FROM power_outage
		WHERE power_outage_id = @power_outage_id
		
		DELETE FROM power_outage_detail WHERE power_outage_id = @power_outage_id
		DELETE FROM power_outage WHERE power_outage_id = @power_outage_id
		
		SET @dt_start = ISNULL(@actual_start, @planned_start)
		SET @dt_end = ISNULL(@actual_end, @planned_end)
	END 
	
	DECLARE @msg VARCHAR(2000)
    SELECT  @msg = ''
    
    IF @flag IN ('i', 'u', 'd')
    BEGIN
    	DECLARE @alert_process_table VARCHAR(300)
    	DECLARE @process_id VARCHAR(200) = dbo.FNAGetNewID()
		SET @alert_process_table = 'adiha_process.dbo.alert_deal_power_outage_' + @process_id + '_adpo'

		EXEC ('CREATE TABLE ' + @alert_process_table + ' (
		       	generator_id  VARCHAR(500),
		       	term_start    DATETIME,
		       	term_end      DATETIME,
		       	[start_hr]	  VARCHAR(20),
		       	[end_hr]	  VARCHAR(20),
		       	[action]      CHAR(1),
		       	hyperlink1    VARCHAR(5000),
		       	hyperlink2    VARCHAR(5000),
		       	hyperlink3    VARCHAR(5000),
		       	hyperlink4    VARCHAR(5000),
		       	hyperlink5    VARCHAR(5000)
		       )')		       
		
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(generator_id, term_start, term_end, [action])
					VALUES (
						' + CAST(@source_generator_id AS VARCHAR(20)) + ',
						' + COALESCE('''' + CONVERT(VARCHAR(100), ISNULL(@actual_start, @planned_start), 120) + '''', 'NULL') + ',
						' + COALESCE('''' + CONVERT(VARCHAR(100), ISNULL(@actual_end, @planned_end), 120) + '''', 'NULL') + ',						
						''' + @flag + '''
					) '
		--PRINT(@sql)
		EXEC(@sql)
				
		EXEC spa_register_event 20601, 20519, @alert_process_table, 1, @process_id
		EXEC spa_power_outage_process @flag, @source_generator_id, @dt_start, @dt_end, @power_outage_id
    END
    
	IF @flag = 'p'
	BEGIN
		DECLARE @source_deal_header_id INT
		
		SELECT @source_deal_header_id = MAX(sdd.source_deal_header_id) 
		FROM power_outage po 
			INNER JOIN source_deal_detail sdd
				ON po.source_generator_id = sdd.location_id
				AND power_outage_id = @power_outage_id

		UPDATE sddh
			SET sddh.volume =
				CASE WHEN po.type_name = 'o' THEN
					0
				ELSE
					CASE WHEN NULLIF(NULLIF(po.derate_mw, ''), 0) IS NOT NULL THEN
						sddh.volume - po.derate_mw
					ELSE
						sddh.volume * (1 - po.derate_percent/100)
					END
				END
		FROM power_outage po
		INNER JOIN source_deal_detail sdd
			ON po.source_generator_id = sdd.location_id
		INNER JOIN source_deal_detail_hour sddh
			ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE sdd.source_deal_header_id = @source_deal_header_id
			AND po.power_outage_id = @power_outage_id
			AND DATEADD(HOUR, CAST(sddh.hr - 1 AS INT), sddh.term_date) BETWEEN  DATEADD(HOUR, CAST(DATEPART(HOUR, po.actual_start) AS INT), CAST(CAST(po.actual_start AS DATE) AS DATETIME))  
																		AND  DATEADD(HOUR, CAST(DATEPART(HOUR, po.actual_end) AS INT), CAST(CAST(po.actual_end AS DATE) AS DATETIME))
	
		--EXEC spa_update_deal_total_volume @source_deal_header_id, NULL, 0, NULL, @user_login_id, 'y'
		--EXEC spa_calc_deal_position_breakdown  @deal_header_ids= @source_deal_header_id
	END
   
   
    
    IF @flag = 'i'
        SET @msg = 'Data Successfully Inserted.'
    ELSE IF @flag = 'u'
        SET @msg = 'Data Successfully Updated.'
    ELSE IF @flag = 'd'
        SET @msg = 'Data Successfully Deleted.'
	ELSE IF @flag = 'p'
		SET @msg = 'Hourly volume updated.'

    IF @msg <> '' 
        EXEC spa_ErrorHandler 0, 'power_outage', 'spa_power_outage', 'Success', @msg, ''
        
END TRY
BEGIN CATCH
    DECLARE @error_number INT
    SET @error_number = ERROR_NUMBER()
    SET @msg_err = ''

	IF @@TRANCOUNT > 0
	    ROLLBACK

    IF @flag = 'i' 
	BEGIN
		IF @error_number = 2627
		BEGIN
		    SET @msg_err = 'The selected location details already exist'
		END
		ELSE
		BEGIN
		    SET @msg_err = 'Fail Insert Data.'
		END
	END			
    ELSE IF @flag = 'u'
    BEGIN
    	IF @error_number = 2627
        BEGIN
            SET @msg_err = 'The selected location details already exist'
        END
        ELSE
        BEGIN
            SET @msg_err = 'Fail Insert Data.'
        END
    END                
    ELSE IF @flag = 'd'
	BEGIN
		SET @msg_err = 'Fail Delete Data.'
	END
        
	EXEC spa_ErrorHandler @error_number, 'power_outage', 'spa_power_outage', 'DB Error', @msg_err, ''
END CATCH

