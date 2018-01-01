#!/usr/bin/env julia
using Gtk.ShortNames, Gtk

win = GtkWindow("Sample App")
v = GtkBox(:v)
push!(win, v)

l = GtkLabel("You clicked 0 times.")
b = GtkButton("Press me")
push!(v, l)
push!(v, b)

niter = 0
function click(widget)
    global niter += 1
    setproperty!(l, :label, "You clicked $niter times.")
    return nothing
end

signal_connect(click, b, "clicked")

showall(win)

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
