
/****** Object:  UserDefinedFunction [dbo].[FNAEMSInputUOM]    Script Date: 08/20/2009 12:30:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSInputUOM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSInputUOM]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--SELECT dbo.FNAEMSInputUOM('1/1/2005',	23, 25)

CREATE FUNCTION [dbo].[FNAEMSInputUOM](
		@ems_source_input_id int,		
		@ems_gen_input int
	)
Returns varchar(100)
AS
BEGIN

DECLARE @value varchar(100)
DECLARE @input_name varchar(100)

	select @value=su.uom_name, @input_name = ei.input_name
		from ems_source_input ei left outer join
			source_uom su on su.source_uom_id = ei.uom_id
		where	ei.ems_source_input_id=@ems_source_input_id 


	return case when (@value is null OR @input_name is null) then isnull(@value, ' Unknown UOM ') +  isnull(@input_name, ' of Unknown Input/Output ') 
	else ' ' + @value + ' of ' + @input_name end 

END















