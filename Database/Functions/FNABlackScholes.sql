/****** Object:  UserDefinedFunction [dbo].[FNABlackScholes]    Script Date: 05/08/2009 16:28:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNABlackScholes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNABlackScholes]
/****** Object:  UserDefinedFunction [dbo].[FNABlackScholes]    Script Date: 05/08/2009 16:28:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * FROM dbo.FNABlackScholes ('c', 42, 40, 0.5, 0.1,0.2)
--select * FROM dbo.FNABlackScholes ('p', 42, 40, 0.5, 0.1,0.2)

CREATE FUNCTION [dbo].[FNABlackScholes] (@CallPutFlag varchar(100), @S float, @X float, @T
									float, @r float, @v float)
returns @tt table(PREMIUM float, DELTA float, GAMMA float, VEGA float, THETA float, RHO float, DELTA2 float
,GAMMA2 float, VEGA2 float, RHO2 float, THETA2 float )
AS
BEGIN
-------TO TEST UNCOMEMNT THIS
--DECLARE @CallPutFlag varchar(100), @S float, @X float, @T float, @r float, @v float
--SET @CallPutFlag = 'c' -- call should be 4.76 and put should be 0.81
--SET @S = 42.00
--SET @X = 40
--SET @T = 152 --05
--SET @r = 0.1
--SET @V = 0.2
--
------Expected Results
----- Option Call = 4.7594 Put = 0.8086
----- Delta  Call = 0.7411 Put = -0.2101
-----
-----
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

declare @GAMMA2 float, @VEGA2 float, @RHO2 float, @THETA2 float

set @PI = 3.14159265358979323846

set @d1 = (Log(@S / NULLIF(@X,0)) + (@r + power(@v,2) / 2) * @T) / NULLIF((@v * Sqrt(@T)),0)
set @d2 = @d1 - @v * Sqrt(@T)


set @CND_D1 = dbo.FNACND(@d1)
set @CND_D2 = dbo.FNACND(@d2)
set @CND_ND1 = dbo.FNACND(-@d1)
set @CND_ND2 = dbo.FNACND(-@d2)
set @CND_D1_Q = Exp(-0.5 * power(@d1,2))/Sqrt(2*@PI)



If @CallPutFlag = 'c'
begin
	set @BS = @S * @CND_D1 - @X * Exp(-@r * @T) * @CND_D2
	set @DELTA = Exp(-@r * @T) * @CND_D1
	set @DELTA2 = -1 * Exp(-@r * @T) * @CND_D2
	set @RHO = @X * @T * Exp(-@r * @T) * @CND_D2
	set @THETA = ((-@S * @CND_D1_Q * @v)/NULLIF((2 * Sqrt(@T)),0)) - (@r * @X * Exp(-@r * @T) * @CND_D2)
end 
else -- IT WILL BE PUT
begin
	set @BS = @X * Exp(-@r * @T) * @CND_ND2 - @S * @CND_ND1
	set @DELTA = Exp(-@r * @T) * (@CND_D1 - 1)
	set @DELTA2 = -1 * Exp(-@r * @T) * (@CND_D2 - 1)
	set @RHO = -@X * @T * Exp(-@r * @T) * @CND_ND2
	set @THETA = ((-@S * @CND_D1_Q * @v)/NULLIF((2 * Sqrt(@T)),0)) + (@r * @X * Exp(-@r * @T) * @CND_ND2)
end 

set @GAMMA = @CND_D1_Q/NULLIF((@S* @v * Sqrt(@T)),0)
set @VEGA =  @CND_D1_Q * @S * Sqrt(@T)

set @GAMMA2 =null
set @VEGA2 = null
set @RHO2 = null
set @THETA2 = null


--select @BS Premium, @DELTA Delta, @GAMMA Gamma, @VEGA Vega, @RHO Rho, @THETA Theta

INSERT INTO @tt values(@BS, @DELTA, @GAMMA, @VEGA, @THETA, @RHO, @DELTA2,@GAMMA2, @VEGA2, @RHO2, @THETA2)

RETURN

END
