SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[map_function_product]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[map_function_product]
    (
    [map_function_product_id]			INT IDENTITY(1, 1) PRIMARY KEY,
    [product_id]						INT NULL,
    [function_id]						INT NULL REFERENCES dbo.static_data_value(value_id),
    [create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]							DATETIME NULL DEFAULT GETDATE(),
    [update_user]						VARCHAR(50) NULL,
    [update_ts]							DATETIME NULL
    CONSTRAINT IX_function_product
	UNIQUE NONCLUSTERED([product_id] ASC, [function_id] ASC)
    )
END
ELSE
BEGIN
    PRINT 'Table map_function_product EXISTS'
END
 
GO

 
IF OBJECT_ID(N'[dbo].[map_function_category]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[map_function_category]
    (
    [map_function_category_id]			INT IDENTITY(1, 1) NOT NULL,
    [category_id]						INT NULL REFERENCES dbo.static_data_value(value_id),
    [function_id]						INT NULL REFERENCES dbo.static_data_value(value_id),
    [create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]							DATETIME NULL DEFAULT GETDATE(),
    [update_user]						VARCHAR(50) NULL,
    [update_ts]							DATETIME NULL
    CONSTRAINT IX_function_category
	UNIQUE NONCLUSTERED([category_id] ASC, [function_id] ASC)
    )
END
ELSE
BEGIN
    PRINT 'Table map_function_category EXISTS'
END
 
GO