
if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('report_hourly_position_profile'))
	alter table report_hourly_position_profile add expiration_date datetime
	

if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('report_hourly_position_breakdown'))
	alter table report_hourly_position_breakdown add expiration_date datetime
	
if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('report_hourly_position_deal'))
	alter table report_hourly_position_deal add expiration_date datetime

	

if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('delta_report_hourly_position_profile'))
	alter table delta_report_hourly_position_profile add expiration_date datetime
	

if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('delta_report_hourly_position_breakdown'))
	alter table delta_report_hourly_position_breakdown add expiration_date datetime
	
if not exists( select 1 from sys.columns where name='expiration_date' and [object_id]=object_id('delta_report_hourly_position_deal'))
	alter table delta_report_hourly_position_deal add expiration_date datetime