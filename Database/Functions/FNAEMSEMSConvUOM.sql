/****** Object:  UserDefinedFunction [dbo].[FNAEMSEMSConvUOM]    Script Date: 08/20/2009 12:27:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSEMSConvUOM]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSEMSConvUOM]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSEMSConvUOM]    Script Date: 08/20/2009 12:27:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSEMSConvUOM](
		@curve_id int,
		@generator_id int,
		@term_start datetime,
		@ems_source_input_id int,
		@conversion_type int,
		@char1 int,
		@char2 int,
		@char3 int,
		@char4 int,
		@char5 int,
		@char6 int,
		@char7 int,
		@char8 int,
		@char9 int,
		@char10 int,
		@from_uom_id int,
		@to_uom_id int,
		@conv_source int
		)
Returns varchar(100)
AS
BEGIN
DECLARE @value varchar(100)
DECLARE @value_from varchar(100)


	select @value=su.uom_name
		from source_uom su where su.source_uom_id = @to_uom_id

	select @value_from=su.uom_name
		from source_uom su where su.source_uom_id = @from_uom_id

		
	return case when (@value is null OR @value_from is null) then ' Unknown UOM' else ' ' + @value + '/' + @value_from end 

END


