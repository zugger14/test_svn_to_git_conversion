/****** Object:  UserDefinedFunction [dbo].[FNAEMSEDRValue]    Script Date: 08/20/2009 12:52:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSEDRValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSEDRValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSEDRValue]    Script Date: 08/20/2009 12:52:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSEDRValue](
		@curve_id int=null,
		@term_start datetime=null,
		@generator_id int=null,
		@hour int=null,
		@edr_type_id int,
		@edr_sub_type_id int
	)
Returns Float
AS
BEGIN

DECLARE @value float

	/*
	If @edr_input_id=1600
	begin
	select @value=volume from emissions_inventory_edr
				  where curve_id=127 and term_start=@term_start
				  and generator_id=@generator_id and @edr_input_id=1600	
				   	
	end
	else If @edr_input_id=1605
	begin
	select @value=0.570000
	end
	else If @edr_input_id=1608
	begin
	select @value=volume from emissions_inventory_edr
				  where curve_id=127 and term_start=@term_start
				  and generator_id=@generator_id --and @edr_input_id=1600	

	end
	*/

		select @value=edr_value
			from 
					edr_raw_data ed
					join rec_generator rg on ed.facility_id=rg.[ID]
					and ed.unit_id=rg.[ems_source_model_id]
			where 1=1
				  --and curve_id=127 
				  and ed.edr_date=@term_start
				  and rg.generator_id=@generator_id and ed.sub_type_id=@edr_sub_type_id
				  and ed.record_type_code=@edr_type_id		
				  and edr_hour=@hour
	

	return @value

END

















