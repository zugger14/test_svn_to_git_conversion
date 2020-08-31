IF OBJECT_ID(N'[dbo].[spa_deal_type_pricing_maping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_type_pricing_maping]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**  
	Generic stored procedure to select deal type pricing mapping data

	Parameters
	@flag : Flag
		's' - Returns deal type id and deal type name of a deal type pricing mapping template
		't' - Returns data of deal type of a deal type pricing mapping template
		'u' - Returns enable or disable status of term type
		'v' - Returns option flag of a deal template
		'x' - Returns list of all active deal templates
		'g' - Returns 'Yes' and 'No' flag for different field for all deal type pricing mapping template
		'y' - Returns data of deal type pricing mapping template according to different filters
	@template_id : Template Id of deal type pricing mapping 
	@deal_type_id : Type Id of Deal
	@pricing_type : Pricing Type
	@call_from : Call From flag
	@commodity_id : Commodity Id
	@term_type : Term Type
	@mapping_id : Mapping Id
	@filter_name : Filter Name

*/


CREATE PROCEDURE [dbo].[spa_deal_type_pricing_maping]
    @flag NCHAR(1),
    @template_id INT = NULL,
    @deal_type_id INT = NULL,
    @pricing_type INT = NULL,
    @call_from NCHAR(1) = 'f',
	@commodity_id INT = NULL,
	@term_type NCHAR(1) = NULL,
	@mapping_id NVARCHAR(20) = NULL,
	@filter_name NVARCHAR(20) = NULL
AS
SET NOCOUNT ON

DECLARE @SQL NVARCHAR(MAX)

IF @flag = 's'
BEGIN
    SELECT DISTINCT sdt.source_deal_type_id, sdt.source_deal_type_name
    FROM deal_type_pricing_maping dtpm
    INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = dtpm.source_deal_type_id
    WHERE dtpm.template_id = @template_id
END

IF @flag = 't'
BEGIN	
    SELECT DISTINCT sdv.value_id, sdv.code
    FROM deal_type_pricing_maping dtpm
    INNER JOIN static_data_value sdv ON sdv.value_id = dtpm.pricing_type
    WHERE dtpm.template_id = @template_id AND dtpm.source_deal_type_id = @deal_type_id
END

IF @flag = 'u'
BEGIN	
	IF @call_from = 'b'
	BEGIN
		SELECT @deal_type_id = sdht.source_deal_type_id
		FROM source_deal_header_template sdht WHERE sdht.template_id = @template_id
	END
	DECLARE @enable_term_type NCHAR(1)
	
    SELECT @enable_term_type = CASE WHEN ISNULL(dtpm.enable_term_type, 0) = 0 THEN 'n' ELSE 'y' END
    FROM deal_type_pricing_maping dtpm
    WHERE dtpm.template_id = @template_id AND dtpm.source_deal_type_id = @deal_type_id 
    AND (@pricing_type IS NULL OR ISNULL(dtpm.pricing_type, -1) = ISNULL(@pricing_type, -1))
    
    SELECT ISNULL(@enable_term_type, 'n') [enable_term_type]
END

IF @flag = 'v'
BEGIN
	SELECT ISNULL(sdht.option_flag, 'n') [is_options]
	FROM source_deal_header_template sdht 
	WHERE sdht.template_id = @template_id
END

IF @flag = 'x'
BEGIN
	SELECT template_id,template_name FROM source_deal_header_template WHERE ISNULL(is_active, 'n') = 'y'
END

IF @flag = 'p'
BEGIN
	EXEC spa_source_deal_type_maintain 'x'
END

IF @flag = 'r'
BEGIN
	SELECT value_id,code FROM static_data_value AS sdv WHERE sdv.[type_id] = 46700
END

IF @flag = 'g'
BEGIN
	SELECT  
		dtpm.deal_type_pricing_maping_id,
		sdht.template_name,
		sc.commodity_name,
		sdt.source_deal_type_name,
		sdv.code,
		CASE WHEN fixed_price  = 1 THEN 'Yes' ELSE 'No' END AS fixed_price,
		CASE WHEN dtpm.curve_id = 1 THEN 'Yes' ELSE 'No' END AS curve_id,
		CASE WHEN dtpm.price_adder = 1 THEN 'Yes' ELSE 'No' END AS price_adder,
		CASE WHEN dtpm.formula_id = 1 THEN 'Yes' ELSE 'No' END AS formula_id,
		CASE WHEN dtpm.multiplier = 1 THEN 'Yes' ELSE 'No' END AS multiplier,
		CASE WHEN dtpm.pricing_start = 1 THEN 'Yes' ELSE 'No' END AS pricing_start,
		CASE WHEN dtpm.pricing_end = 1 THEN 'Yes' ELSE 'No' END AS pricing_end,
		CASE WHEN dtpm.detail_pricing = 1 THEN 'Yes' ELSE 'No' END AS detail_pricing,
		CASE WHEN dtpm.pricing_tab = 1 THEN 'Yes' ELSE 'No' END AS pricing_tab,
		CASE WHEN dtpm.formula_curve_id = 1 THEN 'Yes' ELSE 'No' END  AS formula_curve_id,
		CASE WHEN dtpm.enable_term_type = 1 THEN 'Yes' ELSE 'No' END  AS enable_term_type,
		CASE WHEN dtpm.location_id = 1 THEN 'Yes' ELSE 'No' END AS location_id,
		CASE WHEN dtpm.price_multiplier = 1 THEN 'Yes' ELSE 'No' END AS price_multiplier,
		CASE WHEN dtpm.enable_efp = 1 THEN 'Yes' ELSE 'No' END AS enable_efp,
		CASE WHEN dtpm.enable_trigger = 1 THEN 'Yes' ELSE 'No' END AS enable_trigger
	
		FROM deal_type_pricing_maping AS dtpm
			LEFT JOIN source_deal_header_template sdht ON sdht.template_id = dtpm.template_id
			LEFT JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = dtpm.source_deal_type_id
			LEFT JOIN static_data_value AS sdv ON sdv.value_id = dtpm.pricing_type 
			LEFT JOIN source_commodity AS sc ON sc.source_commodity_id = dtpm.commodity_id
			ORDER BY sdht.template_name
END

-- EXEC spa_deal_type_pricing_maping 'y', @template_id=1577, @deal_type_id = 1171
IF @flag = 'y'
BEGIN
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
	DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 0)

	IF @term_type IS NULL
		SET @term_type = 'd'

	SET @sql = '
		SELECT DISTINCT
			CAST([dtpm].[deal_type_pricing_maping_id] AS NVARCHAR(10)) + ISNULL(''_'' + tt.[id], '''') [deal_type_pricing_maping_id],
			[dtpm].[template_id],
			[dtpm].[source_deal_type_id],
			[dtpm].[commodity_id],
			[dtpm].[pricing_type] [pricing_type_id],
			tt.[id] [term_type_id],
			[sdht].[template_name],
			[sdt].[source_deal_type_name],
			[sc].[commodity_name],
			[sdv].[code] AS [pricing_type],
			tt.[name] [term_type]
		FROM deal_type_pricing_maping dtpm
		INNER JOIN source_deal_header_template sdht ON dtpm.template_id = sdht.template_id
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = dtpm.source_deal_type_id		
		LEFT JOIN source_commodity sc ON dtpm.commodity_id = sc.source_commodity_id		
		LEFT JOIN static_data_value sdv ON dtpm.pricing_type = sdv.value_id
		OUTER APPLY (
			SELECT [id], [name]
			FROM (
				SELECT ''d'' [id], ''Spot'' [name]
				UNION 
				SELECT ''m'', ''Term''
			) a 
			WHERE [dtpm].[enable_term_type] = 1
		) tt
		'
	IF @is_admin = 0
	BEGIN
		SET @sql += '
					INNER JOIN template_mapping tm
						ON tm.template_id = sdht.template_id 
						AND tm.deal_type_id = sdt.source_deal_type_id 
						AND ISNULL(tm.commodity_id, -1) = ISNULL(sc.source_commodity_id, -1) 
					LEFT JOIN template_mapping_privilege tmp 
						ON tmp.template_mapping_id = tm.template_mapping_id
						AND (tmp.[user_id] = ''' + @user_name + ''' OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_name + ''') fur))
					WHERE  1 = 1 AND sdht.is_active = ''y''
					AND tmp.template_mapping_privilege_id IS NOT NULL	
				'
	END
	ELSE
	BEGIN
		SET @sql += ' WHERE  1 = 1 AND sdht.is_active = ''y'''
	END
	
	SET @sql += ' AND ISNULL(sdht.blotter_supported, ''n'') = ''n'''

	IF @template_id IS NOT NULL
		SET @sql += ' AND [dtpm].[template_id] = ' + CAST(@template_id AS NVARCHAR(20)) 

	IF @deal_type_id IS NOT NULL
		SET @sql += ' AND [dtpm].[source_deal_type_id] = ' + CAST(@deal_type_id AS NVARCHAR(20))

	IF @commodity_id IS NOT NULL
		SET @sql += ' AND [dtpm].[commodity_id] = ' + CAST(@commodity_id AS NVARCHAR(20))

	IF @pricing_type IS NOT NULL
		SET @sql += ' AND [dtpm].[pricing_type] = ' + CAST(@pricing_type AS NVARCHAR(20))
	
	SET @sql += ' ORDER BY [sdht].[template_name], [sdt].[source_deal_type_name], [sc].[commodity_name], [sdv].[code]'
	--PRINT(@sql)
	EXEC(@sql)
END