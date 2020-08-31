--trader
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'trader')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN trader 
	PRINT 'Column dropped'
END

--commodity
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'commodity_id')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN commodity_id 
	PRINT 'Column dropped'
END

--deal_type
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'deal_type')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN deal_type 
	PRINT 'Column dropped'
END

--counterparty
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'counterparty_id')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN ounterparty_id
	PRINT 'Column dropped'
END

--term_start
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'term_start')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN term_start 
	PRINT 'Column dropped'
END
ELSE

--term_end
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'term_end')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN term_end 
	PRINT 'Column dropped'
END

--starting_month
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'starting_month')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN starting_month 
	PRINT 'Column dropped'
END

--no_of_month
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'no_of_month')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN no_of_month 
	PRINT 'Column dropped'
END

--limit_id
IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name LIKE 'portfolio_group_book' AND column_name LIKE 'limit_id')
BEGIN
	ALTER TABLE portfolio_group_book DROP COLUMN limit_id 
	PRINT 'Column dropped'
END