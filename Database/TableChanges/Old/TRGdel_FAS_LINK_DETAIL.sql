
/****** Object:  Trigger [TRGdel_FAS_LINK_DETAIL]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGdel_FAS_LINK_DETAIL]'))
DROP TRIGGER [dbo].[TRGdel_FAS_LINK_DETAIL]
GO


CREATE TRIGGER [TRGdel_FAS_LINK_DETAIL]
ON [dbo].[fas_link_detail]
FOR DELETE
AS
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
	'delete' [user_action],
	@audit_id,
	'N'	
FROM DELETED
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
WHERE link_id IN (SELECT link_id FROM DELETED)
	  AND [fas_link_detail_id] NOT IN (SELECT [fas_link_detail_id] FROM DELETED)


DECLARE @link_id VARCHAR(8000)

SELECT  
	@link_id = COALESCE( @link_id + ',' + CAST(fld.link_id AS VARCHAR),CAST(fld.link_id AS VARCHAR))
FROM DELETED fld

exec spa_fas_link_header_detail_audit_map @link_id, 'd', 'delete'

