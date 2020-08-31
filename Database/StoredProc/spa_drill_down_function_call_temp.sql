
/****** Object:  StoredProcedure [dbo].[spa_drill_down_function_call]    Script Date: 12/13/2010 19:02:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_drill_down_function_call_temp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_drill_down_function_call_temp]
/****** Object:  StoredProcedure [dbo].[spa_drill_down_function_call]    Script Date: 12/13/2010 19:03:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_drill_down_function_call_temp] @formula varchar(8000)
AS



DECLARE @index INT
DECLARE @index_next INT
DECLARE @new_formula varchar(8000)
DECLARE @func_call varchar(8000)
DECLARE @func_call_uom varchar(8000)
DECLARE @value varchar(1000)
DECLARE @value_uom varchar(1000)
DECLARE @index_min int
--DECLARE @formula varchar(8000)
--set @formula='dbo.FNAEMSInput(25,310)*dbo.FNAEMSEMSConv(127,270,''2006-01-01'',25,1182,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,39,40,NULL)*dbo.FNAEMSEMSConv(127,270,''2006-01-01'',25,1179,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,40,34,NULL)*0.99'
-- drop table #value
-- drop table #value_uom

-- SET @formula = 
-- 'dbo.FNAEMSInput(''Jan  1 2002 12:00AM'',270,25)* dbo.FNAEMSEMSConv(182,25,1180,NULL,5188,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,40,34) * dbo.FNARECCurve(''09/01/2006'', 137)'

set @index_min=0
set @index = 1
set @index_next = 1

--set @formula = replace(@formula, ' ', '') -- get rid of white spaces

--select @formula



create table #value
(
value float,
)

create table #value_uom
(
uom varchar(100) COLLATE DATABASE_DEFAULT
)

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('dbo.FNA', @formula, 1)
	
	SET @formula=REPLACE(@formula,'dbo.FNAMIN(','')	
	SET @formula=REPLACE(@formula,'dbo.FNAMax(','')	
	SET @formula=REPLACE(@formula,'dbo.FNAMIN (','')	
	SET @formula=REPLACE(@formula,'dbo.FNAMax (','')	

	
	If @index = 0 
	begin
		set @new_formula = @formula
		break
	end

--	SELECT @second_index = CHARINDEX('dbo.FNA', @formula, @index)
--	
--	SET @index=@index+@second_index
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)
--	IF CHARINDEX('))', @formula, @index+1)>0 AND CHARINDEX('dbo.FNARLagCurve', @formula, 1)>0
--		SELECT @index_next = CHARINDEX('))', @formula, @index+1)+1

	--select @index, @index_next

	SET @func_call = SUBSTRING(@formula, @index, @index_next - @index + 1)

 	--select @func_call
-- 	select CHARINDEX(@func_call, 'dbo', 1) 
		
	
	exec ('insert into #value select ' + @func_call)

	SET @func_call_uom = @func_call
	set @value_uom = null

	--if CHARINDEX(@func_call, 'dbo.FNAEMSInput') > 0
		SET @func_call_uom = REPLACE(@func_call_uom, 'dbo.FNAEMSInput', 'dbo.FNAEMSInputUOM')
	--if CHARINDEX(@func_call, 'dbo.FNAEMSEMSConv') > 0
		SET @func_call_uom = REPLACE(@func_call_uom, 'dbo.FNAEMSEMSConv', 'dbo.FNAEMSEMSConvUOM')
	--if CHARINDEX(@func_call, 'dbo.FNAEMSUOMConv') > 0
		SET @func_call_uom = REPLACE(@func_call_uom, 'dbo.FNAEMSUOMConv', 'dbo.FNAEMSUOMConvUOM')

		
-- 	else 
-- 		set @func_call_uom = ''
	
	if @func_call_uom <> @func_call
		exec ('insert into #value_uom select ' + @func_call_uom)

	--select @value = CONVERT(varchar(1000), CAST(value AS float)) from #value
	select @value = (CAST(value AS NUMERIC(20,4))) from #value

	select @value_uom = cast(uom as varchar(500)) from #value_uom

	set @value = case when (@value is null and @func_call not like '%Row(%') then '<font color=''red''>Undefined Value ' +  isnull(@value_uom, '')	 
		+ '</font>' when (@value is null and @func_call  like '%Row(%') then '0' else @value + isnull(@value_uom, '') end

 	set @new_formula = SUBSTRING(@formula, 1, @index-1) + 
				--	@new_formula + 
				'(' + cast(@value as varchar(500)) + ')' + SUBSTRING(@formula, @index_next+1, len(@formula) - @index_next)
	set @formula = @new_formula
	

	delete from #value
	delete from #value_uom

END

select  REPLACE(REPLACE(@new_formula,'dbo.FNAMIN','Min'),'dbo.FNAMax','Max') as formula



















