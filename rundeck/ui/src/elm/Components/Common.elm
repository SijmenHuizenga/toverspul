module Components.Common exposing (..)

import Http


type ModalModus
    = New
    | Edit


makeErrorMessage : Http.Error -> String
makeErrorMessage err =
    toString err
