IF OBJECT_ID(N'dbo.[spa_round_value]', N'P') IS NOT NULL
DROP PROC dbo.[spa_round_value]
Go
CREATE PROC dbo.[spa_round_value]
	@flag CHAR(1) = NULL,
	@id INT = NULL,
	@value INT = NULL
AS
IF @flag='s'
BEGIN
	DECLARE @sql VARCHAR(500)
	SET @sql = 	' SELECT id, value FROM round_value
				WHERE ' + CASE WHEN @id IS NULL THEN ' id < 10 ' ELSE ' id <= ' + CAST(@id AS VARCHAR(10)) END
	EXEC(@sql)
END

--EXEC spa_round_value 's', 6