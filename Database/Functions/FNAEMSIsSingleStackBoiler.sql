/****** Object:  UserDefinedFunction [dbo].[FNAEMSIsSingleStackBoiler]    Script Date: 08/20/2009 12:32:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSIsSingleStackBoiler]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSIsSingleStackBoiler]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




-- select dbo.FNAEMSEDRHeatInput(127,'2006-01-01',958,1)

CREATE FUNCTION [dbo].[FNAEMSIsSingleStackBoiler](
		@curve_id int=null,
		@term_start datetime=null,
		@generator_id int=null,
		@hour int=null

	)
Returns Float
AS
BEGIN

DECLARE @value float

if exists(select rg.generator_id from 
				   ems_stack_unit_map esum inner join  
					rec_generator rg on rg.[ID]=esum.ORSIPL_ID
					inner join ems_multiple_source_unit_map emsum on emsum.generator_id=rg.generator_id
					and esum.unit_id=emsum.EDR_Unit_ID
			where rg.generator_id=@generator_id)
	set @value=1 
else 
	set @value=0


return @value
END





















