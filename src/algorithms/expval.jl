MPSKit.expectation_value(man::Union{InfNNHamChannels,FinNNHamChannels,WinNNHamChannels,FinNNHamCors},nn::NN) = expectation_value(man.envm,nn);
MPSKit.expectation_value(man::Union{InfNNHamChannels,FinNNHamChannels,WinNNHamChannels,FinNNHamCors},opp::MPSKit.MPSBondTensor) = expectation_value(man.envm,opp);

function MPSKit.expectation_value(man::Union{InfEnvManager,WinEnvManager,FinEnvManager},opp::MPSKit.MPSBondTensor)
    expval = map(Iterators.product(1:size(man.peps,1),1:size(man.peps,2))) do (i,j)
        e = @tensor fp1LR(man,North,i,j)[1,2,3,4]*AC(man,East,i,j)[4,5,6,7]*fp1LR(man,South,i,j)[7,8,9,10]*AC(man,West,i,j)[10,11,12,1]*
        man.peps[i,j][11,8,5,2,13]*conj(man.peps[i,j][12,9,6,3,14])*opp[14,13]
        n = @tensor fp1LR(man,North,i,j)[1,2,3,4]*AC(man,East,i,j)[4,5,6,7]*fp1LR(man,South,i,j)[7,8,9,10]*AC(man,West,i,j)[10,11,12,1]*
        man.peps[i,j][11,8,5,2,13]*conj(man.peps[i,j][12,9,6,3,13])

        e/n
    end
end

function MPSKit.expectation_value(man::InfEnvManager,nn::NN)
    tot = 0.0+0im

    for i = 1:size(man.peps,1), j = 1:size(man.peps,2)

        tot += @tensor fp1RL(man,North,i,j)[1,2,3,4]*
            AR(man,East,i,j)[4,5,6,7]*
            AR(man,East,i+1,j)[7,8,9,10]*
            fp1LR(man,South,i+1,j)[10,11,12,13]*
            AL(man,West,i+1,j)[13,14,15,16]*
            AL(man,West,i,j)[16,17,18,1]*
            man.peps[i,j][17,19,5,2,20]*
            conj(man.peps[i,j][18,21,6,3,22])*
            man.peps[i+1,j][14,11,8,19,23]*
            conj(man.peps[i+1,j][15,12,9,21,24])*
            nn.o[22,20,24,23]

        tot += @tensor fp1RL(man,West,i,j)[1,2,3,4]*
                AR(man,North,i,j+1)[7,8,9,10]*
                AR(man,North,i,j)[4,5,6,7]*
                fp1LR(man,East,i,j+1)[10,11,12,13]*
                AL(man,South,i,j+1)[13,14,15,16]*
                AL(man,South,i,j)[16,17,18,1]*
                man.peps[i,j][2,17,19,5,20]*
                conj(man.peps[i,j][3,18,21,6,22])*
                man.peps[i,j+1][19,14,11,8,23]*
                conj(man.peps[i,j+1][21,15,12,9,24])*
                nn.o[22,20,24,23]
    end

    tot
end

function MPSKit.expectation_value(man::InfEnvManager,nn::NNN)
    tot = 0.0+0im

    for i = 1:size(man.peps,1), j = 1:size(man.peps,2)
        tot += @tensor fp1LR(man,West,i,j)[1,2,3,4]*
            AL(man,North,i,j)[4,5,6,7]*
            AC(man,North,i,j+1)[7,8,9,10]*
            fp1LR(man,East,i,j+1)[10,11,12,13]*
            corner(man,SouthEast,i,j+1)[13,14]*
            AR(man,East,i+1,j+1)[14,15,16,17]*
            fp1LR(man,South,i+1,j+1)[17,18,19,20]*
            AL(man,West,i+1,j+1)[20,21,22,23]*
            corner(man,SouthWest,i,j+1)[23,24]*
            AR(man,South,i,j)[24,25,26,1]*
            man.peps[i,j][2,25,27,5,29]*
            conj(man.peps[i,j][3,26,28,6,30])*
            man.peps[i,j+1][27,31,11,8,33]*
            conj(man.peps[i,j+1][28,32,12,9,33])*
            man.peps[i+1,j+1][21,18,15,31,34]*
            conj(man.peps[i+1,j+1][22,19,16,32,35])*
            nn.o[30,29,35,34]

        tot += @tensor fp1LR(man,West,i,j)[1,2,3,4]*
            AL(man,North,i,j)[4,5,6,7]*
            corner(man,NorthWest,i,j+1)[7,8]*
            AR(man,West,i-1,j+1)[8,9,10,11]*
            fp1LR(man,North,i-1,j+1)[11,12,13,14]*
            AL(man,East,i-1,j+1)[14,15,16,17]*
            AC(man,East,i,j+1)[17,18,19,20]*
            fp1LR(man,South,i,j+1)[20,21,22,23]*
            corner(man,SouthWest,i,j+1)[23,24]*
            AR(man,South,i,j)[24,25,26,1]*
            man.peps[i,j][2,25,27,5,29]*
            conj(man.peps[i,j][3,26,28,6,30])*
            man.peps[i,j+1][27,21,18,31,33]*
            conj(man.peps[i,j+1][28,22,19,32,33])*
            man.peps[i-1,j+1][9,31,15,12,34]*
            conj(man.peps[i-1,j+1][10,32,16,13,35])*
            nn.o[35,34,30,29]
    end

    tot
end


function MPSKit.expectation_value(man::FinEnvManager,nn::NN)
    #=
    contrast it with the infpeps code. We only had to add bound checks and normalization (ipeps is normalized in place)
    =#

    tot = 0.0+0im
    normalization = 0.0+0im;
    normalcount = 0;
    for (i,j) in Iterators.product(1:size(man.peps,1),1:size(man.peps,2))
        if i < size(man.peps,1)
            tot += @tensor fp1RL(man,North,i,j)[1,2,3,4]*
                AR(man,East,i,j)[4,5,6,7]*
                AR(man,East,i+1,j)[7,8,9,10]*
                fp1LR(man,South,i+1,j)[10,11,12,13]*
                AL(man,West,i+1,j)[13,14,15,16]*
                AL(man,West,i,j)[16,17,18,1]*
                man.peps[i,j][17,19,5,2,20]*
                conj(man.peps[i,j][18,21,6,3,22])*
                man.peps[i+1,j][14,11,8,19,23]*
                conj(man.peps[i+1,j][15,12,9,21,24])*
                nn.o[22,20,24,23]

            normalcount +=1;
            normalization += @tensor fp1RL(man,North,i,j)[1,2,3,4]*
            AR(man,East,i,j)[4,5,6,7]*
            AR(man,East,i+1,j)[7,8,9,10]*
            fp1LR(man,South,i+1,j)[10,11,12,13]*
            AL(man,West,i+1,j)[13,14,15,16]*
            AL(man,West,i,j)[16,17,18,1]*
            man.peps[i,j][17,19,5,2,20]*
            conj(man.peps[i,j][18,21,6,3,20])*
            man.peps[i+1,j][14,11,8,19,23]*
            conj(man.peps[i+1,j][15,12,9,21,23])
        end

        if j < size(man.peps,2)
            tot += @tensor fp1RL(man,West,i,j)[1,2,3,4]*
                AR(man,North,i,j+1)[7,8,9,10]*
                AR(man,North,i,j)[4,5,6,7]*
                fp1LR(man,East,i,j+1)[10,11,12,13]*
                AL(man,South,i,j+1)[13,14,15,16]*
                AL(man,South,i,j)[16,17,18,1]*
                man.peps[i,j][2,17,19,5,20]*
                conj(man.peps[i,j][3,18,21,6,22])*
                man.peps[i,j+1][19,14,11,8,23]*
                conj(man.peps[i,j+1][21,15,12,9,24])*
                nn.o[22,20,24,23]

            normalcount +=1;
            normalization += @tensor fp1RL(man,West,i,j)[1,2,3,4]*
            AR(man,North,i,j+1)[7,8,9,10]*
            AR(man,North,i,j)[4,5,6,7]*
            fp1LR(man,East,i,j+1)[10,11,12,13]*
            AL(man,South,i,j+1)[13,14,15,16]*
            AL(man,South,i,j)[16,17,18,1]*
            man.peps[i,j][2,17,19,5,20]*
            conj(man.peps[i,j][3,18,21,6,20])*
            man.peps[i,j+1][19,14,11,8,23]*
            conj(man.peps[i,j+1][21,15,12,9,23])
        end
    end

    normalcount*tot/normalization
end


#=
This is a bit poorly defined
=#
function MPSKit.expectation_value(man::WinEnvManager,nn::NN)

    tot = 0.0+0im
    normalization = 0.0+0im;
    normalcount = 0;
    for (i,j) in Iterators.product(1:size(man.peps,1),1:size(man.peps,2))
        if i < size(man.peps,1)
            tot += @tensor fp1RL(man,North,i,j)[1,2,3,4]*
                AR(man,East,i,j)[4,5,6,7]*
                AR(man,East,i+1,j)[7,8,9,10]*
                fp1LR(man,South,i+1,j)[10,11,12,13]*
                AL(man,West,i+1,j)[13,14,15,16]*
                AL(man,West,i,j)[16,17,18,1]*
                man.peps[i,j][17,19,5,2,20]*
                conj(man.peps[i,j][18,21,6,3,22])*
                man.peps[i+1,j][14,11,8,19,23]*
                conj(man.peps[i+1,j][15,12,9,21,24])*
                nn.o[22,20,24,23]

            normalcount +=1;
            normalization += @tensor fp1RL(man,North,i,j)[1,2,3,4]*
            AR(man,East,i,j)[4,5,6,7]*
            AR(man,East,i+1,j)[7,8,9,10]*
            fp1LR(man,South,i+1,j)[10,11,12,13]*
            AL(man,West,i+1,j)[13,14,15,16]*
            AL(man,West,i,j)[16,17,18,1]*
            man.peps[i,j][17,19,5,2,20]*
            conj(man.peps[i,j][18,21,6,3,20])*
            man.peps[i+1,j][14,11,8,19,23]*
            conj(man.peps[i+1,j][15,12,9,21,23])
        end

        if j < size(man.peps,2)
            tot += @tensor fp1RL(man,West,i,j)[1,2,3,4]*
                AR(man,North,i,j+1)[7,8,9,10]*
                AR(man,North,i,j)[4,5,6,7]*
                fp1LR(man,East,i,j+1)[10,11,12,13]*
                AL(man,South,i,j+1)[13,14,15,16]*
                AL(man,South,i,j)[16,17,18,1]*
                man.peps[i,j][2,17,19,5,20]*
                conj(man.peps[i,j][3,18,21,6,22])*
                man.peps[i,j+1][19,14,11,8,23]*
                conj(man.peps[i,j+1][21,15,12,9,24])*
                nn.o[22,20,24,23]

            normalcount +=1;
            normalization += @tensor fp1RL(man,West,i,j)[1,2,3,4]*
            AR(man,North,i,j+1)[7,8,9,10]*
            AR(man,North,i,j)[4,5,6,7]*
            fp1LR(man,East,i,j+1)[10,11,12,13]*
            AL(man,South,i,j+1)[13,14,15,16]*
            AL(man,South,i,j)[16,17,18,1]*
            man.peps[i,j][2,17,19,5,20]*
            conj(man.peps[i,j][3,18,21,6,20])*
            man.peps[i,j+1][19,14,11,8,23]*
            conj(man.peps[i,j+1][21,15,12,9,23])
        end
    end

    normalcount*tot/normalization
end
