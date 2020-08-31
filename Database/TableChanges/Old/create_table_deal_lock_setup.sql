IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_lock_setup_role_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_lock_setup]'))
ALTER TABLE [dbo].[deal_lock_setup] DROP CONSTRAINT [FK_deal_lock_setup_role_id]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_lock_setup_deal_type_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_lock_setup]'))
ALTER TABLE [dbo].[deal_lock_setup] DROP CONSTRAINT [FK_deal_lock_setup_deal_type_id]
GO
/****** Object:  Table [dbo].[broker_fees]    Script Date: 12/08/2009 17:27:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_lock_setup]') AND type in (N'U'))
DROP TABLE [dbo].[deal_lock_setup]
GO
CREATE TABLE deal_lock_setup(
	id INT PRIMARY KEY IDENTITY(1,1),
	role_id INT,
	deal_type_id INT,
	hour INT,
	minute INT,
	create_ts DATETIME,
	create_user VARCHAR(100)
)
GO	
ALTER TABLE [dbo].[deal_lock_setup]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_lock_setup_role_id] FOREIGN KEY(role_id)
REFERENCES [dbo].[application_security_role] ([role_id])
GO
ALTER TABLE [dbo].[deal_lock_setup] CHECK CONSTRAINT [FK_deal_lock_setup_role_id]
GO
ALTER TABLE [dbo].[deal_lock_setup]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_lock_setup_deal_type_id] FOREIGN KEY(deal_type_id)
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO
ALTER TABLE [dbo].[deal_lock_setup] CHECK CONSTRAINT [FK_deal_lock_setup_deal_type_id]
GO