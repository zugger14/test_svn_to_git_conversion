-- Proxy Curve 3
IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name   
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'source_price_curve_def'
        AND ccu.COLUMN_NAME = 'proxy_curve_id3'
)
BEGIN
	ALTER TABLE dbo.source_price_curve_def WITH NOCHECK
	ADD CONSTRAINT FK_source_price_curve_def_proxy_curve_id3_source_curve_def_id
	FOREIGN KEY(proxy_curve_id3)
	REFERENCES dbo.source_price_curve_def (source_curve_def_id)
END

-- Settlement Curve
IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name   
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'source_price_curve_def'
        AND ccu.COLUMN_NAME = 'settlement_curve_id'
)
BEGIN
    ALTER TABLE dbo.source_price_curve_def WITH NOCHECK
	ADD CONSTRAINT FK_source_price_curve_def_settlement_curve_id_source_curve_def_id
	FOREIGN KEY(settlement_curve_id)
	REFERENCES dbo.source_price_curve_def (source_curve_def_id)
END

-- Reporting Curves
IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name   
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'source_price_curve_def'
        AND ccu.COLUMN_NAME = 'proxy_curve_id'
)
BEGIN
	ALTER TABLE dbo.source_price_curve_def WITH NOCHECK
	ADD CONSTRAINT FK_source_price_curve_def_proxy_curve_id_source_curve_def_id
	FOREIGN KEY(proxy_curve_id)
	REFERENCES dbo.source_price_curve_def (source_curve_def_id)
END

GO