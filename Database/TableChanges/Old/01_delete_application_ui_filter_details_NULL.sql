DELETE FROM aufd
FROM application_ui_filter_details AS aufd  
INNER JOIN application_ui_filter auf ON auf.application_ui_filter_id = aufd.application_ui_filter_id
	AND auf.report_id IS NULL
WHERE 1=1
AND aufd.application_field_id IS NULL