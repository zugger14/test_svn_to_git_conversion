IF COL_LENGTH('clr_error_log','stack_trace') IS NOT NULL
BEGIN 
	ALTER TABLE clr_error_log ALTER COLUMN stack_trace NVARCHAR(MAX)
END