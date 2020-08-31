
/****** Object:  StoredProcedure [dbo].[spa_create_bid_offer_submit_report]    Script Date: 07/28/2009 18:02:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_bid_offer_submit_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_bid_offer_submit_report]
/****** Object:  StoredProcedure [dbo].[spa_create_bid_offer_submit_report]    Script Date: 07/28/2009 18:02:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_create_bid_offer_submit_report]
	@bid_offer_flag CHAR(1)='b', -- b- Bid, O- offer
	@location_id VARCHAR(500)=NULL,
	@as_of_date DATETIME,
	@hour_from INT=NULL,
	@hour_to INT=NULL,
	@formulator_id INT=NULL,
	@calc CHAR(1)='n'

AS
SET NOCOUNT ON
BEGIN
--	select * from bid_offer_formulator_header
--	select * from bid_offer_formulator_detail
	DECLARE @bid_offer_id INT
	DECLARE @block_id INT
	DECLARE @hour INT
	DECLARE @volume_formula_id1 INT,@volume_formula1 VARCHAR(1000),@price_formula_id1 INT,@price_formula1 VARCHAR(1000)
	DECLARE @volume_formula_id2 INT,@volume_formula2 VARCHAR(1000),@price_formula_id2 INT,@price_formula2 VARCHAR(1000)
	DECLARE @volume_formula_id3 INT,@volume_formula3 VARCHAR(1000),@price_formula_id3 INT,@price_formula3 VARCHAR(1000)
 	DECLARE @volume_formula_id4 INT,@volume_formula4 VARCHAR(1000),@price_formula_id4 INT,@price_formula4 VARCHAR(1000)
 	DECLARE @volume_formula_id5 INT,@volume_formula5 VARCHAR(1000),@price_formula_id5 INT,@price_formula5 VARCHAR(1000)
 	DECLARE @volume_formula_id6 INT,@volume_formula6 VARCHAR(1000),@price_formula_id6 INT,@price_formula6 VARCHAR(1000)
 	DECLARE @volume_formula_id7 INT,@volume_formula7 VARCHAR(1000),@price_formula_id7 INT,@price_formula7 VARCHAR(1000)
 	DECLARE @volume_formula_id8 INT,@volume_formula8 VARCHAR(1000),@price_formula_id8 INT,@price_formula8 VARCHAR(1000)
 	DECLARE @volume_formula_id9 INT,@volume_formula9 VARCHAR(1000),@price_formula_id9 INT,@price_formula9 VARCHAR(1000)
 	DECLARE @volume_formula_id10 INT,@volume_formula10 VARCHAR(1000),@price_formula_id10 INT,@price_formula10 VARCHAR(1000)
	DECLARE @formula_stmt VARCHAR(MAX)
	DECLARE @sql_stmt VARCHAR(MAX)
	DECLARE @vol_round_value INT
	DECLARE @price_round_value INT

	SET @vol_round_value=2
	SET @price_round_value=4

	IF @hour_from IS NULL
	SET @hour_from=0

	IF @hour_to IS NULL
	SET @hour_to=23

	select 	@bid_offer_id=@formulator_id 
	

	IF @calc='y'
	BEGIN
		
			CREATE TABLE #hour(
				as_of_date datetime,
				[hour] INT
			)

			DECLARE @count INT
			SET @count=0

			WHILE @count<24
				BEGIN
					INSERT INTO #hour(as_of_date,[hour])
					SELECT @as_of_date,@count
					
					SET @count=@count+1
				END

			
			CREATE TABLE #location(
				location_id INT,
				location_name VARCHAR(100) COLLATE DATABASE_DEFAULT

			)

			SET @sql_stmt='
				INSERT INTO #location
				SELECT '
					+CASE WHEN @bid_offer_flag='b' THEN ' sm.source_minor_location_id' ELSE 'sm.source_generator_id' END+','+
					+CASE WHEN @bid_offer_flag='b' THEN ' sm.location_name' ELSE 'sm.generator_name' END+
				' FROM '
				+CASE WHEN @bid_offer_flag='b' THEN ' source_minor_location ' ELSE 'source_generator ' END+' sm'+
				' WHERE '
				+CASE WHEN @bid_offer_flag='b' THEN ' source_minor_location_id IN('+@location_id+')' ELSE ' source_generator_id IN('+@location_id+')' END
				
			EXEC(@sql_stmt)


			CREATE Table #bid_offer_formula(
				bid_offer_id INT,
				block_id INT,
				volume_formula_id1 INT,
				volume_formula1 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id1 INT,
				price_formula1  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id2 INT,
				volume_formula2 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id2 INT,
				price_formula2  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id3 INT,
				volume_formula3 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id3 INT,
				price_formula3  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id4 INT,
				volume_formula4 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id4 INT,
				price_formula4  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id5 INT,
				volume_formula5 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id5 INT,
				price_formula5  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id6 INT,
				volume_formula6 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id6 INT,
				price_formula6  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id7 INT,
				volume_formula7 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id7 INT,
				price_formula7  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id8 INT,
				volume_formula8 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id8 INT,
				price_formula8  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id9 INT,
				volume_formula9 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id9 INT,
				price_formula9  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				volume_formula_id10 INT,
				volume_formula10 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				price_formula_id10 INT,
				price_formula10  VARCHAR(1000) COLLATE DATABASE_DEFAULT		
			)

			INSERT INTO #bid_offer_formula
			SELECT
				bi.bid_offer_id,
				MAX(bi.block_id),
				MAX(CASE WHEN block_id=1 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=1 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=1 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=1 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=2 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=2 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=2 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=2 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=3 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=3 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=3 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=3 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=4 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=4 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=4 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=4 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=5 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=5 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=5 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=5 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=6 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=6 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=6 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=6 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=7 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=7 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=7 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=7 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=8 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=8 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=8 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=8 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=9 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=9 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=9 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=9 THEN fe1.formula ELSE NULL END),
				MAX(CASE WHEN block_id=10 THEN bi.volume_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=10 THEN  fe.formula ELSE NULL END),
				MAX(CASE WHEN block_id=10 THEN bi.price_formula_id ELSE NULL END),
				MAX(CASE WHEN block_id=10 THEN fe1.formula ELSE NULL END)

			from
				bid_offer_formulator_detail bi
				LEFT JOIN formula_editor fe on fe.formula_id=bi.volume_formula_id
				LEFT JOIN formula_editor fe1 on fe1.formula_id=bi.price_formula_id
				
			where
				bi.bid_offer_id=@bid_offer_id
			GROUP BY 
				bi.bid_offer_id



			CREATE TABLE #formula_value(
				as_of_date datetime,
				[hour] INT,
				volume1 FLOAT,
				price1 FLOAT,
				volume2 FLOAT,
				price2 FLOAT,
				volume3 FLOAT,
				price3 FLOAT,
				volume4 FLOAT,
				price4 FLOAT,
				volume5 FLOAT,
				price5 FLOAT,
				volume6 FLOAT,
				price6 FLOAT,
				volume7 FLOAT,
				price7 FLOAT,
				volume8 FLOAT,
				price8 FLOAT,
				volume9 FLOAT,
				price9 FLOAT,
				volume10 FLOAT,
				price10 FLOAT
			)
				


			DECLARE cur1 cursor for
				SELECT bid_offer_id,block_id,
					volume_formula_id1,volume_formula1,price_formula_id1,price_formula1,
 					volume_formula_id2,volume_formula2,price_formula_id2,price_formula2,
 					volume_formula_id3,volume_formula3,price_formula_id3,price_formula3,
 					volume_formula_id4,volume_formula4,price_formula_id4,price_formula4,
 					volume_formula_id5,volume_formula5,price_formula_id5,price_formula5,
 					volume_formula_id6,volume_formula6,price_formula_id6,price_formula6,
 					volume_formula_id7,volume_formula7,price_formula_id7,price_formula7,
 					volume_formula_id8,volume_formula8,price_formula_id8,price_formula8,
 					volume_formula_id9,volume_formula9,price_formula_id9,price_formula9,
 					volume_formula_id10,volume_formula10,price_formula_id10,price_formula10
				from #bid_offer_formula
				open cur1
				fetch next from cur1 into @bid_offer_id,@block_id,
					@volume_formula_id1,@volume_formula1,@price_formula_id1,@price_formula1,
 					@volume_formula_id2,@volume_formula2,@price_formula_id2,@price_formula2,
 					@volume_formula_id3,@volume_formula3,@price_formula_id3,@price_formula3,
 					@volume_formula_id4,@volume_formula4,@price_formula_id4,@price_formula4,
 					@volume_formula_id5,@volume_formula5,@price_formula_id5,@price_formula5,
 					@volume_formula_id6,@volume_formula6,@price_formula_id6,@price_formula6,
 					@volume_formula_id7,@volume_formula7,@price_formula_id7,@price_formula7,
 					@volume_formula_id8,@volume_formula8,@price_formula_id8,@price_formula8,
 					@volume_formula_id9,@volume_formula9,@price_formula_id9,@price_formula9,
 					@volume_formula_id10,@volume_formula10,@price_formula_id10,@price_formula10

				while @@fetch_status=0
					BEGIN

						DECLARE cur2 cursor for
							SELECT as_of_date,[hour] from #hour
									WHERE [hour]>=@hour_from AND [hour]<=@hour_to
							open cur2
							fetch next from cur2 into @as_of_date,@hour	
							while @@fetch_status=0
								BEGIN
								SET @hour=@hour+1
			
								SET @formula_stmt =' INSERT INTO #formula_value
								SELECT 
								'''+CAST(@as_of_date AS VARCHAR)+''','''+CAST(@hour AS VARCHAR)+''','+
								CASE WHEN @volume_formula_id1 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula1,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id1 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id1 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula1,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id1 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id2 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula2,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id2 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id2 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula2,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id2 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id3 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula3,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id3 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id3 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula3,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id3 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id4 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula4,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id4 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id4 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula4,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id4 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id5 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula5,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id5 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id5 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula5,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id5 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id6 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula6,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id6 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id6 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula6,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id6 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id7 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula7,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id7 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id7 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula7,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id7 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id8 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula8,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id8 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id8 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula8,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id8 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id9 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula9,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id9 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id9 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula9,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id9 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @volume_formula_id10 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@volume_formula10,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@volume_formula_id10 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END+','+

								CASE WHEN @price_formula_id10 is null THEN cast(0 AS varchar) ELSE  
								dbo.FNAFormulaTextContract(cast(@as_of_date AS varchar),0, 0,0,0,@price_formula10,@hour,1,1,0,0,
								0,0,0,0,0,0,0,cast(@price_formula_id10 AS varchar),0,0,0,0,cast(@as_of_date as varchar),cast(@as_of_date as varchar),0) END
										
							--	exec spa_print @formula_stmt
								EXEC(@formula_stmt)
								fetch next from cur2 into @as_of_date,@hour	
							END
						close cur2
						deallocate cur2

				fetch next from cur1 into @bid_offer_id,@block_id,
					@volume_formula_id1,@volume_formula1,@price_formula_id1,@price_formula1,
 					@volume_formula_id2,@volume_formula2,@price_formula_id2,@price_formula2,
 					@volume_formula_id3,@volume_formula3,@price_formula_id3,@price_formula3,
 					@volume_formula_id4,@volume_formula4,@price_formula_id4,@price_formula4,
 					@volume_formula_id5,@volume_formula5,@price_formula_id5,@price_formula5,
 					@volume_formula_id6,@volume_formula6,@price_formula_id6,@price_formula6,
 					@volume_formula_id7,@volume_formula7,@price_formula_id7,@price_formula7,
 					@volume_formula_id8,@volume_formula8,@price_formula_id8,@price_formula8,
 					@volume_formula_id9,@volume_formula9,@price_formula_id9,@price_formula9,
 					@volume_formula_id10,@volume_formula10,@price_formula_id10,@price_formula10

				END
	--------####
--				
			DELETE a
			FROM 
				bid_offer a
				JOIN #location b on a.location_id=b.location_id AND bid_offer=@bid_offer_flag 
				JOIN #formula_value c on a.offer_date=c.as_of_date AND a.offer_hour=c.[hour]-1
			WHERE 1=1
						
				
				INSERT INTO bid_offer(bid_offer,location_id,location_name,offer_date,offer_hour,volume1,price1,volume2,price2,volume3,price3,volume4,price4,volume5,price5,volume6,price6,volume7,price7,volume8,price8,volume9,price9,volume10,price10)
				select 
					@bid_offer_flag,
					loc.location_id,
					loc.location_name Location,
					fv.as_of_date,
					fv.[hour]-1,
					fv.volume1 ,
					fv.price1 ,
					fv.volume2 ,
					fv.price2 ,
					fv.volume3 ,
					fv.price3 ,
					fv.volume4 ,
					fv.price4 ,
					fv.volume5 ,
					fv.price5 ,
					fv.volume6 ,
					fv.price6 ,
					fv.volume7 ,
					fv.price7 ,
					fv.volume8 ,
					fv.price8 ,
					fv.volume9 ,
					fv.price9 ,
					fv.volume10 ,
					fv.price10 
				from 
					#formula_value fv
					CROSS JOIN #location loc
		END



		SET @sql_stmt=
				'SELECT 
					location_id [ID],
--					location_name [Location],
					dbo.FNADATEFORMAT(offer_date) [Offer Date],
					offer_hour+1 [Offer Hour],
					ROUND(volume1,'+CAST(@vol_round_value AS VARCHAR)+') Vol1,
					ROUND(price1,'+CAST(@price_round_value AS VARCHAR)+') Price1,
					ROUND(volume2,'+CAST(@vol_round_value AS VARCHAR)+') Vol2,
					ROUND(price2,'+CAST(@price_round_value AS VARCHAR)+')  Price2,
					ROUND(volume3,'+CAST(@vol_round_value AS VARCHAR)+') Vol3,
					ROUND(price3,'+CAST(@price_round_value AS VARCHAR)+')  Price3,
					ROUND(volume4,'+CAST(@vol_round_value AS VARCHAR)+') Vol4,
					ROUND(price4,'+CAST(@price_round_value AS VARCHAR)+') Price4,
					ROUND(volume5,'+CAST(@vol_round_value AS VARCHAR)+') Vol5,
					ROUND(price5 ,'+CAST(@price_round_value AS VARCHAR)+') Price5,
					ROUND(volume6,'+CAST(@vol_round_value AS VARCHAR)+') Vol6,
					ROUND(price6,'+CAST(@price_round_value AS VARCHAR)+')  Price6 ,
					ROUND(volume7,'+CAST(@vol_round_value AS VARCHAR)+') Vol7,
					ROUND(price7,'+CAST(@price_round_value AS VARCHAR)+')  Price7,
					ROUND(volume8,'+CAST(@vol_round_value AS VARCHAR)+') Vol8,
					ROUND(price8,'+CAST(@price_round_value AS VARCHAR)+')  Price8,
					ROUND(volume9,'+CAST(@vol_round_value AS VARCHAR)+') Vol9,
					ROUND(price9,'+CAST(@price_round_value AS VARCHAR)+')  Price9,
					ROUND(volume10,'+CAST(@vol_round_value AS VARCHAR)+') Vol10,
					ROUND(price10,'+CAST(@price_round_value AS VARCHAR)+')  Price10
				FROM bid_offer
				WHERE 1=1 '+
--				' AND bid_offer='''+@bid_offer_flag+''''
				+CASE WHEN @location_id IS NOT NULL THEN ' AND location_id IN('+@location_id+')' ELSE '' END
				+CASE WHEN @as_of_date IS NOT NULL THEN ' AND offer_date ='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
				+' AND offer_hour+1 between '+CAST(@hour_from AS VARCHAR)+' AND '+CAST(@hour_to AS VARCHAR)
	--	EXEC spa_print @sql_stmt	
		EXEC(@sql_stmt)	
	END
