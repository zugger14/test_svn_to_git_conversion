--IF EXISTS (SELECT * FROM information_schema.columns 
--				WHERE table_name ='event_trigger' AND column_name='modules_event_id')
--ALTER TABLE event_trigger ALTER COLUMN modules_event_id INT NULL


IF EXISTS (SELECT * FROM information_schema.columns 
				WHERE table_name ='workflow_event_message' AND column_name='event_trigger_id')
ALTER TABLE workflow_event_message ALTER COLUMN event_trigger_id INT NULL

--IF EXISTS (SELECT * FROM information_schema.columns 
--				WHERE table_name ='workflow_event_action' AND column_name='event_message_id')
--ALTER TABLE workflow_event_action ALTER COLUMN event_message_id INT NULL