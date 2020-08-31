-- ===============================================================================================================
-- Create date: 2012 - 03-19
--  Description:	Script to create archive_data_policy and archive_data_policy_detail Table
-- ===============================================================================================================

SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID('dbo.[archive_data_policy]',N'U') IS  NULL 

	BEGIN
	CREATE TABLE [dbo].[archive_data_policy](
		[archive_data_policy_id]	INT 					IDENTITY(1,1) NOT NULL,
		[archive_type_value_id]		INT  NOT NULL,
		[main_table_name]			VARCHAR(250) NOT NULL,
		[staging_table_name]		VARCHAR(250) NULL,
		[sequence]					TINYINT  NULL,
		[where_field]				VARCHAR(250) NOT NULL,
		[archive_frequency]			VARCHAR(1) NOT NULL,
		[existence_check_fields]	VARCHAR(5000) NULL,
		[create_user]				VARCHAR(100)			DEFAULT dbo.FNADBUser() NULL,
		[create_ts]					DATETIME 				DEFAULT GETDATE() NULL,
		[update_user]				VARCHAR(100) NULL,
		[update_ts]					DATETIME  NULL,
	 CONSTRAINT [PK_archive_data_policy] PRIMARY KEY CLUSTERED 
	(
		[archive_data_policy_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]	

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_archive_data_policy_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[archive_data_policy]'))
	ALTER TABLE [dbo].[archive_data_policy]  WITH CHECK ADD  CONSTRAINT [FK_archive_data_policy_static_data_value] FOREIGN KEY([archive_type_value_id])
	REFERENCES [dbo].[static_data_value] ([value_id])


	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_archive_data_policy_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[archive_data_policy]'))
	ALTER TABLE [dbo].[archive_data_policy] CHECK CONSTRAINT [FK_archive_data_policy_static_data_value]


	END
ELSE
	BEGIN
		PRINT 'Table archive_data_policy  EXISTS'
	END

GO
-- trigger
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
       SELECT *
       FROM   sys.triggers
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_archive_data_policy]')
)

	DROP TRIGGER [dbo].[TRGUPD_archive_data_policy]
GO

CREATE TRIGGER [dbo].[TRGUPD_archive_data_policy]
ON [dbo].archive_data_policy
FOR  UPDATE
AS
	UPDATE archive_data_policy
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   archive_data_policy s
	INNER JOIN DELETED d ON  s.archive_data_policy_id = d.archive_data_policy_id	


GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[archive_data_policy_detail]    Script Date: 03/06/2012 14:37:54 ******/
 
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID('dbo.[archive_data_policy_detail]',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[archive_data_policy_detail](
		[archive_data_policy_detail_id]		INT 				IDENTITY(1,1) NOT NULL,
		[archive_data_policy_id]			INT  NOT NULL,
		[table_name]						VARCHAR(150) NOT NULL,
		[is_arch_table]						BIT  NULL,
		[sequence]							TINYINT  NULL,
		[archive_db]						VARCHAR(250) NULL,
		[field_list]						VARCHAR(8000) NULL,
		[retention_period]					INT  NULL,
		[create_user]						VARCHAR(100)		DEFAULT dbo.FNADBUser() NULL,
		[create_ts]							DATETIME  NULL,
		[update_user]						VARCHAR(100)		DEFAULT GETDATE() NULL,
		[update_ts]							DATETIME  NULL,
	 CONSTRAINT [PK_archive_data_policy_detail] PRIMARY KEY CLUSTERED 
	(
		[archive_data_policy_detail_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
		
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_archive_data_policy_detail_archive_data_policy]') AND parent_object_id = OBJECT_ID(N'[dbo].[archive_data_policy_detail]'))
	ALTER TABLE [dbo].[archive_data_policy_detail]  WITH CHECK ADD  CONSTRAINT [FK_archive_data_policy_detail_archive_data_policy] FOREIGN KEY([archive_data_policy_id])
	REFERENCES [dbo].[archive_data_policy] ([archive_data_policy_id])

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_archive_data_policy_detail_archive_data_policy]') AND parent_object_id = OBJECT_ID(N'[dbo].[archive_data_policy_detail]'))
	ALTER TABLE [dbo].[archive_data_policy_detail] CHECK CONSTRAINT [FK_archive_data_policy_detail_archive_data_policy]


	END
ELSE
	BEGIN
		PRINT 'Table archive_data_policy_detail  EXISTS'
	END
GO
-- trigger
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
       SELECT *
       FROM   sys.triggers
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_archive_data_policy_detail]')
)

	DROP TRIGGER [dbo].[TRGUPD_archive_data_policy_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_archive_data_policy_detail]
ON [dbo].archive_data_policy_detail
FOR  UPDATE
AS
	UPDATE archive_data_policy_detail
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   archive_data_policy_detail s
	INNER JOIN DELETED d ON  s.archive_data_policy_detail_id = d.archive_data_policy_detail_id	


GO

SET ANSI_PADDING OFF
GO

