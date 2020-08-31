IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIsHoliday]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIsHoliday]
/****** Object:  UserDefinedFunction [dbo].[FNARIsHoliday]    Script Date: 07/23/2009 01:08:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.FNARIsHoliday(518,'2009-05-1')

CREATE FUNCTION [dbo].[FNARIsHoliday](
	@contract_id INT = NULL,
	@prod_date varchar(20),
	@calendar_type Varchar(100)=NULL
)

RETURNS INT AS
BEGIN

DECLARE @value INT,@default_holiday_calendar VARCHAR(100)

IF isnull(@calendar_type,'') = ''
	BEGIN
		SELECT @default_holiday_calendar = calendar_desc FROM default_holiday_calendar
	END
ELSE 
	BEGIN
		SELECT @default_holiday_calendar = @calendar_type
	END
	
IF NULLIF(@contract_id,0) IS NOT NULL
BEGIN
	select @value=CASE WHEN hc.hol_date =@prod_date THEN 1 ELSE 0 END
	from contract_group cg LEFT join
		  hourly_block hb ON hb.block_value_id = cg.hourly_block LEFT join
		  holiday_group hc ON hc.hol_group_value_id = ISNULL(hb.holiday_value_id,@default_holiday_calendar)
	WHERE 
		cg.contract_id = @contract_id
		AND hc.hol_date =@prod_date
END
ELSE 
BEGIN
	SELECT @value=CASE WHEN CAST(hc.hol_date  as DATE)=CAST(@prod_date AS DATE) THEN 1 ELSE 0 END FROM holiday_group hc 
	WHERE  hol_group_value_id = @default_holiday_calendar AND CAST(hol_date  as DATE)=CAST(@prod_date AS DATE)
		
END

	RETURN  ISNULL(@value,0)
END



