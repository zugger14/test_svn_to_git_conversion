IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_tagging_audit_report]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_create_tagging_audit_report]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_create_tagging_audit_report]
	@subsidiary_id VARCHAR(MAX),
	@strategy_id VARCHAR(MAX) = NULL,
	@book_id VARCHAR(MAX) = NULL,
	@as_of_date_from VARCHAR(100) = NULL,
	@as_of_date_to VARCHAR(100) = NULL,
	@source_system_book_id1 INT = NULL,
	@source_system_book_id2 INT = NULL,
	@source_system_book_id3 INT = NULL,
	@source_system_book_id4 INT = NULL,
	@deal_id_from INT = NULL,
	@deal_id_to INT = NULL,
	@source_deal_id VARCHAR(200) = NULL,
	@counterparty_id VARCHAR(MAX) = NULL,
	@audit_user VARCHAR(100) = NULL,
	@use_create_date char(1) = 'n',
	@comments VARCHAR(500) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL
AS

SET NOCOUNT ON

BEGIN
	DECLARE @str_batch_table VARCHAR(MAX)
	DECLARE @report_name VARCHAR(100)
	DECLARE @sql_Select VARCHAR(MAX)
	DECLARE @sql_Select1 VARCHAR(MAX)
	DECLARE @group1 VARCHAR(100)
	DECLARE @group2 VARCHAR(100)
	DECLARE @group3 VARCHAR(100)
	DECLARE @group4 VARCHAR(100)

	SET @str_batch_table = ''
	IF @batch_process_id IS NOT NULL
	BEGIN
		SELECT @str_batch_table=dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)
		SET @str_batch_table = @str_batch_table
	END

	-- Get Group Label
	IF EXISTS(SELECT 1 FROM source_book_mapping_clm)
	BEGIN
		SELECT @group1 = group1,
			@group2 = group2,
			@group3 = group3,
			@group4 = group4
		FROM source_book_mapping_clm
	END
	ELSE
	BEGIN
		SET @group1 = 'Group1'
		SET @group2 = 'Group2'
		SET @group3 = 'Group3'
		SET @group4 = 'Group4'
	END

	SET @sql_Select = '
		SELECT * ' + @str_batch_table +  '
		FROM ('

	SET @sql_Select = @sql_Select + '
		SELECT '
	IF @str_batch_table IS NOT NULL
		SET @sql_Select = @sql_Select + ' sDH.source_deal_header_id AS [Deal ID], '
	ELSE
		SET @sql_Select = @sql_Select + ' dbo.FNAHyperLinkText(10131010, sDH.source_deal_header_id, sDH.source_deal_header_id) AS [Deal ID], '
		
	SET @sql_Select = @sql_Select + '
			sdh.deal_id as [Reference ID],
			sb1.source_book_name AS ['+ @group1 +'],
            sb2.source_book_name AS ['+ @group2 +'],
			sb3.source_book_name AS ['+ @group3 +'],
            sb4.source_book_name AS ['+ @group4 +'],
			dbo.FNADateFormat(sDH.deal_date) AS [Deal Date],
			sc.counterparty_name [Counterparty],
			ssd.source_system_name [Source System],
			dta.change_reason [Comments],
			dta.create_user [Updated By],
			dbo.FNADateTimeFormat(dta.create_ts, 1) [Timestamp]
		FROM source_deal_header sdh
		INNER JOIN deal_tagging_audit dta ON dta.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_system_book_map ssbm ON dta.source_system_book_id1 = ssbm.source_system_book_id1
			AND dta.source_system_book_id2 = ssbm.source_system_book_id2
			AND dta.source_system_book_id3 = ssbm.source_system_book_id3
			AND dta.source_system_book_id4 = ssbm.source_system_book_id4
		LEFT OUTER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
		LEFT OUTER JOIN source_book sb4 ON dta.source_system_book_id4 = sb4.source_book_id
		LEFT OUTER JOIN source_book sb3 ON dta.source_system_book_id3 = sb3.source_book_id
		LEFT OUTER JOIN source_book sb2 ON dta.source_system_book_id2 = sb2.source_book_id
		LEFT OUTER JOIN source_book sb1 ON dta.source_system_book_id1 = sb1.source_book_id
		LEFT OUTER JOIN source_system_description ssd ON ssd.source_system_id=sdh.source_system_id
		LEFT JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id
		LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id
		LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
		LEFT JOIN fas_strategy fs ON fs.fas_strategy_id = stra.entity_id ' +'
		WHERE 1 = 1 ' +
		CASE WHEN @source_deal_id IS NOT NULL THEN ' AND sdh.deal_id = ''' + @source_deal_id + '''' ELSE '' END +
		CASE WHEN @source_system_book_id1 IS NOT NULL THEN ' AND sdh.source_system_book_id1 = ' + CAST(@source_system_book_id1 AS VARCHAR) ELSE '' END +
		CASE WHEN @source_system_book_id2 IS NOT NULL THEN ' AND sdh.source_system_book_id2 = ' + CAST(@source_system_book_id2 AS VARCHAR) ELSE '' END +
		CASE WHEN @source_system_book_id3 is not null then ' AND sdh.source_system_book_id3 = ' + CAST(@source_system_book_id3 AS VARCHAR) ELSE '' END +
		CASE WHEN @source_system_book_id4 is not null then ' AND sdh.source_system_book_id4 = ' + CAST(@source_system_book_id4 AS VARCHAR) ELSE '' END +
		CASE 
			WHEN (@as_of_date_from IS NOT NULL) AND (@as_of_date_to IS NOT NULL) THEN
				CASE
					WHEN @use_create_date = 'y' THEN ' AND dbo.FNAConvertTZAwareDateFormat(dta.update_ts, 1) BETWEEN '''
					ELSE ' AND sdh.deal_date BETWEEN ''' 
				END + @as_of_date_from + ''' AND ''' + @as_of_date_to + ''''
			WHEN (@as_of_date_from IS NULL) AND (@as_of_date_to IS NOT NULL) THEN
				CASE
					WHEN @use_create_date = 'y' THEN ' AND dbo.FNAConvertTZAwareDateFormat(dta.update_ts, 1) <= '''
					ELSE ' AND sdh.deal_date <= '''
				END + @as_of_date_to + ''''
			ELSE ''
		END +
		/*+ case when (@as_of_date_from IS NOT NULL) AND (@as_of_date_to IS NOT NULL) then case when @use_create_date='y' then ' AND dbo.FNAGetSQLStandardDate(dta.update_ts)  BETWEEN ''' else ' AND sdh.deal_date  BETWEEN ''' end + @as_of_date_from + '''  and ''' + @as_of_date_to + '''' 
				when (@as_of_date_from IS NULL) AND (@as_of_date_to IS NOT NULL)	then case when @use_create_date='y' then ' AND dbo.FNAGetSQLStandardDate(dta.update_ts) <=''' else ' AND sdh.deal_date <=''' end + @as_of_date_to +'''' else '' end
		*/
		CASE WHEN (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) THEN ' AND sDH.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) + ' AND ' + CAST(@deal_id_to AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @deal_id_from IS NOT NULL THEN ' AND sdh.source_deal_header_id >= ' + CAST(@deal_id_from AS VARCHAR(20)) ELSE '' END +
		CASE WHEN @deal_id_to IS NOT NULL THEN ' AND sdh.source_deal_header_id <= ' + CAST(@deal_id_to AS VARCHAR(20)) ELSE '' END +
		CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR) + ')'  ELSE '' END +
		CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND (sub.entity_id IN (' + @subsidiary_id + ') OR sub.entity_id IS NULL) ' ELSE '' END +
		CASE WHEN @strategy_id IS NOT NULL THEN ' AND (stra.entity_id IN (' + @strategy_id + ') OR stra.entity_id IS NULL) ' ELSE '' END +
		CASE WHEN @book_id IS NOT NULL THEN ' AND (ssbm.fas_book_id IN (' + @book_id + ') OR book.entity_id IS NULL)' ELSE '' END +
		CASE WHEN @audit_user IS NOT NULL THEN ' AND dta.create_user = ''' + @audit_user + '''' ELSE '' END	+
		CASE WHEN @comments IS NOT NULL THEN ' AND change_reason LIKE ''%' + @comments + '%''' ELSE '' END

	SET @sql_Select1 = '
	)a
	ORDER BY [Deal ID], [Timestamp]'
		--			'
		--		UNION
		--		SELECT 
		--			dbo.FNAHyperLinkText(120, sDH.source_deal_header_id, sDH.source_deal_header_id) AS DealID, 
		--			sdh.deal_id as SourceDealID,
		--			sb1.source_book_name AS ['+ @group1 +'], 
		--            sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
		--            sb4.source_book_name AS ['+ @group4 +'], 
		--			dbo.FNADateFormat(sDH.deal_date) as DealDate, 
		--			sc.counterparty_name [Counterparty], 
		--			ssd.source_system_name [Source System],
		--			NULL as  [Comments],
		--			sDH.update_user [Updated By],
		--			sDH.update_ts as [Timestamp]			
		--			'+
		--		' FROM 
		--						  source_deal_header sDH left JOIN
		--	                      source_system_book_map sSBM ON sDH.source_system_book_id1 = sSBM.source_system_book_id1 AND 
		--	                      sDH.source_system_book_id2 = sSBM.source_system_book_id2 
		--						  AND sDH.source_system_book_id3 = sSBM.source_system_book_id3 AND 
		--	                      sDH.source_system_book_id4 = sSBM.source_system_book_id4 LEFT OUTER JOIN
		--	                      source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id LEFT OUTER JOIN
		--	                      source_book sb4 ON sDH.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
		--	                      source_book sb3 ON sDH.source_system_book_id3 = sb3.source_book_id LEFT OUTER JOIN
		--	                      source_book sb2 ON sDH.source_system_book_id2 = sb2.source_book_id LEFT OUTER JOIN
		--	                      source_book sb1 ON sDH.source_system_book_id1 = sb1.source_book_id LEFT OUTER JOIN
		--						  source_system_description ssd on ssd.source_system_id=sdh.source_system_id left join
		--						  portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id left join
		--						  portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id left join
		--						  portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id left join
		--						  fas_strategy fs on fs.fas_strategy_id = stra.entity_id '
		--		+' Where 1=1 '
		--					+ case when @source_deal_id is not null then ' AND sdh.source_deal_header_id='+cast(@source_deal_id as varchar) else '' end
		--                    + case when @source_system_book_id1 is not null then ' AND sdh.source_system_book_id1='+cast(@source_system_book_id1 as varchar) else '' end
		--					+ case when @source_system_book_id2 is not null then ' AND sdh.source_system_book_id2='+cast(@source_system_book_id2 as varchar) else '' end
		--					+ case when @source_system_book_id3 is not null then ' AND sdh.source_system_book_id3='+cast(@source_system_book_id3 as varchar) else '' end
		--					+ case when @source_system_book_id4 is not null then ' AND sdh.source_system_book_id4='+cast(@source_system_book_id4 as varchar) else '' end
		--					+ case when (@as_of_date_from IS NOT NULL) AND (@as_of_date_to IS NOT NULL) then case when @use_create_date='y' then ' AND  dbo.fnadateformat(sDH.update_ts) BETWEEN ''' else ' AND  sDH.deal_date BETWEEN ''' end + @as_of_date_from + ''' and ''' + @as_of_date_to + '''' 
		--						   when (@as_of_date_from IS NULL) AND (@as_of_date_to IS NOT NULL)	then case when @use_create_date='y' then  ' AND fnadateformat(sDH.update_ts) <=''' else   ' AND sdh.deal_date <='''end + @as_of_date_to +'''' else '' end
		--					+ case when (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) then ' AND sDH.source_deal_header_id BETWEEN '+ cast(@deal_id_from as varchar)+ ' and '+ cast(@deal_id_to as varchar)+ '' else '' end
		--					+ case when @counterparty_id is not null then ' And sdh.counterparty_id='+cast(@counterparty_id as varchar)  else '' end	
		--					+ case when (@subsidiary_id is not null) THEN  ' and (sub.entity_id IN (' + @subsidiary_id + ') or sub.entity_id is null)' else '' end 
		--					+ case when (@strategy_id is not null) THEN  ' and (stra.entity_id IN (' + @strategy_id + ') or stra.entity_id is null) ' else '' end  
		--					+ case when (@book_id is not null) THEN  ' and (ssbm.fas_book_id IN (' + @book_id + ') or ssbm.entity_id is null) ' else '' end 
		--					+ case when @audit_user is not null then ' And sDH.create_user='''+@audit_user+''''  else '' end
	
	-- PRINT @sql_Select + @sql_Select1
	EXEC(@sql_Select + @sql_Select1)
END

--*****************FOR BATCH PROCESSING**********************************            
IF @batch_process_id IS NOT NULL
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	EXEC(@str_batch_table)

	SET @report_name='Tagging Audit Report'
        
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_tagging_audit_report', @report_name)
	EXEC(@str_batch_table)
END
--********************************************************************

GO