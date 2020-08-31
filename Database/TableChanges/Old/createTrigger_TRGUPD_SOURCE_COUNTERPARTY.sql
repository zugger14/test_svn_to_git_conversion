SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_COUNTERPARTY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_COUNTERPARTY]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_COUNTERPARTY]
ON [dbo].[source_counterparty]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_counterparty
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_counterparty sc
      INNER JOIN DELETED u ON sc.source_counterparty_id = u.source_counterparty_id  
	    

	INSERT INTO source_counterparty_audit
	  (
		source_counterparty_id,
		source_system_id,
		counterparty_id,
		counterparty_name,
		counterparty_desc,
		int_ext_flag,
		netting_parent_counterparty_id,
		[address],
		phone_no,
		mailing_address,
		fax,
		type_of_entity,
		contact_name,
		contact_title,
		contact_address,
		contact_address2,
		contact_phone,
		contact_fax,
		instruction,
		confirm_from_text,
		confirm_to_text,
		confirm_instruction,
		counterparty_contact_title,
		counterparty_contact_name,
		parent_counterparty_id,
		customer_duns_number,
		is_jurisdiction,
		counterparty_contact_id,
		email,
		contact_email,
		city,
		[state],
		zip,
		is_active,
		user_action,
		cc_email,
	    bcc_email,
	    cc_remittance,
	    bcc_remittance,
	    email_remittance_to,
	    delivery_method,
	    country,
		region,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts
	  )
	SELECT source_counterparty_id,
		   source_system_id,
		   counterparty_id,
		   counterparty_name,
		   counterparty_desc,
		   int_ext_flag,
		   netting_parent_counterparty_id,
		   [address],
		   phone_no,
		   mailing_address,
		   fax,
		   type_of_entity,
		   contact_name,
		   contact_title,
		   contact_address,
		   contact_address2,
		   contact_phone,
		   contact_fax,
		   instruction,
		   confirm_from_text,
		   confirm_to_text,
		   confirm_instruction,
		   counterparty_contact_title,
		   counterparty_contact_name,
		   parent_counterparty_id,
		   customer_duns_number,
		   is_jurisdiction,
		   counterparty_contact_id,
		   email,
		   contact_email,
		   city,
		   [state],
		   zip,
		   is_active,
		   'update' [user_action],
		   cc_email,
		   bcc_email,
		   cc_remittance,
		   bcc_remittance,
		   email_remittance_to,
		   delivery_method,
		   country,
		   region,
	       create_user,
			create_ts,
			dbo.FNADBUser(),
			GETDATE()
	FROM   INSERTED