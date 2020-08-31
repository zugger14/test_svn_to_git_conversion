SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_portfolio_group]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_portfolio_group]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_portfolio_group]
ON [dbo].[maintain_portfolio_group]
FOR UPDATE
AS
    UPDATE maintain_portfolio_group
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_portfolio_group t
      INNER JOIN DELETED u ON t.portfolio_group_id = u.portfolio_group_id
GO