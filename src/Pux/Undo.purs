module Pux.Undo where

import Prelude

import Data.Maybe (Maybe, fromMaybe)
import Data.List (List(Nil), (:))
import Pux.Html as H
import Pux.Html (Html, (#))
import Pux.Html (Attribute)
import Pux.Html.Events as E
import Data.List.Zipper (Zipper(Zipper), up, down)

-- | This type augments another type with Undo capabilities.
data Action n 
    = Undo
    | Redo
    | Next n

-- | The stored history of a component. A simpler approach would be to provide
-- | a history as a `List state`, where the head of the list represents the 
-- | current state. Undo in that case is simply `drop 1 history`. 
-- |
-- | If we want to remember the future, then we need to keep track of the
-- | states that we've undo-ed. We can do this simply with a list zipper. List
-- | zippers are defined like:
-- |
-- | ```purescript
-- | data Zipper a = Zipper (List a) a (List a)
-- | ```
-- | 
-- | `Undo` is moving the focus of the zipper to the past/left, and `Redo` is
-- | moving the focus of the zipper to the future/right.
type History = Zipper

-- | Initializes the state of an Undo component.
initialState :: forall a. a -> History a
initialState a = Zipper Nil a Nil

-- | Takes a function operating on a state value and a history. Applies the
-- | function to the current state to yield a new state, and pushes the old
-- | state into the past.
editToPast :: forall a. (a -> a) -> History a -> History a
editToPast g (Zipper p a f) = Zipper (a : p) (g a) f

-- | Wraps a provided update function in the Undo action.
update :: forall a n. (n -> a -> a) -> Action n -> History a -> History a
update f Redo     = attempt down
update f Undo     = attempt up
update f (Next n) = editToPast (f n)

-- | A simple view function that renders the given component along with a plain
-- | undo and redo button.
-- |
-- | ```purescript
-- | view :: State -> Html Action
-- | view state = Undo.simpleView $ H.div # do
-- |     H.ul # do
-- |         H.li # H.text "Stuff"
-- | -- etc...
-- | ```
simpleView :: forall n. Html n -> Html (Action n)
simpleView =
    view \undo redo c ->
        H.div # do
            undo # H.text "Undo"
            redo # H.text "Redo"
            c
  where
    bind = H.bind

-- | The type signature of this function is a little scary. Be not afraid! The
-- | usage is much simpler than it looks. We use it to create a custom wrapper
-- | for the Undo and Redo buttons. We pass in a function that accepts an undo,
-- | redo, and inner component.
-- | 
-- | ```purescript
-- | wrapper :: Html MyAction -> Html (Undo.Action MyAction)
-- | wrapper = 
-- |     Undo.view \undo redo component ->
-- |         H.div # do
-- |             undo ! A.className "btn btn-warning" # do
-- |                 H.text "Undo"
-- |             redo ! A.className "btn btn-success" # do
-- |                 H.h1 # H.text "Redo"
-- |         H.div # component 
-- |   where
-- |     bind = H.bind
-- |
-- | myView :: State -> Html MyAction
-- | myView state = ...
-- | 
-- | wrappedView :: State -> Html (Undo.Action MyAction)
-- | wrappedView state = wrapper (myView state)
-- | ```
-- | 
-- | The above example uses Bootstrap styling on the buttons to demonstrate
-- | that they behave just like normal Pux `Html` elements.
view :: forall r n. ((Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> (Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> Html (Action n) -> r) -> Html n -> r
view k = k undoButton redoButton <<< H.forwardTo Next

-- | Attempts to apply the function `f` to the value `a`. If the function 
-- | returns `Nothing`, then we return the initial value unchanged. Otherwise,
-- | we return the new value.
attempt :: forall a. (a -> Maybe a) -> a -> a
attempt f a = fromMaybe a (f a)

btn :: forall n. Action n -> Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
btn act attrs elems = H.button (attrs <> [E.onClick (const act)]) elems

undoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
undoButton = btn Undo

redoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
redoButton = btn Redo

