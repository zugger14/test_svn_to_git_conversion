SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ticket_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].ticket_header (
		ticket_header_id INT IDENTITY(1, 1) NOT NULL,
		ticket_number VARCHAR(1000),		
		ticket_issuer INT,
		issued_date	DATETIME,		
		ticket_type INT,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ticket_header EXISTS'
END
 
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'ticket_header' 
                    AND ccu.COLUMN_NAME = 'ticket_header_id'
)
ALTER TABLE [dbo].ticket_header WITH NOCHECK ADD CONSTRAINT pk_ticket_header_id PRIMARY KEY(ticket_header_id)
GO

IF OBJECT_ID('[dbo].[TRGUPD_ticket_header]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ticket_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_ticket_header]
ON [dbo].[ticket_header]
FOR UPDATE
AS
    UPDATE ticket_header
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ticket_header t
      INNER JOIN DELETED u 
		ON t.ticket_header_id = u.ticket_header_id
GO