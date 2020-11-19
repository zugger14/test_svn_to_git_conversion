
/****** Object:  StoredProcedure [dbo].[spa_insert_template_deal]  ***/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_insert_template_deal]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_insert_template_deal]
GO
/****** Object:  StoredProcedure [dbo].[spa_insert_template_deal] ***/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_insert_template_deal]
	@deal_template_id INT,
	@sub_book INT, 
	@deal_table VARCHAR(500) = '',
	@process_id VARCHAR(100) = NULL

AS

----begin tran
--DECLARE @deal_template_id INT = 211,
--@sub_book INT = '75',
--@process_id VARCHAR(60) = 'F3722A38_167D_4D37_910C_0013D0A7C49F_53638a5ce8d32_1',
--@deal_table VARCHAR(200) = 'adiha_process.dbo.blotter_deal_insert_system_C95BDA6C_61DC_4F54_B14D_4007F223B9EE'

-- SELECT * FROM adiha_process . dbo . blotter_deal_insert_system_1F89CDE6_638F_4991_B2DB_B8511E09DDEB
-- UPDATE adiha_process.dbo.blotter_deal_insert_system_8FBBE00F_3244_4400_8715_7CF5FF3445E9 SET row_id = leg
SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
DECLARE @header_cols VARCHAR(MAX), @header_cols_ignore VARCHAR(MAX), @detail_cols VARCHAR(MAX), @xml_string VARCHAR(MAX), @table_name VARCHAR(200)

SET @table_name = STUFF(@deal_table, 1, 18, '')

CREATE TABLE #xml (xml_string VARCHAR(MAX) COLLATE DATABASE_DEFAULT)

SELECT @header_cols = COALESCE(@header_cols+',' ,'') +  'ISNULL(' + column_name + ', '''') ' + ' AS ' + CASE WHEN column_name = 'leg' THEN 'blotter_value' ELSE CASE WHEN column_name = 'row_id' THEN LOWER(column_name) ELSE  ISNULL(STUFF(LOWER(column_name),1, 2, ''), column_name) END END
FROM adiha_process.INFORMATION_SCHEMA.columns WITH(NOLOCK) WHERE TABLE_NAME = @table_name
AND (STUFF(column_name,3, len(column_name), '') = 'h_' or column_name in ('row_id', 'leg'))
--SELECT @header_cols


SELECT @header_cols_ignore = COALESCE(@header_cols_ignore + ',' ,'') +   STUFF(column_name,1, 2, '') + '= ''__ignore__''' 
FROM adiha_process.INFORMATION_SCHEMA.columns WITH(NOLOCK) WHERE TABLE_NAME = @table_name
AND STUFF(column_name,3, len(column_name), '') = 'h_' and column_name <> 'h_sub_book'
--SELECT @header_cols_ignore


SELECT @detail_cols = COALESCE(@detail_cols+',' ,'') +  'ISNULL(' + column_name + ', '''') ' + ' AS ' + CASE WHEN column_name = 'leg' THEN 'blotter_value' ELSE CASE WHEN column_name = 'row_id' THEN LOWER(column_name) ELSE  ISNULL(STUFF(LOWER(column_name),1, 2, ''), column_name) END END
FROM adiha_process.INFORMATION_SCHEMA.columns WITH(NOLOCK) WHERE TABLE_NAME = @table_name
AND (STUFF(column_name,3, len(column_name), '') = 'd_'or column_name in ('row_id', 'leg'))
--SELECT @detail_cols

INSERT INTO #xml
EXEC ('
SELECT ' + @header_cols + ' INTO #deal_header FROM ' + @deal_table 
+ ' select ' + @detail_cols + ' INTO #deal_detail FROM ' + @deal_table 
+ ' DECLARE @leg1_xml VARCHAR(MAX), @leg2_xml VARCHAR(MAX)

	--select * from #deal_header
	--select * from #deal_detail

	UPDATE #deal_header SET ' + @header_cols_ignore + '	WHERE row_id = 2

	SELECT @leg1_xml = ''<PSRecordset>'' + (
	SELECT * FROM #deal_header WHERE row_id = 1
	FOR XML RAW (''header'')
	) + (
	SELECT * FROM #deal_detail WHERE row_id = 1
	FOR XML RAW (''detail'')
	)
	+ ''</PSRecordset>''

	--select @leg1_xml

	SELECT @leg2_xml = ''<PSRecordset>'' + (
	SELECT * FROM #deal_header WHERE row_id = 2
	FOR XML RAW (''header'')
	) + (
	SELECT * FROM #deal_detail WHERE row_id = 2
	FOR XML RAW (''detail'')
	)
	+ ''</PSRecordset>''

	--select @leg2_xml

	 select ''<Root>'' + @leg1_xml + @leg2_xml + ''</Root>''

')

SELECT @xml_string = xml_string from #xml

EXEC spa_InsertDealXmlBlotterV2 't', @sub_book, @deal_template_id, @xml_string, @process_id


drop table #xml

--rollback
GO
