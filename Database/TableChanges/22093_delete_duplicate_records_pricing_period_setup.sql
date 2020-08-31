
-- delete duplicate records in table [dbo].[pricing_period_setup] where pricing_period_value_id is unique column

while (1=1)
begin
	delete top(1) a from [dbo].[pricing_period_setup] a 
	inner join
	(
		select pricing_period_value_id,count(1) no_rec from [dbo].[pricing_period_setup] 
		group by pricing_period_value_id -- unique colum/s
		having count(1)>1
	) b on a.pricing_period_value_id=b.pricing_period_value_id -- join with unique colum/s
	if @@rowcount=0 break
end