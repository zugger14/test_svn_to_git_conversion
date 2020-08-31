/****** Object:  UserDefinedFunction [dbo].[FNAEMSInput]    Script Date: 08/20/2009 12:28:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSInput]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSInput]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAEMSInput]    Script Date: 08/20/2009 12:28:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEMSInput](
		@generator_id INT,
		@term_date DATETIME,
		@char1 INT,
		@char2 INT,
		@char3 INT,
		@char4 INT,
		@char5 INT,
		@char6 INT,
		@char7 INT,
		@char8 INT,
		@char9 INT,
		@char10 INT,
		@input_id int
	)
Returns Float
AS
BEGIN

DECLARE @value float

		SELECT @value=input_value
		FROM 
			ems_gen_input ei
		WHERE	
			generator_id=@generator_id
			AND term_start = @term_date
			AND ems_input_id = @input_id
			AND ISNULL(char1 ,-1)=ISNULL(@char1,-1)
			AND ISNULL(char2 ,-1)=ISNULL(@char2,-1)
			AND ISNULL(char3 ,-1)=ISNULL(@char3,-1)
			AND ISNULL(char4 ,-1)=ISNULL(@char4,-1)
			AND ISNULL(char5 ,-1)=ISNULL(@char5,-1)
			AND ISNULL(char6 ,-1)=ISNULL(@char6,-1)
			AND ISNULL(char7 ,-1)=ISNULL(@char7,-1)
			AND ISNULL(char8 ,-1)=ISNULL(@char8,-1)
			AND ISNULL(char9 ,-1)=ISNULL(@char9,-1)
			AND ISNULL(char10 ,-1)=ISNULL(@char10,-1)

	return @value

END


















