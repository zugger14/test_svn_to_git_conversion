IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('message_board') AND [name]='message_attachment')
	ALTER TABLE message_board add message_attachment VARCHAR(1000) 