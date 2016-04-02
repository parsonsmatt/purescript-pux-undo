# `purescript-pux-undo`

This library provides a wrapper that gives you undo and redo for your Pux components.

## Examples:

Suppose you have:

```purescript
module UI where

view :: State -> Html Action
update :: Action -> State -> State
```

and you want to give the component undo capability. All you have to do is:

```purescript
module Main where

import UI as UI
import Pux.Undo as Undo

main = do
    app <- start 
        { view: Undo.simpleView UI.view 
        , update: fromSimple (Undo.update UI.update)
        , inputs: []
        , initialState: Undo.initialState UI.initialState
        }

    renderToDOM "#app" app.html
```

And that's it!

Check out [the example repository](http://www.github.com/parsonsmatt/purescript-pux-undo-ex).
