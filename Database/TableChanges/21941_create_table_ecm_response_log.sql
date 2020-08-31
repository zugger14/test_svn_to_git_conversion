IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[ecm_response_log]') AND [type] IN (N'U'))
BEGIN
CREATE TABLE [dbo].[ecm_response_log] (
	[id] INT IDENTITY(1, 1) CONSTRAINT [pk_ecm_response_log_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
	[document_id] VARCHAR(100),
	[document_type] VARCHAR(10),
	[document_version] VARCHAR(25),
	[ebXML_message_id] VARCHAR(50),
	[state] VARCHAR(50),
	[timestamp] VARCHAR(30),
	[transfer_id] VARCHAR(100),
	[transmission_timestamp] VARCHAR(30),
	[conversation_id] VARCHAR(50),
	[sender_organisation] VARCHAR(50),
	[receiver_organisation] VARCHAR(50),
	[reason_code] VARCHAR(500),
	[reason_text] VARCHAR(4000),
	[create_ts] DATETIME DEFAULT(GETDATE()),
	[create_user] VARCHAR(50) DEFAULT([dbo].[FNADBUser]()),
) ON [PRIMARY]
END
GO