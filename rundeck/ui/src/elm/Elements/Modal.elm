module Elements.Modal exposing (..)

import Bootstrap.Modal as BSModal
import Elements.ExecResultModal
import Elements.JobEditModal
import Elements.ServerModal
import Html exposing (Html, div)
import Message exposing (Msg(CloseModal))
import Model exposing (ModalModel(ModalExecResult, ModalJob, ModalServer), ModalModus)


viewModalHeader : ModalModel -> ModalModus -> List (Html.Html Msg)
viewModalHeader model mode =
    case model of
        ModalJob job ->
            Elements.JobEditModal.viewModalHeader job mode

        ModalServer server ->
            Elements.ServerModal.viewModalHeader server mode

        ModalExecResult result ->
            Elements.ExecResultModal.viewModalHeader result mode


viewModalBody : ModalModel -> ModalModus -> List (Html.Html Msg)
viewModalBody model mode =
    case model of
        ModalJob job ->
            Elements.JobEditModal.viewModalBody job mode

        ModalServer server ->
            Elements.ServerModal.viewModalBody server mode

        ModalExecResult result ->
            Elements.ExecResultModal.viewModalBody result mode


viewModalFooter : ModalModel -> ModalModus -> List (Html.Html Msg)
viewModalFooter model mode =
    case model of
        ModalJob job ->
            Elements.JobEditModal.viewModalFooter job mode

        ModalServer server ->
            Elements.ServerModal.viewModalFooter server mode

        ModalExecResult result ->
            Elements.ExecResultModal.viewModalFooter result mode


viewModal : ModalModel -> ModalModus -> BSModal.Visibility -> Html Msg
viewModal model mode visability =
    div []
        [ BSModal.config CloseModal
            |> BSModal.large
            |> BSModal.hideOnBackdropClick True
            |> BSModal.header [] (viewModalHeader model mode)
            |> BSModal.body [] (viewModalBody model mode)
            |> BSModal.footer [] (viewModalFooter model mode)
            |> BSModal.view visability
        ]
