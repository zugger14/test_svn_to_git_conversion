--header
UPDATE maintain_field_deal 
SET insert_required = 'n'
	, update_required = 'n' 
	, system_required = 'y'
WHERE header_detail = 'h'
	AND farrms_field_id = 'source_system_id'

UPDATE maintain_field_deal 
SET insert_required = 'n'
	, update_required = 'y' 
	, system_required = 'n'
WHERE header_detail = 'h'
	AND farrms_field_id = 'fas_deal_type_value_id'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
	, system_required = 'y'
WHERE header_detail = 'h'
	AND farrms_field_id = 'commodity_id'

UPDATE maintain_field_deal 
SET insert_required = 'n'
	, update_required = 'y' 
	, system_required = 'n'
WHERE header_detail = 'h'
	AND farrms_field_id = 'Confirm_status_type'


--detail
UPDATE maintain_field_deal 
SET insert_required = 'n'
	, update_required = 'n' 
	, system_required = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'fixed_float_leg'

UPDATE maintain_field_deal 
SET insert_required = 'n'
	, update_required = 'n' 
	, system_required = 'n'
WHERE header_detail = 'd'
	AND farrms_field_id = 'buy_sell_flag'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
	, system_required = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'curve_id'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
	, system_required = 'y'
WHERE header_detail = 'd'
	AND farrms_field_id = 'deal_volume_uom_id'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
	, system_required = 'n'
WHERE header_detail = 'd'
	AND farrms_field_id = 'physical_financial_flag'

UPDATE maintain_field_deal 
SET insert_required = 'y'
	, update_required = 'y' 
	, system_required = 'n'
WHERE header_detail = 'd'
	AND farrms_field_id = 'fixed_price_currency_id'

GO

DROP TABLE IF EXISTS #fields

CREATE TABLE #fields (
	[farrms_field_id] VARCHAR(100) COLLATE DATABASE_DEFAULT
	, [system_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [header_detail] CHAR(1) COLLATE DATABASE_DEFAULT
	, [insert_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [update_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [field_id] INT
)

-- Store field template properties as defined in excel
INSERT INTO #fields (
	[farrms_field_id]
	, [system_required]
	, [header_detail]
	, [insert_required]
	, [update_required]
	, [field_id]
)
VALUES 
	--headers
	('source_system_id', 'y', 'h', 'n', 'n', 5)
	, ('fas_deal_type_value_id', 'n', 'h', 'n', 'y', 207)
	, ('commodity_id', 'y', 'h', 'y', 'y', 56)
	, ('Confirm_status_type', 'n', 'h', 'n', 'y', 79)
	

	--details
	, ('fixed_float_leg', 'y', 'd', 'n', 'n', 86)
	, ('buy_sell_flag', 'n', 'd', 'n', 'n', 87)
	, ('curve_id', 'y', 'd', 'y', 'y', 88)
	, ('deal_volume_uom_id', 'y', 'd', 'y', 'y', 94)
	, ('physical_financial_flag', 'n', 'd', 'y', 'y', 111)
	, ('fixed_price_currency_id', 'n', 'd', 'y', 'y', 90)


-- Update maintain_field_deal according to values defined in excel
UPDATE mfd SET mfd.insert_required = t.insert_required
	, mfd.update_required = t.update_required
	, mfd.system_required = IIF(mfd.system_required = 'y', mfd.system_required, t.system_required)
FROM #fields t
INNER JOIN maintain_field_deal mfd
	ON t.field_id = mfd.field_id


--Update field_template_details as defined in excel
UPDATE mftd 
SET mftd.insert_required = f.insert_required
	, mftd.update_required = f.update_required
FROM #fields f
INNER JOIN maintain_field_template_detail mftd
	ON f.field_id = mftd.field_id


DROP TABLE IF EXISTS #fields_template_id

CREATE TABLE #fields_template_id (
	[farrms_field_id] VARCHAR(100) COLLATE DATABASE_DEFAULT
	, [system_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [header_detail] CHAR(1) COLLATE DATABASE_DEFAULT
	, [insert_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [update_required] CHAR(1) COLLATE DATABASE_DEFAULT
	, [field_id] INT
	, [field_template_id] INT
)

INSERT INTO #fields_template_id (
	[farrms_field_id]
	, [system_required]
	, [header_detail]
	, [insert_required]
	, [update_required]
	, [field_id]
	, [field_template_id]
)
SELECT fs.*
	, a.[field_template_id]
FROM #fields fs
CROSS JOIN (
	SELECT DISTINCT mft.field_template_id
	FROM maintain_field_template mft
	INNER JOIN maintain_field_template_detail mftd
		ON mft.field_template_id = mftd.field_template_id
) a
WHERE system_required = 'y'


-- Insert missing field_details that are marked in excel as system required in insert mode but unavailable in existing template.
INSERT INTO maintain_field_template_detail (
	field_id
	, field_template_id
	, udf_or_system
	, field_group_id
	, field_caption
	, seq_no
	, insert_required
	, update_required
)
SELECT f.field_id [field_id]
	, f.field_template_id [field_template_id]
	, 's' [udf_or_system]
	, mftg.field_group_id [field_group_id]
	, mfd.default_label [field_caption]
	, ROW_NUMBER() OVER(PARTITION BY f.field_template_id ORDER BY f.field_id ASC) * -1 [seq_no]
	, f.insert_required [insert_required]
	, f.update_required [update_required]
FROM #fields_template_id f
LEFT JOIN maintain_field_template_detail mftd
	ON f.field_id = mftd.field_id
		AND f.field_template_id = mftd.field_template_id
		AND mftd.udf_or_system = 's'
OUTER APPLY (
	SELECT TOP 1 seq_no, g.field_group_id
	FROM maintain_field_template_group g
	WHERE g.field_template_id = f.field_template_id
	ORDER BY seq_no 
) mftg
OUTER APPLY (
	SELECT TOP 1 seq_no
	FROM maintain_field_template_detail d
	where d.field_template_id = f.field_template_id
		AND d.field_group_id = mftg.field_group_id
	ORDER BY seq_no 
) ftd
INNER JOIN maintain_field_deal mfd
	ON mfd.field_id = f.field_id
WHERE f.system_required = 'y'
	AND mftd.field_id IS NULL
ORDER BY f.field_template_id
