/*Author  : Vishwas Khanal			
  Dated   : 23.March.2009				
  Purpose : CR - 19March2009 RCN - 5 
*/

IF NOT EXISTS (SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name = 'commodity')
	ALTER TABLE dbo.delivery_path ADD commodity VARCHAR(255)

IF NOT EXISTS (SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name = 'isactive')
	ALTER TABLE dbo.delivery_path ADD isactive CHAR(1)

IF NOT EXISTS (SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name = 'meter_from')
	ALTER TABLE dbo.delivery_path ADD meter_from INT

IF NOT EXISTS (SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name = 'meter_to')
	ALTER TABLE dbo.delivery_path ADD meter_to INT

