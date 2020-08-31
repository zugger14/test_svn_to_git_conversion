IF OBJECT_ID(N'FNARMeterVol', N'FN') IS NOT NULL
DROP FUNCTION FNARMeterVol
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARMeterVol](
		@maturity_date DATETIME, 
		@he INT,	
		@mins INT,
		@granularity INT,
		@meter_id INT,		
		@num_of_month INT,		
		@channel INT,
		@is_dst INT,
		@block_defination INT,
		@contract_id INT,
		@counterparty_id INT
	)
	RETURNS FLOAT AS  
	BEGIN 
	DECLARE @volume FLOAT
		SET @maturity_date = DATEADD(m,@num_of_month,ISNULL(@maturity_date,0))
		SELECT @volume = [dbo].[FNARECChannel](@maturity_date, @he, @mins, @granularity, @meter_id, @contract_id, NULL, @Channel, @block_defination, @is_dst, @counterparty_id)
	
	RETURN @volume
	END















