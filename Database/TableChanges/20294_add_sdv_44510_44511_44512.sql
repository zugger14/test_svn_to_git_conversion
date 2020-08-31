SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44510)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44510, 44500, 'Fuel Intensity tCO2e/GJ', 'Fuel Intensity tCO2e/GJ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44510 - Fuel Intensity tCO2e/GJ.'
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'Fuel Intensity tCO2e/GJ',
		[description] ='Fuel Intensity tCO2e/GJ'
		WHERE [value_id] = 44510
	PRINT 'Updated Static value 44510 - Fuel Intensity tCO2e/GJ.'
END

--------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44511)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44511, 44500, 'OBA Target tCO2e/MWh', 'OBA Target tCO2e/MWh', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44511 - OBA Target tCO2e/MWh.'
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'OBA Target tCO2e/MWh',
		 [description] ='OBA Target tCO2e/MWh'
		WHERE [value_id] = 44511
	PRINT 'Updated Static value 44511 - OBA Target tCO2e/MWh.'
END


----------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44512)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (44512, 44500, 'Carbon Cost $/tCO2e', 'Carbon Cost $/tCO2e', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 44512 - Carbon Cost $/tCO2e.'
END
ELSE
BEGIN
	UPDATE static_data_value
		SET code = 'Carbon Cost $/tCO2e',
		 [description] ='Carbon Cost $/tCO2e'
		WHERE [value_id] = 44512
	PRINT 'Updated Static value 44512 - Carbon Cost $/tCO2e.'

END


---------------------------------------------------------------------------------

--IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 44513)
--BEGIN
--    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
--    VALUES (44513, 44500, 'Fuel Coal Intensity tCO2e/GJ', 'Fuel Coal Intensity tCO2e/GJ', '', 'farrms_admin', GETDATE())
--    PRINT 'Inserted static data value 44513 - Fuel Coal Intensity tCO2e/GJ.'
--END
--ELSE
--BEGIN
--	UPDATE static_data_value
--		SET code = 'Fuel Coal Intensity tCO2e/GJ',
--		 [description] ='Fuel Coal Intensity tCO2e/GJ'
--		WHERE [value_id] = 44513
--	PRINT 'Updated Static value 44513 - Fuel Coal Intensity tCO2e/GJ.'

--END


SET IDENTITY_INSERT static_data_value OFF

update source_minor_location set location_name='JOF1', location_id='JOF1' where location_name='Joffre'
update source_minor_location set location_name='VVW1', location_id='VVW1' where location_name='VVW'

update static_data_type set internal=1   where type_id =10023 