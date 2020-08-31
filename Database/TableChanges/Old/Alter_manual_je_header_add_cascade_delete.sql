ALTER TABLE dbo.manual_je_detail
        DROP CONSTRAINT FK_manual_je_detail_manual_je_header
GO
ALTER TABLE dbo.manual_je_detail ADD CONSTRAINT
        FK_manual_je_detail_manual_je_header FOREIGN KEY
        (
        manual_je_id
        ) REFERENCES [dbo].[manual_je_header] ([manual_je_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE 
        

