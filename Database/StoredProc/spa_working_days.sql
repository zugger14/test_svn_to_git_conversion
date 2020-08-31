/****** Object:  StoredProcedure [dbo].[spa_working_days]    Script Date: 07/06/2009 19:25:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_working_days]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_working_days]
/****** Object:  StoredProcedure [dbo].[spa_working_days]    Script Date: 07/06/2009 19:25:52 ******/

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[spa_working_days]
		@flag char(1),
		@block_value_id int=null,
		@holiday_calendar_value_id int=null,
		@week_day int=null,	
		@hour_block varchar(200)=Null

as
BEGIN
	
IF @flag='s'
 	select 	s.code,s.description,block_value_id,weekday,val
	 from working_days w
	 INNER JOIN static_data_value s	on w.block_value_id=s.value_id 
	 where value_id=@block_value_id  order by weekday

END
