module Elements.JobsTable exposing (viewJobsTable)

import Bootstrap.Button as Button
import Bootstrap.Table as Table
import Components.Job exposing (emptyJob)
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Message exposing (Msg(OpenModal, RunJob))
import Model exposing (Job, ModalModel(ModalJob), ModalModus(Edit, New))


viewJobsTable : List Job -> Html Msg
viewJobsTable jobs =
    div []
        [ Table.table
            { options = []
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Title" ]
                    , Table.th [] [ text "Hostname Pattern" ]
                    , Table.th [] [ text "Commands" ]
                    , Table.th []
                        [ Button.button
                            [ Button.outlineSuccess
                            , Button.small
                            , Button.attrs [ onClick <| OpenModal (ModalJob emptyJob) New ]
                            ]
                            [ text "New Job" ]
                        ]
                    ]
            , tbody = Table.tbody [] (List.map viewJobRow jobs)
            }
        ]


viewJobRow : Job -> Table.Row Msg
viewJobRow job =
    Table.tr []
        [ Table.td [] [ text job.title ]
        , Table.td [] [ text job.hostnamePattern ]
        , Table.td [] [ text (String.join ", " job.commands) ]
        , Table.td []
            [ Button.button [ Button.info, Button.attrs [ onClick (OpenModal (ModalJob job) Edit) ] ] [ text "Edit" ]
            , text " "
            , Button.button [ Button.warning, Button.attrs [ onClick (RunJob job) ] ] [ text "Run" ]
            ]
        ]
