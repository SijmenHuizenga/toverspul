module ServerModal exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Html exposing (div, h3, label, text)
import Html.Attributes exposing (for)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal, ModalDelete, ModalNewHostname, ModalNewIpPort, ModalNewPrivateKey, ModalNewUser, ModalSave))
import Model exposing (ModalModel(ModalServer), ModalModus(Edit, New))


viewModalHeader ModalServer server =
    [ h3 []
        [ text
            (if todo.modalModus == New then
                "New Server"
             else
                "Edit " ++ server.hostname
            )
        ]
    ]


viewModalBody ModalServer server =
    [ Form.form []
        [ Form.group []
            [ Form.label [] [ text "Hostname" ]
            , Input.text [ Input.value server.hostname, Input.onInput ModalNewHostname ]
            ]
        , Form.group []
            [ Form.label [] [ text "ip:port" ]
            , Input.text [ Input.value server.ipPort, Input.onInput ModalNewIpPort ]
            ]
        , Form.group []
            [ Form.label [] [ text "user" ]
            , Input.text [ Input.value server.user, Input.onInput ModalNewUser ]
            ]
        , Form.group []
            [ label [ for "privatekeyarea" ] [ text "Private Key" ]
            , Textarea.textarea
                [ Textarea.id "privatekeyarea"
                , Textarea.rows 3
                , Textarea.value server.privateKey
                , Textarea.onInput ModalNewPrivateKey
                ]
            ]
        ]
    ]


viewModalFooter ModalServer server =
    [ if todo.modalModus == Edit then
        Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ] ] [ text "Delete" ]
      else
        Html.text ""
    , Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ] ] [ text "Close without saving" ]
    , Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ] ] [ text "Save" ]
    ]
