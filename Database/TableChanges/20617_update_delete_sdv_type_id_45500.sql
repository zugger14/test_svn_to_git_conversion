DELETE sdv 
	FROM static_data_value sdv 
WHERE value_id in (45504,45505,45506,45507)

UPDATE sdv  SET sdv.code = 'Monte Carlo',
sdv.description = 'Monte Carlo' 
	FROM static_data_value sdv
WHERE sdv.value_id = 45502

UPDATE sdv  SET sdv.code = 'Kirk Approximation',
sdv.description = 'Kirk Approximation' 
	FROM static_data_value sdv
WHERE sdv.value_id = 45503