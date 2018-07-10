module Main exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as BSModal
import Commands exposing (refreshAllCmd)
import Components.Job exposing (emptyJob)
import Elements.ExecResultsTable exposing (viewResultsTable)
import Elements.JobsTable exposing (viewJobsTable)
import Elements.Modal exposing (viewModal)
import Elements.ServersTable exposing (viewServersTable)
import Errors exposing (viewErrorMessage)
import Html exposing (Html, div, h4, h5, program, small, text)
import Html.Attributes exposing (class)
import Message exposing (Msg(CloseModal, DismissAlert, GetResults))
import Model exposing (ModalModel(ModalJob), ModalModus(New), Model)
import Time exposing (second)
import Update exposing (update)


init : Model
init =
    { errorMessage = Nothing
    , results = []
    , jobs = []
    , servers = []
    , modalvisability = BSModal.hidden
    , modalmodel = ModalJob emptyJob
    , modalmodus = New
    }


main : Program Never Model Msg
main =
    program
        { init = ( init, refreshAllCmd )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (toFloat 5000) (\t -> GetResults)


view : Model -> Html Msg
view model =
    div []
        [ viewModal model.modalmodel model.modalmodus model.modalvisability
        , Grid.container []
            [ viewErrorMessage model.errorMessage DismissAlert
            , cardy
                [ Block.titleH4 [] [ text "Execution Results ", small [ class "text-muted" ] [ text " (last 5)" ] ]
                , Block.custom
                    (viewResultsTable
                        model.results
                    )
                ]
            , cardy
                [ Block.titleH4 [] [ text "Jobs" ]
                , Block.custom (viewJobsTable model.jobs)
                ]
            , cardy
                [ Block.titleH4 [] [ text "Servers" ]
                , Block.custom (viewServersTable model.servers)
                ]
            ]
        ]


cardy : List (Block.Item Msg) -> Html Msg
cardy content =
    Grid.row [ Row.attrs [ class "cardy" ] ]
        [ Grid.col []
            [ Card.config []
                |> Card.block [] content
                |> Card.view
            ]
        ]
