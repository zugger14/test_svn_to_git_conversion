/****** Object:  UserDefinedFunction [dbo].[FNAFNACurveNames]    Script Date: 02/08/2010 17:18:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAFNACurveNames]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAFNACurveNames]
/****** Object:  UserDefinedFunction [dbo].[FNAFNACurveNames]    Script Date: 02/08/2010 17:18:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select [dbo].[FNAFNACurveNames]('FNAPriorCurve(2394,2005,6,2)')
/*
 
select dbo.FNAFNACurveNames(' CounterpartyMTM( NULL ) ')

*/
CREATE FUNCTION [dbo].[FNAFNACurveNames](@formula varchar(8000))
	RETURNS VARCHAR(8000) AS
BEGIN

/*

declare @formula varchar(8000)='AveragePrice(GetLogicalValue(50,''MeterVolm''),307037,980)'
--set @formula='AveragePrice(4779,307037,980)'
--*/
declare @index int
declare @index_next int
declare @price_id int
declare @new_formula varchar(8000)
declare @curve_name varchar(150)
DECLARE @curve_id INT
DECLARE @mapping_table_id INT, @mapping_name VARCHAR(100), @granularity_id VARCHAR(200), @granularity_name  VARCHAR(100), @prior_month VARCHAR(100) 
DECLARE @possible_curve_id AS VARCHAR(500)
--set @formula = 'dbo.FNACounterpartyMTM(NULL) '
--set @formula = 'FNARLagcurve(2005-01-01,2005-01-01,4500,239,2005,6,2,1,null)'
--set @formula = 'ExAntePrice(1950,UDFValue(12594))'
--set @formula = 'ExAntePrice(1950,UDFValue(12594))'
--set @formula = 'DealType(985,NULL)'
--set @formula = 'DealFees(291887)'


DECLARE @UDF_str VARCHAR(100)

SET @formula = REPLACE(@formula,' ','')

  

----########## For UDF Charges
set @index = 1
set @index_next = 1
set @new_formula = ''

while (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('UDFValue(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+8)
	--select @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)

	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''


	set @index =@index_next + 1 
END

set @formula = @new_formula

set @index = 1
set @index_next = 1
set @new_formula = ''

while (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('CurveM(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 7 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 7)	

	 
	  /*
	If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
	It will be extracted by UDFValue function. Such function is used in Questar.
	*/
	--old logic
	--SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )
	select @possible_curve_id  = SUBSTRING(@formula, @index + 7, @index_next - @index -7)
	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
		SET @curve_id = CAST(@possible_curve_id AS INT)
	ELSE
		SET @curve_id = NULL
	


    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    --IF NULLIF(@granularity_id,'NULL') IS NOT NULL	
    SELECT @granularity_id = CAST(
               SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS 
               VARCHAR
           )
    
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
	SELECT @new_formula = @new_formula + '' +  COALESCE(@curve_name, CAST(@curve_id AS VARCHAR) + '', @possible_curve_id) 
           + ', '



    --	select * from source_deal_type
    --	print @deal_type_name
    
    --SET @granularity_name = NULL
    --IF NULLIF(@granularity_id, 'NULL') IS NOT NULL
    --    SELECT @granularity_name = code
    --    FROM   static_data_value
    --    WHERE  CAST(value_id AS VARCHAR) = @granularity_id
    --set @deal_subtype_name = isnull(@deal_subtype_name, cast(@deal_subtype_id as varchar) + '-UNKNOWN') + ''
    SELECT @new_formula = @new_formula + '' + ISNULL(@granularity_name, CAST(@granularity_id AS VARCHAR) + '')
    
    SET @index = @index_next + 1
END


------########## For UDF Charges
--set @index = 1
--set @index_next = 1
--set @formula = @new_formula

--set @new_formula = ''

--while (@index <> 0)
--BEGIN
	
--	SELECT @index = CHARINDEX('UDFValue(', @formula, @index)
--	If @index = 0 
--	begin
--		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
--		break
--	end

--	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)

--	SELECT @index_next = CHARINDEX(')', @formula, @index+8)
--	--select @index, @index_next
	
--	SELECT @price_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)
	
--	SET @curve_name = NULL
--	select @curve_name = code from static_data_value where value_id = @price_id

--	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''


--	set @index =@index_next + 1 
--END


--Now convert for 15 minute curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('Curv15(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	--select @new_formula

	SELECT @index_next = CHARINDEX(',', @formula, @index+8)	
	


		  /*
	If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
	It will be extracted by UDFValue function. Such function is used in Questar.
	*/
	--old logic
	--SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )
	select @possible_curve_id  = cast(SUBSTRING(@formula, @index+8, @index_next - @index - 8) as int)
	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
		SET @price_id = CAST(@possible_curve_id AS INT)
	ELSE
		SET @price_id = NULL


	--select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	--print @price_id
	
	SET @curve_name = NULL
	select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END





--Now convert for 30 minute curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('Curve30(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	---print @new_formula

	SELECT @index_next = CHARINDEX(',', @formula, @index+8)
	--select @index, @index_next
	
	--SELECT @price_id = cast(SUBSTRING(@formula, @index+8, @index_next - @index - 8) as int)
  /*
	If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
	It will be extracted by UDFValue function. Such function is used in Questar.
	*/
	select @possible_curve_id  = cast(SUBSTRING(@formula, @index+8, @index_next - @index - 8) as int)
	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
		SET @curve_id = CAST(@possible_curve_id AS INT)
	ELSE
		SET @curve_id = NULL	
	SET @curve_name = NULL
	select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	
--	select @new_formula = @new_formula + '''' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''''
--	select @new_formula = @new_formula + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') 
--	select @new_formula = @new_formula + '"' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + '"'
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''



	set @index =@index_next + 1 
END



--Now convert for Hourly curve
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
--SELECT @formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('CurveH(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 7 -@index_next)
    
    SET @curve_name = NULL
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+7) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+7, @index_next - @index - 7)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index + 7)	
		--SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT)
		   /*
		If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
		It will be extracted by UDFValue function. Such function is used in Questar.
		*/
		--old logic
		--SELECT @curve_id = CAST(
		--           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
		--       )
		select @possible_curve_id  = SUBSTRING(@formula, @index + 7, @index_next - @index -7)
		--PRINT '@possible_curve_id:' + @possible_curve_id
		IF ISNUMERIC(@possible_curve_id) = 1
			SET @curve_id = CAST(@possible_curve_id AS INT)
		ELSE
			SET @curve_id = NULL




		SELECT @curve_name = curve_name FROM   source_price_curve_def WHERE  source_curve_def_id = @curve_id
	END
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    
    SELECT @granularity_id = CAST(SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS VARCHAR)
    
   	 SELECT @new_formula = @new_formula + '' +  COALESCE(@curve_name, CAST(@curve_id AS VARCHAR) + '', @possible_curve_id) + ','
 
    SET @granularity_name = NULL
    
    IF NULLIF(@granularity_id, 'NULL') IS NOT NULL
    BEGIN
    	SELECT @granularity_name = code
        FROM static_data_value
        WHERE CAST(value_id AS VARCHAR) = @granularity_id
    END       
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@granularity_name, CAST(@granularity_id AS VARCHAR) + '')
    
    SET @index = @index_next + 1
END

--Now convert for Daily curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('CurveD(', REPLACE(@formula,'RelativeCurveD','XY'), @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 7 -@index_next)
    
    SET @curve_name = NULL
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+7) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+7, @index_next - @index - 7)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index + 7)	
		--SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT)
		   /*
		If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
		It will be extracted by UDFValue function. Such function is used in Questar.
		*/
		--old logic
		--SELECT @curve_id = CAST(
		--           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
		--       )
		select @possible_curve_id  = SUBSTRING(@formula, @index + 7, @index_next - @index -7)
		--PRINT '@possible_curve_id:' + @possible_curve_id
		IF ISNUMERIC(@possible_curve_id) = 1
			SET @curve_id = CAST(@possible_curve_id AS INT)
		ELSE
			SET @curve_id = NULL

		SELECT @curve_name = curve_name FROM   source_price_curve_def WHERE  source_curve_def_id = @curve_id
	END
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    
    SELECT @granularity_id = CAST(SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS VARCHAR)
    
   	 SELECT @new_formula = @new_formula + '' +  COALESCE(@curve_name, CAST(@curve_id AS VARCHAR) + '', @possible_curve_id) + ','
 
    SET @granularity_name = NULL

    SELECT @new_formula = @new_formula + '' + CAST(@granularity_id AS VARCHAR) + ''
    
    SET @index = @index_next + 1
END



--Now convert for Yearly curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
--BEGIN

--	SELECT @index = CHARINDEX('CurveY(', @formula, @index)
--	If @index = 0 
--	begin
--		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
--		break
--	end

--	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+7-@index_next)
--	---print @new_formula

--	SELECT @index_next = CHARINDEX(')', @formula, @index+7)
--	--select @index, @index_next
	
--	SELECT @price_id = cast(SUBSTRING(@formula, @index+7, @index_next - @index - 7) as int)
	
--	SET @curve_name = NULL
--	select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id

--	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''

	
--	set @index =@index_next + 1 
--END
BEGIN
    SELECT @index = CHARINDEX('CurveY(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 7 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 7)	
    --SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )


	  /*
	If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
	It will be extracted by UDFValue function. Such function is used in Questar.
	*/
	--old logic
	--SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )
	select @possible_curve_id  = SUBSTRING(@formula, @index + 7, @index_next - @index -7)
	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
		SET @curve_id = CAST(@possible_curve_id AS INT)
	ELSE
		SET @curve_id = NULL
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    --IF NULLIF(@granularity_id,'NULL') IS NOT NULL	
    SELECT @granularity_id = CAST(
               SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS 
               VARCHAR
           )
    
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
	SELECT @new_formula = @new_formula + '' +  COALESCE(@curve_name, CAST(@curve_id AS VARCHAR) + '', @possible_curve_id) 
           + ', '

    SELECT @new_formula = @new_formula + '' + ISNULL(@granularity_name, CAST(@granularity_id AS VARCHAR) + '')
    
    SET @index = @index_next + 1
END

--Now convert for INPUT curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('GetCurveValue(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    --SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 14 -@index_next)
    
 

    SET @curve_name = NULL
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 14 -@index_next)
		SELECT @index_next = CHARINDEX(')', @formula, @index+14)+1
		SELECT @curve_name = SUBSTRING(@formula, @index+14, @index_next - @index - 14)
	END
	ELSE
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 14 -@index_next)
	END
    
      SELECT @index_next = CHARINDEX(')', @formula, @index + 14)	
    
    --SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )


	  /*
	If UDFValue is used under CurveM [e.g. CurveD(UDFValue(3456), NULL)], then curve_id cannot be extracted and shoudl be escaped.
	It will be extracted by UDFValue function. Such function is used in Questar.
	*/
	--old logic
	--SELECT @curve_id = CAST(
    --           SUBSTRING(@formula, @index + 7, @index_next - @index -7) AS INT
    --       )
	select @possible_curve_id  = SUBSTRING(@formula, @index + 14, @index_next - @index -14)
	
	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
		SET @curve_id = CAST(@possible_curve_id AS INT)
	ELSE
		SET @curve_id = NULL
     
    SET @index = @index_next
    --SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    ----IF NULLIF(@granularity_id,'NULL') IS NOT NULL	
    --    
    --SELECT @granularity_id = CAST(
    --           SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS 
    --           VARCHAR
    --       )

    IF @curve_name IS NULL
    BEGIN
		SELECT @curve_name = curve_name
		FROM   source_price_curve_def
		WHERE  source_curve_def_id = @curve_id
    END
    --RETURN(@curve_name)
	SELECT @new_formula = @new_formula + '' +  COALESCE(@curve_name, CAST(@curve_id AS VARCHAR) + '', @possible_curve_id) 
          -- + ', '

    SELECT @new_formula = @new_formula + '' --+ ISNULL(@granularity_name, CAST(@granularity_id AS VARCHAR) + '')
    
    SET @index = @index_next + 1
END

--Now convert for INPUT curve
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

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
	
	SET @curve_name = NULL
	select @curve_name = input_name from ems_source_input where ems_source_input_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END

--Now Convert for EMSConv
DECLARE @conversion_id int
DECLARE @from_uom_id int
DECLARE @to_uom_id int
DECLARE @source_id int

set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('EMSConv(', @formula, @index)

	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)


	SELECT @index_next = CHARINDEX(',', @formula, @index+8)	
	SELECT @price_id = cast(NULLIF(SUBSTRING(@formula, @index+8, @index_next - @index - 8),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @conversion_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index-1),'NULL') as int)

	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @from_uom_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index-1),'NULL') as int)

	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @to_uom_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index-1),'NULL') as int)

	set @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @source_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index-1),'NULL') as int)


	SET @curve_name = NULL
	select @curve_name = input_name from ems_source_input where ems_source_input_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, 'NULL') + ', '

	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @conversion_id
	select @new_formula = @new_formula + '' + isnull(@curve_name, 'NULL') + ', '


	SET @curve_name = NULL
	select @curve_name = uom_name from source_uom where source_uom_id = @from_uom_id
	select @new_formula = @new_formula + '' + isnull(@curve_name,'NULL') + ', '

	SET @curve_name = NULL
	select @curve_name = uom_name from source_uom where source_uom_id = @to_uom_id
	select @new_formula = @new_formula + '' + isnull(@curve_name,'NULL') + ','

	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @source_id
	select @new_formula = @new_formula + '' + isnull(@curve_name, 'NULL') + ''

	set @index =@index_next + 1 
	
	
END


-- Convert ContractVol
declare @contract_id int
declare @contract_name varchar(100)

set @index = 1
set @index_next = 1
set @formula = @new_formula
--set @formula = replace(@formula, ' ', '')


set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('ContractVol(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)
	
	--print @new_formula

	SELECT @index_next = CHARINDEX(')', @formula, @index+11)

	SELECT @contract_id=cast(SUBSTRING(@formula, @index+12, @index_next - @index - 12) as int)



	set @contract_name = null
	select @contract_name = contract_name from contract_group where contract_id = @contract_id


	select @new_formula = @new_formula + '' + isnull(@contract_name, cast(@contract_name as varchar) + '-UNKNOWN') + ''
		
set @index =@index_next + 1 
end

-- Convert ContractValue
DECLARE @param varchar(100)
DECLARE @line_item_id int
DECLARE @row_no INT
DECLARE @line_item_name varchar(100)
DECLARE @tmp_index int
DECLARE @loop int
DECLARE @row_no_desc varchar(100)
DECLARE @month_value VARCHAR(20) 
SET @tmp_index = 0
SET @loop = 0
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN	
	SELECT @index = CHARINDEX('ContractValue(', @formula, @index)
	--print @index
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	END
	
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+14-@index_next)
	--print @new_formula
	SELECT @index_next = CHARINDEX(')', @formula, @index+14)
	SELECT @param=SUBSTRING(@formula, @index+14, @index_next - @index - 14)
	
	WHILE(@loop <> 6)
	BEGIN
		IF @loop = 0
		BEGIN 
			SET @contract_id = SUBSTRING(@param,@tmp_index,CHARINDEX(',',@param))
			SET @tmp_index = CHARINDEX(',',@param)
			SET @param = SUBSTRING(@param,@tmp_index+1,LEN(@param)-@tmp_index)
			SET @tmp_index = 0
			--print @contract_id
			--PRINT @param
		END
		else IF @loop = 1
		BEGIN
			
			--SET @tmp_index = CHARINDEX(',',@param,@tmp_index)
			
			SET @line_item_id = SUBSTRING(@param,@tmp_index,CHARINDEX(',',@param))
			
			SET @tmp_index = CHARINDEX(',',@param)
			SET @param = SUBSTRING(@param,@tmp_index+1,LEN(@param)-@tmp_index)
			SET @tmp_index = 0
		END
		ELSE IF @loop = 2
		BEGIN
			
			SET @row_no = SUBSTRING(@param,@tmp_index,CHARINDEX(',',@param));
			SET @tmp_index = CHARINDEX(',',@param);
			SET @param = SUBSTRING(@param,@tmp_index+1,LEN(@param)-@tmp_index);
			SET @tmp_index = 0
		END
		ELSE IF @loop = 3
		BEGIN
			SET @prior_month = replacE(SUBSTRING(@param, @tmp_index+1, CHARINDEX(',', @param)), ',', '');
			SET @tmp_index = CHARINDEX(',',@param);
			SET @param = SUBSTRING(@param,@tmp_index+1,LEN(@param)-@tmp_index);
			SET @tmp_index = 0
		END
		ELSE IF @loop = 4
		BEGIN
			--SET @formula = 'ContractValue(413,300303,1,2,NULL,8)'
			SET @month_value = SUBSTRING(@param,@tmp_index,CHARINDEX(',',@param))
			SET @tmp_index = CHARINDEX(',',@param);
			SET @param = SUBSTRING(@param,@tmp_index+1,LEN(@param)-@tmp_index)
			SET @tmp_index = 0
			--PRINT @month_value
			--PRINT @param
		END
		
		SET @loop = @loop + 1
		
	END

	SET @loop = 0
	--print @contract_id
	IF @contract_id is not null
		SELECT @contract_name = contract_name FROM contract_group WHERE contract_id = @contract_id
	IF @line_item_id is not null
		SELECT @line_item_name = description FROM static_data_value WHERE value_id = @line_item_id
	IF @row_no is not null
		SELECT @row_no_desc =  'Row'+CAST(fn.sequence_order as varchar) + '.' + fn.description1 FROM formula_nested fn
		LEFT JOIN contract_group_detail cgd on cgd.formula_id = fn.formula_group_id
		LEFT JOIN contract_charge_type_detail cctd on cctd.formula_id= fn.formula_group_id
		WHERE (cgd.contract_id = @contract_id OR cgd.contract_id IS NULL) and ISNULL(cgd.invoice_line_item_id,cctd.invoice_line_item_id) = @line_item_id and fn.sequence_order = @row_no
	
	IF @param = '-1'
		SET @param = 'Prior As of Date'
	ELSE IF @param = '0'
		SET @param = 'Max As of Date'
	ELSE IF @param = '1'
		SET @param = 'Same As of Date'
	
	SELECT @new_formula = @new_formula + '' + ISNULL(@contract_name, CAST(@contract_name as varchar) + '-UNKNOWN') + ''
	SELECT @new_formula = @new_formula + ',' + ISNULL(@line_item_name, CAST(@line_item_name as varchar) + '-UNKNOWN') + ''
	SELECT @new_formula = @new_formula + ',' + ISNULL(@row_no_desc, CAST(@row_no_desc as varchar) + '-UNKNOWN') + ''
	SELECT @new_formula = @new_formula + ',' + ISNULL(@prior_month, CAST(@prior_month as varchar) + '-UNKNOWN') + ''
	SELECT @new_formula = @new_formula + ',' + ISNULL(@month_value, CAST(@month_value as varchar) + '-UNKNOWN') + ''
	SELECT @new_formula = @new_formula + ',' + ISNULL(@param, CAST(@param as varchar) + '-UNKNOWN') + ''
	
	SET @index = @index_next + 1 
	--print @param
	--SELECT @new_formula
END

---- For MeterVol
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
--SELECT @formula
DECLARE @meter_id INT, @month_no INT,@channel_no INT, @meter_name VARCHAR(100),@channel_desc VARCHAR(100), @block_defination_code varchar(500), @block_type int 
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('MeterVol(', @formula, @index)
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END
	
	SET @meter_name = NULL
	SET @channel_desc = NULL

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)	
	
	
	IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+9)+1
		SELECT @meter_name = SUBSTRING(@formula, @index+9, @index_next - @index - 9)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index+9)	
		SELECT @meter_id = CAST(NULLIF(SUBSTRING(@formula, @index+9, @index_next - @index - 9),'NULL') AS INT)
		SELECT @meter_name = recorderid FROM meter_id WHERE meter_id = @meter_id
	END

	SET @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @month_no = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS VARCHAR(100))
	
	SET @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @channel_no = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS INT)

	SET @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)		
	SELECT @channel_desc = ISNULL(channel_description,channel) FROM recorder_properties WHERE meter_id = @meter_id AND channel = @channel_no
	IF @channel_desc IS NULL
		SET @channel_desc = @channel_no
		
	SELECT @block_type = CAST(NULLIF(SUBSTRING(@formula, @index + 1, @index_next - @index -1),'NULL') AS INT)
	SET @block_defination_code = NULL
    SELECT @block_defination_code = code FROM   static_data_value WHERE  value_id = @block_type
	SELECT @new_formula = @new_formula + '' + ISNULL(CAST(@meter_name AS VARCHAR(100)), CAST(@meter_id AS VARCHAR(10)) + '-UNKNOWN') + ',' + CAST(isnull(@month_no, 0) AS VARCHAR) + ',' + isnull(@channel_desc, 'Unknown Channel') + ',' + isnull(@block_defination_code, 'NULL') 
	SET @index =@index_next + 1 
END


DECLARE @currency_id INT
DECLARE @currency_name VARCHAR(50)
--DECLARE @curve_id INT
DECLARE @Relative_Year VARCHAR(10)
DECLARE @Strip_Month_From VARCHAR(10)
DECLARE @Lag_Months VARCHAR
DECLARE @Strip_Month_To VARCHAR(10)
DECLARE @Relative_Month VARCHAR(10)
DECLARE @Relative_Day VARCHAR(10)


SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
	BEGIN
		SELECT @index = CHARINDEX('Lagcurve(', @formula, @index)
		
		If @index = 0 
		begin
			set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
			break
		end

		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)	
		
	
		SELECT @index_next = CHARINDEX(',', @formula, @index+9)	
		SELECT @curve_id = cast(NULLIF(SUBSTRING(@formula, @index+9, @index_next - @index - 9),'NULL') as int)		
		
		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Relative_Year = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR)		
		
		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Strip_Month_From = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR)		
		
		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Lag_Months = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as INT)

		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Strip_Month_To = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR)

		set @index=@index_next		
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)
		SELECT @currency_id = cast(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') as VARCHAR)
		
		IF @index_next <> 0	
			SELECT @currency_id = cast(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') as VARCHAR)	

		IF @index_next <= 0
		BEGIN
			SELECT @index_next = CHARINDEX(')', @formula, @index+1)
			SELECT @currency_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR)	
		END
			


		SET @curve_name = NULL
		select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @curve_id

		select @new_formula = @new_formula + '' + isnull(@curve_name, 'NULL') + ', '+@Relative_Year+', '+@Strip_Month_From+', '+@Lag_Months+', '+@Strip_Month_To+', '

		SET @currency_name = NULL
		select @currency_name = currency_name from source_currency where source_currency_id = @currency_id
		select @new_formula = @new_formula + '' + isnull(@currency_name, 'NULL') + ''
		
		set @index =@index_next + 1 
	END



SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
	BEGIN

		SELECT @index = CHARINDEX('Priorcurve', @formula, @index)

		If @index = 0 
		begin
			set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
			break
		end

		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+11-@index_next)


		SELECT @index_next = CHARINDEX(',', @formula, @index+11)	
		SELECT @curve_id = cast(NULLIF(SUBSTRING(@formula, @index+11, @index_next - @index - 11),'NULL') as int)
		
		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Relative_Year = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR(10))

		set @index=@index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
		SELECT @Relative_Month = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR(10))

		set @index=@index_next
		SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
		SELECT @Relative_Day = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR(10))


		SET @curve_name = NULL
		select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @curve_id


		select @new_formula = @new_formula + '' + isnull(@curve_name, 'NULL') + ', '+@Relative_Year+ ', '+@Relative_Month+ ', '+@Relative_Day

		
		
		set @index =@index_next + 1 
	END


DECLARE @product_type   INT,
        @location_id    VARCHAR(100),
        @product_name   VARCHAR(200),
        @location_name  VARCHAR(100)

SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
	BEGIN

		SELECT @index = CHARINDEX('ExAntePrice(', @formula, @index)

		If @index = 0 
		begin
			set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
			break
		end

		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)


		SELECT @index_next = CHARINDEX(')', @formula, @index+12)	
		SELECT @product_type = cast(NULLIF(SUBSTRING(@formula, @index+12, @index_next - @index - 12),'NULL') as int)
		
--		set @index=@index_next
--		SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
--		SELECT @location_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR(100))


		SET @product_name = NULL
		select @product_name = code from static_data_value where value_id = @product_type

--		SET @location_name = NULL
--		select @location_name = code from static_data_value where value_id  = @location_id



		select @new_formula = @new_formula + '' + ISNULL(@product_name, CAST(@product_type AS VARCHAR)) 
		
		set @index =@index_next + 1 
	END

SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
	BEGIN

		SELECT @index = CHARINDEX('ExPostPrice(', @formula, @index)

		If @index = 0 
		begin
			set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
			break
		end

		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)


		SELECT @index_next = CHARINDEX(',', @formula, @index+12)	
		SELECT @product_type = cast(NULLIF(SUBSTRING(@formula, @index+12, @index_next - @index - 12),'NULL') as int)

		
		set @index=@index_next
		SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
		SELECT @location_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as VARCHAR(100))


		SET @product_name = NULL
		select @product_name = code from static_data_value where value_id = @product_type

		SET @location_name = NULL
		select @location_name = location_name from source_minor_location where source_minor_location_id  = @location_id


		select @new_formula = @new_formula + '' + isnull(@product_name, 'NULL')+',' + isnull(@location_name, 'NULL') 

		
		
		set @index =@index_next + 1 
	END




set @index = 1
set @index_next = 1
SET @formula = @new_formula
set @new_formula = ''


while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('FixedCurve(', @formula, @index)
	
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+11-@index_next)


	SELECT @index_next = CHARINDEX(')', @formula, @index+11)
	SELECT @price_id = cast(SUBSTRING(@formula, @index+11, @index_next - @index - 11) as int)

	
	SET @curve_name = NULL
	select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END

-- Convert for UOMConv

set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('UOMConv(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+8)	
	SELECT @from_uom_id = cast(SUBSTRING(@formula, @index+8, @index_next - @index-8) as int)

	set @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @to_uom_id = cast(SUBSTRING(@formula, @index+1, @index_next - @index-1) as int)


	SET @curve_name = NULL
	select @curve_name = uom_name from source_uom where source_uom_id = @from_uom_id
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ', '

	SET @curve_name = NULL
	select @curve_name = uom_name from source_uom where source_uom_id = @to_uom_id
	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''

	set @index =@index_next + 1 
END





-- Convert for DealType

declare @deal_type_id int 
declare @deal_subtype_id int

declare @deal_type_name varchar(50)
declare @deal_subtype_name varchar(50)

set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('DealType(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+9)	
	SELECT @deal_type_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index-9) as int)

	set @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @deal_subtype_id = cast(case SUBSTRING(@formula, @index+1, @index_next - @index-1) when 'NULL' then NULL else SUBSTRING(@formula, @index+1, @index_next - @index-1) end as int)


	SET @deal_type_name = NULL
	select @deal_type_name = deal_type_id from source_deal_type where source_deal_type_id = @deal_type_id
	select @new_formula = @new_formula + '' + isnull(@deal_type_name, cast(@deal_type_id as varchar) + '-UNKNOWN') + ', '
--	select * from source_deal_type
--	print @deal_type_name

	SET @deal_subtype_name = NULL
--	select @deal_subtype_name = deal_type_id from source_deal_type where source_deal_type_id = @deal_subtype_id
	select @deal_subtype_name = internal_deal_type_subtype_type from internal_deal_type_subtype_types where internal_deal_type_subtype_id = @deal_subtype_id
	set @deal_subtype_name = isnull(@deal_subtype_name, cast(@deal_subtype_id as varchar) + '-UNKNOWN') + ''
	select @new_formula = @new_formula + '' + isnull(@deal_subtype_name,'NULL')

	set @index =@index_next + 1 
END


---## Added for function FNACounterpartyMTM
DECLARE @bucket_id INT,@bucket_name VARCHAR(100)
set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('CounterpartyMTM(', @formula, @index)
	
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+16-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+16)

	SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
	--SELECT @bucket_id = ISNULL(NULLIF(SUBSTRING(@formula, @index+16, @index_next - @index - 16),'NULL'),'')
	
	SET @bucket_name = NULL
	select @bucket_name = tenor_name from risk_tenor_bucket_detail where bucket_detail_id = @bucket_id
	--select @bucket_name = bucket_header_name from risk_tenor_bucket_header where bucket_header_id = @bucket_id
	select @new_formula = @new_formula + '' + isnull(@bucket_name, cast(@bucket_id as varchar) + '') + ''


	set @index =@index_next + 1 
END

set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''


while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('CounterpartyNetPwrPurchase(', @formula, @index)
	
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+27-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+27)

	
	SELECT @bucket_id = cast(SUBSTRING(@formula, @index+27, @index_next - @index - 27) as int)
	
	SET @bucket_name = NULL
	select @bucket_name = tenor_name from risk_tenor_bucket_detail where bucket_detail_id = @bucket_id
	--select @bucket_name = bucket_header_name from risk_tenor_bucket_header where bucket_header_id = @bucket_id
	select @new_formula = @new_formula + '' + isnull(@bucket_name, cast(@bucket_id as varchar) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END
---For LoadVolume

set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''


while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('LoadVolume(', @formula, @index)
	
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+11-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+11)

	
	SELECT @bucket_id = cast(SUBSTRING(@formula, @index+11, @index_next - @index - 11) as int)
	
	SET @bucket_name = NULL
	select @bucket_name = tenor_name from risk_tenor_bucket_detail where bucket_detail_id = @bucket_id
	--select @bucket_name = bucket_header_name from risk_tenor_bucket_header where bucket_header_id = @bucket_id
	select @new_formula = @new_formula + '' + isnull(@bucket_name, cast(@bucket_id as varchar) + '-UNKNOWN') + ''
	set @index =@index_next + 1 
END
---for CoIncidentPeak
set @index = 1
set @index_next = 1
set @formula = @new_formula
set @new_formula = ''
while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('CoIncidentPeak(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end
	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+15-@index_next)
	SELECT @index_next = CHARINDEX(')', @formula, @index+15)
	SELECT @bucket_id = cast(SUBSTRING(@formula, @index+15, @index_next - @index-15) as int)
	SET @bucket_name = NULL
	select @bucket_name = bucket_header_name from risk_tenor_bucket_header where bucket_header_id = @bucket_id
	--select @bucket_name = bucket_header_name from risk_tenor_bucket_header where bucket_header_id = @bucket_id
	select @new_formula = @new_formula + '' + isnull(@bucket_name, cast(@bucket_id as varchar) + '-UNKNOWN') + ''
	set @index =@index_next + 1 
END


-- for MxPrice
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

DECLARE @gran_code VARCHAR(10)
while (@index <> 0)
BEGIN

SELECT @index = CHARINDEX('MxPrice(', @formula, @index)
	If @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
		BREAK
	END

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+8)	
	SELECT @price_id = cast(NULLIF(SUBSTRING(@formula, @index+8, @index_next - @index - 8),'NULL') as int)
	SET @curve_name = NULL
	SELECT @curve_name = curve_name FROM source_price_curve_def WHERE source_curve_def_id = @price_id
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @granularity_id = CAST(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') AS INT)
	set @granularity_name = null
	SELECT @granularity_name = code FROM   static_data_value WHERE  cast(value_id AS VARCHAR) = @granularity_id
	SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@price_id AS VARCHAR) + '') + ',' + isnull(@granularity_name, 'NULL')
    SET @index = @index_next + 1
	
END

--For MnPrice
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('MnPrice(', @formula, @index)
	If @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
		BREAK
	END

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+8)	
	SELECT @price_id = cast(NULLIF(SUBSTRING(@formula, @index+8, @index_next - @index - 8),'NULL') as int)
	SET @curve_name = NULL
	SELECT @curve_name = curve_name FROM source_price_curve_def WHERE source_curve_def_id = @price_id
	SET @index = @index_next
	
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
	SELECT @granularity_id = CAST(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') AS INT)
	set @granularity_name = null
	SELECT @granularity_name = code FROM   static_data_value WHERE  cast(value_id AS VARCHAR) = @granularity_id
	SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@price_id AS VARCHAR) + '') + ',' + isnull(@granularity_name, 'NULL')
    SET @index = @index_next + 1

	SET @index =@index_next + 1 
END


----########## For UDF Charges
set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('UDFCurveValue(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+14-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+13)
	--select @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+14, @index_next - @index - 14) as int)
	
	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''


	set @index =@index_next + 1 
END


--Now convert for Yearly curve
--set @index = 1
--set @index_next = 1
--set @formula = @new_formula

----select @formula

--set @new_formula = ''

--while (@index <> 0)
--BEGIN

--	SELECT @index = CHARINDEX('DynamicCurve(', @formula, @index)
--	If @index = 0 
--	begin
--		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
--		break
--	end

--	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+13-@index_next)
--	--select @new_formula

--	SELECT @index_next = CHARINDEX(',', @formula, @index+13)	
--	SELECT @price_id = cast(SUBSTRING(@formula, @index+13, @index_next - @index - 13) as int)
	


--	--select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
--	--print @price_id
	
--	SET @curve_name = NULL
--	select @curve_name = curve_name from source_price_curve_def where source_curve_def_id = @price_id
	
----	select @new_formula = @new_formula + '''' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''''
----	select @new_formula = @new_formula + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') 
----	select @new_formula = @new_formula + '"' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + '"'
--	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) + '-UNKNOWN') + ''


--	set @index =@index_next + 1 
--END

--FOR EOHHOurs
DECLARE  @recorder_id VARCHAR(200), @channel VARCHAR(10)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0) 
BEGIN
	select @index = charindex('EOHHours(', @formula, @index)
	if @index = 0
	begin
		set @new_formula = @new_formula + substring(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end
	
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+9)
	SELECT @meter_id = cast(NULLIF(SUBSTRING(@formula, @index+9, @index_next - @index - 9),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @channel = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
	
	--SELECT @meter_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)
	SET @recorder_id = NULL
	select @recorder_id = recorderid from meter_id where meter_id = @meter_id
	
	select @new_formula = @new_formula + '' + isnull(@recorder_id, cast(@meter_id as varchar)) + ',' + @channel+ ''
	
--	select @new_formula = @new_formula + '' + isnull(@recorder_id, cast(@meter_id as varchar) + '') + ''
	set @index = @index_next + 1 
END

-- ## Added for function Channel
DECLARE @value_id VARCHAR(100) , @block_defintion VARCHAR(100)
set @index = 1
set @index_next = 1
set @formula = @new_formula

--select @formula

set @new_formula = ''

while (@index <> 0)

BEGIN
	select @index = charindex('Channel(', @formula, @index)
	if @index = 0
	begin
		set @new_formula = @new_formula + substring(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end
	
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+8)
	SELECT @channel = cast(NULLIF(SUBSTRING(@formula, @index+8, @index_next - @index - 8),NULL) as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @value_id = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
	--SELECT @meter_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)
	SET @block_defintion = NULL
	IF NULLIF(@value_id,'NULL') IS NOT NULL
		select @block_defintion = description from static_data_value where value_id = @value_id
	
	select @new_formula = @new_formula + '' + @channel + ',' + isnull(@block_defintion, cast(@value_id as varchar)) + ''
	
--	select @new_formula = @new_formula + '' + isnull(@recorder_id, cast(@meter_id as varchar) + '') + ''
	set @index = @index_next + 1 
END




--	set @new_formula = replace(@new_formula, 'When', ' When ') -- add white space
--	set @new_formula = replace(@new_formula, 'Case', ' Case ') -- add white space
--	set @new_formula = replace(@new_formula, 'Between', ' Between ') -- add white space
--	set @new_formula = replace(@new_formula, 'AND', ' AND ') -- add white space
--	set @new_formula = replace(@new_formula, 'OR', ' OR ') -- add white space
--	set @new_formula = replace(@new_formula, 'Else', ' Else ') -- add white space
--	set @new_formula = replace(@new_formula, 'Then', ' Then ') -- add white space
--	set @new_formula = replace(@new_formula, 'End', ' End ') -- add white space


--SELECT @new_formula

--Now convert for Yearly curve
--SET @index = 1
--SET @index_next = 1
--SET @formula = @new_formula
--SET @new_formula = ''
--for 3Hrs2Samples
/*
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('3Hrs2Samples(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 13 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 13)
    --select @index, @index_next
    --SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
    --SET @value_id = (SELECT TOp 1 SUBSTRING(item, CHARINDEX('(', item) + 1,LEN(item)) ite FROM dbo.FNASplit('Channel(1,291976)', ',') d ) 
    SELECT @curve_id = CAST(
               SUBSTRING(@formula, @index + 13, @index_next -@index -13) AS 
               VARCHAR
           )
    
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR)) 
           + ')'
    
    SET @index = @index_next + 1
END
*/

-- Convert for the ContractPriceValue
DECLARE @index_group VARCHAR(50)
DECLARE @index_group_name VARCHAR(50)

SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('ContractPriceValue(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 19 -@index_next)
   
    SET @curve_name = NULL
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index + 19) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+19, @index_next - @index - 19)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index + 19)	
		SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 19, @index_next - @index -19) AS INT)
		SELECT @curve_name = curve_name FROM source_price_curve_def WHERE  source_curve_def_id = @curve_id
	END
	
	SET @index = @index_next
    SELECT @index_next = CHARINDEX(',', @formula, @index + 1)
    --IF NULLIF(@granularity_id,'NULL') IS NOT NULL	
    SELECT @granularity_id = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
    
	SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @index_group = CAST( SUBSTRING(@formula, @index +1, @index_next -@index -1) AS VARCHAR )
    
   
    SET @granularity_name = NULL  
    IF NULLIF(@granularity_id,'NULL') IS NOT NULL
    SELECT @granularity_name = code FROM   static_data_value WHERE  CAST(value_id AS VARCHAR) = @granularity_id
    
    
    SET @index_group_name = NULL
    SELECT @index_group_name = code FROM static_data_value WHERE CAST (value_id AS VARCHAR) = @index_group 
 	SELECT @new_formula = @new_formula + '' +  ISNULL(@curve_name, CAST(@curve_id AS VARCHAR(10)) + '-UNKNOWN')  + ',' + ISNULL(@granularity_name, 'NULL') + ',' + ISNULL(@index_group_name, 'NULL') 

    SET @index = @index_next + 1
END
--SELECT @new_formula

--Now convert for AverageDaily Price
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    DECLARE  @month_num VARCHAR(5) = NULL
    --SELECT @new_formula
    SELECT @index = CHARINDEX('AverageDailyPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 18 - @index_next)	
    
    SET @curve_name = NULL
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index + 18) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+18, @index_next - @index - 18)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index + 18)	
		SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 18, @index_next - @index -18) AS INT)
		SELECT @curve_name = curve_name FROM source_price_curve_def WHERE source_curve_def_id = @curve_id
	END
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)	
	SELECT @month_num = CAST(SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS VARCHAR)
    
	SELECT  @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR(20)) + '-UNKNOWN')  + ',' + isnull(@month_num, 0)
    SET @index = @index_next + 1
END
-- Convert DealSetPrice
--DECLARE @deal_type_name VARCHAR(200)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('DealSetPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 13 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 13)
    --select @index, @index_next
    --SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
    --SET @value_id = (SELECT TOp 1 SUBSTRING(item, CHARINDEX('(', item) + 1,LEN(item)) ite FROM dbo.FNASplit('Channel(1,291976)', ',') d ) 
    SELECT @deal_type_id = CAST(
               SUBSTRING(@formula, @index + 13, @index_next -@index -13) AS 
               VARCHAR
           )
    
    SET @deal_type_name = NULL
    SELECT @deal_type_name = deal_type_id
    FROM   source_deal_type
    WHERE  source_deal_type_id = @deal_type_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@deal_type_name, CAST(@deal_type_id AS VARCHAR)) 
           + ''
    
    SET @index = @index_next + 1
END

--For InterruptVolume
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('InterruptVol(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 13 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 13)
    --select @index, @index_next
    --SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
    --SET @value_id = (SELECT TOp 1 SUBSTRING(item, CHARINDEX('(', item) + 1,LEN(item)) ite FROM dbo.FNASplit('Channel(1,291976)', ',') d ) 
    SELECT @granularity_id = CAST(
               SUBSTRING(@formula, @index + 13, @index_next -@index -13) AS 
               VARCHAR
           )
    
    SET @granularity_name = NULL
    SELECT @granularity_name = code
    FROM   static_data_value
    WHERE  value_id = @granularity_id
    --set @deal_subtype_name = isnull(@deal_subtype_name, cast(@deal_subtype_id as varchar) + '-UNKNOWN') + ''
    SELECT @new_formula = @new_formula + '' + ISNULL(
               @granularity_name,
               CAST(@granularity_id AS VARCHAR) + '-UNKNOWN'
           ) + ' '
    SET @index = @index_next + 1
END

-- for peakHours
DECLARE @block_type_id    INT,
		@block_defination_id INT ,
        @block_type_code  VARCHAR(200),
        @block_defination_name VARCHAR(200)
        

SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('PeakHours(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 10 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 10)	
    SELECT @block_type_id = CAST(
               SUBSTRING(@formula, @index + 10, @index_next - @index -10) AS INT
           )
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)	
    SELECT @block_defination_id = CAST(
               CASE SUBSTRING(@formula, @index + 1, @index_next - @index -1)
                    WHEN 'NULL' THEN NULL
                    ELSE SUBSTRING(@formula, @index + 1, @index_next - @index -1)
               END AS INT
           )
    
    
    
    SET @block_type_code = NULL
    --select @deal_subtype_name = deal_type_id from source_deal_type where source_deal_type_id = @deal_subtype_id
    SELECT @block_type_code = code
    FROM   static_data_value
    WHERE  value_id = @block_type_id
    --set @deal_subtype_name = isnull(@deal_subtype_name, cast(@deal_subtype_id as varchar) + '-UNKNOWN') + ''
    SELECT @new_formula = @new_formula + '' + ISNULL (@block_type_code, CAST(@block_type_id AS VARCHAR) + '-UNKNOWN' ) + ','
     --	select * from source_deal_type
    --	print @deal_type_name
    SET @block_defination_name = NULL
    SELECT @block_defination_name = code
    FROM   static_data_value 
    WHERE  value_id = @block_defination_id
    SELECT @new_formula = @new_formula + '' + ISNULL(@block_defination_name, CAST(@block_defination_id AS VARCHAR) + '-UNKNOWN') 
           + ' '
    SET @index = @index_next + 1
END

--DealSettlement
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('DealSettlement(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 15 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 15) 
    SELECT @deal_type_id = CAST(
               SUBSTRING(@formula, @index + 15, @index_next -@index -15) AS 
               VARCHAR
           )
    
    SET @deal_type_name = NULL
    SELECT @deal_type_name = deal_type_id
    FROM   source_deal_type
    WHERE  source_deal_type_id = @deal_type_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@deal_type_name, CAST(@deal_type_id AS VARCHAR)) 
           + ''
    
    SET @index = @index_next + 1
END

-- For StaticCurve
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('StaticCurve(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 12 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 12)	
    SELECT @curve_id = CAST(
               SUBSTRING(@formula, @index + 12, @index_next - @index -12) AS INT
           )
    
    SET @index = @index_next
  
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '-UNKNOWN') 
    SET @index = @index_next + 1
END

--For WACOG_Sale
DECLARE @book_id INT ,
		@book_id_name VARCHAR(250)
		
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('WACOG_Sale(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 11 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 11)
    --select @index, @index_next
    --SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
    --SET @value_id = (SELECT TOp 1 SUBSTRING(item, CHARINDEX('(', item) + 1,LEN(item)) ite FROM dbo.FNASplit('Channel(1,291976)', ',') d ) 
    SELECT @book_id = CAST(
               SUBSTRING(@formula, @index + 11, @index_next -@index -11) AS 
               VARCHAR
           )
    
    SET @book_id_name = NULL
    SELECT @book_id_name = source_system_book_id
    FROM   source_book
    WHERE  source_book_id = @book_id
    --set @deal_subtype_name = isnull(@deal_subtype_name, cast(@deal_subtype_id as varchar) + '-UNKNOWN') + ''
    SELECT @new_formula = @new_formula + '' + ISNULL(
               @book_id_name,
               CAST(@book_id AS VARCHAR) + '-UNKNOWN'
           ) + ''
    SET @index = @index_next + 1
END

--convert prevevents
DECLARE @hours VARCHAR(10)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0) 
BEGIN
	select @index = charindex('PrevEvents(', @formula, @index)
	if @index = 0
	begin
		set @new_formula = @new_formula + substring(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end
	
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+11-@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index+11)
	SELECT @meter_id = cast(NULLIF(SUBSTRING(@formula, @index+11, @index_next - @index - 11),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @channel = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @price_id = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as int)
	
	--SELECT @meter_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)
	SET @recorder_id = NULL
	select @recorder_id = recorderid from meter_id where meter_id = @meter_id
	
	select @new_formula = @new_formula + '' + isnull(@recorder_id, cast(@meter_id as varchar)) + ',' + @channel+ ','
	
	SET @curve_name = NULL
	--select @curve_name = code from static_data_value where value_id = @curve_id
	select @curve_name = curve_name from source_price_curve_def where cast(source_curve_def_id AS VARCHAR) = @price_id
	SET @curve_name = ISNULL(@curve_name, 'NULL')
		
	SET @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @hours = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar)) + ',' + @hours + ''
	
--	select @new_formula = @new_formula + '' + isnull(@recorder_id, cast(@meter_id as varchar) + '') + ''
	set @index = @index_next + 1 
END


--Now convert for 15 minute curve
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
--SELECT @formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('Curve15(', @formula, @index)
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	END
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)
	
	--SELECT @index, @index_next
	SET @curve_name = NULL
	
	IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+8) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+8, @index_next - @index - 8)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index+8)
		SELECT @price_id = CAST(SUBSTRING(@formula, @index+8, @index_next - @index - 8) as int)
		SELECT @curve_name = curve_name FROM source_price_curve_def WHERE source_curve_def_id = @price_id
	END
	
	SELECT @new_formula = @new_formula + '' + isnull(@curve_name, CAST(@price_id as varchar) + '-UNKNOWN') + ''

	SET @index =@index_next + 1 
END

--for AverageHourlyPrice
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('AverageHourlyPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @curve_name = NULL
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 19 -@index_next)
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		--SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 19 -@index_next)
		SELECT @index_next = CHARINDEX(')', @formula, @index+19)+1
		SELECT @curve_name = SUBSTRING(@formula, @index+19, @index_next - @index - 19)
	END
	ELSE
	BEGIN
    
		SELECT @index_next = CHARINDEX(',', @formula, @index + 19)	
		SELECT @curve_id = CAST(
               SUBSTRING(@formula, @index + 19, @index_next - @index -19) AS INT
		)
    END
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @value_id = cast(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
     
    IF @curve_name IS NULL
    BEGIN
    	
		SELECT @curve_name = curve_name
		FROM   source_price_curve_def
		WHERE  source_curve_def_id = @curve_id
	END
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '') + ', '
    SET @block_defintion = NULL
	IF NULLIF(@value_id,'NULL') IS NOT NULL
	SELECT @block_defintion = description from static_data_value where value_id = @value_id
    SELECT @new_formula = @new_formula + '' + ISNULL(@block_defintion, CAST(@value_id AS VARCHAR) + '')
    
    SET @index = @index_next + 1
END

--Relative Period
DECLARE @offset VARCHAR(100) , @offset_defination VARCHAR(100)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('RelativePeriod(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 15 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 15)	
    SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 15, @index_next - @index -15) AS INT)
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @offset = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
     
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '')+ ', '
    SET @offset_defination = NULL
    SELECT @new_formula = @new_formula + '' + ISNULL(@offset_defination, CAST(@offset AS VARCHAR) + '')
    SET @index = @index_next + 1
END

----Relative Period
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('RelativeCurveD(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 15 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 15)	
    SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 15, @index_next - @index -15) AS INT)
    
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @offset = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
     
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '')+ ', '
    SET @offset_defination = NULL
    SELECT @new_formula = @new_formula + '' + ISNULL(@offset_defination, CAST(@offset AS VARCHAR) + '')
    SET @index = @index_next + 1
END

--For RateScheduleFees
SET  @index = 1
SET  @index_next = 1
SET  @formula = @new_formula

SET  @new_formula = ''

WHILE  (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('RateScheduleFee(', @formula, @index)
	IF @index = 0 
	BEGIN
		SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END

	SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+16-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+16)
	SELECT @price_id = cast(SUBSTRING(@formula, @index+16, @index_next - @index - 16) as int)
	
	SET @curve_name = NULL
	SELECT  @curve_name = code from static_data_value where value_id = @price_id
	SELECT  @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''
	SET  @index =@index_next + 1 
END

--for DealFees
set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('DealFees(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+9-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+9)
	--print @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+9, @index_next - @index - 9) as int)
	
	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''
	set @index =@index_next + 1 
	
END
--For DealFVolm
set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('DealFVolm(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+10-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+10)
	--print @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+10, @index_next - @index - 10) as int)
	
	SET @curve_name = NULL
	select @curve_name = code from static_data_value where value_id = @price_id

	select @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''
	set @index =@index_next + 1 
	
END


--For BookMap
SET  @index = 1
SET  @index_next = 1
SET @formula = @new_formula

SET @new_formula = ''

WHILE  (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('BookMap(', @formula, @index)
	If @index = 0 
	BEGIN
		SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END

	SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+8-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+8)
	
	SELECT @book_id = CAST(SUBSTRING(@formula, @index + 8, @index_next -@index -8) AS VARCHAR)
	SET @book_id_name = NULL
    SELECT @book_id_name = CASE  @book_id WHEN 1 THEN group1 WHEN 2 THEN group2  WHEN 3 THEN group3  WHEN 4 THEN group4 END
    FROM   source_book_mapping_clm
	IF @book_id_name IS NULL
		SET @book_id_name = CASE  @book_id WHEN 1 THEN 'Group1' WHEN 2 THEN 'Group2'  WHEN 3 THEN 'Group3'  WHEN 4 THEN 'Group4' END
		
	SELECT  @new_formula = @new_formula + '' + ISNULL(@book_id_name,CAST(@book_id AS VARCHAR) )+ ''
	SET  @index = @index_next + 1 
END

--convert prevevents
DECLARE @book_id1 INT,@book_id2 INT,@book_id3 INT,@book_id4 INT,@book_name1 VARCHAR(100), @book_name2 VARCHAR(100), @book_name3 VARCHAR(100), @book_name4 VARCHAR(100),@deal_type VARCHAR(100)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0) 
BEGIN
	select @index = charindex('TotalVolume(', @formula, @index)
	if @index = 0
	BEGIN
		SET @new_formula = @new_formula + substring(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)
	SELECT @index_next = CHARINDEX(',', @formula, @index+12)
	SELECT @book_id1 = CAST(NULLIF(SUBSTRING(@formula, @index+12, @index_next - @index - 12),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book_id2 = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book_id3 = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as int)
	
	set @index=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book_id4 = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as int)

	SET @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @deal_type_id =  CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') as int)

	SET @book_name1 = NULL
	SET @book_name2 = NULL
	SET @book_name3 = NULL
	SET @book_name4 = NULL
	SET @deal_type = NULL
	select @book_name1 = source_book_name FROM source_book WHERE source_book_id = @book_id1 AND source_system_book_type_value_id =50
	select @book_name2 = source_book_name FROM source_book WHERE source_book_id = @book_id2 AND source_system_book_type_value_id =51
	select @book_name3 = source_book_name FROM source_book WHERE source_book_id = @book_id3 AND source_system_book_type_value_id =52
	select @book_name4 = source_book_name FROM source_book WHERE source_book_id = @book_id4 AND source_system_book_type_value_id =53
	select @deal_type = source_deal_type_name FROM source_deal_type WHERE source_deal_type_id = @deal_type_id

	select @new_formula = @new_formula + '' +ISNULL(@book_name1,'NULL') + ','+ISNULL(@book_name2,'NULL') + ','+ISNULL(@book_name3,'NULL') + ','+ISNULL(@book_name4,'NULL') + ',' + ISNULL(@deal_type,'NULL') + ''
	
	set @index = @index_next + 1 
END
--for DealFloatPrice
DECLARE @deal_id INT,@deal_name  VARCHAR(100)
SET  @index = 1
SET  @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE  (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('DealFloatPrice(', @formula, @index)
	If @index = 0 
	BEGIN
		SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END

	SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+15-@index_next)
	SELECT @index_next = CHARINDEX(')', @formula, @index+15)
	SELECT @deal_id = CAST(SUBSTRING(@formula, @index + 15, @index_next -@index -15) AS VARCHAR)
	
	SET @deal_name = NULL
	SELECT @deal_name = deal_type_id from source_deal_type where source_deal_type_id = @deal_id
	SELECT  @new_formula = @new_formula + '' + ISNULL(@deal_name,CAST(@deal_id AS VARCHAR) )+ ''
	
	SET  @index = @index_next + 1 
END
--For WACOG_Buy
DECLARE  @book1 INT,@book2 INT,@book3 INT,@book4 INT
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE (@index <> 0) 
BEGIN
	SELECT @index = charindex('WACOG_Buy(', @formula, @index)
	IF @index = 0
	BEGIN
		SET @new_formula = @new_formula + substring(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 10 -@index_next)
	
	SELECT @index_next = CHARINDEX(',', @formula, @index + 10)
	SELECT @book_id = cast(NULLIF(SUBSTRING(@formula, @index + 10, @index_next - @index - 10),'NULL') AS VARCHAR) 
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book1 = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1) ,'NULL') AS VARCHAR)
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book2 = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS VARCHAR)
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @book3 = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS VARCHAR)
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @book4 = cast(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS VARCHAR)
	
	SET @book_id_name = NULL
	SET @book_name1 = NULL
	SET @book_name2 = NULL
	SET @book_name3 = NULL
	SET @book_name4 = NULL
	SELECT @book_id_name = source_book_name  FROM  source_book WHERE source_book_id = @book_id
	SELECT @book_name1 =  source_book_name FROM  source_book WHERE source_book_id = @book1
	SELECT @book_name2 =  source_book_name FROM  source_book WHERE source_book_id = @book2
	SELECT @book_name3 =  source_book_name FROM  source_book WHERE source_book_id = @book3
	SELECT @book_name4 =  source_book_name FROM  source_book WHERE source_book_id = @book4
	SELECT @new_formula = @new_formula + '' + ISNULL(@book_id_name, CAST(@book_id as varchar)) + ',' + ISNULL(@book_name1, CAST(@book1 as varchar)) + ',' + ISNULL(@book_name2, CAST(@book2 as varchar)) + ',' + ISNULL(@book_name3, CAST(@book3 as varchar)) + ',' + ISNULL(@book_name4, CAST(@book4 as varchar)) + ''
	SET @index = @index_next + 1 
END

--PriceCurve
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
DECLARE @adder AS FLOAT
DECLARE @multiplier AS FLOAT
--select @formula

SET @new_formula = ''

WHILE (@index <> 0)

BEGIN
    SELECT @index = CHARINDEX('PriceCurve(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 11 -@index_next)
    
    SELECT @index_next = CHARINDEX(',', @formula, @index + 11) 
    SELECT @curve_id = CAST( SUBSTRING(@formula, @index + 11, @index_next - @index -11) AS INT )
    
    SET @index = @index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @adder = CAST(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') AS FLOAT)
	
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @multiplier = CAST(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+1, @index_next - @index - 1))),'NULL') AS FLOAT)
 
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '') + ',' +  ISNULL(CAST(@adder AS VARCHAR), 'NULL') + ',' +  ISNULL(CAST(@multiplier AS VARCHAR), 'NULL')
    SET @index = @index_next + 1
END

---- For FieldValue
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''

WHILE  (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('FieldValue(', @formula, @index)
	If @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
		BREAK
	END

	SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+11-@index_next)
		SELECT @index_next = CHARINDEX(')', @formula, @index+10)
	--select @index, @index_next
	
	SELECT @price_id = cast(SUBSTRING(@formula, @index+11, @index_next - @index - 11) as int)
	SET @curve_name = NULL
	SELECT  @curve_name = code from static_data_value where value_id = @price_id

	SELECT  @new_formula = @new_formula + '' + isnull(@curve_name, cast(@price_id as varchar) ) + ''
	SET  @index =@index_next + 1 
END

--For Average Curve Value
DECLARE  @logical_name VARCHAR(100)

SET @INDEX = 1
SET @index_next = 1
/*
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@INDEX <> 0)
BEGIN
    SELECT @INDEX = CHARINDEX('AverageCurveValue(', @formula, @INDEX)
    IF @INDEX = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
 
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @INDEX + 18 -@index_next)
    SELECT @index_next = CHARINDEX(',', @formula, @INDEX + 18)
    SELECT @logical_name = CAST(NULLIF(SUBSTRING(@formula, @INDEX + 18, @index_next - @INDEX -18) ,'NULL') AS VARCHAR(100))  
    
    
    SET @index = @index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @curve_id = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) AS INT)
	
    SET @INDEX = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @INDEX + 1)
    SELECT @offset = CAST(
               SUBSTRING(@formula, @INDEX + 1, @index_next - @INDEX - 1) AS VARCHAR
           )
	
    SET @curve_name = NULL
    SELECT @curve_name = curve_name FROM source_price_curve_def WHERE  source_curve_def_id = @curve_id
    
    SELECT @new_formula = @new_formula + '' + @logical_name + ',' + ISNULL(@curve_name, CAST(@curve_id as varchar)) 
    SET @offset_defination = NULL
    
    SELECT @new_formula = @new_formula + ',' + ISNULL(@offset_defination, CAST(@offset AS VARCHAR) + '')
    SET @INDEX = @index_next + 1
END*/

-- For AveragePrice
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
DECLARE @baseload_id INT
DECLARE @baseload_name VARCHAR(300)
DECLARE @granularity INT
DECLARE @gran_name VARCHAR(50)

WHILE  (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('AveragePrice(', @formula, @index)
	If @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
		BREAK
	END

	SET  @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+13-@index_next)
	SELECT @index_next = CHARINDEX(',', @formula, @index+13)
	--select @index, @index_next,@formula
	
	
	select @possible_curve_id  =  SUBSTRING(@formula, @index + 13, @index_next - @index - 13)

	--PRINT '@possible_curve_id:' + @possible_curve_id
	IF ISNUMERIC(@possible_curve_id) = 1
	begin
		SET @curve_id = CAST(@possible_curve_id AS INT)
		--SELECT @index_next = CHARINDEX(',', @formula, @index + 1)
		SET @index = @index_next
		SELECT @index_next = CHARINDEX(',', @formula, @index + 1)
	end
	ELSE
	begin
		SET @curve_id = NULL
		SELECT @index = CHARINDEX(')', @formula, @index_next+1)
		SELECT @index = CHARINDEX(',', @formula, @index+1)
		SELECT @index_next = CHARINDEX(',', @formula, @index+1)
		set @new_formula=LEFT(@formula,@index-1)
	end
     

	SELECT @curve_name = curve_name FROM source_price_curve_def WHERE  source_curve_def_id = @curve_id
	

	SELECT @baseload_id = CAST(NULLIF(SUBSTRING(@formula, @index + 1, @index_next - @index - 1), 'NULL') AS INT)

	SELECT @baseload_name = code FROM static_data_value AS sdv WHERE sdv.value_id = @baseload_id
	
	
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)	
	SELECT @granularity = CAST(NULLIF(SUBSTRING(@formula, @index + 1, @index_next - @index - 1), 'NULL') AS INT)
	
	SELECT @gran_name = code FROM static_data_value AS sdv WHERE sdv.value_id = @granularity
	
	SELECT @new_formula = isnull(@new_formula,'') + '' +  COALESCE(@curve_name, '')  + ',' +  ISNULL(CAST(@baseload_name AS VARCHAR), 'NULL') + ',' +  ISNULL(CAST(@gran_name AS VARCHAR), 'NULL')


	SET  @index = @index_next + 1 
END
--For GetBookID
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('GetBookID(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 10 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 10)
    SELECT @book_id = CAST(SUBSTRING(@formula, @index + 10, @index_next -@index -10) AS VARCHAR)
    
    SET @book_id_name = NULL
    SELECT @book_id_name = source_book_name
    FROM   source_book
    WHERE  source_book_id = @book_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@book_id_name, CAST(@book_id AS VARCHAR) + '-UNKNOWN') + ''
    
    SET @index = @index_next + 1
END

-- for GetLogicalValue 
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('GetLogicalValue(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 16 - @index_next)	
	SELECT @index_next = CHARINDEX(',', @formula, @index + 16)	
	SELECT @mapping_table_id = CAST( SUBSTRING(@formula, @index + 16, @index_next -@index -16) AS  VARCHAR)
	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)	
	SELECT @logical_name = CAST(SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS VARCHAR)
    SET @mapping_name = NULL
    SELECT @mapping_name = mapping_name FROM generic_mapping_header  WHERE  mapping_table_id = @mapping_table_id
	SELECT  @new_formula = @new_formula + '' + ISNULL(@mapping_name, CAST(@mapping_table_id AS VARCHAR)) + ',' +  ISNULL(@logical_name, NULL)	
    SET @index = @index_next + 1
END



----########## For UDF Detail Charges
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN	
	SELECT @index = CHARINDEX('UDFDetailValue(', @formula, @index)
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	END
	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+15-@index_next)
	SELECT @index_next = CHARINDEX(')', @formula, @index+14)
	--SELECT @index, @index_next
	
	SELECT @price_id = CAST(SUBSTRING(@formula, @index+15, @index_next - @index - 15) as int)
	
	SET @curve_name = NULL
	SELECT @curve_name = code FROM static_data_value WHERE value_id = @price_id
	SELECT @new_formula = @new_formula + '' + isnull(@curve_name, CAST(@price_id as varchar) ) + ''
	SET @index =@index_next + 1 
END

--for AverageYrlyPrice
DECLARE @curve_function1 VARCHAR(200)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('AverageYrlyPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 17 -@index_next)
		SELECT @index_next = CHARINDEX(')', @formula, @index+17)+1
		SELECT @curve_function1 = SUBSTRING(@formula, @index+17, @index_next - @index - 17)
	END
	ELSE
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 17 -@index_next)
		SELECT @index_next = CHARINDEX(',', @formula, @index + 17)
		SELECT @curve_function1 = SUBSTRING(@formula, @index + 17, @index_next - @index -17) 
    END
    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
	SELECT @value_id = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)
    
    IF ISNUMERIC(@curve_function1) = 1
    BEGIN
    	SET @curve_id = @curve_function1	     
		SET @curve_name = NULL
		SELECT @curve_name = curve_name
		FROM   source_price_curve_def
		WHERE  source_curve_def_id = @curve_id	    
		SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '') + ', '	    
    END
    ELSE
    BEGIN    	 
    	SELECT @new_formula = @new_formula + '' + @curve_function1 + ', '	    	
    END
    
	SET @index = @index_next + 1
    SET @block_defintion = NULL		
	SELECT @block_defintion = CASE 
	                               WHEN @value_id = 0 THEN 'Simple Average'
	                               ELSE 'Volume Weighted Average'
	                          END
	SELECT @new_formula = @new_formula + '' + ISNULL(@block_defintion, CAST(@block_defintion AS VARCHAR) + '')
END

--for AverageMnthlyPrice
DECLARE @curve_function VARCHAR(200)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('AverageMnthlyPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
   
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 19 -@index_next)
		SELECT @index_next = CHARINDEX(')', @formula, @index+19)+1
		SELECT @curve_function = SUBSTRING(@formula, @index+19, @index_next - @index - 19)
	END
	ELSE
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 19 -@index_next)
		SELECT @index_next = CHARINDEX(',', @formula, @index + 19)
		SELECT @curve_function = SUBSTRING(@formula, @index + 19, @index_next - @index -19) 
	END

    SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
	SELECT @value_id = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)

    IF ISNUMERIC(@curve_function) = 1
    BEGIN
    	SET @curve_id = @curve_function		     
		SET @curve_name = NULL
		SELECT @curve_name = curve_name
		FROM   source_price_curve_def
		WHERE  source_curve_def_id = @curve_id	    
		SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '') + ', '
    END
    ELSE
    BEGIN
    	SELECT @new_formula = @new_formula + '' + @curve_function + ', '	    	
    END
    
	SET @index = @index_next + 1
    SET @block_defintion = NULL		
	SELECT @block_defintion = CASE 
	                               WHEN @value_id = 0 THEN 'Simple Average'
	                               ELSE 'Volume Weighted Average'
	                          END
	SELECT @new_formula = @new_formula + '' + ISNULL(@block_defintion, CAST(@block_defintion AS VARCHAR) + '')
END

-- For AverageQVol
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN	
	SELECT @index = CHARINDEX('AverageQVol(', @formula, @index)
	
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
		BREAK
	END
	
	SET @meter_name = NULL
	SET @channel_desc = NULL

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)
	
	IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+12)+1
		SELECT @meter_name = SUBSTRING(@formula, @index+12, @index_next - @index - 12)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index+12)	
		SELECT @meter_id = CAST(NULLIF(SUBSTRING(@formula, @index+12, @index_next - @index - 12),'NULL') AS INT)
		SELECT @meter_name = recorderid FROM meter_id WHERE meter_id = @meter_id
	END

	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)	
	SELECT @channel_no = CAST(NULLIF(SUBSTRING(@formula, @index+1, @index_next - @index - 1),'NULL') AS INT)
	SELECT @channel_desc = ISNULL(channel_description,channel) FROM recorder_properties WHERE meter_id = @meter_id AND channel = @channel_no
	
	IF @channel_desc IS NULL
		SET @channel_desc = @channel_no
	
	SELECT @new_formula = @new_formula + '' + ISNULL(CAST(@meter_name AS VARCHAR(100)), CAST(@meter_id AS VARCHAR(10)) + '-UNKNOWN') + ',' + isnull(@channel_desc, @channel_no)
	SET @index = @index_next + 1 
END
-- for AverageQtrDailyPrice
DECLARE  @month VARCHAR(5) = NULL
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --Declare  @month VARCHAR(5) = NULL
    --SELECT @new_formula
    SELECT @index = CHARINDEX('AverageQtrDailyPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 21 - @index_next)	    
    SET @curve_name = NULL
    
    IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index + 21) + 1
		SELECT @curve_name = SUBSTRING(@formula, @index+21, @index_next - @index - 21)
		
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index + 21)	
		SELECT @curve_id = CAST(SUBSTRING(@formula, @index + 21, @index_next - @index -21) AS INT)
		SELECT @curve_name = curve_name FROM source_price_curve_def WHERE source_curve_def_id = @curve_id
	END   

	SET @index = @index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index + 1)	
	SELECT @month = CAST(SUBSTRING(@formula, @index + 1, @index_next - @index - 1) AS VARCHAR)
    
    SELECT  @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR(20)) + '-UNKNOWN')  + ',' + ISNULL(@month, 0)
    SET @index = @index_next + 1
END

--For TimeSeriesData
DECLARE @time_series_id INT,@time_series_name VARCHAR(200)
set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('GetTimeSeriesData(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+18-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+18)

	
	SELECT @time_series_id = cast(SUBSTRING(@formula, @index+18, @index_next - @index - 18) as int)
	
	SET @time_series_name = NULL
	select @time_series_name = time_series_name from time_series_definition where time_series_definition_id = @time_series_id

	select @new_formula = @new_formula + '' + isnull(@time_series_name, cast(@time_series_id as varchar) ) + ''
	set @index =@index_next + 1 
	
END

--For CptMeterVolm
DECLARE @country_id INT, @country VARCHAR(100)
set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('CptMeterVolm(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+13-@index_next)

	SELECT @index_next = CHARINDEX(',', @formula, @index+13)

	
	SELECT @block_type = cast(SUBSTRING(@formula, @index+13, @index_next - @index - 13) as int)
	SET @block_defination_code = NULL
    SELECT @block_defination_code = code FROM   static_data_value WHERE  value_id = @block_type

	SET @index = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @index + 1)
    SELECT @country_id = CAST(SUBSTRING(@formula, @index+1, @index_next - @index - 1) as VARCHAR)	
     
    SET @country = NULL
    SELECT @country = code FROM static_data_value WHERE value_id = @country_id

	select @new_formula = @new_formula + '' + isnull(@block_defination_code, cast(@block_type as varchar) ) + ','+isnull(@country, cast(@country_id as varchar) )
	set @index =@index_next + 1 
	
END

 --For PriorFinalizedAmount

set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('PriorFinalizedAmount(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+21-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+21)

	
	SELECT @line_item_id = cast(SUBSTRING(@formula, @index+21, @index_next - @index - 21) as int)
	
	SET @line_item_name = NULL
	select @line_item_name = code from static_data_value where value_id = @line_item_id

	select @new_formula = @new_formula + '' + isnull(@line_item_name, cast(@line_item_id as varchar) ) + ''
	set @index =@index_next + 1 
	
END

--For PriorFinalizedVol

set @index = 1
set @index_next = 1
set @formula = @new_formula

set @new_formula = ''

while (@index <> 0)
BEGIN
	SELECT @index = CHARINDEX('PriorFinalizedVol(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+18-@index_next)

	SELECT @index_next = CHARINDEX(')', @formula, @index+18)

	
	SELECT @line_item_id = cast(SUBSTRING(@formula, @index+18, @index_next - @index - 18) as int)
	
	SET @line_item_name = NULL
	select @line_item_name = code from static_data_value where value_id = @line_item_id

	select @new_formula = @new_formula + '' + isnull(@line_item_name, cast(@line_item_id as varchar) ) + ''
	set @index =@index_next + 1 
	
END
 

---- For MeterVolmUK
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
--SELECT @formula

SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
	
	SELECT @index = CHARINDEX('MeterVolmUK(', @formula, @index)
	IF @index = 0 
	BEGIN
		SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		BREAK
	END
	
	SET @meter_name = NULL
	SET @channel_desc = NULL

	SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+12-@index_next)	
	
	
	IF SUBSTRING(@formula, @index, LEN(@formula)) LIKE '%GetLogicalValue%'
	BEGIN
		SELECT @index_next = CHARINDEX(')', @formula, @index+12)+1
		SELECT @meter_name = SUBSTRING(@formula, @index+12, @index_next - @index - 12)
	END
	ELSE
	BEGIN
		SELECT @index_next = CHARINDEX(',', @formula, @index+12)	
		SELECT @meter_id = CAST(NULLIF(SUBSTRING(@formula, @index+12, @index_next - @index - 12),'NULL') AS INT)
		SELECT @meter_name = recorderid FROM meter_id WHERE meter_id = @meter_id
	END

	
	SET @index=@index_next
	SELECT @index_next = CHARINDEX(')', @formula, @index+1)		
		
	SELECT @block_type = CAST(NULLIF(SUBSTRING(@formula, @index + 1, @index_next - @index -1),'NULL') AS INT)
	SET @block_defination_code = NULL
    SELECT @block_defination_code = CASE  @block_type WHEN 1 THEN 'Super Red'  WHEN 2 THEN 'Red'  WHEN 3 THEN 'Amber'  WHEN 4 THEN 'Green' END 
	SELECT @new_formula = @new_formula + '' + ISNULL(CAST(@meter_name AS VARCHAR(100)), CAST(@meter_id AS VARCHAR(10)) + '-UNKNOWN') + ',' + isnull(@block_defination_code, 'NULL') 
	SET @index =@index_next + 1 
END

-- GetUkRates
DECLARE @rate_group_id INT
DECLARE @rate_group VARCHAR(100) 
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula

SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('GetUkRates(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 11 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 11)
    
    
    SELECT @rate_group_id = CAST(SUBSTRING(@formula, @index + 11, @index_next - @index - 11) AS INT)
    
    SET @rate_group = NULL
    SELECT @rate_group = CASE @rate_group_id WHEN 1 THEN 'Unit Rate 1'WHEN 2 THEN 
                                  'Unit Rate 2'WHEN 3 THEN 'Unit Rate 3'WHEN 4 THEN 
                                  'Unit Rate 4'WHEN 5 THEN 
                                  'Fixed charge p/MPAN/day'WHEN 6 THEN 
                                  'Capacity charge Gbp/kVA/day'WHEN 7 THEN 
                                  'Reactive power charge Gbp/kVArh'WHEN 8 THEN 
                                  'Excess capacity chargep/kVA/day' ELSE 'UNKNOWN' END
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@rate_group, CAST(@rate_group_id AS VARCHAR)) + ''
    
    SET @index = @index_next + 1
END
 
/*
-- Convert DealSetPrice
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    --SELECT @value_id
    --SELECT @new_formula
    SELECT @index = CHARINDEX('DealSetPrice(', @formula, @index)
    IF @index = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
    
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index + 13 -@index_next)
    
    SELECT @index_next = CHARINDEX(')', @formula, @index + 13)
    --SELECT @index, @index_next
    --SELECT @bucket_id = ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(@formula, @index+16, @index_next - @index - 16))),'NULL'),'')
    --SET @value_id = (SELECT TOp 1 SUBSTRING(item, CHARINDEX('(', item) + 1,LEN(item)) ite FROM dbo.FNASplit('Channel(1,291976)', ',') d ) 
    SELECT @deal_type_id = CAST(
               SUBSTRING(@formula, @index + 13, @index_next -@index -13) AS 
               VARCHAR
           )
    
    SET @deal_type_name = NULL
    SELECT @deal_type_name = deal_type_id
    FROM   source_deal_type
    WHERE  source_deal_type_id = @deal_type_id
    
    SELECT @new_formula = @new_formula + '' + ISNULL(@deal_type_name, CAST(@deal_type_id AS VARCHAR)) 
           + ')'
    
    SET @index = @index_next + 1
END
*/

-- Derived day ahead 
DECLARE @curve_id1 INT
DECLARE @curve_name1 VARCHAR(20)
DECLARE @holiday_value_id INT 
DECLARE @holiday_name VARCHAR(80)
SET @INDEX = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@INDEX <> 0)
BEGIN
    SELECT @INDEX = CHARINDEX('DeriveDayAhead(', @formula, @INDEX)
    IF @INDEX = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
 
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @INDEX + 15 -@index_next)
    SELECT @index_next = CHARINDEX(',', @formula, @INDEX + 15)  
    SELECT @curve_id = CAST(
               SUBSTRING(@formula, @INDEX + 15, @index_next - @INDEX -15) AS INT
           )
 
    SET @INDEX=@index_next
	SELECT @index_next = CHARINDEX(',', @formula, @index+1)	
	SELECT @curve_id1 = CAST(
		SUBSTRING(@formula, @index+1, @index_next - @INDEX-1) AS INT
	       )
    
    SET @INDEX = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @INDEX + 1)
    SELECT @holiday_value_id = CAST(
               SUBSTRING(@formula, @INDEX + 1, @index_next - @INDEX - 1) AS VARCHAR
           )
 
    SET @curve_name = NULL
    SELECT @curve_name = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id
    
    SET @curve_name1 = NULL
	SELECT @curve_name1 = curve_name
    FROM   source_price_curve_def
    WHERE  source_curve_def_id = @curve_id1
    
    SET @holiday_name = NULL
    SELECT @holiday_name = code 
    FROM   static_data_value 
    WHERE  value_id = @holiday_value_id

    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name, CAST(@curve_id AS VARCHAR) + '')
           + ', '
    SELECT @new_formula = @new_formula + '' + ISNULL(@curve_name1, CAST(@curve_id1 AS VARCHAR) + '')
           + ', '
    SELECT @new_formula = @new_formula + '' + ISNULL(@holiday_name, CAST(@holiday_value_id AS VARCHAR) + '')
    SET @INDEX = @index_next + 1
END

--Generic Mapping Contract Fee
DECLARE @row_value VARCHAR(20)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('GetGMContractFee(', @formula, @index)
     IF @INDEX = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
 
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @INDEX + 17 -@index_next)
   
    SELECT @index_next = CHARINDEX(',', @formula, @INDEX + 17)  
    SELECT @mapping_table_id = CAST(
               SUBSTRING(@formula, @INDEX + 17, @index_next - @INDEX -17) AS INT
           )
 
    SET @INDEX = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @INDEX + 1)
    SELECT @row_value = CAST(
               SUBSTRING(@formula, @INDEX + 1, @index_next - @INDEX - 1) AS VARCHAR
           )
     SET @mapping_name = NULL
     SELECT @mapping_name = mapping_name FROM generic_mapping_header  WHERE  mapping_table_id = @mapping_table_id

    SELECT @new_formula = @new_formula + '' + ISNULL(@mapping_name, CAST(@mapping_table_id AS VARCHAR(20)) + '')
	+ ', '
	--SET @row_value = NULL
    SELECT @new_formula = @new_formula + '' + ISNULL(@row_value, CAST(@row_value as VARCHAR(20)) + '')
    SET @INDEX = @index_next + 1
END

-- ContractFixedPrice
DECLARE @product_type_id INT
DECLARE @product_type_name VARCHAR(1000)
DECLARE @pricing_option_id INT
DECLARE @pricing_option_name VARCHAR(1000)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('ContractFixPrice(', @formula, @index)
     IF @INDEX = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
 
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @INDEX + 17 -@index_next)
   
    SELECT @index_next = CHARINDEX(',', @formula, @INDEX + 17)  
    SELECT @product_type_id = CAST(
               SUBSTRING(@formula, @INDEX + 17, @index_next - @INDEX -17) AS INT
           )
 
    SET @INDEX = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @INDEX + 1)
    SELECT @pricing_option_id = CAST(
               SUBSTRING(@formula, @INDEX + 1, @index_next - @INDEX - 1) AS VARCHAR
           )
     SET @product_type_name = NULL
     SELECT @product_type_name = code FROM static_data_value  WHERE  value_id = @product_type_id

	 SET @pricing_option_name = NULL
	 IF @pricing_option_id = 0
		SET @pricing_option_name = 'Index Price'
	ELSE IF @pricing_option_id =  1
		SET @pricing_option_name = 'Adder'
	ELSE IF @pricing_option_id =  2
		SET @pricing_option_name = 'Fixed Price'

    SELECT @new_formula = @new_formula + '' + ISNULL(@product_type_name, CAST(@product_type_id AS VARCHAR(20)) + '')
	+ ', '
	--SET @row_value = NULL
    SELECT @new_formula = @new_formula + '' + ISNULL(@pricing_option_name, CAST(@pricing_option_id as VARCHAR(20)) + '')
    SET @INDEX = @index_next + 1
END


-- ContractFees
DECLARE @product_type_id1 INT
DECLARE @product_type_name1 VARCHAR(1000)
DECLARE @charges_id INT
DECLARE @charges_name VARCHAR(1000)
SET @index = 1
SET @index_next = 1
SET @formula = @new_formula
SET @new_formula = ''
WHILE (@index <> 0)
BEGIN
    SELECT @index = CHARINDEX('ContractFees	(', @formula, @index)
     IF @INDEX = 0
    BEGIN
        SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, LEN(@formula) + 1 - @index_next)
        BREAK
    END
 
    SET @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @INDEX + 13 -@index_next)
   
    SELECT @index_next = CHARINDEX(',', @formula, @INDEX + 13)  
    SELECT @product_type_id1 = CAST(
               SUBSTRING(@formula, @INDEX + 13, @index_next - @INDEX -13) AS INT
           )
 
    SET @INDEX = @index_next
    SELECT @index_next = CHARINDEX(')', @formula, @INDEX + 1)
    SELECT @charges_id = CAST(
               SUBSTRING(@formula, @INDEX + 1, @index_next - @INDEX - 1) AS VARCHAR
           )
     SET @product_type_name1 = NULL
     SELECT @product_type_name1 = code FROM static_data_value  WHERE  value_id = @product_type_id1

	 SET @charges_name = NULL
     SELECT @charges_name = code FROM static_data_value  WHERE  value_id = @charges_id

    SELECT @new_formula = @new_formula + '' + ISNULL(@product_type_name1, CAST(@product_type_id1 AS VARCHAR(20)) + '')
	+ ', '
	--SET @row_value = NULL
    SELECT @new_formula = @new_formula + '' + ISNULL(@charges_name, CAST(@charges_id as VARCHAR(20)) + '')
    SET @INDEX = @index_next + 1
END

--Now convert for GetPoolWACOGPrice curve
DECLARE @WACOG_group_id INT
DECLARE @WACOG_group_name VARCHAR(100)
set @index = 1
set @index_next = 1
set @new_formula = ''

while (@index <> 0)
BEGIN

	SELECT @index = CHARINDEX('GetWACOGPoolPrice(', @formula, @index)
	If @index = 0 
	begin
		set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, len(@formula) + 1 - @index_next)
		break
	end

	set @new_formula = @new_formula + SUBSTRING(@formula, @index_next, @index+18-@index_next)
	---print @new_formula

	SELECT @index_next = CHARINDEX(')', @formula, @index+18)
	--select @index, @index_next
	
	SELECT @WACOG_group_id = cast(SUBSTRING(@formula, @index+18, @index_next - @index - 18) as int)
	
	SET @WACOG_group_name = NULL
	select @WACOG_group_name = wacog_group_name from wacog_group where wacog_group_id = @WACOG_group_id

	select @new_formula = @new_formula + '' + isnull(@WACOG_group_name, cast(@WACOG_group_id as varchar(100)) + '-UNKNOWN') + ''


	set @index =@index_next + 1 
END

RETURN  @new_formula
END