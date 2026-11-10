\
\ *****************************************************************************
\
\ SPDX-License-Identifier: BSD-2-Clause
\
\ Copyright © 2018-2026 Gavin D. Howard and contributors.
\ Copyright © 2026 brian m. carlson
\
\ Redistribution and use in source and binary forms, with or without
\ modification, are permitted provided that the following conditions are met:
\
\ * Redistributions of source code must retain the above copyright notice, this
\   list of conditions and the following disclaimer.
\
\ * Redistributions in binary form must reproduce the above copyright notice,
\   this list of conditions and the following disclaimer in the documentation
\   and/or other materials provided with the distribution.
\
\ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
\ AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
\ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
\ ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
\ LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
\ CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
\ SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
\ INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
\ CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
\ ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
\ POSSIBILITY OF SUCH DAMAGE.
\
\ *****************************************************************************

: e
        0 0 0 0 0 0 0 0 0
    { x b s n r d i p f v }
    base @ to b
    #10 base !

    x 0<
    if
        1 to n
        x negate to x
    then

    scale @ dup to s
    6 + 0.44 x * + to r
    x fscale 1 + scale !

    begin
        x 1 >
    while
        d 1 + to d
        x 2 f/ to x
        scale @ 1 + scale !
    repeat

    r scale !
    x dup 1 + to r to p
    1 dup to f to v
    2 to i

    begin
        v
    while
        p x * to p
        f i * to f
        p f f/ to v
        r v + to r
        i 1 + to i
    repeat

    r
    begin
        d
    while
        d 1 - to d
        dup *
    repeat

    s scale !
    b base !
    n 0 = if 1 f/ else 1 swap f/ then
;

: l
        0 0 0 0 0 0 0 0
    { x b s r p a q i v }

    x 0 <=
    if
        1 #10 scale @ pow - 1 f/
    else
        base @ to b
        #10 base !
        scale @ dup to s
        6 + scale !

        2 to p

        begin
            x 2 < 0=
        while
            p 2 * to p
            x sqrt to x
        repeat

        begin
            x 0.5 > 0=
        while
            p 2 * to p
            x sqrt to x
        repeat

        x 1 - x 1 + f/
        dup to r to a
        a dup * to q
        1 to v

        3 to i
        begin
            v
        while
            a q * to a
            a i f/ to v
            r v + to r
            i 2 + to i
        repeat

        r p * to r
        s scale !
        b base !
        r 1 f/
    then
;

: s
        0 0  0 0  0 0
    { x b sc r ar q i }

    x 0 <
    if
        x negate s negate
        exit
    then

    base @ to b
    #10 base !
    scale @ dup to sc

    1.1 * 2 + scale !

    1 a to ar

    0 scale !

    x ar f/ 2 + 4 f/ to q
    x 4 q * ar * - to x

    q 2 %
    if
        x negate to x
    then

    sc 2 + scale !

    x dup to ar to r
    x dup * negate to q

    3 to i
    begin
        ar
    while
        q i dup 1 - * f/ ar * to ar
        r ar + to r
        i 2 + to i
    repeat

    sc scale !
    b base !
    r 1 f/
;

: a
        0 0  0 1 0  0 0 0 0 0
    { x b sc r n ar m t f i u }

    base @ to b
    #10 base !
    scale @ to sc

    x 0 <
    if
        -1 to n
        x negate to x
    then

    sc 65 <
    if
        x 1 =
        if
            sc scale !
            0.7853981633974483096156608458198757210492923498437764552437361480 n f/
            b base !
            exit
        then

        x 0.2 =
        if
            sc scale !
            0.1973955598498807583700497651947902934475851037878521015176889402 n f/
            b base !
            exit
        then
    then

    x 0.2 >
    if
        scale @ 5 + scale !
        0.2 a to ar
    then
    scale @ 3 + scale !

    begin
        x 0.2 >
    while
        m 1 + to m
        x 0.2 - 1 0.2 x * + f/ to x
    repeat

    x dup to u to r
    x dup * negate to f
    1 to t

    3 to i
    begin
        t
    while
        u f * to u
        u i f/ to t
        r t + to r
        i 2 + to i
    repeat
    m ar * r + n f/ to r

    sc scale !
    b base !
    r 1 f/
;
