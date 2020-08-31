IF NOT EXISTS (SELECT 1 FROM report_widget WHERE report_widget_id = 9)
BEGIN
	INSERT INTO report_widget (report_widget_id, [name], [description])
	SELECT 9, 'Multiselect Dropdown', 'Multiselect Dropdown'
END

GO