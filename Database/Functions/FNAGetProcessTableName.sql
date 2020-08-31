IF OBJECT_ID(N'FNAGetProcessTableName', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetProcessTableName]
GO 

CREATE FUNCTION [dbo].[FNAGetProcessTableName]
(
	@as_of_date  DATETIME,
	@table_name  VARCHAR(50)
)
RETURNS VARCHAR(8000) AS    
BEGIN  
DECLARE @Sql_Select			VARCHAR(8000)  
DECLARE @month_1st_date		VARCHAR(30)  
DECLARE @month_last_date	VARCHAR(30)  
DECLARE @prefix_table		VARCHAR(30)  
DECLARE @dbase_name			VARCHAR(50)  
DECLARE @frequency_type		VARCHAR(1)
	 
IF  @as_of_date IS NULL  
	 SET  @Sql_Select = @table_name  
ELSE   
	BEGIN   
		--SELECT @frequency_type = ISNULL(MAX(frequency_type), 'm')
		--FROM   [process_table_archive_policy]
		--WHERE   tbl_name = @table_name
		SELECT  @frequency_type = ISNULL(MAX(archive_frequency), 'm')
		FROM archive_data_policy 
		WHERE main_table_name = @table_name
		
		IF @frequency_type = 'd'
			SET  @month_1st_date = @as_of_date 
		ELSE 
			SET @month_1st_date = CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-01'  
	  
			SELECT @prefix_table = prefix_location_table, @dbase_name = dbase_name 
			FROM  process_table_location 
			WHERE as_of_date = @month_1st_date
			AND  tbl_name = @table_name  
		   
		IF ISNULL(@prefix_table, '') = ''  
			SET  @Sql_Select = @table_name  
		ELSE   
			SET @Sql_Select = ISNULL(@dbase_name, 'dbo') + '.' + @table_name + @prefix_table  
	END   
	RETURN  @Sql_Select  
END  