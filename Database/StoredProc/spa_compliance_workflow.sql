
IF OBJECT_ID('[dbo].[spa_compliance_workflow]', 'p') IS NOT NULL
    DROP PROC [dbo].[spa_compliance_workflow]
GO

/*
Author : Vishwas Khanal
Dated  : 01.27.2010
Description : SP for Compliance Integration.
*/

CREATE PROC [dbo].[spa_compliance_workflow]
	@functionid				VARCHAR(100),
	@actionType				CHAR(1),
	@id						VARCHAR(1000), -- e.g Deal Id
	@source					VARCHAR(150) = NULL,
	@successErrorFlag		CHAR(1) = 's',
	@msg					VARCHAR(8000) = NULL,
	@activity_id			VARCHAR(100) = NULL,
	@event_id				INT = NULL,
	@deal_status_from		INT = NULL,
	@deal_status_message	INT = NULL,
	@status_rule_detail_id  VARCHAR(8000) = NULL
AS
BEGIN
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET QUOTED_IDENTIFIER ON
	
	/*
	@functionName - Its the filterID from the process_filters table.
	@actionType - based on this parameter we can decide upon source description and message descritpion as well.
	'i' - insertion
	'u' - updation				
	@id -  This is updated deal ID or anything as such.
	@source - Source has to be decided from the @functionid but as this is already used it is kept intact. This is obselete, can
	be used for other purpose later.
	@functionid - 
	2  : Deal confirmation saved(Generate Confirmation). Generate Confirmation link is sent to the back office.
	On deal confirmation, messages from the mid office has to disappear.
	110: Messsage to be sent to the mid office for deal sign off. Also the insertion and updation message 
	created for that particular deal will be deleted for the deal.
	111: Messsage to be sent to the back office for deal sign off. 
	112: Message to be sent to back office and mid office on deal Insertion and updation.
	109: Message to the Traders for deal insertion/updation.
	1  : Clears the message from the message board whose source is Deal.Notification.
	3 : Deletes the messages for the deleted deal.
	115 : Messages to be sent to backoffice and
	116 : Notification to concerned users/roles to approve the matched hedging
	117 : Notification to concerned users/roles to finalize the approved hedging 
	4 : Deletes the messages for the finalized hedging.	
	*/
	
	DECLARE @xml                       VARCHAR(100),
	        @desc                      VARCHAR(5000),
	        @messageboard              VARCHAR(1000),
	        @urlparam                  VARCHAR(1000),
	        @functionName              VARCHAR(1000),
	        @getdate                   DATETIME,
	        @entityId                  INT,
	        @id_tmp                    INT,
	        @ref_id                    VARCHAR(50),
	        @instanceID                VARCHAR(5000),
	        @signedOffBy               VARCHAR(100),
	        @updateUser                VARCHAR(100),
	        @timeStamp                 DATETIME,
	        @descForMail               VARCHAR(5000),
	        @timeStamp_tmp             VARCHAR(10),
	        @mailbody                  VARCHAR(MAX),
	        @createTrigger             CHAR(1),
	        @as_of_date_from           AS VARCHAR(10),
	        @as_of_date_to             AS VARCHAR(10),
	        @deal_status               VARCHAR(100),
	        @deal_status_from_code     VARCHAR(100),
	        @risk_control_activity_id  INT 
	
	-- functionality for @functionid = 3 has been integrated for @functionid = 115
	--	IF @functionid = 3 AND @id IS NOT NULL AND @id <> ''
	--	BEGIN
	--		SELECT @instanceID = NULL
	--		SELECT @instanceID	= COALESCE(@instanceID+',','')+CAST(risk_control_activity_id AS VARCHAR)
	--			FROM process_risk_controls_activities WHERE  source_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@id)) AND source IN ('Deal','Deal.Notification')
	--
	--		UPDATE message_board SET delActive = 'n'
	--			WHERE source_id IN (SELECT 'cmp-'+item FROM dbo.splitCommaSeperatedValues(@instanceID))
	--
	--		RETURN
	--	END
	
	SET @descForMail = ''
	
	IF @functionid IN (110, 2)
	BEGIN
	    SELECT @instanceID = NULL
	    
	    IF @functionid = 110
	        SELECT @instanceID = COALESCE(@instanceID + ',', '') + CAST(risk_control_activity_id AS VARCHAR)
	        FROM   process_risk_controls_activities
	        WHERE  source_id = CAST(@id AS VARCHAR)
	               AND source = 'Deal'
	    ELSE
	        SELECT @instanceID = COALESCE(@instanceID + ',', '') + CAST(risk_control_activity_id AS VARCHAR)
	        FROM   process_risk_controls_activities
	        WHERE  source_id = CAST(@id AS VARCHAR)
	               AND comments LIKE '%risk management%'
	               AND source = 'Deal'
	    
	    
	    --		DELETE FROM process_risk_controls_activities WHERE  source_id = CAST(@id AS VARCHAR)
	    --		DELETE FROM message_board WHERE CASE WHEN CHARINDEX(':',reminderDate)<> 0
	    --									THEN SUBSTRING(reminderDate,CHARINDEX(':',reminderDate)+1,LEN(reminderDate))
	    --								ELSE -1 END = @instanceID
	    --									AND source = 'Deal'	
	    IF @instanceID IS NOT NULL
	        UPDATE message_board
	        SET    delActive = 'n'
	        WHERE  CASE 
	                    WHEN CHARINDEX(':', reminderDate) <> 0 THEN SUBSTRING(reminderDate,CHARINDEX(':', reminderDate) + 1,LEN(reminderDate))
	                    ELSE -1
	               END IN (SELECT item FROM   dbo.splitCommaSeperatedValues(@instanceID))
	               AND source = 'Deal'
	END
	ELSE 
	IF @functionid = 1 -- Clear the message from the message board where the source is Deals.Notification
	BEGIN
	    IF @id = -1 -- when 'clear all' is done then  -1 is passed from spa_message_board. Else, the message_id is passed.
	    BEGIN
	        DECLARE @allbackOfficeInstanceID VARCHAR(5000)
	        SELECT @allbackOfficeInstanceID = ''
	        SELECT @allbackOfficeInstanceID = @allbackOfficeInstanceID + ',' +
	               CAST(message_id AS VARCHAR(5))
	        FROM   message_board
	        WHERE  source = 'Deal.Notification'
	               AND CHARINDEX(':', reminderDate) <> 0
	               AND user_login_id = dbo.FNADBUSer()
	        
	        SELECT @allbackOfficeInstanceID = SUBSTRING(@allbackOfficeInstanceID, 2, LEN(@allbackOfficeInstanceID))	
	        
	        IF @allbackOfficeInstanceID IS NOT NULL AND @allbackOfficeInstanceID <> ''
	            EXEC ('UPDATE message_board  SET delActive = ''n'' WHERE message_id IN (' + @allbackOfficeInstanceID + ')')
	    END
	    ELSE
	    BEGIN
	        IF EXISTS (
	               SELECT 'x'
	               FROM   message_board
	               WHERE  source = 'Deal.Notification'
	                      AND message_id = @id
	                      AND CHARINDEX(':', reminderDate) <> 0
	           )
	            UPDATE message_board SET    delActive = 'n' WHERE  message_id = @id
	    END
	    RETURN
	END
	ELSE 
	IF @functionid = 4 -- Remove message for finalized hedge
	BEGIN
	    --remove finalize message from message board
	    DELETE 
	    FROM   message_board
	    WHERE  source_id IN (SELECT 'cmp-' + CAST(risk_control_activity_id AS VARCHAR)
	                         FROM   process_risk_controls_activities
	                         WHERE  source = 'HedgeRel.Finalize'
	                                AND source_id NOT IN (SELECT ISNULL(approved_process_id, '')
	                                                      FROM   
	                                                             gen_fas_link_header
	                                                      WHERE  gen_status <> 
	                                                             'r'))
	    
	    DELETE 
	    FROM   process_risk_controls_activities
	    WHERE  source = 'HedgeRel.Finalize'
	           AND source_id NOT IN (SELECT ISNULL(approved_process_id, '')
	                                 FROM   gen_fas_link_header
	                                 WHERE  gen_status <> 'r')
	END
	
	
	SELECT @functionName = filterId	FROM   process_functions_detail	WHERE  functionId = @functionid
	
	IF (
	       -- If function Id doesn't exists for no activity has been mapped to the function id then return
	       (
	           NOT EXISTS (
	               SELECT 'x'
	               FROM   process_functions_listing_detail
	               WHERE  functionId = @functionid
	           )
	       )
	       OR (
	              NOT EXISTS (
	                  SELECT 'x'
	                  FROM   process_functions_listing_detail
	                  WHERE  risk_control_id IS NOT NULL
	                         AND functionId = @functionid
	              )
	          )
	   )
	    RETURN
	
	
	SELECT @getdate = dbo.FNAGetSQLStandardDateTime(GETDATE())
	IF @functionid = 109 -- Trader deal insertion. This will flow the message to the mapped Trader.
	BEGIN
	    --SELECT @xml = '<root> '
	    
	    SELECT @source = 'Deal'							
	    
	    DECLARE idsList CURSOR  
	    FOR
	        SELECT item FROM dbo.splitCommaSeperatedValues(@id)
	    
	    OPEN idsList
	    FETCH NEXT FROM idsList INTO @id_tmp
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	        SELECT @entityId = trader_id,
	               @ref_id = deal_id
	        FROM   source_deal_header
	        WHERE  source_deal_header_id = @id_tmp
	        
	        SELECT @xml = '<root> <row ' + @functionName + '="' + CAST(@entityid AS VARCHAR) 
	               + '" ></row></root>'
	        
	        SELECT @desc = 'Deal ID # ' + dbo.FNATrmHyperlink(
	                   'b',
	                   10131010,
	                   @id_tmp,
	                   @id_tmp,
	                   'n',
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT
	               ) + ' (' + @ref_id + ')' + CASE @actionType
	                                               WHEN 'i' THEN ' is inserted.'
	                                               WHEN 'u' THEN ' is updated.'
	                                               WHEN 'x' THEN 
	                                                    ' has been cancelled.'
	                                               WHEN 'd' THEN 
	                                                    ' deal status has been updated'
	                                               WHEN 'c' THEN 
	                                                    ' confirmation status has been updated'
	                                               WHEN 'f' THEN 
	                                                    ' deal ticket has been approved by front office'
	                                               WHEN 'm' THEN 
	                                                    ' deal ticket has been approved by middle office'
	                                               ELSE 
	                                                    ' deal ticket has been approved by back office'
	                                          END
	               --CASE WHEN @actionType = 'i' THEN '' ELSE '<br>
	               --<a target="_blank" href="./dev/spa_html.php?__user_name__=farrms_admin&spa=exec spa_Create_Deal_Audit_Report ''c'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '+CAST(@id_tmp AS VARCHAR(10))+ ', NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,'''+CONVERT(VARCHAR(20),GETDATE(),120)+'''">
	               --View Deal Audit Log Report</a>
	               --&nbsp;&nbsp;&nbsp;'	END					
	               +'<br>' + dbo.FNATrmHyperlink(
	                   'i',
	                   10131010,
	                   'Review Deal',
	                   @id_tmp,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT
	               )
	               + '&nbsp;&nbsp;&nbsp;' +
	               dbo.FNATrmHyperlink(
	                   'i',
	                   10131020,
	                   'Sign off on Trade Ticket',
	                   @id_tmp,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT
	               ),
	               @descForMail = 'Deal ID # ' + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ') ' + 
									CASE @actionType
	                                       WHEN 'i' THEN ' is inserted.'
	                                       WHEN 'u' THEN ' is updated.'
	                                       WHEN 'x' THEN ' has been cancelled.'
	                                       WHEN 'd' THEN ' deal status has been updated'
	                                       WHEN 'c' THEN ' confirmation status has been updated'
	                                       WHEN 'f' THEN ' deal ticket has been approved by front office'
	                                       WHEN 'm' THEN ' deal ticket has been approved by middle office'
	                                       ELSE ' deal ticket has been approved by back office'
	                                  END
	        
	        IF @deal_status_message = 1
	            SET @descForMail = @descForMail + 
	                'Deal status has been changed from Validated to Amended for ' 
	                + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ')'
	        
	        
	        EXEC spa_complete_compliance_activities 'c',
											 @functionid,
											 @xml,
											 @desc,
											 'c',
											 @source,
											 @id_tmp,
											 NULL,
											 @activity_id
	        --EXEC spa_get_outstanding_control_activities_job @getdate,NULL,@descForMail -- will post the message in the message board
	        --END
	        
	        FETCH NEXT FROM idsList INTO @id_tmp
	    END
	    CLOSE idsList
	    DEALLOCATE idsList
	END-- @functionid = 109		  
	ELSE 
	IF @functionid IN (110, 111)
	BEGIN
	    DECLARE idsList CURSOR  
	    FOR
	        SELECT item FROM   dbo.splitCommaSeperatedValues(@id)
	    
	    OPEN idsList
	    FETCH NEXT FROM idsList INTO @id_tmp
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	        SELECT @ref_id = deal_id
	        FROM   source_deal_header
	        WHERE  source_deal_header_id = @id_tmp
	        
	        SELECT @xml = '<root> <row ' + @functionName + 
	               '="5651" ></row></root>'
	        
	        SELECT @source = CASE @functionid
	                              WHEN 110 THEN 'Deal'
	                              ELSE 'Deal.Notification'
	                         END
	        
	        -- check if it has been previously signed off.
	        --SELECT @signedOffBy = NULL
	        --SELECT @signedOffBy = verified_by FROM source_deal_header_audit WHERE source_deal_header_id = @id_tmp  order by verified_by asc
	        --SELECT @actionType = CASE WHEN @signedOffBy IS NULL THEN 'i' ELSE 'u' END
	        
	        SELECT @desc = 'Deal ID # ' + dbo.FNATrmHyperlink(
	                   'b',
	                   10131010,
	                   @id_tmp,
	                   @id,
	                   'n',
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT,
	                   DEFAULT
	               ) + ' (' + @ref_id + ')' + 
					CASE @actionType
					   WHEN 'i' THEN ' has been created'
					   WHEN 'u' THEN ' has been updated'
					   WHEN 'x' THEN ' has been cancelled.'
					   WHEN 'f' THEN ' deal ticket has been approved by front office'
					   WHEN 'm' THEN ' deal ticket has been approved by middle office'
					   ELSE ' deal ticket has been approved by back office'
					END	              
	               + CASE @actionType
	                      WHEN 'f' THEN + '&nbsp;&nbsp;&nbsp;' + 
									   'Please proceed for Risk Review SignOff.'
									   + '<br>' + dbo.FNATrmHyperlink(
										   'b',
										   10131010,
										   'Review Deal',
										   @id,
										   'n',
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
									   + '&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
										   'i',
										   10131020,
										   'Risk Review Sign Off',
										   @id,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
	                      WHEN 'm' THEN +'&nbsp;&nbsp;&nbsp;' + 
										'Please proceed for Back Office SignOff.'
									   + '<br>' + dbo.FNATrmHyperlink(
										   'b',
										   10131010,
										   'Review Deal',
										   @id,
										   'n',
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
									   + '&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
										   'i',
										   10131020,
										   'Back Office Sign Off',
										   @id_tmp,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
									   + '&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
										   'i',
										   10171016,
										   'Generate Confirmation',
										   @id_tmp,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
	                      WHEN 'b' THEN + '&nbsp;&nbsp;&nbsp;' + 
									   'Please review the deal.'
									   + '<br>' + dbo.FNATrmHyperlink(
										   'b',
										   10131010,
										   'Review Deal',
										   @id_tmp,
										   'n',
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT,
										   DEFAULT
									   )
	                      ELSE ''
	                 END,
	               @descForMail = 'Deal ID # ' + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ') ' + 
									CASE @actionType
									   WHEN 'i' THEN ' has been created'
									   WHEN 'u' THEN ' has been updated'
									   WHEN 'x' THEN ' has been cancelled.'
									   WHEN 'd' THEN ' deal status has been updated'
									   WHEN 'c' THEN ' confirmation status has been updated'
									   WHEN 'f' THEN ' deal ticket has been approved by front office'
									   WHEN 'm' THEN ' deal ticket has been approved by middle office'
									   ELSE ' deal ticket has been approved by back office'
									END
							   + ' by ' + @updateUser + ' at ' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())) 
							   + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
							   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
							   + '.'  
	        
	        BEGIN
	        	EXEC spa_complete_compliance_activities 'c',
	        	     @functionid,
	        	     @xml,
	        	     @desc,
	        	     'c',
	        	     @source,
	        	     @id_tmp,
	        	     NULL,
	        	     NULL,
	        	     @risk_control_activity_id = @risk_control_activity_id 
	        	     OUTPUT
	        	
	        	EXEC spa_get_outstanding_control_activities_job @getdate,
	        	     @activity_id,
	        	     NULL,
	        	     @descForMail,
	        	     @id_tmp,
	        	     @risk_control_activity_id -- will post the message in the message board
	        END
	        
	        FETCH NEXT FROM idsList INTO @id_tmp
	    END
	    CLOSE idsList
	    DEALLOCATE idsList
	END
	ELSE 
	IF @functionid = 112
	BEGIN
	    SELECT @source = 'Deal.Notification'							
	    
	    DECLARE idsList CURSOR  
	    FOR
	        SELECT item
	        FROM   dbo.splitCommaSeperatedValues(@id)
	    
	    OPEN idsList
	    FETCH NEXT FROM idsList INTO @id_tmp
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	        SELECT @ref_id = deal_id,
	               @timeStamp = ISNULL(sdd.update_ts, sdd.create_ts)
	        FROM   source_deal_header sdd
	        WHERE  source_deal_header_id = @id_tmp		
	        
	        SELECT @updateUser = ISNULL(user_title, ' ') + ISNULL(user_f_name, ' ')
	               + ISNULL(user_m_name, ' ') + ISNULL(user_l_name, ' ')
	        FROM   source_deal_header sdd
	               INNER JOIN application_users
	                    ON  user_login_id = sdd.update_user
	        WHERE  source_deal_header_id = @id_tmp
	        
	        SELECT @xml = '<root> <row ' + @functionName + '="5652"  ></row></root>'
	        
	        --SET @timeStamp = dbo.FNADateTimeFormat(@timeStamp,1)
	        --			SELECT @timeStamp_tmp =SUBSTRING(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)),1,LEN(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)))-2)+' ' +RIGHT(@timeStamp,2)
	        SET @timeStamp_tmp = '<time>' + CAST(@timeStamp AS VARCHAR(50)) + '</time>'
	        
			IF @actionType = 'u'
	            EXEC spa_get_html_email_body @id_tmp, @mailbody OUT
	        
	        
	        SELECT @deal_status = sdv.code
	        FROM   source_deal_header sdh
	               INNER JOIN static_data_value sdv
	                    ON  sdv.value_id = sdh.deal_status
	        WHERE  sdh.source_deal_header_id = @id_tmp
	        
	        SELECT @deal_status_from_code = sdv.code
	        FROM   static_data_value sdv
	        WHERE  sdv.value_id = @deal_status_from
	        
	        IF @actionType = 'd' OR @actionType = 'c'
	        BEGIN
	            SELECT @desc = CASE @actionType
	                                WHEN 'd' THEN 
	                                     'Deal Status has been changed from <span style ="color:blue">' 
	                                     + @deal_status_from_code + 
	                                     '</span> to <span style ="color:blue">' 
	                                     + @deal_status + ' </span>'
	                                WHEN 'c' THEN 
	                                     'confirm status has been changed'
	                           END + ' for Deal ID #' + dbo.FNATrmHyperlink(
									   'i',
									   10131010,
									   @id_tmp,
									   @id,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT
								   ) + 
							' (' + @ref_id + ')' + ' by ' + @updateUser + ' at ' + 
						   CONVERT(VARCHAR, DATEPART(hh, GETDATE())) + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
						   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
						   + '.',
	                   @descForMail = CASE @actionType
	                                       WHEN 'd' THEN 
	                                            'Deal Status has been changed from ' 
	                                            + @deal_status_from_code + 
	                                            ' to ' + @deal_status
	                                       WHEN 'c' THEN 
	                                            'confirm status has been changed'
	                                  END + ' for Deal ID #' + dbo.FNATrmHyperlink(
											   'i',
											   10131010,
											   @id_tmp,
											   @id,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT,
											   DEFAULT
										   ) + 
									' (' + @ref_id + ')' + ' by ' + @updateUser + ' at ' + 
								   CONVERT(VARCHAR, DATEPART(hh, GETDATE())) + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
								   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2)
								   + '.'
	        END
	        ELSE
	        BEGIN
	            SELECT @desc = 'Deal ID # ' + dbo.FNATrmHyperlink(
	                       'b',
	                       10131010,
	                       @id_tmp,
	                       @id,
	                       'n',
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT,
	                       DEFAULT
	                   ) + ' (' + @ref_id + ')' + CASE @actionType
	                                                   WHEN 'i' THEN 
	                                                        ' has been created'
	                                                   WHEN 'u' THEN 
	                                                        ' has been updated'
	                                                   WHEN 'x' THEN 
	                                                        ' has been cancelled.'
	                                                   WHEN 'f' THEN 
	                                                        ' deal ticket has been approved by front office'
	                                                   WHEN 'm' THEN 
	                                                        ' deal ticket has been approved by middle office'
	                                                   ELSE 
	                                                        ' deal ticket has been approved by back office'
	                                              END
	                   + ' by ' + @updateUser + ' at' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())) 
	                   + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
	                   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
	                   + '.'
	                   
	                   + CASE @actionType
	                          WHEN 'f' THEN +'&nbsp;&nbsp;&nbsp;' + 
	                               'Please proceed for Risk Review SignOff.'
	                               + '<br>' + dbo.FNATrmHyperlink(
	                                   'b',
	                                   10131010,
	                                   'Review Deal',
	                                   @id,
	                                   'n',
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT
	                               )
	                               + '&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
	                                   'i',
	                                   10131020,
	                                   'Risk Review Sign Off',
	                                   @id,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT
	                               )
	                               --WHEN 'm' THEN
	                               --			+'&nbsp;&nbsp;&nbsp;' + 'Please proceed for Back Office SignOff.'
	                               --+'<br>'+ dbo.FNATrmHyperlink('b',10131010,'Review Deal',@id,'n',default,default,default,default,default,default,default,default,default,default)
	                               --+'&nbsp;&nbsp;&nbsp;'+dbo.FNATrmHyperlink('i',10131020,'Back Office Sign Off',@id_tmp,default,default,default,default,default,default,default,default,default,default,default)
	                          WHEN 'b' THEN + '&nbsp;&nbsp;&nbsp;' + 
	                               'Please review the deal and prepare for confirmation process.'
	                               + '<br>' + dbo.FNATrmHyperlink(
	                                   'b',
	                                   10131010,
	                                   'Review Deal',
	                                   @id_tmp,
	                                   'n',
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT
	                               )
	                               + '&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
	                                   'i',
	                                   10171016,
	                                   'Generate Confirmation',
	                                   @id_tmp,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT,
	                                   DEFAULT
	                               )
	                          ELSE ''
	                     END,
	                   @descForMail = 'Deal ID # ' + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ') ' + 
										CASE @actionType
                                            WHEN 'i' THEN ' has been created'
                                            WHEN 'u' THEN ' has been updated'
                                            WHEN 'x' THEN ' has been cancelled.'
                                            WHEN 'd' THEN ' deal status has been updated'
                                            WHEN 'c' THEN ' confirmation status has been updated'
                                            WHEN 'f' THEN ' deal ticket has been approved by front office'
                                            WHEN 'm' THEN ' deal ticket has been approved by middle office'
                                            ELSE ' deal ticket has been approved by back office'
                                       END
									   + ' by ' + @updateUser + ' at ' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())) 
									   + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
									   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
									   + '.'
	        END 
	        
	        --IF EXISTS (
	        --	SELECT 'x' FROM source_deal_header sdh
	        --	INNER JOIN deal_confirmation_rule dcr
	        --		ON	sdh.counterparty_id = dcr.counterparty_id
	        --		AND	sdh.header_buy_sell_flag = ISNULL(dcr.buy_sell_flag,sdh.header_buy_sell_flag)
	        --		AND COALESCE(sdh.commodity_id,-1) = COALESCE(dcr.commodity_id,sdh.commodity_id,-1)
	        --		AND	COALESCE(sdh.contract_id,-1) = COALESCE(dcr.contract_id,sdh.contract_id,-1)
	        --		AND	COALESCE(sdh.source_deal_type_id,-1) = COALESCE(dcr.deal_type_id,sdh.source_deal_type_id,-1)
	        --	WHERE sdh.source_deal_header_id = @id_tmp
	        --)
	        --BEGIN
	        
	        IF @deal_status_message = 1
	            SET @descForMail = @descForMail + 
	                'Deal status has been changed from Validated to Amended for ' 
	                + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ')'
	        
	        EXEC spa_complete_compliance_activities 'c',
	             @functionid,
	             @xml,
	             @desc,
	             'c',
	             @source,
	             @id_tmp,
	             NULL,
	             NULL,
	             @risk_control_activity_id = @risk_control_activity_id OUTPUT
	        
	        EXEC spa_get_outstanding_control_activities_job @getdate,
	             @activity_id,
	             NULL,
	             @descForMail,
	             @id_tmp,
	             @risk_control_activity_id -- -- will post the message in the message board
	        --END
	        
	        FETCH NEXT FROM idsList INTO @id_tmp
	    END
	    CLOSE idsList
	    DEALLOCATE idsList
	END
	ELSE 
	IF @functionid = 113 -- Activity Data Import
	BEGIN
	    UPDATE process_risk_controls_activities
	    SET    control_status = 728
	    WHERE  risk_control_activity_id = (
	               SELECT MAX(risk_control_activity_id)
	               FROM   dbo.process_risk_controls_activities prca
	                      INNER JOIN dbo.process_risk_controls prc
	                           ON  prca.risk_control_id = prc.risk_control_id
	               WHERE  activity_type = 13700
	           )
	    
	    SELECT @xml = '<root> <row ' + @functionName + '="13400"  ></row></root>', @source = 'Import.Activity'				
	    
	    SELECT @desc = 'Activity data import process completed.<BR>' + @msg + 
						CASE 
						   WHEN (@successErrorFlag = 'e') THEN 
								'<BR><i>Water quality limits violation</i>.'
						   ELSE 
								''
						END 
	    
	    SELECT @createTrigger = CASE @successErrorFlag
	                                 WHEN 'e' THEN 'y'
	                                 ELSE 'n'
	                            END
	    
	    EXEC spa_complete_compliance_activities 'c',
	         @functionid,
	         @xml,
	         @desc,
	         @successErrorFlag,
	         @source,
	         @id,
	         @createTrigger
	    
	    EXEC spa_get_outstanding_control_activities_job @getdate,
	         NULL,
	         NULL
	END
	ELSE 
	IF @functionid = 114 -- Allowance Data Import
	BEGIN
	    UPDATE process_risk_controls_activities
	    SET    control_status = 728
	    WHERE  risk_control_activity_id = (
	               SELECT MAX(risk_control_activity_id)
	               FROM   dbo.process_risk_controls_activities prca
	                      INNER JOIN dbo.process_risk_controls prc
	                           ON  prca.risk_control_id = prc.risk_control_id
	               WHERE  activity_type = 13701
	           )
	    
	    SELECT @xml = '<root> <row ' + @functionName + '="13500"  ></row></root>', @source = 'Import.Allowance'				
	    
	    SELECT @desc = 'EPA Allowance import process Completed for as of date:' + 
					   dbo.FNADateFormat(GETDATE()) +
					   CASE 
							WHEN (@successErrorFlag = 'e') THEN ' <BR><i><font color = #C11B17>ERRORS </font> found</i> .'
							ELSE ''
					   END 
					--CASE WHEN @successErrorFlag = 'e' THEN ' (ERRORS found)' ELSE '' END
	    
	    EXEC spa_complete_compliance_activities 'c',
	         @functionid,
	         @xml,
	         @desc,
	         @successErrorFlag,
	         @source,
	         @id
	    
	    EXEC spa_get_outstanding_control_activities_job @getdate,
	         NULL,
	         NULL
	END
	ELSE 
	IF @functionid = 115
	BEGIN
	    -- Delete all the messages related to the deleted Deals 
	    SELECT @instanceID = NULL		
	    SELECT @instanceID = COALESCE(@instanceID + ',', '') + CAST(risk_control_activity_id AS VARCHAR)
	    FROM   process_risk_controls_activities
	    WHERE  source_id IN (SELECT item
	                         FROM   dbo.splitCommaSeperatedValues(@id))
	           AND source IN ('Deal', 'Deal.Notification')
	    
	    DELETE message_board
	    WHERE  source_id IN (SELECT 'cmp-' + item
	                         FROM   dbo.splitCommaSeperatedValues(@instanceID))
	    -- Delete the instance against the deal id
	    DELETE 
	    FROM   process_risk_controls_activities
	    WHERE  risk_control_activity_id IN (SELECT item
	                                        FROM   dbo.splitcommaSeperatedValues(@instanceID))
	    
	    -- Send the Deletion messages
	    SELECT @source = 'Deal.Notification'					
	    
	    SELECT @xml = '<root> <row ' + @functionName + '="5700"  ></row></root>'
	    
	    SELECT @ref_id = deal_id,
	           @timeStamp = ISNULL(sdd.update_ts, sdd.create_ts),
	           @updateUser = ISNULL(user_title, ' ') + ISNULL(user_f_name, ' ') + 
	           ISNULL(user_m_name, ' ') + ISNULL(user_l_name, ' ')
	    FROM   source_deal_header_audit sdd
	           INNER JOIN application_users
	                ON  user_login_id = sdd.update_user
	    WHERE  source_deal_header_id IN (SELECT item
	                                     FROM   dbo.splitcommaSeperatedValues(@id))
	           AND user_action = 'Delete'
	    
	    --		SET @timeStamp = dbo.FNADateTimeFormat(@timeStamp,1)
	    --		SELECT @timeStamp_tmp =SUBSTRING(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)),1,LEN(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)))-2)+' ' +RIGHT(@timeStamp,2)
	    SET @timeStamp_tmp = '<time>' + CAST(@timeStamp AS VARCHAR(50)) + '</time>'
	    
	    --SELECT @desc = 'Deal ID #'+dbo.FNATrmHyperlink('b',10131010,@id,@id,'y',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT)+' ('+@ref_id+') has been deleted by '+@updateUser+'.';
	    SELECT @desc = 'Deal ID #' + @id + ' (' + @ref_id + ') has been deleted by ' + @updateUser + '.';
	    
	    
	    --IF EXISTS (
	    --	SELECT 'x' FROM source_deal_header sdh
	    --	INNER JOIN deal_confirmation_rule dcr
	    --		ON	sdh.counterparty_id = dcr.counterparty_id
	    --		AND	sdh.header_buy_sell_flag = ISNULL(dcr.buy_sell_flag,sdh.header_buy_sell_flag)
	    --		AND COALESCE(sdh.commodity_id,-1) = COALESCE(dcr.commodity_id,sdh.commodity_id,-1)
	    --		AND	COALESCE(sdh.contract_id,-1) = COALESCE(dcr.contract_id,sdh.contract_id,-1)
	    --		AND	COALESCE(sdh.source_deal_type_id,-1) = COALESCE(dcr.deal_type_id,sdh.source_deal_type_id,-1)
	    --	WHERE sdh.source_deal_header_id = @id_tmp
	    --)
	    --BEGIN
	    
	    EXEC spa_complete_compliance_activities 'c',
	         @functionid,
	         @xml,
	         @desc,
	         'c',
	         @source,
	         @id
	  
	    EXEC spa_get_outstanding_control_activities_job @getdate,
	         NULL,
	         @desc -- will post the message in the message board
	    --END
	
	END
	ELSE 
	IF @functionid = 116
	BEGIN
	    SELECT @xml = '<root> <row ' + @functionName + '="13600"  ></row></root>', @source = 'Import.Data'
	END
	ELSE 
	IF @functionid = 116 -- Hedge Relationship Approve
	BEGIN
	    SET @as_of_date_from = SUBSTRING(@source, 1, (CHARINDEX('|', @source) - 1))
	    SET @as_of_date_to = SUBSTRING(@source, (CHARINDEX('|', @source) + 1), 10)
	    
	    SELECT @xml = '<root> <row ' + @functionName + '="5800"  ></row></root>',
	           @source = 'HedgeRel.Approve'				
	    
	    SELECT @desc = 'Automatic Matching Process is completed for as of date:'
					   + dbo.FNADateFormat(GETDATE()) + 
					   '. Please approve hedging relationships.<br>' 
					   + dbo.FNATrmHyperlink(
						   'k',
						   10234500,
						   'Approve Hedging Relationships',
						   'false',
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   @as_of_date_from,
						   @as_of_date_to
					   )
	    
	    EXEC spa_complete_compliance_activities 'c',
	         @functionid,
	         @xml,
	         @desc,
	         @successErrorFlag,
	         @source,
	         @id
	    
	    EXEC spa_get_outstanding_control_activities_job @getdate,
	         NULL,
	         @desc -- will post the message in the message board
	END
	ELSE 
	IF @functionid = 117 -- Hedge Relationship Finalize
	BEGIN
	    SET @as_of_date_from = SUBSTRING(@source, 1, (CHARINDEX('|', @source) - 1))
	    SET @as_of_date_to = SUBSTRING(@source, (CHARINDEX('|', @source) + 1), 10)	    
	    
	    SELECT @xml = '<root> <row ' + @functionName + '="5900"  ></row></root>',
	           @source = 'HedgeRel.Finalize'				
	    
	    SELECT @desc = 'There are outstanding hedging relationships approved by user ' + 
					   dbo.FNADBUser() + ' for as of date:' + dbo.FNADateFormat(GETDATE())
					   + '<br>' +
					   + dbo.FNATrmHyperlink(
						   'k',
						   10234500,
						   'Finalize Approved  Relationships',
						   'true',
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   DEFAULT,
						   @as_of_date_from,
						   @as_of_date_to
					   )
	    
	    EXEC spa_complete_compliance_activities 'c',
	         @functionid,
	         @xml,
	         @desc,
	         @successErrorFlag,
	         @source,
	         @id
	    
	    EXEC spa_get_outstanding_control_activities_job @getdate,
	         NULL,
	         @desc -- will post the message in the message board
	    
	    --remove approve message from message board				
	    DELETE 
	    FROM   message_board
	    WHERE  source_id IN (SELECT 'cmp-' + CAST(risk_control_activity_id AS VARCHAR)
	                         FROM   process_risk_controls_activities
	                         WHERE  source = 'HedgeRel.Approve'
	                                AND source_id NOT IN (SELECT ISNULL(process_id, '')
	                                                      FROM   
															gen_fas_link_header
	                                                      WHERE  gen_approved <> 'y'))			
	    
	    DELETE 
	    FROM   process_risk_controls_activities
	    WHERE  source = 'HedgeRel.Approve'
	           AND source_id NOT IN (SELECT ISNULL(process_id, '')
	                                 FROM   gen_fas_link_header
	                                 WHERE  gen_approved <> 'y')
	END
	ELSE 
	IF @functionid = 118 -- Trader deal insertion. This will flow the message to the mapped Trader.
	BEGIN
	    SELECT @source = 'Deal.Notification'							
	    SELECT @getdate = dbo.FNAGetSQLStandardDateTime(GETDATE())
	    
	    CREATE TABLE #table_deal_confirmation
	    (
	    	deal_id INT
	    )
	    
	    CREATE TABLE #open_deal_ticket
	    (
	    	deal_id INT
	    )
	    
	    CREATE TABLE #send_trader_notification
	    (
	    	risk_control_id  INT,
	    	inform_user      VARCHAR(100) COLLATE DATABASE_DEFAULT
	    )
	    
	    CREATE TABLE #dont_send_trader_notification
	    (
	    	risk_control_id  INT,
	    	inform_user      VARCHAR(100) COLLATE DATABASE_DEFAULT
	    )
	    	    
	    INSERT INTO #table_deal_confirmation(deal_id)
	    SELECT sdh.source_deal_header_id
	    FROM   source_deal_header sdh
			INNER JOIN (SELECT item FROM   dbo.splitcommaseperatedvalues(@id)) it
				ON  sdh.source_deal_header_id = it.Item
			INNER JOIN source_deal_header_template sdht
				ON  sdht.template_id = sdh.template_id
			INNER JOIN status_rule_header srh
				ON  srh.status_rule_id = sdht.confirm_rule
				AND srh.status_rule_type = 17200
			INNER JOIN status_rule_detail srd
				ON  srd.status_rule_id = srh.status_rule_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
				ON  scsv.item = srd.status_rule_detail_id
			INNER JOIN status_rule_activity sra
				ON  srd.status_rule_detail_id = sra.status_rule_detail_id
			LEFT JOIN process_functions_listing_detail pfld
				ON  pfld.listId = sra.workflow_activity_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.open_deal_confirmation = 'y'
	    
	    INSERT INTO #table_deal_confirmation(deal_id)
	    SELECT sdh.source_deal_header_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.deal_rules
	                AND srh.status_rule_type = 5600
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.open_deal_confirmation = 'y'
	    
	    INSERT INTO #open_deal_ticket(deal_id)
	    SELECT sdh.source_deal_header_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.confirm_rule
	                AND srh.status_rule_type = 17200
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.open_deal_ticket = 'y'
	    
	    INSERT INTO #open_deal_ticket(deal_id)
	    SELECT sdh.source_deal_header_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.deal_rules
	                AND srh.status_rule_type = 5600
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.open_deal_ticket = 'y'
	    
	    INSERT INTO #send_trader_notification(
	        risk_control_id,
	        inform_user
	      )
	    SELECT pfld.risk_control_id,
	           st.user_login_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM   dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.confirm_rule
	                AND srh.status_rule_type = 17200
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	           INNER JOIN source_traders st
	                ON  st.source_trader_id = sdh.trader_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.send_trader_notification = 'y'
	    
	    INSERT INTO #send_trader_notification
	      (
	        risk_control_id,
	        inform_user
	      )
	    SELECT pfld.risk_control_id,
	           st.user_login_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.deal_rules
	                AND srh.status_rule_type = 5600
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id)scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	           INNER JOIN source_traders st
	                ON  st.source_trader_id = sdh.trader_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.send_trader_notification = 'y'
	    
	    INSERT INTO #dont_send_trader_notification
	      (
	        risk_control_id,
	        inform_user
	      )
	    SELECT pfld.risk_control_id,
	           st.user_login_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM   dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.deal_rules
	                AND srh.status_rule_type = 5600
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	           INNER JOIN source_traders st
	                ON  st.source_trader_id = sdh.trader_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.send_trader_notification = 'n'
	    
	    INSERT INTO #dont_send_trader_notification
	      (
	        risk_control_id,
	        inform_user
	      )
	    SELECT pfld.risk_control_id,
	           st.user_login_id
	    FROM   source_deal_header sdh
	           INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@id)) it
	                ON  sdh.source_deal_header_id = it.Item
	           INNER JOIN source_deal_header_template sdht
	                ON  sdht.template_id = sdh.template_id
	           INNER JOIN status_rule_header srh
	                ON  srh.status_rule_id = sdht.confirm_rule
	                AND srh.status_rule_type = 17200
	           INNER JOIN status_rule_detail srd
	                ON  srd.status_rule_id = srh.status_rule_id
	           INNER JOIN dbo.SplitCommaSeperatedValues(@status_rule_detail_id) scsv
	                ON  scsv.item = srd.status_rule_detail_id
	           INNER JOIN status_rule_activity sra
	                ON  srd.status_rule_detail_id = sra.status_rule_detail_id
	           LEFT JOIN process_functions_listing_detail pfld
	                ON  pfld.listId = sra.workflow_activity_id
	           INNER JOIN source_traders st
	                ON  st.source_trader_id = sdh.trader_id
	    WHERE  srd.event_id IN (@event_id)
	           AND srd.send_trader_notification = 'n'
	    
	    IF EXISTS(
	           SELECT 'x'
	           FROM   #dont_send_trader_notification
	       )
	    BEGIN
	        DELETE prce
	        FROM   process_risk_controls_email prce
	               INNER JOIN #dont_send_trader_notification dstn
	                    ON  dstn.risk_control_id = prce.risk_control_id
	                    AND dstn.inform_user = prce.inform_user
	    END	
	    
	    IF EXISTS(
	           SELECT 'x'
	           FROM   #send_trader_notification
	       )
	    BEGIN
	        BEGIN TRY
	        	IF NOT EXISTS(
	        	       SELECT 'x'
	        	       FROM   process_risk_controls_email prce
	        	              INNER JOIN #send_trader_notification stn
	        	                   ON  prce.risk_control_id = stn.risk_control_id
	        	                   AND prce.inform_user = stn.inform_user
	        	   )
	        	BEGIN
	        	    INSERT INTO process_risk_controls_email
	        	      (
	        	        risk_control_id,
	        	        control_status,
	        	        inform_role,
	        	        communication_type,
	        	        no_of_days,
	        	        inform_user
	        	      )
	        	    SELECT risk_control_id,
	        	           732,
	        	           NULL,
	        	           751,
	        	           0,
	        	           inform_user
	        	    FROM   #send_trader_notification
	        	END
	        END TRY
	        BEGIN CATCH
	        END CATCH
	    END
	    
	    DECLARE idsList CURSOR  
	    FOR
	        SELECT item
	        FROM   dbo.splitCommaSeperatedValues(@id)
	    
	    OPEN idsList
	    FETCH NEXT FROM idsList INTO @id_tmp
	    WHILE @@FETCH_STATUS = 0
	    BEGIN
	        IF @actionType = 'r'
	        BEGIN
	            SELECT @ref_id = deal_id,
	                   @timeStamp = ISNULL(sdd.update_ts, sdd.create_ts)
	            FROM   delete_source_deal_header sdd
	            WHERE  source_deal_header_id = @id_tmp		
	            
	            SELECT @updateUser = ISNULL(user_title, ' ') + ISNULL(user_f_name, ' ')
	                   + ISNULL(user_m_name, ' ') + ISNULL(user_l_name, ' ')
	            FROM   delete_source_deal_header sdd
	                   INNER JOIN application_users
	                        ON  user_login_id = sdd.update_user
	            WHERE  source_deal_header_id = @id_tmp
	        END
	        ELSE
	        BEGIN
	            SELECT @ref_id = deal_id,
	                   @timeStamp = ISNULL(sdd.update_ts, sdd.create_ts)
	            FROM   source_deal_header sdd
	            WHERE  source_deal_header_id = @id_tmp		
	            
	            SELECT @updateUser = ISNULL(user_title, ' ') + ISNULL(user_f_name, ' ')
	                   + ISNULL(user_m_name, ' ') + ISNULL(user_l_name, ' ')
	            FROM   source_deal_header sdd
	                   INNER JOIN application_users
	                        ON  user_login_id = sdd.update_user
	            WHERE  source_deal_header_id = @id_tmp
	        END
	        
	        
	        SELECT @xml = '<root> <row ' + @functionName + '="5652"  ></row></root>'
	        
	        --SET @timeStamp = dbo.FNADateTimeFormat(@timeStamp,1)
	        --			SELECT @timeStamp_tmp =SUBSTRING(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)),1,LEN(SUBSTRING(CONVERT(VARCHAR,@timeStamp,100),12,LEN(@timeStamp)))-2)+' ' +RIGHT(@timeStamp,2)
	        SET @timeStamp_tmp = '<time>' + CAST(@timeStamp AS VARCHAR(50)) + '</time>'
	        
	        SELECT @deal_status = sdv.code
	        FROM   source_deal_header sdh
	               INNER JOIN static_data_value sdv
	                    ON  sdv.value_id = sdh.deal_status
	        WHERE  sdh.source_deal_header_id = @id_tmp
	        
	        SELECT @deal_status_from_code = sdv.code
	        FROM   static_data_value sdv
	        WHERE  sdv.value_id = @deal_status_from
	        
	        IF @actionType = 'd' OR @actionType = 'c'
	        BEGIN
	            SELECT @desc = CASE @actionType
	                                WHEN 'd' THEN 
	                                     'Deal Status has been changed from <span style ="color:blue">' 
	                                     + @deal_status_from_code + 
	                                     '</span> to <span style ="color:blue">' 
	                                     + @deal_status + ' </span>'
	                                WHEN 'c' THEN 
	                                     'confirm status has been changed'
	                           END + ' for Deal ID #' + dbo.FNATrmHyperlink(
									   'b',
									   10131010,
									   @id_tmp,
									   @id,
									   'n',
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT
							) + ' (' + @ref_id + ')' + ' by ' + @updateUser + ' at ' + 
						   CONVERT(VARCHAR, DATEPART(hh, GETDATE())) + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
						   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
						   + '.',
	                   @descForMail = CASE @actionType
	                                       WHEN 'd' THEN 
	                                            'Deal Status has been changed from ' 
	                                            + @deal_status_from_code + 
	                                            ' to ' + @deal_status
	                                       WHEN 'c' THEN 
	                                            'confirm status has been changed'
	                                  END + ' for Deal ID #' + dbo.FNATrmHyperlink(
									   'i',
									   10131010,
									   @id_tmp,
									   @id,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT,
									   DEFAULT
								   ) + ' (' + @ref_id + ')' + ' by ' + @updateUser + ' at ' + 
								   CONVERT(VARCHAR, DATEPART(hh, GETDATE())) + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
								   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2)
								   + '.'
	        END
	        ELSE
	        BEGIN
	            SELECT @desc = 'Deal ID # ' +
	                   CASE 
	                        WHEN @actionType = 'r' THEN dbo.FNATrmHyperlink(
	                                 'b',
	                                 10131010,
	                                 @id_tmp,
	                                 @id_tmp,
	                                 'y',
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT
	                             )
	                        ELSE dbo.FNATrmHyperlink(
	                                 'b',
	                                 10131010,
	                                 @id_tmp,
	                                 @id_tmp,
	                                 'n',
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT,
	                                 DEFAULT
	                             )
	                   END + ' (' + @ref_id + ')' + CASE @actionType
	                                                     WHEN 'i' THEN 
	                                                          ' has been created'
	                                                     WHEN 'u' THEN 
	                                                          ' has been updated'
	                                                     WHEN 'x' THEN 
	                                                          ' has been cancelled.'
	                                                     WHEN 'r' THEN 
	                                                          ' has been deleted.'
	                                                     WHEN 'd' THEN 
	                                                          ' deal status has been updated'
	                                                     WHEN 'c' THEN 
	                                                          ' confirmation status has been updated'
	                                                     WHEN 'f' THEN 
	                                                          ' deal ticket has been approved by front office'
	                                                     WHEN 'm' THEN 
	                                                          ' deal ticket has been approved by middle office'
	                                                     ELSE 
	                                                          ' deal ticket has been approved by back office'
	                                                END
	                   + ' by ' + @updateUser + ' at' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())) 
	                   + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
	                   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
	                   + '.'
	                   + CASE WHEN @actionType = 'i' THEN '' ELSE '<br>
	                   		<a target="_blank" href="./dev/spa_html.php?__user_name__=farrms_admin&spa=exec spa_Create_Deal_Audit_Report ''c'', NULL, NULL, NULL, '''+CONVERT(VARCHAR(20),GETDATE(),110)+''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '+CAST(@id_tmp AS VARCHAR(10))+ ', NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,NULL,NULL,NULL,NULL,'''+CONVERT(VARCHAR(20),GETDATE(),120)+'''">
	                   		View Deal Audit Log Report</a>
	                   		&nbsp;&nbsp;&nbsp;'	
	                     END
	                   --+'<br>'+ dbo.FNATrmHyperlink('i',10131010,'Review Deal',@id,default,default,default,default,default,default,default,default,default,default,default)
	                   --+'&nbsp;&nbsp;&nbsp;'+dbo.FNATrmHyperlink('i',10131020,'Sign off on Trade Ticket',@id_tmp,default,default,default,default,default,default,default,default,default,default,default)
	                   ,
	                   @descForMail = 'Deal ID # ' + CAST(@id_tmp AS VARCHAR) + ' (' + @ref_id + ') ' + 
										CASE @actionType
                                            WHEN 'i' THEN 
                                                 ' has been created'
                                            WHEN 'u' THEN 
                                                 ' has been updated'
                                            WHEN 'x' THEN 
                                                 ' has been cancelled.'
                                            WHEN 'd' THEN 
                                                 ' deal status has been updated'
                                            WHEN 'c' THEN 
                                                 ' confirmation status has been updated'
                                            WHEN 'f' THEN 
                                                 ' deal ticket has been approved by front office'
                                            WHEN 'm' THEN 
                                                 ' deal ticket has been approved by middle office'
                                            ELSE 
                                                 ' deal ticket has been approved by back office'
                                       END
									   + ' by ' + @updateUser + ' at ' + CONVERT(VARCHAR, DATEPART(hh, GETDATE())) 
									   + ':' + RIGHT('0' + CONVERT(VARCHAR, DATEPART(mi, GETDATE())), 2) 
									   + ' ' + SUBSTRING(CONVERT(VARCHAR(19), GETDATE(), 100), 18, 2) 
									   + '.'
	        END 
	        
	        IF @deal_status_message = 1
	        BEGIN
	            SET @descForMail = @descForMail --+ 'Deal status has been changed from Validated to Amended for ' +CAST(@id_tmp AS VARCHAR)+' ('+@ref_id+')'
	            SET @desc = @desc --+ ' Deal status has been changed from <span style ="color:blue"> Validated </span> to <span style ="color:blue">Amended</span> for ' +CAST(@id_tmp AS VARCHAR)+' ('+@ref_id+')'
	        END
	        
	        IF EXISTS(
	               SELECT 'x'
	               FROM   #table_deal_confirmation
	           )
	            SET @desc = ISNULL(@desc, '') + '<br>' + dbo.FNATrmHyperlink(
								'b',
								10171016,
								'Deal Confirmation',
								@id_tmp,
								'y',
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT
							)
	        
	        IF EXISTS(
	               SELECT 'x'
	               FROM   #open_deal_ticket
	           )
	            SET @desc = ISNULL(@desc, '') + '&nbsp;&nbsp;&nbsp;&nbsp;' + dbo.FNATrmHyperlink(
								'b',
								10131020,
								'Deal Ticket',
								@id_tmp,
								'y',
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT,
								DEFAULT
							)
	        
	        EXEC spa_complete_compliance_activities 'c',
	             @functionid,
	             @xml,
	             @desc,
	             'c',
	             @source,
	             @id_tmp,
	             NULL,
	             @activity_id,
	             @risk_control_activity_id = @risk_control_activity_id OUTPUT
	        --SELECT 'EXEC spa_complete_compliance_activities', 'c',@functionid,@xml,@desc,'c',@source,@id_tmp,NULL,@activity_id,@risk_control_activity_id
	        
	        
	        IF @deal_status_message = 1
	        BEGIN
	            DECLARE @fname            VARCHAR(100),
	                    @risk_control_id  INT 
	            
	            SELECT @risk_control_id = risk_control_id
	            FROM   process_risk_controls_activities
	            WHERE  risk_control_activity_id = @risk_control_activity_id
	            
	            SELECT @fname = ISNULL(@fname, '') +
								CASE 
									WHEN @fname IS NOT NULL THEN ','
									ELSE ''
                                 END + au.user_f_name
	            FROM   process_risk_controls_email prce
	                   INNER JOIN application_users AU
	                        ON  prce.inform_user = au.user_login_id
	            WHERE  prce.risk_control_id = @risk_control_id
	                   AND prce.communication_type IN (752, 750)
	            
	            SET @descForMail = @fname + '<br><br>' + @descForMail + '<br><br>' + 'Thanks'
	        END 
	        
	        EXEC spa_get_outstanding_control_activities_job @getdate,
	             @activity_id,
	             NULL,
	             @descForMail,
	             @id_tmp,
	             @risk_control_activity_id --
	        
	        
	        FETCH NEXT FROM idsList INTO @id_tmp
	    END
	    CLOSE idsList
	    DEALLOCATE idsList
	END
END
