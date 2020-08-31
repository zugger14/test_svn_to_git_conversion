DECLARE @ixp_rule_id INT

SELECT @ixp_rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = '5 Mins Meter Data'
EXEC spa_ixp_rules  @flag='d',@ixp_rules_id=@ixp_rule_id

SELECT @ixp_rule_id = ixp_rules_id FROM ixp_rules WHERE ixp_rules_name = '10 Mins Meter Data'
EXEC spa_ixp_rules  @flag='d',@ixp_rules_id=@ixp_rule_id
