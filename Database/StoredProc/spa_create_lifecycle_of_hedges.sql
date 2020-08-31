IF OBJECT_ID(N'spa_create_lifecycle_of_hedges', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_create_lifecycle_of_hedges]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- exec spa_create_lifecycle_of_hedges '223', '2008-01-23', NULL, NULL, '386'
-- exec spa_create_lifecycle_of_hedges NULL, '2008-01-23', 130062, 130067, NULL, 'ANC124'
-- This procedure returns life cycle of hedges (deals)
-- DROP PROC spa_create_lifecycle_of_hedges
-- EXEC spa_create_lifecycle_of_hedges 10, '1/31/2003'
-- EXEC spa_create_lifecycle_of_hedges 10, '6/16/2004', 50001, 50001

CREATE PROCEDURE [dbo].[spa_create_lifecycle_of_hedges] @fas_book_id VARCHAR(MAX),
	@as_of_date VARCHAR(20),
	@deal_id_from INT = NULL,
	@deal_id_to  INT = NULL,
	@book_deal_type_map_id VARCHAR(MAX) = NULL,
	@source_deal_id VARCHAR(50) = NULL,
	@round_value CHAR(1) = '0', 
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging VARCHAR(200) = NULL,
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR (8000) 
DECLARE @user_login_id VARCHAR (50) 
DECLARE @sql_paging VARCHAR (8000) 
DECLARE @is_batch BIT
 
SET @str_batch_table = '' 
SET @user_login_id = dbo.FNADBUser()
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END
 
IF @is_batch = 1
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()
		
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL  
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
		EXEC (@sql_paging)  
		RETURN  
	END
END
 /*******************************************1st Paging Batch END**********************************************/

DECLARE @sql_stmt VARCHAR(MAX)
DECLARE @where_clause VARCHAR(MAX)

CREATE TABLE #hedges_lifecycle (
	[source_deal_header_id] [int] NOT NULL ,
	[deal_id] [varchar](500) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[as_of_date] [datetime] NOT NULL ,
	[deal_date] [datetime] NOT NULL ,
	[relationship_effective_date] [datetime] NULL ,
	[percentage_used] [float] NOT NULL ,
	[relationship_id] [int] NULL ,
	[description] [varchar] (250) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[sort_order] [int] NOT NULL,
	[create_user] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[create_ts] [datetime] NULL ,
	[update_user] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[update_ts] [datetime] NULL 
) ON [PRIMARY]


If @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
	SET @deal_id_to = @deal_id_from

SET @where_clause = ''

IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL)
	SET @where_clause = @where_clause + ' AND source_deal_header.source_deal_header_id BETWEEN ''' + CAST(@deal_id_from AS VARCHAR) + ''' AND ' + '''' + CAST(@deal_id_to AS VARCHAR) + ''''

IF (@deal_id_from IS NULL) AND (@deal_id_to IS NOT NULL)
	SET @where_clause = @where_clause + ' AND source_deal_header.source_deal_header_id = ''' + CAST(@deal_id_to AS VARCHAR) + ''''

IF (@source_deal_id IS NOT NULL)
	SET @where_clause = @where_clause + ' AND source_deal_header.deal_id LIKE ' + '''%' + @source_deal_id + '%'''

IF @fas_book_id IS NOT NULL AND (@source_deal_id IS NULL AND @deal_id_from IS NULL AND @deal_id_to IS NULL)
	SET @where_clause = @where_clause + ' AND source_system_book_map.fas_book_id IN (' + @fas_book_id + ')'

IF @book_deal_type_map_id IS NOT NULL AND (@source_deal_id IS NULL AND @deal_id_from IS NULL AND @deal_id_to IS NULL)
	SET @where_clause = @where_clause + ' AND source_system_book_map.book_deal_type_map_id IN (' + @book_deal_type_map_id + ') '

-------------------BEGIN OF DEAL ------------------------
SET @sql_stmt = '
	INSERT INTO #hedges_lifecycle
	SELECT source_deal_header.source_deal_header_id AS SourceDeal_Header_Id,
		source_deal_header.deal_id AS Deal_Id,
		source_deal_header.deal_date as AsOfDate,
		source_deal_header.deal_date AS DealDate,
		NULL as RelationshipEffectiveDate,
		0 As PercentageUse,
		NULL as LinkId,
		''Deal created.'' as Description,
		1 as SortOrder,
		NULL,
		NULL,
		NULL,NULL
	FROM source_deal_header
	INNER JOIN source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1
		AND source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2
		AND source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3
		AND source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
	WHERE source_deal_header.deal_date <= ''' + @as_of_date + ''''

SET @sql_stmt = @sql_stmt + @where_clause

--PRINT @sql_stmt
EXEC (@sql_stmt)
----------END OF DEAL -----------------

--BEGIN OF LINK
SET @sql_stmt = '
	INSERT INTO #hedges_lifecycle
	SELECT  source_deal_header.source_deal_header_id AS Source_Deal_Header_Id,
		source_deal_header.deal_id AS Deal_Id, 
		''' + @as_of_date + ''' as As_Of_Date,
		source_deal_header.deal_date AS Deal_Date,
		fas_link_header.link_effective_date as Relationship_Effective_Date, 
		fas_link_detail.percentage_included As Percentage_Use,
		fas_link_detail.link_id as Link_Id, 
		''Designation.'' as Description,
		1 as Sort_Order,
		NULL,
		NULL,
		NULL,
		NULL
	FROM source_deal_header
	INNER JOIN source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1
		AND source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2
		AND source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3
		AND source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
	INNER JOIN fas_link_detail ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id
	INNER JOIN fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id
	WHERE source_deal_header.deal_date <= ''' + @as_of_date + '''' +
		' AND fas_link_header.link_effective_date <= ''' + @as_of_date + '''' +
		' AND link_type_value_id = 450 '

SET @sql_stmt = @sql_stmt + @where_clause
--PRINT(@sql_stmt)
EXEC (@sql_stmt)

SET @sql_stmt = '
	INSERT INTO #hedges_lifecycle
	SELECT source_deal_header.source_deal_header_id AS Source_Deal_Header_Id,
		source_deal_header.deal_id AS Deal_Id,
		''' + @as_of_date + ''' as As_Of_Date,
		source_deal_header.deal_date AS Deal_Date,
		fas_link_header.link_end_date as Relationship_Effective_Date,
		fas_link_detail.percentage_included As Percentage_Use,
		fas_link_detail.link_id as Link_Id, 
		''De-Designation.'' as Description,
		1 as Sort_Order,
		NULL,
		NULL,
		NULL,
		NULL
	FROM source_deal_header
	INNER JOIN source_system_book_map ON source_deal_header.source_system_book_id1 = source_system_book_map.source_system_book_id1
		AND source_deal_header.source_system_book_id2 = source_system_book_map.source_system_book_id2
		AND source_deal_header.source_system_book_id3 = source_system_book_map.source_system_book_id3
		AND source_deal_header.source_system_book_id4 = source_system_book_map.source_system_book_id4
	INNER JOIN fas_link_detail ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id
	INNER JOIN fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id
	WHERE source_deal_header.deal_date <= ''' + @as_of_date + '''' +
		' AND fas_link_header.link_effective_date <= ''' + @as_of_date + '''' +
		' AND link_type_value_id <> 450 '

SET @sql_stmt = @sql_stmt + @where_clause
--PRINT(@sql_stmt)
EXEC (@sql_stmt)

EXEC('
	SELECT
		dbo.FNATRMWinHyperlink(''a'', 10131010, deal_id, ABS(source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Reference ID],
		--dbo.FNAHyperLinkText(10131000, deal_id, cast(source_deal_header_id as varchar)) [Reference ID], 
		dbo.FNADateFormat(as_of_date) as [As of Date],
		dbo.FNADateFormat(deal_date) as [Deal Date],
		dbo.FNADateFormat(relationship_effective_date) as [Link Effective Date],
		dbo.FNATRMWinHyperlink(''a'', 10233700, Relationship_Id, ABS(Relationship_Id),null,null,null,null,null,null,null,null,null,null,null,0) [Link ID],
		CAST(CAST (percentage_used AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) as [% Used], 
		description AS Description,
		source_deal_header_id AS [Deal ID]
	' + @str_batch_table + '
	FROM #hedges_lifecycle
	ORDER BY source_deal_header_id, deal_id, dbo.FNAGetSQLStandardDate(as_of_date), sort_order
')
 
/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	EXEC (@str_batch_table)

	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_lifecycle_of_hedges', 'Life Cycle of Hedges') --TODO: modify sp and report name
	EXEC (@str_batch_table)
	RETURN
END
 
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
 
GO