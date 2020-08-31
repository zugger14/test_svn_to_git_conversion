IF OBJECT_ID('[dbo].[spa_AppendToFile]') IS NOT NULL
	DROP PROC [dbo].[spa_AppendToFile]
GO

CREATE PROCEDURE [dbo].[spa_AppendToFile]
(
	@FileName	VARCHAR(255), 
	@Text1		VARCHAR(max),
	@Append		SMALLINT = 1 -- 0: create new, 1: append content
) AS
BEGIN
	DECLARE @FS int, @OLEResult INT, @FileID INT, @WriteMode SMALLINT
	
	SET @WriteMode = CASE ISNULL(@Append, 1) WHEN 1 THEN 8 ELSE 2 END
	
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'

	--Open a file
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, @WriteMode, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'

	--Write Text1
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @Text1
	IF @OLEResult <> 0 PRINT 'WriteLine'

	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
END



