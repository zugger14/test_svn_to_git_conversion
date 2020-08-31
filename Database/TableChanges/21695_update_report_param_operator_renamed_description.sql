UPDATE report_param_operator
SET [description] = 'Within next days'
WHERE [description] = 'Date Less Than'

UPDATE report_param_operator
SET [description] = 'On next days'
WHERE [description] = 'Date Equals To'

UPDATE report_param_operator
SET [description] = 'After next days'
WHERE [description] = 'Date Greater Than'

UPDATE report_param_operator
SET [description] = 'Not on Next Days'
WHERE [description] = 'Date Not Equals To'

DELETE FROM report_param_operator WHERE [description] IN ('Date Greater Than Equals To','Date Less Than Equals To')