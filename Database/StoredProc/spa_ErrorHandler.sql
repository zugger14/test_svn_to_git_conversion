IF OBJECT_ID('[dbo].[spa_ErrorHandler]') IS NOT NULL
	DROP PROC [dbo].[spa_ErrorHandler]
GO

/**
	A procedure for returning success or error messages and log error messages.

	Parameters:
		@error				:	Error Code, most of the times it would be @@ERROR.
		@msgType1			:	Module of error.
		@msgType2			:	Source of error.
		@msgType3			:	Error Type.
		@msg				:	Description of the error.
		@recommendation		:	Next steps to be taken to solve error.
		@logFlag			:	If this variable is passed then the errors will be logged in a table.
*/

CREATE PROCEDURE [dbo].[spa_ErrorHandler]
	@error			AS INTEGER,
	@msgType1		AS VARCHAR(100),
	@msgType2		AS VARCHAR(100),
	@msgType3		AS VARCHAR(100),
	@msg			AS NVARCHAR(500),
	@recommendation AS NVARCHAR(500),
	@logFlag		AS INTEGER = NULL
AS
SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature

/** Debug Section
DECLARE @error		INTEGER,
	@msgType1		VARCHAR(100),
	@msgType2		VARCHAR(100),
	@msgType3		VARCHAR(100),
	@msg			NVARCHAR(500),
	@recommendation	NVARCHAR(500),
	@logFlag		INTEGER = NULL

SELECT 1, 'Module', 'spa_source', 'Success', 'Saved Successfully', ''
--*/

DECLARE @supress_output BIT = CAST(ISNULL(SESSION_CONTEXT(N'SUPRESS_OUTPUT'), 0) AS BIT)
--SELECT @supress_output [@supress_output]

IF @supress_output = 1 RETURN;

-- SELECT @ERROR
IF @error = 0
BEGIN
	SELECT 'Success' ErrorCode,
		@msgType1 Module,
		@msgType2 Area, 
		@MsgType3 [Status],
		@msg [Message],
		@recommendation Recommendation
END

-- Later this will be enhanced for better error messages.
IF @error <> 0
BEGIN 
	DECLARE @errorMsg	NVARCHAR(500)
	DECLARE @msgLangID	INT
		
	SELECT @msgLangID = msglangid
	FROM sys.syslanguages
	WHERE [langid] = @@LANGID
	
	IF @msgLangID IS NULL
		SELECT @msgLangID = msglangid
		FROM sys.syslanguages
		WHERE [name] = 'us_english' -- English by default

	SELECT @errorMsg = ([description])
	FROM sys.sysmessages
	WHERE error = @error
		AND msglangid = @msgLangID
		
	SELECT 'Error' ErrorCode,
		@msgType1 Module,
		@msgType2 Area, 
		@MsgType3 [Status],
		(@msg + CASE WHEN @errorMsg IS NOT NULL THEN ' (' + @errorMsg + ')' ELSE '' END) [Message],
		@recommendation Recommendation
END

GO