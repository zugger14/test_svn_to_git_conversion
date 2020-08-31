IF OBJECT_ID(N'spa_sourcesystembookmap', N'P') IS NOT NULL
DROP PROCEDURE spa_sourcesystembookmap
 GO 

/*
190	83	108	104	112	116	400	1	NULL	NULL	dbo	2/20/2007 8:42:34 PM	dbo	2/20/2007 8:42:34 PM	1/1/2005 12:00:00 AM
186	83	108	104	117	116	400	1	1/1/2005 12:00:00 AM	NULL	dbo	2/20/2007 8:42:34 PM	dbo	2/20/2007 8:42:34 PM	NULL
exec spa_sourcesystembookmap 'i', 267,446,108,104,117,116,400,.5,'2005-01-01',null,null	

spa_sourcesystembookmap1 'e',83,null,108,104,117,116,400,0.1,'2005-01-01',null,null
spa_sourcesystembookmap1 'e',83,null,108,104,117,116,400,0.1,'2005-01-01',null,null

spa_sourcesystembookmap.php?flag=i&fas_book_id=267&book_deal_type_map_id=NULL&source_system_book_id1=379&source_system_book_id2=308&source_system_book_id3=384&source_system_book_id4=-4&fas_deal_type_value_id=400&percentage_included=1&effective_start_date=2007-12-01&fas_deal_sub_type_value_id=NULL&session_id=a4lq866rranmsbqo48j5het997
*/
--SELECT * FROM source_system_book_map

CREATE PROC [dbo].[spa_sourcesystembookmap]
	@flag CHAR(1),
	@fas_book_id INT = NULL,
	@fas_book_id_arr VARCHAR(MAX) = NULL,
	@book_deal_type_map_id INT = NULL,
	@source_system_book_id1 INT = NULL,
	@source_system_book_id2 INT = NULL,
	@source_system_book_id3 INT = NULL,
	@source_system_book_id4 INT = NULL,
	@fas_deal_type_value_id INT = NULL,
	@percentage_included FLOAT = NULL,
	@effective_start_date VARCHAR(30) = NULL,
	@fas_deal_sub_type_value_id INT = NULL,
	@end_date DATETIME = NULL,
	@gl_number_id_st_asset INT = NULL,
	@gl_number_id_st_liab INT = NULL,
	@gl_number_id_lt_asset INT = NULL,
	@gl_number_id_lt_liab INT = NULL,
	@gl_number_id_item_st_asset INT = NULL,
	@gl_number_id_item_st_liab INT = NULL,
	@gl_number_id_item_lt_asset INT = NULL,
	@gl_number_id_item_lt_liab INT = NULL,
	@gl_number_id_aoci INT = NULL,
	@gl_number_id_pnl INT = NULL,
	@gl_number_id_set INT = NULL,
	@gl_number_id_cash INT = NULL,
	@gl_number_id_inventory INT = NULL,
	@gl_number_id_expense INT = NULL,
	@gl_number_id_gross_set INT = NULL,
	@gl_id_amortization INT = NULL,
	@gl_id_interest INT = NULL,
	@gl_id_st_tax_asset INT = NULL,
	@gl_id_st_tax_liab INT = NULL,
	@gl_id_lt_tax_asset INT = NULL,
	@gl_id_lt_tax_liab INT = NULL,
	@gl_id_tax_reserve INT = NULL,
	@gl_number_unhedged_der_st_asset INT = NULL,
	@gl_number_unhedged_der_lt_asset INT = NULL,
	@gl_number_unhedged_der_st_liab INT = NULL,
	@gl_number_unhedged_der_lt_liab INT = NULL,
    @logicalName VARCHAR(200) = NULL 
AS

SET NOCOUNT ON

DECLARE @group1               VARCHAR(100),
        @group2               VARCHAR(100),
        @group3               VARCHAR(100),
        @group4               VARCHAR(100)

DECLARE @percent              NUMERIC(5, 3)
DECLARE @sql_stmt             AS VARCHAR(5000)
DECLARE @url_desc             VARCHAR(5000)
DECLARE @hedge_type_value_id  INT 

/*
declare 
	@flag CHAR(1),
	@fas_book_id INT = NULL,
	@fas_book_id_arr VARCHAR(MAX) = NULL,
	@book_deal_type_map_id INT = NULL,
	@source_system_book_id1 INT = NULL,
	@source_system_book_id2 INT = NULL,
	@source_system_book_id3 INT = NULL,
	@source_system_book_id4 INT = NULL,
	@fas_deal_type_value_id INT = NULL,
	@percentage_included FLOAT = NULL,
	@effective_start_date VARCHAR(30) = NULL,
	@fas_deal_sub_type_value_id INT = NULL,
	@end_date DATETIME = NULL,
	@gl_number_id_st_asset INT = NULL,
	@gl_number_id_st_liab INT = NULL,
	@gl_number_id_lt_asset INT = NULL,
	@gl_number_id_lt_liab INT = NULL,
	@gl_number_id_item_st_asset INT = NULL,
	@gl_number_id_item_st_liab INT = NULL,
	@gl_number_id_item_lt_asset INT = NULL,
	@gl_number_id_item_lt_liab INT = NULL,
	@gl_number_id_aoci INT = NULL,
	@gl_number_id_pnl INT = NULL,
	@gl_number_id_set INT = NULL,
	@gl_number_id_cash INT = NULL,
	@gl_number_id_inventory INT = NULL,
	@gl_number_id_expense INT = NULL,
	@gl_number_id_gross_set INT = NULL,
	@gl_id_amortization INT = NULL,
	@gl_id_interest INT = NULL,
	@gl_id_st_tax_asset INT = NULL,
	@gl_id_st_tax_liab INT = NULL,
	@gl_id_lt_tax_asset INT = NULL,
	@gl_id_lt_tax_liab INT = NULL,
	@gl_id_tax_reserve INT = NULL,
	@gl_number_unhedged_der_st_asset INT = NULL,
	@gl_number_unhedged_der_lt_asset INT = NULL,
	@gl_number_unhedged_der_st_liab INT = NULL,
	@gl_number_unhedged_der_lt_liab INT = NULL,
    @logicalName VARCHAR(200) = NULL ,
	@group1               VARCHAR(100)     = NULL,
	@group2               VARCHAR(100)     = NULL,
	@group3               VARCHAR(100)     = NULL,
	@group4               VARCHAR(100)     = NULL,
											 
	@percent              NUMERIC(5, 3)		= NULL ,
	@sql_stmt             AS VARCHAR(5000)	= NULL ,
	@url_desc             VARCHAR(5000)		= NULL ,
	@hedge_type_value_id  INT 				= NULL

	select @flag='v', @logicalName='cccc - Transferred', @fas_book_id='1329', @source_system_book_id1='3270', @source_system_book_id2='-2', @source_system_book_id3='-3', @source_system_book_id4='-4', @book_deal_type_map_id='2255', @percentage_included='0', @effective_start_date='2018-05-02', @fas_deal_type_value_id='400', @end_date='2018-07-04'
--*/
IF @flag = 's'
BEGIN
     SELECT ssbm1.book_deal_type_map_id,
            ssbm1.fas_book_id,
            ssbm1.source_system_book_id1,
            ssbm1.source_system_book_id2,
            ssbm1.source_system_book_id3,
            ssbm1.source_system_book_id4,
            ssbm1.fas_deal_type_value_id,
            ssbm1.percentage_included,
            dbo.FNAGetSQLStandardDate(effective_start_date) effective_start_date,
            ssbm1.fas_deal_sub_type_value_id,
            dbo.FNAGetSQLStandardDate(end_date),
            ssbm1.logical_name,
            ISNULL(fb.hedge_type_value_id, fs.hedge_type_value_id) AS [hedge_type_value_id]
     FROM   source_system_book_map ssbm1
            LEFT JOIN fas_books fb
                 ON  fb.fas_book_id = ssbm1.fas_book_id
            LEFT JOIN portfolio_hierarchy ph
                 ON  fb.fas_book_id = ph.entity_id
            LEFT JOIN fas_strategy fs
                 ON  fs.fas_strategy_id = ph.parent_entity_id
     WHERE  book_deal_type_map_id = @book_deal_type_map_id
END
--select * from source_book
IF @flag = 'm' --for DHTMLX grid
BEGIN
     SELECT ssbm.book_deal_type_map_id AS fas_book_id,
			ssbm.logical_name AS logical_name,

			CASE WHEN sb1.source_system_book_id = '-1' THEN 'None' ELSE sb1.source_book_name END AS tag1,
			CASE WHEN sb2.source_system_book_id = '-2' THEN 'None' ELSE sb2.source_book_name END AS tag2,
			CASE WHEN sb3.source_system_book_id = '-3' THEN 'None' ELSE sb3.source_book_name END AS tag3,
			CASE WHEN sb4.source_system_book_id = '-4' THEN 'None' ELSE sb4.source_book_name END AS tag4,
            
			sdv1.code AS transaction_type,
			sdv2.code AS transaction_sub_type,

            CASE WHEN dbo.FNADateFormat(ssbm.effective_start_date) = '1900-01-01' THEN '' ELSE dbo.FNADateFormat(ssbm.effective_start_date) END AS effective_date,
			CASE WHEN dbo.FNADateFormat(ssbm.end_date) = '1900-01-01' THEN '' ELSE dbo.FNADateFormat(ssbm.end_date) END AS end_date,
            
			CASE WHEN ssbm.percentage_included IS NULL THEN 0 ELSE percentage_included END AS percentage_included,

            sdv3.code AS group1,
			sdv4.code AS group2,
			sdv5.code AS group3,
			sdv6.code AS group4,

			ssbm.create_user AS created_by,
			dbo.FNADateFormat(ssbm.create_ts) AS created_ts,
			ssbm.update_user AS updated_by,
			dbo.FNADateFormat(ssbm.update_ts) AS updated_ts
     FROM source_system_book_map ssbm
	 
	 INNER JOIN source_book sb1 ON ssbm.source_system_book_id1 = sb1.source_book_id
	 INNER JOIN source_book sb2 ON ssbm.source_system_book_id2 = sb2.source_book_id
	 INNER JOIN source_book sb3 ON ssbm.source_system_book_id3 = sb3.source_book_id
	 INNER JOIN source_book sb4 ON ssbm.source_system_book_id4 = sb4.source_book_id

	 LEFT JOIN static_data_value sdv1 ON  ssbm.fas_deal_type_value_id  = sdv1.value_id
	 LEFT JOIN static_data_value sdv2 ON  ssbm.fas_deal_sub_type_value_id  = sdv2.value_id

	 LEFT JOIN static_data_value sdv3 ON  ssbm.sub_book_group1  = sdv3.value_id
	 LEFT JOIN static_data_value sdv4 ON  ssbm.sub_book_group2  = sdv4.value_id
	 LEFT JOIN static_data_value sdv5 ON  ssbm.sub_book_group3  = sdv5.value_id
	 LEFT JOIN static_data_value sdv6 ON  ssbm.sub_book_group4  = sdv6.value_id

	 LEFT JOIN fas_books fb ON  fb.fas_book_id = ssbm.fas_book_id
     LEFT JOIN portfolio_hierarchy ph ON  fb.fas_book_id = ph.entity_id
     LEFT JOIN fas_strategy fs ON  fs.fas_strategy_id = ph.parent_entity_id
     WHERE ssbm.fas_book_id = @fas_book_id
END
IF @flag = 'n' --for sub book in create and view deals DHTMLX grid
BEGIN
	SET @sql_stmt = 'SELECT ssbm.book_deal_type_map_id AS fas_book_id,
							ssbm.logical_name AS logical_name,
							CASE WHEN sb1.source_system_book_id = ''-1'' THEN ''None'' ELSE sb1.source_book_name END AS tag1,
							CASE WHEN sb2.source_system_book_id = ''-2'' THEN ''None'' ELSE sb2.source_book_name END AS tag2,
							CASE WHEN sb3.source_system_book_id = ''-3'' THEN ''None'' ELSE sb3.source_book_name END AS tag3,
							CASE WHEN sb4.source_system_book_id = ''-4'' THEN ''None'' ELSE sb4.source_book_name END AS tag4,
							sdv1.code AS transaction_type
					 FROM source_system_book_map ssbm	 
					 INNER JOIN source_book sb1 ON ssbm.source_system_book_id1 = sb1.source_book_id
					 INNER JOIN source_book sb2 ON ssbm.source_system_book_id2 = sb2.source_book_id
					 INNER JOIN source_book sb3 ON ssbm.source_system_book_id3 = sb3.source_book_id
					 INNER JOIN source_book sb4 ON ssbm.source_system_book_id4 = sb4.source_book_id

					 INNER JOIN static_data_value sdv1 ON  ssbm.fas_deal_type_value_id  = sdv1.value_id

					 LEFT JOIN fas_books fb ON  fb.fas_book_id = ssbm.fas_book_id
					 LEFT JOIN portfolio_hierarchy ph ON  fb.fas_book_id = ph.entity_id
					 LEFT JOIN fas_strategy fs ON  fs.fas_strategy_id = ph.parent_entity_id
					 INNER JOIN dbo.SplitCommaSeperatedValues(''' + @fas_book_id_arr + ''') a ON ssbm.fas_book_id = a.item
					 WHERE 1 = 1 ' + CASE WHEN @fas_deal_type_value_id IS NOT NULL THEN ' AND ssbm.fas_deal_type_value_id = ' + CAST(@fas_deal_type_value_id AS VARCHAR(8)) ELSE '' END
	EXEC(@sql_stmt) 
END
IF @flag = 'r' --for sub book in Automation of Forecast Transaction Where transaction type is Hedging Instrument - 400	Hedging Instrument (Der)
BEGIN
	SELECT ssbm.book_deal_type_map_id AS fas_book_id,
			ssbm.logical_name AS logical_name,
			CASE WHEN sb1.source_system_book_id = '-1' THEN 'None' ELSE sb1.source_book_name END AS tag1,
			CASE WHEN sb2.source_system_book_id = '-2' THEN 'None' ELSE sb2.source_book_name END AS tag2,
			CASE WHEN sb3.source_system_book_id = '-3' THEN 'None' ELSE sb3.source_book_name END AS tag3,
			CASE WHEN sb4.source_system_book_id = '-4' THEN 'None' ELSE sb4.source_book_name END AS tag4,
			sdv1.code AS transaction_type
     FROM source_system_book_map ssbm	 
	 INNER JOIN source_book sb1 ON ssbm.source_system_book_id1 = sb1.source_book_id
	 INNER JOIN source_book sb2 ON ssbm.source_system_book_id2 = sb2.source_book_id
	 INNER JOIN source_book sb3 ON ssbm.source_system_book_id3 = sb3.source_book_id
	 INNER JOIN source_book sb4 ON ssbm.source_system_book_id4 = sb4.source_book_id

	 LEFT JOIN static_data_value sdv1 ON  ssbm.fas_deal_type_value_id  = sdv1.value_id

	 LEFT JOIN fas_books fb ON  fb.fas_book_id = ssbm.fas_book_id
     LEFT JOIN portfolio_hierarchy ph ON  fb.fas_book_id = ph.entity_id
     LEFT JOIN fas_strategy fs ON  fs.fas_strategy_id = ph.parent_entity_id
     INNER JOIN dbo.SplitCommaSeperatedValues(@fas_book_id_arr) a ON ssbm.fas_book_id = a.item
     WHERE ssbm.fas_deal_type_value_id = 400
END
IF @flag = 'h'	--get hedge_type_id
BEGIN
	SELECT ISNULL(fb.hedge_type_value_id, fs.hedge_type_value_id) AS 
	       [hedge_type_value_id]
	FROM   fas_books fb
	       LEFT JOIN portfolio_hierarchy ph
	            ON  fb.fas_book_id = ph.entity_id
	       LEFT JOIN fas_strategy fs
	            ON  fs.fas_strategy_id = ph.parent_entity_id
	WHERE  fb.fas_book_id = @fas_book_id
END
If @flag = 'sa'
BEGIN
	IF EXISTS(
	       SELECT group1,
	              group2,
	              group3,
	              group4
	       FROM   source_book_mapping_clm
	   )
	BEGIN
	    SELECT @group1 = group1,
	           @group2 = group2,
	           @group3 = group3,
	           @group4 = group4
	    FROM   source_book_mapping_clm
	END
	ELSE
	BEGIN
	    SET @group1 = 'Group1'
	    SET @group2 = 'Group2'
	    SET @group3 = 'Group3'
	    SET @group4 = 'Group4'
	END
	SET @sql_stmt = 
	' SELECT 
		source_system_book_map.book_deal_type_map_id AS ID, 
		portfolio_hierarchy.entity_name AS [Book Name],
		source_book.source_book_name AS [' + @group1 + '], 
		source_book_1.source_book_name AS [' + @group2 + '], 
		source_book_2.source_book_name AS [' + @group3 + '], 
		source_book_3.source_book_name AS [' + @group4 + '],
		logical_name as [Logical Name], 
		source_system_book_map.percentage_included [Percentage], 
		dbo.FNADateFormat(source_system_book_map.effective_start_date) AS [Effective Date],
		dbo.FNADateFormat(source_system_book_map.end_date) [End Date],
		deal_type.code As Type,
		sv.code [Sub-Type],
		source_system_book_map.create_user as [Created By], 
		dbo.FNADateTimeFormat(source_system_book_map.create_ts,1) as [Created TS],
		source_system_book_map.update_user as [Updated By], 
		dbo.FNADateTimeFormat(source_system_book_map.update_ts,1) as [Updated TS]
	FROM  source_system_book_map 
	INNER JOIN source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id 
	INNER JOIN source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
	INNER JOIN source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
	INNER JOIN source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id 
	INNER JOIN static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id 
	INNER JOIN portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id 
	LEFT OUTER JOIN static_data_value sv on sv.value_id=source_system_book_map.fas_deal_sub_type_value_id
	WHERE (source_system_book_map.fas_book_id =' + CAST(@fas_book_id AS VARCHAR) + ')
	ORDER BY [' + @group1 + '],[' + @group2 + ']
	'
	
	EXEC (@sql_stmt)
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'DB Error',
	         'Failed to select Source System Book Map data.',
	         ''
END

ELSE IF @flag = 'i' 
BEGIN  
	DECLARE @err_msg VARCHAR(100)
	IF EXISTS (
		   SELECT 1
		   FROM   source_system_book_map
		   WHERE  logical_name = @logicalName
	   )
	BEGIN
		SET @err_msg = 'The Sub Book ''' + @logicalName + ''' already exists.'
        
		EXEC spa_ErrorHandler -1,
			 @err_msg,
			 'spa_sourcesystembookmap',
			 'DB Error',
			 @err_msg,
			 ''
        
		RETURN
	END
	
    SELECT @percent = SUM(ISNULL(percentage_included, 1))
	FROM   source_system_book_map
	WHERE  ISNULL(@effective_start_date, '1900-01-01') BETWEEN ISNULL(effective_start_date, '1900-01-01') 
	       AND DATEADD(dd, -1, ISNULL(end_date, '9999-12-31'))
	       AND source_system_book_id1 = @source_system_book_id1
	       AND source_system_book_id2 = @source_system_book_id2
	       AND source_system_book_id3 = @source_system_book_id3
	       AND source_system_book_id4 = @source_system_book_id4

	IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
	BEGIN
		SET @url_desc = 'spa_sourcesystembookmap e,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
						CASE 
							 WHEN @effective_start_date IS NULL THEN 'null'
							 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
						END + ',' +
						ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' +
						CASE 
							 WHEN @end_date IS NULL THEN 'null'
							 ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
						END
		
		exec spa_print @url_desc
		--return
		SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
		
		SELECT 'Error' ErrorCode,
		       'source_system_book_map' Module,
		       'source_system_book_map' Area,
		       'DB Error' STATUS,
		       'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
		       + @url_desc MESSAGE,
		       '' Recommendation
		
		RETURN
	END
	ELSE
	BEGIN
		SET @percent = 0
		SELECT @percent = SUM(ISNULL(percentage_included, 1))
		FROM   source_system_book_map
		WHERE  ISNULL(effective_start_date, '1900-01-01') BETWEEN ISNULL(@effective_start_date, '1900-01-01') 
		       AND DATEADD(dd, -1, ISNULL(@end_date, '9999-12-31'))
		       AND source_system_book_id1 = @source_system_book_id1
		       AND source_system_book_id2 = @source_system_book_id2
		       AND source_system_book_id3 = @source_system_book_id3
		       AND source_system_book_id4 = @source_system_book_id4
		
		IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
		BEGIN
		    SET @url_desc = 'spa_sourcesystembookmap f,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
							CASE 
								 WHEN @effective_start_date IS NULL THEN 'null'
								 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
							END + ',' +
							ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
							CASE 
								WHEN @end_date IS NULL THEN 'null'
								ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
							END
			
			exec spa_print @url_desc
			--return
			SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
			
			SELECT 'Error' ErrorCode,
			       'source_system_book_map' Module,
			       'source_system_book_map' Area,
			       'DB Error' STATUS,
			       'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
			       + @url_desc MESSAGE,
			       '' Recommendation
			
			RETURN
		END
	END

	INSERT INTO source_system_book_map (
	    fas_book_id,
	    source_system_book_id1,
	    source_system_book_id2,
	    source_system_book_id3,
	    source_system_book_id4,
	    fas_deal_type_value_id,
	    percentage_included,
	    effective_start_date,
	    fas_deal_sub_type_value_id,
	    end_date,
	    logical_name
	)
	VALUES (
	    @fas_book_id,
	    @source_system_book_id1,
	    @source_system_book_id2,
	    @source_system_book_id3,
	    @source_system_book_id4,
	    @fas_deal_type_value_id,
	    @percentage_included,
	    @effective_start_date,
	    @fas_deal_sub_type_value_id,
	    @end_date,
	    @logicalName
	)
	DECLARE @source_system_book_map_id INT 
	SELECT @source_system_book_map_id = SCOPE_IDENTITY()
	
	EXEC spa_source_books_map_GL_codes 'i',
	     @source_system_book_map_id,
	     @gl_number_id_st_asset,
	     @gl_number_id_st_liab,
	     @gl_number_id_lt_asset,
	     @gl_number_id_lt_liab,
	     @gl_number_id_item_st_asset,
	     @gl_number_id_item_st_liab,
	     @gl_number_id_item_lt_asset,
	     @gl_number_id_item_lt_liab,
	     @gl_number_id_aoci,
	     @gl_number_id_pnl,
	     @gl_number_id_set,
	     @gl_number_id_cash,
	     @gl_number_id_inventory,
	     @gl_number_id_expense,
	     @gl_number_id_gross_set,
	     @gl_id_amortization,
	     @gl_id_interest,
	     @gl_id_st_tax_asset,
	     @gl_id_st_tax_liab,
	     @gl_id_lt_tax_asset,
	     @gl_id_lt_tax_liab,
	     @gl_id_tax_reserve,
	     @gl_number_unhedged_der_st_asset,
		 @gl_number_unhedged_der_lt_asset,
		 @gl_number_unhedged_der_st_liab,
		 @gl_number_unhedged_der_lt_liab
	 
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'DB Error',
	         'Failed to insert Source System Book Map data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'Success',
	         'Source System Book Map data successfully inserted.',
	         ''
END	

ELSE IF @flag = 'u'
BEGIN
	DECLARE @err_message VARCHAR(100)
	IF EXISTS (
           SELECT 1
           FROM   source_system_book_map
           WHERE  logical_name = @logicalName
                  AND book_deal_type_map_id <> @book_deal_type_map_id 
       )
    BEGIN
        SET @err_message = 'The Sub Book ''' + @logicalName + ''' already exists.'
        
        EXEC spa_ErrorHandler -1,
             @err_message,
             'spa_sourcesystembookmap',
             'DB Error',
             @err_message,
             ''
        
        RETURN
    END
    
     SELECT @percent = SUM(ISNULL(percentage_included, 1))
     FROM   source_system_book_map
     WHERE  ISNULL(@effective_start_date, '1900-01-01') BETWEEN ISNULL(effective_start_date, '1900-01-01') 
            AND DATEADD(dd, -1, ISNULL(end_date, '9999-12-31'))
            AND source_system_book_id1 = @source_system_book_id1
            AND source_system_book_id2 = @source_system_book_id2
            AND source_system_book_id3 = @source_system_book_id3
            AND source_system_book_id4 = @source_system_book_id4
            AND book_deal_type_map_id <> @book_deal_type_map_id

	IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
	BEGIN
	    SET @url_desc = 'spa_sourcesystembookmap e,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
						CASE 
							 WHEN @effective_start_date IS NULL THEN 'null'
							 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
						END + ',' +
						ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' +
						CASE 
							WHEN  @end_date IS NULL THEN 'null'
							ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
						END

	    exec spa_print @url_desc
	    --return
	    SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
	    
	    SELECT 'Error' ErrorCode,
	           'source_system_book_map' Module,
	           'source_system_book_map' Area,
	           'DB Error' STATUS,
	           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
	           + @url_desc MESSAGE,
	           '' Recommendation
	    
	    RETURN
	END
	ELSE
	BEGIN
		SET @percent = 0
		SELECT @percent = SUM(ISNULL(percentage_included, 1))
		FROM   source_system_book_map
		WHERE  ISNULL(effective_start_date, '1900-01-01') BETWEEN ISNULL(@effective_start_date, '1900-01-01') 
		       AND DATEADD(dd, -1, ISNULL(@end_date, '9999-12-31'))
		       AND source_system_book_id1 = @source_system_book_id1
		       AND source_system_book_id2 = @source_system_book_id2
		       AND source_system_book_id3 = @source_system_book_id3
		       AND source_system_book_id4 = @source_system_book_id4
		       AND book_deal_type_map_id <> @book_deal_type_map_id
		IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
		BEGIN
		    SET @url_desc = 'spa_sourcesystembookmap f,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
							CASE 
								 WHEN @effective_start_date IS NULL THEN 'null'
								 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
							END + ',' +
							ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
							CASE 
								WHEN @end_date IS NULL THEN 'null'
								ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
							END
		    
		    exec spa_print @url_desc
		    --return
		    SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
		    
		    SELECT 'Error' ErrorCode,
		           'source_system_book_map' Module,
		           'source_system_book_map' Area,
		           'DB Error' STATUS,
		           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
		           + @url_desc MESSAGE,
		           '' Recommendation
		    
		    RETURN
		END
	END

	UPDATE source_system_book_map
	SET    fas_book_id = @fas_book_id,
	       source_system_book_id1 = @source_system_book_id1,
	       source_system_book_id2 = @source_system_book_id2,
	       source_system_book_id3 = @source_system_book_id3,
	       source_system_book_id4 = @source_system_book_id4,
	       fas_deal_type_value_id = @fas_deal_type_value_id,
	       percentage_included = @percentage_included,
	       effective_start_date = @effective_start_date,
	       fas_deal_sub_type_value_id = @fas_deal_sub_type_value_id,
	       end_date = @end_date,
	       logical_name = @logicalName
	WHERE  book_deal_type_map_id = @book_deal_type_map_id
	
	EXEC spa_source_books_map_GL_codes 'u',
	     @book_deal_type_map_id,
	     @gl_number_id_st_asset,
	     @gl_number_id_st_liab,
	     @gl_number_id_lt_asset,
	     @gl_number_id_lt_liab,
	     @gl_number_id_item_st_asset,
	     @gl_number_id_item_st_liab,
	     @gl_number_id_item_lt_asset,
	     @gl_number_id_item_lt_liab,
	     @gl_number_id_aoci,
	     @gl_number_id_pnl,
	     @gl_number_id_set,
	     @gl_number_id_cash,
	     @gl_number_id_inventory,
	     @gl_number_id_expense,
	     @gl_number_id_gross_set,
	     @gl_id_amortization,
	     @gl_id_interest,
	     @gl_id_st_tax_asset,
	     @gl_id_st_tax_liab,
	     @gl_id_lt_tax_asset,
	     @gl_id_lt_tax_liab,
	     @gl_id_tax_reserve,
	     @gl_number_unhedged_der_st_asset,
		 @gl_number_unhedged_der_lt_asset,
		 @gl_number_unhedged_der_st_liab,
		 @gl_number_unhedged_der_lt_liab
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'DB Error',
	         'Failed to update Source System Book Map data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'Success',
	         'Source System Book Map data successfully updated.',
	         ''
	         END	
ELSE IF @flag = 't' -- TRANSFERED BOOK
BEGIN
     SELECT @percent = SUM(ISNULL(percentage_included, 1))
     FROM   source_system_book_map
     WHERE  ISNULL(@effective_start_date, '1900-01-01') BETWEEN ISNULL(effective_start_date, '1900-01-01') 
            AND DATEADD(dd, -1, ISNULL(end_date, '9999-12-31'))
            AND source_system_book_id1 = @source_system_book_id1
            AND source_system_book_id2 = @source_system_book_id2
            AND source_system_book_id3 = @source_system_book_id3
            AND source_system_book_id4 = @source_system_book_id4
            AND book_deal_type_map_id <> @book_deal_type_map_id

	IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
	BEGIN
	    SET @url_desc = 'spa_sourcesystembookmap e,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
						CASE 
							 WHEN @effective_start_date IS NULL THEN 'null'
							 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
						END + ',' +
						ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
						CASE 
							WHEN @end_date IS NULL THEN 'null'
							ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
						END
	    
	    SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
	    
	    SELECT 'Error' ErrorCode,
	           'source_system_book_map' Module,
	           'source_system_book_map' Area,
	           'DB Error' STATUS,
	           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
	           + @url_desc MESSAGE,
	           '' Recommendation
	    
	    RETURN
	END
	ELSE
	BEGIN
		SET @percent = 0
		SELECT @percent = SUM(ISNULL(percentage_included, 1))
		FROM   source_system_book_map
		WHERE  ISNULL(effective_start_date, '1900-01-01') BETWEEN ISNULL(@effective_start_date, '1900-01-01') 
		       AND DATEADD(dd, -1, ISNULL(@end_date, '9999-12-31'))
		       AND source_system_book_id1 = @source_system_book_id1
		       AND source_system_book_id2 = @source_system_book_id2
		       AND source_system_book_id3 = @source_system_book_id3
		       AND source_system_book_id4 = @source_system_book_id4
		       AND book_deal_type_map_id <> @book_deal_type_map_id

		IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
		BEGIN
		    SET @url_desc = 'spa_sourcesystembookmap f,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
							CASE 
								 WHEN @effective_start_date IS NULL THEN 'null'
								 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
							END + ',' +
							ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
							CASE 
								WHEN @end_date IS NULL THEN 'null'
								ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
							END
		    
		    SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
		    
		    SELECT 'Error' ErrorCode,
		           'source_system_book_map' Module,
		           'source_system_book_map' Area,
		           'DB Error' STATUS,
		           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
		           + @url_desc MESSAGE,
		           '' Recommendation
		    
		    RETURN
		END
	END
	UPDATE source_system_book_map
	SET    fas_book_id = @fas_book_id,
	       percentage_included = @percentage_included,
	       effective_start_date = @effective_start_date
	WHERE  book_deal_type_map_id = @book_deal_type_map_id
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'DB Error',
	         'Failed to update Source System Book Map data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'Success',
	         'Source System Book Map data successfully updated.',
	         ''
END	
ELSE IF @flag = 'v' -- TRANSFERED BOOK
BEGIN
    BEGIN TRANSACTION
     UPDATE source_system_book_map
     SET    end_date = @end_date
     WHERE  book_deal_type_map_id = @book_deal_type_map_id
     
     SELECT @percent = SUM(ISNULL(percentage_included, 1))
     FROM   source_system_book_map
     WHERE  ISNULL(@end_date, '1900-01-01') BETWEEN ISNULL(effective_start_date, '1900-01-01') 
            AND DATEADD(dd, -1, ISNULL(end_date, '9999-12-31'))
            AND source_system_book_id1 = @source_system_book_id1
            AND source_system_book_id2 = @source_system_book_id2
            AND source_system_book_id3 = @source_system_book_id3
            AND source_system_book_id4 = @source_system_book_id4
	IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
	BEGIN
	    SET @url_desc = 'spa_sourcesystembookmap e,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
						ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
						ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
						CASE 
							 WHEN @effective_start_date IS NULL THEN 'null'
							 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
						END + ',' +
						ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
						CASE 
							WHEN @end_date IS NULL THEN 'null'
							ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
						END
	    exec spa_print @url_desc
	    --return
	    SET @url_desc = '' --'<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
	    
	    SELECT 'Error' ErrorCode,
	           'source_system_book_map' Module,
	           'source_system_book_map' Area,
	           'DB Error' STATUS,
	           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
	           + @url_desc MESSAGE,
	           '' Recommendation
	    
	    ROLLBACK TRANSACTION
	    RETURN
	END
	ELSE
	BEGIN
		SET @percent = 0
		SELECT @percent = SUM(ISNULL(percentage_included, 1))
		FROM   source_system_book_map
		WHERE  ISNULL(effective_start_date, '') BETWEEN ISNULL(@end_date, '') 
		       AND ''
		       AND source_system_book_id1 = @source_system_book_id1
		       AND source_system_book_id2 = @source_system_book_id2
		       AND source_system_book_id3 = @source_system_book_id3
		       AND source_system_book_id4 = @source_system_book_id4
		
		IF ISNULL(@percent, 0) + ISNULL(@percentage_included, 1) > 1
		BEGIN
		    SET @url_desc = 'spa_sourcesystembookmap f,' + ISNULL(CAST(@fas_book_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@book_deal_type_map_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id1 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@source_system_book_id2 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id3 AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@source_system_book_id4 AS VARCHAR), 'null') + ',' +
							ISNULL(CAST(@fas_deal_type_value_id AS VARCHAR), 'null') + ',' + 
							ISNULL(CAST(@percentage_included AS VARCHAR), 'null') + ',' +
							CASE 
								 WHEN @effective_start_date IS NULL THEN 'null'
								 ELSE '''' + CAST(@effective_start_date AS VARCHAR) + ''''
							END + ',' +
							ISNULL(CAST(@fas_deal_sub_type_value_id AS VARCHAR), 'null') + ',' + 
							CASE 
								WHEN @end_date IS NULL THEN 'null'
								ELSE '''' + CAST(@end_date AS VARCHAR) + ''''
							END
		    
		    SET @url_desc = '<a href="../../dev/spa_html.php?spa=' + @url_desc + '">Click here...</a>'
		    
		    SELECT 'Error' ErrorCode,
		           'source_system_book_map' Module,
		           'source_system_book_map' Area,
		           'DB Error' STATUS,
		           'Total percentage for this book mapping exceed 100% allocation, Please review the current mapping '
		           + @url_desc MESSAGE,
		           '' Recommendation
		    
		    ROLLBACK TRANSACTION
		    RETURN
		END
	END
	BEGIN TRY
	INSERT INTO source_system_book_map (
	    fas_book_id,
		logical_name,
	    source_system_book_id1,
	    source_system_book_id2,
	    source_system_book_id3,
	    source_system_book_id4,
	    fas_deal_type_value_id,
	    percentage_included,
	    effective_start_date,
	    fas_deal_sub_type_value_id
	 )
	VALUES (
	    @fas_book_id,
		@logicalName,
	    @source_system_book_id1,
	    @source_system_book_id2,
	    @source_system_book_id3,
	    @source_system_book_id4,
	    @fas_deal_type_value_id,
	    @percentage_included,
	    @end_date,
	    @fas_deal_sub_type_value_id
	 )
	
	 EXEC spa_ErrorHandler 0,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'Success',
	         'Source System Book Map data successfully updated.',
	         ''
	    
	   COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	EXEC spa_ErrorHandler -1,
	         'Source System Book Map',
	         'spa_sourcesystembookmap',
	         'DB Error',
	         'Failed to update Source System Book Map data.',
	         ''
	END CATCH
END	

ELSE IF @flag = 'd'
BEGIN
	IF EXISTS ( SELECT 1 FROM source_deal_header dh 
				LEFT OUTER JOIN	source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
				AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
				AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
				AND dh.source_system_book_id4 = sbmp.source_system_book_id4
				WHERE sbmp.book_deal_type_map_id = @book_deal_type_map_id
				UNION ALL
				SELECT 1
				FROM deal_transfer_mapping
				WHERE source_book_mapping_id_from = @book_deal_type_map_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
          'Source System Book Map',
          'spa_sourcesystembookmap',
          'DB Error',
          'There are deals in this sub book. Please remove those deals to other sub book before deleting.',
          ''       
        Return
		
	END
	
	
	EXEC spa_source_books_map_GL_codes 'd', @book_deal_type_map_id
	
	DELETE 
	FROM   source_system_book_map
	WHERE  book_deal_type_map_id = @book_deal_type_map_id
     
     
     
     IF @@ERROR <> 0
         EXEC spa_ErrorHandler @@ERROR,
              'Source System Book Map',
              'spa_sourcesystembookmap',
              'DB Error',
              'Failed to delete Source System Book Map data.',
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'Source System Book Map',
              'spa_sourcesystembookmap',
              'Success',
              'Changes have been saved successfully.',
              ''
END
ELSE IF @flag = 'e' --use for drill down report while error in valiadating total percentage
 BEGIN
	IF EXISTS(
		SELECT group1,
			   group2,
			   group3,
			   group4
		FROM   source_book_mapping_clm
	)
	BEGIN
	 SELECT @group1 = group1,
			@group2 = group2,
			@group3 = group3,
			@group4 = group4
	 FROM   source_book_mapping_clm
	END
	ELSE
	BEGIN
	 SET @group1 = 'Group1'
	 SET @group2 = 'Group2'
	 SET @group3 = 'Group3'
	 SET @group4 = 'Group4'
	END
	SET @sql_stmt='
	SELECT source_system_book_map.book_deal_type_map_id AS ID,
	       sb.entity_name Subsidiary,
	       st.entity_name Strategy,
	       bk.entity_name AS Book,
	       source_book.source_book_name AS ['+ @group1 +'],
	       source_book_1.source_book_name AS ['+@group2 +'],
	       source_book_2.source_book_name AS ['+ @group3 +'],
	       source_book_3.source_book_name AS ['+ @group4 +'],
	       ISNULL(source_system_book_map.percentage_included, 1) [Percentage],
	       dbo.FNADateFormat(source_system_book_map.effective_start_date) 
	       [Eff.Date],
	       deal_type.code AS TYPE,
	       sv.code SubType,
	       dbo.FNADateFormat(source_system_book_map.end_date) [End Date],
	       source_system_book_map.create_user AS CreateBy,
	       dbo.FNADateFormat(source_system_book_map.create_ts) AS CreateTS,
	       source_system_book_map.update_user AS CreateBy,
	       dbo.FNADateFormat(source_system_book_map.update_ts) AS UpdateTS
	FROM   source_system_book_map
	       INNER JOIN source_book
	            ON  source_system_book_map.source_system_book_id1 = source_book.source_book_id
	       INNER JOIN source_book source_book_1
	            ON  source_system_book_map.source_system_book_id2 = 
	                source_book_1.source_book_id
	       INNER JOIN source_book source_book_2
	            ON  source_system_book_map.source_system_book_id3 = 
	                source_book_2.source_book_id
	       INNER JOIN source_book source_book_3
	            ON  source_system_book_map.source_system_book_id4 = 
	                source_book_3.source_book_id
	       INNER JOIN static_data_value deal_type
	            ON  source_system_book_map.fas_deal_type_value_id = deal_type.value_id
	       INNER JOIN portfolio_hierarchy bk
	            ON  bk.entity_id = source_system_book_map.fas_book_id
	       LEFT JOIN portfolio_hierarchy st
	            ON  bk.parent_entity_id = st.entity_id
	       LEFT JOIN portfolio_hierarchy sb
	            ON  st.parent_entity_id = sb.entity_id
	       LEFT OUTER JOIN static_data_value sv
	            ON  sv.value_id = source_system_book_map.fas_deal_sub_type_value_id
	WHERE  '''+isnull(@effective_start_date,'1900 -01 -01') + ''' BETWEEN ISNULL(effective_start_date, ''1900 -01 -01'') 
	       AND DATEADD(dd, -1, ISNULL(end_date, ''9999 -12 -31''))
	       AND source_system_book_id1 = '+cast(@source_system_book_id1 as varchar)+'
	       AND source_system_book_id2 = '+cast(@source_system_book_id2 as varchar)+'
	       AND source_system_book_id3 = '+cast(@source_system_book_id3 as varchar) +'
	       AND source_system_book_id4 = '+cast(@source_system_book_id4 as varchar)
	EXEC (@sql_stmt)
END

ELSE IF @flag = 'f' --use for drill down report while error in valiadating total percentage
 BEGIN
     IF EXISTS(
            SELECT group1,
                   group2,
                   group3,
                   group4
            FROM   source_book_mapping_clm
        )
     BEGIN
         SELECT @group1 = group1,
                @group2 = group2,
                @group3 = group3,
                @group4 = group4
         FROM   source_book_mapping_clm
     END
     ELSE
     BEGIN
         SET @group1 = 'Group1'
         SET @group2 = 'Group2'
         SET @group3 = 'Group3'
         SET @group4 = 'Group4'
     END
     SET @sql_stmt = '
	SELECT source_system_book_map.book_deal_type_map_id AS ID,
	       sb.entity_name Subsidiary,
	       st.entity_name Strategy,
	       bk.entity_name AS Book,
	       source_book.source_book_name AS ['+ @group1 +'],
	       source_book_1.source_book_name AS ['+@group2 +'],
	       source_book_2.source_book_name AS ['+ @group3 +'],
	       source_book_3.source_book_name AS ['+ @group4 +'],
	       ISNULL(source_system_book_map.percentage_included, 1) [Percentage],
	       dbo.FNADateFormat(source_system_book_map.effective_start_date) 
	       [Eff.Date],
	       deal_type.code AS TYPE,
	       sv.code SubType,
	       dbo.FNADateFormat(source_system_book_map.end_date) [End Date],
	       source_system_book_map.create_user AS CreateBy,
	       dbo.FNADateFormat(source_system_book_map.create_ts) AS CreateTS,
	       source_system_book_map.update_user AS CreateBy,
	       dbo.FNADateFormat(source_system_book_map.update_ts) AS UpdateTS
	FROM   source_system_book_map
	       INNER JOIN source_book
	            ON  source_system_book_map.source_system_book_id1 = source_book.source_book_id
	       INNER JOIN source_book source_book_1
	            ON  source_system_book_map.source_system_book_id2 = 
	                source_book_1.source_book_id
	       INNER JOIN source_book source_book_2
	            ON  source_system_book_map.source_system_book_id3 = 
	                source_book_2.source_book_id
	       INNER JOIN source_book source_book_3
	            ON  source_system_book_map.source_system_book_id4 = 
	                source_book_3.source_book_id
	       INNER JOIN static_data_value deal_type
	            ON  source_system_book_map.fas_deal_type_value_id = deal_type.value_id
	       INNER JOIN portfolio_hierarchy bk
	            ON  bk.entity_id = source_system_book_map.fas_book_id
	       LEFT JOIN portfolio_hierarchy st
	            ON  bk.parent_entity_id = st.entity_id
	       LEFT JOIN portfolio_hierarchy sb
	            ON  st.parent_entity_id = sb.entity_id
	       LEFT OUTER JOIN static_data_value sv
	            ON  sv.value_id = source_system_book_map.fas_deal_sub_type_value_id
	WHERE  ISNULL(effective_start_date, '''') BETWEEN '''+cast(isnull(@effective_start_date,'') as varchar) + ''' 
	       AND '''+cast(dateadd(dd,-1,isnull(@end_date,'')) as varchar)+ '''
	       AND source_system_book_id1 = '+cast(@source_system_book_id1 as varchar)+'
	       AND source_system_book_id2 = '+cast(@source_system_book_id2 as varchar)+'
	       AND source_system_book_id3 = '+cast(@source_system_book_id3 as varchar) +'
	       AND source_system_book_id4 = '+cast(@source_system_book_id4 as varchar)
	EXEC (@sql_stmt)
End
ELSE IF @flag = 'g'
BEGIN
	SELECT fs.gl_grouping_value_id gl_entry_grouping, fs.hedge_type_value_id accounting_type FROM dbo.portfolio_hierarchy ph 
	INNER JOIN dbo.portfolio_hierarchy ph1 ON ph1.parent_entity_id = ph.entity_id
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id = ph.entity_id 
	--LEFT JOIN static_data_value sdv ON sdv.value_id = fs.gl_grouping_value_id
	LEFT JOIN source_system_book_map ssbm ON ssbm.fas_book_id = ph1.entity_id
	WHERE ssbm.book_deal_type_map_id = @book_deal_type_map_id
END
ELSE IF @flag = 'j'
BEGIN
	SELECT fs.gl_grouping_value_id gl_entry_grouping, fs.hedge_type_value_id accounting_type FROM dbo.portfolio_hierarchy ph 
	INNER JOIN dbo.portfolio_hierarchy ph1 ON ph1.parent_entity_id = ph.entity_id
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id = ph.entity_id 
	--LEFT JOIN static_data_value sdv ON sdv.value_id = fs.gl_grouping_value_id
	WHERE ph1.entity_id = @book_deal_type_map_id
END
