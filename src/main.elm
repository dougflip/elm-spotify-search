import Html.App exposing (beginnerProgram)
import SpotifySearch exposing (initModel, view, update)

main = beginnerProgram { model = initModel , view = view , update = update }
