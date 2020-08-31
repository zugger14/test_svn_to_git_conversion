ALTER TABLE source_deal_pnl_arch1
ADD tempID INT NULL

GO 

UPDATE source_deal_pnl_arch1
SET tempID = source_deal_pnl_id

GO

ALTER TABLE source_deal_pnl_arch1
DROP COLUMN source_deal_pnl_id

GO

ALTER TABLE source_deal_pnl_arch1
ADD source_deal_pnl_id INT NULL	

GO

UPDATE source_deal_pnl_arch1
SET source_deal_pnl_id = tempID

GO

ALTER TABLE source_deal_pnl_arch1
DROP COLUMN tempID

GO

ALTER TABLE source_deal_pnl_arch1
ALTER COLUMN source_deal_pnl_id INT NOT NULL	

GO
--select * from source_deal_pnl_arch1

