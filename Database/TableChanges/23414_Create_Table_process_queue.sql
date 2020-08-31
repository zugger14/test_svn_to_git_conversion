SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[process_queue]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[process_queue]
    (
    	[process_queue_id]		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[process_queue_type]	INT NOT NULL,
    	[source_id]				INT NOT NULL,
		[queue_sql]				VARCHAR(MAX) NOT NULL,
		[process_id]			VARCHAR(100) NULL,
		[description]			VARCHAR(MAX) NULL,
		[is_processed]			CHAR(1) NULL,
		[has_error]				CHAR(1) NULL,
		[error_description]		VARCHAR(MAX) NULL, 
    	[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]				DATETIME NULL DEFAULT GETDATE(),
    	[update_user]			VARCHAR(50) NULL,
    	[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table process_queue EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_process_queue]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_process_queue]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_process_queue]
ON [dbo].[process_queue]
FOR UPDATE
AS
    UPDATE process_queue
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM process_queue t
      INNER JOIN DELETED u ON t.[process_queue_id] = u.[process_queue_id]
GO