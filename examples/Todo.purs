module Todo where

import Prelude

import Data.Int
import Data.Array (Array, length, zip, (..))

import Pux
import Pux.Html as H
import Pux.Html.Attributes as A
import Pux.Html.Events as E

import Pux.Undo as Undo

data Action
    = Add String
    | Remove Int
    | Noop

type State = Array String

ui :: State -> H.Html Action
ui todos = let bind = H.bind in
    H.div # do
        H.input ! E.onKeyDown handleEnter ## []
        H.ul ## map todoItem (zip (0 .. length todos) todos)
  where
    todoItem (Tuple i str) = 
        H.li # do
            H.text str
            H.button ! E.onClick (\_ -> Remove i) # H.text "Remove"
    handleEnter event =
        if event.key == "Enter" 
           then Add event.target.value
           else Noop

update :: Action -> State -> State
update Noop state = 
    state
update (Add string) state =
    state ++ [string]
update (Remove i) state =
    case deleteAt i state of
         Nothing -> state
         Just new -> new

main = do
    app <- start 
        { initialState: Undo.initialState []
        , update: fromSimple (Undo.update update)
        , inputs: []
        , view: Undo.simpleView ui
        }

    renderToDom "#app" app.html
