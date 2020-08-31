
IF OBJECT_ID('[dbo].[spa_save_confirm_status]', 'p') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_save_confirm_status]
GO 

CREATE PROCEDURE [dbo].[spa_save_confirm_status]
	@flag CHAR(1),
	@confirm_id INT = NULL,
	@counterparty_id VARCHAR(1000) = NULL,
	@as_of_date VARCHAR(50) = NULL,
	@status VARCHAR(50) = NULL,
	@source_deal_header_id VARCHAR(1000) = NULL,
	@deal_locked CHAR(1) = NULL,
	@xml_data VARCHAR(MAX) = NULL
AS
	
DECLARE @confirm_flag AS CHAR(5)

IF @flag='s'
BEGIN
	SELECT confirm_id [Confirmation ID],
	       scs.source_deal_header_id AS [Deal ID],
	       sc.counterparty_name [Counterparty],
	       dbo.FNADateFormat(scs.as_of_date) [As of Date],
	       CASE WHEN ([status] = 'v') THEN 'Voided' ELSE 'Sent' END [Status],
	       scs.create_user [Created By],
	       dbo.FNADateTimeFormat(scs.create_ts, 1) [Created Time Stamp]
	FROM   save_confirm_status scs
	INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') a ON  a.item = scs.source_deal_header_id
	JOIN source_counterparty sc ON  scs.counterparty_id = sc.source_counterparty_id
	ORDER BY scs.source_deal_header_id, confirm_id DESC
END
IF @flag='a'
BEGIN
	SELECT s.confirm_id , s.counterparty_id , dbo.FNADateFormat(s.as_of_date) AsOfDate,s.status,s.source_deal_header_id, sdh.deal_locked
	FROM save_confirm_status  s
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id=s.source_deal_header_id
	WHERE confirm_id = @confirm_id	
END
IF @flag='u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			UPDATE save_confirm_status
			SET    counterparty_id = @counterparty_id,
			       as_of_date = @as_of_date,
			       [status] = @status
			WHERE  confirm_id = @confirm_id
			
			IF @status = 's'
			    SET @confirm_flag = 'y'
			ELSE
			    SET @confirm_flag = 'n' 
			
			IF @status = 's'
			    SET @status = 17202
			ELSE
			    SET @status = 17200 
			
			UPDATE confirm_status
			SET    [TYPE] = @status,
			       as_of_date = @as_of_date
			WHERE  confirm_id = @confirm_id
			
			UPDATE confirm_status_recent
			SET    [type] = @status,
			       as_of_date = GETDATE(),
			       is_confirm = @confirm_flag
			WHERE  confirm_id = @confirm_id				

		COMMIT TRAN
	
		EXEC spa_ErrorHandler 0, 'Save Confirmation History', 'spa_save_confirm_status', 'Success', 'Confiramtion History successfully Updated.', @status
	
	END TRY
	BEGIN CATCH
		BEGIN	
			ROLLBACK TRAN
			
			EXEC spa_ErrorHandler @@ERROR, 'Save Confirmation History', 'spa_save_confirm_status', 'DB Error', 'Error on Updating Confirmation History.', ''
		END
	END CATCH 
END

IF @flag='i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DECLARE @OldConfirmId  AS INT
			DECLARE @statusCount   AS INT,
			        @is_confirm    AS CHAR(5)

			CREATE TABLE #confirm_reports
			(
				[date]                        DATETIME,
				trader                        VARCHAR(100) COLLATE DATABASE_DEFAULT,
				trade_date                    DATETIME,
				trade_type                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
				[type]                        VARCHAR(30) COLLATE DATABASE_DEFAULT,
				commodity                     VARCHAR(30) COLLATE DATABASE_DEFAULT,
				[start_date]                  DATETIME,
				end_date                      DATETIME,
				quantity                      VARCHAR(100) COLLATE DATABASE_DEFAULT,
				total_quantity                VARCHAR(100) COLLATE DATABASE_DEFAULT,
				price_index                   VARCHAR(30) COLLATE DATABASE_DEFAULT,
				pricing_date                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
				fixed_price                   VARCHAR(100) COLLATE DATABASE_DEFAULT,
				service_type                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
				payment_frequency             VARCHAR(30) COLLATE DATABASE_DEFAULT,
				settle_rules                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
				holiday_calendar              VARCHAR(30) COLLATE DATABASE_DEFAULT,
				external_trade_id             VARCHAR(50) COLLATE DATABASE_DEFAULT,
				book                          VARCHAR(30) COLLATE DATABASE_DEFAULT,
				comments                      VARCHAR(100) COLLATE DATABASE_DEFAULT,
				counterparty_name             VARCHAR(100) COLLATE DATABASE_DEFAULT,
				counterparty_address          VARCHAR(255) COLLATE DATABASE_DEFAULT,
				counterparty_phone_no         VARCHAR(100) COLLATE DATABASE_DEFAULT,
				counterparty_mailing_address  VARCHAR(255) COLLATE DATABASE_DEFAULT,
				counterparty_fax_email        VARCHAR(100) COLLATE DATABASE_DEFAULT,
				trade_confirmation_status     VARCHAR(30) COLLATE DATABASE_DEFAULT,
				trade_confirmation_comment    VARCHAR(255) COLLATE DATABASE_DEFAULT,
				nearby_month                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
				roll_convention               VARCHAR(30) COLLATE DATABASE_DEFAULT,
				trader_phone                  VARCHAR(20) COLLATE DATABASE_DEFAULT,
				trader_fax                    VARCHAR(20) COLLATE DATABASE_DEFAULT,
				trader_email                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
				payment_dates                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
				system_trade_id               INT,
				input_by                      VARCHAR(50) COLLATE DATABASE_DEFAULT,
				premium_settlement_date       DATETIME,
				strike_price                  NUMERIC(38, 20),
				premium                       NUMERIC(38, 20),
				total_premium                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
				input_date                    DATETIME,
				verified_by_name              VARCHAR(255) COLLATE DATABASE_DEFAULT,
				verified_date                 DATETIME,
				user_login_id                 VARCHAR(255) COLLATE DATABASE_DEFAULT,
				location_name                 VARCHAR(255) COLLATE DATABASE_DEFAULT,
				broker_name                   VARCHAR(255) COLLATE DATABASE_DEFAULT,
				is_confirm                    CHAR(1) COLLATE DATABASE_DEFAULT,
				init_template                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
				sub_template                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
				curve_definition              VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
				deal_volume_frequency         VARCHAR(1000) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #confirm_reports EXEC spa_deal_confirm_report @source_deal_header_id, 'v'
			
			INSERT INTO save_confirm_status
			  (
			    counterparty_id,
			    as_of_date,
			    create_user,
			    create_ts,
			    [status],
			    source_deal_header_id,
			    [date],
			    trader,
			    trade_date,
			    trade_type,
			    [type],
			    commodity,
			    [start_date],
			    end_date,
			    quantity,
			    total_quantity,
			    price_index,
			    pricing_date,
			    fixed_price,
			    service_type,
			    payment_frequency,
			    settle_rules,
			    holiday_calendar,
			    external_trade_id,
			    book,
			    comments,
			    counterparty_name,
			    counterparty_address,
			    counterparty_phone_no,
			    counterparty_mailing_address,
			    counterparty_fax_email,
			    trade_confirmation_status,
			    trade_confirmation_comment,
			    nearby_month,
			    roll_convention,
			    trader_phone,
			    trader_fax,
			    trader_email,
			    payment_dates,
			    system_trade_id,
			    input_by,
			    premium_settlement_date,
			    strike_price,
			    premium,
			    total_premium,
			    input_date,
			    verified_by_name,
			    verified_date,
			    user_login_id,
			    location_name,
			    broker_name,
			    is_confirm,
			    init_template,
			    sub_template,
			    curve_definition,
			    deal_volume_frequency
			  )
			SELECT @counterparty_id,
			       @as_of_date,
			       dbo.FNADBUser(),
			       GETDATE(),
			       @status,
			       @source_deal_header_id,
			       [date],
			       trader,
			       trade_date,
			       trade_type,
			       [type],
			       commodity,
			       [start_date],
			       end_date,
			       quantity,
			       total_quantity,
			       price_index,
			       pricing_date,
			       fixed_price,
			       service_type,
			       payment_frequency,
			       settle_rules,
			       holiday_calendar,
			       external_trade_id,
			       book,
			       comments,
			       counterparty_name,
			       counterparty_address,
			       counterparty_phone_no,
			       counterparty_mailing_address,
			       counterparty_fax_email,
			       trade_confirmation_status,
			       trade_confirmation_comment,
			       nearby_month,
			       roll_convention,
			       trader_phone,
			       trader_fax,
			       trader_email,
			       payment_dates,
			       system_trade_id,
			       input_by,
			       premium_settlement_date,
			       strike_price,
			       premium,
			       total_premium,
			       input_date,
			       verified_by_name,
			       verified_date,
			       user_login_id,
			       location_name,
			       broker_name,
			       is_confirm,
			       init_template,
			       sub_template,
			       curve_definition,
			       deal_volume_frequency
			FROM   #confirm_reports
			
	
		IF @status = 's'
		    SET @status = 17202
		ELSE
		    SET @status = 17200 
		
		SET @confirm_id = SCOPE_IDENTITY()
		
		SELECT @statusCount = COUNT(*) FROM save_confirm_status
		WHERE  source_deal_header_id = @source_deal_header_id AND STATUS = 'v'
		
		IF @statusCount <= 1
		BEGIN
		    SET @is_confirm = 'n'
		END
		ELSE
		BEGIN
		    SET @is_confirm = 'y'
		END

		INSERT INTO confirm_status(source_deal_header_id, [TYPE], as_of_date, comment1, comment2, confirm_id, 
					create_user, create_ts, update_user, update_ts)
		VALUES(@source_deal_header_id, @status, GETDATE(), NULL, NULL, @confirm_id, NULL, NULL, NULL, NULL) 

		IF EXISTS ( SELECT confirm_status_id FROM confirm_status_recent WHERE source_deal_header_id=@source_deal_header_id)
		BEGIN
			UPDATE confirm_status_recent
			SET    [TYPE] = @status,
			       as_of_date = GETDATE(),
			       confirm_id = @confirm_id,
			       is_confirm = @is_confirm
			WHERE  source_deal_header_id = @source_deal_header_id
		END
		ELSE
		BEGIN			
			INSERT INTO confirm_status_recent(source_deal_header_id, [TYPE], as_of_date, comment1, comment2, confirm_id,
				create_user, create_ts, update_user, update_ts, is_confirm)
			VALUES(@source_deal_header_id, @status, GETDATE(), NULL, NULL, @confirm_id, NULL,NULL, NULL,NULL,@is_confirm)
		END			

		COMMIT TRAN

			DECLARE @returnvalue VARCHAR(100)
			SET @returnvalue = @status + ',' + @is_confirm

			EXEC spa_ErrorHandler 0, 'Save Confirmation History', 'spa_save_confirm_status', 'Success', 'Confirmation History successfully Inserted.', @returnvalue
	END TRY
	BEGIN CATCH
		BEGIN	
			ROLLBACK TRAN
			
			EXEC spa_ErrorHandler -1, 'Save Confirmation History', 'spa_save_confirm_status', 'DB Error', 'Error on Inseting Confirmation History.', ''
		END
	END CATCH 
END

IF @flag = 'v'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		DECLARE @xml_status CHAR(1)
		
		SET @xml_status = ''
		
		IF @xml_data IS NOT NULL OR @xml_data <> ''
		BEGIN
			DECLARE @sm_doc INT
			EXEC sp_xml_preparedocument @sm_doc OUTPUT, @xml_data

			--Execute a INSERT-SELECT statement that uses the OPENXML rowset provider.
			SELECT counterparty_id,
				   as_of_date,
				   [status],
				   source_deal_header_id,
				   deal_locked
			INTO #multiple_deal_templates		       
			FROM OPENXML(@sm_doc, '/Root/PSRecordset', 1)
			WITH (
				   counterparty_id INT,
				   as_of_date VARCHAR(10),
				   [status] VARCHAR(100),
				   source_deal_header_id INT,
				   deal_locked CHAR(1)
			)
							
			EXEC sp_xml_removedocument @sm_doc
			SELECT @xml_status = [status] FROM #multiple_deal_templates
		END
			 
		CREATE TABLE #confirm_report
		(
			DATE                          DATETIME,
			trader                        VARCHAR(100) COLLATE DATABASE_DEFAULT,
			trade_date                    DATETIME -- rename
			,
			trade_type                    VARCHAR(50) COLLATE DATABASE_DEFAULT,
			TYPE                          VARCHAR(30) COLLATE DATABASE_DEFAULT,
			commodity                     VARCHAR(30) COLLATE DATABASE_DEFAULT,
			START_DATE                    DATETIME,
			end_date                      DATETIME,
			quantity                      VARCHAR(100) COLLATE DATABASE_DEFAULT,
			total_quantity                VARCHAR(100) COLLATE DATABASE_DEFAULT,
			price_index                   VARCHAR(30) COLLATE DATABASE_DEFAULT,
			pricing_date                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
			fixed_price                   VARCHAR(100) COLLATE DATABASE_DEFAULT,
			service_type                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
			payment_frequency             VARCHAR(30) COLLATE DATABASE_DEFAULT,
			settle_rules                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
			holiday_calendar              VARCHAR(30) COLLATE DATABASE_DEFAULT,
			external_trade_id             VARCHAR(50) COLLATE DATABASE_DEFAULT,
			book                          VARCHAR(30) COLLATE DATABASE_DEFAULT,
			comments                      VARCHAR(100) COLLATE DATABASE_DEFAULT,
			counterparty_name             VARCHAR(100) COLLATE DATABASE_DEFAULT,
			counterparty_address          VARCHAR(255) COLLATE DATABASE_DEFAULT,
			counterparty_phone_no         VARCHAR(100) COLLATE DATABASE_DEFAULT,
			counterparty_mailing_address  VARCHAR(255) COLLATE DATABASE_DEFAULT,
			counterparty_fax_email        VARCHAR(100) COLLATE DATABASE_DEFAULT,
			trade_confirmation_status     VARCHAR(30) COLLATE DATABASE_DEFAULT,
			trade_confirmation_comment    VARCHAR(255) COLLATE DATABASE_DEFAULT,
			nearby_month                  VARCHAR(30) COLLATE DATABASE_DEFAULT,
			roll_convention               VARCHAR(30) COLLATE DATABASE_DEFAULT,
			trader_phone                  VARCHAR(20) COLLATE DATABASE_DEFAULT,
			trader_fax                    VARCHAR(20) COLLATE DATABASE_DEFAULT,
			trader_email                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
			payment_dates                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
			system_trade_id               INT,
			input_by                      VARCHAR(50) COLLATE DATABASE_DEFAULT,
			premium_settlement_date       DATETIME,
			strike_price                  NUMERIC(38, 20),
			premium                       NUMERIC(38, 20),
			total_premium                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
			input_date                    DATETIME,
			verified_by_name              VARCHAR(255) COLLATE DATABASE_DEFAULT,
			verified_date                 DATETIME,
			user_login_id                 VARCHAR(255) COLLATE DATABASE_DEFAULT,
			location_name                 VARCHAR(255) COLLATE DATABASE_DEFAULT,
			broker_name                   VARCHAR(255) COLLATE DATABASE_DEFAULT,
			is_confirm                    CHAR(1) COLLATE DATABASE_DEFAULT,
			init_template                 VARCHAR(100) COLLATE DATABASE_DEFAULT,
			sub_template                  VARCHAR(100) COLLATE DATABASE_DEFAULT,
			curve_definition              VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			deal_volume_frequency         VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			source_deal_header_id         INT
		)
		
		INSERT INTO #confirm_report
		EXEC spa_deal_confirm_report @source_deal_header_id , 'v'
	
		INSERT INTO save_confirm_status
		  (
			counterparty_id,
			as_of_date,
			create_user,
			create_ts,
			STATUS,
			source_deal_header_id,
			DATE,
			trader,
			trade_date,
			trade_type,
			TYPE,
			commodity,
			START_DATE,
			end_date,
			quantity,
			total_quantity,
			price_index,
			pricing_date,
			fixed_price,
			service_type,
			payment_frequency,
			settle_rules,
			holiday_calendar,
			external_trade_id,
			book,
			comments,
			counterparty_name,
			counterparty_address,
			counterparty_phone_no,
			counterparty_mailing_address,
			counterparty_fax_email,
			trade_confirmation_status,
			trade_confirmation_comment,
			nearby_month,
			roll_convention,
			trader_phone,
			trader_fax,
			trader_email,
			payment_dates,
			system_trade_id,
			input_by,
			premium_settlement_date,
			strike_price,
			premium,
			total_premium,
			input_date,
			verified_by_name,
			verified_date,
			user_login_id,
			location_name,
			broker_name,
			is_confirm,
			init_template,
			sub_template,
			curve_definition,
			deal_volume_frequency
		  )
		SELECT sc.source_counterparty_id,
			   @as_of_date,
			   dbo.FNADBUser(),
			   GETDATE(),
			   CASE 
					WHEN (@xml_status = 'e') THEN 's'
					ELSE 'v'
			   END,
			   source_deal_header_id,
			   DATE,
			   trader,
			   trade_date,
			   trade_type,
			   TYPE,
			   commodity,
			   START_DATE,
			   end_date,
			   quantity,
			   total_quantity,
			   price_index,
			   pricing_date,
			   fixed_price,
			   service_type,
			   payment_frequency,
			   settle_rules,
			   holiday_calendar,
			   external_trade_id,
			   book,
			   comments,
			   cr.counterparty_name,
			   counterparty_address,
			   counterparty_phone_no,
			   counterparty_mailing_address,
			   counterparty_fax_email,
			   trade_confirmation_status,
			   trade_confirmation_comment,
			   nearby_month,
			   roll_convention,
			   trader_phone,
			   trader_fax,
			   trader_email,
			   payment_dates,
			   system_trade_id,
			   input_by,
			   premium_settlement_date,
			   strike_price,
			   premium,
			   total_premium,
			   input_date,
			   verified_by_name,
			   verified_date,
			   user_login_id,
			   location_name,
			   broker_name,
			   is_confirm,
			   init_template,
			   sub_template,
			   curve_definition,
			   deal_volume_frequency
		FROM   #confirm_report cr
		INNER JOIN source_counterparty sc ON  sc.counterparty_name = cr.counterparty_name
		
		IF @xml_data IS NOT NULL OR @xml_data <> ''
		BEGIN
		
			UPDATE mdt
			SET [status] = CASE 
								WHEN mdt.[status] = 'e' THEN 17202
								WHEN mdt.[status] = 'u' THEN 17203
								WHEN mdt.[status] = 'd' THEN 17201
								ELSE  17200 
			               END
			FROM  #multiple_deal_templates mdt
			INNER JOIN save_confirm_status scs ON scs.source_deal_header_id = mdt.source_deal_header_id
			
			ALTER TABLE #multiple_deal_templates ADD confirm_id INT
			
			SELECT MAX(scs.confirm_id) confirm_id , scs.source_deal_header_id 
			INTO #comfimation_ids
			FROM  #multiple_deal_templates mdt
			INNER JOIN save_confirm_status scs ON scs.source_deal_header_id = mdt.source_deal_header_id
			GROUP BY scs.source_deal_header_id
			
			UPDATE mdt
			SET confirm_id = cids.confirm_id 
			FROM  #multiple_deal_templates mdt
			INNER JOIN #comfimation_ids cids ON cids.source_deal_header_id = mdt.source_deal_header_id
			
			INSERT INTO confirm_status
			SELECT source_deal_header_id, [status], GETDATE(), NULL, NULL, confirm_id, NULL,NULL, NULL,NULL 
			FROM #multiple_deal_templates
		     
			UPDATE sdh 
			SET sdh.deal_locked= mdt.deal_locked
			FROM source_deal_header sdh
			INNER JOIN #multiple_deal_templates mdt ON mdt.source_deal_header_id = sdh.source_deal_header_id
			
			ALTER TABLE #multiple_deal_templates ADD confirm_status CHAR(1)
			
			SELECT COUNT(scs.confirm_id) counts, mdt.source_deal_header_id 
			INTO #confirm_status_update
			FROM save_confirm_status scs
			INNER JOIN #multiple_deal_templates mdt ON mdt.source_deal_header_id = scs.source_deal_header_id
				AND scs.[status] = 's'
			GROUP BY mdt.source_deal_header_id
			
			UPDATE mdt
			SET mdt.confirm_status = CASE WHEN ISNULL(csu.counts, 0) <=1 THEN 'n' ELSE 'y' END 
			FROM #multiple_deal_templates mdt
			LEFT JOIN #confirm_status_update csu ON csu.source_deal_header_id = mdt.source_deal_header_id
			
			DECLARE @TableName VARCHAR(255)
			DECLARE @sql VARCHAR(MAX)
			
			DECLARE TableCursor CURSOR FOR
			SELECT 	source_deal_header_id
			FROM #multiple_deal_templates 
			OPEN TableCursor
			FETCH NEXT FROM TableCursor INTO @source_deal_header_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @sql = 'IF EXISTS (SELECT confirm_status_id FROM confirm_status_recent WHERE source_deal_header_id=' + @source_deal_header_id + ')
						BEGIN
							UPDATE csc
							SET [TYPE] = [status]
								, as_of_date = mdt.as_of_date
								, confirm_id = mdt.confirm_id
								, is_confirm = confirm_status
							FROM confirm_status_recent csc 
							INNER JOIN #multiple_deal_templates mdt ON mdt.source_deal_header_id = csc.source_deal_header_id
							AND mdt.source_deal_header_id = ' + @source_deal_header_id + '
						END 
						ELSE 
						BEGIN 
							INSERT INTO confirm_status_recent(source_deal_header_id, [TYPE], as_of_date, comment1, comment2, confirm_id,
															create_user, create_ts, update_user, update_ts, is_confirm)
							SELECT source_deal_header_id, status, GETDATE(), NULL, NULL, confirm_id,NULL,NULL, NULL,NULL,confirm_status
							FROM #multiple_deal_templates WHERE source_deal_header_id = ' + @source_deal_header_id + '
						END' 
			exec spa_print @sql
			EXEC(@sql)
			FETCH NEXT FROM TableCursor INTO @source_deal_header_id
			END
			CLOSE TableCursor
			DEALLOCATE TableCursor
			
			UPDATE sdh
			SET	confirm_status_type = [status]
			FROM source_deal_header sdh 
			INNER JOIN #multiple_deal_templates mdt ON mdt.source_deal_header_id = sdh.source_deal_header_id
		END
		ELSE 
		BEGIN
			IF  @status = 'e'
				SET @status = 17202
			IF  @status = 'u'
				SET @status = 17203 
			IF  @status = 'd'
				SET @status = 17201 
			IF  @status = 'n'
				SET @status = 17200  
			SET @confirm_id = SCOPE_IDENTITY()
		
		
			DECLARE @staCount AS INT,@confirm AS CHAR(5)
			SELECT  @staCount=COUNT(*) FROM save_confirm_status WHERE source_deal_header_id=@source_deal_header_id AND status = 's'
			IF @staCount <= 1 
			BEGIN
				SET @confirm = 'n'
			END
			ELSE
			BEGIN
				SET @confirm = 'y'
			END

			INSERT INTO confirm_status
			SELECT @source_deal_header_id, @status, GETDATE(), NULL, NULL, @confirm_id, NULL,NULL, NULL,NULL 

			UPDATE source_deal_header SET deal_locked=@deal_locked WHERE source_deal_header_id = @source_deal_header_id

			IF EXISTS ( SELECT confirm_status_id FROM confirm_status_recent WHERE source_deal_header_id=@source_deal_header_id)
			BEGIN
				UPDATE confirm_status_recent
				SET    [TYPE] = @status,
				       as_of_date = @as_of_date,
				       confirm_id = @confirm_id,
				       is_confirm = @confirm
				WHERE  source_deal_header_id = @source_deal_header_id
				
				UPDATE source_deal_header
				SET    confirm_status_type = @status
				WHERE  source_deal_header_id = @source_deal_header_id 
				
			END
			ELSE
			BEGIN			
				INSERT INTO confirm_status_recent(source_deal_header_id, [TYPE], as_of_date, comment1, comment2, confirm_id,
					create_user, create_ts, update_user, update_ts, is_confirm)
				VALUES(@source_deal_header_id, @status, GETDATE(), NULL, NULL, @confirm_id, NULL,NULL, NULL,NULL,@confirm)
					
				UPDATE source_deal_header
				SET    confirm_status_type = @status
				WHERE  source_deal_header_id = @source_deal_header_id	
			END
		END

			COMMIT TRAN
			
			EXEC spa_insert_update_audit 'u',@source_deal_header_id
	
			DECLARE @retValue VARCHAR(100)
			SET @retValue = CAST(17201 AS VARCHAR) + ', ' + 'n'

			EXEC spa_ErrorHandler 0, 'Save Confirmation History', 'spa_save_confirm_status', 'Success', 'Confirmation History successfully Inserted.', @source_deal_header_id

	END TRY
	BEGIN CATCH
		BEGIN	
			--SELECT ERROR_MESSAGE()			
			ROLLBACK TRAN
			EXEC spa_ErrorHandler -1, 'Save Confirmation History', 'spa_save_confirm_status', 'DB Error', 'Error on Inserting Confirmation History.', ''
		END
	END CATCH 
END 

IF @flag = 't'
BEGIN
	SELECT TOP(1) confirm_id FROM save_confirm_status scs
	INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') a ON a.item = scs.source_deal_header_id
	ORDER BY confirm_id DESC
END
