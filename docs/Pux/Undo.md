## Module Pux.Undo

#### `Action`

``` purescript
data Action n
  = Undo
  | Redo
  | Next n
```

#### `History`

``` purescript
type History = Zipper
```

#### `initialState`

``` purescript
initialState :: forall a. a -> History a
```

#### `attempt`

``` purescript
attempt :: forall a. (a -> Maybe a) -> a -> a
```

#### `editToPast`

``` purescript
editToPast :: forall a. (a -> a) -> History a -> History a
```

#### `update`

``` purescript
update :: forall a n. (n -> a -> a) -> Action n -> History a -> History a
```

#### `simpleView`

``` purescript
simpleView :: forall n. Html n -> Html (Action n)
```

#### `btn`

``` purescript
btn :: forall n. Action n -> Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
```

#### `undoButton`

``` purescript
undoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
```

#### `redoButton`

``` purescript
redoButton :: forall n. Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)
```

#### `view`

``` purescript
view :: forall r n. ((Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> (Array (Attribute (Action n)) -> Array (Html (Action n)) -> Html (Action n)) -> Html (Action n) -> r) -> Html n -> r
```


