module Hello
using Gtk, Graphics

global flag=0
global dir = ( (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1) )

mutable struct Board
    table::Matrix{Int}
    turn::Int # 1-> white, 0->black
    n::Int # linear size of board

    function Board()
        n = 8
        t = ones(Int, n, n) .* Int(-1)
        a = div(n, 2);
        t[a,a] = t[a+1, a+1] = 1
        t[a,a+1] = t[a+1, a] = 0
        new(t, 1, n)
    end
end

function flip!(b::Matrix{Int}, x::Int, y::Int, h::Int, v::Int, bound::Int, turn::Int)
    ( !(0 < x <= bound) || !(0 < y <= bound) ) && return
    b[x,y] == turn && return (global flag=1; nothing)
    flip!(b, x+h,y+v, h, v, bound, turn)
    flag == 1 && (b[x,y] = turn; nothing)
end
flip!(b::Board, x::Int, y::Int, h::Int, v::Int) = flip!(b.table, x, y, h, v, b.n, b.turn)

function initialize!(c::GtkCanvas)
    @guarded draw(c) do widget
        n = 8
        ctx = getgc(c)
        h = height(c)
        w = width(c)
        space = h/n
        r = space/2

        rectangle(ctx, 0, 0, w, h)
        set_source_rgb(ctx, 0, 0.6, 0)
        fill(ctx)

        for x in 1:n
            move_to(ctx, x*w/n, 0)
            line_to(ctx, x*w/n, h)
        end
        for y in 1:7
            move_to(ctx, 0, y*w/n)
            line_to(ctx, w, y*w/n)
        end
        set_source_rgb(ctx, 0, 0, 0)
        stroke(ctx)
        reveal(widget)
    end
    show(c)
end

function draw_board!(c::GtkCanvas, b::Board)
    table = b.table
    n = 8
    for row in 1:n
        for col in 1:n
            color = table[row,col]
            if color != -1
                @guarded draw(c) do widget
                    ctx = getgc(c)
                    h = height(c)
                    w = width(c)
                    space = h/n
                    r = space/2

                    set_source_rgb(ctx, color, color, color)
                    arc(ctx, (row-1)*space+r, (col-1)*space+r, 0.75*r, 0, 2pi)
                    fill(ctx)
                    reveal(widget)
                end
            end
        end
    end
    show(c)
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    b = Board()
    c = @GtkCanvas()
    n = 400
    bnum = sum(b.table .== 0)
    wnum = sum(b.table .== 1)
    win = GtkWindow(c,
            "Reversi: White $(lpad(wnum, 2)), Black: $(lpad(bnum, 2)), Turn: " * (b.turn == 1 ? "White" : "Black"),
            n, n)
    initialize!(c)
    draw_board!(c, b)

    c.mouse.button1press = @guarded (widget, event) -> begin
        n = 8
        turn = b.turn
        ctx = getgc(widget)
        set_source_rgb(ctx, turn, turn, turn)
        h = height(c)
        space = h/n
        r = space/2
        x, y = Int(div(event.x, space)), Int(div(event.y, space))
        # println(x, y)
        x += 1; y += 1
        b.table[x, y] = b.turn
        for (h,v) in dir
            if 0 < x+h <= n && 0 < y+v <= n
                b.table[x+h, y+v] == -1 && continue
                flip!(b, x+h, y+v, h, v)
                global flag=0
            end
        end
        initialize!(c)
        draw_board!(c, b)
        draw_board!(c, b)
        reveal(widget)
        b.turn = xor(1, b.turn)
        bnum = sum(b.table .== 0)
        wnum = sum(b.table .== 1)
        set_gtk_property!(win, :title, "Reversi: White $(lpad(wnum, 2)), Black: $(lpad(bnum, 2)), Turn: " * (b.turn == 1 ? "White" : "Black"))
    end
    initialize!(c)
    draw_board!(c,b)

    if !isinteractive()
        cond = Condition()
        signal_connect(win, :destroy) do widget
            notify(cond)
        end
        wait(cond)
    end
    return 0
end

end
