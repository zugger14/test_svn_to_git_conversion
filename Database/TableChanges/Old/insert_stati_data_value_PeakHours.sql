SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM   static_data_value WHERE  value_id = -801)
BEGIN
    INSERT INTO static_data_value
      (
        value_id,[type_id],code,[description],create_user,create_ts
      )
    VALUES
      (
        -801,800,'PeakHours','PeakHours','farrms_admin',GETDATE()
      )
    PRINT 'Inserted static data value -801 - PeakHours.'
END
ELSE
BEGIN
    PRINT 'Static data value -801 - PeakHours already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	


PRINT 'Updated Static data type 800 - Formula Editor.'	
UPDATE static_data_value
SET    [type_id] = 800,
       [code] = 'PeakHours',
       [description] = 'PeakHours'
WHERE  [value_id] = -801
 
PRINT 'Updated static data value -801 - PeakHours.'
