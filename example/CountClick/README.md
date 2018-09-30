# Environment
- Julia 1.0
- Gtk.jl v0.16.4
- PackageCompiler v0.5.0


<img src="../../screenshots/click.png" align="middle" />
<img src="../../screenshots/clickreset.png" align="middle" />

```julia
./CountClick.jl

./CountClickandReset.jl
```

# Building an executable
```julia
julia> using PackageCompiler

julia> build_executable("compile_click.jl", "click")

julia> run(`builddir/click`)
```
