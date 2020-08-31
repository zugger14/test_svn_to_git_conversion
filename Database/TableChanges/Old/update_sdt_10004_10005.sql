

UPDATE static_data_type
SET    internal = 0,
       [type_name] = 'VAT Code'
WHERE  TYPE_ID = 10004

UPDATE static_data_type
SET    internal        = 0,
       [type_name]     = 'Cost Encoding'
WHERE  TYPE_ID         = 10005  