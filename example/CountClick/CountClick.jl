#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

win = Window("Count Click")
v = Box(:v)
l = Label("You clicked 0 times.")
b = Button("Click!")
push!(win, v)
push!(v, l)
push!(v, b)
setproperty!(v, :expand, l, true)

showall(win)


niter = 0
function click()
    global niter += 1
    setproperty!(l, :label, "You clicked $niter times.")
    return nothing
end

signal_connect(x -> click(), b, "clicked")


if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
