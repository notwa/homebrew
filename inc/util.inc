macro align(size) { // Align Byte Amount
    while (pc() % {size}) {
        db 0
    }
}

macro nops(new_pc) {
    if (pc() > {new_pc}) {
        error "PC is already past the point specified"
    }
    while (pc() < {new_pc}) {
        nop
    }
}
