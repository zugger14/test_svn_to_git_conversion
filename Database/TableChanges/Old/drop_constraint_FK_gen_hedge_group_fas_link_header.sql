begin try
alter table gen_hedge_group drop constraint FK_gen_hedge_group_fas_link_header
end try
begin catch
print 'FK_gen_hedge_group_fas_link_header not found'
end catch