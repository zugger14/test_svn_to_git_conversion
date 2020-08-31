IF NOT EXISTS(SELECT 'x' FROM sys.[columns] c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
AND t.[name] = 'cum_pnl_series' AND c.[name] = 'comments')
ALTER TABLE cum_pnl_series ADD comments VARCHAR(1000)