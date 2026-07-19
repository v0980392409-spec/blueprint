-- Батч 015: перевірка повного архіву — header count == OData $count, ТЧ масштаб, 0 INVALID.
set pagesize 200 feedback off linesize 160
col entity format a26
col header format 999990
col odata_count format 999990
prompt === headers vs OData $count ===
with tgt as (
  select 'Согласование' e, 185044 c from dual union all
  select 'КомплексныйПроцесс', 108378 from dual union all
  select 'Ознакомление', 50430 from dual union all
  select 'Исполнение', 11942 from dual union all
  select 'Утверждение', 9508 from dual)
select tgt.e entity,
  case tgt.e
    when 'Согласование' then (select count(*) from RSD_SOGLASOVANIE)
    when 'КомплексныйПроцесс' then (select count(*) from RSD_KOMPLEKSNYYPROTSESS)
    when 'Ознакомление' then (select count(*) from RSD_OZNAKOMLENIE)
    when 'Исполнение' then (select count(*) from RSD_ISPOLNENIE)
    when 'Утверждение' then (select count(*) from RSD_UTVERZHDENIE) end header,
  tgt.c odata_count,
  case when (case tgt.e
    when 'Согласование' then (select count(*) from RSD_SOGLASOVANIE)
    when 'КомплексныйПроцесс' then (select count(*) from RSD_KOMPLEKSNYYPROTSESS)
    when 'Ознакомление' then (select count(*) from RSD_OZNAKOMLENIE)
    when 'Исполнение' then (select count(*) from RSD_ISPOLNENIE)
    when 'Утверждение' then (select count(*) from RSD_UTVERZHDENIE) end) = tgt.c then 'OK' else 'MISMATCH' end status
from tgt order by tgt.c desc;
prompt === total ТЧ rows across the 5 process families ===
select 'RSD_* process rows total (header+ТЧ): '||sum(num_rows) from user_tables
 where (table_name like 'RSD_SOGLASOVANIE%' or table_name like 'RSD_KOMPLEKSNYYPROTSESS%'
     or table_name like 'RSD_OZNAKOMLENIE%' or table_name like 'RSD_ISPOLNENIE%'
     or table_name like 'RSD_UTVERZHDENIE%');
prompt === INVALID objects ===
select 'INVALID: '||count(*) from user_objects where status='INVALID';
exit
