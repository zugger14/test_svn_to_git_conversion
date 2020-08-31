if object_id('FNARVATPercent') is not null
drop function dbo.FNARVATPercent
GO

create FUNCTION [dbo].[FNARVATPercent](@as_of_date DATETIME, @counterparty_id INT)
	RETURNS FLOAT
AS
BEGIN
	

	DECLARE @value           FLOAT	
	DECLARE @external_value  VARCHAR(100)
	
	IF EXISTS (SELECT external_value FROM counterparty_epa_account WHERE external_type_id = 2201 AND counterparty_id = @counterparty_id)
	    SET @external_value = 'y'
	ELSE
	    SET @external_value = 'n'
	
	SELECT @value = spc.curve_value
	FROM   generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv
        ON  gmv.mapping_table_id = gmh.mapping_table_id
        AND gmh.mapping_name = 'VAT Rule Mapping'
    INNER JOIN source_counterparty sc ON  CAST(sc.region AS VARCHAR(1000)) = gmv.clm3_value
    INNER JOIN source_deal_header sdh
        ON  sdh.counterparty_id = sc.source_counterparty_id
        AND sdh.source_system_book_id2 = gmv.clm1_value
        AND sdh.source_system_book_id3 = gmv.clm2_value
	INNER JOIN contract_group cg ON  cg.contract_id = sdh.contract_id
	INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
	CROSS APPLY(
	    SELECT MAX(as_of_date) as_of_date,
	           MAX(maturity_date)maturity_date
	    FROM   source_price_curve spc
	    WHERE  CAST(source_curve_def_id AS VARCHAR) = gmv.clm5_value
	           AND as_of_date < @as_of_date
	) spc1
	INNER JOIN source_price_curve spc
        ON  CAST(spc.source_curve_def_id AS VARCHAR) = gmv.clm5_value
        AND spc.as_of_date = spc1.as_of_date
        AND spc.maturity_date = spc1.maturity_date
	WHERE  sc.source_counterparty_id = @counterparty_id AND gmv.clm4_value = @external_value AND gmv.clm3_value = sc.region
	
	RETURN @value
END
