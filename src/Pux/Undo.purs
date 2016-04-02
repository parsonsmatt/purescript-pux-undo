module Pux.Undo where

import Prelude

import Data.Maybe (Maybe, fromMaybe)
import Data.List (List(Nil), (:))
import Pux.Html as H
import Pux.Html (Html, (#))
import Pux.Html (Attribute)
import Pux.Html.Events as E
import Data.List.Zipper (Zipper(Zipper), up, down)

data Action n 
    = Undo
    | Redo
    | Next n

type History = Zipper

initialState :: forall a. a -> History a
initialState a = Zipper Nil a Nil

attempt :: forall a. (a -> Maybe a) -> a -> a
attempt f a = fromMaybe a (f a)

editToPast :: forall a. (a -> a) -> History a -> History a
editToPast g (Zipper p a f) = Zipper (a : p) (g a) f

update :: forall a n. (n -> a -> a) -> Action n -> History a -> History a
update f Redo     = attempt down
update f Undo     = attempt up
update f (Next n) = editToPast (f n)

simpleView :: forall n. Html n -> Html (Action n)
simpleView =
    view \undo redo c ->
        H.div [] [ undo # H.text "Undo", redo # H.text "Redo", c ]

btn :: forall n. Action n -> Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
btn act attrs elems = H.button (attrs <> [E.onClick (const act)]) elems

undoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
undoButton = btn Undo

redoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
redoButton = btn Redo

view :: forall r n. ((Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> (Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> Html (Action n) -> r) -> Html n -> r
view k = k undoButton redoButton <<< H.forwardTo Next
