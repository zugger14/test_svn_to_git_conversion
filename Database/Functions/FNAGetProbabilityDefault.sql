IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetProbabilityDefault]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetProbabilityDefault]
GO

create FUNCTION [dbo].[FNAGetProbabilityDefault] (@debt_rating as int ,@months as int,@as_of_date datetime)  
RETURNS float AS  
BEGIN 
---------------------------------------
--DECLARE @debt_rating as int ,@months as int,@as_of_date DATETIME
--SELECT @debt_rating= 10616,@months=11,@as_of_date ='2001-01-01'

----------------------------------------------
declare @Probability float
select 
@Probability=
Probability from dbo.default_probability x inner join
(
	select max(a.effective_date) effective_date,min(case when months>=@months then months else null end) months_as_of_date,
	min(isnull(months,-1)) months 
	from default_probability 
	a INNER JOIN 
	(
		SELECT  max([effective_date]) [effective_date] FROM [dbo].default_probability 
		WHERE [effective_date]<=@as_of_date and debt_rating=@debt_rating
	) b
	ON a.effective_date=b.[effective_date] and a.debt_rating=@debt_rating

) y 
on isnull(x.months,-1)=isnull(y.months_as_of_date,y.months) AND x.effective_date=y.effective_date AND x.debt_rating=@debt_rating
return (@Probability)
end

--SELECT * FROM dbo.default_probability WHERE debt_rating= @debt_rating