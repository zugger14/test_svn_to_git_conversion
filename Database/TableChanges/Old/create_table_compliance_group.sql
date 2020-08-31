-- OBJECT : TABLE [dbo].[compliance_group]  
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[compliance_group]')
              AND TYPE IN (N'U')
   )
BEGIN
    CREATE TABLE [dbo].[compliance_group]
    (
    	[compliance_group_id]     [int] IDENTITY(1, 1) NOT NULL,
    	[logical_name]            [INT] NULL,
    	[assignment_type]         [int] NULL,
    	[assigned_state]          [int] NULL,
    	[compliance_year]         [int] NULL,
    	[commit_type]             [char](1) NULL,
    	[create_user]             [varchar](100) NULL,
    	[create_ts]               [datetime] NULL,
    	[update_user]             [varchar](100) NULL,
    	[update_ts]               [datetime] NULL,
    	CONSTRAINT [PK__complian__2A546466514F3A60] PRIMARY KEY CLUSTERED([compliance_group_id] ASC)WITH (
    	                                                                                                     PAD_INDEX 
    	                                                                                                     = 
    	                                                                                                     OFF,
    	                                                                                                     STATISTICS_NORECOMPUTE 
    	                                                                                                     = 
    	                                                                                                     OFF,
    	                                                                                                     IGNORE_DUP_KEY 
    	                                                                                                     = 
    	                                                                                                     OFF,
    	                                                                                                     ALLOW_ROW_LOCKS 
    	                                                                                                     = 
    	                                                                                                     ON,
    	                                                                                                     ALLOW_PAGE_LOCKS 
    	                                                                                                     = 
    	                                                                                                     ON
    	                                                                                                 ) 
    	                                                                                                 ON 
    	                                                                                                 [PRIMARY]
    ) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (
       SELECT *
       FROM   dbo.sysobjects
       WHERE  id           = OBJECT_ID(N'[dbo].[DF__complianc__creat__527868C3]')
              AND TYPE     = 'D'
   )
BEGIN
    ALTER TABLE [dbo].[compliance_group] ADD CONSTRAINT 
    [DF__complianc__creat__527868C3] DEFAULT([dbo].[FNADBUser]()) FOR 
    [create_user]
END

GO
IF NOT EXISTS (
       SELECT *
       FROM   dbo.sysobjects
       WHERE  id           = OBJECT_ID(N'[dbo].[DF__complianc__creat__536C8CFC]')
              AND TYPE     = 'D'
   )
BEGIN
    ALTER TABLE [dbo].[compliance_group] ADD CONSTRAINT 
    [DF__complianc__creat__536C8CFC] DEFAULT(GETDATE()) FOR [create_ts]
END

GO

-- OBJECT : TRIGGER [dbo].[TRGUPD_compliance_group]   
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (
       SELECT *
       FROM   sys.triggers
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_compliance_group]')
   )
    EXEC dbo.sp_executesql @statement = 
         N'
CREATE TRIGGER [dbo].[TRGUPD_compliance_group]
ON [dbo].[compliance_group]
FOR UPDATE
AS
UPDATE compliance_group SET update_user =  dbo.FNADBUser(), update_ts = getdate() where  compliance_group.compliance_group_id in (select compliance_group_id from deleted)
' 
GO