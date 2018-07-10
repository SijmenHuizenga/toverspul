module Components.Common exposing (..)

import Bootstrap.Alert as Alert
import Html exposing (Html, text)
import Http


makeErrorMessage : Http.Error -> String
makeErrorMessage err =
    toString err


viewErrorMessage : Maybe String -> (Alert.Visibility -> a) -> Html a
viewErrorMessage msg dismissMsg =
    Alert.config
        |> Alert.danger
        |> Alert.dismissableWithAnimation dismissMsg
        |> Alert.children [ msg |> Maybe.withDefault "" |> text ]
        |> Alert.view (alertVisability msg)


alertVisability : Maybe String -> Alert.Visibility
alertVisability text =
    case text of
        Just txt ->
            Alert.shown

        Nothing ->
            Alert.closed
