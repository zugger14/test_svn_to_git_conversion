UPDATE s
SET s.is_active = 1
FROM static_data_type s
WHERE s.[type_name] = 'Hourly Block'