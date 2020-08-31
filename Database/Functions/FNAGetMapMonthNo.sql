/****** Object:  UserDefinedFunction [dbo].[FNAGetMapMonthNo]    Script Date: 01/29/2009 12:59:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetMapMonthNo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetMapMonthNo]
go


create FUNCTION [dbo].[FNAGetMapMonthNo] (@curve_id as int ,@term_start as datetime,@as_of_date datetime)  
RETURNS int AS  
BEGIN 
declare @MapMonthNo INT
SET @MapMonthNo =null
	select	@MapMonthNo =
		case when map_no_of_months is not null 
		THEN 
			case when datediff(mm,@as_of_date,@term_start) between isnull(from_no_of_months,9999999) and isnull(to_no_of_months,9999999)
				then map_no_of_months 
				else datediff(mm,@as_of_date,@term_start) 
			end  
		else
			 datediff(mm,@as_of_date,@term_start)
		end 
	FROM [dbo].[var_time_bucket_mapping]
	a INNER JOIN 
	(
		SELECT  max([effective_date]) [effective_date] FROM [dbo].[var_time_bucket_mapping] 
		WHERE [effective_date]<=@as_of_date AND curve_id=@curve_id
	) b
	ON a.effective_date=b.[effective_date] AND a.curve_id=@curve_id
	SET @MapMonthNo=ISNULL(@MapMonthNo,datediff(mm,@as_of_date,@term_start))
return (@MapMonthNo)
end
