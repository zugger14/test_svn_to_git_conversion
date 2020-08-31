SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[state_rec_requirement_detail_constraint]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[state_rec_requirement_detail_constraint]
    (
    	[state_rec_requirement_detail_constraint_id] [int] IDENTITY(1, 1) NOT 
    	NULL,
    	[state_rec_requirement_detail_id] INT NOT NULL FOREIGN KEY([state_rec_requirement_detail_id]) 
    	REFERENCES [state_rec_requirement_detail] ([state_rec_requirement_detail_id]),
    	[state_rec_requirement_applied_constraint_detail_id] INT NOT NULL 
    	FOREIGN KEY([state_rec_requirement_applied_constraint_detail_id]) 
    	REFERENCES [state_rec_requirement_detail] ([state_rec_requirement_detail_id]),
    	[create_user]     [varchar](150) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]       [datetime] NULL DEFAULT GETDATE(),
    	CONSTRAINT PK_state_rec_requirement_detail_constraint PRIMARY KEY 
    	CLUSTERED(state_rec_requirement_detail_constraint_id)
    )
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END

