
/****** Object:  Trigger [TRGUPD_SOURCE_DEAL_DETAIL]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].TRGdel_FAS_LINK_HEADER'))
DROP TRIGGER [dbo].TRGdel_FAS_LINK_HEADER
GO


CREATE TRIGGER [TRGdel_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR delete
AS
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.link_id 
delete [dbo].[dedesignated_link_deal] from [dbo].[dedesignated_link_deal] d_l inner join deleted d 
on d_l.link_id=d.original_link_id 

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
	'delete' [user_action]
FROM DELETED


DECLARE @link_id VARCHAR(8000)

SELECT  
	@link_id = COALESCE( @link_id + ',' + CAST(fld.link_id AS VARCHAR),CAST(fld.link_id AS VARCHAR)) 
FROM DELETED fld

exec spa_fas_link_header_detail_audit_map @link_id, 'h', 'delete'
