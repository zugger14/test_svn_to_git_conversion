IF OBJECT_ID('user_defined_deal_fields_template', N'U') IS NOT NULL
BEGIN
	EXEC sp_rename 'user_defined_deal_fields_template', 'user_defined_deal_fields_template_main';
END
GO

IF OBJECT_ID('FK_user_defined_deal_fields_udf_template_id') IS NOT NULL
BEGIN
	ALTER TABLE user_defined_deal_fields DROP CONSTRAINT FK_user_defined_deal_fields_udf_template_id;
END
GO

IF OBJECT_ID('FK_user_defined_deal_detail_fields_udf_template_id') IS NOT NULL
BEGIN
	ALTER TABLE user_defined_deal_detail_fields DROP CONSTRAINT FK_user_defined_deal_detail_fields_udf_template_id;
END
GO

IF OBJECT_ID('[dbo].[TRGINS_user_defined_deal_fields_template]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_user_defined_deal_fields_template]
GO
 
CREATE TRIGGER [dbo].[TRGINS_user_defined_deal_fields_template]
ON [dbo].[user_defined_deal_fields_template_main]
FOR INSERT
AS
    UPDATE user_defined_deal_fields_template_main SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
	FROM user_defined_deal_fields_template_main s INNER JOIN inserted i ON s.udf_template_id= i.udf_template_id
GO	

IF OBJECT_ID('[dbo].[TRGUPD_user_defined_deal_fields_template]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_user_defined_deal_fields_template]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_user_defined_deal_fields_template]
ON [dbo].[user_defined_deal_fields_template_main]
FOR UPDATE
AS
    UPDATE user_defined_deal_fields_template_main SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
	FROM  user_defined_deal_fields_template_main s INNER JOIN deleted d ON s.udf_template_id = d.udf_template_id
GO	