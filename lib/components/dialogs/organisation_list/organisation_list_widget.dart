import '/backend/supabase/supabase.dart';
import '/components/close_keyboard_widget.dart';
import '/components/organisation_comp/organisation_comp_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'organisation_list_model.dart';
export 'organisation_list_model.dart';

class OrganisationListWidget extends StatefulWidget {
  const OrganisationListWidget({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  State<OrganisationListWidget> createState() => _OrganisationListWidgetState();
}

class _OrganisationListWidgetState extends State<OrganisationListWidget> {
  late OrganisationListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrganisationListModel());

    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    _model.searchFocusNode!.addListener(() => safeSetState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: FutureBuilder<List<OrganizationRow>>(
        future: OrganizationTable().queryRows(
          queryFn: (q) => q
              .eqOrNull(
                'hide',
                false,
              )
              .eqOrNull(
                'test',
                FFDevEnvironmentValues().test,
              )
              .eqOrNull(
                'sponsor',
                false,
              )
              .order('title', ascending: true),
        ),
        builder: (context, snapshot) {
          // Customize what your widget looks like when it's loading.
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.transparent,
                  ),
                ),
              ),
            );
          }
          List<OrganizationRow> containerOrganizationRowList = snapshot.data!;

          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 90.0,
              maxWidth: 600.0,
              maxHeight: MediaQuery.sizeOf(context).height * 0.95,
            ),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 56.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 99.0,
                            buttonSize: 40.0,
                            fillColor: FlutterFlowTheme.of(context).alternate,
                            icon: Icon(
                              FFIcons.kleft,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 14.0,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              unawaited(
                                () async {
                                  await actions.closeKeyboard(
                                    context,
                                  );
                                }(),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 40.0, 0.0),
                            child: Text(
                              'Wähle Organisation aus',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    fontSize: 20.0,
                                    letterSpacing: valueOrDefault<double>(
                                      -0.8,
                                      -0.8,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1.4,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleSmallIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _model.searchTextController,
                        focusNode: _model.searchFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.searchTextController',
                          Duration(milliseconds: 50),
                          () async {
                            safeSetState(() {});
                          },
                        ),
                        onFieldSubmitted: (_) async {
                          unawaited(
                            () async {
                              await actions.closeKeyboard(
                                context,
                              );
                            }(),
                          );
                        },
                        autofocus: false,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleSmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).primaryText75,
                                fontSize: 16.0,
                                letterSpacing: valueOrDefault<double>(
                                  -0.4,
                                  -0.4,
                                ),
                                fontWeight: FontWeight.w500,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleSmallIsCustom,
                              ),
                          hintText: 'Suche nach Name oder Stadt',
                          hintStyle: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelMediumFamily,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText50,
                                fontSize: 16.0,
                                letterSpacing: valueOrDefault<double>(
                                  -0.4,
                                  -0.4,
                                ),
                                fontWeight: FontWeight.w500,
                                lineHeight: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelMediumIsCustom,
                              ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).focus,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding: EdgeInsets.all(16.0),
                          prefixIcon: Icon(
                            FFIcons.ksearch,
                            color: FlutterFlowTheme.of(context).secondaryText50,
                            size: 20.0,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              fontSize: 16.0,
                              letterSpacing: valueOrDefault<double>(
                                -0.4,
                                -0.4,
                              ),
                              fontWeight: FontWeight.w500,
                              lineHeight: 1.5,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                        maxLines: 3,
                        minLines: 1,
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        validator: _model.searchTextControllerValidator
                            .asValidator(context),
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              return TextEditingValue(
                                selection: newValue.selection,
                                text: newValue.text.toCapitalization(
                                    TextCapitalization.sentences),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (containerOrganizationRowList.length > 0) {
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: SingleChildScrollView(
                              controller: _model.columnController,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Builder(
                                        builder: (context) {
                                          final containerVar = functions
                                                  .searchOrg(
                                                      containerOrganizationRowList
                                                          .where((e) =>
                                                              valueOrDefault<
                                                                  bool>(
                                                                FFDevEnvironmentValues()
                                                                        .test
                                                                    ? (e.stripeAccountId !=
                                                                            null &&
                                                                        e.stripeAccountId !=
                                                                            '')
                                                                    : (e.stripeAccountIdLive !=
                                                                            null &&
                                                                        e.stripeAccountIdLive !=
                                                                            ''),
                                                                true,
                                                              ))
                                                          .toList(),
                                                      _model
                                                          .searchTextController
                                                          .text,
                                                      null,
                                                      '')
                                                  ?.toList() ??
                                              [];
                                          if (containerVar.isEmpty) {
                                            return Center(
                                              child: Image.asset(
                                                'assets/images/orgEmpty.png',
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                                containerVar.length,
                                                (containerVarIndex) {
                                              final containerVarItem =
                                                  containerVar[
                                                      containerVarIndex];
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (containerVarIndex > 0)
                                                    Divider(
                                                      height: 1.0,
                                                      thickness: 1.0,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child:
                                                        OrganisationCompWidget(
                                                      key: Key(
                                                          'Key9wl_${containerVarIndex}_of_${containerVar.length}'),
                                                      orgRow: containerVarItem,
                                                      buttonText: 'Auswählen',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ].addToEnd(SizedBox(height: 34.0)),
                              ),
                            ),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.asset(
                                    'assets/images/orgEmpty.png',
                                    width: double.infinity,
                                    height: 300.0,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: wrapWithModel(
                      model: _model.closeKeyboardModel,
                      updateCallback: () => safeSetState(() {}),
                      updateOnChange: true,
                      child: CloseKeyboardWidget(),
                    ),
                  ),
                ].addToStart(SizedBox(height: 12.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}
