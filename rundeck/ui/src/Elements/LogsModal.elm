module Elements.LogsModal exposing (..)

import Bootstrap.Button as Button
import Html exposing (pre, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(CloseModal))


viewModalHeader : String -> String -> List (Html.Html Msg)
viewModalHeader title logs =
    [ text title ]


viewModalBody : String -> String -> List (Html.Html Msg)
viewModalBody title logs =
    [ pre [] [ text logs ] ]


viewModalFooter : String -> String -> List (Html.Html Msg)
viewModalFooter title logs =
    [ Button.button [ Button.outlinePrimary, Button.attrs [ onClick CloseModal ] ] [ text "Close" ] ]
