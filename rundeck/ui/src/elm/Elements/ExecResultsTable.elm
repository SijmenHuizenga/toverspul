module Elements.ExecResultsTable exposing (viewResultsTable)

import Bootstrap.Button as Button
import Bootstrap.Table as Table
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(OpenModal))
import Model exposing (ExecResult, ModalModel(ModalExecResult), ModalModus(Edit))


viewResultsTable : List ExecResult -> Html Msg
viewResultsTable results =
    div []
        [ Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Title" ]
                    , Table.th [] [ text "Hostname Pattern" ]
                    , Table.th [] [ text "Commands" ]
                    , Table.th [] []
                    ]
            , tbody = Table.tbody [] (List.map viewResultRow results)
            }
        ]


viewResultRow : ExecResult -> Table.Row Msg
viewResultRow result =
    Table.tr []
        [ Table.td [] [ text (toString result.startTimestamp) ]
        , Table.td [] [ text (toString result.finishTimestamp) ]
        , Table.td [] [ text result.job.title ]
        , Table.td [] [ Button.button [ Button.info, Button.attrs [ onClick (OpenModal (ModalExecResult result) Edit) ] ] [ text "View Logs" ] ]
        ]
