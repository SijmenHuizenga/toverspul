module Components.ExecResult exposing (..)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Modal as Modal
import Bootstrap.Table as Table
import Components.Common exposing (viewErrorMessage)
import Components.Job exposing (emptyJob)
import ConnectionUtil
import Html exposing (..)
import Html.Attributes exposing (for, placeholder)
import Html.Events exposing (onClick)
import Http exposing (Body, expectJson, jsonBody)
import Json.Decode
import List exposing (filter)
import List.Extra exposing (replaceIf)
import Maybe exposing (Maybe(Nothing))
import Model exposing (ExecResult, ExecResultServer, execResultDecoder)
import Result exposing (Result(Ok))
import String exposing (isEmpty, join, split)


type alias Model =
    { results : List ExecResult
    , modal : ExecResult
    , modalVisibility : Modal.Visibility
    , errorMessage : Maybe String
    }


init : Model
init =
    { results = []
    , modal = { id = "", startTimestamp = 0, finishTimestamp = 0, job = emptyJob, executions = [] }
    , modalVisibility = Modal.hidden
    , errorMessage = Nothing
    }


type Msg
    = GetResults
    | ResultsReceived (Result Http.Error (List ExecResult))
    | OpenModal ExecResult
    | CloseModal
    | DismissAlert Alert.Visibility


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetResults ->
            ( model, getResultsCmd )

        ResultsReceived (Ok results) ->
            ( { model | results = results }, Cmd.none )

        ResultsReceived (Err httpError) ->
            ( { model | errorMessage = Just (toString httpError) }, Cmd.none )

        OpenModal toShow ->
            ( { model | modalVisibility = Modal.shown, modal = toShow }, Cmd.none )

        CloseModal ->
            ( { model | modalVisibility = Modal.hidden }, Cmd.none )

        DismissAlert visability ->
            ( { model | errorMessage = Nothing }, Cmd.none )


viewResultsTable : Model -> Html Msg
viewResultsTable model =
    div []
        [ viewErrorMessage model.errorMessage DismissAlert
        , Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Title" ]
                    , Table.th [] [ text "Hostname Pattern" ]
                    , Table.th [] [ text "Commands" ]
                    , Table.th [] []
                    ]
            , tbody = Table.tbody [] (List.map viewResultRow model.results)
            }
        ]


viewResultRow : ExecResult -> Table.Row Msg
viewResultRow result =
    Table.tr []
        [ Table.td [] [ text (toString result.startTimestamp) ]
        , Table.td [] [ text (toString result.finishTimestamp) ]
        , Table.td [] [ text result.job.title ]
        , Table.td [] [ Button.button [ Button.info, Button.attrs [ onClick (OpenModal result) ] ] [ text "View Logs" ] ]
        ]


viewModal : Model -> Html Msg
viewModal model =
    div []
        [ Modal.config CloseModal
            |> Modal.large
            |> Modal.hideOnBackdropClick True
            |> Modal.h3 []
                [ text "Logs" ]
            |> Modal.body [] [ viewEditForm model.modal ]
            |> Modal.footer []
                [ Button.button [ Button.outlinePrimary, Button.attrs [ onClick CloseModal ] ] [ text "Close" ] ]
            |> Modal.view model.modalVisibility
        ]


viewEditForm : ExecResult -> Html Msg
viewEditForm execResult =
    div [] (List.map viewExecutionLogs execResult.executions)


viewExecutionLogs : ExecResultServer -> Html msg
viewExecutionLogs exec =
    div []
        [ h4 [] [ text exec.server ]
        , pre [] [ text exec.logs ]
        ]


getResultsCmd : Cmd Msg
getResultsCmd =
    ConnectionUtil.get "/results" (Json.Decode.list execResultDecoder) ResultsReceived
