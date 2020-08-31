/****** Object:  Table [dbo].[round_value]    Script Date: 04/10/2009 14:35:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[round_value]') AND type in (N'U'))
DROP TABLE [dbo].[round_value]
GO
CREATE TABLE [dbo].[round_value](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[value] [int] NULL,
 CONSTRAINT [PK_round_value] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


insert into round_value values(1)
insert into round_value values(2)
insert into round_value values(3)
insert into round_value values(4)
insert into round_value values(5)
insert into round_value values(6)
insert into round_value values(7)
insert into round_value values(8)
insert into round_value values(9)
insert into round_value values(10)

--select * from round_value

