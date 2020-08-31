IF OBJECT_ID(N'[dbo].[spa_static_data_privilege]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_static_data_privilege
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2016-2-24
-- Description: CRUD operations for table static_data_privilege
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- flag = 'p' - Returns privileges status for source object. Supported source_object = contract, counterparty, commodity, location, meter, pricecurve
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_static_data_privilege
    @flag CHAR(1),
	@type_id VARCHAR(MAX) = NULL,
	@value_id VARCHAR(MAX) = NULL,
	@allow_deny CHAR(1) = NULL,
	@user_id VARCHAR(MAX) = NULL,
	@role_id VARCHAR(MAX) = NULL,
	@deactive CHAR(1) = NULL,
	@xml_data NVARCHAR(MAX) = NULL,
	@call_from INT = NULL,
	@source_object VARCHAR(50) = NULL
AS

SET NOCOUNT ON	
/*
DECLARE		@flag CHAR(1),
			@type_id VARCHAR(MAX) = NULL,
			@value_id VARCHAR(MAX) = NULL,
			@allow_deny CHAR(1) = NULL,
			@user_id VARCHAR(MAX) = NULL,
			@role_id VARCHAR(MAX) = NULL,
			@deactive CHAR(1) = NULL,
			@xml_data NVARCHAR(MAX) = NULL,
			@call_from INT = NULL,
			@source_object VARCHAR(50) = NULL

SELECT @flag='s',@value_id=NULL,@type_id='4000',@call_from='1'

IF OBJECT_ID('tempdb..#final_privilege_list') IS NOT NULL
	DROP TABLE #final_privilege_list

CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT)
--end of debugging code block. 
--*/	

IF OBJECT_ID('tempdb..#temp_static_data_type') IS NOT NULL
	DROP TABLE #temp_static_data_type

DECLARE @sql VARCHAR(MAX)
	, @db_user VARCHAR(200) = dbo.FNADBUser()
	, @isadminuser CHAR(1)

SET @isadminuser = dbo.FNAIsUserOnAdminGroup(@db_user, 0)
--select @db_user,@isadminuser

CREATE TABLE #temp_static_data_type(type_id INT)

IF @flag NOT IN ('p')
BEGIN
	IF OBJECT_ID('tempdb..#defination_pre') IS NOT NULL
		DROP TABLE #defination_pre

	CREATE TABLE #defination_pre (
		value_id	INT,
		defination	NVARCHAR(500) COLLATE DATABASE_DEFAULT
	)
	INSERT INTO #defination_pre(value_id, defination)
	SELECT value_id, Tables FROM vwGetAllValueIdTables
END

IF @flag = 'i' -- insert and update mode
BEGIN
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

	SELECT value_id		
		, [type_id]			
		, CASE WHEN code = 'Enable + Modify' THEN 1 ELSE 0 END is_enable
		, [description]	
		, CASE WHEN [user] = 'None' OR [user] = '' THEN NULL ELSE [user] END	[user]
		, CASE WHEN [role] = 'None' THEN NULL ELSE [role] END	[role]
		, '' active_state
		INTO #temp_privilege_grid			
	FROM   OPENXML (@idoc, '/gridXml/GridRow', 1)
			WITH ( 
				value_id		VARCHAR(5000)	'@value_id',						
				type_id			VARCHAR(5000)	'@type_id', 
				code			VARCHAR(5000)	'@code',
				[description]	VARCHAR(5000)	'@description',
				[user]			VARCHAR(5000)	'@user',
				[role]			VARCHAR(5000)	'@role' 
				)
	EXEC sp_xml_removedocument @idoc
 
 
	CREATE TABLE #privilege_row(value_id	INT	
								, type_id	INT		
								, [user]	VARCHAR(1000) COLLATE DATABASE_DEFAULT		
								, [role] VARCHAR(1000) COLLATE DATABASE_DEFAULT
								, is_enable CHAR(1) COLLATE DATABASE_DEFAULT
								, flag CHAR(1) COLLATE DATABASE_DEFAULT)
 
	SELECT type_id
		INTO #active_type_id
	FROM #temp_privilege_grid
	WHERE RTRIM(LTRIM([user])) <> 'All' OR [role] <>  'All'
	UNION ALL
	SELECT DISTINCT  type_id
	FROM static_data_privilege

	--select * 
	UPDATE  tgp 
	SET active_state = 1
	FROM #active_type_id ati
	INNER JOIN #temp_privilege_grid tgp ON tgp.type_id = ati.type_id

	DECLARE @active_state INT 
	DECLARE @is_enable INT

	DECLARE db_cursor CURSOR FOR  
	SELECT value_id		
			, type_id			
			, [user]			
			, [role]
			, active_state
			, is_enable			
	FROM #temp_privilege_grid
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO  @value_id		
			, @type_id			
			, @user_id 			
			, @role_id 	
			, @active_state
			, @is_enable
	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		IF @user_id = 'All'
		BEGIN 
			
			INSERT INTO #privilege_row( value_id		
								, type_id			
								, [user]
								, is_enable
								, flag)
			SELECT @value_id, @type_id, user_login_id, @is_enable, 'i' FROM application_users
		END 
		ELSE IF @user_id IS NULL
		BEGIN 
			INSERT INTO #privilege_row( value_id		
								, type_id			
								, [user]
								, is_enable
								, flag)
			SELECT @value_id, @type_id, user_login_id, @is_enable, 'd' FROM application_users
		END
		ELSE 
		BEGIN 
			INSERT INTO #privilege_row( value_id		
										, type_id			
										, [user]
										, is_enable
										, flag)
			SELECT @value_id, @type_id, item, @is_enable, 'i'  FROM dbo.FNASplit(@user_id, ',') 
		END 

		IF @role_id = 'All'
		BEGIN				  
			INSERT INTO #privilege_row( value_id		
									, type_id			
									, [role]
									, is_enable
									, flag)
			SELECT @value_id, @type_id, asr.role_id, @is_enable, 'i' FROM application_security_role asr 		 			 
		END 
		ELSE IF @role_id IS NULL
		BEGIN 
			INSERT INTO #privilege_row( value_id		
								, type_id			
								, [role]
								, is_enable
								, flag)
			SELECT @value_id, @type_id, asr.role_id, @is_enable, 'd' FROM application_security_role asr 
		END
		ELSE 
		BEGIN 
			INSERT INTO #privilege_row(value_id		
										, type_id			
										, [role]
										, is_enable
										, flag)
			SELECT @value_id, @type_id, asr.role_id, @is_enable, 'i'
			FROM dbo.FNASplit(@role_id, ',') i
			INNER JOIN application_security_role asr ON asr.role_name = i.item
		END 
		FETCH NEXT FROM db_cursor INTO @value_id		
			, @type_id			
			, @user_id 			
			, @role_id 	
			, @active_state
			, @is_enable
	END   
	CLOSE db_cursor   
	DEALLOCATE db_cursor
 
	--handle none case 
 	IF EXISTS(SELECT  1
			FROM #privilege_row WHERE flag = 'd')
	BEGIN
		--select *   
		DELETE sdp
		FROM #privilege_row tsdp
		INNER JOIN static_data_privilege sdp ON sdp.type_id = tsdp.type_id
			AND sdp.value_id = tsdp.value_id
			AND tsdp.[user] = sdp.user_id
			AND tsdp.is_enable = sdp.is_enable
		WHERE tsdp.flag = 'd'
			 
		DELETE sdp
		FROM #privilege_row tsdp
		INNER JOIN static_data_privilege sdp ON sdp.type_id = tsdp.type_id
			AND sdp.value_id = tsdp.value_id
			AND tsdp.role = sdp.role_id
			AND tsdp.is_enable = sdp.is_enable
		WHERE tsdp.flag = 'd'
		 
	END  
	 
	--SELECT * 
	DELETE sdp
	FROM static_data_privilege sdp
	LEFT JOIN #privilege_row tsdp ON  sdp.value_id = tsdp.value_id
			AND tsdp.is_enable = sdp.is_enable
	WHERE sdp.role_id NOT IN (SELECT [role] FROM #privilege_row WHERE [role] IS NOT NULL)
		AND tsdp.[role] IS NOT NULL
	--SELECT * 
	DELETE sdp
	FROM static_data_privilege sdp
	LEFT JOIN #privilege_row tsdp ON  sdp.value_id = tsdp.value_id
			AND tsdp.is_enable = sdp.is_enable
	WHERE sdp.user_id NOT IN (SELECT [user] FROM #privilege_row WHERE [user] IS NOT NULL)
		AND tsdp.[user] IS NOT NULL
	 
	DELETE sdp
	FROM static_data_privilege sdp
	INNER JOIN #privilege_row tsdp ON  sdp.value_id = tsdp.value_id
			AND tsdp.is_enable <> sdp.is_enable
	 
		
	DELETE sdp
	FROM static_data_privilege sdp
	INNER JOIN #privilege_row tsdp ON  sdp.value_id = tsdp.value_id
			AND tsdp.is_enable <> sdp.is_enable
	 
    
	BEGIN TRY
		BEGIN TRAN
		--for user

		MERGE static_data_privilege AS target
		USING (SELECT type_id, value_id,  [user], is_enable FROM #privilege_row WHERE [user] IS NOT NULL AND flag <> 'd') AS source  
		ON (target.type_id = source.type_id
				AND target.value_id = source.value_id
				AND target.user_id = source.[user]
				AND ISNULL(target.is_enable, 0) = source.is_enable
				)
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (type_id
				, value_id
				, user_id, is_enable) VALUES (source.type_id
									, source.value_id
									 , source.[user]
									 , source.is_enable);
		 
		--for role
		MERGE static_data_privilege AS target
		USING (SELECT type_id, value_id, [role], is_enable FROM #privilege_row WHERE [role] IS NOT NULL AND flag <> 'd') AS source  
		ON (target.type_id = source.type_id
				AND target.value_id = source.value_id
				AND target.role_id = source.[role]
				AND ISNULL(target.is_enable, 0) = source.is_enable)
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (type_id
				, value_id
				, role_id, is_enable) VALUES (source.type_id
									, source.value_id
									 , source.[role], source.is_enable);

	
		COMMIT TRAN
		EXEC spa_ErrorHandler 0
		   , 'static_data_privilege'
		   , 'spa_static_data_privilege'
		   , 'Success'
		   , 'Changes have been saved successfully.'
		   , ''
 
   	     
	 END TRY 
	 BEGIN CATCH 
		 IF @@TRANCOUNT > 0 ROLLBACK TRAN
 
	      EXEC spa_ErrorHandler -1
	           , 'static_data_privilege'
			   , 'spa_static_data_privilege'
			   , 'DB ERROR'
			   , 'Error while assigning privilege.'
			   , ''
	 END CATCH

END
ELSE IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#accordion_data_grid') IS NOT NULL
	DROP TABLE #accordion_data_grid

	IF OBJECT_ID('tempdb..#defination') IS NOT NULL
	DROP TABLE #defination
  
	IF OBJECT_ID('tempdb..#collect_definition') IS NOT NULL
	DROP TABLE #collect_definition

	IF OBJECT_ID('tempdb..#a') IS NOT NULL
	DROP TABLE #a

	IF OBJECT_ID('tempdb..#new_data_privilege') IS NOT NULL
	DROP TABLE #new_data_privilege

	IF OBJECT_ID('tempdb..#no_enable_row') IS NOT NULL
	DROP TABLE #no_enable_row

	CREATE TABLE #defination (
		value_id	INT,
		defination	NVARCHAR(500) COLLATE DATABASE_DEFAULT
	)
	

	INSERT INTO #defination(value_id, defination)
	SELECT value_id, defination 
	FROM #defination_pre dp
	INNER JOIN dbo.FNASplit(@type_id, ',') i On i.item = dp.value_id
 
	CREATE TABLE #accordion_data_grid(
		rownumber					INT IDENTITY(1,1),
		accordion_name				NVARCHAR(200) COLLATE DATABASE_DEFAULT,
		application_function_id		INT,
		value_id					INT,
		code						NVARCHAR(500) COLLATE DATABASE_DEFAULT,
		template_name				NVARCHAR(100) COLLATE DATABASE_DEFAULT DEFAULT NULL,
		identity_col				NVARCHAR(100) COLLATE DATABASE_DEFAULT DEFAULT NULL,		
		height						NVARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT ('*'),
		description				    NVARCHAR(500) COLLATE DATABASE_DEFAULT DEFAULT ('*'),
		definition_id				INT
	)
 
	SET @sql = 'INSERT INTO #accordion_data_grid (accordion_name, application_function_id, value_id, code, description, identity_col, definition_id)
				SELECT  DISTINCT type_name
					, CASE 
						WHEN sdt.type_id = 10017 THEN 10101021	--Calendar
						WHEN sdt.type_id = 10018 THEN 10101024	--Hourly Block
						WHEN sdt.type_id = 30900 THEN 10101050  --Account
						WHEN sdt.type_id = 29600 THEN 10101060  --Quality
					 ELSE 10101010
					  END [type_id]
					, sdv.value_id, sdv.code
					, sdv.description
					, ''value_id''
					, sdt.type_id
				FROM static_data_type sdt
				LEFT JOIN static_data_value sdv ON sdv.type_id = sdt.type_id'
	
	IF @type_id IS NOT NULL 
		SET @sql = @sql + ' INNER JOIN dbo.FNASplit(''' + @type_id + ''', '','') type_i ON type_i.item = sdt.type_id'

	IF @value_id IS NOT NULL 
		SET @sql = @sql + ' INNER JOIN dbo.FNASplit(''' + @value_id + ''', '','') value_i ON value_i.item = sdv.value_id'

	--PRINT (@sql)
	EXEC(@sql)
	
	CREATE TABLE #collect_definition(definition_id INT, application_function_id INT, value_id INT, code VARCHAR(1000) COLLATE DATABASE_DEFAULT, description VARCHAR(1000) COLLATE DATABASE_DEFAULT, identity_col VARCHAR(1000) COLLATE DATABASE_DEFAULT)
	  
	--Collects Definitions
	INSERT INTO #collect_definition
	SELECT d.value_id  definition_id
		, 10101110 application_function_id
		, sb.source_book_id value_id
		, sb.source_book_name + CASE WHEN sb.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END code
		, sb.source_book_desc + CASE WHEN sb.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END description
		, 'source_book_id' AS identity_col 
	FROM #defination d
	LEFT JOIN source_book sb ON d.value_id = 4000
	LEFT JOIN source_system_description ssd ON	ssd.source_system_id = sb.source_system_id
	WHERE d.value_id = 4000
	UNION ALL
	SELECT d.value_id
		, 10101112
		, sc.source_commodity_id
		, sc.commodity_name + CASE WHEN sc.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END
		, sc.commodity_desc AS description
		, 'source_commodity_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_commodity sc ON d.value_id = 4001
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
	WHERE d.value_id=4001
	UNION ALL
	SELECT d.value_id 
		, 10101129
		, sc.source_currency_id
		, sc.currency_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, sc.currency_desc AS description
		, 'source_currency_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_currency sc ON d.value_id = 4003
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
	WHERE d.value_id = 4003
	UNION ALL
	SELECT d.value_id 
		, 10101135
		, sdt.source_deal_type_id
		, sdt.source_deal_type_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, sdt.source_deal_desc AS description
		, 'source_deal_type_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_deal_type sdt ON d.value_id = 4007
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = sdt.source_system_id
	WHERE d.value_id = 4007
	UNION ALL
	SELECT d.value_id 
		, 10101144
		, st.source_trader_id
		, st.trader_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, st.trader_desc AS description
		, 'source_trader_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_traders st ON d.value_id = 4010
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = st.source_system_id
	WHERE d.value_id = 4010
	UNION ALL
	SELECT d.value_id 
		, 10101142
		, sm.[source_major_location_ID]
		, sm.[location_name] + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, sm.location_description AS description
		, 'source_major_location_ID' AS identity_col
	FROM #defination d
	LEFT JOIN [dbo].[source_major_location] sm ON d.value_id = 4030
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = sm.source_system_id
	WHERE d.value_id = 4030
	--UNION ALL
	--SELECT d.value_id 
	--	, 10101180
	--	, sdt.type_id
	--	, sdt.type_name
	--	, sdt.description
	--	, 'type_id' AS identity_col
	--FROM #defination d
	--LEFT JOIN static_data_type sdt ON d.value_id = 4200
	--WHERE d.value_id = 4200
	UNION ALL
	SELECT d.value_id 
		, 10101145
		, su.source_uom_id
		, su.uom_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, su.uom_desc AS description
		, 'source_uom_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_uom su ON d.value_id = 4011
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = su.source_system_id
	WHERE d.value_id = 4011
	UNION ALL
	SELECT d.value_id 
		, 10101143
		, spr.[source_product_id]
		, spr.product_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, spr.product_desc AS description
		, 'source_product_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_product spr ON d.value_id = 4020
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = spr.source_system_id 
	WHERE d.value_id = 4020
	UNION ALL
	SELECT d.value_id 
		, 10101138
		, sle.source_legal_entity_id
		, sle.legal_entity_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
		, sle.legal_entity_desc AS description
		, 'source_legal_entity_id' AS identity_col
	FROM #defination d
	LEFT JOIN source_legal_entity sle ON d.value_id = 4017
	LEFT JOIN source_system_description ssd ON ssd.source_system_id = sle.source_system_id
	WHERE d.value_id = 4017
	
	IF @call_from = 1
	BEGIN 
		INSERT INTO #collect_definition
		SELECT d.value_id 
			, 10105800
			, sle.source_counterparty_id
			, sle.counterparty_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
			, sle.counterparty_desc AS description
			, 'source_counterparty_id' AS identity_col
		FROM #defination d
		LEFT JOIN source_counterparty sle ON d.value_id = 4002
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sle.source_system_id
		WHERE d.value_id = 4002
		UNION ALL
		SELECT d.value_id 
			, 10105800
			, sle.source_minor_location_id
			, sle.location_id + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
			, sle.Location_Description AS description
			, 'source_minor_location_id' AS identity_col
		FROM #defination d
		LEFT JOIN source_minor_location sle ON d.value_id = 4031
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sle.source_system_id
		WHERE d.value_id = 4031
		UNION ALL
		SELECT d.value_id 
			, 10105800
			, cg.contract_id
			, cg.contract_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END 
			, cg.contract_name AS description
			, 'contract_id' AS identity_col
		FROM #defination d
		LEFT JOIN contract_group cg ON d.value_id = 4016
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = cg.source_system_id
		WHERE contract_type_def_id = '38400'
			AND d.value_id = 4016
		UNION ALL
		SELECT d.value_id 
			, 10105800
			, cg.contract_id
			, cg.contract_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END 
			, cg.contract_name AS description
			, 'contract_id' AS identity_col
		FROM #defination d
		LEFT JOIN contract_group cg ON d.value_id = 4073
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = cg.source_system_id
		WHERE contract_type_def_id = '38401'
			AND d.value_id = 4073
		UNION ALL
		SELECT d.value_id 
			, 10105800
			, cg.contract_id
			, cg.contract_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END 
			, cg.contract_name AS description
			, 'contract_id' AS identity_col
		FROM #defination d
		LEFT JOIN contract_group cg ON d.value_id = 4074
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = cg.source_system_id
		WHERE contract_type_def_id = '38402'
			AND d.value_id = 4074	
		UNION ALL
		SELECT d.value_id 
			, 10105800
			, sle.source_curve_def_id
			, sle.curve_id + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
			, sle.curve_name AS description
			, 'source_curve_def_id' AS identity_col
		FROM #defination d
		LEFT JOIN source_price_curve_def sle ON d.value_id = 4008
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sle.source_system_id
		WHERE d.value_id = 4008
		
		UNION ALL
		SELECT d.value_id 
			, 10103000
			, mi.meter_id
			, mi.recorderid
			, mi.description AS description
			, 'meter_id' AS identity_col
		FROM #defination d
		LEFT JOIN meter_id mi ON d.value_id = 400000
		WHERE d.value_id = 400000
	END
 
 	INSERT INTO #accordion_data_grid (accordion_name, application_function_id, value_id, code, description, identity_col, definition_id)
	SELECT d.defination
		, cd.application_function_id
		, cd.value_id
		, cd.code
		, cd.description
		, cd.identity_col
		, cd.definition_id
	FROM #collect_definition cd
	INNER JOIN #defination d ON cd.definition_id = d.value_id
	
	SELECT DISTINCT  i.item value_id,
			definition_id type_id,
			code, 
			description,
			user_id [user],
			dbo.FNAGetUserName(user_id) [user_name],
			asr.role_name [role],
			CAST(asr.role_id AS VARCHAR(10)) [role_id],
			'' [action],
			sdp.is_enable
		INTO #a
	FROM dbo.FNASplit(@value_id, ',') i
	INNER JOIN #accordion_data_grid adg ON adg.value_id = i.item
	INNER JOIN static_data_privilege sdp ON sdp.value_id = adg.value_id
	LEFT JOIN application_security_role asr ON asr.role_id = sdp.role_id
 
	CREATE TABLE #new_data_privilege(
										value_id INT,
										[type_id] INT,
										code VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										[description] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										[user] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										[role] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										[role_id]  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										[action] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
										is_enable CHAR(1)  COLLATE DATABASE_DEFAULT
									)

	SET @sql = 'INSERT INTO #new_data_privilege
				SELECT DISTINCT adg.value_id value_id,
						adg.definition_id type_id,
						adg.code, 
						adg.description,
						ISNULL(sdp.user_id, NULL) [user],
						ISNULL(asr.role_name, NULL) [role],
						ISNULL(asr.role_id, NULL) [role_id],
						'''' action,
						sdp.is_enable 
				FROM #accordion_data_grid adg
				LEFT JOIN static_data_value sdv ON sdv.value_id = adg.value_id
				LEFT JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
				LEFT JOIN static_data_privilege sdp ON sdp.value_id =  adg.value_id
				LEFT JOIN application_security_role asr ON asr.role_id = sdp.role_id '

	IF @value_id IS NOT NULL 
		SET @sql = @sql + ' INNER JOIN dbo.FNASplit(''' + @value_id + ''', '','') type_i ON type_i.item = adg.value_id 
							WHERE 1 = 1 AND adg.value_id NOT IN (SELECT value_id FROM static_data_privilege sdp
																INNER JOIN dbo.FNASplit(''' + @value_id + ''', '','') i ON i.item = sdp.value_id) '

	--PRINT (@sql)
	EXEC(@sql)
	
	--select * from #a
	CREATE table #no_enable_row(value_id varchar(100) 
								, type_id		VARCHAR(100)
								, code			VARCHAR(100) 		  	 
								, description	VARCHAR(MAX)
								, [user]		VARCHAR(100)
								, role			VARCHAR(100)
								, role_id		VARCHAR(100)
								, action		VARCHAR(100)
								, is_enable     VARCHAR(100))

	INSERT INTO #no_enable_row
	SELECT  value_id
			, MAX(type_id) type_id
			, MAX(code) code
			, MAX(description) description
			, MAX([user]) [user]
			, MAX(role) role
			, MAX(role_id) role_id
			, MAX(action) action
			, MAX(is_enable) is_enable
		FROM (	SELECT value_id
					, MAX(type_id) type_id
					, MAX(code) code
					, MAX(description) description
					, 'None' [user] 
					, 'None' role
					, 'None' role_id
					, MAX(action) action
					, is_enable			
			FROM #new_data_privilege
			GROUP BY value_id, is_enable
	) a
	GROUP by value_id  
	HAVING COUNT(value_id) = 1


	INSERT INTO #no_enable_row
	SELECT  value_id
			, MAX(type_id) type_id
			, MAX(code) code
			, MAX(description) description
			, MAX([user]) [user]
			, MAX(role) role
			, MAX(role_id) role_id
			, MAX(action) action
			, MAX(is_enable) is_enable
		FROM (	SELECT value_id
					, MAX(type_id) type_id
					, MAX(code) code
					, MAX(description) description
					, 'None' [user] 
					, 'None' role
					, 'None' role_id
					, MAX(action) action
					, is_enable			
			FROM #a
			GROUP BY value_id, is_enable
	) a
	GROUP by value_id  
	HAVING COUNT(value_id) = 1

	IF EXISTS(SELECT 1 FROM #no_enable_row)
	BEGIN 
		INSERT INTO #a( code	
						, value_id	
						, type_id	
						, description	
						, [user]
						, role	
						, role_id
						, action	
						, is_enable)
		SELECT code	
			, value_id	
			, type_id	
			, description	
			, [user]
			, role	
			, role_id	
			, action	
			, CASE WHEN is_enable = 1 THEN 0 ELSE 1 END FROM #no_enable_row
	END
 
	SELECT code,value_id,
		[type_id],		
		[description],
		ISNULL([user], 'None') [user],
		ISNULL([user_name], 'None') [user_name],
		ISNULL([role], 'None') [role],
		ISNULL([role_id], 'None') [role_id],
		'<a href="javascript:void(0);" onclick="add_edit_privilege(' + CAST((ROW_NUMBER() OVER(ORDER BY value_id, code) -1) AS VARCHAR(100)) + ')">Edit</a>' [action],
		CASE WHEN ISNULL(is_enable, 0) = 0 THEN 'Disable + View Only' ELSE 'Enable + Modify' END [disabled]
	FROM (
		SELECT value_id,
					MAX([type_id]) [type_id],
					MAX(code) code,
					MAX([description]) [description],
					STUFF((SELECT ', ' + ISNULL([user], 'None')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '') [user],
				
				  STUFF((SELECT ', ' + ISNULL(dbo.FNAGetUserName([user]), 'None')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '') [user_name],

					STUFF((SELECT ', ' + ISNULL([role], '')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[role] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '')  [role],

					STUFF((SELECT ', ' + ISNULL([role_id], '')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[role_id] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '')  [role_id],
					'' action,
					is_enable
			FROM   #new_data_privilege a
			WHERE  ISNULL(a.is_enable, 0) = 1 
			GROUP BY value_id, is_enable
			UNION ALL
			SELECT value_id,
				[type_id],
				code,
				[description],
				[user],
				[user_name],
				[role],
				[role_id],
				'' action,
				is_enable
			FROM (SELECT value_id,
					MAX([type_id]) [type_id],
					MAX(code) code,
					MAX([description]) [description],
					STUFF((SELECT ', ' + ISNULL([user], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '') [user],
				

					STUFF((SELECT ', ' + ISNULL(dbo.FNAGetUserName([user_name]), 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[user_name] IS NOT NULL 
								AND b.is_enable = 1
							FOR XML PATH('')), 1, 2, '') [user_name],
				
					STUFF((SELECT ', ' + ISNULL([role], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[role] IS NOT NULL
								AND b.is_enable = 1 
							FOR XML PATH('')), 1, 2, '')  [role],
				
					STUFF((SELECT ', ' + ISNULL([role_id], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[role_id] IS NOT NULL
								AND b.is_enable = 1 
							FOR XML PATH('')), 1, 2, '')  [role_id],
					MAX([action]) [action]
					,is_enable
			FROM #a a
			WHERE  ISNULL(a.is_enable, 0) = 1 
			GROUP BY value_id, is_enable) a
			UNION ALL
			---union for disable
			SELECT value_id,
					MAX([type_id]) [type_id],
					MAX(code) code,
					MAX([description]) [description],
					STUFF((SELECT ', ' + ISNULL([user], 'None')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '') [user],
					STUFF((SELECT ', ' + ISNULL(dbo.FNAGetUserName([user]), 'None')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '') [user_name],
					STUFF((SELECT ', ' + ISNULL([role], '')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[role] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '')  [role],
					STUFF((SELECT ', ' + ISNULL([role_id], '')
							FROM #new_data_privilege b 
							WHERE b.value_id = a.value_id 
								AND b.[role_id] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '')  [role_id],
					'' action,
					is_enable

			FROM   #new_data_privilege a
			WHERE  ISNULL(a.is_enable, 0) = 0 
			GROUP BY value_id, is_enable
			UNION ALL
			SELECT value_id,
				[type_id],
				code,
				[description],
				[user],
				[user_name],
				[role],
				'' [role_id],
				'' action,
				is_enable
			FROM (SELECT value_id,
					MAX([type_id]) [type_id],
					MAX(code) code,
					MAX([description]) [description],
					STUFF((SELECT ', ' + ISNULL([user], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '') [user],
					STUFF((SELECT ', ' + ISNULL(dbo.FNAGetUserName([user]), 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[user] IS NOT NULL 
								AND ISNULL(b.is_enable, 0) = 0
							FOR XML PATH('')), 1, 2, '') [user_name],				
					STUFF((SELECT ', ' + ISNULL([role], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[role] IS NOT NULL
								AND ISNULL(b.is_enable, 0) = 0 
							FOR XML PATH('')), 1, 2, '')  [role],				
					STUFF((SELECT ', ' + ISNULL([role_id], 'None')
							FROM #a b 
							WHERE b.value_id = a.value_id 
								AND b.[role_id] IS NOT NULL
								AND ISNULL(b.is_enable, 0) = 0 
							FOR XML PATH('')), 1, 2, '')  [role_id],
					MAX([action]) [action]
					,is_enable
			FROM #a a
			WHERE  ISNULL(a.is_enable, 0) = 0
			GROUP BY value_id, is_enable) a
	)b 
	ORDER BY [type_id], code, CASE WHEN ISNULL(is_enable, 0) = 0 THEN 'disabled' ELSE 'enabled'  END DESC 
END
ELSE IF @flag = 'd' -- deactivate
BEGIN
	IF @call_from = 1
	BEGIN 
		INSERT INTO #temp_static_data_type(type_id)
		SELECT item FROM dbo.FNASplit(@type_id, ',')
	END
	ELSE 
	BEGIN 
		INSERT INTO #temp_static_data_type(type_id)
		SELECT sdt.type_id 
		FROM dbo.FNASplit(@type_id, ',') i
		INNER JOIN (SELECT type_id,  type_name FROM static_data_type sdt 
					UNION ALL 
					SELECT value_id, defination FROM #defination_pre
		) sdt  ON sdt.type_name = i.item
	END 

	--SELECT * 
	UPDATE sdad
	SET is_active = 0
	FROM #temp_static_data_type i
	INNER JOIN static_data_active_deactive sdad ON sdad.type_id = i.type_id

	EXEC spa_ErrorHandler 0
		   , 'static_data_privilege'
		   , 'spa_static_data_privilege'
		   , 'Success'
		   , 'Changes have been saved successfully.'
		   , ''
END 
ELSE IF @flag = 'a'
BEGIN
	DECLARE @type_ids VARCHAR(MAX)

	IF @call_from = 1
	BEGIN 
		INSERT INTO #temp_static_data_type(type_id)
		SELECT item FROM dbo.FNASplit(@type_id, ',')
	END
	ELSE 
	BEGIN 
		INSERT INTO #temp_static_data_type(type_id)
		SELECT sdt.type_id 
		FROM dbo.FNASplit(@type_id, ',') i
		INNER JOIN (SELECT type_id,  type_name FROM static_data_type sdt 
					UNION ALL 
					SELECT value_id, defination FROM #defination_pre
		) sdt  ON sdt.type_name = i.item
	END 
	IF NOT EXISTS (SELECT 1 
					FROM #temp_static_data_type tsdt
					INNER JOIN static_data_active_deactive sdad ON sdad.type_id = tsdt.type_id)
	BEGIN 
		INSERT INTO static_data_active_deactive([type_id], is_active)
		SELECT sdt.type_id, 1 
		FROM #temp_static_data_type sdt
	END 
	ELSE 
	BEGIN 
		UPDATE sdad
		SET is_active = 1
		FROM #temp_static_data_type tsdt
		INNER JOIN static_data_active_deactive sdad ON sdad.type_id = tsdt.type_id

	END 

	SELECT @type_ids = STUFF((SELECT ', ' + CAST(type_id AS VARCHAR(100))
						FROM #temp_static_data_type tsdt
						FOR XML PATH('')), 1, 2, '') 

	EXEC spa_ErrorHandler 0
		   , 'static_data_privilege'
		   , 'spa_static_data_privilege'
		   , 'Success'
		   , 'Changes have been saved successfully.'
		   , @type_ids
END
ELSE IF @flag = 'c'
BEGIN
		IF OBJECT_ID(N'tempdb..#temp_table') IS NOT NULL
			DROP TABLE #temp_table
		
		CREATE TABLE  #temp_table(is_enable	VARCHAR(8),
			[name] 	NVARCHAR(500) COLLATE DATABASE_DEFAULT)

		IF NOT EXISTS(SELECT 1 FROM static_data_active_deactive WHERE is_active = 1 AND type_id =@type_id) 
		BEGIN
			SELECT 'true' [privilege_status], '' [name]
			RETURN			
		END
	
		DECLARE @source_table_name NVARCHAR(200)
			, @primary_column_name NVARCHAR(200), @sql1 NVARCHAR(4000)
		SELECT @source_table_name = source_table_name
			, @primary_column_name = pk_column
		FROM vwGetAllValueIdTables 
		WHERE value_id = @type_id
		
		--select  @source_table_name,@primary_column_name
		IF OBJECT_ID('tempdb..#entity_privilege') IS NOT NULL
		DROP TABLE #entity_privilege

		CREATE TABLE #entity_privilege (
			type_id		INT,
			value_id	INT,
			user_id 	NVARCHAR(500) COLLATE DATABASE_DEFAULT
		)

		SET @sql1 = 'INSERT INTO #entity_privilege(type_id,value_id,user_id) 
					SELECT ' + CAST(@type_id AS VARCHAR(50)) + ',s.item,rs.create_user FROM ' + @source_table_name + ' rs
					INNER JOIN  dbo.SplitCommaSeperatedValues(''' + @value_id + ''') s ON rs.' + @primary_column_name + '  = s.item
					LEFT JOIN static_data_privilege sdp ON sdp.value_id = s.item	AND sdp.type_id = ' + CAST(@type_id AS VARCHAR(50)) + '
					
					WHERE rs.create_user =  ''' + @db_user + ''' AND sdp.static_data_privilege_id IS NULL'

		--select @sql1	
		EXEC(@sql1)

		--select * from #temp_table

	SET @sql = '
		IF EXISTS (SELECT 1 FROM #entity_privilege)
		BEGIN
			INSERT INTO #temp_table(is_enable,name)	
			SELECT 1 is_enable,'''' [name]
		END
		ELSE
		BEGIN
			INSERT INTO #temp_table(is_enable,name)		
		SELECT is_enable, CASE WHEN ' + @type_id + ' = 4008 THEN spc.curve_name ELSE '''' END [name]
		FROM static_data_privilege sdp
		INNER JOIN  dbo.SplitCommaSeperatedValues(''' + @value_id + ''') s ON sdp.value_id = s.item
		'
	IF @type_id = 4008 --Price Curve
		SET @sql += ' INNER JOIN source_price_curve_def spc ON spc.source_curve_def_id = s.item'
	ELSE
		SET @sql += ' CROSS APPLY (SELECT '''' curve_name) spc'
		
	SET @sql += '
		WHERE type_id = ' + @type_id  + '
			AND user_id = ''' + @db_user + '''
		UNION
		SELECT sdp.is_enable, CASE WHEN ' + @type_id + ' = 4008 THEN spc.curve_name ELSE '''' END [name]
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		INNER JOIN  dbo.SplitCommaSeperatedValues(''' + @value_id + ''') s ON sdp.value_id = s.item
		'
	IF @type_id = 4008
		SET @sql += ' INNER JOIN source_price_curve_def spc ON spc.source_curve_def_id = s.item'
	ELSE
		SET @sql += ' CROSS APPLY (SELECT '''' curve_name) spc'
			
	SET @sql += '
		WHERE sdp.type_id = ' + @type_id + '
			AND asu.user_login_id =  ''' + @db_user + '''

			END
		DECLARE @a VARCHAR(10)
		'
	IF @type_id = 4002 --counterparty
	SET @sql += '			
		SELECT @a = CASE WHEN (SELECT 1 FROM source_counterparty where source_counterparty_id = ' + @value_id + ' and create_user = ''' + @db_user + ''') = 1 THEN ''true''
						 WHEN MIN(a.is_enable) = 1 OR ' + @isadminuser + ' = 1 THEN ''true'' ELSE ''false'' END
		FROM #temp_table a'
	ELSE	
		SET @sql += '			
		SELECT @a = CASE WHEN MIN(a.is_enable) = 1 OR ' + @isadminuser + ' = 1 THEN ''true'' ELSE ''false'' END
		FROM #temp_table a'
	SET @sql += '	
		IF NOT EXISTS(SELECT 1 FROM #temp_table WHERE is_enable = 1)
		BEGIN
			SELECT @a [privilege_status], '''' [name]
		END
		ELSE IF (@a = ''false'' AND ' + @type_id + ' = 4008)
		BEGIN
			SELECT 
				@a [privilege_status],
				SUBSTRING(MAX(s.name), 1, LEN(MAX(s.name)) -1) [name]
			FROM #temp_table a
			CROSS APPLY(
				SELECT name + '', ''
				FROM #temp_table
				WHERE is_enable = 0 AND a.is_enable = is_enable
				FOR XML PATH('''')
			) s (name)
		END
		ELSE
		BEGIN
			SELECT @a [privilege_status]
		END

	'
	EXEC(@sql)
END
ELSE IF @flag = 'p'
BEGIN
	DECLARE @status_check INT

	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
		DROP TABLE #temp

	IF OBJECT_ID('tempdb..#all_data') IS NOT NULL
		DROP TABLE #all_data

	IF OBJECT_ID('tempdb..#collect_privilege') IS NOT NULL
		DROP TABLE #collect_privilege

	CREATE TABLE #temp (type_id INT, is_active INT)
	CREATE TABLE #collect_privilege (static_data_privilege_id INT, type_id INT, value_id INT, is_enable INT)
	CREATE TABLE #all_data (type_id INT, value_id INT, user_id VARCHAR(1000) COLLATE DATABASE_DEFAULT, role_id INT,  is_enable INT, is_active INT, name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
	
	IF @source_object = 'contract'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id IN (4074, 4073, 4016)
		
		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp

		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT contract_id, 'Enable' 
			FROM contract_group
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id IN (4074, 4073, 4016)
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id IN (4074, 4073, 4016)
		UNION ALL 
		SELECT -1
			, 4016
			, cg.contract_id
			, 1
		FROM contract_group cg
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4074, 4073, 4016) AND sdp.value_id = cg.contract_id
		WHERE cg.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		
	END	-- contract ends
	ELSE IF @source_object = 'counterparty'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4002

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_counterparty_id,'Enable' 
			FROM source_counterparty
			
			RETURN
		END
		
		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4002
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4002
		UNION ALL 
		SELECT -1
			, 4002
			, sc.source_counterparty_id
			, 1
		FROM source_counterparty sc 
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4002 AND sdp.value_id = sc.source_counterparty_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL

	END	-- counterparty ends
	ELSE IF @source_object = 'commodity'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4001

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_commodity_id,'Enable' 
			FROM source_commodity
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4001
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4001
		UNION ALL 
		SELECT -1
			, 4001
			, sc.source_commodity_id
			, 1
		FROM source_commodity sc
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4001) AND sdp.value_id = sc.source_commodity_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		
	END	-- commodity ends
	ELSE IF @source_object = 'location'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4031

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_minor_location_id, 'Enable' 
			FROM source_minor_location
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4031
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4031
		UNION ALL 
		SELECT -1
			, 4031
			, sml.source_minor_location_id
			, 1
		FROM source_minor_location sml 
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4031 AND sdp.value_id =sml.source_minor_location_id
		WHERE sml.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END	-- location
	ELSE IF @source_object = 'meter'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 400000

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT meter_id, 'Enable' 
			FROM meter_id
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 400000
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 400000
		UNION ALL 
		SELECT -1
			, 400000
			, mi.meter_id
			, 1
		FROM meter_id mi 
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 400000 AND sdp.value_id = mi.meter_id
		WHERE mi.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL

	END
	ELSE IF @source_object = 'pricecurve'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4008

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_curve_def_id, 'Enable' 
			FROM source_price_curve_def
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4008
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4008
		UNION ALL 
		SELECT -1
			, 4008
			, spcd.source_curve_def_id
			, 1
		FROM source_price_curve_def spcd 
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4008 AND sdp.value_id = spcd.source_curve_def_id
		WHERE spcd.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL

	END	-- pricecurve
	ELSE IF @source_object = 'uom'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4011

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_uom_id, 'Enable' 
			FROM source_uom
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user 
		AND sdp.type_id = 4011
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4011
		UNION ALL 
		SELECT -1
			, 4011
			, su.source_uom_id
			, 1
		FROM source_uom su
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4011 AND sdp.value_id = su.source_uom_id
		WHERE su.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'deal_type'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4007

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_deal_type_id, 'Enable' 
			FROM source_deal_type
			
			RETURN
		END
		
		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4007
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4007
		UNION ALL 
		SELECT -1
			, 4007
			, sdt.source_deal_type_id
			, 1
		FROM source_deal_type sdt
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4007 AND sdp.value_id = sdt.source_deal_type_id
		WHERE sdt.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'currency'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4003

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_currency_id, 'Enable' 
			FROM source_currency
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4003
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4003
		UNION ALL 
		SELECT -1
			, 4003
			, sc.source_currency_id
			, 1
		FROM source_currency sc
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4003 AND sdp.value_id = sc.source_currency_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'book'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4003

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_book_id, 'Enable' 
			FROM source_book
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4000
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4000
		UNION ALL 
		SELECT -1
			, 4000
			, sb.source_book_id
			, 1
		FROM source_book sb
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4000 AND sdp.value_id = sb.source_book_id
		WHERE sb.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'legal_entity'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4017

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_legal_entity_id, 'Enable' 
			FROM source_legal_entity
			
			RETURN
		END
		
		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4017
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id = @db_user
		AND type_id = 4017
		UNION ALL 
		SELECT -1
			, 4017
			, sle.source_legal_entity_id
			, 1
		FROM source_legal_entity sle
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4017 AND sdp.value_id = sle.source_legal_entity_id
		WHERE sle.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'traders'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4010

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_trader_id, 'Enable' 
			FROM source_traders
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4010
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4010
		UNION ALL 
		SELECT -1
			, 4010
			, st.source_trader_id
			, 1
		FROM source_traders st
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4010 AND sdp.value_id = st.source_trader_id
		WHERE st.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'location_group'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4030

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_major_location_ID, 'Enable' 
			FROM source_major_location
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4030
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4030
		UNION ALL 
		SELECT -1
			, 4030
			, sml.source_major_location_ID
			, 1
		FROM source_major_location sml
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4030 AND sdp.value_id = sml.source_major_location_ID
		WHERE sml.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END
	ELSE IF @source_object = 'product'
	BEGIN
		INSERT INTO #temp (type_id, is_active)
		SELECT type_id, is_active
		FROM static_data_active_deactive WHERE type_id = 4020

		SET @status_check = 0
		SELECT TOP 1 @status_check = is_active FROM #temp
		
		IF (@isadminuser = 1 OR @status_check = 0)
		BEGIN
			INSERT INTO #final_privilege_list(value_id, is_enable) 				 
			SELECT source_product_id, 'Enable' 
			FROM source_product
			
			RETURN
		END

		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user
		AND sdp.type_id = 4020
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp WHERE user_id =  @db_user
		AND type_id = 4020
		UNION ALL 
		SELECT -1
			, 4020
			, spr.source_product_id
			, 1
		FROM  source_product spr
		LEFT JOIN static_data_privilege sdp ON sdp.type_id = 4020 AND sdp.value_id = spr.source_product_id
		WHERE spr.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
	END

	INSERT INTO #final_privilege_list(value_id, is_enable)
	SELECT cp.value_id, CASE WHEN ISNULL(cp.is_enable, 0) = 1 THEN 'Enable' ELSE 'Disable' END
	FROM #collect_privilege cp	
END
ELSE IF @flag = 'x'
BEGIN
	SELECT 1
    FROM static_data_privilege sdp
    LEFT JOIN static_data_active_deactive sdad
        ON sdp.type_id = sdad.type_id
    WHERE sdp.type_id = 5500
        AND user_id = dbo.FNADBUser()
        AND sdad.is_active = 1
	UNION
	SELECT 1
	FROM static_data_active_deactive 
	WHERE type_id = 5500
		AND is_active  = 0
END
GO