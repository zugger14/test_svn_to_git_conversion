/**
this function is especially used to parse parameter values which are used on IN operator for text fields when data itself contains ','.
For e.g. default parameter value for block_description might be [a,b],c,d,[xyz,k], where we need to build IN clause as: IN ('[a,b]','c','d','[xyz,k]')

**/
/****** Object:  UserDefinedFunction [dbo].[FNARFXParseComplexParameterValues]   ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARFXParseComplexParameterValues]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFXParseComplexParameterValues]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].FNARFXParseComplexParameterValues(
	@parameter_value		VARCHAR(MAX)
)
--   select dbo.FNARFXParseComplexParameterValues('[b,all],[ae,z,bcg],c,[e,f],g')
RETURNS VARCHAR(MAX)
AS
begin
	--declare @parameter_value varchar(500) = '[b,all],[ae,z,bcg],c,[e,f],g' --select len('[ae,z,bcg],c,[e,f],g')
	declare @final_str varchar(5000) =''
	declare @i int = 1
	declare @section_bb int = 0

	--if not complex(data having ,), simply return values wrapping with single quote and replacing , to !
	if @parameter_value is null
	begin
		set @final_str = '''NULL'''
	end
	else if(CHARINDEX('[',@parameter_value) = 0) 
	begin
		set @final_str = '''' + REPLACE(@parameter_value,'!','''!''') + ''''
	end
	--else handle data comma and identify it as _-_
	else
	begin
		while @i <= len(@parameter_value)
		begin
		
			if(right(left(@parameter_value,@i),1) = '[')
				set @section_bb = 1
			else if (right(left(@parameter_value,@i),1) = ']')
				set @section_bb = 0

			set @final_str += replace(right(left(@parameter_value,@i),1), '!', iif(@section_bb = 0 ,'!' ,'_-_' ))

			set @i += 1
		end
		set @final_str = '''' + REPLACE(@final_str,'!','''!''') + ''''
	end
	return @final_str
end
--'[a,b],c,[e,f],g' = '[a#b]!c![e#f]!g'