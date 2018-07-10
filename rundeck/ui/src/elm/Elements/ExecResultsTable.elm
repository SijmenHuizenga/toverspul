module Elements.ExecResultsTable exposing (viewResultsTable)

import Bootstrap.Button as Button
import Bootstrap.Table as Table
import Date
import Date.Format
import Html exposing (Html, a, br, div, li, small, span, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Message exposing (Msg(OpenModal))
import Model exposing (ExecResult, ExecResultServer, ModalModel(ModalLogs), ModalModus(Edit), Server)


viewResultsTable : List ExecResult -> Html Msg
viewResultsTable results =
    div []
        [ Table.table
            { options = [ Table.small ]
            , thead = Table.simpleThead []
            , tbody = Table.tbody [] (List.map viewResultRow results)
            }
        ]


viewResultRow : ExecResult -> Table.Row Msg
viewResultRow result =
    Table.tr []
        [ Table.td [] [ text result.job.title ]
        , Table.td [] (viewTiming result.startTimestamp result.finishTimestamp)
        , Table.td [] [ viewExecutionsTable result.executions ]
        ]


viewExecutionsTable : List ExecResultServer -> Html Msg
viewExecutionsTable results =
    Table.table
        { options = [ Table.small, Table.attr (class "no-top-border") ]
        , thead = Table.simpleThead []
        , tbody = Table.tbody [] (List.map viewExecutionRow results)
        }


viewExecutionRow : ExecResultServer -> Table.Row Msg
viewExecutionRow result =
    Table.tr []
        [ Table.td [] [ text result.server.hostname ]
        , Table.td [] [ small [ class "text-muted" ] [ text (" (" ++ result.server.user ++ "@" ++ result.server.ipPort ++ ")") ] ]
        , Table.td [] [ a [ href "#", onClick (OpenModal (ModalLogs ( "title!", result.logs )) Edit) ] [ text "Logs" ] ]
        ]


viewTiming : Int -> Int -> List (Html Msg)
viewTiming start finish =
    [ ul [ class "list-unstyled" ]
        [ li [] [ text (viewTimestamp start) ]
        , li [] [ small [ class "text-muted vertical-align-top" ] [ text (viewTimeElapsed start finish) ] ]
        ]
    ]


viewTimestamp : Int -> String
viewTimestamp stamp =
    Date.Format.format " %e %b %H:%M:%S" (Date.fromTime (toFloat stamp * 1000))


viewTimeElapsed : Int -> Int -> String
viewTimeElapsed start finish =
    let
        elapsed =
            finish - start
    in
    if elapsed == 0 then
        "returned immediately"
    else
        toString elapsed
            ++ " second"
            ++ (if elapsed > 1 then
                    "s"
                else
                    ""
               )
