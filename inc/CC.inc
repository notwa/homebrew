// complements F3DEX2.inc

scope CC {
    // the color combiner computes the equation: out = (a - b) * c + d
    // it uses this equation for both color (rgb) and alpha channels.
    // the alpha channel differs in that it uses a different set of inputs.
    // the color combiner can be used in one-cycle or two-cycle mode.
    // the second cycle can use the first cycle's outputs as inputs.
    // using texels requires two-cycle mode regardless of settings.

    // color combiner arguments:
    //       source       |       RGB       |      Alpha      | official name
    //                    | (a - b)* c + d  | (A - B)* C + D  |
    // CC.COLOR_OUT       |  0   0   0   0  | --- --- --- --- | COMBINED
    // CC.COLOR_TEXEL_0   |  1   1   1   1  | --- --- --- --- | TEXEL0
    // CC.COLOR_TEXEL_1   |  2   2   2   2  | --- --- --- --- | TEXEL1
    // CC.COLOR_PRIM      |  3   3   3   3  | --- --- --- --- | PRIMITIVE
    // CC.COLOR_SHADE     |  4   4   4   4  | --- --- --- --- | SHADE
    // CC.COLOR_ENV       |  5   5   5   5  | --- --- --- --- | ENVIRONMENT
    // CC.KEY_CENTER      | ---  6  --- --- | --- --- --- --- | CENTER
    // CC.KEY_SCALE       | --- ---  6  --- | --- --- --- --- | SCALE
    // CC.ALPHA_OUT       | --- ---  7  --- |  0   0  ---  0  | COMBINED_ALPHA
    // CC.ALPHA_TEXEL_0   | --- ---  8  --- |  1   1   1   1  | TEXEL0_ALPHA
    // CC.ALPHA_TEXEL_1   | --- ---  9  --- |  2   2   2   2  | TEXEL1_ALPHA
    // CC.ALPHA_PRIM      | --- --- 10  --- |  3   3   3   3  | PRIMITIVE_ALPHA
    // CC.ALPHA_SHADE     | --- --- 11  --- |  4   4   4   4  | SHADE_ALPHA
    // CC.ALPHA_ENV       | --- --- 12  --- |  5   5   5   5  | ENV_ALPHA
    // CC.LOD             | --- --- 13  --- | --- ---  0  --- | LOD_FRACTION
    // CC.PRIM_LOD        | --- --- 14  --- | --- ---  6  --- | PRIM_LOD_FRAC
    // CC.NOISE           |  7  --- --- --- | --- --- --- --- | NOISE
    // CC.K4              | ---  7  --- --- | --- --- --- --- | K4
    // CC.K5              | --- --- 15  --- | --- --- --- --- | K5
    // CC.CONST_1         |  6  --- ---  6  |  6   6  ---  6  | 1
    // CC.CONST_0         |  8+  8+ 16+  7  |  7   7   7   7  | 0

    // note that these enum values *do not* correspond to hardware values.
    // the hardware values vary across arguments, as shown in the table above.
    constant COLOR_OUT(-1)
    constant COLOR_TEXEL_0(-2)
    constant COLOR_TEXEL_1(-3)
    constant COLOR_PRIM(-4)
    constant COLOR_SHADE(-5)
    constant COLOR_ENV(-6)
    constant KEY_CENTER(-7)
    constant KEY_SCALE(-8)
    constant ALPHA_OUT(-9)
    constant ALPHA_TEXEL_0(-10)
    constant ALPHA_TEXEL_1(-11)
    constant ALPHA_PRIM(-12)
    constant ALPHA_SHADE(-13)
    constant ALPHA_ENV(-14)
    constant LOD(-15)
    constant PRIM_LOD(-16)
    constant NOISE(-17)
    constant K4(-18)
    constant K5(-19)
    constant CONST_1(-20)
    constant CONST_0(-21)

    define c1a(0); define c1b(0); define c1c(0); define c1d(0) // cycle 1 color
    define c1A(0); define c1B(0); define c1C(0); define c1D(0) // cycle 1 alpha
    define c2a(0); define c2b(0); define c2c(0); define c2d(0) // cycle 2 color
    define c2A(0); define c2B(0); define c2C(0); define c2D(0) // cycle 2 alpha

    macro Cycle1Color(variable a, variable b, variable c, variable d) {
        global evaluate CC.c1a(a)
        global evaluate CC.c1b(b)
        global evaluate CC.c1c(c)
        global evaluate CC.c1d(d)
    }

    macro Cycle1Alpha(variable a, variable b, variable c, variable d) {
        global evaluate CC.c1A(a)
        global evaluate CC.c1B(b)
        global evaluate CC.c1C(c)
        global evaluate CC.c1D(d)
    }

    macro Cycle2Color(variable a, variable b, variable c, variable d) {
        global evaluate CC.c2a(a)
        global evaluate CC.c2b(b)
        global evaluate CC.c2c(c)
        global evaluate CC.c2d(d)
    }

    macro Cycle2Alpha(variable a, variable b, variable c, variable d) {
        global evaluate CC.c2A(a)
        global evaluate CC.c2B(b)
        global evaluate CC.c2C(c)
        global evaluate CC.c2D(d)
    }

    macro Cycle2From1() {
        // copy cycle 1's settings to cycle 2.
        global evaluate CC.c2a(c1a)
        global evaluate CC.c2b(c1b)
        global evaluate CC.c2c(c1c)
        global evaluate CC.c2d(c1d)
        global evaluate CC.c2A(c1A)
        global evaluate CC.c2B(c1B)
        global evaluate CC.c2C(c1C)
        global evaluate CC.c2D(c1D)
    }

    macro Cycle1From2() {
        // copy cycle 2's settings to cycle 1.
        global evaluate CC.c1a(c2a)
        global evaluate CC.c1b(c2b)
        global evaluate CC.c1c(c2c)
        global evaluate CC.c1d(c2d)
        global evaluate CC.c1A(c2A)
        global evaluate CC.c1B(c2B)
        global evaluate CC.c1C(c2C)
        global evaluate CC.c1D(c2D)
    }

    macro Commit() {
        // check and apply the current cycle settings.
        // this is gonna get ugly!

        variable c1a({CC.c1a}); variable c2a({CC.c2a})
        variable c1b({CC.c1b}); variable c2b({CC.c2b})
        variable c1c({CC.c1c}); variable c2c({CC.c2c})
        variable c1d({CC.c1d}); variable c2d({CC.c2d})
        variable c1A({CC.c1A}); variable c2A({CC.c2A})
        variable c1B({CC.c1B}); variable c2B({CC.c2B})
        variable c1C({CC.c1C}); variable c2C({CC.c2C})
        variable c1D({CC.c1D}); variable c2D({CC.c2D})

        if c1a <= CC.COLOR_OUT && c1a >= CC.COLOR_ENV {; variable c1a(CC.COLOR_OUT - c1a); }
        if c1b <= CC.COLOR_OUT && c1b >= CC.COLOR_ENV {; variable c1b(CC.COLOR_OUT - c1b); }
        if c1c <= CC.COLOR_OUT && c1c >= CC.COLOR_ENV {; variable c1c(CC.COLOR_OUT - c1c); }
        if c1d <= CC.COLOR_OUT && c1d >= CC.COLOR_ENV {; variable c1d(CC.COLOR_OUT - c1d); }
        if c2a <= CC.COLOR_OUT && c2a >= CC.COLOR_ENV {; variable c2a(CC.COLOR_OUT - c2a); }
        if c2b <= CC.COLOR_OUT && c2b >= CC.COLOR_ENV {; variable c2b(CC.COLOR_OUT - c2b); }
        if c2c <= CC.COLOR_OUT && c2c >= CC.COLOR_ENV {; variable c2c(CC.COLOR_OUT - c2c); }
        if c2d <= CC.COLOR_OUT && c2d >= CC.COLOR_ENV {; variable c2d(CC.COLOR_OUT - c2d); }

        // handle this before we handle the general range since it's different:
        if c1C == CC.LOD {; variable c1C(0); }
        if c2C == CC.LOD {; variable c2C(0); }

        if c1A <= CC.ALPHA_OUT && c1A >= CC.ALPHA_ENV {; variable c1A(CC.ALPHA_OUT - c1A); }
        if c1B <= CC.ALPHA_OUT && c1B >= CC.ALPHA_ENV {; variable c1B(CC.ALPHA_OUT - c1B); }
        if c1D <= CC.ALPHA_OUT && c1D >= CC.ALPHA_ENV {; variable c1D(CC.ALPHA_OUT - c1D); }
        if c2A <= CC.ALPHA_OUT && c2A >= CC.ALPHA_ENV {; variable c2A(CC.ALPHA_OUT - c2A); }
        if c2B <= CC.ALPHA_OUT && c2B >= CC.ALPHA_ENV {; variable c2B(CC.ALPHA_OUT - c2B); }
        if c2D <= CC.ALPHA_OUT && c2D >= CC.ALPHA_ENV {; variable c2D(CC.ALPHA_OUT - c2D); }

        if c1C <= CC.ALPHA_TEXEL_0 && c1C >= CC.ALPHA_ENV {; variable c1C(CC.ALPHA_OUT - c1C); }
        if c2C <= CC.ALPHA_TEXEL_0 && c2C >= CC.ALPHA_ENV {; variable c2C(CC.ALPHA_OUT - c2C); }

        if c1C == CC.PRIM_LOD {; variable c1C(6); }
        if c2C == CC.PRIM_LOD {; variable c2C(6); }

        if c1c <= CC.KEY_SCALE && c1c >= CC.PRIM_LOD {; variable c1c(CC.KEY_SCALE - c1c + 6); }
        if c2c <= CC.KEY_SCALE && c2c >= CC.PRIM_LOD {; variable c2c(CC.KEY_SCALE - c2c + 6); }

        if c1b == CC.KEY_CENTER {; variable c1b(6); }
        if c2b == CC.KEY_CENTER {; variable c2b(6); }

        if c1a == CC.NOISE {; variable c1a(7); }
        if c2a == CC.NOISE {; variable c2a(7); }

        if c1b == CC.K4 {; variable c1b(7); }
        if c2b == CC.K4 {; variable c2b(7); }

        if c1c == CC.K5 {; variable c1c(15); }
        if c2c == CC.K5 {; variable c2c(15); }

        if c1a == CC.CONST_1 {; variable c1a(6); }
        if c1d == CC.CONST_1 {; variable c1d(6); }
        if c1A == CC.CONST_1 {; variable c1A(6); }
        if c1B == CC.CONST_1 {; variable c1B(6); }
        if c1D == CC.CONST_1 {; variable c1D(6); }
        if c2a == CC.CONST_1 {; variable c2a(6); }
        if c2d == CC.CONST_1 {; variable c2d(6); }
        if c2A == CC.CONST_1 {; variable c2A(6); }
        if c2B == CC.CONST_1 {; variable c2B(6); }
        if c2D == CC.CONST_1 {; variable c2D(6); }

        if c1a == CC.CONST_0 {; variable c1a(15); }
        if c1b == CC.CONST_0 {; variable c1b(15); }
        if c1c == CC.CONST_0 {; variable c1c(31); }
        if c1d == CC.CONST_0 {; variable c1d(7); }
        if c1A == CC.CONST_0 {; variable c1A(7); }
        if c1B == CC.CONST_0 {; variable c1B(7); }
        if c1C == CC.CONST_0 {; variable c1C(7); }
        if c1D == CC.CONST_0 {; variable c1D(7); }
        if c2a == CC.CONST_0 {; variable c2a(15); }
        if c2b == CC.CONST_0 {; variable c2b(15); }
        if c2c == CC.CONST_0 {; variable c2c(31); }
        if c2d == CC.CONST_0 {; variable c2d(7); }
        if c2A == CC.CONST_0 {; variable c2A(7); }
        if c2B == CC.CONST_0 {; variable c2B(7); }
        if c2C == CC.CONST_0 {; variable c2C(7); }
        if c2D == CC.CONST_0 {; variable c2D(7); }

        if c1a < 0 || c1a >= 16 {; error "Invalid color for CC cycle 1 (a)"; }
        if c1b < 0 || c1b >= 16 {; error "Invalid color for CC cycle 1 (b)"; }
        if c1c < 0 || c1c >= 32 {; error "Invalid color for CC cycle 1 (c)"; }
        if c1d < 0 || c1d >=  8 {; error "Invalid color for CC cycle 1 (d)"; }
        if c1A < 0 || c1A >=  8 {; error "Invalid alpha for CC cycle 1 (A)"; }
        if c1B < 0 || c1B >=  8 {; error "Invalid alpha for CC cycle 1 (B)"; }
        if c1C < 0 || c1C >=  8 {; error "Invalid alpha for CC cycle 1 (C)"; }
        if c1D < 0 || c1D >=  8 {; error "Invalid alpha for CC cycle 1 (D)"; }
        if c2a < 0 || c2a >= 16 {; error "Invalid color for CC cycle 2 (a)"; }
        if c2b < 0 || c2b >= 16 {; error "Invalid color for CC cycle 2 (b)"; }
        if c2c < 0 || c2c >= 32 {; error "Invalid color for CC cycle 2 (c)"; }
        if c2d < 0 || c2d >=  8 {; error "Invalid color for CC cycle 2 (d)"; }
        if c2A < 0 || c2A >=  8 {; error "Invalid alpha for CC cycle 2 (A)"; }
        if c2B < 0 || c2B >=  8 {; error "Invalid alpha for CC cycle 2 (B)"; }
        if c2C < 0 || c2C >=  8 {; error "Invalid alpha for CC cycle 2 (C)"; }
        if c2D < 0 || c2D >=  8 {; error "Invalid alpha for CC cycle 2 (D)"; }

        gSetCombine(c1a, c1b, c1c, c1d, c1A, c1B, c1C, c1D, c2a, c2b, c2c, c2d, c2A, c2B, c2C, c2D)
    }
}
