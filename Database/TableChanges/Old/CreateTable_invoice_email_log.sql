SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[invoice_email_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].invoice_email_log (
	log_id INT IDENTITY(1, 1) NOT NULL,
	process_id      VARCHAR(200),
	mail_to         VARCHAR(8000) NULL,
	cc_mail         VARCHAR(8000) NULL,
	bcc_mail        VARCHAR(8000) NULL,
	email_subject   VARCHAR(8000) NULL,
	email_description  VARCHAR(MAX) NULL,
	invoice_number  INT NULL
)
END
ELSE
BEGIN
    PRINT 'Table invoice_email_log EXISTS'
END

