UPDATE smlng
SET smlng.[type] = (
           SELECT value_id
           FROM static_data_value
           WHERE code = 'Primary'
                  AND [type_id] = 11130
       )
FROM source_minor_location_nomination_group smlng
WHERE smlng.[type] IS NULL