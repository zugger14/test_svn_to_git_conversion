/****** Object:  UserDefinedFunction [dbo].[FNARExAntePrice]    Script Date: 06/05/2009 17:27:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARExAntePrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARExAntePrice]
/****** Object:  UserDefinedFunction [dbo].[FNARExAntePrice]    Script Date: 06/05/2009 17:27:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARExAntePrice](
		@contract_id INT,
		@prod_date datetime,
		@he INT, 
		@half INT,
		@qtr INT,
		@product_type INT
	)

	RETURNS float AS  
	BEGIN 
	
		DECLARE @price float
		DECLARE @curve_id INT
		DECLARE @ExAnte_price_type INT
		DECLARE @location_id INT

		 SET @ExAnte_price_type=1980

			SELECT @location_id=location_id from rec_generator where ppa_contract_id=@contract_id	


			
			SELECT 
				@curve_id=curve_id 
			FROM	
				location_price_index 
			WHERE 
				location_id=@location_id
				AND	product_type_id=@product_type
				AND price_type_id=@ExAnte_price_type		



			SET @prod_date = dbo.FNAGetSQLStandardDate(@prod_date) + ' ' + 
			case when (@he < 10) then '0' else '' end +
			cast(@he-1 as varchar) + ':00:00'		

			SELECT
				@price = MAX(curve_value) 
			FROM 
				source_price_curve
			where 	
				source_curve_def_id = @curve_id 
				--as_of_date = @as_of_date and
				AND 
				dbo.FNAGetSQLStandardDateTime(maturity_date) = @prod_date
				
		
		
			return @price
	END















