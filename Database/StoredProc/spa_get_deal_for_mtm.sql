--@book_deal_type_map_id is required and takes mustiple ids
--@deal_id_from, @deal_id_to are optional
--@deal_date_from, @deal_date_to are optional
-- exec spa_get_deal_for_mtm '8', '2003-01-31'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_deal_for_mtm]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_deal_for_mtm]
GO

CREATE PROC [dbo].[spa_get_deal_for_mtm] 
	@book_deal_type_map_id	VARCHAR(MAX), 			 
	@as_of_date				VARCHAR(100) = NULL,
	@term_start				VARCHAR(100) = NULL,
	@term_end				VARCHAR(100) = NULL,
	@deal_id				VARCHAR(MAX) = NULL,
	@deal_ref_id			VARCHAR(MAX) = NULL,
	@deal_id_list			VARCHAR(MAX) = NULL,
	@contract				VARCHAR(MAX) = NULL,
	@counterparty_id		VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

IF @as_of_date = '' SET @as_of_date = NULL
IF @term_start = '' SET @term_start = NULL
IF @term_end = '' SET @term_end = NULL
IF @deal_id = '' SET @deal_id = NULL
IF @deal_ref_id = '' SET @deal_ref_id= NULL
IF @deal_id_list = '' SET @deal_id_list = NULL
IF @contract = '' SET @contract = NULL
IF @counterparty_id = '' SET @counterparty_id = NULL

DECLARE @sql_Select    VARCHAR(MAX)
DECLARE @sql_Where     VARCHAR(MAX)
DECLARE @sql_group_by  VARCHAR(MAX)

--TO TEST UNCOMMENT THIS

	--DECLARE @book_deal_type_map_id  VARCHAR(100)
	--DECLARE @deal_id_from           INT 
	--DECLARE @deal_id_to             INT 
	--DECLARE @deal_date_from         DATETIME 
	--DECLARE @deal_date_to           DATETIME 
	--DECLARE @use_by_linking         CHAR

	--SET @book_deal_type_map_id = '2, 8, 10'
	--SET @deal_id_from = NULL
	--SET @deal_id_to = NULL
	--SET @deal_date_from = '1/1/2003'
	--SET @deal_date_to = '7/1/2004'
	--SET @use_by_linking = 'y'

--END OF TO TEST UNCOMMENT THIS

--########### Group Label
DECLARE @group1  VARCHAR(100),
        @group2  VARCHAR(100),
        @group3  VARCHAR(100),
        @group4  VARCHAR(100)

IF EXISTS( SELECT group1,
                  group2,
                  group3,
                  group4
           FROM   source_book_mapping_clm )
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
--######## End

SET @sql_Select = 'SELECT 
						sdh.deal_id AS [Source Deal ID],
						sdh.source_deal_header_id AS [Deal ID],
						dbo.FNADateFormat(MAX(sdh.deal_date)) AS [Deal Date],
						dbo.FNADateFormat(MIN(sdd.term_start)) AS [Term Start],
						dbo.FNADateFormat(MAX(sdd.term_end)) AS [Term End],
						MAX(sPCD.curve_name) AS [Index],
						spcd1.curve_name AS [Index On],
						MAX(sC.currency_name) AS Currency,
						dbo.FNARemoveTrailingZeroes(MAX(sdd.deal_volume)) AS [Deal Volume],
						MAX(source_uom.uom_name) AS [Deal UOM],
						CASE 
							WHEN (MAX(sdd.deal_volume_frequency) = ''m'') THEN ''Monthly''
							WHEN (MAX(sdd.deal_volume_frequency) = ''d'') THEN ''Daily''
							ELSE MAX(sdd.deal_volume_frequency)
						END AS [Volume Frequency],
						MAX(dT.source_deal_type_name) AS [Source Deal Type],
						sdht.template_name AS [Template],
						MAX(dSubT.source_deal_type_name) AS [Sub Deal Type],
						MAX(sb1.source_book_name) AS ['+@group1+'],
						MAX(sb2.source_book_name) AS ['+@group2+'],
						MAX(sb3.source_book_name) AS ['+@group3+'],
						MAX(sb4.source_book_name) AS ['+@group4+']
					FROM source_deal_header sdh
						INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						INNER JOIN source_system_book_map sSBM ON sdh.source_system_book_id1 = sSBM.source_system_book_id1
						AND sdh.source_system_book_id2 = sSBM.source_system_book_id2
						AND sdh.source_system_book_id3 = sSBM.source_system_book_id3
						AND sdh.source_system_book_id4 = sSBM.source_system_book_id4
						LEFT OUTER JOIN source_currency sC ON sdd.fixed_price_currency_id = sC.source_currency_id
						LEFT OUTER JOIN source_price_curve_def sPCD ON sdd.curve_id = sPCD.source_curve_def_id
						LEFT OUTER JOIN source_uom ON sdd.deal_volume_uom_id = source_uom.source_uom_id
						LEFT OUTER JOIN source_deal_type dT ON sdh.source_deal_type_id = dT.source_deal_type_id
						LEFT OUTER JOIN source_book sb4 ON sdh.source_system_book_id4 = sb4.source_book_id
						LEFT OUTER JOIN source_book sb3 ON sdh.source_system_book_id3 = sb3.source_book_id
						LEFT OUTER JOIN source_book sb2 ON sdh.source_system_book_id2 = sb2.source_book_id
						LEFT OUTER JOIN source_book sb1 ON sdh.source_system_book_id1 = sb1.source_book_id
						LEFT OUTER JOIN source_deal_type dSubT ON sdh.deal_sub_type_type_id = dSubT.source_deal_type_id
						LEFT OUTER JOIN source_deal_header_template AS sdht ON sdht.template_id = sdh.template_id
						LEFT OUTER JOIN source_price_curve_def spcd1 ON sdd.formula_curve_id = spcd1.source_curve_def_id
					WHERE 1=1'
					
SET @sql_Where = ' AND sdh.deal_date <= ''' + @as_of_date + ''''

SET @sql_Where += ' AND sdd.term_start >= ''' + @term_start + ''''

SET @sql_Where += ' AND sdd.term_end <= ''' + @term_end + ''''

IF @book_deal_type_map_id IS NOT NULL
	SET @sql_Where = @sql_Where +  ' AND sSBM.book_deal_type_map_id IN ( ' + @book_deal_type_map_id + ' ) '

IF @deal_id IS NOT NULL
BEGIN
	SET @sql_Where = @sql_Where + ' AND sdh.source_deal_header_id in (' + @deal_id + ')'
END
	
IF @deal_ref_id IS NOT NULL
BEGIN
	SET @sql_Where = @sql_Where + ' AND sdh.deal_id LIKE ''' + @deal_ref_id + ''''	
END

IF @deal_id_list IS NOT NULL
BEGIN
	SET @sql_Where = @sql_Where + ' AND sdh.source_deal_header_id IN (' + @deal_id_list + ')'	
END

IF @contract IS NOT NULL
BEGIN
	SET @sql_Where = @sql_Where + ' AND sdh.contract_id IN ( ' + @contract	+ ')' 
END

IF @counterparty_id IS NOT NULL
BEGIN
	SET @sql_Where = @sql_Where + ' AND sdh.counterparty_id IN (' + @counterparty_id + ')'
END

SET @sql_group_by = ' GROUP BY sdh.deal_id, sdh.source_deal_header_id, sdht.template_name, spcd1.curve_name
					 ORDER BY sdh.deal_id, sdh.source_deal_header_id'

--PRINT(@sql_Select + @sql_Where + @sql_group_by)
EXEC (@sql_Select + @sql_Where + @sql_group_by)









