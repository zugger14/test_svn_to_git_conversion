--These two indexes were missing in TRMTracker_Master_Branch version

-- **********************************************************************
-- Index unq_cur_indx_source_deal_settlement on table source_deal_settlement
-- **********************************************************************
IF EXISTS(SELECT 1
            FROM sysindexes si
            INNER JOIN sysobjects so
                   ON so.id = si.id
           WHERE si.[Name] = N'unq_cur_indx_source_deal_settlement' -- Index Name
             AND so.[Name] = N'source_deal_settlement')  -- Table Name
BEGIN
    DROP INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement]
END
GO
CREATE UNIQUE INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement]
(
    [source_deal_header_id] ASC,
    [term_start] ASC,
    [leg] ASC,
    [as_of_date] ASC,
    [set_type] ASC
) 
GO

-- **********************************************************************
-- Index source_curve_def_id_index on table source_price_curve
-- **********************************************************************
IF EXISTS(SELECT 1
            FROM sysindexes si
            INNER JOIN sysobjects so
                   ON so.id = si.id
           WHERE si.[Name] = N'source_curve_def_id_index' -- Index Name
             AND so.[Name] = N'source_price_curve')  -- Table Name
BEGIN
    DROP INDEX [source_curve_def_id_index] ON [dbo].[source_price_curve]
END
GO
CREATE CLUSTERED INDEX [source_curve_def_id_index] ON [dbo].[source_price_curve]
(
    [as_of_date] ASC,
    [source_curve_def_id] ASC,
    [maturity_date] ASC,
    [is_dst] ASC,
    [curve_source_value_id] ASC
) 
GO

-- **********************************************************************
-- Index IX_contract_group_detail on table contract_group_detail
-- **********************************************************************
IF EXISTS(SELECT 1
            FROM sysindexes si
            INNER JOIN sysobjects so
                   ON so.id = si.id
           WHERE si.[Name] = N'IX_contract_group_detail' -- Index Name
             AND so.[Name] = N'contract_group_detail')  -- Table Name
BEGIN
    DROP INDEX [IX_contract_group_detail] ON [dbo].[contract_group_detail]
END
GO
CREATE UNIQUE INDEX [IX_contract_group_detail] ON [dbo].[contract_group_detail]
(
    [invoice_line_item_id] ASC,
    [contract_id] ASC,
    [Prod_type] ASC,
    [deal_type] ASC
) 
GO


