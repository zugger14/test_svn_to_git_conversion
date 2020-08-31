IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_limits]'))
    DROP TRIGGER [dbo].[TRGINS_counterparty_credit_limits]
GO
 
SET ANSI_NULLS ON
GO
-- ===============================================================================================================
-- Author: sbohara@pioneersolutionsglobal.com
-- Create date: 2016-01-11
-- Description: Trigger while inserting data in counterparty_credit_limits
-- ===============================================================================================================

SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_limits]
ON [dbo].[counterparty_credit_limits]
FOR INSERT
AS
BEGIN
	
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
	Select 
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
		'i'
		FROM INSERTED
END
GO

