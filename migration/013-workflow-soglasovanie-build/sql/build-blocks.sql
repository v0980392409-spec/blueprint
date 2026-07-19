-- =====================================================================
-- Батч 013 — блоки для складання APEX Workflow «SOGLASOVANIE» у Designer
-- =====================================================================
-- Це НЕ цілісний скрипт для запуску. Це джерело для копіювання в поля
-- Workflow Designer / Task Definition (app 200 «BUDYNKY», схема BAS_REVERSE).
--
-- Прив'язка версії workflow: Data Source = Table RSD_SOGLASOVANIE, PK = ID.
-- → у PL/SQL доступні bind-змінні рядка: :ID, :NAIMENOVANIE, :SOSTOYANIE_ID …
--
-- ВАЖЛИВО (перевірено в Designer): зв'язки (Connections) мають лише Type
-- Normal / Error — гілкувати на зв'язках НЕ можна. Human Task може мати тільки
-- ОДИН вихід Normal. Тому маршрут ЛІНІЙНИЙ, а рішення (погоджено/відхилено)
-- обираємо В КОДІ останньої активності за значенням, яке Human Task кладе у
-- змінну (поле Human Task → Result → Outcome = змінна V_OUTCOME).
--   Human Task Approval видає у V_OUTCOME: 'APPROVED' або 'REJECTED'.
--
-- Потрібна ОДНА змінна workflow: V_OUTCOME (VARCHAR2).
--
-- Значення (RSD_ENUMS, живі): результат 747 Погоджено · 746 Не погоджено;
--   стан 768 Активний.
-- =====================================================================


-- ---------------------------------------------------------------------
-- [C.START] Активність «Позначити активним»  (Execute Code / PL/SQL)
-- ---------------------------------------------------------------------
update RSD_SOGLASOVANIE
   set SOSTOYANIE_ID = 768,          -- Активний
       DATANACHALA   = systimestamp
 where ID = :ID;


-- ---------------------------------------------------------------------
-- [C.APPROVE] Активність «Погодження»  (Human Task - Create)
-- ---------------------------------------------------------------------
--   Human Task → Definition               : Погодження  (TASK_SOGLASOVANIE)
--   Human Task → Details Primary Key Item : ID
--   Result → Outcome                       : V_OUTCOME   ← змінна, куди ляже результат
--   Result → Owner                         : (порожньо)
--   Один вихідний зв'язок (Normal) → до «Записати результат».


-- ---------------------------------------------------------------------
-- [C.RECORD] Активність «Записати результат»  (Execute Code / PL/SQL) → End
-- ---------------------------------------------------------------------
-- Рішення обираємо ТУТ за :V_OUTCOME (лінійно, без гілок на зв'язках).
declare
  l_result number := case when :V_OUTCOME = 'REJECTED' then 746   -- Не погоджено
                          else 747 end;                           -- Погоджено
begin
  update RSD_SOGLASOVANIE
     set REZULTATSOGLASOVANIYA_ID = l_result,
         DATAZAVERSHENIYA         = systimestamp
   where ID = :ID;

  insert into RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA
        (OWNER_ID, LINE_NO, NOMERITERATSII, REZULTATSOGLASOVANIYA_ID)
  select :ID, nvl(max(LINE_NO),0)+1, 1, l_result
    from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA
   where OWNER_ID = :ID;
end;


-- ---------------------------------------------------------------------
-- ПРОДАКШН (довідково): учасники Task Definition з виконавців процесу.
-- Пілот бере статичних CLAUDE/VIKTOR (Catalog.ПолныеРоли не мігровано;
-- Catalog.Пользователи → RSD_POLZOVATELI, але IDENTIFIKATORPOLZOVATELYAIB
-- ще не звірено з APEX-акаунтами — немає identity-bridge).
--   select u.IDENTIFIKATORPOLZOVATELYAIB as username
--     from RSD_SOGLASOVANIE_ISPOLNITELI i
--     join RSD_POLZOVATELI u
--       on i.ISPOLNITEL_REF_TYPE = 'Catalog.Пользователи' and u.ID = i.ISPOLNITEL_REF_ID
--    where i.OWNER_ID = :ID and u.IDENTIFIKATORPOLZOVATELYAIB is not null;
