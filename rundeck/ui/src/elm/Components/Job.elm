module Components.Job exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Bootstrap.Table as Table
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Json.Decode
import Model exposing (Job, jobDecoder)
import String exposing (join)


type alias Model = {jobs : List Job, modalVisibility : Modal.Visibility}
init : Model
init = {jobs = [], modalVisibility = Modal.hidden}

type Msg = GetJobs
         | JobsReceived (Result Http.Error (List Job))
         | CloseModal
         | ShowModal

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJobs -> (model, getJobsCmd)
        JobsReceived (Ok jobs) ->({model | jobs = jobs}, Cmd.none)
        JobsReceived (Err httpError) -> (model, Cmd.none)
        CloseModal -> ( { model | modalVisibility = Modal.hidden } , Cmd.none )
        ShowModal -> ( { model | modalVisibility = Modal.shown } , Cmd.none )


viewJobsTable : Model -> Html Msg
viewJobsTable model =
    div [] [
        Button.button [ Button.outlineSuccess, Button.attrs [ onClick <| ShowModal ] ] [text "Open Modal"],
        Table.table {
                options = [ Table.striped, Table.hover ],
                thead = Table.simpleThead [
                  Table.th [] [ text "Id"],
                  Table.th [] [ text "Title"],
                  Table.th [] [ text "Hostname Pattern"],
                  Table.th [] [ text "Commands"]
                ],
                tbody = Table.tbody [] (List.map viewJobRow model.jobs)
            }
    ]


viewJobRow : Job -> Table.Row msg
viewJobRow job =
    Table.tr [] [
        Table.td [] [ text job.id],
        Table.td [] [ text job.title],
        Table.td [] [ text job.hostnamePattern],
        Table.td [] [ text (join ", " job.commands)]
    ]

viewModal : Model -> Html Msg
viewModal model =
    div [] [
      Modal.config CloseModal
        |> Modal.small
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Modal header" ]
        |> Modal.body [] [ p [] [ text "This is a modal for you !"] ]
        |> Modal.footer []
            [ Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick CloseModal ]
                ]
                [ text "Close" ]
            ]
        |> Modal.view model.modalVisibility
        ]


getJobsCmd : Cmd Msg
getJobsCmd = Http.send JobsReceived (Http.get "http://localhost:8090/jobs" (Json.Decode.list jobDecoder))