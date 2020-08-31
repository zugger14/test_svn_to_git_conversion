
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_StaticDataValues]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_StaticDataValues]
GO

/**
	Returns static data values for a given type, inserts/updates/deletes and list a value for a static data type.

	Parameters
	@flag : Operation flag.
		's' for select values, 'i' for insert, 'u' for update, 'd' for delete.
		'c' - list function category used in formula editor.
		'g' - list in accordion grid.
		'h' - list data according to type ID in combo field.
		'o' - Generate a comma separated list (e.g. to use in spa_html_header)
	@type_id : Static data type id.
	@entity_id : Not used in bussiness logic.
	@value_id : Unique identifier of value.
	@code : Static data name.
	@description : Description of static data value.
	@license_not_to_static_value_id : TBD
	@category_id : Category of static data value.
	@limit_type : Used for filtering limit type in the block 'l'
	@generator_id :
	@value_ids : Comma separated value ids.
	@call_from : Not in use.
	@chart_of_account_type : Chart of account type in setting GL codes.
	@entity_name_filter : Non pure static data id.
	@internal_external : Type of static data. 'i' for internal. 'e' for external.
	@active_inactive_filter : Set 0  to list inactive data. Defautl is 1.
	@filter_value  : Comma separated value ids to list specific value only.
	
*/

CREATE PROCEDURE [dbo].[spa_StaticDataValues]
	@flag AS CHAR(1), --'f'
	@type_id AS INT = NULL,
	@entity_id AS INT = NULL,
	@value_id AS INT = NULL,
	@code AS NVARCHAR(2000) = NULL,
	@description AS NVARCHAR(250) = NULL,
	@license_not_to_static_value_id AS NVARCHAR(500) = NULL,
	@category_id INT = NULL,
	@limit_type CHAR(1) = NULL,
	@generator_id INT = NULL,
	@value_ids NVARCHAR(2000) = NULL,
	@call_from CHAR(1) = NULL, -- when passing number of value id's e.g. for flag 'o'
	@chart_of_account_type INT = NULL, -- CHART  OF ACCOUNT TYPE in Setting up GL Codes
	@entity_name_filter NVARCHAR(500) = NULL,
	@internal_external INT = NULL,
	@active_inactive_filter BIT = 1,
	@filter_value  NVARCHAR(MAX) = NULL
	
AS
/*

declare @flag AS CHAR(1),
	@type_id AS INT = NULL,
	@entity_id AS INT = NULL,
	@value_id AS INT = NULL,
	@code AS NVARCHAR(2000) = NULL,
	@description AS NVARCHAR(250) = NULL,
	@license_not_to_static_value_id AS NVARCHAR(500) = NULL,
	@category_id INT = NULL,
	@limit_type CHAR(1) = NULL,
	@generator_id INT = NULL,
	@value_ids NVARCHAR(2000) = NULL,
	@call_from CHAR(1) = NULL, -- when passing number of value id's e.g. for flag 'o'
	@chart_of_account_type INT = NULL, -- CHART  OF ACCOUNT TYPE in Setting up GL Codes
	@entity_name_filter NVARCHAR(500) = NULL,
	@internal_external INT = NULL,
	@active_inactive_filter BIT = 1,
	@filter_value  NVARCHAR(MAX) = NULL
select @flag='g',@internal_external='0'

--*/
SET NOCOUNT ON

DECLARE @errorCode  INT
DECLARE @group1     NVARCHAR(100),
        @group2     NVARCHAR(100),
        @group3     NVARCHAR(100),
        @group4     NVARCHAR(100)

DECLARE @selectStr     NVARCHAR(4000)
DECLARE @hourly_block  NVARCHAR(200)
DECLARE @db_user NVARCHAR(1000) = dbo.FNADBUser()
	, @is_admin_user BIT 
	, @is_privilege_activated BIT = 0
SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')
SET @is_admin_user = dbo.FNAIsUserOnAdminGroup(@db_user, 0)


IF EXISTS(SELECT * FROM static_data_active_deactive  WHERE type_id = @type_id AND is_active = 1)
BEGIN
	SET @is_privilege_activated = 1
END


IF @flag IN ('g', 'h', 'b', 'j', 'p')
BEGIN 
	
	
	IF OBJECT_ID('tempdb..#collect_privilege') IS NOT NULL
	DROP TABLE #collect_privilege

	CREATE TABLE #collect_privilege(static_data_privilege_id INT, type_id INT, value_id INT, is_enable INT)

	--IF (dbo.FNAAppAdminRoleCheck(@db_user) <> 1)
	--BEGIN 
		INSERT INTO #collect_privilege
		SELECT sdp.static_data_privilege_id
				, sdp.type_id
				, sdp.value_id
				, sdp.is_enable
		FROM static_data_privilege sdp
		LEFT JOIN application_role_user asu  ON asu.role_id = sdp.role_id
		WHERE user_login_id =  @db_user AND sdp.type_id = ISNULL(@type_id, sdp.type_id)
		UNION ALL 
		SELECT sdp.static_data_privilege_id
			, sdp.type_id
			, sdp.value_id
			, sdp.is_enable
		FROM static_data_privilege sdp where user_id =  @db_user AND sdp.type_id = ISNULL(@type_id, sdp.type_id)
		--Listed values into privilege colletion inserted by user in definition tables (Block of code need to be revised).
		UNION ALL 
		SELECT -1
			, 4000
			, sb.source_book_id
			, 1
		FROM source_book sb
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4000) AND sdp.value_id = sb.source_book_id
		WHERE sb.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
				, 4001
				, sc.source_commodity_id
				, 1
		FROM source_commodity sc 
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4001) AND sdp.value_id = sc.source_commodity_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4003
			, sc.source_currency_id
			, 1
		FROM  source_currency sc
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4003) AND sdp.value_id = sc.source_currency_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4007
			, sdt.source_deal_type_id
			, 1
		FROM  source_deal_type sdt
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4007) AND sdp.value_id = sdt.source_deal_type_id
		WHERE sdt.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4010
			, st.source_trader_id
			, 1
		FROM  source_traders st
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4010) AND sdp.value_id = st.source_trader_id
		WHERE st.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4030
			, sm.source_major_location_ID
			, 1
		FROM  source_major_location sm
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4030) AND sdp.value_id = sm.source_major_location_ID
		WHERE sm.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4011
			, su.source_uom_id
			, 1
		FROM  source_uom su
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4011) AND sdp.value_id = su.source_uom_id
		WHERE su.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4020
			, sp.source_product_id
			, 1
		FROM  source_product sp
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4020) AND sdp.value_id = sp.source_product_id
		WHERE sp.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4017
			, sle.source_legal_entity_id
			, 1
		FROM  source_legal_entity sle
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4017) AND sdp.value_id = sle.source_legal_entity_id
		WHERE sle.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4070
			, ct.commodity_type_id
			, 1
		FROM  commodity_type ct
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4070) AND sdp.value_id = ct.commodity_type_id
		WHERE ct.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4070
			, ca.commodity_attribute_id
			, 1
		FROM  commodity_attribute ca
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4071) AND sdp.value_id = ca.commodity_attribute_id
		WHERE ca.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4069
			, sc.source_container_id
			, 1
		FROM  source_container sc
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4069) AND sdp.value_id = sc.source_container_id
		WHERE sc.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		UNION ALL
		SELECT -1
			, 4076
			, drip.deal_reference_id_prefix_id
			, 1
		FROM  deal_reference_id_prefix drip
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = drip.[deal_type]
		LEFT JOIN static_data_privilege sdp ON sdp.type_id IN (4076) AND sdp.value_id = drip.deal_reference_id_prefix_id
		WHERE drip.create_user =   @db_user AND sdp.static_data_privilege_id IS NULL
		
	--END

	DECLARE @sql			NVARCHAR(MAX)
		, @def				NVARCHAR(500)
		, @template_name	NVARCHAR(100)
		, @identity_col		NVARCHAR(100)
		, @table_name		NVARCHAR(100)

	IF OBJECT_ID('tempdb..#accordion_data_grid') IS NOT NULL
	DROP TABLE #accordion_data_grid

	IF OBJECT_ID('tempdb..#defination') IS NOT NULL
	DROP TABLE #defination

	IF OBJECT_ID('tempdb..#collect_definition') IS NOT NULL
	DROP TABLE #collect_definition

	CREATE TABLE #defination (
		value_id	INT,
		defination	NVARCHAR(500) COLLATE DATABASE_DEFAULT
	)


	INSERT INTO #defination(value_id, defination)
	SELECT value_id, Tables  FROM vwGetAllValueIdTables
	--select * from #defination
	--select * from vwGetAllValueIdTables
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
		definition_id				INT,
		update_ts					DATETIME,
		update_user					NVARCHAR(100) COLLATE DATABASE_DEFAULT  DEFAULT NULL ,
		create_ts					DATETIME,
		create_user					NVARCHAR(100) COLLATE DATABASE_DEFAULT  DEFAULT NULL,
		code1						NVARCHAR(500) COLLATE DATABASE_DEFAULT  DEFAULT NULL
	)

	SET @sql = 'INSERT INTO #accordion_data_grid (accordion_name, application_function_id, value_id, code, description, identity_col, definition_id, update_ts, update_user, create_ts, create_user, code1)
				SELECT  type_name
				, CASE 
					WHEN sdt.type_id = 10017 THEN 10101021	--Calendar
					WHEN sdt.type_id = 10018 THEN 10101024	--Hourly Block
					WHEN sdt.type_id = 15001 THEN 10101034	--Block Type
					WHEN sdt.type_id = 30900 THEN 10101050  --Account
					WHEN sdt.type_id = 29600 THEN 10101060  --Quality
					WHEN sdt.type_id = 10011 THEN 10101025  --Certification Systems
				 ELSE 10101010
				  END  
				, sdv.value_id, sdv.code
				, sdv.description
				, ''value_id''
				, sdt.type_id
				, sdv.update_ts
				, sdv.update_user
				, sdv.create_ts
				, sdv.create_user
				, sdv.code
				FROM static_data_type sdt
				LEFT JOIN static_data_value sdv ON sdv.type_id = sdt.type_id'
				
	IF @flag = 'g'
		--SET @sql += ' AND CAST(ISNULL(sdv.value_id, 1) AS INT) > 0'
		
	SET @sql += ' WHERE 1 = 1 '

	IF @flag = 'g'
		SET @sql = @sql + ' AND is_active =  '+CAST(@active_inactive_filter AS NVARCHAR)

	IF @internal_external IS NOT NULL
		SET @sql = @sql + ' AND internal = ' + CAST(@internal_external AS NVARCHAR(10))
	IF @category_id IS NOT NULL
		SET @sql = @sql + ' AND category_id = ' + CAST(@category_id AS NVARCHAR(10)) 
	IF @code IS NOT NULL
	SET @sql += ' AND sdv.code IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @code + ''')) '
	
	IF @type_id IS NOT NULL
		SET @sql = @sql + ' AND sdt.type_id = ' + CAST(@type_id AS NVARCHAR(10)) 
	--PRINT @sql
	EXEC(@sql)
	

	CREATE TABLE #collect_definition(definition_id INT, application_function_id INT, value_id INT, code NVARCHAR(1000) COLLATE DATABASE_DEFAULT, description NVARCHAR(1000) COLLATE DATABASE_DEFAULT, identity_col NVARCHAR(1000) COLLATE DATABASE_DEFAULT, update_ts DATETIME, update_user NVARCHAR(1000) COLLATE DATABASE_DEFAULT, create_ts DATETIME, create_user NVARCHAR(1000) COLLATE DATABASE_DEFAULT, code1 NVARCHAR(1000) COLLATE DATABASE_DEFAULT)
	IF @internal_external = 0 AND @active_inactive_filter = 1 AND @flag <> 'h'
	BEGIN 
		--Collects Definitions
		INSERT INTO #collect_definition
		SELECT d.value_id  definition_id
		, 10101110 application_function_id
		, sb.source_book_id value_id
		, sb.source_book_name + CASE WHEN sb.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END code
		, sb.source_book_desc + CASE WHEN sb.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END description
		, 'source_book_id' AS identity_col,
		sb.update_ts [update_ts],
		sb.update_user  [update_user],
		sb.create_ts  [create_ts],
		sb.create_user [create_user],
		sb.source_system_book_id [code1] 
		FROM #defination d
		LEFT JOIN source_book sb ON d.value_id = 4000
		LEFT JOIN source_system_description ssd ON	ssd.source_system_id = sb.source_system_id
		WHERE d.value_id=4000
		UNION ALL
		SELECT d.value_id
				, 10101112
				, sc.source_commodity_id
				, sc.commodity_name + CASE WHEN sc.source_system_id = 2 THEN '' ELSE '.' + ssd.source_system_name END
				, sc.commodity_desc AS description
				, 'source_commodity_id' AS identity_col
				, sc.update_ts 
				, sc.update_user
				, sc.create_ts  
				, sc.create_user
				, sc.commodity_id
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
			, sc.update_ts 
			, sc.update_user
			, sc.create_ts  
			, sc.create_user
			, sc.currency_id
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
			, sdt.update_ts 
			, sdt.update_user
			, sdt.create_ts  
			, sdt.create_user
			, sdt.deal_type_id
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
			, st.update_ts 
			, st.update_user
			, st.create_ts  
			, st.create_user
			, st.trader_id
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
			, sm.update_ts 
			, sm.update_user
			, sm.create_ts  
			, sm.create_user
			, sm.location_name
		FROM #defination d
		LEFT JOIN [dbo].[source_major_location] sm ON d.value_id = 4030
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sm.source_system_id
		WHERE d.value_id = 4030

		--========================================================================

		UNION ALL
		SELECT d.value_id 
			, 10101190
			, sm.[deal_reference_id_prefix_id]
			--, sm.[prefix] + CASE WHEN sdt.source_deal_type_name IS NULL THEN '' ELSE  ' ['+ sdt.source_deal_type_name + ']' END
			--, sm.[prefix] + CASE WHEN sdt.source_deal_type_name IS NULL THEN '' ELSE  ' ['+ sdt.source_deal_type_name + ']' END description
			, sm.[prefix] [code]
			, sm.[prefix] [description]  
			, 'deal_reference_id_prefix_id' as identity_col
			, sm.update_ts 
			, sm.update_user
			, sm.create_ts  
			, sm.create_user
			, sm.prefix
		FROM #defination d
		LEFT JOIN [dbo].[deal_reference_id_prefix] sm ON d.value_id = 4076
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sm.[deal_type]
		WHERE d.value_id = 4076

 		--===============================================================================

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
			, su.update_ts 
			, su.update_user
			, su.create_ts  
			, su.create_user
			, su.uom_id
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
			, spr.update_ts 
			, spr.update_user
			, spr.create_ts  
			, spr.create_user
			, spr.product_id
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
			, sle.update_ts 
			, sle.update_user
			, sle.create_ts  
			, sle.create_user
			, sle.legal_entity_id
		FROM #defination d
		LEFT JOIN source_legal_entity sle ON d.value_id = 4017
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sle.source_system_id
		WHERE d.value_id = 4017
		UNION ALL
		SELECT d.value_id
			, 10101070
			, pt.commodity_type_id
			, pt.commodity_name
			, pt.commodity_description
			, 'commodity_type_id' identity_col
			, pt.update_ts 
			, pt.update_user
			, pt.create_ts  
			, pt.create_user
			, pt.commodity_name
		FROM #defination d
		LEFT JOIN commodity_type pt ON d.value_id = 4070
		WHERE d.value_id = 4070
		UNION ALL
		SELECT d.value_id
			, 10101080
			, ca.commodity_attribute_id
			, ca.commodity_name
			, ca.commodity_description
			, 'commodity_attribute_id' identity_col
			, ca.update_ts 
			, ca.update_user
			, ca.create_ts  
			, ca.create_user
			, ca.commodity_name
		FROM #defination d
		LEFT JOIN commodity_attribute ca ON d.value_id = 4071
		WHERE d.value_id = 4071
		UNION ALL
		SELECT d.value_id 
			, 10101051
			, sc.source_container_id
			, sc.container_name + CASE WHEN ssd.source_system_id = 2 THEN '' ELSE '.'+ ssd.source_system_name END 
			, sc.container_type AS description
			, 'source_container_id' AS identity_col
			, sc.update_ts 
			, sc.update_user
			, sc.create_ts  
			, sc.create_user
			, sc.container_name
		FROM #defination d
		LEFT JOIN source_container sc ON d.value_id = 4069
		LEFT JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
		WHERE d.value_id = 4069

		INSERT INTO #accordion_data_grid (accordion_name, application_function_id, value_id, code, description, identity_col, definition_id,update_ts,update_user,create_ts,create_user,code1)
		SELECT d.defination
			, cd.application_function_id
			, cd.value_id
			, cd.code
			, cd.description
			, cd.identity_col
			, cd.definition_id
			, cd.update_ts 
			, cd.update_user
			, cd.create_ts  
			, cd.create_user
			, cd.code1
		FROM #collect_definition cd
		INNER JOIN #defination d ON cd.definition_id = d.value_id
	END 
END

IF @flag IN ('s', 'f') 
BEGIN
	--########### Group Label
	IF EXISTS(SELECT group1, group2, group3, group4 FROM source_book_mapping_clm)
	BEGIN	
		SELECT @group1 = group1, @group2 = group2, @group3 = group3, @group4 = group4 FROM source_book_mapping_clm
	END
	ELSE
	BEGIN
		SET @group1 = 'Group1'
		SET @group2 = 'Group2'
		SET @group3 = 'Group3'
		SET @group4 = 'Group4'
	 
	END
	--######## End
	
	SET @selectStr = 'SELECT s.type_id [Type ID], 
							 value_id [Value ID], 
							CASE value_id 
								WHEN 50 THEN code + '' (' + @group1 + ')''
								WHEN 51 THEN code + '' (' + @group2 + ')'' 
								WHEN 52 THEN code + '' (' + @group3 + ')'' 
								WHEN 53 THEN code + '' (' + @group4 + ')''
								ELSE ' + CASE WHEN @flag = 'f' THEN + 'dbo.FNAToolTipText(code, description)' ELSE + 'code' END + ' 
							END AS ' + CASE WHEN @flag = 'f' THEN  '[Functions/Operators]' ELSE 'Code' END + ' , 
							description AS ' + CASE WHEN @type_id ='22000' THEN 'Module' ELSE '[Description]' END +', 
							--description Description, 
							entity_id [Entity ID], 
							s.category_id [Category ID], 
							category_name [Category Name] 
						FROM static_data_value s 
						LEFT OUTER JOIN static_data_category c ON c.category_id = s.category_id
						WHERE 1 = 1 '
	IF @type_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND	s.type_id = ' + CAST(@type_id AS NVARCHAR(500))
	
	IF @value_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND value_id = ' + CAST(@value_id AS NVARCHAR(500))
		
	IF @entity_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND entity_id IS NULL OR entity_id = ' + CAST(@entity_id AS NVARCHAR(500)) 
	ELSE
		SET @selectStr = @selectStr + ' AND entity_id IS NULL'
		
	IF  @license_not_to_static_value_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND value_id NOT IN( ' + @license_not_to_static_value_id  + ')'
		
	IF @type_id = 977
		SET @selectStr = @selectStr + ' order by value_id'
	ELSE IF @type_id = 1560
		SET @selectStr = @selectStr + ' order by s.value_id desc'
	ELSE
		SET @selectStr = @selectStr + ' order by code,c.category_name'		
		
	--PRINT(@selectStr)
	EXEC(@selectStr)
	
	SET @errorCode = @@ERROR
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'c' --List function category used in formula editor.
BEGIN
	SET @selectStr = 'SELECT sdv.value_id [Value ID], 
							 sdv.code AS ' + CASE 
												 WHEN @type_id = 27400 THEN  '[Category]'
												 ELSE 'Code' 
										   END + ',
							 sdv.type_id [Type ID]
						FROM static_data_value sdv 
						WHERE sdv.type_id = ' + CAST(@type_id AS NVARCHAR(500))
						+
						CASE WHEN @type_id = 27400 THEN ' UNION
						SELECT '''',''All'', 27400'  ELSE '' END
						+ ' Order by ' + CASE 
												 WHEN @type_id = 27400 THEN  '[Category]'
												 ELSE 'Code' 
										   END + ' ASC'
						
	EXEC(@selectStr)					
END

IF @flag = 'm' 
BEGIN
	SELECT TYPE_ID,
	       value_id,
	       code,
	       [description],
	       entity_id,
	       category_id,
	       '' category_name
	FROM   static_data_value
	WHERE  TYPE_ID = @type_id
		AND value_id NOT IN (SELECT emissions_reporting_group_id FROM   source_sink_type WHERE  generator_id = @generator_id)
	
	SET @errorCode = @@ERROR
	
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'a' 
BEGIN
	DECLARE @selectStr1 NVARCHAR(4000)
	SELECT @type_id = TYPE_ID FROM static_data_value WHERE value_id = @value_id	
	
	SET @selectStr1 = 'SELECT TYPE_ID,
	                          value_id,
	                          CASE type_id WHEN 800 THEN dbo.FNAToolTipText(code, description)  ELSE code END AS '
							  + CASE WHEN @type_id = 800 THEN  + '[Functions/Operators]' ELSE 'Code' END +
							  ' ,
	                          description DESCRIPTION,
	                          entity_id,
	                          category_id
	                   FROM   static_data_value
	                   WHERE  value_id = ' + CAST(@value_id AS NVARCHAR(500)) 
	EXEC(@selectStr1)
	
--	print(@selectStr)
	SET @errorCode = @@ERROR
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM static_data_value WHERE TYPE_ID = @type_id AND code = @code)
		BEGIN
			EXEC spa_ErrorHandler -1,
			     'Code must be unique.',
			     'spa_StaticDataValue',
			     'DB Error',
			     'Code must be unique.',
			     ''
			RETURN
		END
	
	INSERT INTO static_data_value (TYPE_ID, code, [description], entity_id, category_id)
	VALUES (@type_id, @code, @description, @entity_id, @category_id)
	
	SET @value_id = SCOPE_IDENTITY()
	
	SELECT @hourly_block = sdt.[type_name] FROM static_data_type sdt WHERE sdt.[type_id] = 10018

	IF @hourly_block = 'Hourly Block'
	BEGIN
		INSERT INTO hourly_block_sdv_audit
		(
			value_id,
			[TYPE_ID],
			code,
			[description],
			create_user,
			create_ts,
			update_user,
			update_ts,
			user_action
		)
		SELECT value_id,
		       [type_id],
		       code,
		       [description],
		       create_user,
		       create_ts,
		       update_user,
		       update_ts,
		       'insert' [user_action]
		FROM   static_data_value
		WHERE  [type_id] = @type_id
		       AND code = @code
		       AND [description] = @description
	END
		
	SET @errorCode = @@ERROR
	IF @errorCode <> 0
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Fail to insert static data value.',
		     ''
	ELSE
		EXEC spa_ErrorHandler 0,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'Success',
		     'Static data value inserted.',
		     @value_id
END
ELSE IF @flag = 'u'
BEGIN
IF EXISTS (SELECT 1 FROM static_data_value WHERE TYPE_ID = @type_id AND code = @code AND value_id <> @value_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'Code must be unique.',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Code must be unique.',
		     ''
		RETURN
	END

	UPDATE static_data_value
	SET    code = @code,
	       [description] = @description,
	       entity_id = @entity_id,
	       category_id = @category_id
	WHERE  value_id = @value_id
	
	SELECT @hourly_block = sdt.[type_name] 
	FROM static_data_value sdv 
		INNER JOIN static_data_type sdt ON sdt.[type_id] = sdv.[type_id] 
	WHERE sdv.value_id = @value_id 

	IF @hourly_block = 'Hourly Block'
	BEGIN
		INSERT INTO hourly_block_sdv_audit
		(
			value_id,
			[TYPE_ID],
			code,
			[description],
			create_user,
			create_ts,
			update_user,
			update_ts,
			user_action
		)
		SELECT value_id,
		       [type_id],
		       @code,
		       @description,
		       create_user,
		       create_ts,
			   @db_user,
			   GETDATE(),
		       'update' [user_action]
		FROM   static_data_value
		WHERE  value_id = @value_id 
	END

	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Failed to update static data value.',
		     ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'Success',
		     'Static data value updated.',
		     @value_id
		RETURN
	END
END

ELSE IF @flag = 'd'
BEGIN
	-- Added for validating values used in Rec Assignment Priority
	IF EXISTS (SELECT 1
			   FROM   rec_assignment_priority_order rapo
			   INNER JOIN rec_assignment_priority_detail rapd ON  rapo.rec_assignment_priority_detail_id = rapd.rec_assignment_priority_detail_id
			   WHERE rapo.priority_type_value_id = @value_id
	) 
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Selected data is in use and cannot be deleted.',
		     ''
		RETURN
	END
	
	--Check for system defined values for external static  data types
	IF @value_id BETWEEN 4500 AND 5000 
	BEGIN
		SELECT 'Error' [ErrorCode],
		       'StaticDataMgmt' [MODULE],
		       'spa_StaticDataValue' [Area],
		       'Success' [Status],
		       'The value you  are attempting to delete is a system defined and you are not allowed to delete it.' [MESSAGE],
		       '' [Recommendation]
	RETURN
	END
	
	--if type_id is 15600 (UDF Group), check if the value_id (UDF group instance) is used in template ("user_defined_deal_fields_template") or not.
	--if used, couldnot be deleted.
	IF @type_id = 15600 AND EXISTS ( SELECT DISTINCT 1 FROM   user_defined_deal_fields_template WHERE  udf_tabgroup = @value_id) 
	BEGIN
		DECLARE @udf_code		NVARCHAR(500),
		        @msg			NVARCHAR(700)
		
		SELECT @udf_code = code FROM static_data_value WHERE value_id = @value_id
		
		SET @msg = '''' + CAST(@udf_code AS NVARCHAR(500)) + ''' has been used in deal template and cannot be deleted.'
		
		EXEC spa_ErrorHandler -1,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Selected data is in use and cannot be deleted.',
		     ''
		RETURN
	END

	BEGIN TRY
		BEGIN TRAN

			SELECT @hourly_block = sdt.[type_name] 
			FROM static_data_value sdv 
				INNER JOIN static_data_type sdt ON sdt.[type_id] = sdv.[type_id] 
			WHERE sdv.value_id = @value_id 

			IF @hourly_block = 'Hourly Block'
			BEGIN
				INSERT INTO hourly_block_sdv_audit
				(
					value_id,
					[TYPE_ID],
					code,
					[description],
					create_user,
					create_ts,
					update_user,
					update_ts,
					user_action
				)
				SELECT value_id,
					   [type_id],
					   code,
					   [description],
					   create_user,
					   create_ts,
					   @db_user,
					   GETDATE(),
					   'delete' [user_action]
				FROM   static_data_value
				WHERE  value_id = @value_id 
			END

		--TODO: Decide what to do with calc_formula_value, DELETE or SET NULL.		
		DELETE FROM holiday_block WHERE block_value_id = @value_id
		DELETE static_data_value WHERE value_id = @value_id
		
		--EXEC spa_maintain_udf_header 'm', NULL, @value_id 

		EXEC spa_ErrorHandler 0,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'Success',
		     'Static data value deleted.',
		     ''
			
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 1
			ROLLBACK
		
		DECLARE @error_no INT
		SET @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler -1,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Selected data is in use and cannot be deleted.',
		     ''
	END CATCH

END
/**************** Added By Pawan KC ************************************/
ELSE  IF @flag = 'l'	--used for the Limit type in TRM Tracker
BEGIN
	IF EXISTS(SELECT group1, group2, group3, group4 FROM source_book_mapping_clm)
	BEGIN	
		SELECT @group1 = group1, @group2 = group2, @group3 = group3, @group4 = group4 
		FROM source_book_mapping_clm
	END
	ELSE
	BEGIN
		SET @group1 = 'Group1'
		SET @group2 = 'Group2'
		SET @group3 = 'Group3'
		SET @group4 = 'Group4'
	END
	
	SET @selectStr = 'SELECT s.type_id, value_id, 
						CASE value_id 
							WHEN 50 THEN code + '' (' + @group1 + ')''
							WHEN 51 THEN code + '' (' + @group2 + ')'' 
							WHEN 52 THEN code + '' (' + @group3 + ')'' 
							WHEN 53 THEN code + '' (' + @group4 + ')''
							ELSE code 
						END 
						AS Code , description Description, entity_id, s.category_id , category_name 
						FROM static_data_value s LEFT OUTER JOIN static_data_category c 
						ON c.category_id=s.category_id
						WHERE s.type_id = ' + CAST(@type_id AS NVARCHAR(500)) 
	
	IF @limit_type = 'p'
	    SET @selectStr = @selectStr + ' AND value_id = 1581 '
	ELSE
	    SET @selectStr = @selectStr + ' AND value_id <> 1581 '	
	
	EXEC (@selectStr)
			--print(@selectStr)
	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	    EXEC spa_ErrorHandler @errorCode,
	         'StaticDataMgmt',
	         'spa_StaticDataValue',
	         'DB Error',
	         'Select of all Static Data Values Failed.',
	         ''
END

ELSE IF @flag = 'b' -- Blotter
BEGIN
	DECLARE @group_by NVARCHAR(MAX) = ''
	--########### Group Label
	IF EXISTS(SELECT group1, group2, group3, group4 FROM source_book_mapping_clm)
	BEGIN	
		SELECT @group1 = group1, @group2 = group2, @group3 = group3, @group4 = group4 FROM source_book_mapping_clm
	END
	ELSE
	BEGIN
		SET @group1 = 'Group1'
		SET @group2 = 'Group2'
		SET @group3 = 'Group3'
		SET @group4 = 'Group4'
	END
	--######## End
	SET @selectStr = 'SELECT sdv.value_id, 
						CASE sdv.value_id 
							WHEN 50 then sdv.code + '' (' + @group1 + ')''
							WHEN 51 then sdv.code + '' (' + @group2 + ')'' 
							WHEN 52 then sdv.code + '' (' + @group3 + ')'' 
							WHEN 53 then sdv.code + '' (' + @group4 + ')''
							ELSE sdv.code 
						END 
						AS Code, --, description Description, entity_id, s.category_id, category_name 
					'
	IF @is_privilege_activated = 1  --active
	BEGIN
		SET @selectStr += ' MIN(CASE WHEN cp.is_enable = 1 THEN ''enable'' 
									ELSE   ''' + CASE WHEN @is_admin_user = 0 THEN 'disable' ELSE 'enable' END + ''' END) [state] 
						FROM  static_data_value sdv
						' + CASE WHEN @is_admin_user = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END 
						+ ' #collect_privilege cp ON cp.value_id = sdv.value_id'
		SET @group_by = ' GROUP BY sdv.value_id, sdv.code, c.category_name'
	END
	ELSE
	BEGIN
		SET @selectStr += ' ''enable'' [state] FROM static_data_value sdv'
	END

	SET @selectStr += ' LEFT OUTER JOIN static_data_category c ON c.category_id = sdv.category_id
						WHERE sdv.type_id = ' + CAST(@type_id AS NVARCHAR(500))

	IF @value_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND sdv.value_id = ' + CAST(@value_id AS NVARCHAR(500))
	IF @entity_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND sdv.entity_id IS NULL OR sdv.entity_id = ' + CAST(@entity_id AS NVARCHAR(500)) 
	ELSE
		SET @selectStr = @selectStr + ' AND sdv.entity_id IS NULL'
	IF  @license_not_to_static_value_id IS NOT NULL
		SET @selectStr = @selectStr + ' AND sdv.value_id NOT IN ( ' + @license_not_to_static_value_id  + ')'
	
	IF  @code IS NOT NULL
		SET @selectStr = @selectStr + ' AND c.category_name = ( ''' + @code  + ''')'
	
	SET @selectStr += @group_by

	IF @type_id = 977
		SET @selectStr = @selectStr + ' ORDER BY sdv.value_id'
	ELSE
		SET @selectStr = @selectStr + ' ORDER BY c.category_name, sdv.code'
	EXEC(@selectStr)
	--print(@selectStr)
	
	SET @errorCode = @@ERROR
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'o' -- Generate a comma separated list (e.g. to use in spa_html_header)
BEGIN
	DECLARE @values NVARCHAR(2000)
	
	SELECT * INTO #tmp_values FROM dbo.SplitCommaSeperatedValues(@value_ids)
	
	SELECT @values = COALESCE(@values + ', ' + sdv.code, sdv.code)
	FROM   static_data_value sdv
	INNER JOIN #tmp_values tv ON  sdv.value_id = tv.Item
	WHERE  [TYPE_ID] = @type_id
	ORDER BY code 

	SELECT @values
END

ELSE IF @flag = 'v' 
BEGIN
	SET @selectStr = 'SELECT type_id, value_id, code FROM   static_data_value WHERE type_id = ' + CAST(@type_id AS NVARCHAR) 
	
	IF @value_id <> 17351
		SET @selectStr = @selectStr + ' AND value_id = 1522'
	
	SET @selectStr = @selectStr + ' ORDER BY code'
	EXEC(@selectStr)
	
	SET @errorCode = @@ERROR
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'w' --for virtual storage
BEGIN
	SELECT [TYPE_ID], value_id, code
	FROM   static_data_value WHERE  value_id IN (980, 981, 982)
	ORDER BY code 
	
	SET @errorCode = @@ERROR
	IF @errorCode <> 0 
		EXEC spa_ErrorHandler @errorCode,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Select of all Static Data Values Failed.',
		     ''
END

ELSE IF @flag = 'r' -- html report
BEGIN
	SELECT sdv.code [Code] FROM static_data_value sdv WHERE sdv.[type_id] = @type_id
END
ELSE IF @flag = 'e' -- for grid new framework (dhtmlx)
BEGIN
	SET @selectStr = 'SELECT sdv.value_id [value_id],
	                         sdv.code [Code]
	                  FROM   static_data_value sdv
	                  WHERE sdv.[type_id] = ' + CAST(@type_id AS NVARCHAR(20))
	
	IF @value_id IS NOT NULL
		SET @selectStr += ' AND value_id = ' + CAST(@value_id AS NVARCHAR(20))
	
	IF NULLIF(@license_not_to_static_value_id, '') IS NOT NULL
		SET @selectStr += ' AND value_id NOT IN (' + CAST(@license_not_to_static_value_id AS NVARCHAR(20)) + ')'
	
	EXEC(@selectStr)
END
ELSE IF @flag = 'x' --Added to support the role based import feature.
BEGIN
	--check for app admin role 1=true
	
	DECLARE @app_admin_role_check INT
	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@db_user)
	
	SET @selectStr = '
					SELECT DISTINCT sdv.value_id,
						   sdv.[description]
					FROM   static_data_value sdv
						   LEFT JOIN static_data_category sdc
								ON  sdc.category_id = sdv.category_id
						   INNER JOIN application_functions af
								ON  af.function_desc = sdv.[description]
						   LEFT JOIN application_role_user aru
								ON  aru.user_login_id = ''' + @db_user + '''
						   LEFT JOIN application_functional_users afu
								ON  afu.function_id IN (af.function_id, 10131341, 10131300)
								AND (
										afu.role_id = aru.role_id
										OR afu.login_id = ''' + @db_user	+ '''									
										OR ' + CAST(@app_admin_role_check AS NVARCHAR(1)) + ' = 1
									)
					WHERE  afu.function_id IS NOT NULL
						   AND sdv.[type_id] =' + CAST(@type_id AS NVARCHAR(10))+ ' 
						   AND sdv.value_id NOT IN (' + ISNULL(@license_not_to_static_value_id, '''') + ')' + '
						   OR af.function_id = 10131748'
							   
	--PRINT @selectStr
	EXEC (@selectStr)
END
ELSE IF @flag = 'z'--Added to support the role based import feature.
BEGIN
	SELECT sdv.value_id, sdv.[description] FROM static_data_value sdv WHERE sdv.[type_id] = 5450 AND sdv.value_id = 5468
END
ELSE IF @flag = 'g' 
BEGIN
	--SELECT DISTINCT  
	--				adg.accordion_name type_name,	
	--				adg.code,
	--				CAST(adg.definition_id AS NVARCHAR(10)) + '' + CAST(adg.value_id AS NVARCHAR(10)) rownumber,
	--				adg.value_id,
	--				adg.description,
	--				adg.definition_id type_id, 	
	--				adg.application_function_id,
	--				aut.template_name,
	--				adg.identity_col, 
	--				ISNULL(sdad.is_active, 0) is_activated,
	--				adg.code1,
	--				adg.update_ts,
	--				adg.update_user,
	--				adg.create_ts,
	--				adg.create_user
	--			FROM #accordion_data_grid  adg
	--			LEFT JOIN application_ui_template aut ON aut.application_function_id =  adg.application_function_id
	--			LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = adg.definition_id
	--			LEFT JOIN  #collect_privilege cp ON cp.value_id = CASE WHEN ISNULL(sdad.is_active, 0) = 0 THEN cp.value_id ELSE adg.value_id END
	--				--AND cp.type_id = ISNULL(sdt.type_id, adg.definition_id)
	--			WHERE 1 = 1	
					--AND adg.accordion_name NOT IN ('Amortization Type'')
	--				--AND adg.definition_id NOT IN (1550, 1500,520,1700)
	--				--AND adg.description NOT LIKE '%-%'
	--				AND CAST(ISNULL(adg.value_id, 1) AS INT) > 0
	--				AND ISNULL(adg.accordion_name, '') = ISNULL(adg.accordion_name, '') 							 
	--				--AND  ISNULL(adg.value_id, 1) = CASE WHEN ISNULL(sdad.is_active, 0) = 0 THEN ISNULL(adg.value_id, 1) ELSE CASE WHEN 0 = 0 THEN cp.value_id  ELSE ISNULL(adg.value_id, 1)  END END  
	--				AND ((0 = 1)  OR (sdad.is_active = 1 AND cp.value_id IS NOT NULL) OR (ISNULL(sdad.is_active,0) = 0))
 --				ORDER BY adg.accordion_name, adg.code


--return

	SET @sql = '
				SELECT DISTINCT  
					adg.accordion_name type_name,	
					adg.code,
					CAST(adg.definition_id AS NVARCHAR(10)) + '''' + CAST(adg.value_id AS NVARCHAR(10)) rownumber,
					adg.value_id,
					adg.description,
					adg.definition_id type_id, 	
					adg.application_function_id,
					aut.template_name,
					adg.identity_col, 
					ISNULL(sdad.is_active, 0) is_activated,
					adg.code1,
					adg.update_ts,
					adg.update_user,
					adg.create_ts,
					adg.create_user
				FROM #accordion_data_grid  adg
				LEFT JOIN application_ui_template aut ON aut.application_function_id =  adg.application_function_id
				LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = adg.definition_id
				LEFT JOIN  #collect_privilege cp ON cp.value_id = CASE WHEN ISNULL(sdad.is_active, 0) = 0 THEN cp.value_id ELSE adg.value_id END
					--AND cp.type_id = ISNULL(sdt.type_id, adg.definition_id)
				WHERE 1 = 1	
					AND adg.definition_id NOT IN (900, 925, 10012, 19100, 23100)
					--AND adg.description NOT LIKE ''%-%''
					--AND CAST(ISNULL(adg.value_id, 1) AS INT) > 0
					AND ISNULL(adg.accordion_name, '''') = ' + ISNULL(@entity_name_filter, 'ISNULL(adg.accordion_name, '''') ') + '							 
					--AND  ISNULL(adg.value_id, 1) = CASE WHEN ISNULL(sdad.is_active, 0) = 0 THEN ISNULL(adg.value_id, 1) ELSE CASE WHEN ' + CAST(@is_admin_user AS CHAR(1))  + ' = 0 THEN cp.value_id  ELSE ISNULL(adg.value_id, 1)  END END  
					AND ((' + CAST(@is_admin_user AS CHAR(1)) + ' = 1)  OR (sdad.is_active = 1 AND cp.value_id IS NOT NULL) OR (ISNULL(sdad.is_active,0) = 0))
 				ORDER BY adg.accordion_name, adg.code
						'
	--PRINT(@sql)
	EXEC(@sql)
 
END
ELSE IF @flag = 'h'--Show data according to type ID in combo field.
BEGIN
	
	IF @is_privilege_activated = 1 --active
	BEGIN 
		SET @selectStr = 'SELECT DISTINCT adg.value_id [Value ID],  MAX(adg.code) [code] 
						, MIN(CASE WHEN cp.is_enable = 1 THEN ''enable'' 
									ELSE   ''' + CASE WHEN @is_admin_user = 0 THEN 'disable' ELSE 'enable' END + ''' END) [state] 
						FROM  #accordion_data_grid adg
						' + CASE WHEN @is_admin_user = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END 
						+ ' #collect_privilege cp ON cp.value_id = adg.value_id
						WHERE definition_id = ' + CAST(@type_id AS NVARCHAR(100)) + ' AND adg.value_id IS NOT NULL'

		IF  @license_not_to_static_value_id IS NOT NULL
			SET @selectStr += ' AND adg.value_id NOT IN( ' + @license_not_to_static_value_id  + ')'

		IF  @value_ids IS NOT NULL
			SET @selectStr += ' AND adg.value_id IN( ' + @value_ids  + ')'

		SET @selectStr += ' GROUP BY adg.value_id ' + IIF(@type_id = 23700, 'ORDER BY adg.value_id', ' ORDER BY MAX(adg.code)')
	END
	ELSE 
	BEGIN --deactive state
		SET @selectStr = '	SELECT  adg.value_id [Value ID],  adg.code [code], ''enable'' [state]
							FROM  #accordion_data_grid adg
							WHERE definition_id = ' + CAST(@type_id AS NVARCHAR(100)) + ' AND adg.value_id IS NOT NULL'
		IF  @license_not_to_static_value_id IS NOT NULL
			SET @selectStr += ' AND adg.value_id NOT IN( ' + @license_not_to_static_value_id  + ')'
		
		IF  @value_ids IS NOT NULL
			SET @selectStr += ' AND adg.value_id IN( ' + @value_ids  + ')'

		SET @selectStr +=  IIF(@type_id = 23700, ' ORDER BY adg.value_id', ' ORDER BY adg.code')
	END
	--PRINT @selectStr
	EXEC(@selectStr)
END
ELSE IF @flag = 'j'
BEGIN
	SET @selectStr = ' SELECT a.value_id, a.description, '
	SET @group_by = ''
	SET @selectStr1 = '  (SELECT sdv.value_id, sdv.[description]
						FROM static_data_value sdv
						INNER JOIN external_source_import esi ON esi.data_type_id = sdv.value_id
						WHERE sdv.[type_id] = ' + CAST(@type_id AS NVARCHAR(100)) + '
						UNION ALL
						SELECT sdv.value_id, sdv.[description]
						FROM static_data_value sdv
						WHERE sdv.[value_id] = 4054) a '

	IF @is_privilege_activated = 1  --active
	BEGIN
		SET @selectStr += ' MIN(CASE WHEN cp.is_enable = 1 THEN ''enable'' 
									ELSE   ''' + CASE WHEN @is_admin_user = 0 THEN 'disable' ELSE 'enable' END + ''' END) [state] 
						FROM  ' + @selectStr1  + CASE WHEN @is_admin_user = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END 
						+ ' #collect_privilege cp ON cp.value_id = a.value_id'
		SET @group_by = ' GROUP BY a.value_id, a.description'
	END
	ELSE
	BEGIN
		SET @selectStr += ' ''enable'' [state] FROM ' + @selectStr1
	END

	EXEC(@selectStr + @group_by)
END

ELSE IF @flag = 'q'--Show data limit to value_ids
BEGIN
	SET @selectStr = ' SELECT sdv.value_id [Value ID], sdv.[code] [code]
						FROM static_data_value sdv where sdv.value_id in (' + @value_ids + ')'
	EXEC(@selectStr)					
END

---- Show data in View Report Browser for generic static data values.
ELSE IF @flag = 'p' 
BEGIN
	SET @selectStr = 'SELECT sdv.value_id [value_id],
	                         sdv.code [Code],
							 sdv.description [Description],'
	IF @is_privilege_activated = 1  --active
	BEGIN
		SET @selectStr += '	MIN(CASE WHEN cp.is_enable = 1 THEN ''enable'' 
					ELSE   ''' + CASE WHEN @is_admin_user = 0 THEN 'disable' ELSE 'enable' END + ''' END) [state] 
				FROM  static_data_value sdv 
			' + CASE WHEN @is_admin_user = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END 
		+ ' #collect_privilege cp ON cp.value_id = sdv.value_id and cp.type_id = ' + CAST(@type_id AS NVARCHAR(20)) 
	END 
	ELSE
	BEGIN
		SET @selectStr += '''enable'' [state] FROM  static_data_value sdv'
	END

	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @selectStr += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sdv.value_id'
	END
	                
	SET @selectStr += ' WHERE sdv.[type_id] = ' + CAST(@type_id AS NVARCHAR(20))  + '' 
	
	IF @value_id IS NOT NULL
		SET @selectStr += ' AND value_id = ' + CAST(@value_id AS NVARCHAR(20))
	SET @selectStr += ' GROUP BY sdv.value_id, sdv.code, sdv.Description, sdv.entity_id'
	EXEC(@selectStr)
END


 