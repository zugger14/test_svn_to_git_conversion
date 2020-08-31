SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_enhancements]'))
    DROP TRIGGER [dbo].[TRGINS_counterparty_credit_enhancements]
GO
-- insert trigger 
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_enhancements]
ON [dbo].[counterparty_credit_enhancements]
FOR INSERT
AS
BEGIN
	INSERT INTO counterparty_credit_enhancements_audit
	  (
			counterparty_credit_enhancement_id
			,counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,update_user
			,update_ts
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked
			,user_action
	  )
	SELECT counterparty_credit_enhancement_id
			,counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,update_user
			,update_ts
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked 
	        ,'insert'
	FROM   INSERTED
END

GO
--update trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_credit_enhancements]'))
    DROP TRIGGER [dbo].[TRGUPD_counterparty_credit_enhancements]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_credit_enhancements]
ON [dbo].[counterparty_credit_enhancements]
FOR UPDATE
AS
BEGIN
	IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE counterparty_credit_enhancements
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM counterparty_credit_enhancements t
		INNER JOIN DELETED u ON t.counterparty_credit_enhancement_id = u.counterparty_credit_enhancement_id
	END

	INSERT INTO counterparty_credit_enhancements_audit
	  (
			counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,update_user
			,update_ts
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked
			,user_action                  
	  )
	SELECT counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,update_user
			,update_ts
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked
	        ,'update'
	FROM   INSERTED
END

GO
-- delete trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_counterparty_credit_enhancements]'))
    DROP TRIGGER [dbo].[TRGDEL_counterparty_credit_enhancements]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_counterparty_credit_enhancements]
ON [dbo].[counterparty_credit_enhancements]
FOR DELETE
AS
BEGIN
	INSERT INTO counterparty_credit_enhancements_audit
	  (
			counterparty_credit_enhancement_id
			,counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,update_user
			,update_ts
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked
			,user_action                   
	  )
	SELECT counterparty_credit_enhancement_id
			,counterparty_credit_info_id
			,enhance_type
			,guarantee_counterparty
			,comment
			,amount
			,currency_code
			,eff_date
			,margin
			,rely_self
			,approved_by
			,expiration_date
			,create_user
			,create_ts
			,dbo.FNADBUser()
			,CURRENT_TIMESTAMP
			,exclude_collateral
			,contract_id
			,internal_counterparty
			,deal_id
			,auto_renewal
			,transferred
			,is_primary
			,collateral_status
			,blocked
	       ,'delete'
	FROM   DELETED
END