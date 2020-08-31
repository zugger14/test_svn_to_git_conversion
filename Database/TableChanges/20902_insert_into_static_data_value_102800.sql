IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Load/Save/Delete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102808, 102800, 'Hybrid Load/Save/Delete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Load/Save/Delete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Form Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102809, 102800, 'Hybrid Form Load Complete', 'Hybrid Form Load Complete')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Form Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Load/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102810, 102800, 'Hybrid Load/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Load/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Delete/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102811, 102800, 'Hybrid Delete/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Delete/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Save/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102812, 102800, 'Hybrid Save/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Save/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Load/Save/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102813, 102800, 'Hybrid Load/Save/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Load/Save/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Load/Delete/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102814, 102800, 'Hybrid Load/Delete/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Load/Delete/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Save/Delete/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102815, 102800, 'Hybrid Save/Delete/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Save/Delete/Load Complete Inserted'
END

IF (SELECT 1 FROM static_data_value WHERE type_id = 102800 and code = 'Hybrid Load/Save/Delete/Load Complete') IS NULL
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value
	(value_id, [type_id], code, [description])
	VALUES
	(102816, 102800, 'Hybrid Load/Save/Delete/Load Complete', '')
	SET IDENTITY_INSERT static_data_value OFF
	PRINT 'Hybrid Load/Save/Delete/Load Complete Inserted'
END
