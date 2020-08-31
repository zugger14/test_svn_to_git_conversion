/****** Object:  UserDefinedFunction [dbo].[FNARExAnteVolume]    Script Date: 06/05/2009 17:30:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARExAnteVolume]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARExAnteVolume]
/****** Object:  UserDefinedFunction [dbo].[FNARExAnteVolume]    Script Date: 06/05/2009 17:30:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARExAnteVolume](
		@contract_id INT,
		@prod_date datetime,
		@he int, 
		@half int,
		@qtr int
	)

	RETURNS float AS  
	BEGIN 
	DECLARE @volume float
	DECLARE @location_id INT
	
	SELECT @location_id=location_id from rec_generator where ppa_contract_id=@contract_id

-- If the location is generator, then we get the volume from dispatch_volume else load_forecast
			
		if exists(select generator_id from source_generator where location_id=@location_id)
			BEGIN
				select 
					@volume=dispatch_volume 
				FROM  
					dispatch_volume
				WHERE
					location_id=@location_id
					AND dispatch_date=@prod_date
					AND dispatch_hour=@he					 

			END

		ELSE
			BEGIN
				select 
					@volume=load_forecast_volume 
				FROM  
					load_forecast
				WHERE
					location_id=@location_id
					AND load_forecast_date=@prod_date
					AND load_forecast_hour=@he			

			END
	
		return @volume
	END















