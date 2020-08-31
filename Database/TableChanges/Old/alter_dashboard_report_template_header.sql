BEGIN TRAN 
ALTER TABLE dashboard_report_template_header ADD report_view_type CHAR(1) 
COMMIT 