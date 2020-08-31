/****** Object:  UserDefinedFunction [dbo].[FNACalcOptionsPrem]    Script Date: 05/08/2009 16:37:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACalcOptionsPrem]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACalcOptionsPrem]
/****** Object:  UserDefinedFunction [dbo].[FNACalcOptionsPrem]    Script Date: 05/08/2009 16:37:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- select * from dbo.FNACalcOptionsPrem('c', 'a', null,null, 2,null, 20, null, 42, null, 40, 0.5, 0.1, 0.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
-- select * from dbo.FNACalcOptionsPrem('p', 'a', null,null, 2,null, 20, null, 42, null, 40, 0.5, 0.1, 0.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
-- select * from dbo.FNACalcOptionsPrem('c', 'a', null,null, 3,null, null, null, 100, 112, 10, 0.5, 0.03, 0.1, 0.2, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
-- select * from dbo.FNACalcOptionsPrem('p', 'a', null,null, 3,null, null, null, 100, 112, 10, 0.5, 0.03, 0.1, 0.2, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
-- select * from dbo.FNACalcOptionsPrem('c', 'a', null,null, 18,null, null, null, 100, 112, 0, 0.5, 0.03, 0.1, 0.2, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
-- select * from dbo.FNACalcOptionsPrem('p', 'a', null,null, 18,null, null, null, 100, 112, 0, 0.5, 0.03, 0.1, 0.2, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)

CREATE  Function [dbo].[FNACalcOptionsPrem](@CallPutFlag varchar(100), 
					@ExcerciseType varchar(100),
					@DealType int,
					@SubDealType int,
					@InternalDealType int,
					@InternalSubDealType int,
					@F1 float, @F2 float,  --forward prices 
					@S1 float, @S2 float,  -- spot prices
					@X float, --strike price
					@T float, --time to expiration
					@R float, --discount rate
					@V1 float, @V2 float, -- volatilities
					@C float, -- correlation,
					@UPARAM1 float,
					@UPARAM2 float,
					@UPARAM3 float,
					@UPARAM4 float,
					@UPARAM5 float,
					@UPARAM6 float,
					@UPARAM7 float,
					@UPARAM8 float,
					@UPARAM9 float,
					@CUST_ID int
					) 
returns @ttf table(PREMIUM float, DELTA float, GAMMA float, VEGA float, THETA float, RHO float, DELTA2 float
,GAMMA2 float, VEGA2 float, RHO2 float, THETA2 float )

as
begin

--return dbo.FNABlackScholes('c', 20, 25, 340, 0.06, 0.4) 
    if @InternalDealType = 2 
	begin
		insert into @ttf select * from dbo.FNABlackScholes(@CallPutFlag, @S1, @X, @T, @R, @V1) 
	end
	else
	begin
		--calculate portfolio volatility
		DECLARE @P_VOL float
		set @P_VOL = sqrt(abs(power(@V1, 2) - (2 * @S2 * @C * @V1 * @V2)/(@S2 + @X) + power(@S2/(@S2+@X), 2) * power(@V2, 2)))
	
		IF @P_VOL = 0
			SET @P_VOL = 0.0000001


		if @InternalDealType = 18 
		begin
			insert into @ttf select * from dbo.FNABlackScholes(@CallPutFlag, @S1, @S2, @T, @R, @P_VOL) 
		end	
		if @InternalDealType = 3 
		begin
			insert into @ttf select * from dbo.FNABlackScholesSpread(@CallPutFlag, @S1, @S2, @X, @T, @R, @P_VOL,@V1, @V2,@C) 
		end	

	end

	Return 

End