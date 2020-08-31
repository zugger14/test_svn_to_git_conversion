--Make 'Technology Sub Type' as Active.
UPDATE static_data_type 
SET is_active = 1
WHERE [type_id] = 13000

--Make 'Fuel Type' as external and active static Data.
UPDATE static_data_type
SET internal = 0
, is_active = 1
WHERE [type_id] = 10023