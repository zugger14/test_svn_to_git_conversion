IF OBJECT_ID(N'dbo.spa_delete_duplicate_transfer_adjust') IS NOT NULL
    DROP PROCEDURE dbo.[spa_delete_duplicate_transfer_adjust]
GO
 
SET ANSI_NULLS ON
GO

 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Deletes duplicate transport created by transfer adjust.

	Parameters 
	@source_deal_header_id: source deal
*/


CREATE PROCEDURE [dbo].[spa_delete_duplicate_transfer_adjust]
	@source_deal_header_id INT

AS


CREATE TABLE #temp_trans_deal (
	source_deal_header_id INT 
)



INSERT INTO #temp_trans_deal(source_deal_header_id)
SELECT DISTINCT sdh.source_deal_header_id
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd
    ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER  JOIN user_defined_deal_fields uddf
    ON sdd.source_deal_header_id = uddf.source_deal_header_id
INNER JOIN user_defined_deal_fields_template uddft
    ON uddft.udf_template_id = uddf.udf_template_id
INNER JOIN user_defined_fields_template udft
    ON udft.field_id = uddft.field_id
WHERE udft.field_label = 'From Deal'
	AND uddf.udf_value = CAST(@source_deal_header_id as VARCHAR(30))


SELECT *
INTO #temp_multiple_deals
FROM  
(
  
	SELECT  sdh.source_deal_header_id, udft.Field_label, uddf.udf_value , sdh.contract_id, sdh.internal_portfolio_id, sdh.entire_term_start, sdh.entire_term_end
	FROM #temp_trans_deal ttd
	INNER JOIN source_deal_header sdh
		ON ttd.source_deal_header_id = sdh.source_deal_header_id
	INNER  JOIN user_defined_deal_fields uddf
		ON sdh.source_deal_header_id = uddf.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft
		ON uddft.udf_template_id = uddf.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON udft.field_id = uddft.field_id
	WHERE udft.field_label in ('From Deal', 'Delivery Path')
) AS SourceTable  
PIVOT  
(  
  MIN(udf_value)  
  FOR Field_label IN ([From Deal], [Delivery Path]) 
) AS PivotTable;  



DECLARE @source_deal_header_ids VARCHAR(1000)

SELECT @source_deal_header_ids = ISNULL( @source_deal_header_ids + ',', '') + CAST(tmd.source_deal_header_id as VARCHAR(30))
FROM #temp_multiple_deals tmd
INNER JOIN source_deal_header sdh
	ON tmd.source_deal_header_id = sdh.source_deal_header_id
OUTER APPLY (
	SELECT 
		contract_id
		, internal_portfolio_id
		, entire_term_start
		, entire_term_end
		, [from deal]
		, [Delivery Path]
		, MIN(source_deal_header_id)  source_deal_header_id
	FROM  #temp_multiple_deals t
	WHERE tmd.contract_id = t.contract_id
		AND tmd.internal_portfolio_id = t.internal_portfolio_id
		AND tmd.entire_term_start = t.entire_term_start
		AND tmd.entire_term_end =  t.entire_term_end
		AND tmd.[from deal] = t.[from deal]
		AND tmd.[Delivery Path] = t.[Delivery Path]
	GROUP BY contract_id, internal_portfolio_id, entire_term_start, entire_term_end, [from deal], [Delivery Path]

) sub
WHERE tmd.source_deal_header_id <> sub.source_deal_header_id

IF @source_deal_header_ids IS NOT NULL
BEGIN
	EXEC spa_source_deal_header  @flag='d', @deal_ids = @source_deal_header_ids, @comments='Duplicate transfer deals automatically deleted.'
		
	DECLARE @after_insert_process_table VARCHAR(500)
			, @sql VARCHAR(MAX)
			, @user_name NVARCHAR(100) = dbo.FNADBUser()
			, @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()

	SET @after_insert_process_table = dbo.FNAProcessTableName('transport_table', @user_name, @job_process_id)
		
	EXEC ('CREATE TABLE ' + @after_insert_process_table + '(source_deal_header_id INT)')

	SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id) 
				SELECT 
					MIN(source_deal_header_id)  source_deal_header_id
				FROM  #temp_multiple_deals t
				GROUP BY contract_id, internal_portfolio_id, entire_term_start, entire_term_end, [from deal], [Delivery Path]
				'
	EXEC(@sql)

	exec ('SELECT * FROM ' + @after_insert_process_table )

	EXEC spa_deal_insert_update_jobs 'i', @after_insert_process_table
END



