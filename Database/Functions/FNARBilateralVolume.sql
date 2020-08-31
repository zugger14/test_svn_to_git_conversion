/****** Object:  UserDefinedFunction [dbo].[FNARBilateralVolume]    Script Date: 06/05/2009 17:28:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARBilateralVolume]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARBilateralVolume]
/****** Object:  UserDefinedFunction [dbo].[FNARBilateralVolume]    Script Date: 06/05/2009 17:28:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARBilateralVolume](
		@contract_id INT,
		@prod_date datetime,
		@he int, 
		@half int,
		@qtr int,
		@deal_id INT
	)

	RETURNS float AS  
	BEGIN 
	declare @volume float
	DECLARE @location_id INT
	DECLARE @udf_location_id INT
	

--	-- TEST
--	DECLARE @contract_id INT
--	DECLARE @prod_date DATETIME
--	DECLARE @he INT
--	
--	SET @contract_id=514
--	SET @prod_date='2009-02-12'
--	SET @he=1

	SET @udf_location_id=12579

	SELECT @location_id=location_id from rec_generator where ppa_contract_id=@contract_id
					


	select @volume=
		ISNULL(SUM(CASE WHEN @he=1 THEN Hr1
				 WHEN @he=2 THEN Hr2	
				 WHEN @he=3 THEN Hr3	
				 WHEN @he=4 THEN Hr4	
				 WHEN @he=5 THEN Hr5	
				 WHEN @he=6 THEN Hr6	
				 WHEN @he=7 THEN Hr7	
				 WHEN @he=8 THEN Hr8	
				 WHEN @he=9 THEN Hr9	
				 WHEN @he=10 THEN Hr10	
				 WHEN @he=11 THEN Hr11	
				 WHEN @he=12 THEN Hr12	
				 WHEN @he=13 THEN Hr13	
				 WHEN @he=14 THEN Hr14	
				 WHEN @he=15 THEN Hr15	
				 WHEN @he=16 THEN Hr16	
				 WHEN @he=17 THEN Hr17	
				 WHEN @he=18 THEN Hr18	
				 WHEN @he=19 THEN Hr19	
				 WHEN @he=20 THEN Hr20	
				 WHEN @he=21 THEN Hr21	
				 WHEN @he=22 THEN Hr22	
				 WHEN @he=23 THEN Hr23	
				 WHEN @he=24 THEN Hr24	
				END
			),0)	
		FROM mv90_data_hour 
		WHERE source_deal_header_id IN		
		( select sdd.source_deal_detail_id
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN user_defined_deal_fields uddf on uddf.source_deal_header_id=sdh.source_deal_header_id
			LEFT JOIN user_defined_deal_fields_template uddft on uddft.udf_template_id=uddf.udf_template_id
			AND field_id=@udf_location_id	
		WHERE
			 CAST(uddf.udf_value AS VARCHAR)=CAST(@location_id AS VARCHAR)
		)
		AND prod_date=@prod_date
		
	
		return @volume
	END















