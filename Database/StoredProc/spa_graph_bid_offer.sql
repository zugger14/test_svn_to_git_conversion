
/****** Object:  StoredProcedure [dbo].[spa_graph_bid_offer]    Script Date: 07/28/2009 18:01:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_graph_bid_offer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_graph_bid_offer]
/****** Object:  StoredProcedure [dbo].[spa_graph_bid_offer]    Script Date: 07/28/2009 18:01:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_graph_bid_offer] 
	@sub VARCHAR(200)=null,
	@sta VARCHAR(200)=NULL,
	@book VARCHAR(200)=NULL,
	@source VARCHAR(200)=NULL,
	@location VARCHAR(200),
	@from_date DATETIME=NULL,
	@to_date DATETIME=NULL,
	@avg VARCHAR(1)='n',
	@granularity INT=null,
	@bid_offer_flag CHAR(1)='b'
AS


--DECLARE @sub VARCHAR(200),@sta VARCHAR(200),@book VARCHAR(200),
--@source INT,@location VARCHAR(200),@from_date DATETIME,@to_date DATETIME,
--@avg VARCHAR(1),@granularity INT
--
--SELECT @sub=null,@sta=NULL,@book =NULL,@source =NULL,@location ='1,2',@from_date='2008-01-01',@to_date =NULL,
--@avg ='n',@granularity=null
--
--DROP TABLE #tmp_data
--DROP TABLE #tmp_data1

DECLARE @st VARCHAR(MAX)
SET @st=''

	CREATE TABLE #tmp_data(
		Location_Name VARCHAR(100) COLLATE DATABASE_DEFAULT
		,volume1 float
		,price1 float
		,volume2 float
		,price2 float
		,volume3 float
		,price3 float
		,volume4 float
		,price4 float
		,volume5 float
		,price5 float
		,volume6 float
		,price6 float
		,volume7 float
		,price7 float
		,volume8 float
		,price8 float
		,volume9 float
		,price9 float
		,volume10 float
		,price10 float
	)


--IF @sub IS NOT NULL
--	SET @st= @st + ' stra.parent_entity_id in (' +@sub+')'
--IF @sta IS NOT NULL
--	SET @st= @st + ' stra.entity_id in (' +@sta+')'
--IF @book IS NOT NULL
--	SET @st= @st + ' book.entity_id in (' +@book+')'


IF @bid_offer_flag= 'o' AND @location IS NOT NULL
	SET @st= @st + ' AND l.source_generator_id in(' +@location+')'
ELSE IF @bid_offer_flag= 'b' AND @location IS NOT NULL
	SET @st= @st + ' AND l.source_minor_location_id in (' +@location+')'

IF @from_date IS NOT NULL
	SET @st= @st + ' AND CONVERT(VARCHAR(20),b.offer_date,106)+'' ''+CAST(offer_hour AS VARCHAR)+'':00:00.000''>=CAST(''' + CONVERT(VARCHAR(20),@from_date,113) + ''' AS DATETIME)'
IF @to_date IS NOT NULL
	SET @st= @st + ' AND CONVERT(VARCHAR(20),b.offer_date,106)+'' ''+CAST(offer_hour AS VARCHAR)+'':00:00.000''<=CAST(''' + CONVERT(VARCHAR(20),@from_date,113) + ''' AS DATETIME)'

SET @st='insert into #tmp_data 
		SELECT  
		'+CASE WHEN @bid_offer_flag='b' THEN 'REPLACE(l.Location_Name,'' '',''_'') Location_Name ,'
			ELSE 'REPLACE(l.generator_name,'' '',''_'') Location_Name ,' END+
		 ' AVG(volume1) volume1
		,AVG(price1) price1
		,AVG(volume2) volume2
		,AVG(price2) price2
		,AVG(volume3) volume3
		,AVG(price3) price3
		,AVG(volume4) volume4
		,AVG(price4) price4
		,AVG(volume5) volume5
		,AVG(price5) price5
		,AVG(volume6) volume6
		,AVG(price6) price6
		,AVG(volume7) volume7
		,AVG(price7) price7
		,AVG(volume8) volume8
		,AVG(price8) price8
		,AVG(volume9) volume9
		,AVG(price9) price9
		,AVG(volume10) volume10
		,AVG(price10) price10
		FROM bid_offer b 
		'+CASE WHEN @bid_offer_flag='b' THEN ' LEFT JOIN source_minor_location l ON l.source_minor_location_id=b.location_id'
			ELSE ' LEFT JOIN source_generator l ON l.source_generator_id=b.location_id' END+
		--LEFT JOIN source_generator g ON g.location_id=l.source_minor_location_id
		' where 1=1  '+ @st+' GROUP BY '+CASE WHEN @bid_offer_flag='b' THEN ' REPLACE(l.Location_Name,'' '',''_'')' ELSE ' REPLACE(l.generator_name,'' '',''_'')' END

	exec spa_print @st
	EXEC(@st)
--Unpivot the table.
DECLARE @fld_variable VARCHAR(1000)
SET @fld_variable=''
SELECT  @fld_variable= @fld_variable + ',['+Location_Name+']' FROM #tmp_data GROUP BY Location_Name
SET @fld_variable=SUBSTRING(@fld_variable,2,LEN(@fld_variable))


SELECT * INTO #tmp_data1 FROM (
SELECT Location_Name, SUBSTRING(Tran_type,7,LEN(Tran_type)) Tran_type,T_Value Quantity, null Price
FROM 
   (SELECT Location_Name, volume1, volume2, volume3, volume4, volume5,volume6,volume7,volume8,volume9,volume10
   FROM #tmp_data) p
UNPIVOT
   (T_Value FOR Tran_type IN 
      ( volume1, volume2, volume3, volume4, volume5,volume6,volume7,volume8,volume9,volume10)
)AS unpvt
) aa

UPDATE #tmp_data1 SET price=p.price FROM  #tmp_data1 q INNER JOIN (
SELECT  Location_Name,SUBSTRING(Tran_type,6,LEN(Tran_type)) Tran_type, T_Value Price
FROM 
   (SELECT Location_Name, price1, price2, price3, price4, price5,price6,price7,price8,price9,price10
   FROM #tmp_data) p
UNPIVOT
   (T_Value FOR Tran_type IN 
      ( price1, price2, price3, price4, price5,price6,price7,price8,price9,price10)
)AS unpvt
) p ON q.Tran_type =p.Tran_type


IF @avg='y'
BEGIN

	SET @st='
	SELECT  Quantity, avg(Price) [Average Price]
	FROM #tmp_data1 group by Quantity 
	'
end
else
	SET @st='
	SELECT Quantity,'+ @fld_variable+ ' 
	FROM 
	(SELECT Location_Name, Quantity, avg(Price) Price
	FROM #tmp_data1 group by Location_Name ,Quantity) p
	PIVOT
	(
	avg (Price)
	FOR Location_Name IN
	( '+@fld_variable+' )
	) AS pvt
	ORDER BY Quantity'
	
EXEC spa_print @st
EXEC(@st)



