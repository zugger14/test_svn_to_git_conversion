/****** Object:  UserDefinedFunction [dbo].[FNAEMSWhatIfInput]    Script Date: 06/16/2009 08:55:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSWhatIfInput]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSWhatIfInput]
/****** Object:  UserDefinedFunction [dbo].[FNAEMSWhatIfInput]    Script Date: 06/16/2009 08:56:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAEMSWhatIfInput](
		@criteria_id INT,
		@input_id int,		
		@ems_gen_input_id int=1

	)
Returns Float
AS
BEGIN

DECLARE @value float
DECLARE @generator_id INT
DECLARE @term_start DATETIME
DECLARE @term_end DATETIME
DECLARE @shift_value float
DECLARE @new_value float

	SELECT 
		@generator_id=generator_id,
		@term_start=term_start,
		@term_end=term_end
	FROM
		ems_gen_input ei
	WHERE	
		ems_generator_id=@ems_gen_input_id 				

	SELECT
		@new_value=input_value,
		@shift_value=value_shift
	FROM 
		ems_gen_input_whatif ei
	WHERE	
		generator_id=@generator_id
		AND  term_start=@term_start
		AND  term_end=@term_end
		AND  ems_input_id=@input_id
		AND criteria_id=@criteria_id

	select @value=input_value
		from ems_gen_input ei
		where	ems_generator_id=@ems_gen_input_id 

			
	select @value=input_value
		from ems_gen_input ei
		where	ems_generator_id=@ems_gen_input_id 

	SELECT @value=ISNULL(@new_value,@value)*ISNULL(@shift_value,1)

	return @value

END















