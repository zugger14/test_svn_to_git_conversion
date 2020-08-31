IF OBJECT_ID('FNAFasHeader') IS NOT NULL
DROP FUNCTION [dbo].[FNAFasHeader]
GO 
/****** Object:  UserDefinedFunction [dbo].[FNAFasHeader]    Script Date: 03/17/2010 14:25:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNAFasHeader(27)
-- 
CREATE FUNCTION [dbo].[FNAFasHeader] (@link_id as int)  
RETURNS char(1) AS  
BEGIN 

-- 	DECLARE @link_id int
-- 	sET @link_id = 59

	DECLARE @link_eff_date datetime
	DECLARE @min_run_as_of_date datetime
	DECLARE @allow_changes as char(1)

	DECLARE @link_type as integer

	select	@link_eff_date = case when (link_type_value_id = 450) then link_effective_date else link_end_date end 
	from fas_link_header 
	where link_id = @link_id			

	select @min_run_as_of_date = min(as_of_date) from close_measurement_books where as_of_date >= @link_eff_date

	IF @min_run_as_of_date is not null 
		SET @allow_changes = 'n'
	Else
		SET @allow_changes = 'y'

--SELECT @allow_changes 

RETURN (@allow_changes)
END

GO

