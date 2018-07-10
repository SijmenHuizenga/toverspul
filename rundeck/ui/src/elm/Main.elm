module Main exposing (..)

import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Modal as BSModal
import Commands exposing (refreshAllCmd)
import ConnectionUtil
import Elements.ExecResultsTable exposing (viewResultsTable)
import Elements.JobsTable exposing (viewJobsTable)
import Elements.ServersTable exposing (viewServersTable)
import Html exposing (..)
import Http
import Json.Decode
import Message exposing (Msg(CloseModal))
import Model exposing (ExecResult, Job, ModalModel(ModalJob, ModalServer), Model, Server, execResultDecoder)
import Update exposing (update)


-- APP


init : Model
init =
    { errorMessage = Nothing
    , modalvisability = BSModal.hidden
    , jobs = []
    , servers = []
    , errorMessage = Nothing
    }


main : Program Never Model Msg
main =
    program
        { init = ( init, refreshAllCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


viewModalHeader : ModalModel -> List (Html.Html msg)
viewModalHeader ModalJob modalmodel =
    [ h3 [] [ text "Job" ] ]
viewModalHeader ModalServer modalmodel =
    [ h3 [] [ text "Server" ] ]


viewModal : ModalModel -> BSModal.Visibility -> Html Msg
viewModal modalmodel visability =
    div []
        [ BSModal.config CloseModal
            |> BSModal.large
            |> BSModal.hideOnBackdropClick True
            |> BSModal.header [] viewModalHeader modalmodel
            |> BSModal.body [] viewModalHeader modalmodel
            |> BSModal.footer [] viewModalHeader modalmodel
            |> BSModal.view visability
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewModal model
        , Grid.container []
            [ Grid.row []
                [ Grid.col []
                    [ p [] [ text model.error ]
                    , viewResultsTable model.execresultmodel.results
                    ]
                ]
            ]
        ]
