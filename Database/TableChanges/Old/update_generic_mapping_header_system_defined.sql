UPDATE generic_mapping_header
SET system_defined = 0

UPDATE generic_mapping_header
SET system_defined = 1 WHERE mapping_name = 'Imbalance Report'

UPDATE generic_mapping_header
SET system_defined = 1 WHERE mapping_name = 'Imbalance Deal'