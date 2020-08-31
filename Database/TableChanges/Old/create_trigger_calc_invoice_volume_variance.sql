IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_calc_invoice_volume_variance]'))
    DROP TRIGGER [dbo].[TRGUPD_calc_invoice_volume_variance]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_calc_invoice_volume_variance]
ON [dbo].[calc_invoice_volume_variance]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts) AND NOT UPDATE(invoice_file_name) AND NOT UPDATE(netting_file_name) AND NOT UPDATE(invoice_number)
    BEGIN
        UPDATE calc_invoice_volume_variance
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM calc_invoice_volume_variance an
        INNER JOIN DELETED d ON d.calc_id = an.calc_id
               
		INSERT INTO Calc_invoice_Volume_variance_audit
		(
		    [calc_id],
		    [as_of_date],
		    [counterparty_id],
		    [generator_id],
		    [contract_id],
		    [prod_date],
		    [metervolume],
		    [invoicevolume],
		    [allocationvolume],
		    [variance],
		    [onpeak_volume],
		    [offpeak_volume],
		    [UOM],
		    [ActualVolume],
		    [book_entries],
		    [finalized],
		    [invoice_id],
		    [deal_id],
		    [estimated],
		    [calculation_time],
		    [book_id],
		    [sub_id],
		    [process_id],
		    [invoice_number],
		    [comment1],
		    [comment2],
		    [comment3],
		    [comment4],
		    [comment5],
		    [invoice_status],
		    [invoice_lock],
		    [invoice_note],
		    [invoice_type],
		    [netting_group_id],
		    [prod_date_to],
		    [settlement_date],
		    [user_action],
		    create_user,
 			create_ts,
 			update_user,
 			update_ts
		)
		SELECT [calc_id],
		       [as_of_date],
		       [counterparty_id],
		       [generator_id],
		       [contract_id],
		       [prod_date],
		       [metervolume],
		       [invoicevolume],
		       [allocationvolume],
		       [variance],
		       [onpeak_volume],
		       [offpeak_volume],
		       [UOM],
		       [ActualVolume],
		       [book_entries],
		       [finalized],
		       [invoice_id],
		       [deal_id],
		       [estimated],
		       [calculation_time],
		       [book_id],
		       [sub_id],
		       [process_id],
		       [invoice_number],
		       [comment1],
		       [comment2],
		       [comment3],
		       [comment4],
		       [comment5],
		       [invoice_status],
		       [invoice_lock],
		       [invoice_note],
		       [invoice_type],
		       [netting_group_id],
		       [prod_date_to],
		       [settlement_date],
		       'update',
		       dbo.FNADBUser(),
 			   GETDATE(),
 			   dbo.FNADBUser(),
 			   GETDATE()
		FROM   INSERTED
        
    END
END
GO