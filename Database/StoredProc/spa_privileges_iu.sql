

IF OBJECT_ID('dbo.spa_privileges_iu','p') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spa_privileges_iu
END
GO
CREATE PROC dbo.spa_privileges_iu
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL

AS

DECLARE @idoc INT
DECLARE @st_sql VARCHAR(5000)

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

CREATE TABLE #tmp_deal_privileges (
	template_id INT,
	[user_ids] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[role_ids] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[user_ids_label] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[role_ids_label] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
)

IF @flag = 'u'
DECLARE @template_ids VARCHAR(MAX)
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO #tmp_deal_privileges (
				template_id,
				[user_ids],
				[role_ids],
				[user_ids_label],
				[role_ids_label]
			)
			SELECT 
				template_id,
				[user_ids] ,
				[role_ids],
				[user_ids_label],
				[role_ids_label]

			FROM   OPENXML (@idoc, '/Root/PSRecordset', 1)
				 WITH ( 
						template_id INT	'@editGrid1',
						user_ids  VARCHAR(MAX) '@editGrid3',
						role_ids VARCHAR(MAX) '@editGrid4',
						user_ids_label  VARCHAR(MAX) '@editGrid5',
						role_ids_label VARCHAR(MAX) '@editGrid6'
					)
			--SELECT * FROM  #tmp_deal_privileges
			SELECT @template_ids =  STUFF((
						SELECT ',' + CAST(tdp.template_id AS VARCHAR(10)) 
						FROM #tmp_deal_privileges tdp FOR XML PATH('')
					), 1, 1, '')
					 
			
			DELETE dtp
			--SELECT * 
			FROM deal_template_privilages dtp 
			INNER JOIN dbo.FNASplit(@template_ids, ',') template_ids ON template_ids.item = dtp.deal_template_id
			
			--insert user privileges
			INSERT INTO deal_template_privilages (deal_template_id,[user_id])
			SELECT template_id, user_ids.item
			FROM #tmp_deal_privileges 
			CROSS APPLY dbo.FNASplit(user_ids_label, ',') user_ids
			
			--insert role privileges
			INSERT INTO deal_template_privilages (deal_template_id,[role_id])
			SELECT template_id, aru.role_id
			FROM #tmp_deal_privileges 
			CROSS APPLY dbo.FNASplit(role_ids_label, ',') [role_ids]
			INNER JOIN application_security_role aru ON aru.role_name =  [role_ids].item 
			
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
			, 'Send Message'
			, 'spa_privileges_iu'
			, 'Success'
			, 'Privileges successfully assigned for Deal Template.'
			, ''
	END TRY
	BEGIN CATCH
		ROLLBACK
		IF @@ERROR <> 0
			BEGIN 
				EXEC spa_ErrorHandler @@ERROR
					, 'Insert Broker Fees.'
					, 'spa_privileges_iu'
					, 'DB Error'
					, 'Failed to assign privileges for templates..'
					, ''
			END
		RETURN
	END CATCH
END
