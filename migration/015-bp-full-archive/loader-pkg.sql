-- Батч 015: партиційний завантажувач повного архіву великих BusinessProcess.
-- Ключ партиції — префікс Number (ДО-<42-знак поле>): deep-$skip таймаутить >3000,
-- $orderby ігнорується → startswith(Number,'ДО-'||lpad(k,39,'0')) = чанк ~1000
-- рядків (seq k*1000..k*1000+999) одним запитом (з ТЧ у фіді). Резюмовний
-- (RSD_LOAD_LOG), стоп за 5 порожніми чанками поспіль (gap-safe). NLS_LANG=.AL32UTF8.
declare n number;
begin
  select count(*) into n from user_tables where table_name='RSD_LOAD_LOG';
  if n=0 then execute immediate q'[
    create table RSD_LOAD_LOG(entity varchar2(80), chunk_k number, rows_got number,
      loaded_at timestamp default systimestamp,
      constraint RSD_LOAD_LOG_PK primary key(entity, chunk_k))]';
  end if;
end;
/
create or replace package RSD_BP_ARCHIVE as
  -- p_count = OData $count (для лог-прогресу + hardcap); фактичний стоп — за стриком
  procedure load(p_entity varchar2, p_enc varchar2, p_count number);
end;
/
create or replace package body RSD_BP_ARCHIVE as
  BASE  constant varchar2(120) := 'https://rv.entercom.ua:5683/bas_doc/odata/standard.odata/';
  DOENC constant varchar2(20)  := '%D0%94%D0%9E-';

  function fetch_chunk(p_enc varchar2, p_pfx varchar2) return clob is
    l clob;
  begin
    for attempt in 1..3 loop
      begin
        l := apex_web_service.make_rest_request(
               p_url => BASE||p_enc||'?$format=json&$top=1000&$filter=startswith%28Number%2C%27'||p_pfx||'%27%29%20eq%20true',
               p_http_method=>'GET', p_credential_static_id=>'BAS_DOC_CRED', p_transfer_timeout=>600);
        return l;
      exception when others then
        if attempt=3 then raise; end if;
        dbms_session.sleep(3);
      end;
    end loop;
  end;

  procedure load(p_entity varchar2, p_enc varchar2, p_count number) is
    l_clob clob; l_got number; l_empty pls_integer := 0; l_k pls_integer := 0;
    l_done pls_integer; l_total number := 0; l_hardcap pls_integer := ceil(p_count/1000)*3 + 50;
  begin
    loop
      -- resume: replay already-logged chunks
      select count(*) into l_done from rsd_load_log where entity=p_entity and chunk_k=l_k;
      if l_done>0 then
        select rows_got into l_got from rsd_load_log where entity=p_entity and chunk_k=l_k;
        l_total := l_total + l_got;
        l_empty := case when l_got=0 then l_empty+1 else 0 end;
        l_k := l_k+1;
        exit when l_empty>=5 or l_k>l_hardcap;
        continue;
      end if;
      l_clob := fetch_chunk(p_enc, DOENC||lpad(to_char(l_k),39,'0'));
      select count(*) into l_got from json_table(l_clob,'$.value[*]' columns(rk varchar2(36) path '$.Ref_Key'));
      if l_got>0 then
        merge into rsd_odata_raw t using (
          select rk, dc from json_table(l_clob,'$.value[*]' columns(
                 rk varchar2(36) path '$.Ref_Key', dc clob format json path '$'))
        ) s on (t.entity=p_entity and t.ref_key=s.rk)
        when matched then update set t.doc=s.dc, t.loaded_at=systimestamp
        when not matched then insert(entity,ref_key,doc) values(p_entity,s.rk,s.dc);
      end if;
      insert into rsd_load_log(entity,chunk_k,rows_got) values(p_entity,l_k,l_got);
      commit;
      l_total := l_total + l_got;
      l_empty := case when l_got=0 then l_empty+1 else 0 end;
      dbms_output.put_line(to_char(systimestamp,'HH24:MI:SS')||' '||p_entity||' chunk '||l_k||' -> '||l_got||'  (total '||l_total||'/'||p_count||')');
      l_k := l_k+1;
      exit when l_empty>=5 or l_k>l_hardcap;
    end loop;
    dbms_output.put_line('== '||p_entity||' DONE: staged '||l_total||' (OData $count '||p_count||') ==');
  end;
end;
/
show errors package body RSD_BP_ARCHIVE
