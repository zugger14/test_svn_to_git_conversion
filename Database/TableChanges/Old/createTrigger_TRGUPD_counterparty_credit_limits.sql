SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_counterparty_credit_limits]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterparty_credit_limits]
GO
-- ===============================================================================================================
-- Author: sbohara@pioneersolutionsglobal.com
-- Create date: 2016-01-11
-- Description: Trigger while updating data in counterparty_credit_limits
-- ===============================================================================================================


CREATE TRIGGER [dbo].[TRGUPD_counterparty_credit_limits]
	ON [dbo].[counterparty_credit_limits]
FOR UPDATE
AS  
	DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.counterparty_credit_limits
	SET    update_user = @update_user,
		   update_ts = @update_ts
	FROM   dbo.counterparty_credit_limits cci
	INNER JOIN DELETED u ON  cci.counterparty_credit_limit_id = u.counterparty_credit_limit_id
      
	INSERT INTO counterparty_credit_limits_audit (
		counterparty_credit_limit_id,
		effective_Date,
		credit_limit,
		credit_limit_to_us,
		tenor_limit,
		max_threshold,
		min_threshold,
		counterparty_id,
		internal_counterparty_id,
		contract_id,
		currency_id,
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	)
	SELECT 
		counterparty_credit_limit_id,
		effective_Date,
		credit_limit,
		credit_limit_to_us,
		tenor_limit,
		max_threshold,
		min_threshold,
		counterparty_id,
		internal_counterparty_id,
		contract_id,
		currency_id,
		create_user,
		create_ts,
		update_user,
		update_ts,
		'u'
	FROM INSERTED	
GO        