IF COL_LENGTH('calc_invoice_volume_variance ', 'invoice_number') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD invoice_number VARCHAR(50)
	PRINT 'Column invoice_number added.'
END
ELSE
BEGIN
	PRINT 'Column invoice_number already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance ', 'comment1') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD comment1 VARCHAR(100) 
	PRINT 'Column comment1 added.'
END
ELSE
BEGIN
	PRINT 'Column comment1 already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance ', 'comment2') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD comment2 VARCHAR(100) 
	PRINT 'Column comment2 added.'
END
ELSE
BEGIN
	PRINT 'Column comment2 already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance ', 'comment3') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD comment3 VARCHAR(100) 
	PRINT 'Column comment3 added.'
END
ELSE
BEGIN
	PRINT 'Column comment3 already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance ', 'comment4') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD comment4 VARCHAR(100) 
	PRINT 'Column comment4 added.'
END
ELSE
BEGIN
	PRINT 'Column comment4 already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance', 'comment5') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD comment5 VARCHAR(100) 
	PRINT 'Column comment5 added.'
END
ELSE
BEGIN
	PRINT 'Column comment5 already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_status') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD invoice_status INT 
	PRINT 'Column invoice_status added.'
END
ELSE
BEGIN
	PRINT 'Column invoice_status already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_lock') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD invoice_lock CHAR(1)
	PRINT 'Column invoice_lock added.'
END
ELSE
BEGIN
	PRINT 'Column invoice_lock already exists.'
END
GO
IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_note') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance ADD invoice_note varchar(500)
	PRINT 'Column invoice_note added.'
END
ELSE
BEGIN
	PRINT 'Column invoice_note already exists.'
END
GO
--3.	Alter table calc_invoice_volume_variance to add following fields
--a.	invoice_number VARCHAR(50)
--b.	comment1 VARCHAR(100)
--c.	comment2 VARCHAR(100)
--d.	comment3 VARCHAR(100)
--e.	comment4 VARCHAR(100)
--f.	comment5 VARCHAR(100)
--g.	invoice_status INT
