
/*Renamed Field Label name for general mapping (Contract Curves) */
UPDATE user_defined_fields_template
  SET
      Field_label = 'Counterparty'
WHERE Field_label = 'Counterparty UDF';


UPDATE user_defined_fields_template
  SET
      Field_label = 'Contract'
WHERE Field_label = 'Contract UDF';