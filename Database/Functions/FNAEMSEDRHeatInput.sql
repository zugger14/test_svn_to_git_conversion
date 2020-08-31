/****** Object:  UserDefinedFunction [dbo].[FNAEMSEDRHeatInput]    Script Date: 08/20/2009 12:24:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSEDRHeatInput]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSEDRHeatInput]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSEDRHeatInput]    Script Date: 08/20/2009 12:24:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSEDRHeatInput](
		@curve_id int=null,
		@term_start datetime=null,
		@generator_id int=null,
		@hour int=null

	)
Returns Float
AS
BEGIN

DECLARE @value float,@edr_type_id int,@edr_sub_type_id int


			

--if exists(select rg.generator_id from 
--				 rec_generator rg inner join ems_multiple_source_unit_map
--				  emsum on 	emsum.generator_id=rg.generator_id	 
--				  inner join (select distinct ORSIPL_ID,unit_id from ems_stack_unit_map)
--								 esum on esum.ORSIPL_ID=rg.[id]
--								 and emsum.EDR_unit_id=esum.unit_id	where rg.generator_id=574)
--	
--select @value=(max(case when ed.unit_id=emsum.EDR_UNIT_ID then ed.edr_value*ed1.edr_value else 0 end)/sum(ed.edr_value*ed1.edr_value))
--				
--			from 
--					edr_raw_data ed
--					join rec_generator rg on ed.facility_id=rg.[ID] 
--					and ed.sub_type_id=1603 and ed.record_type_code=300	
--					left join (select distinct ORSIPL_ID,unit_id from ems_stack_unit_map)
--								 esum on esum.ORSIPL_ID=ed.facility_id
--								 and ed.unit_id=esum.unit_id	
--					join edr_raw_data ed1 on 
--						ed1.facility_id=ed.facility_id
--						and ed1.unit_id=ed.unit_id
--						and ed1.sub_type_id=1605 and ed1.record_type_code=300
--						and ed.edr_date=ed1.edr_date
--						and ed.edr_hour=ed1.edr_hour
--					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
--
--			where 1=1
--				  --and curve_id=127 
--				  and ed.edr_date=@term_start
--				  and rg.generator_id=@generator_id 		
--				  and ed.edr_hour=@hour
--else
--	
--select @value=ed.edr_value*ed1.edr_value
--				
--			from 
--					edr_raw_data ed
--					join rec_generator rg on ed.facility_id=rg.[ID] 
--					and ed.sub_type_id=1603 and ed.record_type_code=300	
--					join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
--					and emsum.EDR_UNIT_ID=ed.unit_id
--					join edr_raw_data ed1 on 
--						ed1.facility_id=ed.facility_id
--						and ed1.unit_id=ed.unit_id
--						and ed1.sub_type_id=1605 and ed1.record_type_code=300
--						and ed.edr_date=ed1.edr_date
--						and ed.edr_hour=ed1.edr_hour
--
--			where 1=1
--				  --and curve_id=127 
--				  and ed.edr_date=@term_start
--				  and rg.generator_id=@generator_id 		
--				  and ed.edr_hour=@hour

	select @value=heatinputvalue from edr_calculated_values
		where generator_id=@generator_id
		and term_date=@term_start


	return @value

END




















