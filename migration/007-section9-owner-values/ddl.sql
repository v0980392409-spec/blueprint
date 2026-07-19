-- Батч 007 (§9): рішення власника 2026-07-19.
-- Група 2: OWNER_TYPE до поліморфних власників. Група 4a: типізовані VALUE_*
-- замість нетипізованого Значение у ТЧ доп.реквізитів (патерн характеристик).
-- Ідемпотентно (ADD ... лише якщо колонки немає). NLS_LANG=.AL32UTF8.

declare
  procedure add_col(p_tab varchar2, p_col varchar2, p_def varchar2, p_comment varchar2 := null) is
    n number;
  begin
    select count(*) into n from user_tab_columns where table_name=p_tab and column_name=p_col;
    if n=0 then
      execute immediate 'alter table '||p_tab||' add '||p_col||' '||p_def;
      if p_comment is not null then
        execute immediate 'comment on column '||p_tab||'.'||p_col||' is '''||p_comment||'''';
      end if;
    end if;
  end;
begin
  add_col('RSD_BANKOVSKIESCHETA','OWNER_TYPE','VARCHAR2(60 CHAR)','Тип власника (поліморфний, з OWNER_ID)');
  add_col('RSD_NASTROI_KIRABOCHIKHMESTPOLZOVATELEI','OWNER_TYPE','VARCHAR2(60 CHAR)','Тип власника (поліморфний, з OWNER_ID)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_BANKOVSKIESCHETA_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_VIDYRABOT_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_VNESHNIEPOLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_DOLZHNOSTI_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_KONTRAGENTY_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_NOMENKLATURA_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_PAPKIFAI_LOV_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_POLZOVATELI_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_TYPE','VARCHAR2(30 CHAR)','Тип значення (String/Number/Date/Boolean/Ref)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_STRING','VARCHAR2(2000 CHAR)','Значення (рядок)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_NUMBER','NUMBER','Значення (число)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_DATE','DATE','Значення (дата)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_BOOL','BOOLEAN','Значення (булеве)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_REF_TYPE','VARCHAR2(60 CHAR)','Значення-посилання (тип)');
  add_col('RSD_STRUKTURAPREDPRIYATIYA_DOPOLNITELNYEREKVIZITY','VALUE_REF_ID','NUMBER','Значення-посилання (id)');
end;
/
