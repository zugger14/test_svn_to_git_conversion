
--to remove garbage data,
update source_price_curve_def set exp_calendar_id=NULL where exp_calendar_id is not null and exp_calendar_id not in (select value_id from static_data_value where type_id=10017)