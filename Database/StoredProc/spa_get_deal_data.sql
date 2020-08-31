IF OBJECT_ID(N'[dbo].[spa_get_deal_data]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_get_deal_data

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2016-02-01
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_get_deal_data
	@flag VARCHAR(20),
	@source_deal_header_id INT = NULL,
	@source_deal_detail_id INT = NULL,
	@filter_value VARCHAR(MAX) = NULL,
	@term_frequency VARCHAR(100) = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(1000)
SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag = 'LOCATION'
BEGIN
	SET @sql = 'SELECT DISTINCT sml.source_minor_location_id, sml.location_name
				FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_minor_location sml
						ON sml.source_minor_location_id = sdd.location_id
				WHERE 1 = 1 '
				+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) ELSE '' END
				+ CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(10)) ELSE '' END

				+ ' ORDER BY sml.location_name '
				
	EXEC(@sql)

END

ELSE IF @flag = 'LEG'
BEGIN
	SET @sql = 'SELECT DISTINCT sdd.leg, sdd.leg
				FROM source_deal_detail sdd						
				WHERE 1 = 1 '
				+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) ELSE '' END
				+ CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(10)) ELSE '' END
				+ 'ORDER BY sdd.leg '

	EXEC(@sql)

END
ELSE IF @flag = 'PRIORITY'
BEGIN
	SET @sql =	
				'SELECT DISTINCT sdv.value_id, CAST(code AS INT) code
				FROM source_deal_detail sdd
					INNER JOIN user_defined_deal_detail_fields udddf
						ON sdd.source_deal_detail_id = udddf.source_deal_detail_id
					INNER JOIN user_defined_deal_fields_template  uddft
						ON uddft.udf_template_id = udddf.udf_template_id
					INNER JOIN user_defined_fields_template udft
						ON uddft.field_id = udft.field_id
					INNER JOIN static_data_value sdv
						ON CAST(sdv.value_id AS VARCHAR(5000)) = CAST(udddf.udf_value AS VARCHAR(5000))
						AND sdv.type_id = 32000
				WHERE udft.Field_label = ''Priority'' '
				+ CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) ELSE '' END
				+ CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(10)) ELSE '' END	
				+ ' ORDER BY CAST(code AS INT) 
				'
	EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = 'Select source_deal_header_id, deal_id from source_deal_header sdh'
					
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sdh.source_deal_header_id'
	END
	IF @term_frequency is NOT NULL 
	BEGIN
		SET @sql += ' WHERE sdh.term_frequency = ''' + @term_frequency + ''''
	END
	EXEC(@sql)
END