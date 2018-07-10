module Elements.ServerModal exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Html exposing (div, h3, label, text)
import Html.Attributes exposing (for)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal, ModalDelete, ModalSave, SetServerModalField), setServerHostnameMsg, setServerIpPortMsg, setServerPrivateKeyMsg, setServerUserMsg)
import Model exposing (ModalModel(ModalServer), ModalModus(Edit, New), Server, setServerHostname, setServerIpPort, setServerPrivateKey, setServerUser)


viewModalHeader : Server -> ModalModus -> List (Html.Html Msg)
viewModalHeader server modus =
    [ h3 []
        [ text
            (case modus of
                New ->
                    "New Server"

                Edit ->
                    "Edit " ++ server.hostname
            )
        ]
    ]


viewModalBody : Server -> ModalModus -> List (Html.Html Msg)
viewModalBody server modus =
    [ Form.form []
        [ Form.group []
            [ Form.label [] [ text "Hostname" ]
            , Input.text [ Input.value server.hostname, Input.onInput setServerHostnameMsg ]
            ]
        , Form.group []
            [ Form.label [] [ text "ip:port" ]
            , Input.text [ Input.value server.ipPort, Input.onInput setServerIpPortMsg ]
            ]
        , Form.group []
            [ Form.label [] [ text "user" ]
            , Input.text [ Input.value server.user, Input.onInput setServerUserMsg ]
            ]
        , Form.group []
            [ label [ for "privatekeyarea" ] [ text "Private Key" ]
            , Textarea.textarea
                [ Textarea.id "privatekeyarea"
                , Textarea.rows 3
                , Textarea.value server.privateKey
                , Textarea.onInput setServerPrivateKeyMsg
                ]
            ]
        ]
    ]


viewModalFooter : Server -> ModalModus -> List (Html.Html Msg)
viewModalFooter server modus =
    [ case modus of
        Edit ->
            Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ] ] [ text "Delete" ]

        New ->
            Html.text ""
    , Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ] ] [ text "Close without saving" ]
    , Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ] ] [ text "Save" ]
    ]
