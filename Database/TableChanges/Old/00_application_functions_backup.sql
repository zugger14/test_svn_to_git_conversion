IF OBJECT_ID(N'application_functions_old') IS NOT NULL
BEGIN
 DROP TABLE dbo.application_functions_old
END

SELECT * INTO dbo.application_functions_old FROM dbo.application_functions