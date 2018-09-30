# Julia GUI App Example

These are GUI apps in Julia. They are made of GTK.

## REQUIRE
- [Gtk.jl](https://github.com/JuliaGraphics/Gtk.jl)
- [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl) if you build an executable

```julia
using Pkg
Pkg.add("Gtk")
Pkg.add("PackageCompiler")
```

## Reference
- [Gtk.jl documentation](http://juliagraphics.github.io/Gtk.jl/latest/)
- [GTK+ 3 Reference Manual](https://developer.gnome.org/gtk3/stable/)

## Screenshots
### [Count Click](./example/CountClick)
<img src="screenshots/click.png" align="middle" />

<img src="screenshots/clickreset.png" align="middle" />

### [Calculate Area](./example/CalArea)
<img src="screenshots/calarea.png" align="middle" />

### [Bingo machine](./example/BingoMachine)
<img src="screenshots/bingomachine.png" align="middle" />

### [Conway's Game of Life](./example/GameOfLife)
<img src="screenshots/gol.png" align="middle" />

### [Tic Tac Toe](./example/Tictactoe)
<img src="screenshots/tictactoe.png" align="middle" />

### [Text editor](./example/TextEditor)

<img src="screenshots/texteditor.png" align="middle" />

### [Calculator](./example/Calculator)
<img src="screenshots/calculator.png" align="middle" />

### [Plot function](./example/Plotfunction)
<img src="screenshots/plotfunction.png" align="middle" />

### [Reversi](./example/Reversi)
<img src="screenshots/reversi.gif" align="middle" />
