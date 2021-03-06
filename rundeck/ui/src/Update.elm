module Update exposing (..)

import Bootstrap.Modal as BSModal
import Commands exposing (..)
import Components.Job exposing (..)
import Components.Server exposing (..)
import Elements.ExecResultsTable exposing (logsTitle)
import Errors exposing (makeErrorMessage)
import Message exposing (Msg(..))
import Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OpenModal modalmodel modus ->
            ( { model | modalvisability = BSModal.shown, modalmodel = modalmodel, modalmodus = modus }, Cmd.none )

        CloseModal ->
            ( { model | modalvisability = BSModal.hidden }, Cmd.none )

        ModalSave ->
            ( model
            , case model.modalmodel of
                ModalJob job ->
                    case model.modalmodus of
                        New ->
                            createJobCmd job

                        Edit ->
                            updateJobCmd job

                ModalServer server ->
                    case model.modalmodus of
                        New ->
                            createServerCmd server

                        Edit ->
                            updateServerCmd server

                _ ->
                    Cmd.none
            )

        ModalDelete ->
            ( model
            , case model.modalmodel of
                ModalJob job ->
                    deleteJobCmd job

                ModalServer server ->
                    deleteServerCmd server

                _ ->
                    Cmd.none
            )

        SetJobModalField setter value ->
            ( case model.modalmodel of
                ModalJob job ->
                    value
                        |> flip setter job
                        |> ModalJob
                        |> asModalModelIn model

                _ ->
                    model
            , Cmd.none
            )

        SetServerModalField setter value ->
            ( case model.modalmodel of
                ModalServer server ->
                    value
                        |> flip setter server
                        |> ModalServer
                        |> asModalModelIn model

                _ ->
                    model
            , Cmd.none
            )

        --- JOBS
        GetJobs ->
            ( model, getJobsCmd )

        JobsReceived (Ok jobs) ->
            ( { model | jobs = jobs }, Cmd.none )

        JobsReceived (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        JobStored (Ok job) ->
            ( model
                |> (case model.modalmodus of
                        New ->
                            createJob

                        Edit ->
                            updateJob
                   )
                    job
                |> update CloseModal
                |> Tuple.first
            , Cmd.none
            )

        JobStored (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        JobDeleted (Ok job) ->
            ( model |> deleteJob job |> update CloseModal |> Tuple.first, Cmd.none )

        JobDeleted (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        RunJob job ->
            ( model, runJobCmd job )

        JobStarted _ ->
            --todo: display & handle error
            ( model, getResultsCmd )

        --- SERVERS
        GetServers ->
            ( model, getServersCmd )

        ServersReceived (Ok servers) ->
            ( { model | servers = servers }, Cmd.none )

        ServersReceived (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        ServerStored (Ok server) ->
            ( model
                |> (if model.modalmodus == New then
                        createServer
                    else
                        updateServer
                   )
                    server
                |> update CloseModal
                |> Tuple.first
            , Cmd.none
            )

        ServerStored (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        ServerDeleted (Ok server) ->
            ( model |> deleteServer server |> update CloseModal |> Tuple.first, Cmd.none )

        ServerDeleted (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        ---RESULTS
        GetResults ->
            ( model, getResultsCmd )

        ResultsReceived (Ok results) ->
            ( { model
                | results =
                    results
                        |> List.sortBy .startTimestamp
                        |> List.reverse
                        |> List.take 5
              }
            , Cmd.none
            )

        ResultsReceived (Err httpError) ->
            ( { model | errorMessage = Just (makeErrorMessage httpError) }, Cmd.none )

        --- ALERT
        DismissAlert visability ->
            ( { model | errorMessage = Nothing }, Cmd.none )


setModalModel : ModalModel -> Model -> Model
setModalModel new model =
    { model | modalmodel = new }


asModalModelIn : Model -> ModalModel -> Model
asModalModelIn =
    flip setModalModel
