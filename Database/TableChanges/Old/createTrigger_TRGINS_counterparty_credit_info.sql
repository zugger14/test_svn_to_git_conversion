IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_info]'))
    DROP TRIGGER [dbo].[TRGINS_counterparty_credit_info]
GO
 
SET ANSI_NULLS ON
GO
-- ===============================================================================================================
-- Author: pamatya@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified date: 2014-01-07
-- Description: Trigger during insertion of data in counterparty_credit_info
-- Params:
--  
-- ===============================================================================================================
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_info]
ON [dbo].[counterparty_credit_info]
FOR INSERT
AS
BEGIN
	INSERT INTO counterparty_credit_info_audit (
		counterparty_credit_info_id,
		Counterparty_id,
		account_status,
		limit_expiration,
		credit_limit,
		curreny_code,
		Tenor_limit,
		Industry_type1,
		Industry_type2,
		SIC_Code,
		Duns_No,
		Risk_rating,
		Debt_rating,
		Ticker_symbol,
		Date_established,
		Next_review_date,
		Last_review_date,
		Customer_since,
		Approved_by,
		Watch_list,
		Settlement_contact_name,
		Settlement_contact_address,
		Settlement_contact_address2,
		Settlement_contact_phone,
		Settlement_contact_email,
		payment_contact_name,
		payment_contact_address,
		contactfax,
		payment_contact_phone,
		payment_contact_email,
		Debt_Rating2,
		Debt_Rating3,
		Debt_Rating4,
		Debt_Rating5,
		credit_limit_from,
		payment_contact_address2,
		max_threshold,
		min_threshold,
		check_apply,
		cva_data,
		pfe_criteria,
		create_user,
		create_ts,
		update_user,
		update_ts,
		exclude_exposure_after,
		user_action
	) 
	Select 
		counterparty_credit_info_id,
		Counterparty_id,
		account_status,
		limit_expiration,
		credit_limit,
		curreny_code,
		Tenor_limit,
		Industry_type1,
		Industry_type2,
		SIC_Code,
		Duns_No,
		Risk_rating,
		Debt_rating,
		Ticker_symbol,
		Date_established,
		Next_review_date,
		Last_review_date,
		Customer_since,
		Approved_by,
		Watch_list,
		Settlement_contact_name,
		Settlement_contact_address,
		Settlement_contact_address2,
		Settlement_contact_phone,
		Settlement_contact_email,
		payment_contact_name,
		payment_contact_address,
		contactfax,
		payment_contact_phone,
		payment_contact_email,
		Debt_Rating2,
		Debt_Rating3,
		Debt_Rating4,
		Debt_Rating5,
		credit_limit_from,
		payment_contact_address2,
		max_threshold,
		min_threshold,
		check_apply,
		cva_data,
		pfe_criteria,
		create_user,
		create_ts,
		update_user,
		update_ts,
		exclude_exposure_after,
		'i'
		FROM INSERTED
	
END
GO

