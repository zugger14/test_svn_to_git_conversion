IF OBJECT_ID(N'FNAGetProcessTableInternal', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetProcessTableInternal]
GO 

CREATE  FUNCTION [dbo].[FNAGetProcessTableInternal] (@as_of_date DATETIME, @table_name VARCHAR(50))
RETURNS VARCHAR(8000) AS  
BEGIN
DECLARE @Sql_Select			VARCHAR(8000)
DECLARE @month_1st_date		VARCHAR(30)
DECLARE @month_last_date	VARCHAR(30)
DECLARE @prefix_table		VARCHAR(30)
DECLARE @dbase_name			VARCHAR(50)
DECLARE @frequency_type		VARCHAR(1)
	--if as_of_date not supplied, take all data from main table (i.e. for all as_of_date)
	IF  @as_of_date IS NULL 
			SET  @Sql_Select = ' (SELECT  * FROM dbo.' + @table_name + ' WHERE 1 = 1)'
	ELSE 
		BEGIN
			--SELECT  @frequency_type = ISNULL(MAX(frequency_type), 'm')
			--FROM   [process_table_archive_policy]
			--WHERE  tbl_name = @table_name
			
			SELECT @frequency_type = ISNULL(MAX(archive_frequency), 'm') 
			FROM archive_data_policy 
			WHERE main_table_name = @table_name
			
			IF @frequency_type = 'd'
				BEGIN
					SET @month_1st_date = @as_of_date
					SET @month_last_date = @as_of_date
				END
			ELSE
				BEGIN
					SET @month_1st_date = CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-01'
					SET @as_of_date = DATEADD(d, -1, DATEADD(m, 1, CAST(@month_1st_date AS DATETIME)))
					SET @month_last_date = CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-' + CAST(DAY(@as_of_date) AS VARCHAR)
				  
				END
			--set @month_1st_date=cast(floor(cast(@month_1st_date as float)) as datetime)
				SELECT @prefix_table = prefix_location_table, @dbase_name = dbase_name 
				FROM process_table_location 
				WHERE as_of_date = @month_1st_date 
				AND tbl_name = @table_name
				
				IF ISNULL(@prefix_table, '') = ''
					SET @Sql_Select = ' (SELECT * FROM  dbo.' + @table_name + ' where ' + CASE WHEN @table_name = 'source_deal_pnl' THEN  ' pnl_as_of_date ' ELSE  ' as_of_date ' END  + ' BETWEEN ''' + @month_1st_date + ''' AND ''' + @month_last_date + ''')'
				ELSE 
					SET  @Sql_Select = ' (SELECT * FROM ' + ISNULL(@dbase_name, 'dbo') + '.' + @table_name + @prefix_table + ' WHERE ' + CASE WHEN @table_name = 'source_deal_pnl' THEN ' pnl_as_of_date ' ELSE ' as_of_date ' END + ' BETWEEN  ''' + @month_1st_date + ''' AND ''' + @month_last_date + ''')'
		END 
	RETURN  @Sql_Select
END
