function sodium_init()
    ccall((:sodium_init, libsodium), Cint, ())
end

function crypto_box_sealbytes()
    ccall((:crypto_box_sealbytes, libsodium), Csize_t, ())
end

function crypto_box_seal(c, m, mlen, pk)
    ccall(
        (:crypto_box_seal, libsodium),
        Cint,
        (Ptr{Cuchar}, Ptr{Cuchar}, Culonglong, Ptr{Cuchar}),
        c,
        m,
        mlen,
        pk,
    )
end
