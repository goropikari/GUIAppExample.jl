#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

win = Window("Calculate Area", 400, 100)
hbox = Box(:h)
vbox = Box(:v)
label = Label("")
fh = Frame("Height")
fw = Frame("Width")
hent = Entry(); set_gtk_property!(hent, :text, 3)
went = Entry(); set_gtk_property!(went, :text, 4)

push!(win, hbox)
push!(hbox, label)
push!(hbox, vbox)
push!(vbox, fh); push!(fh, hent)
push!(vbox, fw); push!(fw, went)

set_gtk_property!(hbox, :expand, label, true)
set_gtk_property!(label, :use_markup, true)
set_gtk_property!(label, :label, "<span font=\"60\">" * string(*(get_gtk_property(hent, :text, String) |> Meta.parse |> eval, get_gtk_property(went, :text, String) |> Meta.parse |> eval)) * "</span>")
showall(win)

function calarea()
    set_gtk_property!(label, :label, "<span font=\"60\">" * string(*(get_gtk_property(hent, :text, String) |> Meta.parse |> eval, get_gtk_property(went, :text, String) |> Meta.parse |> eval)) * "</span>")

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
