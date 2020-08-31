/*
* insertion on table report_param_operator
* sligal
*/
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 1)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (1, N'Equals To', N'=')	
	PRINT 'report Param Operator ID 1 inserted.'
END
ELSE PRINT 'Report Param Operator ID 1 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 2)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (2, N'Greater Than', N'>')	
	PRINT 'report Param Operator ID 2 inserted.'
END
ELSE PRINT 'Report Param Operator ID 2 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 3)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (3, N'Less Than', N'<')	
	PRINT 'report Param Operator ID 3 inserted.'
END
ELSE PRINT 'Report Param Operator ID 3 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 4)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (4, N'Greater Than Equals To', N'>=')
	PRINT 'report Param Operator ID 4 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 4 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 5)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (5, N'Less Than Equals To', N'<=')	
	PRINT 'report Param Operator ID 5 inserted.'
END
ELSE PRINT 'Report Param Operator ID 5 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 6)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (6, N'IS NULL', N'IS NULL')
	PRINT 'report Param Operator ID 6 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 6 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 7)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (7, N'IS NOT NULL', N'IS NOT NULL')
	PRINT 'report Param Operator ID 7 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 7 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 8)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (8, N'BETWEEN', N'BETWEEN')
	PRINT 'report Param Operator ID 8 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 8 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 9)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (9, N'IN', N'IN')
	PRINT 'report Param Operator ID 9 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 9 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 10)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (10, N'Not IN', N'NOT IN')
	PRINT 'report Param Operator ID 10 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 10 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 11)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (11, N'Not Equals To', N'<>')
	PRINT 'report Param Operator ID 11 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 11 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 12)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (12, N'LIKE', N'LIKE')
	PRINT 'report Param Operator ID 12 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 12 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 13)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (13, N'NOT LIKE', N'NOT LIKE')
	PRINT 'report Param Operator ID 13 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 13 already EXISTS.'



IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 14)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (14, N'Date Equals To', N'=')
	PRINT 'report Param Operator ID 14 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 14 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 15)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (15, N'Date Greater Than', N'>')
	PRINT 'report Param Operator ID 15 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 15 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 16)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (16, N'Date Less Than', N'<')
	PRINT 'report Param Operator ID 16 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 16 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 17)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (17, N'Date Greater Than Equals To', N'>=')
	PRINT 'report Param Operator ID 17 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 17 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 18)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (18, N'Date Less Than Equals To', N'<=')
	PRINT 'report Param Operator ID 18 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 18 already EXISTS.'

IF NOT EXISTS (SELECT 1 FROM report_param_operator rpo WHERE rpo.report_param_operator_id = 19)
BEGIN
	INSERT INTO [dbo].[report_param_operator]([report_param_operator_id], [description], [sql_code])
	VALUES (19, N'Date Not Equals To', N'<>')
	PRINT 'report Param Operator ID 19 inserted.'	
END
ELSE PRINT 'Report Param Operator ID 19 already EXISTS.'
GO
/*****/
