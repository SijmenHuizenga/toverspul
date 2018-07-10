module Elements.ExecResultModal exposing (..)

import Bootstrap.Button as Button
import Html exposing (Html, div, h4, pre, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal))
import Model exposing (ExecResult, ExecResultServer, ModalModel(ModalExecResult))


viewModalBody ModalExecResult model =
    [ div [] (List.map viewExecutionLogs model.executions) ]
        [ div [] (List.map viewExecutionLogs model.executions) ]


viewModalHeader ModalExecResult model =
    [ text "Logs" ]


viewModalFooter ModalExecResult model =
    [ Button.button [ Button.outlinePrimary, Button.attrs [ onClick CloseModal ] ] [ text "Close" ] ]


viewExecutionLogs : ExecResultServer -> Html msg
viewExecutionLogs exec =
    div []
        [ h4 [] [ text exec.server.hostname ]
        , pre [] [ text exec.logs ]
        ]
