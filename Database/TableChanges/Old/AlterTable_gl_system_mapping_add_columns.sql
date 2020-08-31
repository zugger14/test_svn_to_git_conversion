IF col_length('gl_system_mapping','is_active') IS  NULL
ALTER TABLE gl_system_mapping ADD  is_active VARCHAR(100) NULL

IF col_length('gl_system_mapping','account_type') IS  NULL
ALTER TABLE gl_system_mapping  add account_type VARCHAR(100) NULL

IF col_length('gl_system_mapping','is_reversal') IS  NULL
ALTER TABLE gl_system_mapping  add is_reversal VARCHAR(100) NULL

IF col_length('gl_system_mapping','account') IS  NULL
ALTER TABLE gl_system_mapping  add account VARCHAR(100) NULL

IF col_length('gl_system_mapping','type') IS  NULL
ALTER TABLE gl_system_mapping  add [type] VARCHAR(100) NULL

--add cols for gl codes
IF col_length('gl_system_mapping','gl_code_1') IS  NULL
ALTER TABLE gl_system_mapping ADD  gl_code_1 VARCHAR(100) NULL
--EXEC sp_RENAME 'gl_system_mapping.account', 'chart_of_account_name', 'COLUMN'
IF col_length('gl_system_mapping','gl_code_2') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_2 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_3') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_3 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_4') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_4 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_5') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_5 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_6') IS  NULL
ALTER TABLE gl_system_mapping ADD  gl_code_6 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_7') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_7 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_8') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_8 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_9') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_9 VARCHAR(100) NULL

IF col_length('gl_system_mapping','gl_code_10') IS  NULL
ALTER TABLE gl_system_mapping  add gl_code_10 VARCHAR(100) NULL