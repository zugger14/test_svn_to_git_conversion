IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'application_users' AND column_name = 'share_calendar')
	ALTER TABLE application_users ADD share_calendar INT