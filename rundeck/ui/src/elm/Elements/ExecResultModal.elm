module Elements.ExecResultModal exposing (..)

import Bootstrap.Button as Button
import Html exposing (Html, div, h4, pre, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal))
import Model exposing (ExecResult, ExecResultServer, ModalModel(ModalExecResult), ModalModus)


viewModalHeader : ExecResult -> ModalModus -> List (Html.Html Msg)
viewModalHeader result modus =
    [ text "Logs" ]


viewModalBody : ExecResult -> ModalModus -> List (Html.Html Msg)
viewModalBody result modus =
    [ div [] (List.map viewExecutionLogs result.executions)
    , div [] (List.map viewExecutionLogs result.executions)
    ]


viewModalFooter : ExecResult -> ModalModus -> List (Html.Html Msg)
viewModalFooter model modus =
    [ Button.button [ Button.outlinePrimary, Button.attrs [ onClick CloseModal ] ] [ text "Close" ] ]


viewExecutionLogs : ExecResultServer -> Html Msg
viewExecutionLogs exec =
    div []
        [ h4 [] [ text exec.server.hostname ]
        , pre [] [ text exec.logs ]
        ]
