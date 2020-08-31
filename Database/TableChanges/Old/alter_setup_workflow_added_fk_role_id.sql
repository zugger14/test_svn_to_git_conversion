IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_setup_workflow_application_security_role]') AND parent_object_id = OBJECT_ID(N'[dbo].[setup_workflow]'))
BEGIN

ALTER TABLE [dbo].[setup_workflow]  WITH CHECK ADD  CONSTRAINT [FK_setup_workflow_application_security_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[application_security_role] ([role_id])
ON DELETE CASCADE


ALTER TABLE [dbo].[setup_workflow] CHECK CONSTRAINT [FK_setup_workflow_application_security_role]

END



