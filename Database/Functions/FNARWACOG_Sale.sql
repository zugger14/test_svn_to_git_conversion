--SELECT dbo.FNARWACOG_Sale ('2009-08-15',350)
IF OBJECT_ID('[dbo].[FNARWACOG_Sale]') IS NOT null
DROP FUNCTION [dbo].[FNARWACOG_Sale]
go
--DECLARE @book_id INT, @as_of_date DATETIME
--SELECT @book_id=4,@as_of_date='2009-08-01'
CREATE FUNCTION dbo.FNARWACOG_Sale(@as_of_date DATETIME, @book_id int) 
RETURNS float AS 
begin 
 DECLARE @ret_val float

SELECT 
		@ret_val=SUM((ISNULL(spc.curve_value,0)+ISNULL(sdd.fixed_price,0)+ISNULL(sdd.price_adder,0)+ISNULL(fixed_cost,0))*ISNULL(sdd.deal_volume,0))/SUM(sdd.deal_volume) 
		
			from source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			AND sdd.buy_sell_flag='s'
				and sdd.term_start=@as_of_date 
			INNER JOIN 
			source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
											ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
											ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
											ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			AND ssbm.fas_book_id=@book_id
			left JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 								
			LEFT JOIN dbo.source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id	
			AND spc.as_of_date=	@as_of_date AND spc.maturity_date=@as_of_date						
											
											
RETURN @ret_val
end