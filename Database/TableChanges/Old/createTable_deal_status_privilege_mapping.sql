SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_status_privilege_mapping]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[deal_status_privilege_mapping]
	(
		[deal_status_privilege_mapping_id]  [INT] IDENTITY(1, 1) NOT NULL,
		[from_status_value_id]              [INT] NULL,
		[to_status_value_id]                [INT] NULL,
		[create_user]                       [VARCHAR](50) NULL DEFAULT([dbo].[FNADBUser]()),
		[create_ts]                         [DATETIME] NULL DEFAULT(GETDATE()),
		[update_user]                       [VARCHAR](50) NULL,
		[update_ts]                         [DATETIME] NULL
		CONSTRAINT [PK_deal_status_privilege_mapping] PRIMARY KEY CLUSTERED([deal_status_privilege_mapping_id] ASC)
		WITH (
		    PAD_INDEX = OFF,
		    STATISTICS_NORECOMPUTE = OFF,
		    IGNORE_DUP_KEY = OFF,
		    ALLOW_ROW_LOCKS = ON,
		    ALLOW_PAGE_LOCKS = ON,
		    FILLFACTOR = 90
		) ON [PRIMARY],
		CONSTRAINT [IX_deal_status_privilege_mapping] UNIQUE NONCLUSTERED([to_status_value_id] ASC, [from_status_value_id] ASC)
		WITH (
		    PAD_INDEX = OFF,
		    STATISTICS_NORECOMPUTE = OFF,
		    IGNORE_DUP_KEY = OFF,
		    ALLOW_ROW_LOCKS = ON,
		    ALLOW_PAGE_LOCKS = ON,
		    FILLFACTOR = 90
		) ON [PRIMARY]
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table deal_status_privilege_mapping EXISTS'
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
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_status_privilege_mapping]')
)

	DROP TRIGGER [dbo].[TRGUPD_deal_status_privilege_mapping]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_status_privilege_mapping]
ON [dbo].deal_status_privilege_mapping
FOR  UPDATE
AS
	UPDATE deal_status_privilege_mapping
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   deal_status_privilege_mapping s
	INNER JOIN DELETED d ON  s.deal_status_privilege_mapping_id = d.deal_status_privilege_mapping_id	

GO