#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

ui = Builder(filename=(@__DIR__) * "/ui.glade")
showall(ui["win"])


function preview()
    getproperty(ui["text"], :buffer, GtkTextBuffer) |> x -> getproperty(x, :text, String) |> x -> setproperty!(ui["label"], :label, x)

    return nothing
end

function open_about()
    showall(ui["about"])

    return nothing
end

signal_connect(x-> preview(), ui["preview_button"], "clicked")
signal_connect((x,y) -> open_about(), ui["menu_about"], :activate, Void, (), false)


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

