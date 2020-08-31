/****** Object:  UserDefinedFunction [dbo].[FNARExPostPrice]    Script Date: 07/28/2009 18:08:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARExPostPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARExPostPrice]
/****** Object:  UserDefinedFunction [dbo].[FNARExPostPrice]    Script Date: 07/28/2009 18:08:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARExPostPrice](
		@contract_id INT,
		@prod_date datetime,
		@he INT, 
		@half INT,
		@qtr INT,
		@product_type INT,
		@location_id INT
	)

	RETURNS FLOAT AS  
	BEGIN 
	
		DECLARE @price float
		DECLARE @curve_id INT
		DECLARE @ExPost_price_type INT
		--DECLARE @location_id INT

		 SET @ExPost_price_type=1981

			IF @location_id IS NULL
				SELECT @location_id=location_id from rec_generator where ppa_contract_id=@contract_id	


			
			SELECT 
				@curve_id=curve_id 
			FROM	
				location_price_index 
			WHERE 
				location_id=@location_id
				AND	product_type_id=@product_type
				AND price_type_id=@ExPost_price_type		



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















