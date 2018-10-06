#!/usr/bin/env julia
using Gtk, Gtk.ShortNames, Printf
using Random: rand!

row, column, space = 400, 600, 20
mutable struct GOL
    tmpmat::Matrix{Bool}
    now::Matrix{Bool}
    row::Int
    column::Int
    
    function GOL()
        row_cell = div(row, space)
        column_cell = div(column, space)
        new(falses(row_cell, column_cell), falses(row_cell, column_cell), row_cell, column_cell)
    end
end
gol = GOL()

c = @GtkCanvas(column, row)
win = GtkWindow("Game of Life")
hbox = GtkBox(:h)
vbox = GtkBox(:v)
button_reset = GtkButton("Reset")
button_random = GtkButton("Random")
button_start = GtkButton("Start")
push!(vbox, button_reset)
push!(vbox, button_random)
push!(vbox, button_start)
push!(win, hbox)
push!(hbox, c)
push!(hbox, vbox)
set_gtk_property!(hbox, :expand, c, true)
showall(win)

"white brckgroud"
function makebroad!(c)
    @guarded draw(c) do widget
        ctx = getgc(c)
        rectangle(ctx, 0, 0, column, row)
        set_source_rgb(ctx, 1, 1, 1)
        fill(ctx)
    end
end
    
"make grid"
function grid!(c)
    @guarded draw(c) do widget
        n = 8
        ctx = getgc(c)
        h = height(c)
        w = width(c)
        
        for x in 0:space:w
            move_to(ctx, x, 0)
            line_to(ctx, x, h)
        end
        for y in 0:space:h
            move_to(ctx, 0, y)
            line_to(ctx, w, y)
        end    
        set_source_rgb(ctx, 0, 0, 0)
        stroke(ctx)
        reveal(widget)
    end
    show(c)
end
# grid!(c)

function initilize!(c)
    makebroad!(c)
    grid!(c)
end
initilize!(c)

function paintcell!(c, x, y, red=0, green=1, blue=1)
    @guarded draw(c) do widget
        ctx = getgc(c)
        set_source_rgb(ctx, red, green, blue)
        rectangle(ctx, x*space, y*space, space, space)
        fill(ctx)
        reveal(widget)
    end
    # show(c)
end

function board_draw!(c, gol)
    row, column = gol.row, gol.column
    # grid!(c)
    for x in 0:column-1
        for y in 0:row-1
            if gol.now[y+1, x+1]
                paintcell!(c, x, y)
            else
                paintcell!(c, x, y, 1, 1, 1)
            end
        end
    end
    # grid!(c)
end


c.mouse.button1press = @guarded (widget, event) -> begin
    x, y = Int(div(event.x, space)), Int(div(event.y, space))
    println(x, " ", y)
    paintcell!(c, x, y)
    grid!(c)
    gol.now[y+1, x+1] = true
end

function board_reset!()
    initilize!(c)
    row, column = gol.row, gol.column
    fill!(gol.now, false)
    fill!(gol.tmpmat, false)
    # show(c)
    return
end
signal_connect(x -> board_reset!(), button_reset, "clicked")

function board_rand!()
    # initilize!(c)
    row, column = gol.row, gol.column
    rand!(gol.now)
    fill!(gol.tmpmat, false)
    board_draw!(c, gol)
    println("rand")
    # show(c)
    return
end
signal_connect(x -> board_rand!(), button_random, "clicked")

function next_gen_state(gol, x, y)
    row, column = gol.row, gol.column
    nowboard = gol.now
    num = 0
    for i in -1:1
        for j in -1:1
            num += nowboard[mod1(x+i, row), mod1(y+j, column)]
        end
    end
    # println(num)
    
    if !nowboard[x,y] # 死んでいた場合
        if num == 3
            return true
        else
            return false
        end
    else
        if num <= 2 || num >= 5
            return false
        else
            return true
        end
    end        
end

function next_gen!(gol)
    row, column = gol.row, gol.column
    for x in 1:row
        for y in 1:column
            gol.tmpmat[x,y] = next_gen_state(gol, x, y)
        end
    end
    copyto!(gol.now, gol.tmpmat)
    return
end

ngen = 0
function board_start!()
    # initilize!(c)
    row, column = gol.row, gol.column
    for i in 1:50
        sleep(0.1)
        next_gen!(gol)
        # fill!(gol.tmpmat, false)
        board_draw!(c, gol)
        global ngen += 1
        @printf("%d\r", ngen)
        # show(c)
    end
    return
end
signal_connect(x -> board_start!(), button_start, "clicked")
showall(win)

if !isinteractive()
    cond = Condition()
    signal_connect(win, :destroy) do widget
        notify(cond)
    end
    wait(cond)
end
