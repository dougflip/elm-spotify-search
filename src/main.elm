import Html.App exposing (program)
import SpotifySearch exposing (initModel, view, update, subscriptions)

main = program {
    init = (initModel, Cmd.none)
    , update = update
    , subscriptions = subscriptions
    , view = view }
