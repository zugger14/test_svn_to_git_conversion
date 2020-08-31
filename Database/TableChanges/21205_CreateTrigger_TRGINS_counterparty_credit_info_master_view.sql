SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_info_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_credit_info_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_info_master_view] ON [dbo].[counterparty_credit_info]
AFTER INSERT, UPDATE
AS
	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END
	IF EXISTS (SELECT 1 FROM deleted ) 
		AND EXISTS (
		SELECT TOP 1
			1
		FROM master_view_counterparty_credit_info AS m
		INNER JOIN inserted AS i ON i.counterparty_credit_info_id = m.counterparty_credit_info_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			mvcc.counterparty_credit_info_id = cc.counterparty_credit_info_id,
			mvcc.Counterparty_id = sc.counterparty_name,
			mvcc.account_status = sdv.code,
			mvcc.limit_expiration = cc.limit_expiration,
			mvcc.curreny_code = sc2.currency_name,
			mvcc.Industry_type1 = sdv2.code,
			mvcc.Industry_type2 = sdv3.code,
			mvcc.SIC_Code = sdv4.code,
			mvcc.Duns_No = cc.Duns_No,
			mvcc.Risk_rating = sdv5.code,
			mvcc.Debt_rating = sdv6.code,
			mvcc.Ticker_symbol = cc.Ticker_symbol,
			mvcc.Date_established = CONVERT(VARCHAR(10), cc.Date_established, 120),
			mvcc.Next_review_date = CONVERT(VARCHAR(10), cc.Next_review_date, 120),
			mvcc.Last_review_date = CONVERT(VARCHAR(10), cc.Last_review_date, 120),
			mvcc.Customer_since = CONVERT(VARCHAR(10), cc.Customer_since, 120),
			mvcc.Approved_by = cc.Approved_by,
			mvcc.Settlement_contact_name = cc.Settlement_contact_name,
			mvcc.Settlement_contact_address = cc.Settlement_contact_address,
			mvcc.Settlement_contact_address2 = cc.Settlement_contact_address2,
			mvcc.Settlement_contact_phone = cc.Settlement_contact_phone,
			mvcc.Settlement_contact_email = cc.Settlement_contact_email,
			mvcc.payment_contact_name = cc.payment_contact_name,
			mvcc.payment_contact_address = cc.payment_contact_address,
			mvcc.contactfax = cc.contactfax,
			mvcc.payment_contact_phone = cc.payment_contact_phone,
			mvcc.payment_contact_email = cc.payment_contact_email,
			mvcc.Debt_Rating2 = sdv7.code,
			mvcc.Debt_Rating3 = sdv8.code,
			mvcc.Debt_Rating4 = sdv9.code,
			mvcc.Debt_Rating5 = sdv10.code,
			mvcc.payment_contact_address2 = cc.payment_contact_address2,
			mvcc.analyst = cc.analyst,
			mvcc.rating_outlook = sdv11.code
		FROM [master_view_counterparty_credit_info] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_credit_info_id] = [mvcc].[counterparty_credit_info_id]
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[counterparty_id]
		LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.curreny_code
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.account_status
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.Industry_type1
		LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cc.Industry_type2
		LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cc.SIC_Code
		LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cc.Risk_rating
		LEFT JOIN static_data_value sdv6 ON sdv6.value_id = cc.Debt_rating
		LEFT JOIN static_data_value sdv7 ON sdv7.value_id = cc.Debt_rating2
		LEFT JOIN static_data_value sdv8 ON sdv8.value_id = cc.Debt_rating3
		LEFT JOIN static_data_value sdv9 ON sdv9.value_id = cc.Debt_rating4
		LEFT JOIN static_data_value sdv10 ON sdv10.value_id = cc.Debt_rating5
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = cc.rating_outlook

	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_credit_info (
			counterparty_credit_info_id,
			Counterparty_id,
			account_status,
			limit_expiration,
			curreny_code,
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
			payment_contact_address2,
			analyst,
			rating_outlook
		)
		SELECT
			cc.counterparty_credit_info_id,
			sc.counterparty_name,
			sdv.code,
			cc.limit_expiration,
			sc2.currency_name,
			sdv2.code,
			sdv3.code,
			sdv4.code,
			cc.Duns_No,
			sdv5.code,
			sdv6.code,
			cc.Ticker_symbol,
			CONVERT(VARCHAR(10), cc.Date_established, 120),
			CONVERT(VARCHAR(10), cc.Next_review_date, 120),
			CONVERT(VARCHAR(10), cc.Last_review_date, 120),
			CONVERT(VARCHAR(10), cc.Customer_since, 120),
			cc.Approved_by,
			cc.Settlement_contact_name,
			cc.Settlement_contact_address,
			cc.Settlement_contact_address2,
			cc.Settlement_contact_phone,
			cc.Settlement_contact_email,
			cc.payment_contact_name,
			cc.payment_contact_address,
			cc.contactfax,
			cc.payment_contact_phone,
			cc.payment_contact_email,
			sdv7.code,
			sdv8.code,
			sdv9.code,
			sdv10.code,
			cc.payment_contact_address2,
			cc.analyst,
			sdv11.code
		FROM inserted AS cc
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[counterparty_id]
		LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.curreny_code
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.account_status
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.Industry_type1
		LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cc.Industry_type2
		LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cc.SIC_Code
		LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cc.Risk_rating
		LEFT JOIN static_data_value sdv6 ON sdv6.value_id = cc.Debt_rating
		LEFT JOIN static_data_value sdv7 ON sdv7.value_id = cc.Debt_rating2
		LEFT JOIN static_data_value sdv8 ON sdv8.value_id = cc.Debt_rating3
		LEFT JOIN static_data_value sdv9 ON sdv9.value_id = cc.Debt_rating4
		LEFT JOIN static_data_value sdv10 ON sdv10.value_id = cc.Debt_rating5
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = cc.rating_outlook
	END
GO