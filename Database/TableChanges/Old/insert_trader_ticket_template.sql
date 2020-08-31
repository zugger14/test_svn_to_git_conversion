TRUNCATE TABLE trader_ticket_template 

INSERT INTO trader_ticket_template (template_id,template_name,template_desc,template_filename,commodity_id,deal_type)
VALUES (1, 'Gas Template', 'Gas Template', 'spa_html_Trade_Ticket_gas.php', 511, NULL )

INSERT INTO trader_ticket_template (template_id,template_name,template_desc,template_filename,commodity_id,deal_type)
VALUES (2, 'Power Template', 'Power Template', 'spa_html_Trade_Ticket_power.php', 11, NULL )

INSERT INTO trader_ticket_template (template_id,template_name,template_desc,template_filename,commodity_id,deal_type)
VALUES (3, 'Options Template', 'Options Template', 'spa_html_Trade_Ticket_options.php', NULL, 3 )


--INSERT INTO trader_ticket_template (template_id,template_name,template_desc,template_filename,commodity_id,deal_type)
--VALUES (4, 'Options2 Template', 'Options2 Template', 'spa_html_Trade_Ticket_options2.php', 11, 3 )

--DELETE FROM trader_ticket_template WHERE template_id = 4

