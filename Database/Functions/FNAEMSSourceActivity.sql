/****** Object:  UserDefinedFunction [dbo].[FNAEMSSourceActivity]    Script Date: 06/11/2009 09:10:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSSourceActivity]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSSourceActivity]
/****** Object:  UserDefinedFunction [dbo].[FNAEMSSourceActivity]    Script Date: 06/11/2009 09:10:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [dbo].[FNAEMSSourceEmissionsValue](127,'2007-02-01',3264,14303,1)
-- select [dbo].[FNAEMSSourceInput]('2007-02-01',3264,431,1)

CREATE FUNCTION [dbo].[FNAEMSSourceActivity](
		@term DATETIME,
		@generator_id INT,
		@input_id INT,
		@no_of_month INT

	)

Returns Float
AS
BEGIN

DECLARE @value float
SELECT @term=DATEADD(MONTH,ISNULL(@no_of_month,0)*-1,@term)

	SELECT 
		@value=ISNULL(input_value,0)
	FROM 
		ems_gen_input egi
	WHERE	
		egi.generator_id=@generator_id
		AND ems_input_id=@input_id
		AND term_start=@term

	return @value

END















