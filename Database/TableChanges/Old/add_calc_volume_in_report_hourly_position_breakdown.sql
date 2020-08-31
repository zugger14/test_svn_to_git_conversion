if not exists(select 1 from sys.columns where [object_id]=object_id('report_hourly_position_breakdown') and [name]='calc_volume')
begin
	alter table report_hourly_position_breakdown drop column hr25
	alter table report_hourly_position_breakdown drop column hr24
	alter table report_hourly_position_breakdown drop column hr23
	alter table report_hourly_position_breakdown drop column hr22
	alter table report_hourly_position_breakdown drop column hr21
	alter table report_hourly_position_breakdown drop column hr20
	alter table report_hourly_position_breakdown drop column hr19
	alter table report_hourly_position_breakdown drop column hr18
	alter table report_hourly_position_breakdown drop column hr17
	alter table report_hourly_position_breakdown drop column hr16
	alter table report_hourly_position_breakdown drop column hr15
	alter table report_hourly_position_breakdown drop column hr14
	alter table report_hourly_position_breakdown drop column hr13
	alter table report_hourly_position_breakdown drop column hr12
	alter table report_hourly_position_breakdown drop column hr11
	alter table report_hourly_position_breakdown drop column hr10
	alter table report_hourly_position_breakdown drop column hr9
	alter table report_hourly_position_breakdown drop column hr8
	alter table report_hourly_position_breakdown drop column hr7
	alter table report_hourly_position_breakdown drop column hr6
	alter table report_hourly_position_breakdown drop column hr5
	alter table report_hourly_position_breakdown drop column hr4
	alter table report_hourly_position_breakdown drop column hr3
	alter table report_hourly_position_breakdown drop column hr2
	alter table report_hourly_position_breakdown drop column hr1
	alter table report_hourly_position_breakdown add calc_volume float
end