SELECT DISTINCT sc.source_counterparty_id,
       pbm.counterparty_id
FROM   pratos_book_mapping pbm
       INNER JOIN source_counterparty sc
            ON  sc.counterparty_id = pbm.counterparty_id
	
UPDATE pbm
SET    counterparty_id = sc.source_counterparty_id
FROM   pratos_book_mapping pbm
       INNER JOIN source_counterparty sc
            ON  sc.counterparty_id = pbm.counterparty_id
		
SELECT DISTINCT 
       sdv.value_id,
       pbm1.country_id
FROM   pratos_book_mapping pbm1
       INNER JOIN static_data_value sdv
            ON  pbm1.country_id = CASE WHEN sdv.code = 'NLL' THEN 'NL' ELSE sdv.code END 	
            
UPDATE pbm1
SET    country_id = sdv.value_id
FROM   pratos_book_mapping pbm1
       INNER JOIN static_data_value sdv
            ON  pbm1.country_id = CASE WHEN sdv.code = 'NLL' THEN 'NL' ELSE sdv.code END  WHERE sdv.[type_id] = 14000
            
                       
SELECT DISTINCT sdv.value_id,
       pbm2.grid_id
FROM   pratos_book_mapping pbm2
       INNER JOIN static_data_value sdv
            ON  pbm2.grid_id = sdv.code
            
UPDATE pbm2
SET    grid_id = sdv.value_id
FROM   pratos_book_mapping pbm2
       INNER JOIN static_data_value sdv
            ON  pbm2.grid_id = sdv.code  
    
            
SELECT DISTINCT sdv.value_id,
       pbm3.category
FROM   pratos_book_mapping pbm3
       INNER JOIN static_data_value sdv
            ON  pbm3.category = sdv.code
            
UPDATE pbm3
SET    category = sdv.value_id
FROM   pratos_book_mapping pbm3
       INNER JOIN static_data_value sdv
            ON  pbm3.category = sdv.code             