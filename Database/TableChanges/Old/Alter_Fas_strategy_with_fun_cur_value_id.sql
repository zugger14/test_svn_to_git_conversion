
IF NOT EXISTS(SELECT 'x' FROM information_schema.columns WHERE table_name LIKE 'fas_strategy' AND column_name LIKE 'fun_cur_value_id')
	ALTER TABLE [dbo].[fas_strategy] ADD fun_cur_value_id INT 
GO