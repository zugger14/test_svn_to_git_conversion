DECLARE @gm_to_delete AS VARCHAR(8000) = ' Ice Trader,Ice Broker, Ice CounterParty, Invoice Title, Imbalance Report,Template Mapping, Imbalance Deal, Approved Trades Matrix,Valid Templates, TAX Rule Mapping, Exposure Breakdown, SAP GL Code Mapping, VAT Rule Mapping, Contract Meters, Contract Curves, Contract Value'

DELETE generic_mapping_values 
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id
INNER JOIN dbo.SplitCommaSeperatedValues(@gm_to_delete) scsv On scsv.item = gmh.mapping_name

DELETE generic_mapping_definition 
FROM generic_mapping_definition gmd
INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
INNER JOIN dbo.SplitCommaSeperatedValues(@gm_to_delete) scsv On scsv.item = gmh.mapping_name

DELETE generic_mapping_header 
FROM generic_mapping_header gmh
INNER JOIN dbo.SplitCommaSeperatedValues(@gm_to_delete) scsv On scsv.item = gmh.mapping_name

