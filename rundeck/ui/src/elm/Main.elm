module Main exposing (..)

import Bootstrap.Grid as Grid
import Components.Job exposing (viewJobsTable)
import Components.Server exposing (viewServersTable)
import Html exposing (..)


-- APP


init : Model
init =
    { jobsmodel = Components.Job.init
    , serversmodel = Components.Server.init
    , error = ""
    }


main : Program Never Model Msg
main =
    program
        { init = ( init, refreshAllCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


refreshAllCmd : Cmd Msg
refreshAllCmd =
    Cmd.batch
        [ Cmd.map JobMsg Components.Job.getJobsCmd
        , Cmd.map ServerMsg Components.Server.getServersCmd
        ]



-- MODEL


type alias JobsModel =
    Components.Job.Model


type alias ServersModel =
    Components.Server.Model


type alias Model =
    { jobsmodel : JobsModel
    , serversmodel : ServersModel
    , error : String
    }



-- UPDATE


type Msg
    = NoOp
    | JobMsg Components.Job.Msg
    | ServerMsg Components.Server.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JobMsg msg_ ->
            let
                ( jobsmodel_, cmd_ ) =
                    Components.Job.update msg_ model.jobsmodel
            in
            ( { model | jobsmodel = jobsmodel_ }, Cmd.map JobMsg cmd_ )

        ServerMsg msg_ ->
            let
                ( serversmodel_, cmd_ ) =
                    Components.Server.update msg_ model.serversmodel
            in
            ( { model | serversmodel = serversmodel_ }, Cmd.map ServerMsg cmd_ )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Html.map JobMsg (Components.Job.viewModal model.jobsmodel)
        , Html.map ServerMsg (Components.Server.viewModal model.serversmodel)
        , Grid.container []
            [ Grid.row []
                [ Grid.col []
                    [ p [] [ text model.error ]
                    , Html.map JobMsg (viewJobsTable model.jobsmodel)
                    ]
                ]
            , Grid.row []
                [ Grid.col []
                    [ p [] [ text model.error ]
                    , Html.map ServerMsg (viewServersTable model.serversmodel)
                    ]
                ]
            ]
        ]
