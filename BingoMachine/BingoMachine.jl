#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

# 画面レイアウト
win = Window("Bingo Machine")
vbox = Box(:v)
push!(win, vbox)

number_display = Label("")
setproperty!(number_display, :use_markup, true)
hbox = Box(:h)
push!(vbox, number_display)
push!(vbox, hbox)

next_button = Button("Next")
reset_button = Button("Reset")
push!(hbox, next_button)
push!(hbox, reset_button)

setproperty!(vbox, :expand, number_display, true)
setproperty!(hbox, :expand, next_button, true)
setproperty!(hbox, :expand, reset_button, true)


maxnum = 75
number_list = shuffle(1:maxnum)
number_history = []


function next_number()
    if length(number_list) != 0
        n = pop!(number_list)
        push!(number_history, n)
        sort!(number_history)
        GAccessor.markup(number_display, "<span font=\"60\">$n</span>")
    else
        GAccessor.markup(number_display, "<span font=\"60\">Finish!</span>")
    end

    return nothing
end

function reset_number()
    global number_list = shuffle(1:maxnum)
    global number_history = []
    setproperty!(number_display, :label, "")

    return nothing
end


signal_connect(x -> next_number(), next_button, "clicked")
signal_connect(x -> reset_number(), reset_button, "clicked")

showall(win)

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
