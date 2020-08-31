
/****** Object:  Trigger [TRGUPD_FAS_LINK_HEADER]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_FAS_LINK_HEADER]'))
DROP TRIGGER [dbo].[TRGUPD_FAS_LINK_HEADER]
GO


CREATE TRIGGER [TRGUPD_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR UPDATE
AS
UPDATE FAS_LINK_HEADER SET update_user = dbo.FNADBUser(), update_ts = getdate() where  FAS_LINK_HEADER.link_id in (select link_id from deleted)

IF UPDATE(update_user) OR UPDATE(update_ts) OR UPDATE(create_user) OR UPDATE(create_ts)
	RETURN

INSERT INTO [dbo].[fas_link_header_audit]
	(link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	create_user,
	create_ts,
	update_user,
	update_ts,
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	user_action)
SELECT 
	link_id,
	fas_book_id,
	perfect_hedge,
	fully_dedesignated,
	link_description,
	eff_test_profile_id,
	link_effective_date,
	link_type_value_id,
	link_active,
	dbo.FNADBUser(),
	GETDATE(),
	dbo.FNADBUser(),
	GETDATE(),
	original_link_id,
	link_end_date,
	dedesignated_percentage,
	'update' [user_action]
FROM INSERTED


DECLARE @link_id VARCHAR(8000)
SELECT  
	@link_id = COALESCE( @link_id + ',' + CAST(link_id AS VARCHAR),CAST(link_id AS VARCHAR)) 
FROM INSERTED 

exec spa_fas_link_header_detail_audit_map @link_id, 'h', 'update'
