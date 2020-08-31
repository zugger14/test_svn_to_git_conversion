/*
Adds the following fields in deal detail:
a. Price UOM
b. Category
c. Profile Code
d. PV Party
*/

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18100, 'Deal Detail Category', 0, 'Deal Detail Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18100 - Deal Detail Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 18100 - Deal Detail Category already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18200, 'Profile Code', 0, 'Profile Code', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18200 - Profile Code.'
END
ELSE
BEGIN
	PRINT 'Static data type 18200 - Profile Code already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18300, 'Pv Party', 0, 'Pv Party', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18300 - Pv Party.'
END
ELSE
BEGIN
	PRINT 'Static data type 18300 - Pv Party already EXISTS.'
END
