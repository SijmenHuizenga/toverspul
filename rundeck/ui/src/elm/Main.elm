module Main exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Modal as BSModal
import Commands exposing (refreshAllCmd)
import Components.Common exposing (viewErrorMessage)
import Components.Job exposing (emptyJob)
import Elements.ExecResultsTable exposing (viewResultsTable)
import Elements.JobsTable exposing (viewJobsTable)
import Elements.Modal exposing (viewModal)
import Elements.ServersTable exposing (viewServersTable)
import Html exposing (Html, div, program)
import Message exposing (Msg(CloseModal, DismissAlert))
import Model exposing (ModalModel(ModalJob), ModalModus(New), Model)
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
        , subscriptions = \_ -> Sub.none
        }


view : Model -> Html Msg
view model =
    div []
        [ viewModal model.modalmodel model.modalmodus model.modalvisability
        , Grid.container []
            [ viewErrorMessage model.errorMessage DismissAlert
            , Grid.row [] [ Grid.col [] [ viewResultsTable model.results ] ]
            , Grid.row [] [ Grid.col [] [ viewJobsTable model.jobs ] ]
            , Grid.row [] [ Grid.col [] [ viewServersTable model.servers ] ]
            ]
        ]
