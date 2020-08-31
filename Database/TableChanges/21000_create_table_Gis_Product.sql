SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[Gis_Product]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Gis_Product]
    (
       [source_product_number]		INT IDENTITY(1,1) NOT NULL,
       [source_deal_header_id]		INT NULL,
       [in_or_not]					INT NULL,
       [jurisdiction_id]			INT NULL,
       [tier_id]					INT NULL,
       [vintage]					INT NULL,
       [cert_entity]				INT NULL,
       [create_user]				VARCHAR(100) NULL,
       [create_ts]					DATETIME NULL,
       [update_user]				VARCHAR(100) NULL,
       [update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table Gis_Product EXISTS'
END
 
GO

--Insert Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_Gis_Product]'))
    DROP TRIGGER [dbo].[TRGINS_Gis_Product]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGINS_Gis_Product]
ON [dbo].[Gis_Product]
FOR INSERT
AS
BEGIN
	UPDATE Gis_Product SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  Gis_Product.source_product_number in (select source_product_number from inserted)
END
GO

--Update Trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_Gis_Product]'))
    DROP TRIGGER [dbo].[TRGUPD_Gis_Product]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_Gis_Product]
ON [dbo].[Gis_Product]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[Gis_Product]
        SET update_user = dbo.FNADBUser(), [update_ts] = GETDATE()
        FROM [dbo].[Gis_Product] fr
        INNER JOIN DELETED d ON d.source_product_number = fr.source_product_number
    END
END
GO






  