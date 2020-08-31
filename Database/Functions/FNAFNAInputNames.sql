/****** Object:  UserDefinedFunction [dbo].[FNAFNAInputNames]    Script Date: 08/20/2009 12:35:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAFNAInputNames]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFNAInputNames]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


--select dbo.FNAFNACurveNames('2 + 5 *  CurveH(88) + INPUT(7) -  CurveM(179)')



-- 
-- declare @formula varchar(8000)
-- 
-- set @formula = 
-- --'dbo.FNAMax((dbo.FNACurve(99)/(dbo.FNACurve(99) + dbo.FNACurve(88))) * ((dbo.FNACurve(1) * 3.4567) + 2.25), 6.5)'
-- 'dbo.FNAMax((dbo.FNACurve(99)/(dbo.FNACurve(99) + dbo.FNACurveH(88))) * ((dbo.FNACurve(1) * 3.4567) + 2.25), 6.5)'
-- 
-- set @formula = dbo.FNAFormulaFormat(@formula, 'c')
-- select dbo.FNAFNACurveNames(@formula)

-- 
CREATE FUNCTION [dbo].[FNAFNAInputNames](@formula varchar(8000))
RETURNS VARCHAR(8000) AS
BEGIN


declare @index int
declare @index_next int
declare @price_id int
declare @new_formula varchar(8000)
declare @curve_name varchar(50)

set @formula ='2 + 5 *  CurveH(88) + INPUT(7) -  CurveD(179) - -  CurveM(179)  -  CurveY(179) '

set @index = 1
set @index_next = 1
set @formula = replace(@formula, ' ', '') -- get rid of white spaces

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('INPUT(', @formula, @index)
	
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+6-@index_next)
	---print @new_formula

	SELECT @index_next = CHARINDEX(')', @formula, @index+6)
	--select @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+6, @index_next - @index - 6) as int)

	--select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	--print @price_id
	
	SET @curve_name = NULL
	select @curve_name = input_name from ems_source_input where ems_source_input_id = @price_id
	
--	select @new_formula = @new_formula + '''' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''''
--	select @new_formula = @new_formula + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') 
--	select @new_formula = @new_formula + '"' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + '"'
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END
-- print @formula
--return

set @new_formula = replace(@new_formula, 'Case', ' Case ') -- add white space
set @new_formula = replace(@new_formula, 'Between', ' Between ') -- add white space
set @new_formula = replace(@new_formula, 'AND', ' AND ') -- add white space
set @new_formula = replace(@new_formula, 'Else', ' Else ') -- add white space
set @new_formula = replace(@new_formula, 'Then', ' Then ') -- add white space
set @new_formula = replace(@new_formula, 'End', ' End ') -- add white space
set @new_formula = replace(@new_formula, 'When', ' When ') -- add white space


return @new_formula

END















