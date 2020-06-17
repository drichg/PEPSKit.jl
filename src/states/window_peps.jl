#=
A mutable window of tensors embedded in an infinite peps ...
=#
mutable struct WinPEPS{T<:PEPSType}
    inside :: FinPEPS{T}
    outside :: InfPEPS{T}
end

function WinPEPS(outside::InfPEPS{T},width::Int,height::Int) where T
    inside = FinPEPS{T}(outside[1:width,1:height]);
    WinPEPS{T}(inside,outside);
end

Base.copy(f::WinPEPS) = WinPEPS(copy(f.inside),copy(f.outside));

function Base.getindex(st::WinPEPS,row,col)
    if row > 0 && col > 0 && row <= size(st.inside,1) && col <=size(st.inside,2)
        return st.inside[row,col]
    else
        return st.outside[row,col]
    end
end

function Base.setindex!(st::WinPEPS,v,row,col)
    #we can easily support it, but I don't see when it should be needed?
    !(row > 0 && col > 0 && row <= size(st.inside,1) && col <=size(st.inside,2)) && throw(ArgumentError("unsupported"))

    setindex!(st.inside,v,row,col)
    return st
end

Base.size(t::WinPEPS) = size(t.inside)
Base.size(t::WinPEPS,i) = size(t.inside,i)

Base.rotl90(dat::WinPEPS) = WinPEPS(rotl90(dat.inside),rotl90(dat.outside));
Base.rotr90(dat::WinPEPS) = WinPEPS(rotr90(dat.inside),rotr90(dat.outside));

#the physical space
TensorKit.space(t::WinPEPS,i,j) = space(t[i,j],5)

Base.iterate(t::WinPEPS) = iterate(t.inside)
Base.iterate(t::WinPEPS,state) = iterate(t.inside,state)
Base.length(t::WinPEPS) = length(t.inside)
Base.map(f,x::WinPEPS) = map(f,x.inside);

Base.lastindex(t::WinPEPS, i::Int64) = size(t,i)
Base.similar(t::WinPEPS) = WinPEPS(similar(t.inside),copy(t.outside))
