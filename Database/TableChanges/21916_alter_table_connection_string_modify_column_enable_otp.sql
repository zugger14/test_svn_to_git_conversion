-- Remove default value constraint first and then modify column type

DECLARE @constraint VARCHAR(50)

SELECT @constraint = SYSOBJECTS.[Name]
FROM SYSOBJECTS INNER JOIN (Select [Name],[ID] From SYSOBJECTS Where XType = 'U') As Tab
ON Tab.[ID] = SYSOBJECTS.[Parent_Obj] 
INNER JOIN SYSCONSTRAINTS On SYSCONSTRAINTS.Constid = SYSOBJECTS.[ID] 
INNER JOIN SYSCOLUMNS Col On Col.[ColID] = SYSCONSTRAINTS.[ColID] And Col.[ID] = Tab.[ID]
WHERE Col.[Name] = 'enable_otp'
AND Tab.[Name] = 'connection_string'

IF @constraint IS NOT NULL
BEGIN
	EXEC ('ALTER TABLE connection_string DROP CONSTRAINT ' + @constraint )
END

IF COL_LENGTH('connection_string','enable_otp') IS NOT NULL
BEGIN
	ALTER TABLE connection_string
	ALTER COLUMN enable_otp INT
END