IF COL_LENGTH('report_hourly_position_breakdown', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_breakdown.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('report_hourly_position_deal', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_deal.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('report_hourly_position_profile', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_profile.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('report_hourly_position_profile_blank', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_profile_blank.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('report_hourly_position_fixed', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_fixed.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('report_hourly_position_financial', 'create_usr') IS NOT NULL
	EXEC sp_rename 'report_hourly_position_financial.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_report_hourly_position_profile', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_report_hourly_position_profile.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_report_hourly_position_deal', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_report_hourly_position_deal.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_report_hourly_position_fixed', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_report_hourly_position_fixed.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_delta_report_hourly_position_breakdown', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_delta_report_hourly_position_breakdown.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_delta_report_hourly_position', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_delta_report_hourly_position.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('delta_report_hourly_position_profile', 'create_usr') IS NOT NULL
	EXEC sp_rename 'delta_report_hourly_position_profile.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('delta_report_hourly_position_financial', 'create_usr') IS NOT NULL
	EXEC sp_rename 'delta_report_hourly_position_financial.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('delta_report_hourly_position_breakdown', 'create_usr') IS NOT NULL
	EXEC sp_rename 'delta_report_hourly_position_breakdown.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('delta_report_hourly_position', 'create_usr') IS NOT NULL
	EXEC sp_rename 'delta_report_hourly_position.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('dedesignated_link_deal', 'create_usr') IS NOT NULL
	EXEC sp_rename 'dedesignated_link_deal.create_usr', 'create_user', 'COLUMN';

IF COL_LENGTH('stage_report_hourly_position_breakdown', 'create_usr') IS NOT NULL
	EXEC sp_rename 'stage_report_hourly_position_breakdown.create_usr', 'create_user', 'COLUMN';





