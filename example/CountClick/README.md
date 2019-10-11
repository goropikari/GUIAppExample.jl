# Environment
- OS: ArchLinux
- Julia 1.2


<img src="../../screenshots/click.png" align="middle" />
<img src="../../screenshots/clickreset.png" align="middle" />

```bash
./CountClick.jl

./CountClickandReset.jl
```

# Building an executable
```bash
julia -e 'using Pkg; Pkg.add.(["Gtk", "PackageCompiler"]); \
          using PackageCompiler; \
          build_executable("compile_click.jl", "click")'
./click
```
