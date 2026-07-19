prompt --application/shared_components/workflow/task_definitions/погодження
begin
wwv_flow_imp_shared.create_task_def(
 p_id=>wwv_flow_imp.id(10359744862155157)
,p_name=>unistr('\041F\043E\0433\043E\0434\0436\0435\043D\043D\044F')
,p_static_id=>'TASK_SOGLASOVANIE'
,p_subject=>unistr('\041F\043E\0433\043E\0434\0436\0435\043D\043D\044F: &NAIMENOVANIE.')
,p_task_type=>'APPROVAL'
,p_priority=>3
,p_initiator_can_complete=>false
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(10360563290170580)
,p_task_def_id=>wwv_flow_imp.id(10359744862155157)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'STATIC'
,p_value=>'CLAUDE'
);
wwv_flow_imp_shared.create_task_def_participant(
 p_id=>wwv_flow_imp.id(10360829358171921)
,p_task_def_id=>wwv_flow_imp.id(10359744862155157)
,p_participant_type=>'POTENTIAL_OWNER'
,p_identity_type=>'USER'
,p_value_type=>'STATIC'
,p_value=>'VIKTOR'
);
end;
/
prompt --application/shared_components/workflow/workflows/погодження
begin
wwv_flow_imp_shared.create_workflow(
 p_id=>wwv_flow_imp.id(8569503572107037)
,p_name=>unistr('\041F\043E\0433\043E\0434\0436\0435\043D\043D\044F')
,p_static_id=>'SOGLASOVANIE'
,p_title=>'New'
);
wwv_flow_imp_shared.create_workflow_version(
 p_id=>wwv_flow_imp.id(8569654544107038)
,p_workflow_id=>wwv_flow_imp.id(8569503572107037)
,p_version=>'New'
,p_state=>'ACTIVE'
,p_query_type=>'TABLE'
,p_query_table=>'RSD_SOGLASOVANIE'
,p_pk_column=>'ID'
);
wwv_flow_imp_shared.create_workflow_variable(
 p_id=>wwv_flow_imp.id(10368667485924914)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_label=>'V_OUTCOME'
,p_static_id=>'V_OUTCOME'
,p_direction=>'VARIABLE'
,p_data_type=>'VARCHAR2'
,p_value_type=>'NULL'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(8569978876107041)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_name=>'End'
,p_static_id=>'end_1'
,p_display_sequence=>70
,p_activity_type=>'NATIVE_WORKFLOW_END'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'end_state', 'COMPLETED')).to_clob
,p_diagram=>'{"position":{"x":1230,"y":1300}}'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(8569790611107039)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_name=>'Start'
,p_static_id=>'start_1'
,p_display_sequence=>10
,p_activity_type=>'NATIVE_WORKFLOW_START'
,p_diagram=>'{"position":{"x":700,"y":970}}'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(10368274317924910)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_name=>unistr('\0417\0430\043F\0438\0441\0430\0442\0438 \0440\0435\0437\0443\043B\044C\0442\0430\0442')
,p_static_id=>unistr('\0437\0430\043F\0438\0441\0430\0442\0438-\0440\0435\0437\0443\043B\044C\0442\0430\0442')
,p_display_sequence=>60
,p_activity_type=>'NATIVE_PLSQL'
,p_activity_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_result number := case when :V_OUTCOME = ''REJECTED'' then 746 else 747 end;',
'begin',
'  update RSD_SOGLASOVANIE',
'     set REZULTATSOGLASOVANIYA_ID = l_result, DATAZAVERSHENIYA = systimestamp',
'   where ID = :ID;',
'  insert into RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA (OWNER_ID,LINE_NO,NOMERITERATSII,REZULTATSOGLASOVANIYA_ID)',
'  select :ID, nvl(max(LINE_NO),0)+1, 1, l_result from RSD_SOGLASOVANIE_REZULTATYSOGLASOVANIYA where OWNER_ID=:ID;',
'end;'))
,p_activity_code_language=>'PLSQL'
,p_location=>'LOCAL'
,p_diagram=>'{"position":{"x":1150,"y":1120},"z":7}'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(8570597207107047)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_name=>unistr('\041F\043E\0433\043E\0434\0436\0435\043D\043D\044F')
,p_static_id=>unistr('\043F\043E\0433\043E\0434\0436\0435\043D\043D\044F')
,p_display_sequence=>50
,p_activity_type=>'NATIVE_CREATE_TASK'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'details_primary_key_item', 'ID',
  'outcome_item', 'V_OUTCOME',
  'task_definition_id', wwv_flow_imp.id(10359744862155157))).to_clob
,p_diagram=>'{"position":{"x":1150,"y":970},"z":4}'
);
wwv_flow_imp_shared.create_workflow_activity(
 p_id=>wwv_flow_imp.id(8569862383107040)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_name=>unistr('\041F\043E\0437\043D\0430\0447\0438\0442\0438 \0430\043A\0442\0438\0432\043D\0438\043C')
,p_static_id=>unistr('\043F\043E\0437\043D\0430\0447\0438\0442\0438-\0430\043A\0442\0438\0432\043D\0438\043C')
,p_display_sequence=>20
,p_activity_type=>'NATIVE_PLSQL'
,p_activity_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'update RSD_SOGLASOVANIE',
unistr('   set SOSTOYANIE_ID = 768,          -- \0410\043A\0442\0438\0432\043D\0438\0439'),
'       DATANACHALA   = systimestamp',
' where ID = :ID;'))
,p_activity_code_language=>'PLSQL'
,p_location=>'LOCAL'
,p_diagram=>'{"position":{"x":880,"y":970},"z":2}'
);
wwv_flow_imp_shared.create_workflow_transition(
 p_id=>wwv_flow_imp.id(8570031874107042)
,p_name=>'New'
,p_transition_type=>'NORMAL'
,p_from_activity_id=>wwv_flow_imp.id(8569790611107039)
,p_to_activity_id=>wwv_flow_imp.id(8569862383107040)
,p_diagram=>'{"source":{"args":{"dx":"50%","dy":"50%","rotate":true},"name":"topLeft"},"target":{"args":{"dx":"50%","dy":"50%","rotate":true},"name":"topLeft"},"vertices":[],"z":1,"label":{"distance":0.5,"offset":0}}'
);
wwv_flow_imp_shared.create_workflow_transition(
 p_id=>wwv_flow_imp.id(8570654085107048)
,p_name=>'New'
,p_transition_type=>'NORMAL'
,p_from_activity_id=>wwv_flow_imp.id(10368274317924910)
,p_to_activity_id=>wwv_flow_imp.id(8569978876107041)
,p_diagram=>'{"source":{"args":{"dx":"50%","dy":"100%","rotate":true},"name":"topLeft"},"target":{"name":"topLeft","args":{"dx":"50%","dy":"0%","rotate":true}},"vertices":[],"z":5,"label":{"distance":0.5,"offset":0}}'
);
wwv_flow_imp_shared.create_workflow_transition(
 p_id=>wwv_flow_imp.id(10368190999924909)
,p_name=>unistr('\041F\043E\0433\043E\0434\0436\0435\043D\043E')
,p_transition_type=>'NORMAL'
,p_from_activity_id=>wwv_flow_imp.id(8570597207107047)
,p_to_activity_id=>wwv_flow_imp.id(10368274317924910)
,p_diagram=>'{"source":{},"target":{},"vertices":[],"z":6,"label":{"distance":0.5,"offset":0}}'
);
wwv_flow_imp_shared.create_workflow_transition(
 p_id=>wwv_flow_imp.id(8570164332107043)
,p_name=>'New'
,p_transition_type=>'NORMAL'
,p_from_activity_id=>wwv_flow_imp.id(8569862383107040)
,p_to_activity_id=>wwv_flow_imp.id(8570597207107047)
,p_diagram=>'{"source":{"args":{"dx":"50%","dy":"50%","rotate":true},"name":"topLeft"},"target":{},"vertices":[],"z":1,"label":{"distance":0.5,"offset":0}}'
);
wwv_flow_imp_shared.create_workflow_participant(
 p_id=>wwv_flow_imp.id(10368732387924915)
,p_workflow_version_id=>wwv_flow_imp.id(8569654544107038)
,p_participant_type=>'OWNER'
,p_name=>'VIKTOR'
,p_identity_type=>'USER'
,p_value_type=>'STATIC'
,p_value=>'VIKTOR'
);
end;
/
