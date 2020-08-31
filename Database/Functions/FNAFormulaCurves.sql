IF OBJECT_ID(N'FNAFormulaCurves', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAFormulaCurves]
 GO 

-- select dbo.FNAFormulaCurves('dbo.FNACurve(96) - dbo.FNACurve(97)')


CREATE FUNCTION dbo.FNAFormulaCurves(@formula varchar(8000))
RETURNS VARCHAR(100) AS
BEGIN


declare @index int
declare @index_next int
declare @price_id int
declare @new_formula varchar(8000)
declare @curve_name varchar(50)

set @index = 1
set @index_next = 1
set @formula = replace(@formula, ' ', '') -- get rid of white spaces

--select @formula

set @new_formula = ''
SET @curve_name = ''
while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('(', @formula, @index)

	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	SELECT @index_next = CHARINDEX(')', @formula, @index+1)
	--select @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as int)

	SET @curve_name = @curve_name + case when (@curve_name <> '') then ',' else '' end + cast (@price_id as varchar)

	
	set @index =@index_next + 1 
END
-- print @formula




RETURN @curve_name

END













