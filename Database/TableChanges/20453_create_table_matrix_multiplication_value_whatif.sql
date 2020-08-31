IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[matrix_multiplication_value_whatif]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
   CREATE TABLE [dbo].[matrix_multiplication_value_whatif] (
	mul_value_id		INT IDENTITY(1, 1)
	, criteria_id		INT NOT NULL
    , run_date			DATETIME NOT NULL
    , as_of_date		DATETIME NOT NULL
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

IF OBJECT_ID('TRGUPD_matrix_multiplication_value_whatif') IS NOT NULL
	DROP TRIGGER TRGUPD_matrix_multiplication_value_whatif
GO

CREATE TRIGGER [dbo].[TRGUPD_matrix_multiplication_value_whatif]
ON [dbo].[matrix_multiplication_value_whatif]
FOR UPDATE
AS
    UPDATE matrix_multiplication_value_whatif
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM matrix_multiplication_value_whatif mmvw
    INNER JOIN DELETED u ON mmvw.mul_value_id = u.mul_value_id
GO