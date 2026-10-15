# Component node detail: Image_nzqe916o
Scope: gamesUserComp

## DSL
```dart
import 'package:flutterflow_ai/flutterflow_ai.dart';

DslWidget buildDecompiledSubtree() =>
  Image(
    'projects/play-for-good-o0lpcq/assets/pnf9mgo4ojsw/🥈_1.webp',
    isNetwork: false,
    width: 20,
    height: 20,
    visible: Bound('function call'),
    opacity: 1,
    name: 'DecompiledImage',
    key: 'Image_nzqe916o',
  ) /* // visible: Bound('function call'); raw path: widgetClasses['Container_f1ihd94m'].node.children[0].children[0].children[1].children[1].children[1].children[1].children[1].props; inspect --node 'Image_nzqe916o' // +2 props not in DSL; raw path: widgetClasses['Container_f1ihd94m'].node.children[0].children[0].children[1].children[1].children[1].children[1].children[1].props; inspect --node 'Image_nzqe916o' */;

```

## Triggers
None.

## Properties and markers not in DSL
- `cacheFadeDuration` = 500
- `format` = "FF_IMAGE_FORMAT_AUTO"
- `visible` = visible: Bound('function call')

## Serialized subtree
```json
{
  "key": "Image_nzqe916o",
  "type": "Image",
  "props": {
    "image": {
      "type": "FF_IMAGE_TYPE_ASSET",
      "fit": "FF_BOX_FIT_COVER",
      "dimensions": {
        "width": {
          "pixelsValue": {
            "inputValue": 20
          }
        },
        "height": {
          "pixelsValue": {
            "inputValue": 20
          }
        }
      },
      "borderRadius": {
        "type": "FF_BORDER_RADIUS_ONLY",
        "allValue": {
          "inputValue": 8
        }
      },
      "cacheFadeDuration": 500,
      "pathValue": {
        "inputValue": "projects/play-for-good-o0lpcq/assets/pnf9mgo4ojsw/🥈_1.webp"
      },
      "format": "FF_IMAGE_FORMAT_AUTO"
    },
    "padding": {
      "animatedPadding": {}
    },
    "visibility": {
      "visibleValue": {
        "variable": {
          "source": "FUNCTION_CALL",
          "functionCall": {
            "values": [
              {
                "variable": {
                  "source": "FUNCTION_CALL",
                  "functionCall": {
                    "values": [
                      {
                        "variable": {
                          "source": "WIDGET_CLASS_PARAMETER",
                          "baseVariable": {
                            "widgetClass": {
                              "paramIdentifier": {
                                "name": "rating",
                                "key": "phsgpm"
                              }
                            }
                          },
                          "nodeKeyRef": {
                            "key": "Container_f1ihd94m"
                          }
                        }
                      },
                      {
                        "inputValue": {
                          "serializedValue": "2"
                        }
                      }
                    ],
                    "condition": {
                      "relation": "EQUAL_TO"
                    }
                  }
                }
              },
              {
                "variable": {
                  "source": "FUNCTION_CALL",
                  "functionCall": {
                    "values": [
                      {
                        "variable": {
                          "source": "WIDGET_CLASS_PARAMETER",
                          "baseVariable": {
                            "widgetClass": {
                              "paramIdentifier": {
                                "name": "value",
                                "key": "sujgnr"
                              }
                            }
                          },
                          "nodeKeyRef": {
                            "key": "Container_f1ihd94m"
                          }
                        }
                      },
                      {
                        "variable": {
                          "source": "ENUMS",
                          "baseVariable": {
                            "enumVariable": {
                              "enumIdentifier": {
                                "name": "ratingGamesFilter",
                                "key": "pks08"
                              },
                              "enumElementIdentifier": {
                                "name": "valuable",
                                "key": "vnmeh"
                              }
                            }
                          }
                        }
                      }
                    ],
                    "condition": {
                      "relation": "EQUAL_TO"
                    }
                  }
                }
              }
            ],
            "combineConditions": {
              "operator": "AND_OP"
            }
          }
        },
        "mostRecentInputValue": true
      }
    },
    "responsiveVisibility": {},
    "opacity": {
      "opacityValue": {
        "inputValue": 1
      },
      "animatedOpacity": {}
    },
    "animatedAlignment": {}
  },
  "valueKey": {}
}
```

More: `inspect --node <key>` for one focused subtree; add `--raw` for the serialized proto; `inspect --tree` for the full page view; `inspect --dsl-json` for the machine-readable snapshot.
