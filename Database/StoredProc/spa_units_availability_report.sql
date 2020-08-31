
/****** Object:  StoredProcedure [dbo].[spa_units_availability_report]    Script Date: 07/29/2009 18:33:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_units_availability_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_units_availability_report]
/****** Object:  StoredProcedure [dbo].[spa_units_availability_report]    Script Date: 07/29/2009 18:33:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spa_units_availability_report]
		@sub VARCHAR(200)=null,
		@sta VARCHAR(200)=NULL,
		@book VARCHAR(200)=NULL,
		@aggregation CHAR(1) = 's',
		@granularity int = NULL,
		@generator_id VARCHAR(50) = NULL,
		@date_time_from DATETIME,
		@date_time_to DATETIME 
AS
SET NOCOUNT ON
BEGIN
	
	
--DECLARE @sub VARCHAR(200),@sta VARCHAR(200),@book VARCHAR(200),
--	@generator_id VARCHAR(200),@from_date DATETIME,@to_date DATETIME,
--	@granuality INT,@aggregation CHAR(1),
--	@date_time_from DATETIME,
--	@date_time_to DATETIME 
--
--SELECT @sub=null,@sta=NULL,@book =NULL,@generator_id =NULL,@date_time_from='2008-01-01',@date_time_to =NULL,
--@aggregation ='s',@granuality=null
--	
--DROP table  #tmp_data
--DROP table  #tmp_data1
--DROP table  #tmp_hr

--DECLARE @date_part VARCHAR(10)
--DECLARE @date_incr INT 
--DECLARE @temp_date_time DATETIME
 
 
DECLARE @st VARCHAR(MAX)
SET @st=''

 
IF @sub IS NOT NULL
	SET @st=@st+' AND stra.parent_entity_id in (' +@sub+')'
IF @sta IS NOT NULL
	SET @st=@st+' AND stra.entity_id in (' +@sta+')'
IF @book IS NOT NULL
	SET @st=@st+' AND book.entity_id in (' +@book+')'

IF @generator_id IS NOT NULL
	SET @st=@st+' AND g.source_generator_id IN (' +@generator_id +')'

--IF @date_time_from IS NOT NULL
--BEGIN 
--	IF @date_time_to IS NOT NULL
--		SET @st= @st + ' AND (g.generator_start_date>=''' + CAST(@date_time_from AS  varchar) + ''' OR g.generation_end_date<=''' + CAST(@date_time_to AS  varchar) + ''')'
--	ELSE
--		SET @st= @st + ' AND g.generator_start_date>=''' + CAST(@date_time_from AS  varchar) + ''''
--END
--ELSE 
--BEGIN
--	IF @date_time_to IS NOT NULL
--	SET @st= @st + ' AND g.generation_end_date<=''' + CAST(@date_time_to AS  varchar) + ''''
--END
CREATE TABLE #tmp_data(
	source_generator_id INT,
	generator VARCHAR(100) COLLATE DATABASE_DEFAULT,
	X_value float

)
CREATE TABLE #tmp_hr(
dt datetime
);

WITH temp_hr (dt_hr,inc) AS 
(
SELECT @date_time_from,0
	UNION ALL
SELECT DATEADD(hh,1,dt_hr),inc+1 FROM temp_hr WHERE DATEADD(hh,1,dt_hr)<=@date_time_to

)


INSERT INTO #tmp_hr(dt )
 SELECT dt_hr FROM temp_hr
OPTION(MAXRECURSION 0)

SET @st='insert into #tmp_data 
SELECT source_generator_id, REPLACE(g.generator_id,'' '',''_'') source, generator_capacity 
 FROM source_generator g 
LEFT JOIN dbo.portfolio_hierarchy book ON g.book_id=book.entity_id
LEFT JOIN dbo.portfolio_hierarchy stra ON book.parent_entity_id=stra.entity_id
where 1=1 '+@st
--print(@st)

EXEC(@st)


 SELECT a.source_generator_id,a.generator,b.dt X_axis, a.X_value INTO #tmp_data1  
 FROM #tmp_data a CROSS JOIN #tmp_hr b

UPDATE #tmp_data1 SET X_value=o.outage
FROM #tmp_data1 p INNER JOIN power_outage o ON p.X_axis BETWEEN o.actual_start AND o.actual_end
AND o.source_generator_id=p.source_generator_id

	DECLARE @fld_variable VARCHAR(1000)
	SET @fld_variable=''
	SELECT  @fld_variable= @fld_variable + ',['+generator+']' FROM #tmp_data GROUP BY generator
	SET @fld_variable=SUBSTRING(@fld_variable,2,LEN(@fld_variable))


	SET @st='
	SELECT X_axis '+CASE WHEN @fld_variable ='' THEN '' ELSE ',' END + @fld_variable+ '
	FROM 
	(
		SELECT generator, [dbo].[FNATermGrouping](X_axis,'+ CAST(@granularity AS VARCHAR) +') X_axis, 
		' +
		case @aggregation 
			when 'a'	THEN 'AVG'
			when 's'	THEN 'sum'
			when 'x' 	THEN 'max'
			when 'n' 	THEN 'min' 
		end + '(X_value) X_value
		FROM #tmp_data1 group by
		generator, [dbo].[FNATermGrouping](X_axis,'+ CAST(@granularity AS VARCHAR) +') 
	) p '+ CASE WHEN @fld_variable ='' THEN '' ELSE '
	PIVOT
	(' +
	case @aggregation 
		when 'a'	THEN 'AVG'
		when 's'	THEN 'sum'
		when 'x' 	THEN 'max'
		when 'n' 	THEN 'min' 
	end + '  (X_value)
	FOR generator IN
	( '+@fld_variable+' )
	) AS pvt
	ORDER BY X_axis' END 
	


	
--PRINT @st
EXEC(@st)


END

