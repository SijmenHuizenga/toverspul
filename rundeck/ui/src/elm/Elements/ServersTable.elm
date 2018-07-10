module Elements.ServersTable exposing (viewServersTable)

import Bootstrap.Button as Button
import Bootstrap.Table as Table
import Components.Server exposing (emptyServer)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(OpenModal))
import Model exposing (ModalModel(ModalServer), ModalModus(..), Server)


viewServersTable : List Server -> Html Msg
viewServersTable servers =
    div []
        [ Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Hostname" ]
                    , Table.th [] [ text "IP:Port" ]
                    , Table.th [] [ text "User" ]
                    , Table.th []
                        [ Button.button
                            [ Button.outlineSuccess
                            , Button.small
                            , Button.attrs [ onClick <| OpenModal (ModalServer emptyServer) New ]
                            ]
                            [ text "New Server" ]
                        ]
                    ]
            , tbody = Table.tbody [] (List.map viewServerRow servers)
            }
        ]


viewServerRow : Server -> Table.Row Msg
viewServerRow server =
    Table.tr []
        [ Table.td [] [ text server.hostname ]
        , Table.td [] [ text server.ipPort ]
        , Table.td [] [ text server.user ]
        , Table.td []
            [ Button.button [ Button.info, Button.attrs [ onClick (OpenModal (ModalServer server) Edit) ] ] [ text "Edit" ]
            ]
        ]
