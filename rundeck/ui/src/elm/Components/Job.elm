module Components.Job exposing (..)

import Html exposing (..)
import Html.Attributes exposing (for, placeholder)
import Html.Events exposing (onClick)
import Http exposing (Body, expectJson, jsonBody)
import Bootstrap.Table as Table
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Json.Decode
import List exposing (filter)
import List.Extra exposing (replaceIf)
import Maybe exposing (Maybe(Nothing))
import Model exposing (Job, asJobCommands, asJobPatternIn, asJobTitleIn, jobDecoder, jobEncoder, setJobCommands, setJobHostnamePattern, setJobTitle)
import Result exposing (Result(Ok))
import String exposing (isEmpty, join, split)


type ModalModus = New | Edit
type alias Model = {jobs : List Job,
                    modalVisibility : Modal.Visibility,
                    modalModus : ModalModus,
                    modalJob : Job}

emptyJob : Job
emptyJob = {id = "", title = "", hostnamePattern = "", commands = []}

init : Model
init = {jobs = [],
        modalVisibility = Modal.hidden,
        modalModus = Edit,
        modalJob = emptyJob}

type Msg = GetJobs
         | JobsReceived (Result Http.Error (List Job))
         | JobStored (Result Http.Error Job)
         | JobDeleted (Result Http.Error Job)
         | CloseModal
         | CreateJob
         | EditJob Job
         | ModelNewTitle String
         | ModelNewHostnamePattern String
         | ModelNewCommands String
         | ModalSave
         | ModalDelete


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetJobs
            -> (model, getJobsCmd)
        JobsReceived (Ok jobs)
            -> ({model | jobs = jobs}, Cmd.none)
        JobsReceived (Err httpError)
            -> (model, Cmd.none) --- todo

        JobStored (Ok job)
            -> (model |> (if model.modalModus == New then createJob else updateSingleJob) job |> update CloseModal |> Tuple.first, Cmd.none ) --- todo for real
        JobStored (Err httpError)
            -> (model, Cmd.none) --- todo

        JobDeleted (Ok job)
            -> (model |> deleteJob job |> update CloseModal |> Tuple.first, Cmd.none ) --- todo for real
        JobDeleted (Err httpError)
            -> (model, Cmd.none) --- todo

        CreateJob
            -> ( { model | modalVisibility = Modal.shown, modalJob = emptyJob, modalModus = New} , Cmd.none )
        EditJob job
            -> ( { model | modalVisibility = Modal.shown, modalJob = job, modalModus = Edit } , Cmd.none )

        CloseModal
            -> ( { model | modalVisibility = Modal.hidden } , Cmd.none )
        ModalSave
            -> (model, if model.modalModus == New then createJobCmd model.modalJob else storeJobCmd model.modalJob)
        ModalDelete
            -> (model, deleteJobCmd model.modalJob)

        ModelNewTitle newTitle
            -> ( newTitle
                    |> asJobTitleIn model.modalJob
                    |> asModalJobIn model
                , Cmd.none)
        ModelNewHostnamePattern newPattern
            -> ( newPattern
                    |> asJobPatternIn model.modalJob
                    |> asModalJobIn model
                , Cmd.none)
        ModelNewCommands newCommands
            -> ( newCommands
                    |> split "\n"
                    |> asJobCommands model.modalJob
                    |> asModalJobIn model
                , Cmd.none)

setModalJob : Job -> Model -> Model
setModalJob newJob model =
    {model | modalJob = newJob}

asModalJobIn : Model -> Job -> Model
asModalJobIn = flip setModalJob

asJobWithoutEmptyCommands : Job -> Job
asJobWithoutEmptyCommands job =
    {job | commands = filter (not << String.isEmpty) job.commands}


updateSingleJob : Job -> Model -> Model
updateSingleJob job model =
    {model | jobs = model.jobs |> replaceIf (\j -> j.id == job.id) job }

createJob : Job -> Model -> Model
createJob job model =
    {model | jobs = job :: model.jobs }

deleteJob : Job -> Model -> Model
deleteJob job model =
    {model | jobs = model.jobs |> filter (\j -> j.id /= job.id) }

viewJobsTable : Model -> Html Msg
viewJobsTable model =
    div [] [
        Table.table {
                options = [ Table.striped, Table.hover ],
                thead = Table.simpleThead [
                  Table.th [] [ text "Id"]
                  , Table.th [] [ text "Title"]
                  , Table.th [] [ text "Hostname Pattern"]
                  , Table.th [] [ text "Commands"]
                  , Table.th [] [ Button.button [ Button.outlineSuccess, Button.small, Button.attrs [ onClick <| CreateJob ] ] [text "New Job"] ]
                ],
                tbody = Table.tbody [] (List.map viewJobRow model.jobs)
            }
    ]


viewJobRow : Job -> Table.Row Msg
viewJobRow job =
    Table.tr [] [
        Table.td [] [ text job.id]
        , Table.td [] [ text job.title]
        , Table.td [] [ text job.hostnamePattern]
        , Table.td [] [ text (join ", " job.commands)]
        , Table.td [] [
            Button.button [ Button.info, Button.attrs [ onClick (EditJob job) ]][ text "Edit" ]
        ]
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
            Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ]][ text "Delete" ],
            Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ]][ text "Close without saving" ],
            Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ]][ text "Save" ]]
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

storeJobCmd : Job -> Cmd Msg
storeJobCmd job = Http.send JobStored (Http.request {
                    method = "PUT"
                    , url = "http://localhost:8090/jobs/" ++ job.id
                    , body = job |> asJobWithoutEmptyCommands |> jobEncoder |> jsonBody
                    , headers = []
                    , timeout = Nothing
                    , expect = expectJson jobDecoder
                    , withCredentials = False } )

deleteJobCmd : Job -> Cmd Msg
deleteJobCmd job = Http.send JobDeleted (Http.request {
                    method = "DELETE"
                    , url = "http://localhost:8090/jobs/" ++ job.id
                    , body = Http.emptyBody
                    , headers = []
                    , timeout = Nothing
                    , expect = expectJson jobDecoder
                    , withCredentials = False } )

createJobCmd : Job -> Cmd Msg
createJobCmd job = Http.send JobStored (Http.request {
                   method = "POST"
                   , url = "http://localhost:8090/jobs"
                   , body = job |> asJobWithoutEmptyCommands |> jobEncoder |> jsonBody
                   , headers = []
                   , timeout = Nothing
                   , expect = expectJson jobDecoder
                   , withCredentials = False } )