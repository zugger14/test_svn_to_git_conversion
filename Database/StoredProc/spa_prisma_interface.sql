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
								 - 'pisma' flag used for data in temp table.							
    @process_id				   : Process ID
    @response_data			   : Create Date To
   */
   
Create   PROCEDURE [dbo].[spa_prisma_interface]
@flag VARCHAR(100) = 'prisma',
@process_id varchar(500),
@response_data NVARCHAR(MAX) = NULL

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
	Declare @process_table_name varchar(500)
	Set @process_table_name = Concat('adiha_process.dbo.','prisma_data_json_',@process_id)
		
Declare @response_process_table_name varchar(500)
Declare @user_login_id varchar(500) = dbo.FNADBUser()

SELECT @response_process_table_name = Concat('adiha_process.dbo.','prisma_interface_response_',@user_login_id,@process_id)

 IF OBJECT_ID('tempdb..#gettemp_data') IS NOT NULL
 DROP TABLE #gettemp_data
  
 Create table #gettemp_data
 (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT, [label] Nvarchar(500) COLLATE DATABASE_DEFAULT, [value] Nvarchar(max) COLLATE DATABASE_DEFAULT , [counter] Int)
  
 Create table #gettemp_data_values
 (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,[key] Nvarchar(500)  COLLATE DATABASE_DEFAULT, [value] Nvarchar(max) COLLATE DATABASE_DEFAULT,  [type] int, [counter] Int)

  Create table  #gettemp_data_level_2
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  v2 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

  Create table  #gettemp_data_level_3
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v3 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

   Create table  #gettemp_data_level_4
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k4 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v4 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

   Create table  #gettemp_data_level_5
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k4 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k5 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v5 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

  Create table  #gettemp_data_level_6
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k4 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k5 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k6 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v6 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

  Create table  #gettemp_data_level_7
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k4 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k5 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k6 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k7 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v7 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)

   Create table  #gettemp_data_level_8
  (dealID Nvarchar(500) COLLATE DATABASE_DEFAULT,k1 Nvarchar(500)  COLLATE DATABASE_DEFAULT ,  k2 Nvarchar(500)  COLLATE DATABASE_DEFAULT,  k3 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k4 Nvarchar(500)  COLLATE DATABASE_DEFAULT, k5 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k6 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k7 Nvarchar(500)  COLLATE DATABASE_DEFAULT,k8 Nvarchar(500)  COLLATE DATABASE_DEFAULT, v8 Nvarchar(2000)  COLLATE DATABASE_DEFAULT, [Counter]  INT,[TYPE] INT)


DECLARE @json2 NVarChar(MAX)
DECLARE @json3 NVarChar(MAX)
DECLARE @json NVarChar(MAX)  =  REPLACE(@response_data, CHAR(13) + CHAR(10), '')

SELECT * INTO #gettemp_data_base FROM OpenJson(@json);

Declare @count int 
select @count = count(value) from #gettemp_data_base

	DECLARE @Counter INT 
	SET @Counter= 0
	WHILE ( @Counter < @count)
	BEGIN
		SELECT  @json2 = Value FROM  #gettemp_data_base   where [key]  = @Counter

		Insert into #gettemp_data_values
		SELECT  d.[value]as deal_id, j.[key] ,j.[value] ,j.[type], @Counter as counter
		FROM OpenJson(@json2) j
		OUTER APPLY(select value FROM OpenJson(@json2) where [key] = 'dealId' ) d				

		SET @Counter  = @Counter  + 1
	END	


SELECT [key] k1, [value] v1, [counter], [dealID]
	INTO	#gettemp_data_level_1 
FROM	 #gettemp_data_values  WHERE TYPE <= 3

SELECT [key] k1, [value] v1, [counter], [dealID]
	INTO	#gettemp_data_object_1 
FROM	#gettemp_data_values  WHERE TYPE > 3


INSERT INTO  #gettemp_data_level_2
SELECT [dealID], k1, [key] k2, [value] v2 , [Counter] ,T2.[TYPE]
	FROM  #gettemp_data_object_1 T1
	CROSS APPLY OPENJSON(T1.[v1], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT [dealID], k1, [key] k2, [value] v2 , [Counter] ,T2.[TYPE]
INTO #gettemp_data_object_2
	FROM  #gettemp_data_object_1 T1
	CROSS APPLY OPENJSON(T1.[v1], '$') T2 
WHERE T2.[TYPE] > 3

INSERT INTO #gettemp_data_level_3
SELECT [dealID], k1, k2,[key]k3, [value]v3, [Counter]  , T2.[Type] 
	FROM  #gettemp_data_object_2 T1
	CROSS APPLY OPENJSON(T1.[v2], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT [dealID], k1, k2,[key]k3, [value]v3, [Counter]  ,T2.[Type]
INTO #gettemp_data_object_3
	FROM  #gettemp_data_object_2 T1
	CROSS APPLY OPENJSON(T1.[v2], '$') T2 
WHERE T2.[TYPE] > 3


INSERT INTO #gettemp_data_level_4
SELECT  [dealID], k1, k2, k3, [key]k4 ,[value]v4, [Counter]  ,T2.[Type]
	FROM  #gettemp_data_object_3 T1
	CROSS APPLY OPENJSON(T1.[v3], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT  [dealID], k1, k2, k3, [key] k4, [value] v4, [Counter]  , T2.[Type]
INTO  #gettemp_data_object_4
	FROM  #gettemp_data_object_3 T1
	CROSS APPLY OPENJSON(T1.[v3], '$') T2 
WHERE T2.[TYPE] > 3

INSERT INTO #gettemp_data_level_5
SELECT  [dealID], k1, k2, k3, k4, [key]k5 ,[value]v5, [Counter]  , T2.[Type]
	FROM  #gettemp_data_object_4 T1
	CROSS APPLY OPENJSON(T1.[v4], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT  [dealID], k1, k2, k3,k4, [key]k5 ,[value] v5, [Counter]  , T2.[Type]
INTO  #gettemp_data_object_5
	FROM  #gettemp_data_object_4 T1
	CROSS APPLY OPENJSON(T1.[v4], '$') T2 
WHERE T2.[TYPE] > 3

INSERT INTO #gettemp_data_level_6
SELECT [dealID], k1, k2, k3, k4, k5 , [key] k6,[value]v6, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_5 T1
	CROSS APPLY OPENJSON(T1.[v5], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT  [dealID], k1, k2, k3,k4, k5, [key]k6 ,[value] v6, [Counter]  , T2.[Type]
INTO  #gettemp_data_object_6
	FROM  #gettemp_data_object_5 T1
	CROSS APPLY OPENJSON(T1.[v5], '$') T2 
WHERE T2.[TYPE] > 3

INSERT INTO #gettemp_data_level_7
SELECT  [dealID], k1, k2, k3, k4, k5 ,k6, [key] k7,[value]v7, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_6 T1
	CROSS APPLY OPENJSON(T1.[v6], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT  [dealID], k1, k2, k3,k4, k5, k6, [key]k7 ,[value] v7,[Counter]  , T2.[Type]
INTO  #gettemp_data_object_7
	FROM  #gettemp_data_object_6 T1
	CROSS APPLY OPENJSON(T1.[v6], '$') T2 
WHERE T2.[TYPE] > 3


INSERT INTO #gettemp_data_level_8
SELECT  [dealID], k1, k2, k3, k4, k5 ,k6,k7, [key] k8,[value]v8, [Counter] , T2.[Type] 
	FROM  #gettemp_data_object_7 T1
	CROSS APPLY OPENJSON(T1.[v7], '$') T2 
WHERE T2.[TYPE] <= 3

SELECT  [dealID], k1, k2, k3,k4, k5, k6, k7, [key]k8 ,[value] v8, [Counter]  , T2.[Type]
INTO  #gettemp_data_object_8
	FROM  #gettemp_data_object_7 T1
	CROSS APPLY OPENJSON(T1.[v7], '$') T2 
WHERE T2.[TYPE] > 3

INSERT INTO #gettemp_data
	select [dealID],Replace(k1,'0','')  [label], v1 [value] , [counter] from #gettemp_data_level_1 --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0','')) [label],v2 [value], [counter] from #gettemp_data_level_2 --where counter = 1
UNION ALL
	select [dealID], concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0','')) [label],v3 [value], [counter] from #gettemp_data_level_3 --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0','')),v4 [value], [counter] from #gettemp_data_level_4 --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0','')),v5 [value], [counter] from #gettemp_data_level_5 --where --counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0','')),v6 [value] , [counter] from #gettemp_data_level_6 --where --counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7),v7 [value] , [counter]from #gettemp_data_level_7 --where --counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7,'_',k8),v8 [value] , [counter] from #gettemp_data_level_8 --where --counter = 1
UNION ALL
	select [dealID],Replace(k1,'0','')  [label], NULL [value] , [counter] from #gettemp_data_object_1 Where v1 IN ('[]','{}') --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0','')) [label],NULL [value], [counter] from #gettemp_data_object_2 Where v2 IN ('[]','{}') --where counter = 1
UNION ALL
	select [dealID], concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0','')) [label],NULL [value], [counter] from #gettemp_data_object_3 Where v3 IN ('[]','{}') --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0','')),NULL [value], [counter] from #gettemp_data_object_4 Where v4 IN ('[]','{}') --where counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0','')),NULL [value], [counter] from #gettemp_data_object_5 Where v5 IN ('[]','{}') --where --counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0','')),NULL [value] , [counter] from #gettemp_data_object_6 Where v6 IN ('[]','{}') --where --counter = 1
UNION ALL
	select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7),NULL [value] , [counter]from #gettemp_data_object_7 Where v7 IN ('[]','{}') --where --counter = 1
UNION ALL
select [dealID],concat(Replace(k1,'0',''),'_',Replace(k2,'0',''),'_',Replace(k3,'0',''),'_',Replace(k4,'0',''),'_',Replace(k5,'0',''),'_',Replace(k6,'0',''),'_',k7,'_',k8),NULL [value]  , [counter] from #gettemp_data_object_8 Where v8 IN ('[]','{}') --where --counter = 1

Exec ('select  Distinct [dealID],replace(label,''__'',''_'') Label, value ,[counter]
INTO '+ @response_process_table_name +'
from #gettemp_data')
END

