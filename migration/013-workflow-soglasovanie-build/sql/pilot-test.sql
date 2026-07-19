-- =====================================================================
-- Батч 013 — пілотний прогін Workflow «SOGLASOVANIE» (наскрізний, headless)
-- =====================================================================
-- ПЕРЕВІРЕНО НА СТЕНДІ: наскрізь працює (екземпляр COMPLETED, RSD_SOGLASOVANIE=747).
-- Запускати ПІСЛЯ складання + Save + Activate у Designer.
-- Схема запуску: BAS_REVERSE (не sysdba) — workflow-рантайму потрібен APEX-контекст:
--   ssh apex-vps 'docker exec -i apex-ords /opt/oracle/sqlcl/bin/sql \
--     BAS_REVERSE/<pwd>@//db:1521/FREEPDB1' < pilot-test.sql
--   <pwd> — /root/apex-credentials.txt, рядок 'schema BAS_REVERSE' (поле 4).
--
-- ТРИ БОЙОВІ УРОКИ (інакше «не спрацювало»):
--   1) Завершує НЕ-ініціатор. Ініціатор (CLAUDE) заблокований «Initiator Can Complete=OFF»
--      (розділення обов'язків) → ORA-20987 «не авторизовано». Стартуємо від CLAUDE, погоджує VIKTOR.
--   2) Задача СТВОРЮЄТЬСЯ асинхронно після start_workflow → не брати max(task_id) наосліп
--      (схопиш стару). Запам'ятати baseline і опитувати появу НОВОЇ (task_id > baseline).
--   3) Продовження ПІСЛЯ complete теж асинхронне → опитувати екземпляр до COMPLETED, потім читати рядок.
--
-- Ціль — процес ID=94. Скидання для повтору — у кінці файлу.
-- =====================================================================
set serveroutput on size unlimited
set linesize 160 pagesize 100
variable g_instance  number
variable g_task_base number
variable g_task_id   number

prompt === СТАН ДО (ID=94) ===
select ID, SOSTOYANIE_ID, REZULTATSOGLASOVANIYA_ID as REZULT,
       to_char(DATAZAVERSHENIYA,'DD.MM.YYYY HH24:MI') as ZAVERSH
  from RSD_SOGLASOVANIE where ID = 94;

-- Крок 1 — baseline задач + старт workflow від ІНІЦІАТОРА (CLAUDE)
prompt === КРОК 1: старт workflow (initiator CLAUDE) ===
begin
  apex_session.create_session(p_app_id => 200, p_page_id => 1, p_username => 'CLAUDE');
  select nvl(max(task_id),0) into :g_task_base
    from apex_tasks where application_id = 200 and task_def_static_id = 'TASK_SOGLASOVANIE';
  :g_instance := apex_workflow.start_workflow(
                   p_application_id => 200,
                   p_static_id      => 'SOGLASOVANIE',
                   p_detail_pk      => '94',
                   p_initiator      => 'CLAUDE');
  dbms_output.put_line('workflow instance = ' || :g_instance || '   (task baseline=' || :g_task_base || ')');
  commit;
end;
/

-- Крок 2 — дочекатись НОВОЇ задачі (async) і завершити VIKTOR (не-ініціатор) APPROVED
prompt === КРОК 2: чекаємо нову задачу → VIKTOR APPROVED ===
declare
  l_task_id number;
begin
  for i in 1 .. 15 loop
    select max(task_id) into l_task_id
      from apex_tasks
     where application_id = 200 and task_def_static_id = 'TASK_SOGLASOVANIE' and task_id > :g_task_base;
    exit when l_task_id is not null;
    dbms_session.sleep(2);
  end loop;
  :g_task_id := l_task_id;
  dbms_output.put_line('нова задача = ' || l_task_id);

  apex_session.create_session(p_app_id => 200, p_page_id => 1, p_username => 'VIKTOR');
  apex_approval.complete_task(p_task_id => l_task_id, p_outcome => 'APPROVED', p_autoclaim => true);
  dbms_output.put_line('завершено APPROVED (VIKTOR)');
  commit;
end;
/

-- Крок 3 — дочекатися COMPLETED (async доопрацювання рушієм)
prompt === КРОК 3: чекаємо екземпляр COMPLETED ===
declare
  l_state varchar2(30);
begin
  for i in 1 .. 15 loop
    select max(state_code) into l_state
      from apex_workflows where application_id = 200 and workflow_id = :g_instance;
    exit when l_state = 'COMPLETED';
    dbms_session.sleep(2);
  end loop;
  dbms_output.put_line('workflow state = ' || l_state);
end;
/

-- Стан ПІСЛЯ — очікуємо REZULTATSOGLASOVANIYA_ID = 747 (Погоджено) + новий рядок ТЧ
prompt === СТАН ПІСЛЯ (очікуємо REZULT=747, DATAZAVERSHENIYA заповнено) ===
select ID, SOSTOYANIE_ID, REZULTATSOGLASOVANIYA_ID as REZULT,
       to_char(DATANACHALA,'DD.MM.YYYY HH24:MI') as NACHALO,
       to_char(DATAZAVERSHENIYA,'DD.MM.YYYY HH24:MI') as ZAVERSH
  from RSD_SOGLASOVANIE where ID = 94;
select LINE_NO, NOMERITERATSII, REZULTATSOGLASOVANIYA_ID
  from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA where OWNER_ID = 94 order by LINE_NO;


-- =====================================================================
-- СКИДАННЯ для повторного прогону (розкоментувати й виконати):
-- =====================================================================
-- delete from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA where OWNER_ID = 94 and REZULTATSOGLASOVANIYA_ID = 747 and NOMERITERATSII = 1;
-- update RSD_SOGLASOVANIE set REZULTATSOGLASOVANIYA_ID = null, DATAZAVERSHENIYA = null where ID = 94;
-- commit;
-- (Кожен прогін стартує НОВИЙ екземпляр і додає рядок ТЧ; старі екземпляри/задачі —
--  прибрати через App Builder → Monitor Activity, або apex_workflow.clear_test_data.)
