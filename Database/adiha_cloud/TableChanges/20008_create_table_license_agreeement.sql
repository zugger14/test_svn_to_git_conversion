USE adiha_cloud

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[license_agreement]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[license_agreement] (
		[license_agreement_id]	 INT IDENTITY(1,1) NOT NULL,
    	[application_users_id]	 INT NOT NULL,
		[agreement_status]		 CHAR(1) NOT NULL,
		[license_date]				 DATETIME NOT NULL,	
		FOREIGN KEY ([application_users_id]) REFERENCES [dbo].[application_users]([application_users_id])
    )
END
ELSE
BEGIN
    PRINT 'Table license_agreement EXISTS'
END
 
GO

