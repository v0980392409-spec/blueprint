-- Батч 014: reporting-view'и для blueprint-track кластера «Погодження».
-- Резолвлять FK-ідентифікатори у людські підписи (для IR/faceted та детальних
-- звітів), бо генератор blueprint над плоским джерелом надійніший, ніж над
-- складним join-SQL. Форми лишаються над БАЗОВИМИ таблицями (LOV-редагування).
-- NLS_LANG=.AL32UTF8 ОБОВʼЯЗКОВО — у view є кириличні літерали типів.

-- 1. Шапка: RSD_SOGLASOVANIE + імена Автора/Стану/Результату/Варіанту/Важливості
CREATE OR REPLACE VIEW RSD_V_SOGLASOVANIE AS
SELECT s.ID,
       s.LEGACY_REF,
       s.NAIMENOVANIE,
       s.DOC_DATE,
       s.DATANACHALA,
       s.DATAZAVERSHENIYA,
       s.SROKISPOLNENIYAPROTSESSA,
       s.OPISANIE,
       s.AVTOR_ID,
       a.NAME              AS AVTOR_NAME,
       s.SOSTOYANIE_ID,
       e_sost.NAME         AS SOSTOYANIE_NAME,
       s.REZULTATSOGLASOVANIYA_ID,
       e_rez.NAME          AS REZULTAT_NAME,
       s.VARIANTSOGLASOVANIYA_ID,
       e_var.NAME          AS VARIANT_NAME,
       s.VAZHNOST_ID,
       e_vazh.NAME         AS VAZHNOST_NAME,
       CASE WHEN s.POVTORITSOGLASOVANIE IS TRUE THEN 'Так' ELSE 'Ні' END AS POVTORIT_LABEL,
       CASE WHEN s.PODPISYVATEP        IS TRUE THEN 'Так' ELSE 'Ні' END AS PODPISYVAT_LABEL
FROM       RSD_SOGLASOVANIE s
LEFT JOIN  RSD_POLZOVATELI  a      ON a.ID      = s.AVTOR_ID
LEFT JOIN  RSD_ENUMS        e_sost ON e_sost.ID = s.SOSTOYANIE_ID
LEFT JOIN  RSD_ENUMS        e_rez  ON e_rez.ID  = s.REZULTATSOGLASOVANIYA_ID
LEFT JOIN  RSD_ENUMS        e_var  ON e_var.ID  = s.VARIANTSOGLASOVANIYA_ID
LEFT JOIN  RSD_ENUMS        e_vazh ON e_vazh.ID = s.VAZHNOST_ID
WHERE      s.IS_DELETED = FALSE;

COMMENT ON TABLE RSD_V_SOGLASOVANIE IS 'Погодження — звітна проекція (імена резолвлені)';

-- 2. Аркуш погодження (виконавці): поліморфний виконавець → Роль/Користувач + імʼя
CREATE OR REPLACE VIEW RSD_V_SOGLAS_ISPOLNITELI AS
SELECT i.ID,
       i.OWNER_ID,
       i.LINE_NO,
       CASE i.ISPOLNITEL_REF_TYPE
            WHEN 'Catalog.Пользователи' THEN 'Користувач'
            WHEN 'Catalog.ПолныеРоли'   THEN 'Роль'
            ELSE i.ISPOLNITEL_REF_TYPE
       END AS ISPOLNITEL_TYPE,
       CASE WHEN i.ISPOLNITEL_REF_TYPE = 'Catalog.Пользователи'
            THEN (SELECT p.NAME FROM RSD_POLZOVATELI p WHERE p.ID = i.ISPOLNITEL_REF_ID)
       END AS ISPOLNITEL_NAME,
       i.PORYADOKSOGLASOVANIYA_ID,
       e_por.NAME AS PORYADOK_NAME,
       CASE WHEN i.PROYDEN IS TRUE THEN 'Так' ELSE 'Ні' END AS PROYDEN_LABEL,
       i.SROKISPOLNENIYA
FROM       RSD_SOGLASOVANIE_ISPOLNITELI i
LEFT JOIN  RSD_ENUMS e_por ON e_por.ID = i.PORYADOKSOGLASOVANIYA_ID;

COMMENT ON TABLE RSD_V_SOGLAS_ISPOLNITELI IS 'Аркуш погодження — виконавці (поліморф резолвлено)';

-- 3. Результати погодження: рішення → підпис
CREATE OR REPLACE VIEW RSD_V_SOGLAS_REZULTATY AS
SELECT r.ID,
       r.OWNER_ID,
       r.LINE_NO,
       r.NOMERITERATSII,
       r.REZULTATSOGLASOVANIYA_ID,
       e.NAME AS REZULTAT_NAME
FROM       RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA r
LEFT JOIN  RSD_ENUMS e ON e.ID = r.REZULTATSOGLASOVANIYA_ID;

COMMENT ON TABLE RSD_V_SOGLAS_REZULTATY IS 'Результати погодження — рішення по ітераціях';
