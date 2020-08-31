SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_scenario]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_scenario]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_scenario]
ON [dbo].[maintain_scenario]
FOR UPDATE
AS
    UPDATE maintain_scenario
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_scenario t
      INNER JOIN DELETED u ON t.scenario_id = u.scenario_id
GO