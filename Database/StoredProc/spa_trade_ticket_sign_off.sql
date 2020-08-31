IF OBJECT_ID('[dbo].[spa_trade_ticket_sign_off]', 'p') IS NOT NULL 
    DROP PROC [dbo].[spa_trade_ticket_sign_off]
GO

CREATE PROC [dbo].[spa_trade_ticket_sign_off]
    @flag CHAR(1),
    @source_deal_header_id INT 
AS 

DECLARE @process_id                VARCHAR(150),
        @job_name                  VARCHAR(150),
        @spa                       VARCHAR(500),
        @user_login_id             VARCHAR(200),
        @run_job                   INT,
        @change_deal_status_to     INT,
        @change_confirm_status_to  INT,
        @called_rule               INT 

SET @called_rule = 0

SET NOCOUNT ON

IF @flag = 'a' -- Used in Trade Ticket window
BEGIN
    SELECT st.user_login_id,
           sdh.verified_date,
           sdh.verified_by,
           sdh.risk_sign_off_date,
           sdh.risk_sign_off_by,
           sdh.back_office_sign_off_date,
           sdh.back_office_sign_off_by,
           sdht.deal_rules,
           sdht.confirm_rule,
		   sdht.trade_ticket_template_id  -- Get template id
    FROM   source_deal_header sdh
           INNER JOIN source_traders st ON  st.source_trader_id = sdh.trader_id
           LEFT JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id
    WHERE  sdh.source_deal_header_id = @source_deal_header_id
END

IF @flag = 'b' -- Back Office Sign Off
BEGIN
    UPDATE source_deal_header
    SET    back_office_sign_off_by = dbo.FNADBUser(),
           back_office_sign_off_date = GETDATE(),
           update_user = dbo.FNADBUser()
    WHERE  source_deal_header_id = @source_deal_header_id
    
    --SET @process_id = REPLACE(NEWID(), '-', '_')
    
    --SET @user_login_id = dbo.FNADBUser()
    
    --SET @spa = ''
    
    --exec spa_compliance_workflow 109,'b',@source_deal_header_id,'Deal',NULL
    --EXEC spa_compliance_workflow 112, 'b', @source_deal_header_id
    --EXEC spa_compliance_workflow 111, 'b', @source_deal_header_id, null, null  -- Back Office Messaging
    
    IF @@ERROR <> 0
    BEGIN
        EXEC spa_ErrorHandler @@ERROR,
             'Failed Verifying the Trade Ticket',
             'spa_trade_ticket_sign_off',
             'DB Error',
             'Failed Verifying the Trade Ticket',
             'Failed Verifying the Trade Ticket'
    END
    ELSE
    BEGIN
        EXEC spa_ErrorHandler 0,
             'Source Deal Header table',
             'spa_trade_ticket_sign_off',
             'Success',
             'Trade Ticket Verified',
             ''
    END
END
IF @flag = 'r' -- Risk Sign Off
BEGIN
    UPDATE source_deal_header
    SET    risk_sign_off_by = dbo.FNADBUser(),
           risk_sign_off_date = GETDATE(),
           update_user = dbo.FNADBUser()
    WHERE  source_deal_header_id = @source_deal_header_id
    
    --EXEC spa_compliance_workflow 2, NULL, @source_deal_header_id, NULL, NULL
    
    --SET @process_id = REPLACE(NEWID(), '-', '_')
    
    --SET @user_login_id = dbo.FNADBUser()
    
    --SET @spa = ''
    
    --exec spa_compliance_workflow 109,'m',@source_deal_header_id,'Deal',NULL
    -- EXEC spa_compliance_workflow 112, 'm', @source_deal_header_id
    --EXEC spa_compliance_workflow 111, 'm', @source_deal_header_id, null, null  -- Back Office Messaging
    
    IF @@ERROR <> 0
    BEGIN
        EXEC spa_ErrorHandler @@ERROR,
             'Failed Verifying the Trade Ticket',
             'spa_trade_ticket_sign_off',
             'DB Error',
             'Failed Verifying the Trade Ticket',
             'Failed Verifying the Trade Ticket'
    END
    ELSE
    BEGIN
        EXEC spa_ErrorHandler 0,
             'Source Deal Header table',
             'spa_trade_ticket_sign_off',
             'Success',
             'Trade Ticket Verified',
             ''
    END
END
IF @flag = 't' -- Trader Sign Off
BEGIN
    --EXEC spa_compliance_workflow 111,'i',@source_deal_header_id,null,null  -- Back Office Messaging
    
    --EXEC spa_compliance_workflow 110,'i',@source_deal_header_id,null,null  -- Mid Office Messaging
    
    --EXEC spa_compliance_workflow 110, 'f', @source_deal_header_id, null, null  -- Mid Office Messaging
    --SET @process_id = REPLACE(NEWID(), '-', '_')
    
    --SET @user_login_id = dbo.FNADBUser()
    
    --SET @spa = ''
    
    --exec spa_compliance_workflow 109,'f',@source_deal_header_id,'Deal',NULL
  --  EXEC spa_compliance_workflow 112, 'f', @source_deal_header_id
    
     
    UPDATE source_deal_header
    SET    verified_by = dbo.FNADBUser(),
           verified_date = GETDATE(),
           update_user = dbo.FNADBUser()
    WHERE  source_deal_header_id = @source_deal_header_id
    
    
    IF @@ERROR <> 0
    BEGIN
        EXEC spa_ErrorHandler @@ERROR,
             'Failed Verifying the Trade Ticket',
             'spa_trade_ticket_sign_off',
             'DB Error',
             'Failed Verifying the Trade Ticket',
             'Failed Verifying the Trade Ticket'
    END
    ELSE
    BEGIN
        EXEC spa_ErrorHandler 0,
             'Source Deal Header table',
             'spa_trade_ticket_sign_off',
             'Success',
             'Trade Ticket Verified',
             ''
    END
END