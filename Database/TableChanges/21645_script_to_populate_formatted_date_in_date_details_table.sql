
--Create Table for Date Dimension
IF OBJECT_ID('[dbo].[date_details]') IS NOT NULL DROP TABLE [date_details]
CREATE TABLE	[dbo].[date_details]
	(	[region_id] INT, 
		[sql_date_value] DATE,	--SQL Date format in yyyy-mm-dd format
		[user_date] CHAR(10), -- Date in dd/MM/yyyy or MM/dd/yyyy format based on region
		[sql_date_string] CHAR(10), --Date in yyyy-mm-dd format
		[day_of_month] VARCHAR(2), -- Field will hold day number of month
		[day_suffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[day_name] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[day_of_week] CHAR(1),-- First day Sunday=1 and Saturday=7
		[day_of_quarter] VARCHAR(3),
		[day_of_year] VARCHAR(3),
		[week_of_month] VARCHAR(1),-- Week Number of month 
		[week_of_quarter] VARCHAR(2), --Week Number of the quarter
		[week_of_year] VARCHAR(2),--Week Number of the year
		[month_id] VARCHAR(2), --Number of the month 1 to 12
		[month_name] VARCHAR(9),--January, February etc
		[month_of_quarter] VARCHAR(2),-- month Number belongs to quarter
		[quarter_id] CHAR(1),
		[quarter_name] VARCHAR(9),--First,Second..
		[year_id] CHAR(4),-- year value of Date stored in Row
		[mon_yyyy] CHAR(10), --Jan-2013,Feb-2013
		[yyyymm] CHAR(6),
		[first_day_of_month] DATE,
		[last_day_of_month] DATE,
		[first_day_of_prev_month] DATE,
		[last_day_of_prev_month] DATE,
		[first_day_of_next_month] DATE,
		[last_day_of_next_month] DATE,
		[first_day_of_quarter] DATE,
		[last_day_of_quarter] DATE,
		[first_day_of_year] DATE,
		[last_day_of_year] DATE,
		[first_day_of_prev_year] DATE,
		[last_day_of_prev_year] DATE,
		[first_day_of_next_year] DATE,
		[last_day_of_next_year] DATE,
		[is_weekday] BIT -- 0=Week End ,1=Week day
		
		CONSTRAINT [PK_date_details] PRIMARY KEY CLUSTERED([sql_date_value],[region_id], [user_date])  ON [PRIMARY] 
	)
GO

SET ANSI_PADDING OFF 
GO 
SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'date_details_1')
CREATE NONCLUSTERED INDEX date_details_1 ON dbo.date_details([sql_date_value])
GO

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'date_details_2')
CREATE NONCLUSTERED INDEX date_details_2 ON dbo.date_details(user_date)

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_populate_date_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_populate_date_data]
GO

/***** Create Stored procedure To Fill Date Dimension with Values****/
CREATE PROCEDURE [dbo].[spa_populate_date_data] 
	  @start_date DATETIME = '01/01/1995' --Starting value of Date Range
	, @end_date DATETIME = '01/01/2051' --End Value of Date Range

AS 
BEGIN 
	IF OBJECT_ID('tempdb..#temp_date_format') IS NOT NULL
    DROP TABLE #temp_date_format    

	CREATE TABLE #temp_date_format(
		date_type INT
	)

	INSERT INTO #temp_date_format
	SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 

	DECLARE @region_id as INT;	
	DECLARE @region_cursor as CURSOR;
 
	SET @region_cursor = CURSOR FOR
		SELECT region_id FROM [dbo].[region]
 
	OPEN @region_cursor;
	FETCH NEXT FROM @region_cursor INTO @region_id; --@dtfiscal_year_start(if FY different for each region.Add in region table too)

	WHILE @@FETCH_STATUS = 0  --region Looping
	BEGIN

		--Temporary Variables To Hold the Values During Processing of Each Date of year
		DECLARE
			@day_of_quarter INT,
			@week_of_month INT,
			@current_year INT,
			@current_month INT,
			@current_quarter INT

		/* Table Data type to store the day of week count for the month and year */
		DECLARE @day_of_week TABLE (DOW INT, month_count INT, quarter_count INT, year_count INT)

		INSERT INTO @day_of_week VALUES (1, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (2, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (3, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (4, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (5, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (6, 0, 0, 0)
		INSERT INTO @day_of_week VALUES (7, 0, 0, 0)

		--Extract and assign various parts of Values from Current Date to Variable
		DECLARE @current_date AS DATETIME = @start_date
		SET @current_month = DATEPART(MM, @current_date)
		SET @current_year = DATEPART(YY, @current_date)
		SET @current_quarter = DATEPART(QQ, @current_date)

		--Proceed only if Start Date(Current date ) is less than End date you specified above
		WHILE @current_date < @end_date
		BEGIN
 
			/*Check for Change in month of the Current date if month changed then Change variable value*/
			IF @current_month != DATEPART(MM, @current_date) 
			BEGIN
				UPDATE @day_of_week
				SET month_count = 0
				SET @current_month = DATEPART(MM, @current_date)
			END

			 /* Check for Change in quarter of the Current date if quarter changed then change Variable value */
			IF @current_quarter != DATEPART(QQ, @current_date)
			BEGIN
				UPDATE @day_of_week
				SET quarter_count = 0
				SET @current_quarter = DATEPART(QQ, @current_date)
			END
       
			/* Check for Change in year of the Current date if year changed then change Variable value */
			IF @current_year != DATEPART(YY, @current_date)
			BEGIN
				UPDATE @day_of_week
				SET year_count = 0
				SET @current_year = DATEPART(YY, @current_date)
			END
	
			-- Set values in table data type created above from variables 
			UPDATE @day_of_week
			SET 
				month_count = month_count + 1,
				quarter_count = quarter_count + 1,
				year_count = year_count + 1
			WHERE DOW = DATEPART(DW, @current_date)

			SELECT @day_of_quarter = quarter_count
			FROM @day_of_week
			WHERE DOW = DATEPART(DW, @current_date)

			/* Populate Your Dimension Table with values*/
			INSERT INTO [dbo].[date_details]([region_id] ,
			       [sql_date_value],[user_date],[sql_date_string],[day_of_month],[day_suffix],
			       [day_name],[day_of_week],[day_of_quarter],[day_of_year],[week_of_month],
		           [week_of_quarter],[week_of_year],[month_id],[month_name],[month_of_quarter],[quarter_id],[quarter_name],[year_id],
		           [mon_yyyy],[yyyymm],[first_day_of_month],[last_day_of_month],
				   [first_day_of_prev_month],[last_day_of_prev_month],[first_day_of_next_month],[last_day_of_next_month],
				   [first_day_of_quarter],[last_day_of_quarter],
				   [first_day_of_year],[last_day_of_year],[first_day_of_prev_year],[last_day_of_prev_year],
		           [first_day_of_next_year],[last_day_of_next_year],[is_weekday])
			SELECT DISTINCT
				@region_id as region_id,
				@current_date AS sql_date_value,
				CASE @region_id
					WHEN 1 THEN CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,101)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,101),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,101),1,1,''),CONVERT (CHAR(10),@current_date,101)),'/0','/')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,101), '/0', '/')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,101),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,101),1,1,''),CONVERT (CHAR(10),@current_date,101))
								END
					WHEN 2 THEN CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,103)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,103),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,103),1,1,''),CONVERT (CHAR(10),@current_date,103)),'/0','/')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,103),'/0','/')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,103),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,103),1,1,''),CONVERT (CHAR(10),@current_date,103))
								END
					WHEN 3 THEN CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,110)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,110),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,110),1,1,''),CONVERT (CHAR(10),@current_date,110)),'-0','-')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,110),'-0','-')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,110),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,110),1,1,''),CONVERT (CHAR(10),@current_date,110))
								END
					WHEN 4 THEN CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,105)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,105),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,105),1,1,''),CONVERT (CHAR(10),@current_date,105)),'-0','-')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,105),'-0','-')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,105),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,105),1,1,''),CONVERT (CHAR(10),@current_date,105))
								END
					WHEN 5 THEN CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,104)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,104),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,104),1,1,''),CONVERT (CHAR(10),@current_date,104)),'.0','.')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,104),'.0','.')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,104),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,104),1,1,''),CONVERT (CHAR(10),@current_date,104))
								END
					ELSE CASE date_type  
									WHEN 1 THEN CONVERT (CHAR(10),@current_date,101)
									WHEN 2 THEN REPLACE(IIF(LEFT(CONVERT (CHAR(10),@current_date,101),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,101),1,1,''),CONVERT (CHAR(10),@current_date,101)),'/0','/')
									WHEN 3 THEN REPLACE(CONVERT (CHAR(10),@current_date,101),'/0','/')
									WHEN 4 THEN IIF(LEFT(CONVERT (CHAR(10),@current_date,101),1) = '0',STUFF(CONVERT (CHAR(10),@current_date,101),1,1,''),CONVERT (CHAR(10),@current_date,101))
								END
				END as user_date,
				CONVERT (char(10),@current_date,126) as sql_date_string, 
				DATEPART(DD, @current_date) AS day_of_month,
				--Apply Suffix values like 1st, 2nd 3rd etc..
				CASE 
					WHEN DATEPART(DD,@current_date) IN (11,12,13) 
					THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th'
					WHEN RIGHT(DATEPART(DD,@current_date),1) = 1 
					THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'st'
					WHEN RIGHT(DATEPART(DD,@current_date),1) = 2 
					THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'nd'
					WHEN RIGHT(DATEPART(DD,@current_date),1) = 3 
					THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'rd'
					ELSE CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th' 
					END AS day_suffix,
				DATENAME(DW, @current_date) AS day_name,
				DATEPART(DW, @current_date)  as day_of_week,
				@day_of_quarter AS day_of_quarter,
				DATEPART(DY, @current_date) AS day_of_year,
				DATEPART(WW, @current_date) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @current_date)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS week_of_month,
				(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @current_date), 0), @current_date) / 7) + 1 AS week_of_quarter,
				DATEPART(WW, @current_date) AS week_of_year,
				DATEPART(MM, @current_date) AS month,
				DATENAME(MM, @current_date) AS month_name,
				CASE
					WHEN DATEPART(MM, @current_date) IN (1, 4, 7, 10) THEN 1
					WHEN DATEPART(MM, @current_date) IN (2, 5, 8, 11) THEN 2
					WHEN DATEPART(MM, @current_date) IN (3, 6, 9, 12) THEN 3
					END AS month_of_quarter,
				DATEPART(QQ, @current_date) AS quarter,
				CASE DATEPART(QQ, @current_date)
					WHEN 1 THEN 'First'
					WHEN 2 THEN 'Second'
					WHEN 3 THEN 'Third'
					WHEN 4 THEN 'Fourth'
					END AS quarter_name,
				DATEPART(YEAR, @current_date) AS year,
				LEFT(DATENAME(MM, @current_date), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @current_date)) AS mon_yyyy,
				CONVERT(VARCHAR, DATEPART(YY, @current_date)) + RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @current_date)),2)  AS yyyymm,
				CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @current_date) - 1), @current_date))) AS first_day_of_month,
				CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @current_date)))), DATEADD(MM, 1, @current_date)))) AS last_day_of_month,
				DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @current_date) - 1, '19000101') AS first_day_of_prev_month,
				DATEADD(D, -1, DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @current_date), '19000101')) AS last_day_of_prev_month,
				DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @current_date) + 1, '19000101') AS first_day_of_next_month,
				DATEADD(D, -1, DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @current_date) + 2, '19000101')) AS last_day_of_next_month,
				DATEADD(QQ, DATEDIFF(QQ, 0, @current_date), 0) AS first_day_of_quarter,
				DATEADD(QQ, DATEDIFF(QQ, -1, @current_date), -1) AS last_day_of_quarter,
				CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS first_day_of_year,
				CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS last_day_of_year,
				DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @current_date) - 1 , '19000101') AS first_day_of_prev_year,
		        DATEADD(d, -1, DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @current_date), '19000101')) AS last_day_of_prev_year,
		        DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @current_date) + 1 , '19000101') AS first_day_of_next_year,
		        DATEADD(d, -1, DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @current_date) + 2 , '19000101')) AS last_day_of_next_year,
				CASE DATEPART(DW, @current_date)
					WHEN 1 THEN 0
					WHEN 2 THEN 1
					WHEN 3 THEN 1
					WHEN 4 THEN 1
					WHEN 5 THEN 1
					WHEN 6 THEN 1
					WHEN 7 THEN 0
					END AS is_weekday
			FROM #temp_date_format
			SET @current_date = DATEADD(DD, 1, @current_date)

		END
		
		FETCH NEXT FROM @region_cursor INTO @region_id;

	END  --REGION LOOP ENDS
 
	CLOSE @region_cursor;
	DEALLOCATE @region_cursor;

END  --end of SP
GO

--run the sp to populate data in the table
EXEC [dbo].[spa_populate_date_data] 
	  @start_date  = '01/01/1995' --Starting value of Date Range
	, @end_date = '01/01/2051' --End Value of Date Range
GO

--select * from date_details --where day_name='Saturday'
 
--Create view to collect user specific region's date data. 
IF OBJECT_ID('[dbo].[vw_date_details]') IS NOT NULL
    DROP VIEW [dbo].[vw_date_details]
GO

CREATE VIEW [dbo].[vw_date_details]
AS

	SELECT dd.* 
	FROM date_details dd
	LEFT JOIN application_users au ON au.user_login_id = dbo.FNADBUser() 
	WHERE ISNULL(au.region_id,1) = dd.region_id	
	
GO





