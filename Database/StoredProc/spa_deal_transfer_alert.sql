IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_transfer_alert]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_deal_transfer_alert]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Sp to call spatranfer_adjust from alert.

	Parameters 
	@flag : Operational Flag 'a' - Auto deal schedule Block.
	@source_deal_header_ids : Source Deal Header Ids to process.
	@process_id : Process ID.
	process_status in process_deal_alert_transfer_adjust: 1 NEW, 2 processing, 3 success, 4 adjust fail
*/

CREATE PROC [dbo].[spa_deal_transfer_alert]
	@flag CHAR(1),
	@source_deal_header_id NVARCHAR(MAX) = NULL,
	@process_id NVARCHAR(100) = NULL	
AS

/**
EXEC spa_drop_all_temp_table

	DECLARE 
		@flag CHAR(1) = 'a',
		@source_deal_header_id NVARCHAR(MAX) =  '106492, 106492, 106492, 106492, 106492, 106492, 106492, 106492, 106492, 106492, 106492, 106492',
		@process_id NVARCHAR(100) = 'CDEBC909_AF84_4DF3_8073_5C24552F3F07'	

--**/
	
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUSER()
	
	--IF @process_id IS NULL
	--	SET @process_id = dbo.FNAGetNewID()

IF @flag IN ('a', 'r') --AUTO DEAL SCHEDULE BLOCK
BEGIN	
	DECLARE @alert_process_table NVARCHAR(200) = dbo.FNAProcessTableName('alert_org_deal', @process_id, 'ad')

	CREATE TABLE #temp_alert_deals(
		source_deal_header_id INT, 
		source_deal_detail_id INT
	)

	CREATE TABLE #temp_error(
		process_id VARCHAR(200) COLLATE DATABASE_DEFAULT
		, code VARCHAR(500) COLLATE DATABASE_DEFAULT
		, module VARCHAR(500) COLLATE DATABASE_DEFAULT
		, [source] VARCHAR(500) COLLATE DATABASE_DEFAULT
		, [type] VARCHAR(500) COLLATE DATABASE_DEFAULT
		, [description] VARCHAR(1000) COLLATE DATABASE_DEFAULT
		, recommendation VARCHAR(500) COLLATE DATABASE_DEFAULT
	) 


	IF @flag = 'a'
	BEGIN
		EXEC('INSERT INTO #temp_alert_deals
			  SELECT source_deal_header_id, source_deal_detail_id 
			  FROM ' + @alert_process_table
		)
	END
	ELSE IF @flag = 'r' 
	BEGIN
		INSERT INTO #temp_alert_deals
		SELECT source_deal_header_id, source_deal_detail_id 
		FROM process_deal_alert_transfer_adjust
		WHERE process_status = 4
		AND error_description = 'Failed to auto adjust.'
		AND process_id = @process_id

		UPDATE process_deal_alert_transfer_adjust
			SET process_status = 1,
			error_description = NULL
		WHERE process_status = 4
		AND error_description = 'Failed to auto adjust.'
		AND process_id = @process_id
			 
	END

	----change this from ixp_generic
	--DELETE pp
	----select pp.*
	--FROM process_deal_alert_transfer_adjust pp
	--LEFT JOIN (
	--	--get source_deal_deal_id of the min term
	--	SELECT sdd1.source_deal_header_id, sdd1.source_deal_detail_id, sub.process_id
	--	FROM source_deal_detail sdd1
	--	INNER JOIN 
	--	(	--get min term
	--		SELECT pp.source_deal_header_id
	--			, pp.process_id
	--			, MIN(sdd.term_start) term_start		   
	--		FROM process_deal_alert_transfer_adjust pp
	--		INNER JOIN source_deal_detail sdd
	--			On sdd.source_deal_detail_id = pp.source_deal_detail_id	
	--		WHERE pp.process_status = 1
	--		GROUP BY pp.source_deal_header_id, pp.process_id, YEAR(sdd.term_start), MONTH(sdd.term_start)
	--	)sub
	--	ON sdd1.source_deal_header_id = sub.source_deal_header_id
	--	AND sdd1.term_start = sub.term_start

	--) pp1
	--ON pp1.source_deal_detail_id = pp.source_deal_detail_id
	--	AND pp1.process_id = pp.process_id
	--WHERE pp1.source_deal_header_id IS NULl
	--	AND pp.process_status = 1

	DECLARE @c_source_Deal_header_id INT
	DECLARE @c_process_id			 VARCHAR(200)
	DECLARE @c_date					 DATE
	DECLARE @c_source_deal_detail_id INT
	DECLARE @create_ts DATETIME
	--DECLARE @counter INT = 1
	DECLARE @show_retry_message BIT = 0;
	DECLARE @deal_id VARCHAR(50);
	DECLARE @deal_term DATETIME;

	DECLARE cur_deals CURSOR LOCAL FOR

	--[TO DO] add process table
	SELECT DISTINCT a.item, pp.process_id, sdd.term_start, sdd.source_deal_detail_id,pp.create_ts
	FROM dbo.fnasplit(@source_deal_header_id, ',') a
	INNER JOIN process_deal_alert_transfer_adjust pp
		ON a.item = pp.source_deal_header_id
	INNER JOIN #temp_alert_deals tad  --- need to check
		ON tad.source_deal_header_id = pp.source_deal_header_id
		AND tad.source_deal_detail_id = pp.source_deal_detail_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = tad.source_deal_detail_id
		AND sdd.source_deal_detail_id = pp.source_deal_detail_id
	LEFT JOIN process_deal_position_breakdown ppd
		ON ppd.source_deal_header_id = pp.source_deal_header_id	
		AND ppd.process_status <> 9 --This will process at EOD
	WHERE pp.process_status = 1
		AND ppd.source_deal_header_id IS NULL
	ORDER BY pp.create_ts	

	OPEN cur_deals
	FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id, @c_process_id, @c_date, @c_source_deal_detail_id, @create_ts
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @deal_id = deal_id 
		FROM source_deal_header 
		WHERE source_deal_header_id = @c_source_Deal_header_id

		UPDATE process_deal_alert_transfer_adjust 
		SET process_status = 2
		  , error_description = 'Processing.'
		WHERE source_deal_header_id = @c_source_Deal_header_id
			AND process_id = @c_process_id
			AND source_deal_detail_id = @c_source_deal_detail_id

		IF EXISTS( SELECT   1-- uddf.udf_value
				   FROM source_deal_header sdh
				   INNER JOIN user_defined_deal_fields_template_main uddft
					   ON uddft.template_id = sdh.template_id
				   INNER JOIN user_defined_deal_fields uddf
					   ON uddf.source_deal_header_id = sdh.source_deal_header_id 
					   AND uddf.udf_template_id = uddft.udf_template_id
				   INNER JOIN user_defined_fields_template udft
					   ON udft.field_id = uddft.field_id
					INNER JOIN source_Deal_type sdt
						ON sdt.source_Deal_type_id = sdh.source_Deal_type_id
					INNER JOIN static_data_value sdv
						ON sdv.value_id = sdh.internal_portfolio_id
						AND sdv.type_id = 39800
						AND sdv.code IN (						
							'Complex-EEX'
							,'Complex-LTO'
							,'Complex-ROD'
							,'Autopath Only'
						)
				   WHERE sdh.source_deal_header_id = @c_source_Deal_header_id --7385 --
					   AND udft.Field_label = 'Delivery Path'
					   AND NULLIF(uddf.udf_value, '') IS NOT NULL
						 AND sdt.deal_type_id <> 'Transportation'						 
		)
		BEGIN						
			DECLARE @output_status BIT
			BEGIN TRY
				EXEC [dbo].[spa_transfer_adjust] @source_deal_header_id = @c_source_Deal_header_id, @term = @c_date, @is_deal_created  = @output_status OUTPUT
			END TRY
			BEGIN CATCH
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 4
				  , error_description = 'Failed to auto adjust due to technical error.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id

				INSERT INTO #temp_error (
					process_id
					, code
					, module
					, source
					, type
					, [description]
					, recommendation
				) 
				SELECT @c_process_id
						, 'Error'
						, 'Auto Schedule'
						, 'Deal With Technical Error'
						, 'Deal With Technical Error'
						, 'Auto schedule of Deal:  <B>' + @deal_id + 
							' </B> Term Date:  <B>' + [dbo].[FNADateFormat](@c_date) +  
						+ '</B> is not done successfully.'
						, NULL

			END CATCH

			IF @output_status = 1
			BEGIN
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 3
					, error_description = 'Auto adjust completed.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id	
					
				INSERT INTO #temp_error (
					process_id
					, code
					, module
					, source
					, type
					, [description]
					, recommendation
				) 

				SELECT @c_process_id
						, 'Info'
						, 'Auto Schedule'
						, 'Successfully Auto Scheduled'
						, 'Successfully Auto Scheduled'
						, 'Auto schedule of Deal:  <B>' + @deal_id + 
							' </B> Term Date:  <B>' + [dbo].[FNADateFormat](@c_date) +  
						+ ' </B> is done successfully.'
						, NULL		
				
			END
			ELSE
			BEGIN
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 4
				  , error_description = 'Failed to auto adjust.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id

				INSERT INTO #temp_error (
					process_id
					, code
					, module
					, source
					, type
					, [description]
					, recommendation
				) 
				SELECT @c_process_id
						, 'Error'
						, 'Auto Schedule'
						, 'Failed To Auto Adjust'
						, 'Failed To Auto Adjust'
						, 'Auto schedule of Deal: <B>' + @deal_id + 
							'</B> Term Date: <B>' + [dbo].[FNADateFormat](@c_date) +  
						+ '</B> is failed.'
						, 'Click <span style=cursor:pointer onClick=retry_auto_schedule(''' + @c_process_id +  ''')><font color=#0000ff><u>here</u></font></span> to retry.'


				SET @show_retry_message = 1;
			END			
		END	
		ELSE
		BEGIN
			UPDATE process_deal_alert_transfer_adjust
			SET process_status = 4
			  , error_description = 'No need to auto adjust.'
			WHERE source_deal_header_id = @c_source_Deal_header_id
				AND process_id = @c_process_id
				AND source_deal_detail_id = @c_source_deal_detail_id

			INSERT INTO #temp_error (
					process_id
					, code
					, module
					, source
					, type
					, [description]
					, recommendation
				) 
				SELECT @c_process_id
					, 'Info'
					, 'Auto Schedule'
					, 'Auto Schedule Not Necessary'
					, 'Auto Schedule Not Necessary'
					, 'Auto schedule of Deal: <B>' + @deal_id + 
						' </B> Term Date:  <B>' + [dbo].[FNADateFormat](@c_date) +  
					+ ' </B> is not necessary.'
					, NULL

		END
		
		FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id, @c_process_id, @c_date, @c_source_deal_detail_id,@create_ts
		DELETE FROM process_deal_alert_transfer_adjust WHERE process_status = 3
	END
	
	CLOSE cur_deals
	DEALLOCATE cur_deals

	
	INSERT INTO source_system_data_import_status(
		process_id
		, code
		, module
		, source
		, type
		, [description]
		, recommendation
	) 
	SELECT @process_id
		, MAX(code)
		, MAX(module)
		, MAX(source)
		, MAX(type)
		, type + ':' + CAST(COUNT(1) AS VARCHAR(10)) 
		, MAX(recommendation)
	FROM #temp_error
	GROUP BY type

	INSERT INTO source_system_data_import_status_detail(process_id,source,[type],[description]) 
	SELECT @process_id
		, source
		, type
		,[description]
	FROM #temp_error
	
	DECLARE @user_login_id NVARCHAR(100) = dbo.FNADBUser()
	-- DECLARE @process_id3  VARCHAR(100) = dbo.FNAGetNewID()
	DECLARE @url NVARCHAR(1000);

	--set @user_login_id = 'dmanandhar'

	IF EXISTS(SELECT 1 FROM #temp_error)
	BEGIN
		IF @show_retry_message = 1
		BEGIN
			SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
						'&spa=EXEC spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
			SELECT @url = '<a target="_blank" href="' + @url + '">' 
						+ 'Auto schedule completed successfully with errors.</a>' 
	
			EXEC  spa_message_board 'i', @user_login_id, NULL, 'Auto Schedule', @url, '', '', 's', NULL, NULL, @process_id
			
		END

		ELSE IF @show_retry_message = 0
		BEGIN
			SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
						'&spa=EXEC spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
			SELECT @url = '<a target="_blank" href="' + @url + '">' 
						+ 'Auto schedule completed successfully.</a>'	

			EXEC  spa_message_board 'i', @user_login_id, NULL, 'Auto Schedule', @url, '', '', 's', NULL, NULL, @process_id
		END
	END

END



