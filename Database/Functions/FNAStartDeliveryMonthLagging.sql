set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




--select dbo.Curve('3/1/2004', 4500, '7/1/2004', 1)
--select dbo.Curve('4/1/2004', 4500, '7/1/2004', 1)

/*
select [dbo].[FNAStartDeliveryMonthLagging]('2007-01-01',2)
select [dbo].[FNAStartDeliveryMonthLagging]('2007-05-01',2)
select [dbo].[FNAStartDeliveryMonthLagging]('2007-09-01',2)
select [dbo].[FNAStartDeliveryMonthLagging]('2007-11-01',2)

*/
IF OBJECT_ID('[dbo].[FNAStartDeliveryMonthLagging]') IS NOT NULL
DROP FUNCTION [dbo].[FNAStartDeliveryMonthLagging]
go
create FUNCTION [dbo].[FNAStartDeliveryMonthLagging] (@delivery_date datetime,@Strip_Month_To int)
RETURNS datetime AS  
BEGIN 



DECLARE @ret_val datetime
SELECT @ret_val=CAST(CAST(year(@delivery_date) AS VARCHAR) +'-' +
							 CAST((((MONTH(@delivery_date)/@Strip_Month_To
								) + 
								CASE WHEN MONTH(@delivery_date)%@Strip_Month_To=0 THEN -1 ELSE 0 END
							   )* @Strip_Month_To
							  )+1 AS VARCHAR) + '-01'  AS DATETIME)


	return(@ret_val)
END




