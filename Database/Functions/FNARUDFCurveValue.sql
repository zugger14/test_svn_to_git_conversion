/****** Object:  UserDefinedFunction [dbo].[FNARUDFValue]    Script Date: 12/11/2010 23:12:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARUDFCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARUDFCurveValue]
/****** Object:  UserDefinedFunction [dbo].[FNARUDFValue]    Script Date: 12/11/2010 23:07:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARUDFCurveValue](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@maturity_date varchar(20),
	@as_of_date varchar(20), 
	@udf_Charge_type INT
)

RETURNS FLOAT AS
BEGIN


DECLARE @total_charge VARCHAR(100)
DECLARE @udf_value VARCHAR(100)
DECLARE @source_curve_def_id INT
--set @source_deal_header_id = 1477 -- 1478
--set @source_price_curve = 'source_price_curve'

	SELECT 
		@udf_value=udf_value
			FROM
				user_defined_deal_fields uddf
				JOIN source_deal_header sdh on sdh.source_deal_header_id=uddf.source_deal_header_id
				JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
					AND sdd.source_deal_detail_id=@deal_id 	
				JOIN user_defined_deal_fields_template uddfp on uddfp.udf_template_id=uddf.udf_template_id
				AND uddfp.[field_id]=@udf_Charge_type

	 

	SELECT 
		@total_charge = curve_value 
	FROM 
		source_price_curve
	where 	
		source_curve_def_id = @udf_value
		AND as_of_date = @as_of_date
		AND assessment_curve_type_value_id in (77,78) 
		AND curve_source_value_id = 4500
		AND maturity_date = @maturity_date
		

	RETURN @total_charge
END


 