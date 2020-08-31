IF COL_LENGTH('optimizer_header', 'path_id') IS NOT NULL
BEGIN
    ALTER TABLE optimizer_header DROP COLUMN path_id 
END
GO

IF COL_LENGTH('optimizer_detail', 'path_id') IS NOT NULL
BEGIN
     ALTER TABLE optimizer_detail DROP COLUMN path_id
END
GO

IF COL_LENGTH('optimizer_header', 'group_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_header ADD group_path_id INT
END
GO

IF COL_LENGTH('optimizer_header', 'single_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_header ADD single_path_id INT
END
GO

IF COL_LENGTH('optimizer_header', 'contract_id') IS NULL
BEGIN
    ALTER TABLE optimizer_header ADD contract_id INT
END
GO

IF COL_LENGTH('optimizer_detail', 'group_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail ADD group_path_id INT
END
GO

IF COL_LENGTH('optimizer_detail', 'single_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail ADD single_path_id INT
END
GO

IF COL_LENGTH('optimizer_detail', 'contract_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail ADD contract_id INT
END
GO


IF COL_LENGTH('optimizer_detail_downstream', 'group_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail_downstream ADD group_path_id INT
END
GO

IF COL_LENGTH('optimizer_detail_downstream', 'single_path_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail_downstream ADD single_path_id INT
END
GO

IF COL_LENGTH('optimizer_detail_downstream', 'contract_id') IS NULL
BEGIN
    ALTER TABLE optimizer_detail_downstream ADD contract_id INT
END
GO
