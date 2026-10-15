"""Native-property overlay from the saved current FF snapshot. Local only."""
import copy
import hashlib
import json
from pathlib import Path

root=Path(__file__).resolve().parent
refs=json.loads(Path('/private/tmp/pfg-ui-code-refs.json').read_text())
assets={a['filename']:a['storagePath'] for a in json.loads(Path('/private/tmp/pfg-ui-assets.json').read_text())}
scopes=['GoodGamesPage','userProfilePage','userProfile','gamesUserComp','userProfileFilters','goodGamesPlayersFilters','userProfileInfoStatsRow']
original={s:json.loads(Path('/private/tmp/pfg-ui-'+s+'.json').read_text()) for s in scopes}
edited=copy.deepcopy(original)
def key(seed):return 'gg'+hashlib.sha256(seed.encode()).hexdigest()[:10]
def literal(x):return {'inputValue':{'serializedValue':str(x).lower() if isinstance(x,bool) else str(x)}}
def value(v):return {'variable':v}
def fn(name,*args):return {'source':'FUNCTION_CALL','functionCall':{'customFunction':refs['functions'][name]['identifier'],'values':list(args)}}
def cond(v,x,relation='EQUAL_TO'):return {'source':'FUNCTION_CALL','functionCall':{'condition':{'relation':relation},'values':[value(v),literal(x)]}}
def both(*vs):return {'source':'FUNCTION_CALL','functionCall':{'combineConditions':{'operator':'AND_OP'},'values':[value(v) for v in vs]}}
def not_(v):return cond(v,False)
def conditional(v,yes,no,typ):return {'source':'FUNCTION_CALL','functionCall':{'conditionalValue':{'ifConditionalValues':[{'condition':v,'value':yes}],'elseValue':no,'returnParameter':{'dataType':{'scalarType':typ,'nonNullable':True}}}}}
def state(w,name):
 f=next(f for f in w['classModel']['stateFields'] if f['parameter']['identifier']['name']==name)
 return {'source':'LOCAL_STATE','baseVariable':{'localState':{'fieldIdentifier':f['parameter']['identifier'],'stateVariableType':'WIDGET_CLASS_STATE'}},'nodeKeyRef':{'key':w['node']['key']}}
def param(w,name):return {'source':'WIDGET_CLASS_PARAMETER','baseVariable':{'widgetClass':{'paramIdentifier':next(p['identifier'] for p in w['params'].values() if p['identifier']['name']==name)}},'nodeKeyRef':{'key':w['node']['key']}}
def j(v,path,typ='JSON',is_list=False):
 v=copy.deepcopy(v);dt={'listType':{'scalarType':typ}} if is_list else {'scalarType':typ}
 v.setdefault('operations',[]).append({'jsonPathOperation':{'jsonPath':path,'returnParameter':{'dataType':dt}}});return v
def gen(node):return {'source':'GENERATOR_VARIABLE','baseVariable':{'generatorVariable':{}},'nodeKeyRef':{'key':node['key']}}
def nodes(w):
 result={}
 def walk(n,parent=None):
  result[n['key']]=n
  for c in n.get('children',[]):walk(c,n)
 walk(w['node']);return result
def text(n,v):n.setdefault('props',{}).setdefault('text',{})['textValue']={'variable':v}
def number(v,decimals=0):
 v=copy.deepcopy(v);v.setdefault('operations',[]).append({'numberFormat':{'formatType':'CUSTOM','customFormat':'#,##0'+('.'+'0'*decimals if decimals else '')}});return v
def visible(n,v):n.setdefault('props',{}).setdefault('visibility',{})['visibleValue']={'variable':v}
def color_value(c):
 palette={'FIRST':('4293121201','first'),'SECOND':('4292664540','second'),'THIRD':('4294303683','third'),'PRIMARY30':('1308560957','primary30')}
 return {'inputValue':{'color':{'value':palette[c][0],'paletteColorName':palette[c][1]}}} if c in palette else {'inputValue':{'color':{'themeColor':c}}}
def typed_color(c):return {'inputValue':{'themeColor':c}}
def fallback(new,old,ready,typ):
 oldvalue={'variable':old['variable']} if 'variable' in old else literal(old.get('inputValue',''))
 return conditional(ready,value(new),oldvalue,typ)
def ensure_state(w,name,typ,default):
 w.setdefault('classModel',{}).setdefault('stateFields',[])
 if any(f['parameter']['identifier']['name']==name for f in w['classModel']['stateFields']):return
 w['classModel']['stateFields'].append({'parameter':{'identifier':{'name':name,'key':key(w['name']+name)},'dataType':{'scalarType':typ,'nonNullable':True}},'serializedDefaultValue':[default]})
def ensure_param(w,name):
 ident={'name':name,'key':key(w['name']+name)}
 w.setdefault('params',{})[ident['key']]={'identifier':ident,'dataType':{'scalarType':'JSON','nonNullable':False}}
 return ident
def pass_value(n,ident,v):
 n['parameterValues']['parameterPasses'][ident['key']]={'paramIdentifier':ident,'variable':v}

for name in ['GoodGamesPage','userProfilePage','userProfile']:
 w=edited[name]
 for f in w['classModel']['stateFields']:
  if f['parameter']['identifier']['name'] in ['periodPageUser','periodPageGame','infoStatsPeriod']:f['serializedDefaultValue']=['auto']
 if name=='GoodGamesPage':
  for p in w['params'].values():
   if p['identifier']['name']=='periodGames':p['defaultValue']={'serializedValue':'auto'}
 for field in (['ggRanking','ggMyStats','ggHistory'] if name=='GoodGamesPage' else ['ggProfile','ggGuest']):ensure_state(w,field,'JSON','{}')

# Component parameters are nullable: existing instances on other screens remain valid.
w=edited['gamesUserComp'];player_id=ensure_param(w,'playerJson');ranking_id=ensure_param(w,'rankingJson')
ns=nodes(w);player=param(w,'playerJson');ranking=param(w,'rankingJson');ready=fn('ggHasData',value(player))
old=ns['Text_l3frcpxh']['props']['text']['textValue'];new=number(fn('ggMetricValue',value(player),literal('score'),literal(False)))
text(ns['Text_l3frcpxh'],fallback(new,old,ready,'String'))
old=ns['Text_yttsso1d']['props']['text']['textValue'];new=number(fn('ggMetricRank',value(player),literal('score'),literal(False)))
text(ns['Text_yttsso1d'],fallback(new,old,ready,'String'))
old=ns['Text_tnfcf2yg']['props']['text']['textValue'];text(ns['Text_tnfcf2yg'],fallback(j(player,'$.display_name','String'),old,ready,'String'))
medals=[('Image_0vehu90a','valuable',1),('Image_nzqe916o','valuable',2),('Image_htydfn2a','valuable',3),('Image_xxzxnlnx','active',1),('Image_8c1rk6o5','active',2),('Image_4yiaiipt','active',3)]
for node,cat,place in medals:visible(ns[node],fn('ggHasAward',value(player),literal(cat),literal(place),{'inputValue':{'serializedValue':''}}))
style=fn('ggRowStyle',value(ranking),value(player))
def style_color(prefix,colors):
 return {'source':'FUNCTION_CALL','functionCall':{'conditionalValue':{'ifConditionalValues':[{'condition':cond(style,prefix+'_'+name),'value':color_value(c)} for name,c in zip(['first','second','third'],colors)],'elseValue':{'inputValue':{'color':{'value':'0'}}},'returnParameter':{'dataType':{'scalarType':'Color','nonNullable':True}}}}}
body=ns['Container_9xooiwg2']['props']['container']['boxDecoration'];old=body['colorValue'];body['colorValue']={'variable':conditional(ready,value(style_color('final',['FIRST','SECOND','THIRD'])),value(old['variable']),'Color')}
stripe=ns['Container_rzgvzjsq'];stripe['props']['container']['boxDecoration']['colorValue']={'variable':style_color('current',['PRIMARY','ERROR','PRIMARY30'])}
visible(stripe,not_(fn('ggIsFinalSeason',value(ranking))))
# Use payload photos when available; preserve the original asset fallback.
for n in ns.values():
 if n.get('componentClassKeyRef',{}).get('key')=='Container_py4g82i5':
  for p in n['parameterValues']['parameterPasses'].values():
   if p['paramIdentifier']['name']=='image':p['variable']=fallback(j(player,'$.photo_url','ImagePath'),{'variable':p['variable']},ready,'ImagePath')
 if n.get('databaseRequest'):n['databaseRequest'].get('postgres',{})['hideOnEmpty']=False

# Page sources. Keep old Backend Queries as the staged fallback until SQL is ready.
w=edited['GoodGamesPage'];ns=nodes(w);ranking=state(w,'ggRanking');my=state(w,'ggMyStats');ready=fn('ggHasData',value(ranking))
for name in ['Text_5m4bxljx','Text_i9pi99ho']:
 text(ns[name],number(fn('ggTotalPower',value(ranking))))
for g in ['ListView_f2ogaegd','Column_vukwnj3x']:
 n=ns[g];n['generatorVariable']['variable']=conditional(ready,value(fn('ggRankingPlayerIds',value(ranking))),value(n['generatorVariable']['variable']),'String')
 # Conditional list must have list return type.
 n['generatorVariable']['variable']['functionCall']['conditionalValue']['returnParameter']['dataType']={'listType':{'scalarType':'String'},'nonNullable':True}
for name,n in ns.items():
 if n.get('componentClassKeyRef',{}).get('key')=='Container_f1ihd94m':
  passes=n['parameterValues']['parameterPasses'];uid=passes['njtyqh']['variable']
  row=fn('ggPlayerRow',value(ranking),value(uid));pass_value(n,player_id,row);pass_value(n,ranking_id,ranking)
  old=passes['phsgpm']['variable'];passes['phsgpm']['variable']=conditional(ready,value(fn('ggMetricRank',value(row),literal('score'),literal(False))),value(old),'Integer')
 # Replace displayed Meine Games metrics by their matching profile fields.
 if n.get('type')=='Text':
  tv=n.get('props',{}).get('text',{}).get('textValue',{});s=json.dumps(tv)
  targets={'gamesForPeriod':'games','totalSumPeriodLichtwattPerGame':'good_power_per_game','totalSumPeriodGoodPowerPerGame':'good_power_per_game','totalSumPeriodGoodPower':'good_power','totalSumPeriodLichtwatt':'good_power','totalSumPeriodGoodEnergyPerGame':'good_energy_per_game','totalSumAVG':'good_energy_per_game'}
  for f,metric in targets.items():
   if '"name": "'+f+'"' in s:
    text(n,fallback(number(fn('ggMetricValue',value(my),literal(metric),literal(False)),1 if 'per_game' in metric else 0),tv,fn('ggHasData',value(my)),'String'));break
  if '"name": "ratingUsersPerUser"' in s:
   metric='games' if 'active' in s else 'good_power'
   text(n,fallback(number(fn('ggMetricRank',value(my),literal(metric),literal(False))),tv,fn('ggHasData',value(my)),'String'))

# Podium original nodes: positions 2,1,3 in both native branches.
podiums=[('Stack_lspkrsgh',2,['Image_fmn24woq','Image_btimk278']),('Stack_d8ch3pyr',1,['Image_dz94m2rf','Image_pa5rzu6m','Image_c9fmlphb','Image_j0tk6agf']),('Stack_y8g2r7sq',3,['Image_l3rjec1r','Image_trbruprq']),('Stack_ff59uepl',2,['Image_9uknrrjm','Image_vhbjgc5e']),('Stack_9s3qgozx',1,['Image_u4atug4s','Image_zoyswxec','Image_ffztbimg','Image_dhg2o8p4']),('Stack_ymvf9ztj',3,['Image_g2a8y806','Image_ueiogbtf'])]
for sk,place,images in podiums:
 if sk not in ns:continue
 row=j(ranking,f'$.top_players[{place-1}]');stack=ns[sk]
 if stack.get('databaseRequest'):stack['databaseRequest']['postgres']['hideOnEmpty']=False
 for nk in images:
  image=ns[nk];path=image['props']['image']['pathValue']['inputValue']
  if 'Star_' in path:condition=fn('ggShowCurrentPlace',value(ranking),value(row),literal('valuable'),literal(place))
  elif path.endswith('/fire.webp'):condition=fn('ggShowCurrentPlace',value(ranking),value(row),literal('active'),literal(place))
  else:
   cat='valuable' if 'Trophy' in path or any(c in path for c in ['🥈','🥉','🥇']) else 'active'
   condition=fn('ggShowFinalPlace',value(ranking),value(row),literal(cat),literal(place))
  visible(image,condition)
 for n in nodes({'node':stack}).values():
  kids=n.get('children',[])
  if n.get('type')=='Container' and len(kids)==1 and kids[0].get('type')=='Text' and kids[0].get('props',{}).get('text',{}).get('textValue',{}).get('inputValue') in ['2','3']:
   visible(n,both(not_(fn('ggIsFinalSeason',value(ranking))),fn('ggHasData',value(row))))
 # Every photo/click inside this stack refers to its actual JSON player.
 def bind_subtree(n):
  for p in n.get('parameterValues',{}).get('parameterPasses',{}).values():
   if p['paramIdentifier']['name']=='image':p['variable']=fallback(j(row,'$.photo_url','ImagePath'),{'variable':p['variable']},ready,'ImagePath')
  for c in n.get('children',[]):bind_subtree(c)
 bind_subtree(stack)

# Profiles: stats labels, values/ranks and all-season dynamic medals.
for scope in ['userProfilePage','userProfile']:
 w=edited[scope];ns=nodes(w);profile=state(w,'ggProfile');ready=fn('ggHasData',value(profile))
 guest=state(w,'ggGuest')
 def guest_or(old):
  if isinstance(old.get('inputValue'),str):old=literal(old['inputValue'])
  return conditional(fn('ggHasData',value(guest)),value(number(fn('ggPlace',value(guest)))),old,'String')
 for n in ns.values():
  if n.get('type')=='Text':
   tv=n.get('props',{}).get('text',{}).get('textValue',{})
   if n['key'] in ['Text_nfa5jrbd','Text_wn608uvw']:
    text(n,fallback(number(fn('ggMetricValue',value(profile),literal('good_power'),literal(True))),tv,ready,'String'))
   if n['key']=='Text_gsiwo116':
    text(n,conditional(ready,value(number(fn('ggMetricRank',value(profile),literal('good_power'),literal(True)))),value(guest_or(value(tv['variable']) if 'variable' in tv else literal(tv.get('inputValue','')))),'String'))
   if 'infoStatsPeriod' in json.dumps(tv):text(n,fn('ggPeriodLabel',value(state(w,'infoStatsPeriod')),value(profile)))
  passes=n.get('parameterValues',{}).get('parameterPasses',{})
  title=next((p.get('inputValue',{}).get('serializedValue') for p in passes.values() if p.get('paramIdentifier',{}).get('name')=='title'),None)
  if title not in ['Total Good Power','Punkte per Game','Good Games','Supporters']:continue
  metric={'Total Good Power':'good_power','Punkte per Game':'good_energy','Good Games':'games','Supporters':'sponsored_games'}[title]
  for p in passes.values():
   pname=p['paramIdentifier']['name'];old={'variable':p['variable']} if 'variable' in p else {'inputValue':p.get('inputValue',{}).get('serializedValue','0')}
   if pname=='value' and title!='Supporters':p['variable']=fallback(number(fn('ggMetricValue',value(profile),literal(metric),literal(False)),1 if metric=='good_energy' else 0),old,ready,'String');p.pop('inputValue',None)
   if pname=='number':
    old2=value(guest_or(old)) if title=='Total Good Power' else old
    p['variable']=fallback(number(fn('ggMetricRank',value(profile),literal(metric),literal(False))),old2,ready,'String');p.pop('inputValue',None)
 # Current page has an existing MVP/MAP Row; keep its children/keys and extend it.
 for row in list(ns.values()):
  children=row.get('children',[])
  if row.get('type')!='Row' or not any('1st_Place.webp' in json.dumps(c.get('props',{})) for c in children):continue
  row['generatorVariable']={'identifier':{'name':'ggAward'},'variable':fn('ggAwards',value(profile),literal(''))}
  item=gen(row)
  template=copy.deepcopy(next(c for c in children if c.get('type')=='Image'))
  configurations=[('valuable',1,'1st_Place.webp'),('active',1,'Most_Active_Player.webp'),('valuable',2,'2nd_Place.webp'),('valuable',3,'3rd_Place.webp'),('active',2,'Group_1676.webp'),('active',3,'Group_1677.webp')]
  for idx,(cat,place,filename) in enumerate(configurations):
   if idx<len(children):image=children[idx]
   else:
    image=copy.deepcopy(template);image['key']=key(scope+filename);children.append(image)
   image['props']['image']['pathValue']={'inputValue':assets[filename]}
   visible(image,fn('ggHasAward',value(item),literal(cat),literal(place),literal('')))

# Filter normalization and dirty-color; keep the existing Confirm/Cancel actions.
for scope,button in [('userProfileFilters','IconButton_1xnvcpmt'),('goodGamesPlayersFilters','IconButton_d1rwfoa2')]:
 w=edited[scope];ns=nodes(w)
 sp=state(w,'periodState');ap=param(w,'period')
 sc=state(w,'valueState') if scope=='goodGamesPlayersFilters' else None
 ac=param(w,'value') if scope=='goodGamesPlayersFilters' else None
 dirty=fn('ggFiltersChanged',value(sp),value(ap),value(sc) if sc else literal(''),value(ac) if ac else literal(''))
 ib=ns[button]['props']['iconButton'];ib['fillColorValue']={'variable':conditional(dirty,{'inputValue':{'color':{'value':'4278190080'}}},color_value('ALTERNATE'),'Color')}
 ib['iconValue']['inputValue']['colorValue']={'variable':conditional(dirty,{'inputValue':{'color':{'value':'4294967295'}}},color_value('PRIMARY_TEXT'),'Color')}
 # Radio conditions compare normalized period names so enum aliases keep working.
 def normalize(x):
  if isinstance(x,dict):
   f=x.get('functionCall',{})
   if f.get('condition',{}).get('relation')=='EQUAL_TO' and any('periodState' in json.dumps(v) for v in f.get('values',[])):
    for v in f.get('values',[]):
     if 'variable' in v:
      raw=v['variable'];enum_name=raw.get('baseVariable',{}).get('enumVariable',{}).get('enumElementIdentifier',{}).get('name')
      v['variable']=fn('ggPeriodKey',literal(enum_name) if enum_name else value(raw))
     elif 'inputValue' in v:
      raw=v['inputValue'].get('serializedValue','');v.clear();v['variable']=fn('ggPeriodKey',literal(raw))
   for v in x.values():normalize(v)
  elif isinstance(x,list):
   for v in x:normalize(v)
 # Normalize only known radio visibility expressions, not every equality/action.
 for n in ns.values():
  vv=n.get('props',{}).get('visibility',{}).get('visibleValue',{})
  if vv.get('variable',{}).get('functionCall',{}).get('condition'):normalize(vv)

w=edited['userProfileInfoStatsRow'];ns=nodes(w)
visible(ns['Container_hw07fq8w'],both(cond(param(w,'number'),'0','NOT_EQUAL_TO'),cond(param(w,'number'),'','NOT_EQUAL_TO')))

# Mutation audit: every original native node/asset reference still exists.
report={}
for scope in scopes:
 before=nodes(original[scope]);after=nodes(edited[scope]);assert set(before)<=set(after),scope
 report[scope]={'nodes_before':len(before),'nodes_after':len(after),'states_added':len(edited[scope].get('classModel',{}).get('stateFields',[]))-len(original[scope].get('classModel',{}).get('stateFields',[]))}
Path('/private/tmp/pfg-ui-overlay.json').write_text(json.dumps({'before':original,'after':edited,'report':report},ensure_ascii=False))
print(json.dumps(report,ensure_ascii=False))
