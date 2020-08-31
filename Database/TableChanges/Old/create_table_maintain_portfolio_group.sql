SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_portfolio_group]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[maintain_portfolio_group]
	(
		[portfolio_group_id]			INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[portfolio_group_name]			VARCHAR(500) NOT NULL,
		[portfolio_group_description]	VARCHAR(1000) NULL,
		[user]							VARCHAR(500) NULL,
		[role]							VARCHAR(500) NULL, 
		[public]						CHAR(1) NOT NULL,
		[active]						CHAR(1) NOT NULL,
		
		[create_user]					VARCHAR(100) NOT NULL CONSTRAINT DF_maintain_portfolio_group_create_user DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL CONSTRAINT DF_maintain_portfolio_group_create_ts DEFAULT GETDATE(),
		[update_user]					VARCHAR(100) NULL,
		[update_ts]						DATETIME NULL
	)
END 
ELSE
BEGIN
	PRINT 'Table maintain_portfolio_group already EXIST'
END 
	
	
	