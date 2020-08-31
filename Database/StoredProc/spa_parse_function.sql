
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_parse_function]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_parse_function]
GO



CREATE PROCEDURE [dbo].[spa_parse_function] (@str varchar(8000), @function_name varchar(100), @start_index INT,
			@formula_str varchar(8000) OUTPUT, @last_index INT OUTPUT)
AS

BEGIN

/****** BEGIN OF TESTING ******/
/*
declare @str varchar(8000)
declare @function_name varchar(100)
declare @start_index INT
declare @formula_str varchar(8000)
declare @last_index int
set @start_index=1 --84
--set @function_name='dbo.FNALagCurve'
set @function_name='dbo.FNAAvg'
--set @str= ' dbo.FNALagCurve(9,0,0,0,1,NULL,0, cast(100 as float)/(dbo.FNAUDFValue(291624)*500)) + dbo.FNALagCurve(9,0,0,0,1,NULL,0, cast(100 as float)/(7.3*500))'
set @str= 'dbo.FNAAvg(20,21) + dbo.FNALagCurve(7,0,0,0,1,NULL,0, dbo.FNAUOMCOnv(19,10)) + dbo.FNALagCurve(9,0,0,0,1,NULL,0, cast(100 as float)/(dbo.FNAUDFValue(291624)*500))  + dbo.FNALagCurve(10,0,0,0,1,NULL,0, cast(15 as float)/7.43) '
--declare @formula_str1 varchar(8000)
--declare @last_index1 int
--exec spa_parse_function @str, @function_name, @start_index, @formula_str1 OUTPUT, @last_index1 OUTPUT
--select @formula_str1, @last_index1
*/
/****** END OF TESTING ******/


declare @index int, @index2 int, @index3 int
declare @tmp_str varchar(8000), @str_formula varchar(8000)

SELECT @index = CHARINDEX(@function_name, @str, @start_index)


If @index = 0
BEGIN 
	set @formula_str=NULL
	set @last_index=0
	return
END

SET @index2 = 1
SET @index3 = @index
WHILE @index2 > 0 
BEGIN
	SET @index2 = CHARINDEX(')', @str, @index3+1)

	--select @str, @index3, @index2

	If @index2 = 0
		break

	set @tmp_str = substring(@str, @index, @index2-@index+1)

	--select @tmp_str 

	set @str_formula='DECLARE @result varchar(8000)
		  SELECT @result = '+ @tmp_str 
	 
	BEGIN TRY
	  exec( @str_formula)
	  BREAK
	END TRY
	BEGIN CATCH
		set @index3=@index2		
	END CATCH
END 

--SELECT @tmp_str formula_str, @index2 last_index
set @formula_str = @tmp_str
set @last_index = @index2


return 


END