
IF OBJECT_ID('[dbo].[spa_getVolumeFrequency]' ,'p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_getVolumeFrequency]
 GO 


CREATE PROCEDURE [dbo].[spa_getVolumeFrequency]
	@frequency CHAR(1) = NULL ,
	@exclude_values VARCHAR(100) = NULL
AS

SET NOCOUNT ON;
	CREATE TABLE #temp_table
	(
		[id]    CHAR(1) COLLATE DATABASE_DEFAULT
	   ,[name]  VARCHAR(50) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #temp_table
	VALUES
	  (
	    'h'
	   ,'Hourly'
	  )
	INSERT INTO #temp_table
	VALUES
	  (
	    'd'
	   ,'Daily'
	  )
	--INSERT INTO #temp_table
	--VALUES
	--  (
	--    'w'
	--   ,'Weekly'
	--  )
	INSERT INTO #temp_table
	VALUES
	  (
	    'm'
	   ,'Monthly'
	  )
	--INSERT INTO #temp_table
	--VALUES
	--  (
	--    'q'
	--   ,'Quarterly'
	--  )
	--INSERT INTO #temp_table
	--VALUES
	--  (
	--    's'
	--   ,'Semi-Annually'
	--  )
	INSERT INTO #temp_table
	VALUES
	  (
	    'a'
	   ,'Annually'
	  )
	INSERT INTO #temp_table
	VALUES
	  (
	    't'
	   ,'Term'
	  )
	
	-- inserted for shaped hourly data
	INSERT INTO #temp_table
	VALUES
	  (
	    'x'
	   ,'15 Minutes'
	  )
	INSERT INTO #temp_table
	VALUES
	  (
	    'y'
	   ,'30 Minutes'
	  )
	
	DECLARE @sql VARCHAR(1000)
	
	SET @sql = 'select * from #temp_table where 1=1 ' 
	   + CASE 
	         WHEN @frequency IS NOT NULL THEN ' AND id = '''+@frequency+''''
	         ELSE ''
	     END 
	   + CASE 
	         WHEN @exclude_values IS NOT NULL THEN 
	              ' AND [id] NOT IN(SELECT [item] FROM dbo.SplitCommaSeperatedValues(''' + @exclude_values + '''))'
	         ELSE ''
	     END
	   + ' order by name'
	
	EXEC (@sql)
