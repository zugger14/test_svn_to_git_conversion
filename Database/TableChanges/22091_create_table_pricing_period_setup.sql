SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[pricing_period_setup]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pricing_period_setup] (
		pricing_period_setup_id INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
		,pricing_period_value_id int
		,period_type varchar(1)
		,average_period smallint
		,skip_period smallint
		,delivery_period smallint
		,expiration_calendar bit
		,formula_id int
		,[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		,[create_ts] DATETIME NULL DEFAULT GETDATE()
		,[update_user] VARCHAR(50) NULL
		,[update_ts] DATETIME NULL
    )

	INSERT [dbo].[pricing_period_setup] ([pricing_period_value_id], [period_type], [average_period], [skip_period], [delivery_period], [expiration_calendar], [formula_id])
	 VALUES
		  ( 106601, N'm', 0, 0, 1, 1, NULL),
		 ( 106607, N'w', 1, 0, 1, 0, NULL),
		 ( 106606, N'm', 1, 0, 1, 0, NULL),
		 ( 106606, N'm', 1, 0, 1, 0, NULL),
		 ( 106605, N'f', 1, 0, 1, 0, NULL),
		 (106604, N'd', NULL, NULL, NULL, 0, NULL),
		 ( 106603, N'm', NULL, NULL, NULL, 1, NULL),
		 ( 106602, N'd', NULL, NULL, NULL, 0, NULL),
		 ( 106600, N'm', 0, 0, 1, 0, NULL)


END
ELSE
BEGIN
    PRINT 'Table pricing_period_setup EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pricing_period_setup]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pricing_period_setup]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pricing_period_setup]
ON [dbo].[pricing_period_setup]
FOR UPDATE
AS
    UPDATE pricing_period_setup
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pricing_period_setup t
      INNER JOIN DELETED u ON t.pricing_period_setup_id = u.pricing_period_setup_id
GO