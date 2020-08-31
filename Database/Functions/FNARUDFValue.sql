/****** Object:  UserDefinedFunction [dbo].[FNARUDFValue]    Script Date: 12/11/2010 23:12:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARUDFValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARUDFValue]
/****** Object:  UserDefinedFunction [dbo].[FNARUDFValue]    Script Date: 12/11/2010 23:07:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 /**
	Function to return UDF value defined in UDF of deal

	Parameters 
	@deal_id : Source Deal Header Id
	@granularity : Granularity
	@maturity_date : Maturity Date
	@as_of_date : As Of Date
	@he : Hour
	@half : minutes
	@qtr : Quarter
	@counterparty_id : Counterparty Id
	@contract_id : Contract Id
	@audit_date : Audit Date
	@deal_price_type_id : Deal Price Type Id
	@udf_Charge_type : Udf Charge Type used in deal
	Returns value
*/

CREATE FUNCTION [dbo].[FNARUDFValue](
	@deal_id int, -- if -ve  @deal_id then source_deal_detail_id else source_deal_header_id
	@granularity INT,
	@maturity_date varchar(20),
	@as_of_date varchar(20), 
	@he int,
	@half int,
	@qtr int,
	@counterparty_id INT,
	@contract_id INT,
	@audit_date datetime,
	@deal_price_type_id INT,
	@udf_Charge_type INT
)

RETURNS FLOAT AS
BEGIN

--declare @deal_id int=-6730, -- if -ve  @deal_id then source_deal_detail_id else source_deal_header_id
--	@granularity INT=980,
--	@maturity_date varchar(20)='2018-05-01',
--	@as_of_date varchar(20)='2018-05-31', 
--	@he int,
--	@half int,
--	@qtr int,
--	@counterparty_id INT,
--	@contract_id INT,
--	@audit_date datetime,
--	@udf_Charge_type INT=50000029
-- @deal_price_type_id INT
	--select dbo.FNARUDFValue(-6730,980,'2018-05-01','2018-05-31',null,null,null,null,null,null,50000029)

	DECLARE @total_charge VARCHAR(100)
	DECLARE @udf_value VARCHAR(100)
	DECLARE @source_curve_def_id INT
	--set @source_deal_header_id = 1477 -- 1478
	--set @source_price_curve = 'source_price_curve'

	--IF EXISTS(SELECT 1 FROM user_defined_deal_fields_template uddfp where uddfp.[field_id]=@udf_Charge_type AND uddfp.udf_type='h')
	--	IF @deal_id<0
	--		SELECT @deal_id=source_deal_header_Id FROM source_deal_detail WHERE source_deal_detail_Id=ABS(@deal_id)
	
	
	if @audit_date is not null
	BEGIN
		IF EXISTS(SELECT 1 FROM user_defined_deal_fields_template uddfp where uddfp.[field_id]=@udf_Charge_type AND uddfp.udf_type='h')
			SELECT @udf_value=udf_value
			from ( select top 1 udf_value FROM	user_defined_deal_fields_audit uddf
			inner JOIN user_defined_deal_fields_template uddfp on uddfp.udf_template_id=uddf.udf_template_id
				and convert(varchar(10),uddf.update_ts,120)<=@audit_date 
				and  uddf.source_deal_header_Id=@deal_id	 AND uddfp.udf_type='h'
					 AND uddfp.[field_id]=@udf_Charge_type
			 order by uddf.create_ts DESC
			) a
		ELSE
			SELECT @udf_value=udf_value
			from ( select top 1 udf_value FROM	user_defined_deal_detail_fields_audit uddf
			inner JOIN user_defined_deal_fields_template uddfp on uddfp.udf_template_id=uddf.udf_template_id
				and convert(varchar(10),uddf.update_ts,120)<=@audit_date 
				and  uddf.source_deal_detail_Id=abs(@deal_id) AND uddfp.udf_type='d'
					 AND uddfp.[field_id]=@udf_Charge_type
			 order by uddf.create_ts DESC
			) a
	END 
	if @udf_value is null
	BEGIN 
		--IF EXISTS(SELECT 1 FROM user_defined_deal_fields_template uddfp where uddfp.[field_id]=@udf_Charge_type AND uddfp.udf_type='h')

			SELECT @udf_value=uddf.udf_value
			FROM 		user_defined_deal_fields_template uddfp
				INNER JOIN  user_defined_deal_fields uddf on
						 uddfp.udf_template_id=uddf.udf_template_id AND uddfp.udf_type='h'
				and uddf.source_deal_header_id=@deal_id AND uddfp.[field_id]=@udf_Charge_type

		if NULLIF(@udf_value,'0') is null
			SELECT top(1) @udf_value= 
			 coalesce(ddfu.udf_value, dpa.udf_value,udddf.udf_value)
			FROM 		user_defined_deal_fields_template uddfp --where uddfp.[field_id]=50000029
				left join user_defined_deal_detail_fields udddf on uddfp.udf_template_id=udddf.udf_template_id -- AND uddfp.udf_type='d'
					and udddf.source_deal_detail_id =abs(@deal_id) 
				left join deal_price_adjustment dpa on dpa.source_deal_detail_id = abs(@deal_id)
					AND dpa.udf_template_id=uddfp.udf_user_field_id 
					--and dpa.deal_price_type_id=@deal_price_type_id
				left join deal_detail_formula_udf ddfu on ddfu.source_deal_detail_id = abs(@deal_id)
					AND ddfu.udf_template_id=uddfp.udf_user_field_id 
					--and ddfu.deal_price_type_id=@deal_price_type_id
				where coalesce(ddfu.udf_value, dpa.udf_value,udddf.udf_value) is not null
				and 	uddfp.[field_id]=@udf_Charge_type

				

	END 

	--select @udf_value

	SELECT @total_charge=CASE ISNUMERIC(@udf_value) WHEN 1 THEN  @udf_value ELSE '0' END

	return @total_charge --RETURN ISNULL(@total_charge,0)
END


 
/************************************* Object: 'FNARUDFValue' END *************************************/

