IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'commodity'
          AND Object_ID = Object_ID(N'contract_group'))
BEGIN
	ALTER TABLE contract_group
	ADD commodity INT 
END          		   
	 