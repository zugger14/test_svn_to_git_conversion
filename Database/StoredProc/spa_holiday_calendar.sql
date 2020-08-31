/****** Object:  StoredProcedure [dbo].[spa_var_measurement_criteria]    Script Date: 07/06/2009 19:25:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_holiday_calendar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_holiday_calendar]
/****** Object:  StoredProcedure [dbo].[spa_holiday_calendar]    Script Date: 07/06/2009 19:25:52 ******/

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE procedure [dbo].[spa_holiday_calendar]
	@flag char(1),
	@hol_group_id int=NULL,
	@hol_group_value_id int=NULL,
	@fromdate datetime=NULL,
	@todate datetime=NULL,
	@description varchar(100)=NULL,
	@exp_date DATETIME

as
BEGIN
	
IF @flag='s'

	select hol_group_id [ID],dbo.FNADateFormat(hol_date) [Date],dbo.FNADateFormat(exp_date) AS [Expiration Date],hg.[description] [Description]
	 from 	holiday_calendar hg inner join static_data_value sd on
	sd.value_id=hg.hol_group_value_id where hol_group_value_id=@hol_group_value_id
	and hol_date between @fromdate and @todate

IF @flag='a'

	select hol_group_id [ID],dbo.FNADateFormat(hol_date) [Date],hg.[description] [Description],dbo.FNADateFormat(exp_date)
	 from holiday_calendar hg inner join static_data_value sd on
	sd.value_id=hg.hol_group_value_id where hol_group_id=@hol_group_id


IF @flag='i'
BEGIN
	insert into holiday_calendar(hol_group_value_id,hol_date,[description],exp_date)
	select @hol_group_value_id,@fromdate,@description,@exp_date

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Holiday Group', 
				'spa_holiday_calendar', 'DB Error', 
			'Error Inserting Values', ''
	else
		Exec spa_ErrorHandler 0, 'Holiday Group', 
				'spa_holiday_calendar', 'Success', 
				'Holiday values successfully Inserted.', ''
END

IF @flag='u'
BEGIN
	update holiday_calendar
	set
		hol_date=@fromdate,
		exp_date=@exp_date,
		[description]=@description
	where 
		hol_group_id=@hol_group_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Holiday Group', 
				'spa_holiday_calendar', 'DB Error', 
			'Error Updating Values', ''
	else
		Exec spa_ErrorHandler 0, 'Holiday Group', 
				'spa_holiday_calendar', 'Success', 
				'Holiday values successfully Updated.', ''
END

IF @flag='d'
BEGIN
	delete from 
		holiday_calendar
	where 
		hol_group_id=@hol_group_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Holiday Group', 
				'spa_holiday_calendar', 'DB Error', 
			'Error Deleting Values', ''
	else
		Exec spa_ErrorHandler 0, 'Holiday Group', 
				'spa_holiday_calendar', 'Success', 
				'Holiday values successfully Deleted.', ''
END
END





