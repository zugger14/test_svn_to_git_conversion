IF OBJECT_ID(N'[dbo].[spa_daylight_saving_time]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_daylight_saving_time]
GO


CREATE PROCEDURE [dbo].[spa_daylight_saving_time]
	@year int
AS

BEGIN
	
	select year,
		max(case when insert_delete='d' then dbo.fnadateformat(date) else NULL end) as dst_begin_date,
		max(case when insert_delete='d' then hour else NULL end) as dst_begin_hour,
		max(case when insert_delete='i' then dbo.fnadateformat(date) else NULL end) as dst_end_date,
		max(case when insert_delete='i' then hour else NULL end) as dst_end_hour
from
	mv90_DST where [year]=@year 
group by year


	


END







