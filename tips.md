```julia
using Gtk, Gtk.ShortNames

win = Window()
textview = TextView()
push!(win, textview)

showall(win)

# get text in GtkTextView
getproperty(textview, :buffer, GtkTextBuffer) |> x -> getproperty(x, :text, String)
```

