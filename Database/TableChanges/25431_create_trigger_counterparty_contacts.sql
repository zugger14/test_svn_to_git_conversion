SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_counterparty_contacts]'))
    DROP TRIGGER [dbo].[TRGINS_counterparty_contacts]
GO
-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_counterparty_contacts]
ON [dbo].[counterparty_contacts]
FOR INSERT
AS
BEGIN
	INSERT INTO counterparty_contacts_audit
	  (
			counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,update_user
			,update_ts
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id
			,user_action 
	  )
	SELECT counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,update_user
			,update_ts
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id  
	        ,'insert'
	FROM   INSERTED
END

GO
--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_contacts]'))
    DROP TRIGGER [dbo].[TRGUPD_counterparty_contacts]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_contacts]
ON [dbo].[counterparty_contacts]
FOR UPDATE
AS
BEGIN
	IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE counterparty_contacts
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM counterparty_contacts cca
        INNER JOIN DELETED d ON d.counterparty_contact_id = cca.counterparty_contact_id
    END

	INSERT INTO counterparty_contacts_audit
	  (
			counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,update_user
			,update_ts
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id
			,user_action                  
	  )
	SELECT counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,update_user
			,update_ts
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id
	        ,'update'
	FROM   INSERTED
END

GO
-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_counterparty_contacts]'))
    DROP TRIGGER [dbo].[TRGDEL_counterparty_contacts]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_counterparty_contacts]
ON [dbo].[counterparty_contacts]
FOR DELETE
AS
BEGIN
	INSERT INTO counterparty_contacts_audit
	  (
			counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,update_user
			,update_ts
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id
			,user_action                   
	  )
	SELECT counterparty_contact_id
			,counterparty_id
			,contact_type
			,title
			,[name]
			,id
			,address1
			,address2
			,city
			,[state]
			,zip
			,telephone
			,fax
			,email
			,country
			,region
			,comment
			,is_active
			,is_primary
			,create_user
			,create_ts
			,dbo.FNADBUser()
			,CURRENT_TIMESTAMP
			,cell_no
			,email_cc
			,email_bcc
			,last_name
			,date_of_birth
			,national_id
	       ,'delete'
	FROM   DELETED
END