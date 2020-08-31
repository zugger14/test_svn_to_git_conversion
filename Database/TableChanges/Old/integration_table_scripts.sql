IF OBJECT_ID ('dbo.process_filters') is not null
DROP TABLE dbo.process_filters
GO
CREATE TABLE dbo.process_filters
(
	filterID		INT	IDENTITY(1,1)UNIQUE,
	filterDesc		VARCHAR(8000)					,
	tableName		VARCHAR	(8000)		,
	columnName		VARCHAR	(8000)		
)
GO
IF OBJECT_ID ('dbo.process_functions') is not null
DROP TABLE dbo.process_functions
GO
CREATE TABLE dbo.process_functions
(
	functionID	INT	UNIQUE,
	functionDesc VARCHAR(8000)
)
GO
IF OBJECT_ID ('dbo.process_functions_detail') is not null
DROP TABLE dbo.process_functions_detail
GO
CREATE TABLE dbo.process_functions_detail
(
	sno		INT	IDENTITY(1,1),
	functionID	INT CONSTRAINT FK_process_filters_filterID FOREIGN KEY REFERENCES process_functions(functionID),
	filterID	INT CONSTRAINT FK_process_functions_functionID FOREIGN KEY REFERENCES process_filters(filterID)
)

