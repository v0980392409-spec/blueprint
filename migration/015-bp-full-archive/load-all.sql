-- Батч 015: драйвер повного архіву — 4 решти великих BP (Утверждение вже завантажено).
-- Порядок: менші→більші. Кожна сутність у своєму блоці з fresh apex_session.
-- Резюмовний (RSD_LOAD_LOG). Запускати detached (docker exec -d), NLS_LANG=.AL32UTF8.
set define off serveroutput on size unlimited
set linesize 200 pagesize 0 feedback off
begin apex_session.create_session(p_app_id=>200,p_page_id=>1,p_username=>'CLAUDE');
  RSD_BP_ARCHIVE.load('BusinessProcess.Исполнение',
    'BusinessProcess_%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5', 11942); end;
/
begin apex_session.create_session(p_app_id=>200,p_page_id=>1,p_username=>'CLAUDE');
  RSD_BP_ARCHIVE.load('BusinessProcess.Ознакомление',
    'BusinessProcess_%D0%9E%D0%B7%D0%BD%D0%B0%D0%BA%D0%BE%D0%BC%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5', 50430); end;
/
begin apex_session.create_session(p_app_id=>200,p_page_id=>1,p_username=>'CLAUDE');
  RSD_BP_ARCHIVE.load('BusinessProcess.КомплексныйПроцесс',
    'BusinessProcess_%D0%9A%D0%BE%D0%BC%D0%BF%D0%BB%D0%B5%D0%BA%D1%81%D0%BD%D1%8B%D0%B9%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81', 108378); end;
/
begin apex_session.create_session(p_app_id=>200,p_page_id=>1,p_username=>'CLAUDE');
  RSD_BP_ARCHIVE.load('BusinessProcess.Согласование',
    'BusinessProcess_%D0%A1%D0%BE%D0%B3%D0%BB%D0%B0%D1%81%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5', 185044); end;
/
prompt == LOAD-ALL DRIVER FINISHED ==
exit
