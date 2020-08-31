SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_credit_limits_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].counterparty_credit_limits_audit(
	audit_id INT IDENTITY(1,1),
	counterparty_credit_limit_id INT NOT NULL,
	effective_Date DATE NULL,
	credit_limit FLOAT NULL,
	credit_limit_to_us FLOAT NULL,
	tenor_limit INT NULL,
	max_threshold FLOAT NULL,
	min_threshold FLOAT NULL,
	counterparty_id INT NULL,
	INTernal_counterparty_id INT NULL,
	contract_id INT NULL,
	currency_id INT NULL,
	create_user VARCHAR(50) NULL,
	create_ts DATETIME NULL,
	update_user VARCHAR(50) NULL,
	update_ts DATETIME NULL,
	user_action CHAR NOT NULL
 ) 
END
GO


