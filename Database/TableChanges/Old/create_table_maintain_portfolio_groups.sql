SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_portfolio_groups]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[maintain_portfolio_groups]
	(
		[id]				INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[name]				VARCHAR(500) NOT NULL,
		[description]		VARCHAR(1000) NULL,
		[user]				VARCHAR(500) NULL,
		[role]				VARCHAR(500) NULL, 
		[public]			VARCHAR(5) NOT NULL,
		[active]			VARCHAR(5) NOT NULL,
		[create_user]		VARCHAR(100) NOT NULL CONSTRAINT DF_maintain_portfolio_groups_create_user DEFAULT dbo.FNADBUser(),
		[create_ts]			DATETIME NULL CONSTRAINT DF_maintain_portfolio_groups_create_ts DEFAULT GETDATE(),
		[update_user]		VARCHAR(100) NULL,
		[update_ts]			DATETIME NULL
	)
END 
ELSE
BEGIN
	PRINT 'Table maintain_portfolio_groups already EXIST'
END 
	