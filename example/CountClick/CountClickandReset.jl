#!/usr/bin/env julia
using Gtk.ShortNames, Gtk

win = GtkWindow("Sample App")
v = GtkBox(:v)
push!(win, v)

l = GtkLabel("You clicked 0 times.")
r = GtkButton("Reset")
b = GtkButton("Click")
push!(v, l)
push!(v, r)
push!(v, b)
set_gtk_property!(v, :expand, l, true)

niter = 0
function click(widget)
    global niter += 1
    set_gtk_property!(l, :label, "You clicked $niter times.")
    return nothing
end

function resetcount(widget)
    global niter = 0
    set_gtk_property!(l, :label, "You clicked 0 times.")
    return nothing
end

signal_connect(click, b, "clicked")
signal_connect(resetcount, r, "clicked")


showall(win)


if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
