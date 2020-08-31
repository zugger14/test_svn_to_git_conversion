--insert
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name] = 'TRGINS_SOURCE_PRICE_CURVE')
	DROP TRIGGER TRGINS_SOURCE_PRICE_CURVE
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_PRICE_CURVE]
ON [dbo].[source_price_curve]
FOR INSERT
AS
INSERT INTO source_price_curve_audit(source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, user_action)
SELECT   source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, 'insert'
FROM INSERTED                  

GO
--update
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name] = 'TRGUPD_SOURCE_PRICE_CURVE')
	DROP TRIGGER TRGUPD_SOURCE_PRICE_CURVE
GO

CREATE TRIGGER [dbo].[TRGUPD_source_price_curve]
ON [dbo].[source_price_curve]
FOR UPDATE
AS

INSERT INTO source_price_curve_audit(source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, user_action)
SELECT   source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, 'update' 
FROM INSERTED     

GO
--delete
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name] = 'TRGDEL_SOURCE_PRICE_CURVE')
	DROP TRIGGER TRGDEL_SOURCE_PRICE_CURVE
GO

CREATE TRIGGER [dbo].[TRGDEL_source_price_curve]
ON [dbo].[source_price_curve]
FOR DELETE
AS
INSERT INTO source_price_curve_audit(source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, user_action)
SELECT   source_curve_def_id, as_of_date,
            Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
            curve_value, bid_value, ask_value, is_dst, 'delete' 
FROM DELETED  


GO


