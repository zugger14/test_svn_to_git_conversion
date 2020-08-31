
IF COL_LENGTH('maintain_field_deal', 'is_hidden') IS NULL
BEGIN
	ALTER TABLE maintain_field_deal ADD is_hidden CHAR
	PRINT 'Column maintain_field_deal.is_hidden added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_field_deal.is_hidden already exists.'
END
GO

IF COL_LENGTH('maintain_field_deal', 'insert_required') IS NULL
BEGIN
	ALTER TABLE maintain_field_deal ADD insert_required CHAR
	PRINT 'Column maintain_field_deal.insert_required added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_field_deal.insert_required already exists.'
END
GO

IF COL_LENGTH('maintain_field_deal', 'default_value') IS NULL
BEGIN
	ALTER TABLE maintain_field_deal ADD default_value VARCHAR(200)
	PRINT 'Column maintain_field_deal.default_value added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_field_deal.default_value already exists.'
END
GO


UPDATE mfd
SET
	is_hidden = 'y'
FROM maintain_field_deal mfd

UPDATE mfd
SET
	is_hidden = 'n'
FROM maintain_field_deal mfd
WHERE 
field_id IN (4,6,7,11,18,27,30,48,49,50,51,58,69,79,19,20,21,22)
AND mfd.header_detail = 'h'

UPDATE mfd
SET
	is_hidden = 'n'
FROM maintain_field_deal mfd
WHERE 
field_id IN (87,88,92,85,114,117,89,90,118,97,111,128,82,83,93,94)
AND mfd.header_detail = 'd'

UPDATE mfd
SET
	insert_required = 'n'
FROM maintain_field_deal mfd

UPDATE mfd
SET
	insert_required = 'y'
FROM maintain_field_deal mfd
WHERE mfd.field_id IN (4, 7,11, 6, 27, 87,88,92,85,114,117,89,90,118,97,111,128,83,82,93,94)

UPDATE mfd
SET
	field_type = 'd',
	mfd.sql_string = 'SELECT source_system_id, source_system_name FROM source_system_description'
FROM maintain_field_deal mfd
WHERE mfd.field_id = 5


UPDATE mfd
SET
	default_value = 2
FROM maintain_field_deal mfd
WHERE field_id = 5

UPDATE mfd
SET
	default_value = 31
FROM maintain_field_deal mfd
WHERE field_id = 14


UPDATE mfd
SET
	default_value = 'n'
FROM maintain_field_deal mfd
WHERE field_id = 16

UPDATE mfd
SET
	mfd.system_required = 'y'	
FROM maintain_field_deal mfd 
WHERE mfd.field_id IN (19, 20, 21, 22)