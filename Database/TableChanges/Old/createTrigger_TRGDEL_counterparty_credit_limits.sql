SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TRGDEL_counterparty_credit_limits]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_counterparty_credit_limits]
GO
-- ===============================================================================================================
-- Author: sbohara@pioneersolutionsglobal.com
-- Create date: 2016-01-11
-- Description: Trigger while deleting data from counterparty_credit_limits
-- ===============================================================================================================

CREATE TRIGGER [dbo].[TRGDEL_counterparty_credit_limits]
ON [dbo].[counterparty_credit_limits]
FOR  DELETE
AS
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
		dbo.FNADBUser(),
		CURRENT_TIMESTAMP,
		'd'
		FROM deleted	
GO
