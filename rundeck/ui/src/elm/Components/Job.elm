module Components.Job exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Bootstrap.Table as Table
import Json.Decode
import Model exposing (Job, jobDecoder)
import String exposing (join)

type Msg = GetJobs | JobsReceived (Result Http.Error (List Job))

type alias Model = List Job

viewJobsTable jobs =
    Table.table {
        options = [ Table.striped, Table.hover ],
        thead = Table.simpleThead [
          Table.th [] [ text "Id"],
          Table.th [] [ text "Title"],
          Table.th [] [ text "Hostname Pattern"],
          Table.th [] [ text "Commands"]
        ],
        tbody = Table.tbody [] (List.map viewJobRow jobs)
    }

viewJobRow job =
    Table.tr [] [
        Table.td [] [ text job.id],
        Table.td [] [ text job.title],
        Table.td [] [ text job.hostnamePattern],
        Table.td [] [ text (join ", " job.commands)]
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJobs -> (model, getJobsCmd)
        JobsReceived (Ok jobs) ->(jobs, Cmd.none)
        JobsReceived (Err httpError) -> (model, Cmd.none)

getJobsCmd : Cmd Msg
getJobsCmd = Http.send JobsReceived (Http.get "http://localhost:8090/jobs" (Json.Decode.list jobDecoder))