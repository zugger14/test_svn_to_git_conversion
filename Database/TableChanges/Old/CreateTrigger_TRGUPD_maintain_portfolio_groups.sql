SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_maintain_portfolio_groups]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_portfolio_groups]
GO

CREATE TRIGGER [dbo].[TRGUPD_maintain_portfolio_groups]
ON [dbo].[maintain_portfolio_groups]
FOR  UPDATE
AS
	UPDATE maintain_portfolio_groups
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   maintain_portfolio_groups mpg
	       INNER JOIN DELETED u
	       ON  mpg.id = u.id
GO
	



