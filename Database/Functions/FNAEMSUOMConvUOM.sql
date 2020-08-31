/****** Object:  UserDefinedFunction [dbo].[FNAEMSUOMConvUOM]    Script Date: 08/20/2009 12:34:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSUOMConvUOM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSUOMConvUOM]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



-- select dbo.FNAEMSUOMConvUOM (24, 29)

CREATE FUNCTION [dbo].[FNAEMSUOMConvUOM]
	(@from_uom_id int,
	 @to_uom_id int	
)
RETURNS varchar(100) AS  
BEGIN 
DECLARE @value varchar(100)

DECLARE @value_from varchar(100)

	select @value=su.uom_name
		from source_uom su where su.source_uom_id = @to_uom_id
		
	select @value_from =su.uom_name
		from source_uom su where su.source_uom_id = @from_uom_id

	return case when (@value is null OR @value_from is null) then ' Unknown UOM' else ' ' + @value + '/' + @value_from end 
END









