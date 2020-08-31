IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_getDealTemplate]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_getDealTemplate]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_getDealTemplate]
	@flag CHAR(1),
	@source_deal_type_id INT = NULL,
	@deal_sub_type_type_id INT = NULL,
	@template_id INT = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@process_id VARCHAR(100) = NULL,
	@strategy_id INT = NULL,
	@internal_deal_type_value_id INT = NULL,
	@is_blotter CHAR(1) = NULL
AS

SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(5000)
DECLARE @db_user VARCHAR(MAX)
SET @db_user = dbo.FNADBUser()
DECLARE @check_admin_role INT
SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)

IF @flag = 's'
BEGIN
	SET @sql_stmt = '
		SELECT DISTINCT sdht.template_id AS TemplateID,
			sdht.template_name ' + CASE WHEN @strategy_id IS NOT NULL THEN ' + CASE WHEN ssd.source_system_id = 2 THEN ''''ELSE ''.'' + ssd.source_system_name END ' ELSE '' END + ' AS TemplateName
		FROM source_deal_header_template sdht
		LEFT OUTER JOIN source_deal_type sdt ON sdht.source_deal_type_id = sdt.source_deal_type_id ' +
		CASE
			WHEN @strategy_id IS NOT NULL THEN '
			LEFT JOIN fas_strategy fs ON  fs.source_system_id = sdt.source_system_id
			LEFT JOIN source_system_description ssd ON  ssd.source_system_id = fs.source_system_id '
			ELSE ''
		END

	IF @check_admin_role <> 1 -- does not have admin role
	BEGIN
		SET @sql_stmt = @sql_stmt + '
			INNER JOIN template_mapping tm ON tm.template_id = sdht.template_id
			LEFT JOIN template_mapping_privilege tmp ON tmp.template_mapping_id = tm.template_mapping_id
				AND (tmp.[user_id] = ''' + @db_user + ''' OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @db_user + ''') fur))
			WHERE  1 = 1 AND sdht.is_active = ''y''
				AND tmp.template_mapping_privilege_id IS NOT NULL
		'
	END
	ELSE
	BEGIN
		SET @sql_stmt = @sql_stmt + '
			WHERE 1 = 1 AND sdht.is_active = ''y''
		'
	END
	
    IF @source_deal_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.source_deal_type_id = ' + CAST(@source_deal_type_id AS VARCHAR(20))  
    
    IF @deal_sub_type_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.deal_sub_type_type_id = ' + CAST(@deal_sub_type_type_id AS VARCHAR(20))  
    
    IF @strategy_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND fs.fas_strategy_id = ' + CAST(@strategy_id AS VARCHAR(20))   
    
	IF @internal_deal_type_value_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.internal_deal_type_value_id= ' + CAST(@internal_deal_type_value_id AS VARCHAR(20))
    	
    IF @is_blotter IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND ISNULL(sdht.blotter_supported, ''n'') = ''' + @is_blotter + ''''

	IF @template_id IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND sdht.template_id = ''' + CAST(@template_id AS VARCHAR(50)) + ''''
    
	SET @sql_stmt = @sql_stmt + ' ORDER BY TemplateName'
    
    EXEC (@sql_stmt)
END

ELSE IF @flag = 't' -- select template data to show in hyperlinked form
BEGIN
	SELECT sdht.template_id, sdht.template_name, field_template_id, source_deal_type_id, deal_sub_type_type_id
		FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
END

ELSE IF @flag = 'a'
BEGIN
    DECLARE @tempdetailtable  VARCHAR(150),
            @user_login_id    VARCHAR(50)
    
    SET @user_login_id = dbo.FNADBUser()  
    SET @tempdetailtable = dbo.FNAProcessTableName('source_deal_detail_temp', @user_login_id, @process_id)  
    
    SET @sql_stmt = 
        'SELECT dbo.FNADateFormat(term_start) TermStart,
			   dbo.FNADateFormat(term_end) TermEnd,
			   Leg,
			   CASE WHEN buy_sell_flag = ''b'' THEN ''Buy(RECEIVE)'' ELSE ''Sell(Pay)'' END BuySell,
			   curve_id [Index],
			   deal_volume Volume,
			   deal_volume_frequency Frequency,
			   deal_volume_uom_id UOM,
			   fixed_price Price,
			   fixed_price_currency_id Currency,
			   option_strike_price [Opt.StrikePrice],
			   formula_id Formula
		FROM ' + @tempdetailtable  
    
    EXEC (@sql_stmt) 
         
         --select * from adiha_process.dbo.source_deal_detail_temp_farrms_admin_64B41233_94B5_4E5F_AB23_7E67CE0F253F
END
ELSE 
IF @flag = 'l'
BEGIN
    SET @sql_stmt = 
				'SELECT a.template_id,
				   a.template_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END AS TemplateName,
				   sdt1.source_system_id,a.header_buy_sell_flag,
				   b.deal_volume_frequency,b.deal_volume_uom_id,b.currency_id,b.fixed_float_leg,b.curve_id,b.physical_financial_flag,
				   b.location_id,option_flag,term_frequency_type,option_type,option_exercise_type,a.internal_deal_subtype_value_id,
				   a.source_deal_type_id,
				   sdt1.source_deal_type_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END,
				   a.deal_sub_type_type_id,
				   sdt2.source_deal_type_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END,
				   sdt1.disable_gui_groups,b.commodity_id,a.deal_category_value_id,dv.code,a.block_type,a.block_define_id,
				   a.granularity_id,a.Pricing,
				   dv1.code,dv2.code,dv3.code,dv4.code,
				   b.formula,b.pay_opposite,
				   CASE WHEN source_Major_Location.location_name IS NULL THEN '''' ELSE source_Major_Location.location_name + '' - > '' END + l.Location_Name,
				   i.curve_name,
				   a.counterparty_id,
				   sc.counterparty_name,
				   a.contract_id,
				   cg.contract_name,
				   a.deal_rules,
				   a.confirm_rule				   
			FROM   source_deal_header_template a
				   LEFT OUTER JOIN source_deal_detail_template b ON  b.template_id = a.template_id
				   LEFT OUTER JOIN source_deal_type sdt1 ON  a.source_deal_type_id = sdt1.source_deal_type_id
				   LEFT OUTER JOIN source_deal_type sdt2 ON  a.deal_sub_type_type_id = sdt2.source_deal_type_id
				   LEFT JOIN source_system_description ssd ON  ssd.source_system_id = sdt1.source_system_id
				   LEFT OUTER JOIN static_data_value dv ON  dv.value_id = a.deal_category_value_id
				   LEFT OUTER JOIN static_data_value dv1 ON  dv1.value_id = a.block_type
				   LEFT OUTER JOIN static_data_value dv2 ON  dv2.value_id = a.block_define_id
				   LEFT OUTER JOIN static_data_value dv3 ON  dv3.value_id = a.granularity_id
				   LEFT OUTER JOIN static_data_value dv4 ON  dv4.value_id = a.pricing 
				 --LEFT OUTER JOIN source_deal_detail_template c ON c.template_id =a.template_id
				   LEFT OUTER JOIN source_minor_location l ON  l.source_minor_location_id = b.location_id
				   LEFT OUTER JOIN source_price_curve_def i ON  i.source_curve_def_id = b.curve_id
				   LEFT JOIN source_Major_Location ON  l.source_Major_Location_Id = source_Major_Location.source_major_location_ID
				   LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = a.counterparty_id
				   LEFT JOIN contract_group cg ON cg.contract_id = a.contract_id
			WHERE  1 = 1 '  
    
    IF @source_deal_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' and a.source_deal_type_id=' + CAST(@source_deal_type_id AS VARCHAR(20))
    
    IF @deal_sub_type_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' and a.deal_sub_type_type_id=' + CAST(@deal_sub_type_type_id AS VARCHAR(20))
    
    IF @template_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' and a.template_id=' + CAST(@template_id AS VARCHAR(20))  
    
    SET @sql_stmt = @sql_stmt + ' order by a.internal_flag asc ' 
    
    EXEC (@sql_stmt)
END
ELSE 
IF @flag = 'e' -- templatecombochanged in Environmental Transaction
BEGIN
    SET @sql_stmt = 
        'SELECT   
			MAX(term_frequency_type) AS term_frequency_type,  
			MAX(term_end_flag) AS term_end_flag,  
			MAX(allow_edit_term) AS allow_edit_term,   
			MAX(deal_volume_uom_id) AS deal_volume_uom_id 
			FROM   
			source_deal_header_template a   
			LEFT JOIN source_deal_detail_template b ON a.template_id=b.template_id  
			WHERE 1=1 '
    
    IF @template_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' and a.template_id=' + CAST(@template_id AS VARCHAR(20)) 
    
    --PRINT @sql_stmt  
    EXEC (@sql_stmt)
END
ELSE 
IF @flag = 'p'
BEGIN
    SELECT template_id,
           internal_deal_subtype_value_id
    FROM   source_deal_header_template
    WHERE  template_id = @template_id
END
	
IF @flag = 'b' --for blotter support
BEGIN
    SET @sql_stmt = 
        'SELECT DISTINCT  
					  sdht.template_id AS TemplateID  
					  , sdht.template_name+ case when ssd.source_system_id=2 then '''' else ''.''+ssd.source_system_name END AS TemplateName  
					  , sdt.source_system_id AS source_system_id  
					  , sdht.header_buy_sell_flag  
					  , sdht.option_flag  
					  , sdht.term_frequency_type  
					  , sdht.option_type  
					  , sdht.option_exercise_type        
					  , sdht.internal_deal_subtype_value_id  
					 FROM source_deal_header_template sdht   
					 LEFT OUTER JOIN source_deal_type sdt ON sdht.source_deal_type_id = sdt.source_deal_type_id  
					 LEFT JOIN fas_strategy fs ON fs.source_system_id = sdt.source_system_id 
					 LEFT JOIN source_system_description ssd ON ssd.source_system_id = fs.source_system_id   
					 WHERE sdht.blotter_supported=''y''AND sdht.is_active=''y'''  
    
    IF @source_deal_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.source_deal_type_id = ' + 
            CAST(@source_deal_type_id AS VARCHAR(20))  
    
    IF @deal_sub_type_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.deal_sub_type_type_id = ' + 
            CAST(@deal_sub_type_type_id AS VARCHAR(20))  
    
    IF @strategy_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND fs.fas_strategy_id = ' + CAST(@strategy_id AS VARCHAR(20))   
    
    SET @sql_stmt = @sql_stmt + ' ORDER BY TemplateName' 
    
    --PRINT (@sql_stmt)  
    EXEC (@sql_stmt)
END
	
IF @flag = 'q' -- all active templates
BEGIN
	SELECT DISTINCT 
		   sdht.template_id AS TemplateID,
		   sdht.template_name AS TemplateName,
		   sdt.source_system_id AS source_system_id,
		   sdht.header_buy_sell_flag,
		   sdht.option_flag,
		   sdht.term_frequency_type,
		   sdht.option_type,
		   sdht.option_exercise_type,
		   sdht.internal_deal_subtype_value_id
	FROM   source_deal_header_template sdht
		   LEFT OUTER JOIN source_deal_type sdt
				ON  sdht.source_deal_type_id = sdt.source_deal_type_id
		   LEFT JOIN fas_strategy fs
				ON  fs.source_system_id = sdt.source_system_id
		   LEFT JOIN source_system_description ssd
				ON  ssd.source_system_id = fs.source_system_id
	WHERE  1 = 1 
		   AND sdht.template_name IS NOT NULL
		   AND sdht.is_active = 'y'
	ORDER BY
		   TemplateName
END

IF @flag = 'c' -- for combobox
BEGIN
	SELECT DISTINCT 
		   sdht.template_id AS TemplateID,
		   sdht.template_name AS TemplateName
	FROM   source_deal_header_template sdht
	ORDER BY
		   TemplateName ASC
END
ELSE IF @flag = 'z'--check if user has right for the template
BEGIN
	SET @sql_stmt = '
					SELECT sdht.template_id AS TemplateID,
						   sdht.template_name ' + CASE WHEN @strategy_id IS NOT NULL THEN ' + CASE WHEN ssd.source_system_id = 2 THEN ''''ELSE ''.'' + ssd.source_system_name END ' ELSE '' END + ' AS TemplateName,
						   sdt.source_system_id AS source_system_id,
						   sdht.header_buy_sell_flag,
						   sdht.option_flag,
						   sdht.term_frequency_type,
						   sdht.option_type,
						   sdht.option_exercise_type,
						   sdht.internal_deal_subtype_value_id 
					FROM source_deal_header_template sdht
					LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id '
					+ CASE 
					       WHEN @strategy_id IS NOT NULL THEN 
					            '	LEFT JOIN fas_strategy fs ON  fs.source_system_id = sdt.source_system_id
									LEFT JOIN source_system_description ssd ON  ssd.source_system_id = fs.source_system_id '
					       ELSE ''
					  END
					  +		'
					LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id
					WHERE  1 = 1 AND sdht.is_active = ''y'' AND sdht.template_id = ' + CAST(@template_id AS VARCHAR(100))
					
    IF @source_deal_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.source_deal_type_id = ' + CAST(@source_deal_type_id AS VARCHAR(20))  
    
    IF @deal_sub_type_type_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.deal_sub_type_type_id = ' + CAST(@deal_sub_type_type_id AS VARCHAR(20))  
    
    IF @strategy_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND fs.fas_strategy_id = ' + CAST(@strategy_id AS VARCHAR(20))   
    
	IF @internal_deal_type_value_id IS NOT NULL
        SET @sql_stmt = @sql_stmt + ' AND sdht.internal_deal_type_value_id= ' + CAST(@internal_deal_type_value_id AS VARCHAR(20))
    	
	IF @check_admin_role <> 1 -- does not have admin role
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND (sdp.user_id = dbo.FNADBUser() OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(dbo.FNADBUser())) OR sdht.create_user = dbo.FNADBUser())'
	END
    
    SET @sql_stmt = @sql_stmt + ' ORDER BY TemplateName' 
    
    --PRINT @sql_stmt  
    EXEC (@sql_stmt)
END
ELSE IF @flag = 'x'
BEGIN
	SELECT	sdht.template_id AS TemplateID,
			sdht.template_name ,
			sdt.source_system_id AS source_system_id,
			sdht.header_buy_sell_flag,
			sdht.option_flag,
			sdht.term_frequency_type,
			sdht.option_type,
			sdht.option_exercise_type,
			sdht.internal_deal_subtype_value_id 
	FROM source_deal_header_template sdht
	LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id
END

GO