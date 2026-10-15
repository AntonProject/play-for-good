import 'dart:convert';
import 'dart:io';
import 'package:flutterflow_ai/src/internal_sdk.dart';
import 'package:flutterflow_ai/src/dsl/unknown_field_restore.dart';
import 'transfer.dart';

const variants='/Users/a123/a123-dev/portfolio-projects/play_for_good/docs/gg_logic/variants';
const reports='/private/tmp/pfg-ui-reports';
FFIdentifier id(String name,String seed)=>FFIdentifier(name:name,key:generateRandomAlphaNumericString(seedString:'pfg.gg.ui.$seed'));
FFValue literal(Object v)=>FFValue(inputValue:FFParameterValue(serializedValue:v.toString()));
FFVariable state(FFWidgetClass w,String name)=>varFromPageState(w.classModel.stateFields.firstWhere((f)=>f.parameter.identifier.name==name).parameter.identifier)..nodeKeyRef=FFNodeKeyReference(key:w.node.key);
FFVariable param(FFWidgetClass w,String name)=>FFVariable(source:FFVariableSource.WIDGET_CLASS_PARAMETER,baseVariable:FFBaseVariable(widgetClass:FFWidgetClassVariable(paramIdentifier:w.params.values.firstWhere((p)=>p.identifier.name==name).identifier)),nodeKeyRef:FFNodeKeyReference(key:w.node.key));
FFVariable jsonPath(FFVariable v,String path,FFBaseDataType type)=>v.deepCopy()..operations.add(FFVariableOperation(jsonPathOperation:FFJsonPathOperation(jsonPath:path,returnParameter:FFParameter(dataType:FFDataTypeV2(scalarType:type)))));
FFVariable func(FFProject p,String name,List<FFValue> args)=>FFVariable(source:FFVariableSource.FUNCTION_CALL,functionCall:FFFunctionCall(customFunction:findCustomFunction(p,name:name)!.identifier,values:args));

class BindNativeGg extends FlutterFlowAITask {
  @override String get name=>'bind-native-good-games-preview';
  @override Set<String> get dependsOn=>{'register-gg-rpc'};
  @override bool get skipPushWhenProjectUnchanged=>true;
  @override void run(TaskContext ctx) {
    final p=ctx.project;
    final overlay=jsonDecode(File('/private/tmp/pfg-ui-overlay.json').readAsStringSync()) as Map;
    final before=overlay['before'] as Map;final after=overlay['after'] as Map;
    final untouched={for(final e in p.widgetClasses.entries) if(!after.containsKey(e.value.name)) e.key:base64Encode(e.value.writeToBuffer())};
    for(final entry in after.entries) {
      final old=p.widgetClasses.values.firstWhere((w)=>w.name==entry.key);
      if(jsonEncode(old.toProto3Json())!=jsonEncode(before[entry.key])) {
        throw StateError('Cloud scope ${entry.key} changed since backup; refresh overlay before push.');
      }
      final next=FFWidgetClass()..mergeFromProto3Json(entry.value);
      restoreUnknownFields(old,next);
      p.widgetClasses[old.node.key]=next;
    }
    for(final name in ['GoodGamesPage','userProfilePage','userProfile']) {
      final w=p.widgetClasses.values.firstWhere((w)=>w.name==name);
      final isGames=name=='GoodGamesPage';
      final action=findCustomAction(p,name:'ggPreviewData')!;
      FFActionNode call(String suffix,String period,String category,String destination,{bool personal=false}) {
        final actionKey=id('previewAction',name+suffix).key;
        final outputName='ggPreview$suffix';
        final enabled=andConditionsVar([state(w,'ggUsePreviewData'),(varFromEnvironmentSecret('test')..baseVariable.environmentValue.identifier=findEnvironmentValue(p,'test')!.parameter.identifier)]).variable;
        final args=<String,FFValue>{
          'period':FFValue(variable:func(p,'ggPeriodKey',[FFValue(variable:state(w,period))])),
          'category':isGames?FFValue(variable:state(w,category)..defaultValue=FFParameterValue(serializedValue:'valuable')):literal('valuable'),
          'userId':FFValue(variable:isGames?varFromSupabaseAuthUser(FFAuthVariable_AuthProperty.USER_ID):param(w,'userId')),
          'page':isGames?FFValue(variable:state(w,personal?'pageNumberGames':'pageNumberUsers')..defaultValue=FFParameterValue(serializedValue:'1')):literal(1),
          'pageSize':literal(10),'enabled':FFValue(variable:enabled),
        };
        final values=FFFunctionCallValues();
        for(final a in action.arguments) values.arguments[a.identifier.key]=FFFunctionCallValues_FFArgument(value:args[a.identifier.name]);
        final root=FFActionNode(key:id('previewNode',name+suffix).key,action:FFAction(key:actionKey,customAction:FFCustomActionCall(customActionIdentifier:action.identifier,argumentValues:values),outputVariableName:outputName));
        final out=varFromActionOutput(actionKey:actionKey,outputName:outputName);
        final updates=[StateFieldUpdate.setFromVariable(destination,jsonPath(out,isGames&&!personal?r'$.ranking':r'$.profile',FFBaseDataType.JSON))];
        if(personal)updates.add(StateFieldUpdate.setFromVariable('ggHistory',jsonPath(out,r'$.games',FFBaseDataType.JSON)));
        // Resolve auto to the concrete key used by radio and dirty comparison.
        updates.add(StateFieldUpdate.setFromVariable(period,jsonPath(out,isGames&&!personal?r'$.ranking.period.key':r'$.profile.period.key',FFBaseDataType.String)));
        root.followUpAction=FFActionNode(key:id('setPreviewNode',name+suffix).key,action:Actions.updatePageState(p,widgetClassName:name,updates:updates));
        return root;
      }
      final blockRoot=call('Ranking',isGames?'periodPageUser':'infoStatsPeriod','valuePageUser',isGames?'ggRanking':'ggProfile');
      if(isGames) {
        var tail=blockRoot;while(tail.hasFollowUpAction())tail=tail.followUpAction;
        tail.followUpAction=call('Personal','periodPageGame','valuePageGame','ggMyStats',personal:true);
      }
      // The complete test action chain is guarded; production receives no fixtures.
      final enabled=andConditionsVar([state(w,'ggUsePreviewData'),(varFromEnvironmentSecret('test')..baseVariable.environmentValue.identifier=findEnvironmentValue(p,'test')!.parameter.identifier)]).variable;
      final guarded=Actions.conditional(condition:enabled,trueActions:blockRoot);
      final blockId=addActionBlock(p,name:'ggRefreshPreview',rootAction:guarded,widgetClass:w,description:'Test environment only. Replace preview source with RPC after backend installation.',identifier:id('ggRefreshPreview',name+'block'));
      FFActionNode refresh(String seed)=>FFActionNode(key:id('refreshNode',name+seed).key,action:Actions.executeActionBlock(p,actionBlockName:blockId.name,widgetClass:w));
      void append(FFActionNode root,String seed) {
        var tail=root;while(tail.hasFollowUpAction())tail=tail.followUpAction;
        tail.followUpAction=refresh(seed);
      }
      // Append after On Load and the actual filter/pagination/tab state updates.
      final watched=w.classModel.stateFields.where((f)=>['periodPageUser','periodPageGame','valuePageUser','valuePageGame','pageNumberUsers','pageNumberGames','tab','infoStatsPeriod'].contains(f.parameter.identifier.name)).map((f)=>f.parameter.identifier.key).toSet();
      void inspectActions(FFActionNode node) {
        if(node.hasFollowUpAction())inspectActions(node.followUpAction);
        if(node.hasConditionActions()) {
          for(final branch in node.conditionActions.trueActions)inspectActions(branch.trueAction);
          if(node.conditionActions.hasFalseAction())inspectActions(node.conditionActions.falseAction);
        }
        if(node.hasAction()&&node.action.hasLocalStateUpdate()&&node.action.localStateUpdate.updates.any((u)=>watched.contains(u.fieldIdentifier.key))) append(node,'update${node.key}');
        if(node.hasAction()&&node.action.hasBottomSheet()) {
          for(final pass in node.action.bottomSheet.passedParameters.parameterPasses.values) {
            if(pass.hasAction())inspectActions(pass.action.rootAction);
          }
        }
      }
      void walk(FFNode n) {
        for(final trigger in n.triggerActions) {
          inspectActions(trigger.rootAction);
          if(n.key==w.node.key&&trigger.trigger.triggerType==FFActionTriggerType.ON_INIT_STATE)append(trigger.rootAction,'onLoad');
        }
        for(final pass in n.parameterValues.parameterPasses.values)if(pass.hasAction())inspectActions(pass.action.rootAction);
        for(final child in n.children)walk(child);
      }
      walk(w.node);
    }
    for(final e in untouched.entries)if(base64Encode(p.widgetClasses[e.key]!.writeToBuffer())!=e.value)throw StateError('Unexpected edit outside requested scopes');
    final candidate=File('$reports/ui-candidate.pb')..writeAsBytesSync(p.writeToBuffer());Process.runSync('chmod',['600',candidate.path]);
    File('$reports/native-ui-report.json').writeAsStringSync(jsonEncode({'scopes':after.keys.toList(),'node_audit':overlay['report'],'real_rpc_activated':false,'test_fixtures_guarded_by_environment':true}));
    print('Native GG bindings prepared in ${after.length} scopes; RPC activation deferred.');
  }
}

Future<void> main(List<String> args) async {
  final apply=args.contains('--apply');
  final backup=jsonDecode(File('/Users/a123/.config/pfg-gg-backups/20261013/backup.json').readAsStringSync());
  if(apply&&(backup['commit_id'] as String).isEmpty)throw StateError('Backup Commit required');
  final result=await FlutterFlowAIPipeline(apiKey:Platform.environment['FF_API_KEY']!,project:PipelineProject.existing('play-for-good-o0lpcq'),
    tasks:[RegisterGgCode(variants,'rpc',reports),BindNativeGg()],
    source:PipelineSource.paths([Platform.script.toFilePath(),'$variants/flutterflow_cli/custom_code.json','/private/tmp/pfg-ui-overlay.json']),
    commitMessage:'Good Games native JSON bindings and guarded test preview',dryRun:!apply,refreshContext:false).run();
  for(final task in result.taskResults)print(task.summary);
  for(final diagnostic in result.diagnostics)if(diagnostic.isError)print(diagnostic.toString());
  print(jsonEncode({'success':result.success,'validation_blocked':result.validationBlocked,'commit_id':result.commitId,'dry_run':!apply}));
  if(!result.success||result.validationBlocked)exitCode=1;
}
