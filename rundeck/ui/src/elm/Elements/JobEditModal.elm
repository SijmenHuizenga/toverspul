module JobEditModal exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form exposing (label)
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Html exposing (div, h3, text)
import Html.Attributes exposing (for)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal, ModalDelete, ModalSave, ModelNewCommands, ModelNewHostnamePattern, ModelNewTitle))
import Model exposing (ModalModel(ModalJob), ModalModus(Edit, New))


viewModalHeader ModalJob job =
    [ h3 []
        [ text
            (if todo.modalModus == New then
                "New Job"
             else
                "Edit " ++ job.title
            )
        ]
    ]


viewModalBody ModalJob job =
    [ div []
        [ Form.form []
            [ Form.group []
                [ Form.label [] [ text "Title" ]
                , Input.text [ Input.value job.title, Input.onInput ModelNewTitle ]
                ]
            , Form.group []
                [ Form.label [] [ text "Hostname Pattern" ]
                , Input.text [ Input.value job.hostnamePattern, Input.onInput ModelNewHostnamePattern ]
                ]
            , Form.group []
                [ label [ for "commandsarea" ] [ text "Commands" ]
                , Textarea.textarea
                    [ Textarea.id "commandsarea"
                    , Textarea.rows 3
                    , Textarea.value (String.join "\n" job.commands)
                    , Textarea.onInput ModelNewCommands
                    ]
                ]
            ]
        ]
    ]


viewModalFooter ModalJob job =
    [ if todo.modalModus == Edit then
        Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ] ] [ text "Delete" ]
      else
        Html.text ""
    , Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ] ] [ text "Close without saving" ]
    , Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ] ] [ text "Save" ]
    ]
