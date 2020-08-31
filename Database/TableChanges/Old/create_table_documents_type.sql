SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[documents_type]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].documents_type(
		document_id						INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		document_name					VARCHAR(200) NOT NULL,
		document_description			VARCHAR(1000) NULL,
		document_type_id				INT REFERENCES static_data_value(value_id) NOT NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].documents_type EXISTS'
END


GO

IF OBJECT_ID('[dbo].[TRGUPD_documents_type]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_documents_type]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_documents_type]
ON [dbo].[documents_type]
FOR UPDATE
AS
    UPDATE documents_type
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM documents_type t
      INNER JOIN DELETED u ON t.document_id = u.document_id
GO