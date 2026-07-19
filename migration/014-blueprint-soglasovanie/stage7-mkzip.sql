-- Stage 7 (частина 1): blueprint.md → APEXlang zip через APEX_GENDEV.PROCESS_BLUEPRINT.
-- Читає /tmp/blueprint.md (BP_TMP_DIR=/tmp у контейнері apex-db, UTF-8), викликає
-- процедуру, друкує parsing-log (має бути NULL = чисто), пише /tmp/apexlang.zip.
-- Запускати як BAS_REVERSE (parsing schema), NLS_LANG=.AL32UTF8.
set serveroutput on size unlimited
whenever sqlerror exit failure
declare
    l_bp      clob;
    l_log     clob;
    l_zip     blob;
    l_bfile   bfile := bfilename('BP_TMP_DIR', 'blueprint.md');
    l_dest    integer := 1;
    l_src     integer := 1;
    l_csid    integer := nls_charset_id('AL32UTF8');
    l_lang    integer := dbms_lob.default_lang_ctx;
    l_warn    integer;
begin
    dbms_lob.createtemporary(l_bp, true);
    dbms_lob.fileopen(l_bfile, dbms_lob.file_readonly);
    dbms_lob.loadclobfromfile(l_bp, l_bfile, dbms_lob.lobmaxsize,
                              l_dest, l_src, l_csid, l_lang, l_warn);
    dbms_lob.fileclose(l_bfile);
    dbms_output.put_line('blueprint chars=' || dbms_lob.getlength(l_bp) || ' load_warn=' || l_warn);

    apex_gendev.process_blueprint(p_blueprint   => l_bp,
                                  p_parsing_log => l_log,
                                  p_apexlang_zip => l_zip);

    if l_log is not null and dbms_lob.getlength(l_log) > 0 then
        dbms_output.put_line('=== PARSING LOG (NOT NULL — розбирати) ===');
        dbms_output.put_line(dbms_lob.substr(l_log, 24000, 1));
    else
        dbms_output.put_line('=== parsing log NULL — чисто ===');
    end if;

    if l_zip is not null and dbms_lob.getlength(l_zip) > 0 then
        declare
            l_file utl_file.file_type;
            l_buf  raw(32767);
            l_amt  binary_integer := 32767;
            l_pos  integer := 1;
            l_len  integer := dbms_lob.getlength(l_zip);
        begin
            l_file := utl_file.fopen('BP_TMP_DIR', 'apexlang.zip', 'wb', 32767);
            while l_pos <= l_len loop
                l_amt := least(32767, l_len - l_pos + 1);
                dbms_lob.read(l_zip, l_amt, l_pos, l_buf);
                utl_file.put_raw(l_file, l_buf, true);
                l_pos := l_pos + l_amt;
            end loop;
            utl_file.fclose(l_file);
            dbms_output.put_line('zip bytes=' || l_len || ' -> /tmp/apexlang.zip');
        end;
    else
        dbms_output.put_line('!!! zip NULL/порожній — blueprint не оброблено');
    end if;
end;
/
exit
