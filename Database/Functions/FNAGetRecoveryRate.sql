/****** Object:  UserDefinedFunction [dbo].[FNAGetRecoveryRate]    Script Date: 12/29/2008 16:02:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetRecoveryRate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetRecoveryRate]


go
create FUNCTION [dbo].[FNAGetRecoveryRate] (@debt_rating as int ,@months as int,@as_of_date datetime)  
RETURNS float AS  
BEGIN 
declare @Recovery_Rate float

select @Recovery_Rate=rate from dbo.default_recovery_rate x inner join
(

	select max(a.effective_date) effective_date,min(case when months>=@months then months else null end) months_as_of_date,
	max(isnull(months,-1)) months 
	from [dbo].default_recovery_rate  a
	 INNER JOIN 
	(
		SELECT max([effective_date]) [effective_date] FROM [dbo].default_recovery_rate 
		WHERE [effective_date]<=@as_of_date and debt_rating=@debt_rating
	) b
	ON a.effective_date=b.[effective_date] and a.debt_rating=@debt_rating

) y 
on isnull(x.months,-1)=isnull(y.months_as_of_date,y.months) AND x.effective_date=y.effective_date AND x.debt_rating=@debt_rating

return (@Recovery_Rate)
end

