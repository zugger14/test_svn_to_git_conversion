IF COL_LENGTH('ixp_source_counterparty_template', 'counterparty_address3') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'ixp_source_counterparty_template.[counterparty_address3]' , 'zip', 'COLUMN'
END
GO

IF COL_LENGTH('ixp_source_counterparty_template', 'counterparty_address4') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'ixp_source_counterparty_template.[counterparty_address4]' , 'city', 'COLUMN'
END
GO