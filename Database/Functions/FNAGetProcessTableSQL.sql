/****** Object:  UserDefinedFunction [dbo].[FNAGetProcessTableSQL]    Script Date: 07/08/2009 21:51:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetProcessTableSQL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetProcessTableSQL]
/****** Object:  UserDefinedFunction [dbo].[FNAGetProcessTableSQL]    Script Date: 07/08/2009 21:51:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT dbo.FNAGetProcessTableSQL('emissions_inventory','2001-01-01','2001-12-01','3516,1440')
-- SELECT dbo.FNAGetProcessTableSQL('emissions_inventory','2001-01-01 00:00:00.000','2001-12-01 00:00:00.000','3516,1440')

CREATE FUNCTION [dbo].[FNAGetProcessTableSQL] (
		@table_name varchar(50),
		@term_start datetime,
		@term_end DATETIME=null,
		@sub_id VARCHAR(100)=NULL,
		@show_base_period CHAR(1)='n',
		@base_year_from INT,
		@base_year_to INT
	)
RETURNS VARCHAR(1000) AS  
BEGIN 
--declare @table_name varchar(50),@term_start datetime,@term_end datetime,@sub_id VARCHAR(100)
--SELECT @table_name='emissions_inventory',@term_start='2001-01-01 00:00:00.000'
--	,@term_end ='2001-12-01 00:00:00.000',@sub_id=NULL --'3516,1440'
--PRINT @table_name
--PRINT @term_start 
--PRINT 	@term_end 
--PRINT @sub_id
--
	SET @term_start=CAST(CAST(YEAR(@term_start) AS VARCHAR)+'-01-01' AS DATETIME)
	IF  @term_end IS NULL
		set	@term_end=DATEADD(DAY,-1,DATEADD(YEAR,1,@term_start))
	ELSE
		set	@term_end=DATEADD(DAY,-1,DATEADD(YEAR,1,CAST(CAST(YEAR(@term_end) AS VARCHAR)+'-01-01' AS DATETIME)))


	DECLARE @ret_value VARCHAR(1000)
	SET @ret_value='';

	WITH tbl (table_name,term_start,term_end) 
	AS (
	SELECT [dbo].[FNAGetProcessTableName](@term_start,@table_name),@term_start,DATEADD(DAY,-1,DATEADD(YEAR,1,@term_start))
	UNION ALL
	SELECT [dbo].[FNAGetProcessTableName](dateadd(YEAR,1,t.term_start),@table_name),dateadd(YEAR,1,t.term_start),dateadd(YEAR,1,t.term_end)
	FROM tbl t WHERE dateadd(YEAR,1,t.term_end)<=@term_end
	)
	--SELECT   ISNULL(t.table_name,s.table_name) ,t.term_start,t.term_end , s.base_from,s.base_from 
	SELECT  @ret_value =@ret_value +' union all select *'+
		 CASE WHEN s.base_from IS NULL THEN ',0 AS is_base_year' ELSE ',1 AS is_base_year' END+' from '  + ISNULL(t.table_name,s.table_name) +
		 ' where 1=1 ' + 
	 CASE WHEN  t.term_start IS NULL THEN '' 
	 else  
		' and ( ' + case when @table_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between ''' +
		 CAST(t.term_start AS VARCHAR) + ''' and ''' + CAST(t.term_end AS VARCHAR) + ''')' 
	 end
	  + 
	 CASE WHEN  s.base_from IS NULL THEN '' 
	  ELSE 
		' OR (' + case when @table_name='edr_raw_data' then 'edr_date' ELSE 'term_start' END + ' between ''' +
		 CAST(s.base_from AS VARCHAR) + ''' and ''' + CAST(s.base_to AS VARCHAR) + ''')' 
	END
	 from
	(
		SELECT table_name,MIN(term_start) term_start,MAX(term_end) term_end  FROM tbl GROUP BY table_name
	) t 
	full JOIN 
	( 
		SELECT MIN(CAST(CAST(ISNULL(@base_year_from,base_year_from) AS varchar)+'-01-01' AS DATETIME)) base_from,
		MAX(DATEADD(DAY,-1,CAST(CAST(ISNULL(@base_year_to,base_year_to)+1 AS varchar)+'-01-01' AS DATETIME))) base_to,
		[dbo].[FNAGetProcessTableName](CAST(CAST(base_year_from AS varchar)+'-01-01' AS DATETIME),@table_name) table_name 
		FROM fas_subsidiaries f INNER JOIN [dbo].[SplitCommaSeperatedValues](@sub_id) l ON f.fas_subsidiary_id=l.Item
		WHERE @show_base_period='y' 
		GROUP BY [dbo].[FNAGetProcessTableName](CAST(CAST(base_year_from AS varchar)+'-01-01' AS DATETIME),@table_name) 
	) s ON t.table_name=s.table_name

	SET @ret_value=SUBSTRING(@ret_value,11,LEN(@ret_value))
--	PRINT @ret_value


	RETURN(@ret_value)
end