module Components.Job exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Json.Decode
import Model exposing (Job, jobDecoder)
import String exposing (join)

type Msg = GetJobs | JobsReceived (Result Http.Error (List Job))

type alias Model = List Job

viewJobsTable jobs =
    table [class "table"] [
      thead [] [
        tr [] [
          td [] [text ("Id")],
          td [] [(text) "Title"],
          td [] [(text) "Hostname Pattern"],
          td [] [(text) "Commands"]
        ]
      ],
      tbody [] (List.map viewJobRow jobs)
    ]

viewJobRow job =
    tr [] [
        td [] [ text (job.id)],
        td [] [ text (job.title)],
        td [] [ text (job.hostnamePattern)],
        td [] [ text (join ", " job.commands)]
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJobs -> (model, getJobsCmd)
        JobsReceived (Ok jobs) ->(jobs, Cmd.none)
        JobsReceived (Err httpError) -> (model, Cmd.none)

getJobsCmd : Cmd Msg
getJobsCmd = Http.send JobsReceived (Http.get "http://localhost:8090/jobs" (Json.Decode.list jobDecoder))