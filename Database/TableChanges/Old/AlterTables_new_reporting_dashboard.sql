IF COL_LENGTH('report_group_parameters_criteria', 'paramset_id') IS NOT NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria DROP COLUMN paramset_id
END
GO
IF COL_LENGTH('report_group_parameters_criteria', 'rds_alias_combined') IS NOT NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria DROP COLUMN rds_alias_combined
END
GO
IF COL_LENGTH('report_group_parameters_criteria', 'report_description') IS NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria ADD report_description VARCHAR(500)
END
GO
IF COL_LENGTH('report_group_parameters_criteria', 'section') IS NOT NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria DROP COLUMN section
END
GO

IF COL_LENGTH('report_group_parameters_criteria', 'report_writer_id') IS NOT NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria DROP COLUMN report_writer_id
END
GO

IF COL_LENGTH('report_group_parameters_criteria', 'report_name') IS NOT NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria DROP COLUMN report_name
END
GO

IF COL_LENGTH('report_group_parameters_criteria', 'paramset_hash') IS NULL
BEGIN
    ALTER TABLE report_group_parameters_criteria ADD paramset_hash VARCHAR(500)
END
GO

IF COL_LENGTH('report_group_parameters_criteria', 'critetia') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'report_group_parameters_criteria.[critetia]' , 'criteria', 'COLUMN'
END
GO

IF COL_LENGTH('my_report', 'group_id') IS NULL
BEGIN
    ALTER TABLE my_report ADD group_id INT
END
GO

IF COL_LENGTH('my_report', 'criteria_flag') IS NOT NULL
BEGIN
   ALTER TABLE my_report DROP COLUMN criteria_flag
END
GO


IF COL_LENGTH('report_manager_group', 'refresh_time') IS NULL
BEGIN
    ALTER TABLE report_manager_group ADD refresh_time INT
END
GO
