module Main exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap.Grid as Grid

import Model exposing (Job, jobDecoder)
import Components.Job exposing (viewJobsTable)


-- APP
main : Program Never Model Msg
main =
  program { init = ({jobs = [], error = ""}, refreshAllCmd),
            view = view,
            update = update,
            subscriptions = \_ -> Sub.none }

refreshAllCmd = Cmd.batch [
        Cmd.map JobMsg Components.Job.getJobsCmd
    ]

-- MODEL`
type alias Model = {
    jobs : Components.Job.Model,
    error : String}


-- UPDATE
type Msg = NoOp | JobMsg Components.Job.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    JobMsg msg_ ->  let (jobs_, cmd_) = Components.Job.update msg_ model.jobs
                    in ({model | jobs = jobs_}, Cmd.map JobMsg cmd_)
    NoOp -> (model, Cmd.none)

-- VIEW
view : Model -> Html Msg
view model =
  Grid.container [] [
    Grid.row [] [
      Grid.col [] [
        p [] [ text (model.error)],
        (viewJobsTable model.jobs)
      ]
    ]
  ]

