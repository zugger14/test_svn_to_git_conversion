/****** Object:  StoredProcedure [dbo].[spa_netting_groups]    Script Date: 03/29/2009 17:36:22 ******/
IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_netting_groups]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_netting_groups]
GO



/****** Object:  StoredProcedure [dbo].[spa_netting_groups]    Script Date: 03/29/2009 17:36:31 ******/

-- EXEC spa_netting_groups 's', 10 
--This procedure returns all netting groups
CREATE PROC [dbo].[spa_netting_groups] 	
					@flag CHAR, -- 'c' called from counterparty screen, 's' to show in grid, 'a', for update screen, 'i' insert, 'u' update,'d'-delete
					@netting_parent_group_id INT = NULL,
					@netting_group_id INT = NULL,
					@netting_group_name VARCHAR(100) = NULL,
					@effective_date VARCHAR(20) = NULL,
					@end_date VARCHAR(20) = NULL,
					@sub_entity_id INT = NULL,
					@strategy_entity_id INT = NULL,
					@book_entity_id INT = NULL,
					@source_commodity_id INT = NULL,
					@physical_financial_flag VARCHAR(1) = NULL,
					@source_deal_type_id INT = NULL,
					@source_deal_sub_type_id INT = NULL,
					@hedge_type_value_id INT = NULL,
					@gl_id_gross_revenue INT = NULL,
					@gl_id_net_revenue INT = NULL,
					@gl_id_gross_expense INT = NULL,
					@gain_loss_flag VARCHAR(1) = 'n',
					@source_system_id INT = NULL,
					@legal_entity INT = NULL,
					@counterparty_id INT = NULL,
					@contract_ids VARCHAR(2000) = NULL ,
					@del_net_grp_id VARCHAR(1000) = NULL
AS 

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

SET CONCAT_NULL_YIELDS_NULL ON

SET NOCOUNT ON


DECLARE @sql_select VARCHAR(8000)
DECLARE @new_id INT
IF @flag = 's'
BEGIN
    SET @sql_select = 
        'SELECT 
				netting_group.netting_group_name AS [Group Name]
				,dbo.FNADateFormat(netting_group.effective_date) AS [Effective Date]
				,dbo.FNADateFormat(netting_group.end_date) AS [End Date]
				,sle.legal_entity_name + CASE WHEN ssd.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd.source_system_name END [Legal Entity]				 
				,source_commodity.commodity_name + CASE WHEN ssd1.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd1.source_system_name END AS [Commodity]
				,CASE netting_group.physical_financial_flag WHEN ''p'' THEN ''Physical'' when ''a'' then ''All''  when ''n'' then ''None''  ELSE ''Financial'' END AS [Financial]
				,hedge_type.code As [Hedge Type]
				,DealType.source_deal_type_name + CASE WHEN ssd2.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd2.source_system_name END AS [Deal Type]
				,DealSubType.source_deal_type_name + CASE WHEN ssd2.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd2.source_system_name END AS [Deal Sub Type]
				,netting_group.netting_group_id AS [Net Grp ID]
				,netting_group.netting_parent_group_id AS [Net Prt Grp ID]
				,gl_gross.gl_account_number + '' ('' + gl_gross.gl_account_name + '')'' AS [GL Gross]
				,gl_net.gl_account_number + '' ('' + gl_net.gl_account_name + '')'' AS [GL Net] 
				,gl_expense.gl_account_number + '' ('' + gl_expense.gl_account_name + '')'' AS [GL Expense]
			FROM netting_group 
				LEFT OUTER JOIN netting_group_detail ngd ON netting_group.netting_group_id = ngd.netting_group_id
				LEFT OUTER JOIN portfolio_hierarchy Sub ON netting_group.sub_entity_id = Sub.entity_id 
				LEFT OUTER JOIN portfolio_hierarchy Strategy ON netting_group.strategy_entity_id = Strategy.entity_id 
				LEFT OUTER JOIN portfolio_hierarchy Book ON netting_group.book_entity_id = Book.entity_id 
				LEFT OUTER JOIN source_commodity ON netting_group.source_commodity_id = source_commodity.source_commodity_id 
				LEFT OUTER JOIN source_deal_type DealType ON netting_group.source_deal_type_id = DealType.source_deal_type_id 
				LEFT OUTER JOIN source_deal_type DealSubType ON netting_group.source_deal_sub_type_id = DealSubType.source_deal_type_id 
				LEFT OUTER JOIN static_data_value hedge_type ON hedge_type.value_id = netting_group.hedge_type_value_id 
				LEFT OUTER JOIN	gl_system_mapping gl_gross on gl_gross.gl_number_id=netting_group.gl_id_gross_revenue 
				LEFT OUTER JOIN gl_system_mapping gl_net on gl_net.gl_number_id=netting_group.gl_id_net_revenue 
				LEFT OUTER JOIN	gl_system_mapping gl_expense on gl_expense.gl_number_id=netting_group.gl_id_gross_expense 
				LEFT JOIN netting_group_parent ngp on ngp.netting_parent_group_id=netting_group.netting_parent_group_id  
				LEFT JOIN source_legal_entity sle on sle.source_legal_entity_id=ngp.legal_entity
				LEFT OUTER JOIN source_system_description  ssd ON ssd.source_system_id = sle.source_system_id
				LEFT OUTER JOIN source_system_description  ssd1 ON ssd1.source_system_id = source_commodity.source_system_id
				LEFT OUTER JOIN source_system_description  ssd2 ON ssd2.source_system_id = DealType.source_system_id
				LEFT OUTER JOIN source_system_description  ssd3 ON ssd3.source_system_id = DealSubType.source_system_id
			WHERE netting_group.netting_parent_group_id = ' + (CAST(ISNULL(@netting_parent_group_id, '') AS VARCHAR))
    
    IF @counterparty_id IS NOT NULL
        SET @sql_select = @sql_select + ' AND ngd.source_counterparty_id = ''' + 
            CAST(@counterparty_id AS VARCHAR(100)) + ''''
    
    IF @gain_loss_flag IS NULL
       OR @gain_loss_flag = 'n'
        SET @sql_select = @sql_select + 
            ' and (gain_loss_flag is null or gain_loss_flag=''n'')'
    ELSE
        SET @sql_select = @sql_select + ' and gain_loss_flag=''' + @gain_loss_flag
            + '''' 
    
    exec spa_print @sql_select
    EXEC (@sql_select)
END
ELSE 
IF @flag = 'a'
BEGIN
    SELECT netting_group.netting_group_name AS GroupName,
           dbo.FNADateFormat(netting_group.effective_date) AS EffectiveDate,
           dbo.FNADateFormat(netting_group.end_date) AS EndDate,
           Sub.entity_name       AS Subsidiary,
           Strategy.entity_name  AS Strategy,
           Book.entity_name      AS Book,
           source_commodity.commodity_name AS Commodity,
           netting_group.physical_financial_flag,
           hedge_type.code       AS HedgeType,
           DealType.source_deal_type_name AS DealType,
           DealSubType.source_deal_type_name AS DealSubType,
           netting_group.netting_group_id AS NetGrpId,
           netting_group.netting_parent_group_id AS NetPrtGrpId,
           gl_gross.gl_account_number + ' (' + gl_gross.gl_account_name + ')' AS 
           GLGross,
           gl_net.gl_account_number + ' (' + gl_net.gl_account_name + ')' AS 
           GLNet,
           gl_expense.gl_account_number + ' (' + gl_expense.gl_account_name + 
           ')' AS                   GLExpense,
           netting_group.gl_id_gross_revenue,
           netting_group.gl_id_net_revenue,
           netting_group.gl_id_gross_expense,
           source_system_description.source_system_name,
           netting_group.sub_entity_id,
           netting_group.strategy_entity_id,
           netting_group.source_system_id,
           netting_group.source_commodity_id,
           netting_group.source_deal_type_id,
           netting_group.source_deal_sub_type_id,
           legal_entity
    FROM   netting_group
           LEFT OUTER JOIN portfolio_hierarchy Sub
                ON  netting_group.sub_entity_id = Sub.entity_id
           LEFT OUTER JOIN portfolio_hierarchy Strategy
                ON  netting_group.strategy_entity_id = Strategy.entity_id
           LEFT OUTER JOIN portfolio_hierarchy Book
                ON  netting_group.book_entity_id = Book.entity_id
           LEFT OUTER JOIN source_commodity
                ON  netting_group.source_commodity_id = source_commodity.source_commodity_id
           LEFT OUTER JOIN source_deal_type DealType
                ON  netting_group.source_deal_type_id = DealType.source_deal_type_id
           LEFT OUTER JOIN source_deal_type DealSubType
                ON  netting_group.source_deal_sub_type_id = DealSubType.source_deal_type_id
           LEFT OUTER JOIN static_data_value hedge_type
                ON  hedge_type.value_id = netting_group.hedge_type_value_id
           LEFT OUTER JOIN gl_system_mapping gl_gross
                ON  gl_gross.gl_number_id = netting_group.gl_id_gross_revenue
           LEFT OUTER JOIN gl_system_mapping gl_net
                ON  gl_net.gl_number_id = netting_group.gl_id_net_revenue
           LEFT OUTER JOIN gl_system_mapping gl_expense
                ON  gl_expense.gl_number_id = netting_group.gl_id_gross_expense
           LEFT OUTER JOIN source_system_description
                ON  netting_group.source_system_id = source_system_description.source_system_id
    WHERE  netting_group.netting_group_id = @netting_group_id
END
ELSE 
IF @flag = 'i'
BEGIN
    INSERT INTO netting_group (
		netting_parent_group_id,
		netting_group_name,
		effective_date,
		end_date,
		sub_entity_id,
		strategy_entity_id,
		book_entity_id,
		source_commodity_id,
		physical_financial_flag,
		source_deal_type_id,
		source_deal_sub_type_id,
		hedge_type_value_id,
		gl_id_gross_revenue,
		gl_id_net_revenue,
		gl_id_gross_expense,
		gain_loss_flag,
		source_system_id,
		create_user,
		create_ts,
		update_user,
		update_ts,
		legal_entity
	)
    VALUES
      (
        @netting_parent_group_id,
        @netting_group_name,
        @effective_date,
        @end_date,
        @sub_entity_id,
        @strategy_entity_id,
        @book_entity_id,
        @source_commodity_id,
        @physical_financial_flag,
        @source_deal_type_id,
        @source_deal_sub_type_id,
        @hedge_type_value_id,
        @gl_id_gross_revenue,
        @gl_id_net_revenue,
        @gl_id_gross_expense,
        @gain_loss_flag,
        @source_system_id,
        NULL,
        NULL,
        NULL,
        NULL,
        @legal_entity
      ) 
    
    SET @new_id = SCOPE_IDENTITY()
    



	
    -- if counterparty_id is passed then insert in the netting_group_detail for that counterparty.
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Netting Group',
             'spa_netting_parent_groups',
             'DB Error',
             'Failed to Insert Netting Group.',
             ''
    ELSE
    BEGIN
        IF @counterparty_id IS NOT NULL
        BEGIN
            INSERT INTO netting_group_detail
              (
                netting_group_id,
                source_counterparty_id
              )
            SELECT @new_id,
                   @counterparty_id
        END
        
		IF @contract_ids IS NOT NULL
		BEGIN
			INSERT INTO netting_group_detail_contract (			    
			    netting_group_detail_id,
			    source_contract_id
			  )
			SELECT @new_id,
			       item
			FROM   dbo.SplitCommaSeperatedValues(@contract_ids) scsv
		END
        
		DECLARE @recommend_netting_group_id VARCHAR(20)
		SELECT @recommend_netting_group_id = CAST(@netting_parent_group_id AS VARCHAR(10)) + '_' + CAST(@new_id AS VARCHAR(10)) + '_0'

		EXEC spa_ErrorHandler 0,
             'Netting Group',
             'spa_netting_parent_groups',
             'Success',
             'Changes have been saved successfully.',
             @recommend_netting_group_id
    END
END
ELSE 
IF @flag = 'u'
BEGIN
    UPDATE netting_group
    SET    netting_group_name = @netting_group_name,
           effective_date = @effective_date,
           end_date = @end_date,
           sub_entity_id = @sub_entity_id,
           strategy_entity_id = @strategy_entity_id,
           book_entity_id = @book_entity_id,
           source_commodity_id = @source_commodity_id,
           physical_financial_flag = @physical_financial_flag,
           source_deal_type_id = @source_deal_type_id,
           source_deal_sub_type_id = @source_deal_sub_type_id,
           hedge_type_value_id = @hedge_type_value_id,
           gl_id_gross_revenue = @gl_id_gross_revenue,
           gl_id_net_revenue = @gl_id_net_revenue,
           gl_id_gross_expense = @gl_id_gross_expense,
           gain_loss_flag = @gain_loss_flag,
           source_system_id = @source_system_id,
           legal_entity = @legal_entity
    WHERE  netting_group_id = @netting_group_id
    
    
    IF @contract_ids IS NOT NULL
    BEGIN
        INSERT INTO netting_group_detail_contract (
           netting_group_detail_id,
			source_contract_id
          )
        SELECT @netting_group_id,
               item
        FROM   dbo.SplitCommaSeperatedValues(@contract_ids) scsv
               LEFT JOIN netting_group_detail_contract ngps
                    ON  ngps.source_contract_id = scsv.item
                    AND ngps.netting_group_detail_id = @netting_group_id
        WHERE  ngps.netting_group_detail_id IS NULL 		
        
        DELETE ngps
        FROM   netting_group_detail_contract ngps
               LEFT JOIN dbo.SplitCommaSeperatedValues(@contract_ids) scsv
                    ON  ngps.source_contract_id = scsv.item
        WHERE  ngps.netting_group_detail_id = @netting_group_id
               AND scsv.item IS NULL
    END
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Netting Group',
             'spa_netting_parent_groups',
             'DB Error',
             'Failed to Update Netting Group.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Netting Group',
             'spa_netting_parent_groups',
             'Success',
             'Changes have been saved successfully.',
             ''
END
ELSE 
IF @flag = 'd'
BEGIN
    BEGIN TRY
    	DECLARE @ErrorNumber      INT,
    	        @ErrorMessage     VARCHAR(1000)
    	
    	DELETE ng
		FROM netting_group ng
		INNER JOIN dbo.FNASplit(@del_net_grp_id, ',') di ON di.item = ng.netting_group_id

    END TRY	
    
    BEGIN CATCH
    	SELECT @ErrorNumber = ERROR_NUMBER(),
    	       @ErrorMessage = ERROR_MESSAGE();
    END CATCH
    
    IF @ErrorNumber = 547
        SELECT 'Error',
               'Netting Group',
               'spa_netting_groups',
               'DB Error',
               'Please Delete Group Applies to First.' [message],
               ''
    ELSE 
    IF @ErrorNumber > 0
        EXEC spa_ErrorHandler @ErrorNumber,
             'Netting Group',
             'spa_netting_groups',
             'DB Error',
             'Fail to Delete Netting Group. ',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Netting Parent Group',
             'spa_netting_groups',
             'Success',
             'Changes have been saved successfully.',
             ''
END
ELSE 
IF @flag = 'z' -- Delete from netting_group_gain_loss, netting_group and netting_group_detail
BEGIN
    BEGIN TRY
    	DELETE netting_group_gain_loss
    	WHERE  netting_group_id = @netting_group_id
    	
    	DELETE netting_group_detail
    	WHERE  netting_group_id = @netting_group_id
    	
    	DELETE netting_group
    	WHERE  netting_group_id = @netting_group_id
    	
    	EXEC spa_ErrorHandler 0,
    	     'Netting Parent Group',
    	     'spa_netting_groups',
    	     'Success',
    	     'Changes have been saved successfully.',
    	     ''
    END TRY	
    
    BEGIN CATCH
    	IF @@ERROR <> 0
    	    EXEC spa_ErrorHandler @ErrorNumber,
    	         'Netting Group',
    	         'spa_netting_groups',
    	         'DB Error',
    	         'Fail to Delete Netting Group. ',
    	         ''
    END CATCH
END

IF @flag = 'c'
BEGIN
    SET @sql_select = 
        '
			SELECT     
				netting_group.netting_group_name AS GroupName, dbo.FNADateFormat(netting_group.effective_date) AS EffectiveDate, dbo.FNADateFormat(netting_group.end_date) AS EndDate, 
						  sle.legal_entity_name AS LegalEntity,source_commodity.commodity_name AS Commodity, 
						  CASE netting_group.physical_financial_flag WHEN ''p'' THEN ''Physical'' when ''a'' then ''All''  when ''n'' then ''None''  ELSE ''Financial'' END AS Financial, 
				  hedge_type.code As HedgeType,	
						  DealType.source_deal_type_name AS DealType, DealSubType.source_deal_type_name AS DealSubType, 
						  netting_group.netting_group_id AS NetGrpId, netting_group.netting_parent_group_id AS NetPrtGrpId,
			  gl_gross.gl_account_number + '' ('' + gl_gross.gl_account_name + '')'' AS GLGross, 
           			gl_net.gl_account_number + '' ('' + gl_net.gl_account_name + '')'' AS GLNet, 
				   gl_expense.gl_account_number + '' ('' + gl_expense.gl_account_name + '')'' AS GLExpense
			FROM       
				netting_group
				LEFT JOIN netting_group_detail ngd ON netting_group.netting_group_id=ngd.netting_group_id
				LEFT OUTER JOIN
						  portfolio_hierarchy Sub ON netting_group.sub_entity_id = Sub.entity_id LEFT OUTER JOIN
						  portfolio_hierarchy Strategy ON netting_group.strategy_entity_id = Strategy.entity_id LEFT OUTER JOIN
						  portfolio_hierarchy Book ON netting_group.book_entity_id = Book.entity_id LEFT OUTER JOIN
						  source_commodity ON netting_group.source_commodity_id = source_commodity.source_commodity_id LEFT OUTER JOIN
						  source_deal_type DealType ON netting_group.source_deal_type_id = DealType.source_deal_type_id LEFT OUTER JOIN
						  source_deal_type DealSubType ON netting_group.source_deal_sub_type_id = DealSubType.source_deal_type_id LEFT OUTER JOIN
			static_data_value hedge_type ON hedge_type.value_id = netting_group.hedge_type_value_id LEFT OUTER JOIN
			gl_system_mapping gl_gross on gl_gross.gl_number_id=netting_group.gl_id_gross_revenue LEFT OUTER JOIN
			gl_system_mapping gl_net on gl_net.gl_number_id=netting_group.gl_id_net_revenue LEFT OUTER JOIN
			gl_system_mapping gl_expense on gl_expense.gl_number_id=netting_group.gl_id_gross_expense LEFT JOIN
			netting_group_parent ngp on ngp.netting_parent_group_id=netting_group.netting_parent_group_id  LEFT JOIN
			source_legal_entity sle on sle.source_legal_entity_id=ngp.legal_entity
	WHERE		netting_group.netting_parent_group_id = ' + CAST(@netting_parent_group_id AS VARCHAR)
        
        + CASE 
               WHEN @counterparty_id IS NOT NULL THEN 
                    ' AND(ngd.source_counterparty_id=' + CAST(@counterparty_id AS VARCHAR)
                    + ' OR ngd.source_counterparty_id IS NULL)'
               ELSE ''
          END
    
    IF @gain_loss_flag IS NULL
       OR @gain_loss_flag = 'n'
        SET @sql_select = @sql_select + 
            ' and (gain_loss_flag is null or gain_loss_flag=''n'')'
    ELSE
        SET @sql_select = @sql_select + ' and gain_loss_flag=''' + @gain_loss_flag
            + ''''
    
    exec spa_print @sql_select
    EXEC (@sql_select)
END

IF @flag = 'n'
BEGIN
	SELECT DISTINCT 
		ng.netting_group_id,
		ng.netting_parent_group_id,
		ng.netting_group_name,
		ng.effective_date,
		ng.end_date
		--,
		--ng.source_deal_type_id,
		--ng.source_deal_sub_type_id,
		--ng.source_commodity_id,
		--ng.physical_financial_flag,
		--ng.hedge_type_value_id,
		--ng.internal_counterparty,
		--SUBSTRING(ss.contract_name, 1, LEN(ss.contract_name) -1) [contract_name],
		--SUBSTRING(s.contract_id, 1, LEN(s.contract_id) -1) [contract_id]
	FROM netting_group ng
	LEFT JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
	LEFT JOIN netting_group_detail_contract ngdc ON ngd.netting_group_detail_id = ngdc.netting_group_detail_id
	CROSS APPLY(
		SELECT CAST(ngdc.source_contract_id AS VARCHAR(MAX)) + ', '
		FROM netting_group ngi
		LEFT JOIN netting_group_detail ngd ON ngi.netting_group_id = ngd.netting_group_id
		LEFT JOIN netting_group_detail_contract ngdc ON ngd.netting_group_detail_id = ngdc.netting_group_detail_id
		WHERE ngi.netting_group_id = ng.netting_group_id
		FOR XML PATH('')
	) s (contract_id)
	CROSS APPLY(
		SELECT CAST(cg.contract_name AS VARCHAR(MAX)) + ', '
		FROM netting_group ngi
		LEFT JOIN netting_group_detail ngd ON ngi.netting_group_id = ngd.netting_group_id
		LEFT JOIN netting_group_detail_contract ngdc ON ngd.netting_group_detail_id = ngdc.netting_group_detail_id
		LEFT JOIN contract_group cg ON cg.contract_id = ngdc.source_contract_id
		WHERE ngi.netting_group_id = ng.netting_group_id
		FOR XML PATH('')
	) ss (contract_name)
	WHERE ngd.source_counterparty_id = @counterparty_id
END