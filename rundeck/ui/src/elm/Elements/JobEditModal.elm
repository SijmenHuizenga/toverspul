module Elements.JobEditModal exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form exposing (label)
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Html exposing (div, h3, text)
import Html.Attributes exposing (for)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal, ModalDelete, ModalSave, SetJobModalField))
import Model exposing (Job, ModalModel(ModalJob), ModalModus(Edit, New), setJobCommands, setJobHostnamePattern, setJobTitle)


viewModalHeader : Job -> ModalModus -> List (Html.Html Msg)
viewModalHeader job modus =
    [ h3 []
        [ text
            (case modus of
                New ->
                    "New Job"

                Edit ->
                    "Edit " ++ job.title
            )
        ]
    ]


viewModalBody : Job -> ModalModus -> List (Html.Html Msg)
viewModalBody job modus =
    [ div []
        [ Form.form []
            [ Form.group []
                [ Form.label [] [ text "Title" ]
                , Input.text [ Input.value job.title, Input.onInput (SetJobModalField setJobTitle) ]
                ]
            , Form.group []
                [ Form.label [] [ text "Hostname Pattern" ]
                , Input.text [ Input.value job.hostnamePattern, Input.onInput (SetJobModalField setJobHostnamePattern) ]
                ]
            , Form.group []
                [ label [ for "commandsarea" ] [ text "Commands" ]
                , Textarea.textarea
                    [ Textarea.id "commandsarea"
                    , Textarea.rows 3
                    , Textarea.value (String.join "\n" job.commands)
                    , Textarea.onInput (SetJobModalField setJobCommands)
                    ]
                ]
            ]
        ]
    ]


viewModalFooter : Job -> ModalModus -> List (Html.Html Msg)
viewModalFooter job modus =
    [ case modus of
        Edit ->
            Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ] ] [ text "Delete" ]

        New ->
            Html.text ""
    , Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ] ] [ text "Close without saving" ]
    , Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ] ] [ text "Save" ]
    ]
