/****** Object:  UserDefinedFunction [dbo].[FNAEMSGenerationData]    Script Date: 08/20/2009 12:27:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSGenerationData]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSGenerationData]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSGenerationData]    Script Date: 08/20/2009 12:27:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEMSGenerationData](
		@term_moth datetime,
		@generator_id int,
		@input_id int
	)
Returns Float
AS
BEGIN

DECLARE @value float

	select @value=input_value
		from ems_gen_input ei
		where	
			generator_id=@generator_id	
			and ems_input_id=@input_id
			and term_start=@term_moth

	return ISNULL(@value,0)

END



















