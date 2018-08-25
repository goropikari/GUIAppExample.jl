#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

ui = Builder(filename=(@__DIR__) * "/ui.glade")
showall(ui["win"])


function preview()
    get_gtk_property(ui["text"], :buffer, GtkTextBuffer) |> x -> get_gtk_property(x, :text, String) |> x -> set_gtk_property!(ui["label"], :label, x)

    return nothing
end

function open_about()
    showall(ui["about"])

    return nothing
end

signal_connect(x-> preview(), ui["preview_button"], "clicked")
signal_connect((x,y) -> open_about(), ui["menu_about"], :activate, Nothing, (), false)


signal_connect(ui["file_quit"], :activate) do w
  if !isinteractive()
    Gtk.gtk_quit()
  else
    exit()
  end
end

if !isinteractive()
    c = Condition()
    signal_connect(ui["win"], :destroy) do widget
        notify(c)
    end
    wait(c)
end

