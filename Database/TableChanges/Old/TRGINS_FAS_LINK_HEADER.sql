
/****** Object:  Trigger [TRGINS_FAS_LINK_HEADER]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_FAS_LINK_HEADER]'))
DROP TRIGGER [dbo].[TRGINS_FAS_LINK_HEADER]
GO



CREATE TRIGGER [TRGINS_FAS_LINK_HEADER]
ON [dbo].[fas_link_header]
FOR INSERT
AS
UPDATE FAS_LINK_HEADER SET create_user = dbo.FNADBUser(), create_ts = getdate() where  FAS_LINK_HEADER.link_id in (select link_id from inserted)


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
	'Insert' [user_action]
FROM INSERTED


DECLARE @link_id VARCHAR(8000)
SELECT  
	@link_id = COALESCE( @link_id + ',' + CAST(link_id AS VARCHAR),CAST(link_id AS VARCHAR)) 
FROM INSERTED 

exec spa_fas_link_header_detail_audit_map @link_id, 'h', 'insert'

DECLARE @alert_process_table VARCHAR(300),@process_id VARCHAR(50)
SET @process_id = dbo.FNAGetNewID()
SET @alert_process_table = 'adiha_process.dbo.alert_designation_' + @process_id + '_add'

EXEC ('
IF OBJECT_ID('''  + @alert_process_table + ''') IS NOT NULL
DROP TABLE '  + @alert_process_table + '

CREATE TABLE ' + @alert_process_table + ' (
	link_id VARCHAR(8000)
)

INSERT INTO ' + @alert_process_table + ' SELECT ''' + @link_id + '''
'
)

EXEC spa_register_event 20631, 20591, @alert_process_table, 1, @process_id 