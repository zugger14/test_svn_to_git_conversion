IF OBJECT_ID('spa_print') IS NOT NULL
	DROP PROCEDURE dbo.spa_print
GO

CREATE PROCEDURE dbo.spa_print
	@msg1 VARCHAR(MAX),
	@msg2 VARCHAR(MAX) = '',
	@msg3 VARCHAR(MAX) = '',
	@msg4 VARCHAR(MAX) = '',
	@msg5 VARCHAR(MAX) = '',
	@msg6 VARCHAR(MAX) = '',
	@msg7 VARCHAR(MAX) = '',
	@msg8 VARCHAR(MAX) = '',
	@msg9 VARCHAR(MAX) = '',
	@msg10 VARCHAR(MAX) = '',
	@msg11 VARCHAR(MAX) = '',
	@msg12 VARCHAR(MAX) = '',
	@msg13 VARCHAR(MAX) = '',
	@msg14 VARCHAR(MAX) = '',
	@msg15 VARCHAR(MAX) = ''
AS

DECLARE @msg VARCHAR(MAX)
DECLARE @batch_size INT
	--, @i INT
	, @st VARCHAR(2000)
	, @debug_mode VARCHAR(128)

SET @msg =	ISNULL(@msg1, CHAR(13) + '*****@msg1 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg2, CHAR(13) + '*****@msg2 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg3, CHAR(13) + '*****@msg3 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg4, CHAR(13) + '*****@msg4 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg5, CHAR(13) + '*****@msg5 IS NULL*****' + CHAR(13) )	 
			+ ISNULL(@msg6, CHAR(13) + '*****@msg6 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg7, CHAR(13) + '*****@msg7 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg8, CHAR(13) + '*****@msg8 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg9, CHAR(13) + '*****@msg9 IS NULL*****' + CHAR(13) )
			+ ISNULL(@msg10, CHAR(13) + '*****@msg10 IS NULL*****' + CHAR(13))
			+ ISNULL(@msg11, CHAR(13) + '*****@msg11 IS NULL*****' + CHAR(13))
			+ ISNULL(@msg12, CHAR(13) + '*****@msg12 IS NULL*****' + CHAR(13))
			+ ISNULL(@msg13, CHAR(13) + '*****@msg13 IS NULL*****' + CHAR(13))
			+ ISNULL(@msg14, CHAR(13) + '*****@msg14 IS NULL*****' + CHAR(13))
			+ ISNULL(@msg15, CHAR(13) + '*****@msg15 IS NULL*****' + CHAR(13))

-- Get Debug mode from CONTEXT_INFO or SESSION_CONTEXT wherever is present
SET @debug_mode = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF (ISNULL(@debug_mode, '') = 'DEBUG_MODE_ON')
	SET @debug_mode = 'ON'
ELSE
	SET @debug_mode = CONVERT(VARCHAR(128), SESSION_CONTEXT(N'DEBUG_MODE'))

SET @batch_size = 2000
--SET @i = 1

IF ISNULL(@debug_mode, '') = 'ON' -- OR (@@OPTIONS & 512) = 0 
BEGIN
	DECLARE @i INT,
		@newline NCHAR(2),
		@print VARCHAR(MAX),
		@int_msg VARCHAR(MAX);

	SET @newline = NCHAR(13) + NCHAR(10);
	SELECT @i = CHARINDEX(@newline, @msg);

	WHILE (@i > 0)
	BEGIN
		SELECT @print = SUBSTRING(@msg, 0, @i);
		WHILE (LEN(@print) > 8000)
		BEGIN
			SET @int_msg = SUBSTRING(@print,0,8000)
			RAISERROR(@int_msg,0,1) WITH NOWAIT
			--PRINT SUBSTRING(@print, 0, 8000);
			SELECT @print = SUBSTRING(@print, 8000, LEN(@print));
		END
		RAISERROR(@print, 0, 1) WITH NOWAIT
		--PRINT @print;
		SELECT @msg = SUBSTRING(@msg, @i + 2, LEN(@msg));
		SELECT @i = CHARINDEX(@newline, @msg);
	END
	RAISERROR(@msg, 0, 1) WITH NOWAIT
	--PRINT @msg;

	--WHILE 1 = 1
	--BEGIN
	--	SET @st = SUBSTRING(@msg, @i, @batch_size)
	--	PRINT @st
	--	IF LEN(@st) < @batch_size
	--		BREAK

	--	SET @i = @i + @batch_size
	--END
END