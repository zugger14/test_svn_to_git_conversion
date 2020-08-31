IF OBJECT_ID(N'FNAFormulaValueText', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAFormulaValueText]
GO 

-- declare @stmt varchar(8000) 
-- declare @formula varchar(8000)
-- --select @formula = formula from formula_editor where formula_id = 17
-- set @formula = 'dbo.FNAMin(dbo.FNACurveH(99), 40)'
-- set @stmt = 'select ' + dbo.FNAFormulaValueText ('2004-03-01', 20, 0, @formula, NULL)
-- print @stmt
-- exec(@stmt)

CREATE FUNCTION [dbo].[FNAFormulaValueText]
(
	@as_of_date                      DATETIME,
	@maturity_date                   DATETIME,
	@assessment_curve_type_value_id  INT,
	@curve_source_value_id           INT,
	@formula                         VARCHAR(8000)
)
--RETURNS float AS  
RETURNS varchar(8000) AS  
BEGIN

----test variables
-- declare @maturity_date varchar(20)
-- declare @volume float
-- declare @sum_volume float
-- declare @formula varchar(8000)
-- declare @he int
-- 
-- 
-- set @formula = 'dbo.FNAMin(dbo.FNACurveH(99), 40)'
-- set @volume = 20
-- set @sum_volume = 0
-- set @maturity_date = '2004-03-02'
-- --set @maturity_date = '03/02/2004'
-- set @he  = 14
-- end of test variables

--print @maturity_date
DECLARE  @formula_stmt varchar(8000)
	SET @formula_stmt = replace(@formula, 'dbo.FNACurve(', 'dbo.FNACurveValue(''' + dbo.FNAGetSQLStandardDate(@as_of_date) + ''','  +  '''' + 
					dbo.FNAGetSQLStandardDate(@maturity_date) + '''' + ',' + cast(@assessment_curve_type_value_id as varchar) 
					+ ',' + cast(@curve_source_value_id as varchar) + ',')

	RETURN (@formula_stmt)
END











