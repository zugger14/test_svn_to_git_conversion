/****** Object:  Trigger [TRGUPD_SOURCE_DEAL_DETAIL]    Script Date: 02/10/2012 09:42:45 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_STATUS_RULE_HEADER]'))
DROP TRIGGER [dbo].[TRGUPD_STATUS_RULE_HEADER]
GO

CREATE TRIGGER [dbo].[TRGUPD_STATUS_RULE_HEADER]
ON [dbo].[status_rule_header]
FOR UPDATE
AS
UPDATE status_rule_header SET update_user =  dbo.FNADBUser(), update_ts = getdate() from [status_rule_header] s inner join deleted i on 
s.status_rule_id = i.status_rule_id
