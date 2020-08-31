
/****** Object:  Trigger [TRGUPD_FAS_LINK_HEADER]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_FAS_LINK_DETAIL]'))
DROP TRIGGER [dbo].[TRGUPD_FAS_LINK_DETAIL]
GO

CREATE TRIGGER [TRGUPD_FAS_LINK_DETAIL]
ON [dbo].[fas_link_detail]
FOR UPDATE
AS
UPDATE FAS_LINK_DETAIL SET update_user = dbo.FNADBUser(), update_ts = getdate() where  FAS_LINK_DETAIL.link_id in (select link_id from deleted) AND FAS_LINK_DETAIL.source_deal_header_id in (select source_deal_header_id from deleted)
IF UPDATE(update_user) OR UPDATE(update_ts) OR UPDATE(create_user) OR UPDATE(create_ts)
	RETURN
	
DECLARE @audit_id INT
SET @audit_id = ISNULL((SELECT MAX(audit_id)  FROM fas_link_detail_audit flda), 0) + 1
	
	
INSERT INTO [dbo].[fas_link_detail_audit]
	(
	[fas_link_detail_id],
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	[create_user],
	[create_ts],
	[update_user],
	[update_ts],
	[effective_date],
	[user_action],
	audit_id,
	auto_update 
	)
SELECT
	[fas_link_detail_id],
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	dbo.fnadbuser(),
	GETDATE(),
	dbo.fnadbuser(),
	GETDATE(),
	[effective_date],
	'update' [user_action],
	@audit_id,
	'N'	
FROM INSERTED
UNION ALL
SELECT
	[fas_link_detail_id], 
	[link_id],
	[source_deal_header_id],
	[percentage_included] ,
	[hedge_or_item],
	dbo.fnadbuser(),
	GETDATE(),
	dbo.fnadbuser(),
	GETDATE(),
	[effective_date],
	'update' [user_action],
	@audit_id,
	'Y'
FROM fas_link_detail
WHERE link_id IN (SELECT link_id FROM INSERTED)
	  AND [fas_link_detail_id] NOT IN (SELECT [fas_link_detail_id] FROM INSERTED)
	

DECLARE @link_id VARCHAR(8000)
SELECT  
	@link_id = COALESCE( @link_id + ',' + CAST(link_id AS VARCHAR),CAST(link_id AS VARCHAR)) 
FROM INSERTED 

exec spa_fas_link_header_detail_audit_map @link_id, 'd', 'update'
