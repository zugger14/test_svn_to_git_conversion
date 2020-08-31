IF (SELECT 1 FROM static_data_value WHERE code = 'Extrinsic/Other Value') IS NOT NULL
BEGIN
	UPDATE static_data_value
	SET code = 'Extrinsic to PNL'
	WHERE [type_id] = 225 AND code = 'Extrinsic/Other Value'
END 
ELSE
BEGIN
	PRINT ('Extrinsic/Other Value already updated to Extrinsic to PNL.')
END

IF (SELECT 1 FROM static_data_value WHERE code = 'Extrinsic Values in AOCI') IS NULL
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description]) VALUES ('225', 'Extrinsic Values in AOCI', 'Extrinsic Values in AOCI')
END
ELSE
BEGIN
	PRINT ('Extrinsic Values in AOCI already added.')
END

IF (SELECT 1 FROM static_data_value WHERE code = 'Extrinsic to PNL') IS NOT NULL
BEGIN
	UPDATE static_data_value
	SET code = 'Extrinsic Values in PNL'
	WHERE [type_id] = 225 AND code = 'Extrinsic to PNL'
END
ELSE
BEGIN
	PRINT ('Extrinsic to PNL already updated to Extrinsic Values in PNL.')
END