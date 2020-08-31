IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[cholesky_decomposition_value_whatif]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
   CREATE TABLE [dbo].[cholesky_decomposition_value_whatif] (
	decom_value_id				INT IDENTITY(1, 1)
	, criteria_id				INT NOT NULL
    , as_of_date				DATETIME NOT NULL
	, x_id						INT
	, y_id						INT
	, x_curve_id				INT
	, y_curve_id				INT
	, x_term_start				DATETIME
	, y_term_start				DATETIME
	, d_value					FLOAT
	, curve_source				INT
	, create_user               VARCHAR(50) 	NULL DEFAULT dbo.FNADBUser()
    , create_ts                 DATETIME 		NULL DEFAULT GETDATE()
    , update_user               VARCHAR(50) 	NULL
    , update_ts                 DATETIME 		NULL
)
    PRINT 'Table Successfully Created'
END
GO

IF OBJECT_ID('[dbo].[TRGUPD_cholesky_decomposition_value_whatif]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_cholesky_decomposition_value_whatif]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_cholesky_decomposition_value_whatif]
ON [dbo].[cholesky_decomposition_value_whatif]
FOR UPDATE
AS
    UPDATE cholesky_decomposition_value_whatif
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM cholesky_decomposition_value_whatif cdvw
    INNER JOIN DELETED u ON cdvw.decom_value_id = u.decom_value_id
GO