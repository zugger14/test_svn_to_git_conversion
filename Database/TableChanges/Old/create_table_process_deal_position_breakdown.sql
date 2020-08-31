IF object_id('process_deal_position_breakdown') IS NOT NULL
DROP TABLE dbo.process_deal_position_breakdown

GO

CREATE TABLE dbo.process_deal_position_breakdown (
source_deal_header_id INT,
create_user	varchar(30),
create_ts	datetime	,
process_status TINYINT NOT null
)
