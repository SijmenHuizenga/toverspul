module Components.Job exposing (..)

import Html exposing (..)
import Html.Attributes exposing (for, placeholder)
import Html.Events exposing (onClick)
import Http
import Bootstrap.Table as Table
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Json.Decode
import List exposing (filter)
import Model exposing (Job, asJobCommands, asJobPatternIn, asJobTitleIn, jobDecoder, setJobCommands, setJobHostnamePattern, setJobTitle)
import String exposing (isEmpty, join, split)


type ModalModus = New | Edit
type alias Model = {jobs : List Job,
                    modalVisibility : Modal.Visibility,
                    modalModus : ModalModus,
                    modalJob : Job}
init : Model
init = {jobs = [],
        modalVisibility = Modal.hidden,
        modalModus = Edit,
        modalJob = {id = "123", title = "abc", hostnamePattern = "somepattern", commands = ["abc1", "abc2"]}}

type Msg = GetJobs
         | JobsReceived (Result Http.Error (List Job))
         | CloseModal
         | ShowModal
         | ModelNewTitle String
         | ModelNewHostnamePattern String
         | ModelNewCommands String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJobs -> (model, getJobsCmd)
        JobsReceived (Ok jobs) ->({model | jobs = jobs}, Cmd.none)
        JobsReceived (Err httpError) -> (model, Cmd.none)
        CloseModal -> ( { model | modalVisibility = Modal.hidden } , Cmd.none )
        ShowModal -> ( { model | modalVisibility = Modal.shown } , Cmd.none )
        ModelNewTitle newTitle -> (
            newTitle
                |> asJobTitleIn model.modalJob
                |> asModalJobIn model
            , Cmd.none)
        ModelNewHostnamePattern newPattern -> (
            newPattern
                |> asJobPatternIn model.modalJob
                |> asModalJobIn model
            , Cmd.none)
        ModelNewCommands newCommands -> (
            newCommands
                |> split "\n"
                --- |> filter (not << String.isEmpty)
                |> asJobCommands model.modalJob
                |> asModalJobIn model
            , Cmd.none)

setModalJob : Job -> Model -> Model
setModalJob newJob model =
    {model | modalJob = newJob}

asModalJobIn : Model -> Job -> Model
asModalJobIn = flip setModalJob


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
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text (if model.modalModus == New then "New Job" else "Edit " ++ model.modalJob.title) ]
        |> Modal.body [] [viewEditForm model.modalJob]
        |> Modal.footer [] [
            Button.button [ Button.outlineDanger, Button.attrs [ onClick CloseModal ]][ text "Delete" ],
            Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ]][ text "Close without saving" ],
            Button.button [ Button.outlineSuccess, Button.attrs [ onClick CloseModal ]][ text "Save" ]]
        |> Modal.view model.modalVisibility
        ]

viewEditForm : Job -> Html Msg
viewEditForm job =
    div [] [
        Form.form []
            [ Form.group []
                [ Form.label [] [ text "Title" ]
                , Input.text [Input.value job.title, Input.onInput ModelNewTitle]
                ]
            , Form.group []
                [ Form.label [] [ text "Hostname Pattern" ]
                , Input.text [Input.value job.hostnamePattern, Input.onInput ModelNewHostnamePattern]
                ]
            , Form.group []
                [ label [ for "commandsarea"] [ text "Commands"]
                , Textarea.textarea
                    [ Textarea.id "commandsarea"
                    , Textarea.rows 3
                    , Textarea.value (join "\n" job.commands)
                    , Textarea.onInput ModelNewCommands
                    ]
                ]
            ]]


getJobsCmd : Cmd Msg
getJobsCmd = Http.send JobsReceived (Http.get "http://localhost:8090/jobs" (Json.Decode.list jobDecoder))