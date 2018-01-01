#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

win = Window("Sample App")
v = Box(:v)
push!(win, v)

l = Label("You clicked 0 times.")
b = Button("Click!")
push!(v, l)
push!(v, b)
setproperty!(v, :expand, l, true)

niter = 0
function click()
    global niter += 1
    setproperty!(l, :label, "You clicked $niter times.")
    return nothing
end

signal_connect(x -> click(), b, "clicked")

showall(win)

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
