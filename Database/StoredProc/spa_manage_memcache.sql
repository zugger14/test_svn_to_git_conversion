IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_manage_memcache]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Main SP to release cache key, list keys and data stored in respective keys.
	Parameter
	@flag : 'd' - To release cache key.
			'e' - List of key and menu name using this key. Used to list grid of data cache menu.
	, @key_prefix :
	, @cmbobj_key_source : Comma separated dropdown source name.eg source_counterparty is search in application UI template sql_string and generate combo change key to release key. This is not in use.
	, @other_key_source : 	
	, @source_object :
	, @product_id :
*/

CREATE PROCEDURE [dbo].[spa_manage_memcache]
	@flag CHAR(1)
	, @key_prefix NVARCHAR(MAX) = NULL
	, @cmbobj_key_source NVARCHAR(MAX) = NULL
	, @other_key_source NVARCHAR(MAX) = NULL	
	, @source_object NVARCHAR(1000) = NULL	
	, @product_id INT = NULL
AS
SET NOCOUNT ON 
/*
DECLARE  @flag CHAR(1) = 'd'
	, @key_prefix	NVARCHAR(MAX) = 'TRMTracker_Release_MM'
	, @cmbobj_key_source NVARCHAR(MAX) = 'application_users' 
	, @other_key_source NVARCHAR(MAX) --= 'MainMenu'
	, @source_object NVARCHAR(1000) = NULL
	, @product_id INT = NULL
			
SELECT  @flag = 'd', @key_prefix = NULL, @cmbobj_key_source = 'source_counterparty', @other_key_source = NULL
	--	SELECT  *  FROM [adiha_process].[dbo].[memcache_log]
--*/
BEGIN
	DECLARE @db	VARCHAR(100) = lower(db_name())
	--Lower case db name is used as key prefix. It is not fesible to change case of db name in @key_prefix at source so here below code is added.
	SET @key_prefix = REPLACE(@key_prefix, @db, @db)

	/* Cache key release logic starts */
	IF @flag = 'd'
	BEGIN
		--NULL if blank
		SELECT @key_prefix = NULLIF(@key_prefix,''), @cmbobj_key_source = NULLIF(@cmbobj_key_source,''), @other_key_source = NULLIF(@other_key_source,'')
		
		/*Application supports to cache combov2 options. When any static data is updated then updated dropdown options should be displayed in UI. For this purpose @cmbobj_key_source is used to release cached keys related to combov2 and any UI having this dropdown. But due to few complexity, dropdown option is not cached(feature is disabled). So to bypass combov2 key releasing logic @cmbobj_key_source is set to NULL. */
		SET @cmbobj_key_source = NULL
		IF (@cmbobj_key_source IS NULL AND 	@key_prefix IS NULL AND @other_key_source IS NULL)
		BEGIN
			RETURN
		END

		DECLARE @url_address		NVARCHAR(500),
			@post_data				NVARCHAR(MAX),
			@msg					NVARCHAR(MAX),
			@session_data			NVARCHAR(MAX),
			@user_login_id			NVARCHAR(100) = dbo.FNADBUser(),
			@generated_cmbv2_key	NVARCHAR(MAX),
			@generated_cmb_key		NVARCHAR(MAX),
			@generated_rmcmb_key	NVARCHAR(MAX),
			@generated_other_key	NVARCHAR(MAX),
			@final_key_list			NVARCHAR(MAX),
			@http_response			NVARCHAR(MAX),
			@filtered_session_data  NVARCHAR(MAX),
			@enable_data_caching	BIT = 0,
			@mainmenu_key			VARCHAR(MAX)

		
		--Session_data post variable is used to resolve farrms client folder to include farrms.client.config.ini.php file. Top 1 is used assuming that farrms client folder will be same per database.
		SELECT TOP 1 @session_data = session_data FROM trm_session where is_active = 1 AND session_data like '%farrms_client_dir%' ORDER BY create_ts DESC
		
		SELECT @enable_data_caching = right(item,1)
		FROM dbo.FNASplit(@session_data,';')
		WHERE item LIKE '%enable_data_caching%'

		IF @enable_data_caching = 1
		BEGIN	
			SELECT @filtered_session_data= COALESCE(@filtered_session_data + '&','')  + substring(item,0,charindex('|',item)) + '=' + 
				REPLACE(REPLACE(RIGHT(item,  CHARINDEX(':',REVERSE(item))-1),';',''),'"','')
			FROM dbo.FNASplit(@session_data,';')
			WHERE item like '%farrms_client_dir%' --OR item LIKE '%enable_data_caching%'
						
			IF @other_key_source = 'MainMenu'
			BEGIN				
				SELECT    @mainmenu_key = COALESCE(@mainmenu_key + ',' , '') + @db + '_MM_' + lower(user_login_id) + '_k'
				FROM application_users i
			END

			SELECT  @generated_other_key = 	CASE @other_key_source 
										WHEN 'Privilege' THEN
											+ @db + '_'		
										WHEN 'MainMenu' THEN	
											+ @mainmenu_key		--Left Main Menu	
										WHEN 'BookStructure' THEN
											+ @db + '_' + 'PH_'		--BS		
										WHEN 'ReportManagerPrivilege' THEN
											+ @db + '_' + 'RptList'		--View Report->Left Main Report List
											+ ',' +
											+ @db + '_' + 'RptRM'		--Report Manager Reports	
											+ ',' +
											+ @db + '_' + 'RptExcel'		--Excel Reports						
							
										ELSE NULL
										END 
		

			/* todo remove duplicate from array */
			IF ISNULL(@other_key_source,'') <> 'Privilege' AND @cmbobj_key_source IS NOT NULL
			BEGIN
				SET @cmbobj_key_source = NULLIF(RTRIM(LTRIM(@cmbobj_key_source)),'')			
		
				--list of dropdown fields using @cmbobj_key_source in sql_strring.

				SELECT   @generated_cmbv2_key =  COALESCE(@generated_cmbv2_key+',','') + dbo.FNAGetUniqueSQLKey(REPLACE(autd.sql_string,' ',''),'cmbv2') 
				FROM application_ui_template_definition autd
				INNER JOIN application_ui_template_fields autf ON autd.application_ui_field_id = autf.application_ui_field_id
				CROSS JOIN dbo.FNASplit(@cmbobj_key_source,'||') i
				WHERE autd.field_type = 'combo_v2'
					AND autd.sql_string like '%'+RTRIM(LTRIM(i.item))+'%'
				GROUP BY REPLACE(autd.sql_string,' ','')

				--list of UI using @cmbobj_key_source in sql_strring.
				SELECT   @generated_cmb_key =  COALESCE(@generated_cmb_key+',','') + @db +'_UI_' + CAST(autd.application_function_id AS VARCHAR(8)) 
				FROM application_ui_template_definition autd
				INNER JOIN application_ui_template_fields autf ON autd.application_ui_field_id = autf.application_ui_field_id
				CROSS JOIN dbo.FNASplit(@cmbobj_key_source,'||') i
				WHERE autd.field_type like 'combo%'  AND autd.field_type <> 'combo_v2'
					AND autd.sql_string like '%'+RTRIM(LTRIM(i.item))+'%'
				GROUP BY autd.application_function_id						

			   --list of Report Manager UI using @cmbobj_key_source in dropdown sql string.
				SELECT   @generated_rmcmb_key =  COALESCE(@generated_rmcmb_key+',','') + @db +'_RptRM_' + rps.paramset_hash 
				FROM data_source_column dsc
				INNER JOIN report_param rp ON rp.column_id = dsc.data_source_column_id
				INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
				INNER JOIN report_paramset rps ON rps.report_paramset_id = rdp.paramset_id
				CROSS JOIN dbo.FNASplit(@cmbobj_key_source,'||') i
				WHERE dsc.param_data_source like '%'+RTRIM(LTRIM(i.item))+'%'
				GROUP BY rps.paramset_hash
			END
		
		
			SELECT @final_key_list = COALESCE(@final_key_list+',','') + rs_memcache_key.id
			FROM (
				   VALUES (NULLIF(@key_prefix,'')) ,(NULLIF(@generated_cmb_key,'')), (NULLIF(@generated_cmbv2_key,'')),(NULLIF(@generated_other_key,'')), (NULLIF(@generated_rmcmb_key,''))
				 ) AS rs_memcache_key(id)
			WHERE rs_memcache_key.id IS NOT NULL
		
			--select  @final_key_list
			--return
			--In SasS mode db name could not resolve from client folder. So this block added temporarily to reset cache if privilege or book structure is changed.
			IF @other_key_source IN ('Privilege','BookStructure')
			BEGIN
				SET @final_key_list = ''	
				SET @filtered_session_data = @filtered_session_data + '&delete_all=1'
			END

			SELECT @url_address = SUBSTRING(file_attachment_path,0,CHARINDEX('adiha.php.scripts',file_attachment_path,0)+17)  
									+ '/components/process_cached_data.php'
				 , @post_data = 'prefix=' + @final_key_list + '&' + @filtered_session_data 
			FROM connection_string

			SET @final_key_list = NULLIF(@final_key_list, '')
			--SELECT @db	[db_name],@key_prefix
			--		, @url_address	[post_url_address]
			--		, @post_data	[cache_key_prefix]		
			--		, CASE WHEN @final_key_list IS NULL THEN 'Key is null' ELSE @msg END			[status]
			--		, @user_login_id [create_user]
			--RETURN
		
			IF @post_data IS NOT NULL
			BEGIN
				EXEC spa_push_notification  @url_address,@post_data ,'n',@msg output,@http_response output
			END
		
			--Maintain memcache log.			
			INSERT INTO [dbo].[memcache_log]([db_name]
					, [post_url_address]	
					, [cache_key_prefix]			
					, [status]		
					, [create_user]	
					, [source_object]	
			)
			SELECT @db
					, @url_address	
					, @post_data			
					, CASE WHEN @final_key_list IS NULL THEN 'Key is null' 
						ELSE CASE WHEN @msg = 'success' THEN ISNULL(NULLIF(@http_response,''), 'response is blank')  ELSE @msg END
					END
					, @user_login_id
					, @source_object	
		 
		END 
	END
	/* Cache key release logic ends */
ELSE IF @flag = 'e'
BEGIN
	DECLARE @source VARCHAR(1000)
	SELECT @source = (SELECT display_name FROM setup_menu
					 WHERE function_id = 10131000 
					 AND product_category = @product_id
					 AND hide_show = 1)
	
	--List of menus using combo fields.
	IF OBJECT_ID(N'tempdb..#final_list') IS NOT NULL
	DROP TABLE #final_list

	SELECT 'Std Report - '  + sm.display_name [Menu]	
		, @db + '_' +'RptStd'  +'_' + CAST(sm.function_id AS VARCHAR(10)) key_prefix
		, NULL key_suffix
	INTO #final_list 
	FROM application_ui_template aut
	INNER JOIN setup_menu sm ON sm.function_id = aut.application_function_id
	INNER JOIN  application_ui_template_definition autd ON aut.application_function_id = autd.application_function_id
	WHERE aut.is_report = 'y'
	UNION
	SELECT  'Non Std Reports - '+ rps.name
		, @db + '_' +'RptRM'  +'_' + rps.paramset_hash key_prefix
		, NULL key_suffix

	FROM report r
	INNER JOIN report_page rp ON rp.report_id = r.report_id 
	INNER JOIN report_dataset rd ON rd.report_id = r.report_id
	INNER JOIN report_dataset_paramset rdp ON rdp.root_dataset_id = rd.report_dataset_id
	INNER JOIN report_paramset rps ON rps.report_paramset_id = rdp.paramset_id
	WHERE 1 = 1 AND rp.is_deployed = 1
	UNION
	SELECT 
				'PBI Report - '+ pbr.[name] name
				, @db + '_' +'RptRM'  +'_' + pbr.powerbi_report_id
				, NULL key_suffix
				FROM power_bi_report AS [pbr]
					left JOIN report_paramset rps01 ON  rps01.paramset_hash = pbr.[source_report]
					left join  report_page rp01 ON rp01.report_page_id = rps01.page_id
					left join report r ON r.report_id = rp01.report_id
				WHERE pbr.is_published = 1 AND r.is_powerbi = 1 and pbr.powerbi_report_id <> '' AND  pbr.powerbi_report_id is not null
	UNION
	SELECT
		'Non Std Report-Excel - ' + es.sheet_name
		, @db + '_' + 'RptExcel' + '_' + CAST(es.excel_sheet_id AS VARCHAR(20))  key_prefix
		, NULL key_suffix
	FROM excel_sheet es
	WHERE  es.[snapshot] = 1 
	UNION
	SELECT 
		'Book Structure - ' + ds.name
		, @db + '_' + 'PH'  key_prefix
		, CAST(dsc.source_id + 10000000 AS VARCHAR(20)) + '_y' key_suffix
	FROM report_param rp
	INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp.column_id -- AND dsc.source_id =2778
	INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	INNER JOIN report_paramset rps ON rps.report_paramset_id = rdp.paramset_id
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id
	where widget_id in (3,4,5,8)
	GROUP BY rps.name,dsc.source_id,ds.name
	UNION
	SELECT 'Book Structure - ' + sm.display_name
	    , @db + '_' + 'PH'  key_prefix
	    , CAST(sm.function_id AS VARCHAR(20)) + '_y' key_suffix
	FROM application_ui_template aut
	INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
	INNER JOIN application_ui_template_fields autf ON autf.application_ui_field_id = autd.application_ui_field_id
	INNER JOIN setup_menu sm ON sm.function_id = aut.application_function_id
	WHERE autf.field_type = 'browser' AND autf.grid_id = 'book'
	GROUP BY sm.display_name, sm.function_id
	UNION
	SELECT 'Form - Create  View Deals', @db + '_' + 'UI_10130000'	, NULL UNION
	SELECT  @source					  , @db + '_' + 'UI_10131000'	, NULL UNION
	SELECT 'Combov2'				  , @db + '_' + 'cmbv2'		, NULL UNION
	--SELECT 'Book Structure'			  , @db + '_' + 'PH'		    , NULL UNION
	SELECT 'Main Menu'				  , @db + '_' + 'MM'		    , 'k'  UNION
	SELECT 'Message Board Count'	  , @db + '_' + 'MB'			, 'c'  UNION
	SELECT 'Message Board List'		  , @db + '_' + 'MB'			, 'v'  UNION
	SELECT 'View report list'		  , @db + '_' + 'RptList'		, NULL 

	SELECT DISTINCT Menu	[source], key_prefix , ISNULL(key_suffix,'')  key_suffix
	FROM #final_list 
	ORDER BY menu

	

	END
END

