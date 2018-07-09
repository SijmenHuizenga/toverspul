module Components.Server exposing (..)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Modal as Modal
import Bootstrap.Table as Table
import Components.Common exposing (ModalModus(Edit, New), makeErrorMessage)
import ConnectionUtil
import Html exposing (..)
import Html.Attributes exposing (for, placeholder)
import Html.Events exposing (onClick)
import Http exposing (Body, expectJson, jsonBody)
import Json.Decode
import List exposing (filter)
import List.Extra exposing (replaceIf)
import Maybe exposing (Maybe(Nothing))
import Result exposing (Result(Ok))
import Server exposing (..)


type alias Model =
    { servers : List Server
    , modalVisibility : Modal.Visibility
    , modalModus : ModalModus
    , modalServer : Server
    , errorMessage : Maybe String
    }


init : Model
init =
    { servers = []
    , modalVisibility = Modal.hidden
    , modalModus = Edit
    , modalServer = emptyServer
    , errorMessage = Nothing
    }


emptyServer : Server
emptyServer =
    { id = "", hostname = "", ipPort = "", privateKey = "", user = "" }


type Msg
    = GetServers
    | ServersReceived (Result Http.Error (List Server))
    | ServerStored (Result Http.Error Server)
    | ServerDeleted (Result Http.Error Server)
    | CloseModal
    | CreateServer
    | EditServer Server
    | ModalNewPrivateKey String
    | ModalNewUser String
    | ModalNewIpPort String
    | ModalNewHostname String
    | ModalSave
    | ModalDelete
    | DismissAlert Alert.Visibility


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetServers ->
            ( model, getServersCmd )

        ServersReceived (Ok servers) ->
            ( { model | servers = servers }, Cmd.none )

        ServersReceived (Err httpError) ->
            ( { model | errorMessage = Just (toString httpError) }, Cmd.none )

        ServerStored (Ok server) ->
            ( model
                |> (if model.modalModus == New then
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

        CreateServer ->
            ( { model | modalVisibility = Modal.shown, modalServer = emptyServer, modalModus = New }, Cmd.none )

        EditServer server ->
            ( { model | modalVisibility = Modal.shown, modalServer = server, modalModus = Edit }, Cmd.none )

        CloseModal ->
            ( { model | modalVisibility = Modal.hidden }, Cmd.none )

        ModalSave ->
            ( model
            , if model.modalModus == New then
                createServerCmd model.modalServer
              else
                updateServerCmd model.modalServer
            )

        ModalDelete ->
            ( model, deleteServerCmd model.modalServer )

        ModalNewPrivateKey newVal ->
            ( newVal
                |> asPrivateKeyIn model.modalServer
                |> asModalServerIn model
            , Cmd.none
            )

        ModalNewUser newVal ->
            ( newVal
                |> asUserIn model.modalServer
                |> asModalServerIn model
            , Cmd.none
            )

        ModalNewIpPort newVal ->
            ( newVal
                |> asIpPortIn model.modalServer
                |> asModalServerIn model
            , Cmd.none
            )

        ModalNewHostname newVal ->
            ( newVal
                |> asHostnameIn model.modalServer
                |> asModalServerIn model
            , Cmd.none
            )

        DismissAlert visability ->
            ( { model | errorMessage = Nothing }, Cmd.none )


setModalServer : Server -> Model -> Model
setModalServer newServer model =
    { model | modalServer = newServer }


asModalServerIn : Model -> Server -> Model
asModalServerIn =
    flip setModalServer


createServer : Server -> Model -> Model
createServer server model =
    { model | servers = server :: model.servers }


updateServer : Server -> Model -> Model
updateServer server model =
    { model | servers = model.servers |> replaceIf (\j -> j.id == server.id) server }


deleteServer : Server -> Model -> Model
deleteServer server model =
    { model | servers = model.servers |> filter (\j -> j.id /= server.id) }


viewServersTable : Model -> Html Msg
viewServersTable model =
    div []
        [ viewErrorMessage model.errorMessage
        , Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Hostname" ]
                    , Table.th [] [ text "IP:Port" ]
                    , Table.th [] [ text "User" ]
                    , Table.th [] [ Button.button [ Button.outlineSuccess, Button.small, Button.attrs [ onClick <| CreateServer ] ] [ text "New Server" ] ]
                    ]
            , tbody = Table.tbody [] (List.map viewServerRow model.servers)
            }
        ]


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage msg =
    Alert.config
        |> Alert.danger
        |> Alert.dismissableWithAnimation DismissAlert
        |> Alert.children [ msg |> Maybe.withDefault "" |> text ]
        |> Alert.view (alertVisability msg)


alertVisability : Maybe String -> Alert.Visibility
alertVisability text =
    case text of
        Just txt ->
            Alert.shown

        Nothing ->
            Alert.closed


viewServerRow : Server -> Table.Row Msg
viewServerRow server =
    Table.tr []
        [ Table.td [] [ text server.hostname ]
        , Table.td [] [ text server.ipPort ]
        , Table.td [] [ text server.user ]
        , Table.td []
            [ Button.button [ Button.info, Button.attrs [ onClick (EditServer server) ] ] [ text "Edit" ]
            ]
        ]


viewModal : Model -> Html Msg
viewModal model =
    div []
        [ Modal.config CloseModal
            |> Modal.large
            |> Modal.hideOnBackdropClick True
            |> Modal.h3 []
                [ text
                    (if model.modalModus == New then
                        "New Server"
                     else
                        "Edit " ++ model.modalServer.hostname
                    )
                ]
            |> Modal.body [] [ viewEditForm model.modalServer ]
            |> Modal.footer []
                [ if model.modalModus == Edit then
                    Button.button [ Button.outlineDanger, Button.attrs [ onClick ModalDelete ] ] [ text "Delete" ]
                  else
                    Html.text ""
                , Button.button [ Button.outlineWarning, Button.attrs [ onClick CloseModal ] ] [ text "Close without saving" ]
                , Button.button [ Button.outlineSuccess, Button.attrs [ onClick ModalSave ] ] [ text "Save" ]
                ]
            |> Modal.view model.modalVisibility
        ]


viewEditForm : Server -> Html Msg
viewEditForm server =
    div []
        [ Form.form []
            [ Form.group []
                [ Form.label [] [ text "Hostname" ]
                , Input.text [ Input.value server.hostname, Input.onInput ModalNewHostname ]
                ]
            , Form.group []
                [ Form.label [] [ text "ip:port" ]
                , Input.text [ Input.value server.ipPort, Input.onInput ModalNewIpPort ]
                ]
            , Form.group []
                [ Form.label [] [ text "user" ]
                , Input.text [ Input.value server.user, Input.onInput ModalNewUser ]
                ]
            , Form.group []
                [ label [ for "privatekeyarea" ] [ text "Private Key" ]
                , Textarea.textarea
                    [ Textarea.id "privatekeyarea"
                    , Textarea.rows 3
                    , Textarea.value server.privateKey
                    , Textarea.onInput ModalNewPrivateKey
                    ]
                ]
            ]
        ]


getServersCmd : Cmd Msg
getServersCmd =
    ConnectionUtil.get "/servers" (Json.Decode.list serverDecoder) ServersReceived


updateServerCmd : Server -> Cmd Msg
updateServerCmd server =
    ConnectionUtil.put ("/servers/" ++ server.id) server serverEncoder serverDecoder ServerStored


deleteServerCmd : Server -> Cmd Msg
deleteServerCmd server =
    ConnectionUtil.delete ("/servers/" ++ server.id) serverDecoder ServerDeleted


createServerCmd : Server -> Cmd Msg
createServerCmd server =
    ConnectionUtil.post "/servers" server serverEncoder serverDecoder ServerStored
