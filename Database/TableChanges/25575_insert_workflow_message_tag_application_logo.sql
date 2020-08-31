IF NOT EXISTS (SELECT 1 FROM workflow_message_tag WHERE workflow_message_tag = '<APPLICATION_LOGO>')
BEGIN
	INSERT INTO workflow_message_tag (
		workflow_message_tag_name
		, workflow_message_tag
		, module_id
		, workflow_tag_query
		, system_defined
		, is_hyperlink
	)
	VALUES (
		'APPLICATION LOGO'
		, '<APPLICATION_LOGO>'
		, 20601
		, 'DECLARE @name VARCHAR(200)
	  , @workflow_activity_id INT

SELECT TOP(1) @name = wem.event_message_name, 
    @workflow_activity_id = wa.workflow_activity_id 
FROM workflow_activities wa
INNER JOIN workflow_event_message wem ON wa.event_message_id = wem.event_message_id
WHERE LTRIM(RTRIM(source_id)) = ''@_source_id'' AND source_column = ''source_deal_header_id'' AND wa.control_status IS NULL
ORDER BY 1 DESC

SELECT ISNULL(@workflow_activity_id,0) [workflow_activity_id], ''<img src="'' + file_attachment_path + ''" alt="Logo">'' [application_logo] FROM connection_string'
		, 0
		, 0
	)	
END