IF NOT EXISTS(SELECT 1 FROM report_widget WHERE [name] = 'DataBrowser')
BEGIN
    INSERT INTO report_widget
	(
		[report_widget_id],
		[name],
		[description]
	)
	VALUES
	(
		7,
		'OpenWindow',
		'OpenWindow'
	)
	PRINT 'Report Widget already exists.'
END
ELSE
BEGIN
    PRINT 'Function ID 10201700 already exists.'
END

UPDATE report_widget SET [name] = 'DataBrowser' WHERE report_widget_id = 7