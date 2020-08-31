/****** Object:  UserDefinedFunction [dbo].[FNARAverageHourlyPrice]    Script Date: 06/15/2010 18:30:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARAverageHourlyPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARAverageDailyPrice]
GO
CREATE FUNCTION [dbo].[FNARAverageDailyPrice](@deal_id int,@maturity_date DATETIME,@as_of_date DATETIME,@curve_id INT)
RETURNS float AS  
BEGIN 

	--DECLARE @deal_id int,@maturity_date DATETIME,@as_of_date DATETIME
	DECLARE @contract_id INT
	DECLARE @avg_price float
	DECLARE @block_type INT
	DECLARE @block_define_id INT 

--	SET @deal_id=919
--	SET @maturity_date='2010-01-01'
--	SET @as_of_date='2010-01-01'
--	SET @curve_id=13


	select @contract_id=contract_id, @block_define_id=block_define_id,@block_type=block_type 
		from source_deal_header sdh
			 INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		where 
			sdd.source_deal_detail_id=@deal_id


--	select @block_define_id=291307
--	select @block_type=12000


	select @avg_price=
			--spc.curve_value,flag,substring(a.hr,3,2)
			AVG(spc.curve_value)
	FROM
		source_price_curve_def spcd 
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id

	WHERE
		spcd.source_curve_def_id=@curve_id
		AND dbo.fnagetcontractmonth(spc.maturity_date)=dbo.fnagetcontractmonth(@maturity_date)
		--AND spc.as_of_date=@as_of_date


	RETURN @avg_price
END
