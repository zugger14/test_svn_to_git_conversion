IF EXISTS(
   	SELECT 1
   	FROM sys.objects
   	WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[eigen_value_decomposition]')
   		AND TYPE IN (N'U')
   )
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE eigen_value_decomposition
    (
    id                        INT IDENTITY(1 , 1),
    as_of_date                DATETIME,
    curve_id_from             INT,
    curve_id_to               INT,
    term1                     DATETIME,
    term2                     DATETIME,
    curve_source_value_id     INT,
    eigen_values              FLOAT,
    eigen_vectors             FLOAT,
    eigen_factors             FLOAT,
    create_user               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    create_ts                 DATETIME NULL DEFAULT GETDATE(),
    update_user               VARCHAR(50) NULL,
    update_ts                 DATETIME NULL
    )
    PRINT 'Table Successfully Created'
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_eigen_value_decomposition]' , 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_eigen_value_decomposition]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_eigen_value_decomposition]
ON [dbo].[eigen_value_decomposition]
FOR  UPDATE
AS
	UPDATE eigen_value_decomposition
		SET update_user     = dbo.FNADBUser(),
			update_ts       = GETDATE()
	FROM eigen_value_decomposition evd
	INNER JOIN DELETED u ON evd.id = u.id
GO