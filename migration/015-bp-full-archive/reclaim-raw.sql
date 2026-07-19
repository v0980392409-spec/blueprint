-- Батч 015: вивільнення місця — RAW.doc LOB роздувся до ~9ГБ (365k BP-записів з ТЧ),
-- ударив Free-ліміт 12ГБ (ORA-12954) під час проекції. RAW — одноразовий staging;
-- видаляємо вже спроектовані великі сутності + shrink LOB. NLS_LANG=.AL32UTF8, BAS_REVERSE.
set define off serveroutput on size unlimited
set feedback on timing on
alter table RSD_ODATA_RAW enable row movement;
delete from RSD_ODATA_RAW where entity in ('BusinessProcess.Согласование','BusinessProcess.КомплексныйПроцесс');
commit;
prompt == DELETE+COMMIT DONE, shrinking LOB ==
alter table RSD_ODATA_RAW shrink space cascade;
prompt == SHRINK DONE ==
exit
