#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

win = Window("Calculate Area", 400, 100)
hbox = Box(:h)
vbox = Box(:v)
label = Label("")
fh = Frame("Height")
fw = Frame("Width")
hent = Entry(); setproperty!(hent, :text, 3)
went = Entry(); setproperty!(went, :text, 4)

push!(win, hbox)
push!(hbox, label)
push!(hbox, vbox)
push!(vbox, fh); push!(fh, hent)
push!(vbox, fw); push!(fw, went)

setproperty!(hbox, :expand, label, true)
setproperty!(label, :use_markup, true)
setproperty!(label, :label, "<span font=\"60\">" * string(*(getproperty(hent, :text, String) |> parse |> eval, getproperty(went, :text, String) |> parse |> eval)) * "</span>")
showall(win)

function calarea()
    setproperty!(label, :label, "<span font=\"60\">" * string(*(getproperty(hent, :text, String) |> parse |> eval, getproperty(went, :text, String) |> parse |> eval)) * "</span>")

    return nothing
end

signal_connect(x -> calarea(), went, "activate")
signal_connect(x -> calarea(), hent, "activate")

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
