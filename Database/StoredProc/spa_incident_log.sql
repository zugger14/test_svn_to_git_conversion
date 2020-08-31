IF OBJECT_ID(N'[dbo].[spa_incident_log]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_incident_log]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Used to perform select, insert, update and delete from incident_log table.

	Parameters 
	@flag : Flag operations.
	@incident_log_id : primary key of the table incident_log.
	@xml_data : Data of grid in xml format.
	@category : internal_type_value_id of table application notes.
	@notes_object : notes_object_id of table application notes.
	@download_url : Not in use.
	@incident_log_detail_id : primary key of table incident_log_detail
	@search_result_table : Table from where the data is searched.
	@incident_status : incident_status of incident_log table.

*/

CREATE PROCEDURE [dbo].[spa_incident_log] 
	@flag					CHAR(1),
	@incident_log_id		VARCHAR(200) = NULL,
	@xml_data				VARCHAR(MAX) = NULL,
	@category				INT = NULL,
	@notes_object			INT = NULL,
	@download_url			VARCHAR(200) = NULL,
	@incident_log_detail_id VARCHAR(200) = NULL,
	@search_result_table	VARCHAR(500) = NULL,
	@incident_status		INT = NULL
AS

SET NOCOUNT ON;

DECLARE @idoc INT

DECLARE @notes_flag CHAR(1),
		@category_id INT,
		@object_id INT,
		@parent_object_id INT,
		@notes_subject VARCHAR(500),
		@application_notes_id INT,
		@new_incident_id INT,
		@category_name VARCHAR(100),
		@file_attachment VARCHAR(100),
		@notes_attachment VARCHAR(200)

IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_incident') IS NOT NULL
			DROP TABLE #tmp_incident
		
		SELECT	incident_log_id				[incident_log_id],
				incident_type				[incident_type],
				incident_description		[incident_description],
				incident_status				[incident_status],
				buyer_from					[buyer_from],
				seller_to					[seller_to],
				--counterparty				[counterparty],
				internal_counterparty		[internal_counterparty],
				contract					[contract],
				location					[location],
				date_initiated				[date_initiated],
				date_closed					[date_closed],
				trader						[trader],
				logistics					[logistics],
				ref_incident_id				[ref_incident_id],

				commodity					[commodity],
				origin						[origin],
				is_organic					[is_organic],
				form						[form],
				attribute1					[attribute1],
				attribute2					[attribute2],
				attribute3					[attribute3],
				attribute4					[attribute4],
				attribute5					[attribute5],
				crop_year					[crop_year],

				initial_assesment			[initial_assesment],
				outcome_acceptable			[outcome_acceptable],
				resolved_satisfactory		[resolved_satisfactory],
				non_confirming_delivered	[non_confirming_delivered],
				root_cause					[root_cause],
				corrective_action			[corrective_action],
				preventive_action			[preventive_action],
				claim_amount				[claim_amount],
				claim_amount_currency		[claim_amount_currency],
				settle_amount				[settle_amount],
				settle_amount_currency		[settle_amount_currency]
		INTO #tmp_incident
		FROM OPENXML(@idoc, '/Root/IncientLog', 1)
		WITH (
			incident_log_id				VARCHAR(10),
			incident_type				VARCHAR(10),
			incident_description		VARCHAR(500),
			incident_status				VARCHAR(10),
			buyer_from					VARCHAR(10),
			seller_to					VARCHAR(10),
			--counterparty				VARCHAR(10),
			internal_counterparty		VARCHAR(10),
			contract					VARCHAR(10),
			location					VARCHAR(10),
			date_initiated				VARCHAR(20),
			date_closed					VARCHAR(20),
			trader						VARCHAR(10),
			logistics					VARCHAR(10),
			ref_incident_id				VARCHAR(10),

			commodity					VARCHAR(10),
			origin						VARCHAR(10),
			is_organic					VARCHAR(10),
			form						VARCHAR(10),
			attribute1					VARCHAR(10),
			attribute2					VARCHAR(10),
			attribute3					VARCHAR(10),
			attribute4					VARCHAR(10),
			attribute5					VARCHAR(10),
			crop_year					VARCHAR(10),

			initial_assesment			CHAR(1),
			outcome_acceptable			CHAR(1),
			resolved_satisfactory		CHAR(1),
			non_confirming_delivered	CHAR(1),
			root_cause					VARCHAR(1000),
			corrective_action			VARCHAR(1000),
			preventive_action			VARCHAR(1000),
			claim_amount				VARCHAR(1000),
			claim_amount_currency		INT,
			settle_amount				VARCHAR(1000),
			settle_amount_currency		INT
		)


		IF OBJECT_ID('tempdb..#tmp_app_notes') IS NOT NULL
			DROP TABLE #tmp_app_notes
		
		SELECT	category_id			[category_id],
				sub_category_id		[sub_category_id],
				notes_object_id		[notes_object_id],
				parent_object_id	[parent_object_id],
				notes_subject		[notes_subject],
				file_attachment		[file_attachment]
		INTO #tmp_app_notes
		FROM OPENXML(@idoc, '/Root/ApplicationNotes', 1)
		WITH (
			category_id				VARCHAR(10),
			sub_category_id			VARCHAR(10),
			notes_object_id			VARCHAR(10),
			parent_object_id		VARCHAR(10),
			notes_subject			VARCHAR(500),
			file_attachment			VARCHAR(200)
		)

		/*
		 * INSERT/UPDATE in application notes.
		 */
		
		SELECT	@category_id = category_id,
				@object_id = notes_object_id,
				@parent_object_id = ISNULL(NULLIF(parent_object_id,''),notes_object_id),
				@notes_subject = notes_subject,
				@file_attachment = file_attachment
		FROM #tmp_app_notes
	
		SELECT @category_name = code FROM static_data_value WHERE value_id = @category_id
		SET @notes_attachment = '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + @category_name + '/' + @file_attachment
		
		IF EXISTS (SELECT 1 FROM #tmp_incident WHERE incident_log_id = '')
		BEGIN	
			SET @notes_flag = 'i'
			SET @application_notes_id = ''
		END	
		ELSE
		BEGIN
			SET @notes_flag = 'u'
			SELECT @application_notes_id = il.application_notes_id FROM #tmp_incident tmp
			INNER JOIN incident_log il ON tmp.incident_log_id = il.incident_log_id
		END

		IF OBJECT_ID('tempdb..#error_status') IS NOT NULL
			DROP TABLE #error_status
		CREATE TABLE #error_status (error_code VARCHAR(20), module VARCHAR(20), area VARCHAR(20), [status] VARCHAR(20), [message] VARCHAR(100), recommendation VARCHAR(100))

		INSERT INTO #error_status (error_code, module, area, [status], [message], recommendation)
		EXEC spa_post_template	@flag = @notes_flag,
								@notes_subject = @notes_subject,
								@internal_type_value_id = @category_id,
								@category_value_id = 42027,
								@notes_object_id = @object_id,
								@parent_object_id = @parent_object_id,
								@notes_share_email_enable = 0,
								@notes_id = @application_notes_id,
								@doc_file_name = @notes_attachment,
								@doc_file_unique_name = @file_attachment
		IF @notes_flag = 'i'
		BEGIN
			SET @application_notes_id = IDENT_CURRENT('application_notes')						
		END
	
		/*
		 * INSERT/UPDATE in incident log
		 */
	
		IF @notes_flag = 'i'
		BEGIN
			INSERT INTO incident_log (
				incident_type,
				incident_description,
				incident_status,
				buyer_from,
				seller_to,
				--counterparty,
				internal_counterparty,
				[contract],
				location,
				date_initiated,
				date_closed,
				trader,
				logistics,
				commodity,
				Origin,
				is_organic,
				form,
				attribute1,
				attribute2,
				attribute3,
				attribute4,
				attribute5,
				crop_year,
				initial_assesment,
				outcome_acceptable,
				resolved_satisfactory,
				non_confirming_delivered,
				root_cause,
				corrective_action,
				preventive_action,
				ref_incident_id,
				application_notes_id,
				claim_amount,
				claim_amount_currency,
				settle_amount,
				settle_amount_currency	
			)
			SELECT 
				incident_type,
				incident_description,
				incident_status,
				NULLIF(buyer_from,''),
				NULLIF(seller_to,''),
				--NULLIF(counterparty,''),
				NULLIF(internal_counterparty,''),
				NULLIF(contract,''),
				NULLIF(location,''),
				date_initiated,
				NULLIF(date_closed,''),
				NULLIF(trader,''),
				NULLIF(logistics,''),
				NULLIF(commodity,''),
				NULLIF(Origin,''),
				NULLIF(is_organic,''),
				NULLIF(form,''),
				NULLIF(attribute1,''),
				NULLIF(attribute2,''),
				NULLIF(attribute3,''),
				NULLIF(attribute4,''),
				NULLIF(attribute5,''),
				NULLIF(crop_year,''),
				initial_assesment,
				outcome_acceptable,
				resolved_satisfactory,
				non_confirming_delivered,
				root_cause,
				corrective_action,
				preventive_action,
				NULLIF(ref_incident_id,''),
				@application_notes_id,
				NULLIF(claim_amount,''),
				NULLIF(claim_amount_currency,''),
				NULLIF(settle_amount,''),
				NULLIF(settle_amount_currency,'')	
			FROM #tmp_incident 
			WHERE incident_log_id = ''

			SET @new_incident_id = IDENT_CURRENT('incident_log')	
		END
		ELSE 
		BEGIN
			UPDATE il
				SET il.incident_type = ti.incident_type,
					il.incident_description = ti.incident_description,
					il.incident_status = ti.incident_status,
					il.buyer_from = NULLIF(ti.buyer_from,''),
					il.seller_to = NULLIF(ti.seller_to,''),
					--il.counterparty = NULLIF(ti.counterparty,''),
					il.internal_counterparty = NULLIF(ti.internal_counterparty,''),
					il.contract = NULLIF(ti.contract,''),
					il.location = NULLIF(ti.location,''),
					il.date_initiated = ti.date_initiated,
					il.date_closed = NULLIF(ti.date_closed,''),
					il.trader = NULLIF(ti.trader,''),
					il.logistics = NULLIF(ti.logistics,''),
					il.commodity = NULLIF(ti.commodity,''),
					il.Origin = NULLIF(ti.Origin,''),
					il.is_organic = NULLIF(ti.is_organic,''),
					il.form = NULLIF(ti.form,''),
					il.attribute1 = NULLIF(ti.attribute1,''),
					il.attribute2 = NULLIF(ti.attribute2,''),
					il.attribute3 = NULLIF(ti.attribute3,''),
					il.attribute4 = NULLIF(ti.attribute4,''),
					il.attribute5 = NULLIF(ti.attribute5,''),
					il.crop_year = NULLIF(ti.crop_year,''),
					il.initial_assesment = ti.initial_assesment,
					il.outcome_acceptable = ti.outcome_acceptable,
					il.resolved_satisfactory = ti.resolved_satisfactory,
					il.non_confirming_delivered = ti.non_confirming_delivered,
					il.root_cause = ti.root_cause,
					il.corrective_action = ti.corrective_action,
					il.preventive_action = ti.preventive_action,
					il.ref_incident_id = NULLIF(ti.ref_incident_id,''),
					il.application_notes_id = @application_notes_id,
					il.claim_amount = NULLIF(ti.claim_amount,''),
					il.claim_amount_currency = NULLIF(ti.claim_amount_currency,''),
					il.settle_amount = NULLIF(ti.settle_amount,''),
					il.settle_amount_currency = NULLIF(ti.settle_amount_currency,'')
			FROM incident_log il
			INNER JOIN #tmp_incident ti ON il.incident_log_id = ti.incident_log_id

			SELECT @new_incident_id = incident_log_id FROM #tmp_incident
		END

		COMMIT 

	DECLARE @process_table VARCHAR(500)
	DECLARE @sql_stmt VARCHAR(MAX)
	DECLARE @process_id VARCHAR(200)
	SET @process_id = dbo.FNAGetNewID()  
	SET @process_table = 'adiha_process.dbo.alert_incident_log_' + @process_id + '_all'
	SET @sql_stmt = 'CREATE TABLE ' + @process_table + '
	                 (
	                 	incident_log_id    INT,
	                 	incident_type  VARCHAR(200),
	                 	incident_description VARCHAR(200),
	                 	incident_status		VARCHAR(200),
						counterparty_id  INT,
	                 	hyperlink1 VARCHAR(5000), 
         				hyperlink2 VARCHAR(5000), 
         				hyperlink3 VARCHAR(5000), 
         				hyperlink4 VARCHAR(5000), 
         				hyperlink5 VARCHAR(5000)
	                 )
					INSERT INTO ' + @process_table + '(
						incident_log_id,
						incident_type,
						incident_description,
						incident_status 
					  )
					SELECT il.incident_log_id
						  ,il.incident_type
						  ,il.incident_description
						  ,il.incident_status 
					FROM incident_log il
					WHERE  il.incident_log_id = ' +  CAST(@new_incident_id AS VARCHAR(30)) + ''

	EXEC(@sql_stmt)
	EXEC spa_register_event 20624, 20573, @process_table, 0, @process_id


		EXEC spa_ErrorHandler 0
			, 'spa_incident_log' 
			, 'incident_log'
			, 'incident_log'
			, 'Change have been saved successfully.'
			, @new_incident_id
	END TRY 
	BEGIN CATCH
	--print error_message()
		EXEC spa_ErrorHandler -1
			,'spa_incident_log' 
			, 'incident_log'
			, 'incident_log'
			, 'Failed adding incident'
			, ''
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'l'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_incident_detail') IS NOT NULL
			DROP TABLE #tmp_incident_detail
		
		SELECT	incident_log_id	[incident_log_id],
				incident_log_detail_id	[incident_log_detail_id],
				incident_status	[incident_status],
				[date]			[date],
				comment			[comment],
				file_attachment	[file_attachment]
		INTO #tmp_incident_detail
		FROM OPENXML(@idoc, '/Root/IncidentDetail', 1)
		WITH (
			incident_log_id		VARCHAR(10),
			incident_log_detail_id VARCHAR(10),
			incident_status		VARCHAR(10),
			[date]				VARCHAR(20),
			comment				VARCHAR(1000),
			file_attachment		VARCHAR(200)
		)

		DECLARE @new_incident_detail_id INT
		IF EXISTS (SELECT 1 FROM #tmp_incident_detail WHERE incident_log_detail_id = '')
		BEGIN
			INSERT INTO incident_log_detail (
				incident_log_id,
				incident_status,
				incident_update_date,
				comments
			)
			SELECT	incident_log_id,
					incident_status,
					[date],
					comment
			FROM #tmp_incident_detail

			SET @new_incident_detail_id = IDENT_CURRENT('incident_log_detail');
			SET @notes_flag = 'i';	
			SET @application_notes_id = '';
		END
		ELSE
		BEGIN
			UPDATE ild
			SET ild.incident_status = tmp.incident_status,
				ild.incident_update_date = tmp.date,
				ild.comments = tmp.comment
			FROM incident_log_detail ild
			INNER JOIN #tmp_incident_detail tmp ON ild.incident_log_detail_id = tmp.incident_log_detail_id

			SELECT TOP(1) 
				@new_incident_detail_id = tmp.incident_log_detail_id, 
				@application_notes_id = application_notes_id	
			FROM #tmp_incident_detail tmp
			INNER JOIN incident_log_detail ild ON tmp.incident_log_detail_id = ild.incident_log_detail_id

			IF @application_notes_id IS NULL
			BEGIN
				SET @notes_flag = 'i';
				SET @application_notes_id = '';
			END
			ELSE
				SET @notes_flag = 'u';

		END

		IF EXISTS (SELECT 1 FROM #tmp_incident_detail WHERE file_attachment <> '')
		BEGIN
			SELECT	@category_id = an.internal_type_value_id,
					@object_id = an.notes_object_id,
					@parent_object_id = ISNULL(NULLIF(an.parent_object_id,''),an.notes_object_id),
					@notes_subject = an.notes_subject,
					@file_attachment = tmp.file_attachment,
					@category_name = sdv.code
			FROM incident_log il
			INNER JOIN application_notes an ON il.application_notes_id = an.notes_id
			INNER JOIN #tmp_incident_detail tmp ON il.incident_log_id = tmp.incident_log_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
	
			SET @notes_attachment = '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + @category_name + '/' + @file_attachment

			IF OBJECT_ID('tempdb..#error_status1') IS NOT NULL
			DROP TABLE #error_status1
			CREATE TABLE #error_status1 (error_code VARCHAR(20), module VARCHAR(20), area VARCHAR(20), [status] VARCHAR(20), [message] VARCHAR(100), recommendation VARCHAR(100))

			--INSERT INTO #error_status1 (error_code, module, area, [status], [message], recommendation)
			EXEC spa_post_template	@flag = @notes_flag,
									@notes_subject = @notes_subject,
									@internal_type_value_id = @category_id,
									@category_value_id = 42027,
									@notes_object_id = @object_id,
									@parent_object_id = @parent_object_id,
									@notes_share_email_enable = 0,
									@notes_id = @application_notes_id,
									@doc_file_name = @notes_attachment,
									@doc_file_unique_name = @file_attachment
			
			IF @notes_flag = 'i'
			BEGIN
				DECLARE @new_notes_id1 INT
				SET @new_notes_id1 = IDENT_CURRENT('application_notes')		
			
				UPDATE incident_log_detail
				SET application_notes_id = @new_notes_id1
				WHERE incident_log_detail_id = @new_incident_detail_id
			END
		END
			

		EXEC spa_ErrorHandler 0
				, 'spa_incident_log' 
				, 'incident_log_detail'
				, 'incident_log_detail'
				, 'Change have been saved successfully.'
				, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_incident_log' 
			, 'incident_log_detail'
			, 'incident_log_detail'
			, 'Failed adding incident'
			, ''
	END CATCH
END

ELSE IF @flag = 's'
BEGIN
	SELECT	incident_log_detail_id, 
			sdv.code, 
			dbo.FNADateFormat(incident_update_date), 
			comments, 
			application_notes_id 
	FROM incident_log_detail ild
	LEFT JOIN static_data_value sdv ON ild.incident_status = sdv.value_id
	WHERE incident_log_id = @incident_log_id
	ORDER BY incident_update_date DESC
END

ELSE IF @flag = 'g'
BEGIN
	IF OBJECT_ID('tempdb..#temp_incident_log_collect') IS NOT NULL
		DROP TABLE #temp_incident_log_collect

	
		SELECT	ISNULL(sdv_cat.code, 'General')		[category],
				ISNULL(sdv_inc_typ.code, 'General') [incident_type],
				an.notes_subject 					[incident],
				an.notes_subject					[description],
				an.attachment_file_name + '^javascript:fx_download_file("' + an.notes_attachment + '")^_self' [notes_attachment],
				cast(isnull(an.parent_object_id, an.notes_object_id) as varchar(500)) + ' (' + isnull(sdv_cat.code, '') + ')^javascript:fx_click_parent_object_id_link(' + cast(sdv_cat.value_id as varchar(10)) + ',' + cast(isnull(an.parent_object_id, an.notes_object_id) as varchar(500))+ ')^_self' parent_object_id,
				sdv_user_cat.code					[user_category],
				sdv_inc_sts.code					[incident_status],
				dbo.FNADateFormat(il.date_initiated) [date_initiated],
				dbo.FNADateFormat(il.date_closed)	[date_closed],
				dbo.FNADateFormat(an.create_ts)		[create_ts],
				an.create_user						[create_user],	
				an.attachment_file_name,
				CASE an.notes_share_email_enable
					WHEN 0 THEN 'Disabled'
					WHEN 1 THEN 'Enabled'
				END AS notes_share_email_enable,
				an.notes_id,
				an.category_value_id [sub_category_id],
				'none' [search_criteria],
				sdv_cat.value_id [category_id],
				an.notes_object_id [notes_object_id],
				il.incident_log_id,
				'' incident_log_detail_id
		INTO #temp_incident_log_collect
		FROM incident_log il
		INNER JOIN application_notes an ON il.application_notes_id = an.notes_id
		LEFT JOIN static_data_value sdv_cat on sdv_cat.value_id = an.internal_type_value_id
		LEFT JOIN static_data_value sdv_inc_typ on sdv_inc_typ.value_id = an.category_value_id
		LEFT JOIN static_data_value sdv_user_cat on sdv_user_cat.value_id = an.user_category
		LEFT JOIN static_data_value sdv_inc_sts ON sdv_inc_sts.value_id = il.incident_status
		WHERE 1=1 
		AND an.internal_type_value_id IN (CASE WHEN @category IS NULL THEN an.internal_type_value_id ELSE @category END) AND 
		(an.notes_object_id = CASE WHEN @notes_object IS NULL THEN an.notes_object_id ELSE @notes_object END OR isnull(an.parent_object_id, -1) = CASE WHEN @notes_object IS NULL THEN isnull(an.parent_object_id, -1) ELSE @notes_object END)
		UNION ALL
		SELECT	ISNULL(sdv_cat.code, 'General')		[category],
				ISNULL(sdv_inc_typ.code, 'General') [incident_type],
				an.notes_subject 							[incident],
				'Update-' + CAST(ROW_NUMBER() OVER (PARTITION by il.incident_log_id ORDER BY ild.incident_update_date) AS VARCHAR)					[description],
				an1.attachment_file_name + '^javascript:fx_download_file("' + an1.notes_attachment + '")^_self' [notes_attachment],
				'' parent_object_id,
				sdv_user_cat.code					[user_category],
				sdv_inc_sts.code					[incident_status],
				dbo.FNADateFormat(ild.incident_update_date) [date_initiated],
				dbo.FNADateFormat(il.date_closed)	[date_closed],
				dbo.FNADateFormat(an.create_ts)		[create_ts],
				an.create_user						[create_user],	
				an.attachment_file_name,
				CASE an.notes_share_email_enable
					WHEN 0 THEN 'Disabled'
					WHEN 1 THEN 'Enabled'
				END AS notes_share_email_enable,
				an1.notes_id,
				an.category_value_id [sub_category_id],
				'none' [search_criteria],
				sdv_cat.value_id [category_id],
				an.notes_object_id [notes_object_id],
				il.incident_log_id,
				ild.incident_log_detail_id
		FROM incident_log il
		INNER JOIN application_notes an ON il.application_notes_id = an.notes_id
		LEFT JOIN static_data_value sdv_cat on sdv_cat.value_id = an.internal_type_value_id
		LEFT JOIN static_data_value sdv_inc_typ on sdv_inc_typ.value_id = an.category_value_id
		LEFT JOIN static_data_value sdv_user_cat on sdv_user_cat.value_id = an.user_category
		LEFT JOIN incident_log_detail ild ON ild.incident_log_id = il.incident_log_id
		LEFT JOIN application_notes an1 ON an1.notes_id = ild.application_notes_id
		LEFT JOIN static_data_value sdv_inc_sts ON sdv_inc_sts.value_id = ild.incident_status
		WHERE 1=1 AND ild.incident_log_detail_id IS NOT NULL 
		AND an.internal_type_value_id IN (CASE WHEN @category IS NULL THEN an.internal_type_value_id ELSE @category END) AND 
		(an.notes_object_id = CASE WHEN @notes_object IS NULL THEN an.notes_object_id ELSE @notes_object END OR isnull(an.parent_object_id, -1) = CASE WHEN @notes_object IS NULL THEN isnull(an.parent_object_id, -1) ELSE @notes_object END)
	

	IF @search_result_table	IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#temp_search_result') IS NOT NULL
			DROP TABLE #temp_search_result
		CREATE TABLE #temp_search_result (incident_log_id INT)

		EXEC('INSERT INTO #temp_search_result(incident_log_id) SELECT incident_log_id FROM ' + @search_result_table)
		IF EXISTS(SELECT 1 FROM #temp_search_result)
		BEGIN
			SELECT t1.*
			FROM #temp_incident_log_collect t1
			INNER JOIN #temp_search_result t2 ON t1.incident_log_id = t2.incident_log_id
			ORDER BY t1.incident_log_id, t1.parent_object_id desc, t1.date_initiated
		END
		ELSE
		BEGIN
			SELECT t1.*
			FROM #temp_incident_log_collect t1
			ORDER BY t1.incident_log_id, t1.parent_object_id desc, t1.date_initiated
		END
	END
	ELSE
	BEGIN
		SELECT t1.*
		FROM #temp_incident_log_collect t1
		ORDER BY t1.incident_log_id, t1.parent_object_id desc, t1.date_initiated
	END

END

ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF OBJECT_ID('tempdb..#tmp_notes') IS NOT NULL
			DROP TABLE #tmp_notes
		
		SELECT application_notes_id 
		INTO #tmp_notes
		FROM incident_log_detail ild
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_detail_id) a ON ild.incident_log_detail_id = a.item

		DELETE ild 
		FROM incident_log_detail ild
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_detail_id) a ON ild.incident_log_detail_id = a.item

		DELETE an FROM application_notes an
		INNER JOIN #tmp_notes tmp ON an.notes_id = tmp.application_notes_id

		COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_incident_log' 
				, 'incident_log_detail'
				, 'incident_log_detail'
				, 'Change have been saved successfully.'
				, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_incident_log' 
			, 'incident_log_detail'
			, 'incident_log_detail'
			, 'Failed to delete incident detail.'
			, ''
		ROLLBACK
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		
		IF OBJECT_ID('tempdb..#tmp_notes1') IS NOT NULL
			DROP TABLE #tmp_notes1
		
		CREATE TABLE #tmp_notes1(application_notes_id INT)

		INSERT INTO #tmp_notes1(application_notes_id)
		SELECT ild.application_notes_id 
		FROM incident_log_detail ild 
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON ild.incident_log_id = a.item

		INSERT INTO #tmp_notes1(application_notes_id)
		SELECT il.application_notes_id 
		FROM incident_log il 
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON il.incident_log_id = a.item

		DELETE ild FROM master_view_incident_log_detail ild
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON ild.incident_log_id = a.item

		DELETE ild FROM incident_log_detail ild
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON ild.incident_log_id = a.item

		DELETE il FROM master_view_incident_log il
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON il.incident_log_id = a.item

		DELETE il FROM incident_log il
		INNER JOIN dbo.SplitCommaSeperatedValues(@incident_log_id) a ON il.incident_log_id = a.item

		DELETE an FROM application_notes an
		INNER JOIN #tmp_notes1 tn  ON an.notes_id = tn.application_notes_id
		
	COMMIT
		EXEC spa_ErrorHandler 0
				, 'spa_incident_log' 
				, 'incident_log'
				, 'incident_log'
				, 'Change have been saved successfully.'
				, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_incident_log' 
			, 'incident_log'
			, 'incident_log'
			, 'Failed to delete incident.'
			, ''
		ROLLBACK
	END CATCH
END

ELSE IF @flag = 'p'
BEGIN
	SELECT incident_status, incident_update_date, comments,notes_attachment,attachment_file_name FROM incident_log_detail ild
	LEFT JOIN application_notes an ON ild.application_notes_id = an.notes_id
	WHERE incident_log_detail_id = @incident_log_detail_id
END

ELSE IF @flag = 'f'
BEGIN
	SELECT notes_attachment,attachment_file_name FROM application_notes an
	LEFT JOIN incident_log il ON an.notes_id = il.application_notes_id
	WHERE incident_log_id = @incident_log_id
END

--Updating Incident status on Incident Detail update
ELSE IF @flag = 't'
BEGIN
	UPDATE incident_log
	SET incident_status = @incident_status
	WHERE incident_log_id = @incident_log_id
END