IF OBJECT_ID(N'[dbo].[spa_update_prorated_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_prorated_volume]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_update_prorated_volume]
    @flag CHAR(1),
	@source_deal_header_ids VARCHAR(MAX)
AS
 
/*---------------Debug Section---------------
DECLARE @flag CHAR(1),
		@source_deal_header_ids VARCHAR(MAX)

SELECT @flag = 'u', @source_deal_header_ids = '10142'
-------------------------------------------*/

DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'u'
BEGIN
    DECLARE @start_daytime DATETIME , @end_daytime DATETIME , @start_time VARCHAR(10), @end_time VARCHAR(10)

	IF OBJECT_ID('tempdb..#temp_alert_deal') IS NOT NULL
		DROP TABLE #temp_alert_deal

	CREATE TABLE #temp_alert_deal (source_deal_header_id INT)

	INSERT INTO #temp_alert_deal(source_deal_header_id)
	SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@source_deal_header_ids) scsv 


	SELECT @start_daytime = sdd.term_start + ISNULL(NULLIF(udddf.udf_value, ''), '8:00') , @start_time = ISNULL(NULLIF(udddf.udf_value, ''), '8:00')
	FROM source_deal_header sdh
	INNER JOIN #temp_alert_deal tmp ON sdh.source_deal_header_id = tmp.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template_main uddft	ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND uddft.udf_template_id = udddf.udf_template_id --and sdh.source_deal_header_id = 59053
		where udft.field_name = -10000152 --'Start Time'

	SELECT @end_daytime = DATEADD(dd, 1,  sdd.term_end) + ISNULL(NULLIF(udddf.udf_value, ''), '8:00'), @end_time  = ISNULL(NULLIF(udddf.udf_value, ''), '8:00')
	FROM source_deal_header sdh
	INNER JOIN #temp_alert_deal tmp ON sdh.source_deal_header_id = tmp.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template_main uddft	ON uddft.template_id = sdh.template_id
	INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
	INNER JOIN user_defined_deal_detail_fields udddf 
		ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		AND uddft.udf_template_id = udddf.udf_template_id 
	WHERE udft.field_name = -10000153 --'End Time'
	
	IF ISNULL(@start_time, '') <> ISNULL(@end_time, '')
	BEGIN
		INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id, udf_value)
		SELECT sdd.source_deal_detail_id,
			   uddft.udf_template_id, 
			   CAST((sdd.deal_volume *24)/DATEDIFF(hh, @start_daytime, @end_daytime) AS INT) udf_value
		FROM source_deal_header sdh
		INNER JOIN #temp_alert_deal tmp ON sdh.source_deal_header_id = tmp.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template_main uddft	ON uddft.template_id = sdh.template_id
		INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
		LEFT JOIN user_defined_deal_detail_fields udddf 
			ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			AND uddft.udf_template_id = udddf.udf_template_id 
		WHERE udft.field_name = -10000154
			AND udddf.udf_deal_id IS NULL
			
		UPDATE udddf
		SET udddf.udf_value = CAST((sdd.deal_volume *24)/DATEDIFF(hh, @start_daytime, @end_daytime) AS INT)	
		FROM source_deal_header sdh
		INNER JOIN #temp_alert_deal tmp ON sdh.source_deal_header_id = tmp.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template_main uddft	ON uddft.template_id = sdh.template_id
		INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
		INNER JOIN user_defined_deal_detail_fields udddf 
			ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			AND uddft.udf_template_id = udddf.udf_template_id 
		WHERE udft.field_name = -10000154
	END
	ELSE
	BEGIN
		UPDATE udddf
		SET udddf.udf_value = NULL
		FROM source_deal_header sdh
		INNER JOIN #temp_alert_deal tmp ON sdh.source_deal_header_id = tmp.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template_main uddft	ON uddft.template_id = sdh.template_id
		INNER JOIN user_defined_fields_template udft ON udft.field_name = uddft.field_name
		INNER JOIN user_defined_deal_detail_fields udddf 
			ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			AND uddft.udf_template_id = udddf.udf_template_id 
		WHERE udft.field_name = -10000154
	END
END