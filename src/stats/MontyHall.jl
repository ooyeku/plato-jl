module MontyHall
using Plots



function monty_hall(N::Int)
    stay = zeros(Int32, N)
    switch = zeros(Int32, N)

    for game in 1:N
        prize = rand(1:3)
        choice = rand(1:3)
        if prize == choice
            stay[game] = 1
        end
    end
    
    for game in 1:N
        prize = rand(1:3)
        choice = rand(1:3)
        if choice != prize
            switch[game] = 1
        end
    end
    stayra = [sum(stay[1:i])/i for i in 1:N]
    switchra = [sum(switch[1:i])/i for i in 1:N]
    
    
    plot(1:N, [stayra, switchra, ones(N)*1/3, ones(N)*2/3], label=["Stay" "Switch" "" ""])
    annotate!(2700, 1/3, text("1/3", 10))
    annotate!(2700, 2/3, text("2/3", 10))
end

end