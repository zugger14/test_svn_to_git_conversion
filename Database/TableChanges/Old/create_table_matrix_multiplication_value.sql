IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[matrix_multiplication_value]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
   CREATE TABLE [dbo].[matrix_multiplication_value] (
	mul_value_id		INT IDENTITY(1, 1)
    , run_date			DATETIME
    , as_of_date		DATETIME
	, curve_id			INT
	, risk_id			INT
	, term_start		DATETIME
	, rnd_value			FLOAT
	, norm_rnd_value	FLOAT
	, cor_rnd_value		FLOAT
	, curve_value		FLOAT
	, exp_rtn_value		FLOAT
	, vol_value			FLOAT
	, is_dst			TINYINT
	, curve_source		INT
	, create_user       VARCHAR(50) 	NULL DEFAULT dbo.FNADBUser()
    , create_ts         DATETIME 		NULL DEFAULT GETDATE()
    , update_user       VARCHAR(50) 	NULL
    , update_ts         DATETIME 		NULL
)
    PRINT 'Table Successfully Created'
END

GO

IF OBJECT_ID('TRGUPD_matrix_multiplication_value') IS NOT NULL
	DROP TRIGGER TRGUPD_matrix_multiplication_value
GO

CREATE TRIGGER [dbo].[TRGUPD_matrix_multiplication_value]
ON [dbo].[matrix_multiplication_value]
FOR UPDATE
AS
    UPDATE matrix_multiplication_value
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM matrix_multiplication_value mmv
    INNER JOIN DELETED u ON mmv.mul_value_id = u.mul_value_id
GO