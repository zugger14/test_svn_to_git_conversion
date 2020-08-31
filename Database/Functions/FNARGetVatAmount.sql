IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNARGetVatAmount]')
              AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
    DROP FUNCTION [dbo].[FNARGetVatAmount]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNARGetVatAmount]
(
	@counterparty_id     INT,
	@contract_id         INT,
	@as_of_date          DATETIME,
	@process_id			 VARCHAR(255)
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @sum_value FLOAT
	DECLARE @vat_percent FLOAT
	
	--	Doc type 
	DECLARE @doc_type VARCHAR(255)
	SELECT TOP 1 @doc_type = gmv.clm5_value
	FROM   generic_mapping_header gmh
		   INNER JOIN generic_mapping_values gmv
				ON  gmv.mapping_table_id = gmh.mapping_table_id
		   INNER JOIN source_counterparty sc
				ON  sc.source_counterparty_id = @counterparty_id
		   INNER JOIN contract_group cg
				ON  cg.contract_id = @contract_id
				AND sc.int_ext_flag = CAST(gmv.clm3_value AS VARCHAR(10))
		   OUTER APPLY (
		                   SELECT cea1.external_value [sap]
		                   FROM   counterparty_epa_account cea1
		                   WHERE  cea1.counterparty_id = @counterparty_id
		                          AND cea1.external_type_id = 307213 -- Double Booking compare to SAP
		               )dbl_booking
	WHERE  gmh.mapping_name = 'Non EFET SAP Doc Type'
		-- check for self billing first else check for contract group document type 
	AND CASE WHEN dbl_booking.sap = 'yes' THEN 'y' ELSE  'n'  END = CAST(gmv.clm4_value AS VARCHAR(10))
	AND CASE WHEN cg.self_billing = 'y' THEN 's' ELSE CASE WHEN cg.[type] = 'i' THEN 'o' WHEN cg.[type] = 'r' THEN 'o' ELSE 'o' END END = CAST(gmv.clm2_value AS VARCHAR(10))
	AND CAST(gmv.clm1_value AS VARCHAR(10)) = 'i' -- Always look for invoice only

	
	DECLARE @mapping_table_id INT       
	
	SELECT @mapping_table_id = gmh.mapping_table_id
	FROM   generic_mapping_header gmh
	WHERE  gmh.mapping_name = 'Non EFET VAT Rule Mapping'
	
	DECLARE @curve_vat TABLE (curve_id INT, vat_percent FLOAT,product_group INT)

	INSERT INTO @curve_vat
	SELECT gmv.clm5_value, MAX(ISNULL(spc.curve_value, 0)),gmv.clm1_value
	FROM   generic_mapping_header gmh
	       INNER JOIN generic_mapping_values gmv
	            ON  gmv.mapping_table_id = gmh.mapping_table_id
	            AND gmh.mapping_name = 'Non EFET VAT Rule Mapping'
	       INNER JOIN counterparty_contacts sc
	            ON  CAST(sc.region AS VARCHAR(1000)) = gmv.clm2_value
	            AND is_primary = 'y'
	            AND sc.counterparty_id = @counterparty_id
	       OUTER APPLY (
	                SELECT cea.external_value [Entrepot]
	                FROM   counterparty_epa_account cea
	                WHERE  cea.counterparty_id = @counterparty_id
	                       AND cea.external_type_id = 2201 -- Entrepot number
	            ) ext1 
			OUTER APPLY(
	               SELECT cea1.external_value [ic]
	               FROM   counterparty_epa_account cea1
	               WHERE  cea1.counterparty_id = @counterparty_id
	                      AND cea1.external_type_id = 307212 -- IC with Fiscal Unit
	           ) ext2	
		   CROSS APPLY(
		SELECT MAX(as_of_date)     as_of_date,
			   MAX(maturity_date)     maturity_date
		FROM   source_price_curve     spc
		WHERE  CAST(source_curve_def_id AS VARCHAR) = gmv.clm5_value
			   AND as_of_date <= dbo.FNAGetContractMonth(@as_of_date) -- @as_of_date
	) spc1
	INNER JOIN source_price_curve spc
				ON  CAST(spc.source_curve_def_id AS VARCHAR) = gmv.clm5_value
				AND spc.as_of_date = spc1.as_of_date
				AND spc.maturity_date = spc1.maturity_date
	WHERE  sc.counterparty_id = @counterparty_id
		   AND gmv.clm2_value = CAST(sc.region AS VARCHAR(1000))
			AND CASE WHEN ext1.Entrepot IS NULL THEN 'No' ELSE 'Yes' END  =  CASE WHEN gmv.clm3_value = 'y' THEN 'Yes' ELSE 'No' END
			AND ISNULL(ext2.ic, 'No') = CASE WHEN gmv.clm4_value = 'y' THEN 'Yes' ELSE 'No' END
			AND gmv.clm8_value = @doc_type
	GROUP BY gmv.clm5_value,gmv.clm1_value

	SELECT @sum_value = SUM(ISNULL(cv.vat_percent, 0) * ISNULL(CALC.contract_value, 0))
	FROM   calc_line_item_formula_value calc
	       INNER JOIN contract_group cg
	            ON  calc.contract_id = cg.contract_id
	       CROSS APPLY(
	                      -- Invoice Line Item  from contract template setup
	                      SELECT cctd.sequence_order,
	                             cctd.invoice_line_item_id,
	                             cctd.alias
	                      FROM   contract_charge_type cct
	                             LEFT JOIN contract_charge_type_detail cctd
	                                  ON  cctd.contract_charge_type_id = cct.contract_charge_type_id
	                      WHERE  cct.contract_charge_type_id = cg.contract_charge_type_id
	                             AND cctd.invoice_line_item_id = calc.invoice_line_item_id
	                      UNION ALL -- Invoice Line Item Defined in contract
	                      SELECT cgd.sequence_order,
	                             cgd.invoice_line_item_id,
	                             cgd.alias
	                      FROM   contract_group_detail cgd
	                      WHERE  cgd.contract_id = calc.contract_id
	                  ) ct
	INNER JOIN counterparty_contacts cc
	            ON  calc.counterparty_id = cc.counterparty_id
	            AND cc.is_primary = 'y'
	       LEFT JOIN counterparty_epa_account cea
	            ON  cea.counterparty_id = @counterparty_id
	            AND cea.external_type_id = 2201 -- Entrepot number	                
	                
	       LEFT JOIN counterparty_epa_account cea1
	            ON  cea.counterparty_id = @counterparty_id
	            AND cea.external_type_id = 307212 -- IC within Fiscal Unit
	                
	       INNER JOIN generic_mapping_values gmv
	            ON  ct.alias = gmv.clm1_value
	            AND gmv.mapping_table_id = @mapping_table_id
	            AND cc.region = gmv.clm2_value
	       INNER JOIN @curve_vat cv
	            ON  gmv.clm5_value = cv.curve_id
	            AND cv.product_group = ct.alias
	       OUTER APPLY (
	                       SELECT cea.external_value [Entrepot]
	                       FROM   counterparty_epa_account cea
	                       WHERE  cea.counterparty_id = @counterparty_id
	                              AND cea.external_type_id = 2201 -- Entrepot number
	                   ) ext1 
		  OUTER APPLY(
		                 SELECT cea1.external_value [ic]
		                 FROM   counterparty_epa_account cea1
		                 WHERE  cea1.counterparty_id = @counterparty_id
		                        AND cea1.external_type_id = 307212 -- IC with Fiscal Unit
		             ) ext2
	WHERE  calc.process_id = @process_id
	       AND ct.invoice_line_item_id = calc.invoice_line_item_id
	       AND calc.counterparty_id = @counterparty_id
	       AND calc.contract_id = @contract_id
	       AND calc.prod_date = dbo.FNAGetContractMonth(@as_of_date)
	AND CASE WHEN ext1.Entrepot IS NULL THEN 'No' ELSE 'Yes' END  =  CASE WHEN gmv.clm3_value = 'y' THEN 'Yes' ELSE 'No' END
	AND ISNULL(ext2.ic, 'No') = CASE WHEN gmv.clm4_value = 'y' THEN 'Yes' ELSE 'No' END
	AND CAST(gmv.clm8_value AS VARCHAR(10))= @doc_type
	RETURN ISNULL(@sum_value , 0)
END
GO





