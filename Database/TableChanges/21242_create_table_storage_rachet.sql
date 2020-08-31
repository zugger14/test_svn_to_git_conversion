SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[storage_ratchet]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].storage_ratchet(
		storage_ratchet_id					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		general_assest_id					INT FOREIGN KEY REFERENCES general_assest_info_virtual_storage(general_assest_id) NOT NULL,
		term_from							DATE,
		term_to								DATE,
		gas_in_storage_perc_from			INT,
		gas_in_storage_perc_to				INT,
		[type]								INT,
		fixed_value							INT,
		perc_of_contracted_storage_space	FLOAT,
		[create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]							DATETIME NULL DEFAULT GETDATE(),
    	[update_user]						VARCHAR(50) NULL,
    	[update_ts]							DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].storage_ratchet EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_storage_ratchet]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_storage_ratchet]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_storage_ratchet]
ON [dbo].[storage_ratchet]
FOR UPDATE
AS
    UPDATE storage_ratchet
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM storage_ratchet sr
      INNER JOIN DELETED d ON sr.storage_ratchet_id = d.storage_ratchet_id
GO