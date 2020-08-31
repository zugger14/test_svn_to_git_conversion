if OBJECT_ID('forward_curve_mapping') is null
begin
CREATE TABLE [dbo].[forward_curve_mapping](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[book_id] [int] NULL,
	[commodity_id] [int] NULL,
	[curve_id] [int] NULL,
	[country_id] [int] NULL,
	[base_uom_id] [int] NULL,
	[base_curve_id] [int] NULL
) ON [PRIMARY]


INSERT INTO [dbo].[forward_curve_mapping]
           ([book_id]
           ,[commodity_id]
           ,[country_id]
           ,[base_uom_id]
           ,[base_curve_id])
   select
book.entity_id,-1,292068,1,5
	from source_system_book_map sbm            
		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
		left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
		where sb.entity_name='Gas'

		
INSERT INTO [dbo].[forward_curve_mapping]
           ([book_id]
           ,[commodity_id]
           ,[country_id]
           ,[base_uom_id]
           ,[base_curve_id])
   select
book.entity_id,-2,292068,1,76
	from source_system_book_map sbm            
		INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
		left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
		where sb.entity_name='Power'
end