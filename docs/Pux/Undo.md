## Module Pux.Undo

#### `Action`

``` purescript
data Action n
  = Undo
  | Redo
  | Next n
```

This type augments another type with Undo capabilities.

#### `History`

``` purescript
type History = Zipper
```

The stored history of a component. A simpler approach would be to provide
a history as a `List state`, where the head of the list represents the 
current state. Undo in that case is simply `drop 1 history`. 

If we want to remember the future, then we need to keep track of the
states that we've undo-ed. We can do this simply with a list zipper. List
zippers are defined like:

```purescript
data Zipper a = Zipper (List a) a (List a)
```

`Undo` is moving the focus of the zipper to the past/left, and `Redo` is
moving the focus of the zipper to the future/right.

#### `initialState`

``` purescript
initialState :: forall a. a -> History a
```

Initializes the state of an Undo component.

#### `update`

``` purescript
update :: forall a n. (n -> a -> a) -> Action n -> History a -> History a
```

Wraps a provided update function in the Undo action.

#### `simpleView`

``` purescript
simpleView :: forall n. Html n -> Html (Action n)
```

A simple view function that renders the given component along with a plain
undo and redo button.

```purescript
view :: State -> Html (Undo.Action MyAction)
view state = Undo.simpleView $ H.div # do
    H.ul # do
        H.li # H.text "Stuff"
-- etc...
```

#### `view`

``` purescript
view :: forall r n. ((Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> (Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> Html (Action n) -> r) -> Html n -> r
```

The type signature of this function is a little scary. Be not afraid! The
usage is much simpler than it looks. We use it to create a custom wrapper
for the Undo and Redo buttons. We pass in a function that accepts an undo,
redo, and inner component.

```purescript
wrapper :: Html MyAction -> Html (Undo.Action MyAction)
wrapper = 
    Undo.view \undo redo component ->
        H.div # do
            undo ! A.className "btn btn-warning" # do
                H.text "Undo"
            redo ! A.className "btn btn-success" # do
                H.h1 # H.text "Redo"
        H.div # component 
  where
    bind = H.bind

myView :: State -> Html MyAction
myView state = ...

wrappedView :: State -> Html (Undo.Action MyAction)
wrappedView state = wrapper (myView state)
```

The above example uses Bootstrap styling on the buttons to demonstrate
that they behave just like normal Pux `Html` elements.


