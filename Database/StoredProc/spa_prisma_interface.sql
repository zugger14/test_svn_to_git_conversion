IF OBJECT_ID (N'[dbo].[spa_prisma_interface]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_prisma_interface]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used for prisma interface data import

	Parameters
	@flag	                   :  Flag
								 - 'prisma' flag used for data in temp table.							
    @process_id				   : Process ID
    @response_data			   : Create Date To
   */
   
CREATE PROCEDURE [dbo].[spa_prisma_interface]
	@flag VARCHAR(100) = 'prisma',
	@process_id varchar(500),
	@response_data NVARCHAR(MAX) = NULL,
	@process_table NVARCHAR(250) = NULL
AS 
/*------------------Debug Section------------------
DECLARE @flag CHAR(1) = NULL,
		@process_id VARCHAR(100) = NULL,
		@response_data VARCHAR(100) = NULL,
		
SELECT @flag='prisma',
	  @response_data = ''
-------------------------------------------------*/
IF @flag = 'prisma'
Begin	
	IF OBJECT_ID('tempdb..#gettemp_data') IS NOT NULL
	DROP TABLE #gettemp_data
  
	CREATE TABLE #gettemp_data
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT, [label] NVARCHAR(500) COLLATE DATABASE_DEFAULT, [value] NVARCHAR(max) COLLATE DATABASE_DEFAULT , [counter] Int)
  
	CREATE TABLE #gettemp_data_values
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,[key] NVARCHAR(500) COLLATE DATABASE_DEFAULT, [value] NVARCHAR(max) COLLATE DATABASE_DEFAULT,  [type] int, [counter] Int)

	CREATE TABLE #gettemp_data_level_1 (k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT , v1 NVARCHAR(4000)  COLLATE DATABASE_DEFAULT , [counter] INT , [dealID] NVARCHAR(500) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #gettemp_data_object_1 (k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT , v1 NVARCHAR(4000)  COLLATE DATABASE_DEFAULT , [counter] INT , [dealID] NVARCHAR(500) COLLATE DATABASE_DEFAULT )
		 
	CREATE TABLE  #gettemp_data_object_2
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  v2 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_object_3 (dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v3 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_object_4
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v4 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)
	
	CREATE TABLE #gettemp_data_object_5
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v5 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)
	
	CREATE TABLE #gettemp_data_object_6
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v6 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)
	
	CREATE TABLE  #gettemp_data_object_7
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k7 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v7 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_object_8
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k7 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k8 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v8 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)
	
	CREATE TABLE  #gettemp_data_level_2
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  v2 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_3
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v3 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_4
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v4 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_5
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v5 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_6
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v6 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_7
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k7 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v7 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

	CREATE TABLE  #gettemp_data_level_8
	(dealID NVARCHAR(500) COLLATE DATABASE_DEFAULT,k1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,  k2 NVARCHAR(500) COLLATE DATABASE_DEFAULT,  k3 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k4 NVARCHAR(500) COLLATE DATABASE_DEFAULT, k5 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k6 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k7 NVARCHAR(500) COLLATE DATABASE_DEFAULT,k8 NVARCHAR(500) COLLATE DATABASE_DEFAULT, v8 NVARCHAR(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)
	
	DECLARE @json2 NVARCHAR(MAX)
	DECLARE @json3 NVARCHAR(MAX)
	DECLARE @json NVARCHAR(MAX) = REPLACE(@response_data, CHAR(13) + CHAR(10), '')
	
	SELECT * INTO #gettemp_data_base FROM OpenJson(@json);
	
	DECLARE @count int 
	SELECT @count = count(value) FROM #gettemp_data_base

	DECLARE @Counter INT 
	SET @Counter= 0
	WHILE ( @Counter < @count)
	BEGIN
		SELECT  @json2 = Value FROM  #gettemp_data_base   WHERE [key]  = @Counter

		INSERT INTO #gettemp_data_values
		SELECT  d.[value]as deal_id, j.[key] ,j.[value] ,j.[type], @Counter as counter
		FROM OpenJson(@json2) j
		OUTER APPLY(SELECT value FROM OpenJson(@json2) WHERE [key] = 'dealId' ) d				

		SET @Counter  = @Counter  + 1
	END	
	INSERT INTO #gettemp_data_level_1
	SELECT [key] k1, [value] v1, [counter], [dealID]		
	FROM #gettemp_data_values  WHERE TYPE <= 3
	
	INSERT INTO #gettemp_data_object_1 
	SELECT [key] k1, [value] v1, [counter], [dealID]
	FROM #gettemp_data_values  WHERE TYPE > 3
	
	INSERT INTO  #gettemp_data_level_2
	SELECT [dealID], k1, [key] k2, [value] v2 , [Counter] ,T2.[TYPE]
	FROM  #gettemp_data_object_1 T1
	CROSS APPLY OPENJSON(T1.[v1], '$') T2 
	WHERE T2.[TYPE] <= 3

	INSERT INTO #gettemp_data_object_2
	SELECT [dealID], k1, [key] k2, [value] v2 , [Counter] ,T2.[TYPE]
	FROM  #gettemp_data_object_1 T1
	CROSS APPLY OPENJSON(T1.[v1], '$') T2 
	WHERE T2.[TYPE] > 3

	INSERT INTO #gettemp_data_level_3
	SELECT [dealID], k1, k2,[key]k3, [value]v3, [Counter]  , T2.[Type] 
	FROM  #gettemp_data_object_2 T1
	CROSS APPLY OPENJSON(T1.[v2], '$') T2 
	WHERE T2.[TYPE] <= 3

	INSERT INTO #gettemp_data_object_3
	SELECT [dealID], k1, k2,[key]k3, [value]v3, [Counter]  ,T2.[Type]	
	FROM  #gettemp_data_object_2 T1
	CROSS APPLY OPENJSON(T1.[v2], '$') T2 
	WHERE T2.[TYPE] > 3
	
	INSERT INTO #gettemp_data_level_4
	SELECT [dealID], k1, k2, k3, [key]k4 ,[value]v4, [Counter]  ,T2.[Type]
	FROM  #gettemp_data_object_3 T1
	CROSS APPLY OPENJSON(T1.[v3], '$') T2 
	WHERE T2.[TYPE] <= 3
	
	INSERT INTO #gettemp_data_object_4
	SELECT [dealID], k1, k2, k3, [key] k4, [value] v4, [Counter]  , T2.[Type]	  
	FROM  #gettemp_data_object_3 T1
	CROSS APPLY OPENJSON(T1.[v3], '$') T2 
	WHERE T2.[TYPE] > 3
	
	INSERT INTO #gettemp_data_level_5
	SELECT  [dealID], k1, k2, k3, k4, [key]k5 ,[value]v5, [Counter]  , T2.[Type]
	FROM  #gettemp_data_object_4 T1
	CROSS APPLY OPENJSON(T1.[v4], '$') T2 
	WHERE T2.[TYPE] <= 3

	INSERT INTO #gettemp_data_object_5
	SELECT  [dealID], k1, k2, k3,k4, [key]k5 ,[value] v5, [Counter]  , T2.[Type]
	FROM  #gettemp_data_object_4 T1
	CROSS APPLY OPENJSON(T1.[v4], '$') T2 
	WHERE T2.[TYPE] > 3

	INSERT INTO #gettemp_data_level_6
	SELECT [dealID], k1, k2, k3, k4, k5 , [key] k6,[value]v6, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_5 T1
	CROSS APPLY OPENJSON(T1.[v5], '$') T2 
	WHERE T2.[TYPE] <= 3

	INSERT INTO #gettemp_data_object_6
	SELECT  [dealID], k1, k2, k3,k4, k5, [key]k6 ,[value] v6, [Counter]  , T2.[Type]
	FROM  #gettemp_data_object_5 T1
	CROSS APPLY OPENJSON(T1.[v5], '$') T2 
	WHERE T2.[TYPE] > 3

	INSERT INTO #gettemp_data_level_7
	SELECT  [dealID], k1, k2, k3, k4, k5 ,k6, [key] k7,[value]v7, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_6 T1
	CROSS APPLY OPENJSON(T1.[v6], '$') T2 
	WHERE T2.[TYPE] <= 3

	INSERT INTO #gettemp_data_object_7
	SELECT  [dealID], k1, k2, k3,k4, k5, k6, [key]k7 ,[value] v7,[Counter]  , T2.[Type]
	FROM  #gettemp_data_object_6 T1
	CROSS APPLY OPENJSON(T1.[v6], '$') T2 
	WHERE T2.[TYPE] > 3

	INSERT INTO #gettemp_data_level_8
	SELECT  [dealID], k1, k2, k3, k4, k5 ,k6,k7, [key] k8,[value]v8, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_7 T1
	CROSS APPLY OPENJSON(T1.[v7], '$') T2 
	WHERE T2.[TYPE] <= 3
	
	INSERT INTO #gettemp_data_object_8
	SELECT  [dealID], k1, k2, k3,k4, k5, k6, k7, [key]k8 ,[value] v8, [Counter]  , T2.[Type]
	FROM  #gettemp_data_object_7 T1
	CROSS APPLY OPENJSON(T1.[v7], '$') T2 
	WHERE T2.[TYPE] > 3

	INSERT INTO #gettemp_data
		SELECT [dealID],Replace(k1,'0','')  [label], v1 [value] , [counter] FROM #gettemp_data_level_1 --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0','')) [label],v2 [value], [counter] FROM #gettemp_data_level_2 --WHERE counter = 1
	UNION ALL
		SELECT [dealID], concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0','')) [label],v3 [value], [counter] FROM #gettemp_data_level_3 --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0','')),v4 [value], [counter] FROM #gettemp_data_level_4 --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0','')),v5 [value], [counter] FROM #gettemp_data_level_5 --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0','')),v6 [value] , [counter] FROM #gettemp_data_level_6 --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7),v7 [value] , [counter]FROM #gettemp_data_level_7 --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7,'_',k8),v8 [value] , [counter] FROM #gettemp_data_level_8 --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],Replace(k1,'0','')  [label], NULL [value] , [counter] FROM #gettemp_data_object_1 WHERE v1 IN ('[]','{}') --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0','')) [label],NULL [value], [counter] FROM #gettemp_data_object_2 WHERE v2 IN ('[]','{}') --WHERE counter = 1
	UNION ALL
		SELECT [dealID], concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0','')) [label],NULL [value], [counter] FROM #gettemp_data_object_3 WHERE v3 IN ('[]','{}') --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0','')),NULL [value], [counter] FROM #gettemp_data_object_4 WHERE v4 IN ('[]','{}') --WHERE counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0','')),NULL [value], [counter] FROM #gettemp_data_object_5 WHERE v5 IN ('[]','{}') --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0','')),NULL [value] , [counter] FROM #gettemp_data_object_6 WHERE v6 IN ('[]','{}') --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7),NULL [value] , [counter]FROM #gettemp_data_object_7 WHERE v7 IN ('[]','{}') --WHERE --counter = 1
	UNION ALL
		SELECT [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7,'_',k8),NULL [value]  , [counter] FROM #gettemp_data_object_8 WHERE v8 IN ('[]','{}') --WHERE --counter = 1

	EXEC ('SELECT  Distinct [dealID], replace(label,''__'',''_'') Label, value ,[counter]
	INTO '+ @process_table +'
	FROM #gettemp_data')
END