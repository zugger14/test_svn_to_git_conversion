ALTER TABLE source_traders ADD user_login_id VARCHAR(50)
GO
ALTER TABLE [dbo].[source_traders]  WITH CHECK ADD  CONSTRAINT [FK_source_traders_application_users] FOREIGN KEY([user_login_id])
REFERENCES [dbo].[application_users] ([user_login_id])
GO