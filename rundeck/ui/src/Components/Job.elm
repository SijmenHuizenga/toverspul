module Components.Job exposing (..)

import List.Extra
import Model exposing (Job, Model)


emptyJob : Job
emptyJob =
    { id = "", title = "", hostnamePattern = "", commands = [] }


updateJob : Job -> Model -> Model
updateJob job model =
    { model | jobs = model.jobs |> List.Extra.replaceIf (\j -> j.id == job.id) job }


createJob : Job -> Model -> Model
createJob job model =
    { model | jobs = job :: model.jobs }


deleteJob : Job -> Model -> Model
deleteJob job model =
    { model | jobs = model.jobs |> List.filter (\j -> j.id /= job.id) }
