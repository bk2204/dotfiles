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
    x 0< if 1 to n x negate to x then
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
    d while
    d 1 - to d
    dup *
    repeat
    s scale !
    b base !
    n 0 = if 1 f/ else 1 swap f/ then
;

: t
    { x }
    x
    begin
    x 0 >
    while
    x .
    x 1 - to x
    repeat
;
