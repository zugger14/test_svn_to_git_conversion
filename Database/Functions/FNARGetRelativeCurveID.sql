IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARGetRelativeCurveID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARGetRelativeCurveID]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.FNARGetRelativeCurveID
(
    @source_deal_detail_id	INT
)
RETURNS INT
AS
BEGIN
   DECLARE @relative_curve_id INT, @curve_id INT
   
	SELECT 
		@curve_id = MAX(udddf_pricing_index.udf_value)
	 from  source_deal_detail sdd    
	 INNER JOIN user_defined_deal_detail_fields udddf_pricing_index WITH(NOLOCK) ON  udddf_pricing_index.source_deal_detail_id = sdd.source_deal_detail_id
	 INNER JOIN user_defined_deal_fields_template uddft_pricing_index WITH(NOLOCK) ON uddft_pricing_index.udf_template_id = udddf_pricing_index.udf_template_id
	 WHERE sdd.source_deal_detail_id = @source_deal_detail_id
		AND uddft_pricing_index.Field_type = 'd'
		AND uddft_pricing_index.field_name = 300859 
		
   SELECT 
		@relative_curve_id = MAX(gmv.clm2_value) 
   FROM 
		generic_mapping_values gmv 
   INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
   WHERE gmh.mapping_name = 'Relative Curve Mapping' AND gmv.clm1_value = CAST(@curve_id AS VARCHAR)
      	
   RETURN @relative_curve_id
END