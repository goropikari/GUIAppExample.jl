import Base.sprint
export Gol, game, glidergun

type Gol
    state::Matrix{Int8}
    isperiodic::Bool
    generations::Int
end

function Gol(n::Int,
             m::Int = n;
             isperiodic::Bool = true,
             generations::Int = 100)
    state = rand(Int8[0,1], n, m)

    return Gol(state, isperiodic, generations)
end

"count the number of live neighbors"
function determine_neighbor_state(d::Gol, i::Integer, j::Integer)
    n, m = size(d.state)
    neighbor = [(p,q) for p in -1:1 for q in -1:1 if !(p == 0 && q == 0)]
    total = Int8(0)
    if d.isperiodic # periodic
        for idx in 1:8
            total += d.state[mod1(i + neighbor[idx][1], n), mod1(j + neighbor[idx][2], m)]
        end
    else # non-periodic
        for idx in 1:8
            if !(i + neighbor[idx][1] <= 0 || j + neighbor[idx][2] <= 0 || i + neighbor[idx][1] > n || j + neighbor[idx][2] > m)
                total += d.state[i + neighbor[idx][1], j + neighbor[idx][2]]
            end
        end
    end

    return total
end

"update cells"
function next_generation(d::Gol)
    n,m = size(d.state)
    next_state = zeros(Int8, n, m)
    for col in 1:m
        for row in 1:n
            if d.state[row, col] == one(d.state[row, col]) # live
                if determine_neighbor_state(d, row, col) in Int8[2, 3]
                    next_state[row, col] = Int8(1)
                end
            else # dead
                if determine_neighbor_state(d, row, col) == Int8(3)
                    next_state[row, col] = Int8(1)
                end
            end
        end
    end
    return next_state
end

function sprint(d::Gol)
    n, m = size(d.state)
    sm = Matrix{String}(n,m)
    s = ""
    for i in 1:n
        for j in 1:m
            if Bool(d.state[i,j])
                s *= "X"
            else
                s *= " "
            end
        end
        s *= "\n"
    end
    return s = chomp(s)
end

