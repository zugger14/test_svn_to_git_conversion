
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_email_log]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_invoice_email_log]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_invoice_email_log]
@process_id varchar(50),
@user_login_id VARCHAR(100)=NULL,
@flag char(1),
@email_subject varchar(200) = NULL
AS

if @flag = 'd'
BEGIN
	SELECT email_subject as [Email Subject], mail_to [To],cc_mail [CC], bcc_mail [BCC],  process_id AS [Process ID] from invoice_email_log a
WHERE  a.process_id = @process_id AND email_subject= @email_subject
	
END