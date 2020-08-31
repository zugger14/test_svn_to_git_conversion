BEGIN TRAN 
ALTER TABLE broker_fees ADD counterparty_id INT 

ALTER TABLE broker_fees WITH CHECK ADD CONSTRAINT FK_broker_fees_source_counterparty FOREIGN KEY (counterparty_id) REFERENCES source_counterparty(source_counterparty_id)

SELECT * FROM broker_fees
COMMIT  