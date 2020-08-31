if object_id('[FNARUDFDetailValue]') is not null
drop function dbo.[FNARUDFDetailValue]
GO
create  FUNCTION [dbo].[FNARUDFDetailValue](
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


	BEGIN
		SELECT 
			@udf_value=udf_value
				FROM
					user_defined_deal_detail_fields uddf
					JOIN user_defined_deal_fields_template uddfp on uddfp.udf_template_id=uddf.udf_template_id
					
				WHERE
					 uddf.source_deal_detail_Id=@deal_id	
					 AND uddfp.[field_id]=@udf_Charge_type
	END


		SELECT @total_charge=(CASE ISNUMERIC(@udf_value) WHEN 1 THEN  CAST(@udf_value aS FLOAT) ELSE CAST( 0 AS FLOAT) END)

	RETURN ISNULL(@total_charge,0)
END


 
/************************************* Object: 'FNARUDFDetailValue' END *************************************/

