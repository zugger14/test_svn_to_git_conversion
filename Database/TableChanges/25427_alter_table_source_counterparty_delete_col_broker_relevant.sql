IF COL_LENGTH('source_counterparty', 'broker_relevant') IS NOT NULL 
BEGIN 
    ALTER TABLE source_counterparty DROP column broker_relevant  
END 