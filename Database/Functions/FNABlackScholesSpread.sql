/****** Object:  UserDefinedFunction [dbo].[FNABlackScholesSpread]    Script Date: 05/08/2009 16:28:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNABlackScholesSpread]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNABlackScholesSpread]
/****** Object:  UserDefinedFunction [dbo].[FNABlackScholesSpread]    Script Date: 05/08/2009 16:28:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * FROM dbo.FNABlackScholesSpread ('c', 100, 112, 10, 0.5, 0.3, 0.1)
--select * FROM dbo.FNABlackScholesSpread ('p', 100, 112, 10, 0.5, 0.3, 0.1)

CREATE FUNCTION [dbo].[FNABlackScholesSpread] (@CallPutFlag varchar(100), @S1 float, @S2 float, @X float, 
				@T float, @R float, @P_VOL float,@V1 float, @V2 float,@C float)
returns @tt table(PREMIUM float, DELTA float, GAMMA float, VEGA float, THETA float, RHO float, DELTA2 float
,GAMMA2 float, VEGA2 float, RHO2 float, THETA2 float )
AS
BEGIN
-------TO TEST UNCOMEMNT THIS
/*
DECLARE @CallPutFlag varchar(100), @S1 float, @S2 float, @X float, @T float, @R float, @P_VOL float
SET @CallPutFlag = 'c' -- call should be 4.76 and put should be 0.81
SET @S1 = 100.00
SET @S2 = 112.00
SET @X = 10
SET @T = 0.5 --05
SET @R = 0.03
SET @P_VOL = 0.1
--
------Expected Results
----- Option Call = 4.7594 Put = 0.8086
----- Delta  Call = 0.7411 Put = -0.2101
-----
-----
*/
---------------------------------------

declare @d1 float
declare @d2 float
declare @BS float
declare @PI float
declare @DELTA float
declare @DELTA2 float
declare @GAMMA float
declare @VEGA float
declare @THETA float
declare @RHO float
declare @CND_D1 float
declare @CND_D2 float
declare @CND_ND1 float
declare @CND_ND2 float
declare @CND_D1_Q float
declare @CND_D2_Q float

declare @GAMMA2 float, @VEGA2 float, @RHO2 float, @THETA2 float


declare @PDVS2 float,@PD2VS2 float,@PDd2S2 float



set @PI = 3.14159265358979323846

--set @P_VOL = sqrt(power(@v, 2) - (2 * @S2 * @c * @v * @v2)/(@S2 + @X) + power(@S2/(@S2+@X), 2) * power(@v2, 2))

set @d1 = (Log(@S1 / NULLIF(@S2+@X,0)) + 0.5 * power(@P_VOL, 2) * @T) / NULLIF((@P_VOL * Sqrt(@T)),0)

set @d2 = @d1 - @P_VOL * Sqrt(@T)

set @CND_D1 = dbo.FNACND(@d1)
set @CND_D2 = dbo.FNACND(@d2)
set @CND_ND1 = dbo.FNACND(-@d1)
set @CND_ND2 = dbo.FNACND(-@d2)
set @CND_D1_Q = Exp(-0.5 * power(@d1,2))/Sqrt(2*@PI)
set @CND_D2_Q = Exp(-0.5 * power(@d2,2))/Sqrt(2*@PI)


set @BS = Exp(-@R * @T) *  ((@S1 * @CND_D1) - ((@S2 + @X) * @CND_D2))

If @CallPutFlag = 'c'
begin
	set @DELTA = Exp(-@R * @T) * @CND_D1
	set @DELTA2 = -1 * Exp(-@R * @T) * @CND_D2
	set @RHO = @X * @T * Exp(-@R * @T) * @CND_D2
	set @THETA = ((-@S1 * @CND_D1_Q * @P_VOL)/NULLIF((2 * Sqrt(@T)),0)) - (@R * @X * Exp(-@R * @T) * @CND_D2)
end 
else -- IT WILL BE PUT
begin
	set @BS = @BS - Exp(-@R * @T) * (@S1 - @S2 - @X)
	set @DELTA = Exp(-@R * @T) * (@CND_D1 - 1)
	set @DELTA2 =  -1 * Exp(-@R * @T) * (@CND_D2 - 1)
	set @RHO = -@X * @T * Exp(-@R * @T) * @CND_ND2
	set @THETA = ((-@S1 * @CND_D1_Q * @P_VOL)/NULLIF((2 * Sqrt(@T)),0)) + (@R * @X * Exp(-@R * @T) * @CND_ND2)
end 

set @GAMMA = @CND_D1_Q/NULLIF((@S1* @P_VOL * Sqrt(@T)),0)
set @VEGA =  @CND_D1_Q * @S1 * Sqrt(@T)

set	   @PDVS2 = (@V2 * @X / @P_VOL) * ((@V2 * @S2 / (@S2 + @X)) - @C * @V1) / power((@S2 + @X), 2)
set	   @PD2VS2 = @V2 * @X / ( power(@P_VOL, 2) * power((@S2 + @X), 3)) * (@P_VOL *@V2 * @X / (@S2 + @X) + (@C * @V1 - (@V2 * @S2 / (@S2 + @X))) * (2* @P_VOL + (@S2 + @X) * @PDVS2))
set	   @PDd2S2 = - 1 / @P_VOL * @PDVS2 * @d1 - 1/(@P_VOL * Sqrt(@T) * (@S2 + @X))

set @GAMMA2 =  Exp(-@R * @T) * @CND_D2_Q *(- @PDd2S2 + Sqrt(@T) * ( @PDVS2 + (@S2 + @X)* (@PD2VS2 - @d2 * @PDd2S2 * @PDVS2)))


set @VEGA2 = null
set @RHO2 = null
set @THETA2 = null




--select @BS Premium, @DELTA Delta, @GAMMA Gamma, @VEGA Vega, @RHO Rho, @THETA Theta

INSERT INTO @tt values(@BS, @DELTA, @GAMMA, @VEGA, @THETA, @RHO, @DELTA2,@GAMMA2, @VEGA2, @RHO2, @THETA2)

RETURN

END