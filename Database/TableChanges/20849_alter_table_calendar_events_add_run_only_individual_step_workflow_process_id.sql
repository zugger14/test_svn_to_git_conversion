IF COL_LENGTH('calendar_events','run_only_individual_step') IS NULL
	ALTER TABLE calendar_events ADD run_only_individual_step CHAR(1)


IF COL_LENGTH('calendar_events','workflow_process_id') IS NULL
	ALTER TABLE calendar_events ADD workflow_process_id VARCHAR(300)