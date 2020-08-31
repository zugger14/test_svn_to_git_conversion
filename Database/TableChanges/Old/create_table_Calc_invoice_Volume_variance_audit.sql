SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Calc_invoice_Volume_variance_audit]
	(
		[Calc_invoice_Volume_variance_audit_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[calc_id]              [INT] NULL,
		[as_of_date]           [datetime] NULL,
		[recorderid]           [varchar](100) NULL,
		[counterparty_id]      [int] NULL,
		[generator_id]         [int] NULL,
		[contract_id]          [int] NULL,
		[prod_date]            [datetime] NULL,
		[metervolume]          [float] NULL,
		[invoicevolume]        [float] NULL,
		[allocationvolume]     [float] NULL,
		[variance]             [float] NULL,
		[onpeak_volume]        [float] NULL,
		[offpeak_volume]       [float] NULL,
		[UOM]                  [int] NULL,
		[ActualVolume]         [char](1) NULL,
		[book_entries]         [char](1) NULL,
		[finalized]            [char](1) NULL,
		[invoice_id]           [int] NULL,
		[deal_id]              [int] NULL,
		[estimated]            [char](1) NULL,
		[calculation_time]     [float] NULL,
		[book_id]              [INT] NULL,
		[sub_id]               [INT] NULL,
		[process_id]           VARCHAR(100) NULL,
		[invoice_number]       VARCHAR(50) NULL,
		[comment1]             VARCHAR(100) NULL,
		[comment2]             VARCHAR(100) NULL,
		[comment3]             VARCHAR(100) NULL,
		[comment4]             VARCHAR(100) NULL,
		[comment5]             VARCHAR(100) NULL,
		[invoice_status]       INT NULL,
		[invoice_lock]         CHAR(1) NULL,
		[invoice_note]         VARCHAR(500) NULL,
		[invoice_type]         CHAR(1) NULL,
		[netting_group_id]     INT NULL,
		[prod_date_to]         DATETIME NULL,
		[settlement_date]      DATETIME NULL,
		[user_action]          VARCHAR(50) NULL,
		[create_user]          VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            DATETIME NULL DEFAULT GETDATE(),
		[update_user]          [varchar](50) NULL,
		[update_ts]            [datetime] NULL
	)
END
ELSE
BEGIN
    PRINT 'Table Calc_invoice_Volume_variance_audit EXISTS'
END
 
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_Calc_invoice_Volume_variance_audit]'))
    DROP TRIGGER [dbo].[TRGUPD_Calc_invoice_Volume_variance_audit]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_Calc_invoice_Volume_variance_audit]
ON [dbo].[Calc_invoice_Volume_variance_audit]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE Calc_invoice_Volume_variance_audit
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM Calc_invoice_Volume_variance_audit an
        INNER JOIN DELETED d ON d.Calc_invoice_Volume_variance_audit_id = an.Calc_invoice_Volume_variance_audit_id
    END
END
GO
