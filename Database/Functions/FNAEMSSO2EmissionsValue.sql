/****** Object:  UserDefinedFunction [dbo].[FNAEMSSO2EmissionsValue]    Script Date: 08/20/2009 12:33:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSSO2EmissionsValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSSO2EmissionsValue]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE  FUNCTION [dbo].[FNAEMSSO2EmissionsValue](
		@curve_id int=null,
		@term_start datetime=null,
		@generator_id int=null,
		@hour int=null
	)
Returns Float
AS
BEGIN

DECLARE @value float,@edr_type_id int,@edr_sub_type_id int
--select @value=sum(ed.edr_value*ed1.edr_value)
--				
--			from 
--					edr_raw_data ed
--					join rec_generator rg on ed.facility_id=rg.[ID] 
--					and ed.sub_type_id=1605 and ed.record_type_code=300	
--					join ems_multiple_source_unit_map esum
--					on esum.generator_id=rg.generator_id  
--					and ed.unit_id=ISNULL(esum.EDR_unit_id,rg.[id2])	
--					join edr_raw_data ed1 on 
--						ed1.facility_id=ed.facility_id
--						and ed1.unit_id=ed.unit_id
--						and ed1.sub_type_id=1600 and ed1.record_type_code=330
--						and ed.edr_date=ed1.edr_date
--						and ed.edr_hour=ed1.edr_hour
--
--			where 1=1
--				  --and curve_id=127 
--				  and ed.edr_date=@term_start
--				  and rg.generator_id=@generator_id 		
--				  and ed.edr_hour=@hour


	select @value=SO2MassEmissionData from edr_calculated_values
		where generator_id=@generator_id
		and term_date=@term_start

	return @value

END





















