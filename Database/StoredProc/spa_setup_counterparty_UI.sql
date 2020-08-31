/****** Object:  StoredProcedure [dbo].[spa_setup_counterparty_UI]    Script Date: 24/06/2014 ******/
--braryal@pioneersolutionsglobal.com
IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_setup_counterparty_UI]')
  AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_setup_counterparty_UI]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_setup_counterparty_UI] @flag char(1),
@xml nvarchar(max) = NULL
AS
SET NOCOUNT ON
  DECLARE @sql Nvarchar(4000),
          @idoc int

  DECLARE @a Nvarchar(100) = ''
  DECLARE @b Nvarchar(100)
  DECLARE @counterparty_id NVARCHAR(10)


IF @flag = 'i'
BEGIN
BEGIN TRY
	
	DECLARE @is_primary NVARCHAR(10)
	DECLARE @counterparty_contact_id NVARCHAR(10)
	DECLARE @contract_type NVARCHAR(10)
	DECLARE @name NVARCHAR(100)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml

	IF OBJECT_ID('tempdb..#temp_update_contact') IS NOT NULL
      DROP TABLE #temp_update_contact

    IF OBJECT_ID('tempdb..#temp_insert_contact') IS NOT NULL
      DROP TABLE #temp_insert_contact
    
    SELECT
      @counterparty_id = counterparty_id
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    counterparty_id NVARCHAR(10)
    )
    SELECT
      @is_primary = is_primary
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    is_primary NVARCHAR(10)
    )
    SELECT
      @contract_type = contact_type
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    contact_type NVARCHAR(10)
    )
    SELECT
      @name = [name]
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    [name] NVARCHAR(100)
    )
    SELECT
      @counterparty_contact_id = [object_id]
    FROM OPENXML(@idoc, '/Root', 1)
    WITH (
    [object_id] NVARCHAR(10)
    )
    
    IF @counterparty_contact_id = ''
		BEGIN    
    
		--INSERT
    
		SELECT
		  --counterparty_contact_id [counterparty_contact_id],
		  counterparty_id [counterparty_id],
		  contact_type [contact_type],
		  title [title],
		  name [name],
		  id [id],
		  address1,
		  address2,
		  city,
		  state [state],
		  zip,
		  telephone,
		  cell_no,
		  fax,
		  email,
		  email_cc,
		  email_bcc,
		  country,
		  region,
		  comment,
		  is_active,
		  is_primary
      
		  INTO #temp_insert_contact
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
		--counterparty_contact_id varchar(10),
		counterparty_id NVARCHAR(10),
		contact_type NVARCHAR(10),
		title NVARCHAR(100),
		name nvarchar(200),
		id nvarchar(1000),
		address1 nvarchar(4000),
		address2 nvarchar(4000),
		city NVARCHAR(100),
		[state] NVARCHAR(100),
		zip NVARCHAR(10),
		telephone varchar(30),
		cell_no nvarchar(24),
		fax varchar(20),
		email varchar(150),
		email_cc varchar(150),
		email_bcc varchar(150),
		country varchar(100),
		region varchar(100),
		comment nvarchar(4000),
		is_active varchar(10),
		is_primary varchar(10)
		)

	 IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND is_primary = 'y' AND @is_primary = 'y')
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Error',
			'Primary Contact has already been defined for this Counterparty.',
			''		
			RETURN
		END

		IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND contact_type = @contract_type AND NAME = @name )
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Error',
			'Combination of Contact Type and Name must be unique.',
			''		
			RETURN
		END
	
		INSERT INTO counterparty_contacts (counterparty_id, contact_type, title, name, id, address1, address2, city, [state], zip, telephone, cell_no, fax, email, email_cc, email_bcc, country, region, comment, is_active, is_primary)
		SELECT counterparty_id, contact_type, title, name, id, address1, address2, city, [state], zip, telephone, cell_no, fax, email, email_cc, email_bcc, country, region, comment, is_active, is_primary
		FROM #temp_insert_contact
		
		SELECT @counterparty_contact_id = SCOPE_IDENTITY();
	
		EXEC spa_ErrorHandler 0,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Success',
			'Changes have been saved successfully.',
			@counterparty_contact_id
	END
	ELSE
	BEGIN
		
		--UPDATE
		
		SELECT
		  --counterparty_contact_id [counterparty_contact_id],
		  counterparty_id [counterparty_id],
		  contact_type [contact_type],
		  title [title],
		  name [name],
		  id [id],
		  address1,
		  address2,
		  city,
		  state [state],
		  zip,
		  telephone,
		  cell_no,
		  fax,
		  email,
		  email_cc,
		  email_bcc,
		  country,
		  region,
		  comment,
		  is_active,
		  is_primary
      
		  INTO #temp_update_contact
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
		--counterparty_contact_id varchar(10),
		counterparty_id NVARCHAR(10),
		contact_type NVARCHAR(10),
		title NVARCHAR(100),
		name NVARCHAR(200),
		id nvarchar(100),
		address1 nvarchar(4000),
		address2 nvarchar(4000),
		city NVARCHAR(200),
		[state] NVARCHAR(10),
		zip NVARCHAR(10),
		telephone varchar(30),
		cell_no varchar(12),
		fax varchar(20),
		email varchar(MAX),
		email_cc varchar(MAX),
		email_bcc varchar(MAX),
		country varchar(10),
		region varchar(10),
		comment nvarchar(4000),
		is_active varchar(10),
		is_primary varchar(10)
		)
		
		IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND is_primary = 'y' AND @is_primary = 'y' AND counterparty_contact_id <> @counterparty_contact_id )
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Error',
			'Primary Contact has already been defined for this Counterparty.',
			''		
			RETURN
		END

		IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND contact_type = @contract_type AND NAME = @name AND counterparty_contact_id<>@counterparty_contact_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Error',
			'Combination of Contact Type and Name must be unique.',
			''		
			RETURN
		END
		
			UPDATE  cc
		SET cc.contact_type = tic.contact_type, 
			cc.title = tic.title, 
			cc.name = tic.name, 
			cc.id = tic.id, 
			cc.address1 = tic.address1, 
			cc.address2 = tic.address2, 
			cc.city = tic.city, 
			cc.[state] = tic.[state], 
			cc.zip = tic.zip, 
			cc.telephone = tic.telephone, 
			cc.cell_no = tic.cell_no,
			cc.fax = tic.fax, 
			cc.email = tic.email, 
			cc.email_cc = tic.email_cc,
			cc.email_bcc = tic.email_bcc,
			cc.country = tic.country, 
			cc.region = tic.region, 
			cc.comment = tic.comment, 
			cc.is_active = tic.is_active, 
			cc.is_primary = tic.is_primary
			FROM #temp_update_contact tic
			INNER JOIN counterparty_contacts cc ON cc.counterparty_id = tic.counterparty_id 
		WHERE cc.counterparty_contact_id = @counterparty_contact_id
		
		EXEC spa_ErrorHandler 0,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Success',
			'Changes have been saved successfully.',
			''
		END
	END TRY	
	
	BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'counterparty_contacts',
                          'spa_counterparty_contacts',
                          'DB Error',
                          'Failed to insert/update Contact.',
                          ''
  END CATCH
		
END

IF @flag = 'b'
BEGIN
BEGIN TRY
	
	--DECLARE @counterparty_id VARCHAR(10)
	DECLARE @Account_no NVARCHAR(10)
	DECLARE @counterparty_bankinfo_id NVARCHAR(10)
	DECLARE @currency NVARCHAR(10)
	DECLARE @primary_account CHAR(1)
	DECLARE @accountname NVARCHAR(50)
	DECLARE @wire_ABA NVARCHAR(50)
	DECLARE @alert_process_id VARCHAR(200)
	DECLARE @alert_process_table VARCHAR(500)
	SET @alert_process_id = dbo.FNAGetNewID()  
	SET @alert_process_table = 'adiha_process.dbo.alert_counterparty_bank_info_' + @alert_process_id + '_cbi'

	EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml

	IF OBJECT_ID('tempdb..#temp_update_contact') IS NOT NULL
      DROP TABLE #temp_update_bankinfo

    IF OBJECT_ID('tempdb..#temp_insert_contact') IS NOT NULL
      DROP TABLE #temp_insert_bankinfo
    
    SELECT
      @counterparty_id = counterparty_id
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    counterparty_id Nvarchar(10)
    )
    SELECT
      @Account_no = Account_no
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    Account_no NVARCHAR(10)
    )
    SELECT
      @currency = currency
    FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    currency NVARCHAR(10)
    )

    SELECT
      @counterparty_bankinfo_id = [bank_id]
     FROM OPENXML(@idoc, '/Root/FormXML', 1)
    WITH (
    [bank_id] NVARCHAR(10)
    )
    
    SELECT @primary_account = primary_account
    FROM   OPENXML(@idoc, '/Root/FormXML', 1)
           WITH (primary_account CHAR(1))
    
    SELECT @accountname = accountname
    FROM   OPENXML(@idoc, '/Root/FormXML', 1)
           WITH (accountname NVARCHAR(50))
    
    SELECT @wire_ABA = wire_ABA
    FROM   OPENXML(@idoc, '/Root/FormXML', 1)
           WITH (wire_ABA NVARCHAR(50))
    
    IF @counterparty_bankinfo_id = ''
		BEGIN    
    
		--INSERT
    
		SELECT
		  --counterparty_contact_id [counterparty_contact_id],
		  counterparty_id [counterparty_id],
		  bank_name,
		  accountname,
		  Account_no,
		  ACH_ABA,
		  wire_ABA,
		  currency,
		  Address1,
		  Address2,
		  reference,
		  primary_account
      
		  INTO #temp_insert_bankinfo
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
		--counterparty_contact_id varchar(10),
		counterparty_id Nvarchar(10),
		bank_name Nvarchar(100),
		  accountname Nvarchar(100),
		  Account_no Nvarchar(100),
		  ACH_ABA Nvarchar(100),
		  wire_ABA Nvarchar(100),
		  currency Nvarchar(100),
		  Address1 Nvarchar(4000),
		  Address2 Nvarchar(4000),
		  reference Nvarchar(100),
		  primary_account CHAR(1)
		)
				
		IF EXISTS (SELECT 1 FROM counterparty_bank_info WHERE counterparty_id = @counterparty_id AND Account_no = @Account_no AND bank_id<>@counterparty_bankinfo_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_bank_info',
			'spa_setup_counterparty_UI',
			'Error',
			'Bank info for entered Account No. is already defined.',
			''		
			RETURN
		END
		
		--IF EXISTS (SELECT 1 FROM counterparty_bank_info WHERE counterparty_id = @counterparty_id AND currency = @currency AND bank_id<>@counterparty_bankinfo_id)
		--BEGIN
		--	EXEC spa_ErrorHandler -1,
		--	'counterparty_bank_info',
		--	'spa_setup_counterparty_UI',
		--	'Error',
		--	'Bank info for selected currency is already defined.',
		--	''		
		--	RETURN
		--END
	
		INSERT INTO counterparty_bank_info (
			counterparty_id,bank_name,accountname, Account_no, ACH_ABA,  wire_ABA, currency,  Address1, Address2,reference)
		SELECT counterparty_id,bank_name,accountname, Account_no, ACH_ABA,  wire_ABA, currency,  Address1, Address2,reference
		FROM #temp_insert_bankinfo
		
		SET @counterparty_bankinfo_id = SCOPE_IDENTITY();
	
		EXEC spa_ErrorHandler 0,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Success',
			'Changes have been saved successfully.',
			@counterparty_bankinfo_id
	END
	ELSE
	BEGIN
		
		--UPDATE
		
		SELECT
		  --counterparty_contact_id [counterparty_contact_id],
		  counterparty_id [counterparty_id],
		  bank_name,
		  accountname,
		  Account_no,
		  ACH_ABA,
		  wire_ABA,
		  currency,
		  Address1,
		  Address2,
		  reference,
		  primary_account
      
		  INTO #temp_update_bankinfo
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
		--counterparty_contact_id varchar(10),
		counterparty_id Nvarchar(10),
		bank_name Nvarchar(100),
		  accountname Nvarchar(100),
		  Account_no Nvarchar(100),
		  ACH_ABA Nvarchar(100),
		  wire_ABA Nvarchar(100),
		  currency Nvarchar(100),
		  Address1 Nvarchar(4000),
		  Address2 Nvarchar(4000),
		  reference Nvarchar(100),
		  primary_account CHAR(1)
		)
		--select @counterparty_bankinfo_id
		--RETURN
		--SELECT * FROM #temp_update_bankinfo
		--RETURN
		IF EXISTS (SELECT 1 FROM counterparty_bank_info WHERE counterparty_id = @counterparty_id AND Account_no = @Account_no AND bank_id<>@counterparty_bankinfo_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_bank_info',
			'spa_setup_counterparty_UI',
			'Error',
			'Bank info for entered Account No. is already defined.',
			''		
			RETURN
		END
		
		IF EXISTS (SELECT 1 FROM counterparty_bank_info WHERE counterparty_id = @counterparty_id AND currency = @currency AND bank_id<>@counterparty_bankinfo_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
			'counterparty_bank_info',
			'spa_setup_counterparty_UI',
			'Error',
			'Bank info for selected currency is already defined.',
			''		
			RETURN
		END
		
		IF EXISTS (SELECT 1 FROM counterparty_bank_info WHERE counterparty_id = @counterparty_id AND primary_account = 'y' AND currency = @currency) AND @primary_account = 'y'
		BEGIN
			UPDATE counterparty_bank_info SET primary_account = NULL WHERE counterparty_id = @counterparty_id AND primary_account = 'y' AND currency = @currency
		END
		
			UPDATE  cc
		SET cc.bank_name = tic.bank_name,
		  cc.accountname=tic.accountname ,
		  cc.Account_no=tic.Account_no,
		  cc.ACH_ABA=tic.ACH_ABA ,
		  cc.wire_ABA=tic.wire_ABA ,
		  cc.currency =tic.currency,
		  cc.Address1 =tic.Address1,
		  cc.Address2 =tic.Address2,
		  cc.reference =tic.reference,
		  cc.primary_account = tic.primary_account
			FROM #temp_update_bankinfo tic
			INNER JOIN counterparty_bank_info cc ON cc.counterparty_id = tic.counterparty_id 
		WHERE cc.bank_id = @counterparty_bankinfo_id
		
		SET @counterparty_bankinfo_id = SCOPE_IDENTITY();
		
		EXEC spa_ErrorHandler 0,
			'counterparty_contacts',
			'spa_counterparty_contacts',
			'Success',
			'Changes have been saved successfully.',
			@counterparty_bankinfo_id
		END

		SET @sql = 'CREATE TABLE ' + @alert_process_table + '
					(
						counterparty_bankinfo_id INT
					)
					INSERT INTO ' + @alert_process_table + '(
						counterparty_bankinfo_id
					)
					SELECT ' + CAST(@counterparty_bankinfo_id AS VARCHAR)
		EXEC(@sql)
		-- Start Alert/Workflow Process
		EXEC spa_register_event 20602, 10000328, @alert_process_table, 1, @alert_process_id
		EXEC spa_register_event 20602, 10000329, @alert_process_table, 1, @alert_process_id
	END TRY	
	
	BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'counterparty_contacts',
                          'spa_counterparty_contacts',
                          'DB Error',
                          'Failed to insert/update Contact.',
                          ''
  END CATCH
		
END