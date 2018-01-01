#!/usr/bin/env julia

using Gtk.ShortNames, Gtk

n = 3
win = GtkWindow("Tic tac toe", 100, 100)
f = GtkFrame()
v = GtkBox(:v)
push!(win, f)
push!(f, v)

### メニュー
const menu_bar = GtkMenuBar()
const file = GtkMenuItem("File")
const filemenu = GtkMenu(file)
const menu_quit = GtkMenuItem("Quit")
push!(v, menu_bar)
push!(menu_bar, file)
push!(filemenu, menu_quit)

label = GtkLabel("")
reset_button = GtkButton("Reset")
g = Grid()
push!(v, label)
push!(v, reset_button)
push!(v, g)

for i in 1:n, j in 1:n
    g[i,j] = GtkButton()
end

for i in 1:n, j in 1:n
    signal_connect(x -> onoff(x, g[i,j]), g[i,j], "clicked")
end

iter = 0
function onoff(x, h)
    global iter += 1
    if isodd(iter)
        setproperty!(h, :label, "O")
        setproperty!(h, :name, "O")
    else
        setproperty!(h, :label, "X")
        setproperty!(h, :name, "X")
    end
    checkboard()

    return nothing
end

function checkboard()
    if (all([ getproperty(g[1,i], :name, String) == getproperty(g[1,1], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[i,1], :name, String) == getproperty(g[1,1], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[2,i], :name, String) == getproperty(g[2,2], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[i,2], :name, String) == getproperty(g[2,2], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[3,i], :name, String) == getproperty(g[3,3], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[i,3], :name, String) == getproperty(g[3,3], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[i,i], :name, String) == getproperty(g[2,2], :name, String) != "" for i in 1:n]) ||
        all([ getproperty(g[3-i,i+1], :name, String) == getproperty(g[2,2], :name, String) != "" for i in 0:n-1]) )

        if isodd(iter)
            setproperty!(label, :label, "Win O")
        else
            setproperty!(label, :label, "Win X")
        end

    elseif (all([getproperty(g[i,j], :name, String) != "" for i in 1:n for j in 1:n]) &&
                                getproperty(label, :label, String) == "")
        setproperty!(label, :label, "Draw")

    end
end

function reset_state(x)
    global iter = 0
    for i in 1:n, j in 1:n
        setproperty!(g[i,j], :label, "")
        setproperty!(g[i,j], :name, "")
    end
    setproperty!(label, :label, "")
end

signal_connect(reset_state, reset_button, "clicked")


showall(win)

signal_connect(menu_quit, :activate) do w
  if !isinteractive()
    Gtk.gtk_quit()
  else
    exit()
  end
end

if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
end
