#!/usr/bin/env julia
using Gtk.ShortNames, Gtk

include("GameOfLife.jl")

const win = GtkWindow("Game of Life")
const hbox = GtkBox(:h)
const board = GtkLabel("")

const buttonbox = GtkBox(:v)
const label = GtkLabel("0 generation")
const reset_button = GtkButton("Reset")
const next_button = GtkButton("Next")

push!(win, hbox)
push!(hbox, board)
push!(hbox, buttonbox)
push!(buttonbox, label)
push!(buttonbox, reset_button)
push!(buttonbox, next_button)

set_gtk_property!(hbox, :expand, board, true)


row, col = 20, 40
d = Gol(row, col)
GAccessor.markup(board, "<span font_desc=\"mono 10\">" * sprint(d) * "</span>")

ngen = 0
function nextstate(x)
    global ngen += 1
    set_gtk_property!(label, :label, "$ngen generation")
    d.state = next_generation(d)
    GAccessor.markup(board, "<span font_desc=\"mono 10\">" * sprint(d) * "</span>")
end

function resetbutton(x, l)
    global ngen = 0
    set_gtk_property!(label, :label, "0 generation")
    set_gtk_property!(l, :label, "")
    global d = Gol(row, col)
    GAccessor.markup(board, "<span font_desc=\"mono 10\">" * sprint(d) * "</span>")
    # set_gtk_property!(l, :label, sprint(d))
    return nothing
end


signal_connect(nextstate, next_button, "clicked")
signal_connect(x -> resetbutton(x, board), reset_button, "clicked")

showall(win)


if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
