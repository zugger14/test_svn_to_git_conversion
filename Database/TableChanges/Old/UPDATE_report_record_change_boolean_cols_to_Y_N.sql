--report_public, report_internal_description & report_sql_check value 
--should be (Y/N) instead of (1/0)

UPDATE Report_record SET report_public = 'Y' WHERE report_public = '1'
UPDATE Report_record SET report_public = 'N' WHERE report_public = '0'
UPDATE Report_record SET report_internal_description = 'Y' WHERE report_internal_description = '1'
UPDATE Report_record SET report_internal_description = 'N' WHERE report_internal_description = '0'
UPDATE Report_record SET report_sql_check = 'Y' WHERE report_sql_check = '1'
UPDATE Report_record SET report_sql_check = 'N' WHERE report_sql_check = '0'