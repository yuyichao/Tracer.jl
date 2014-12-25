# Copyright (c) 2014-2014, Yichao Yu <yyc1992@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3.0 of the License, or (at your option) any later version.
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
# You should have received a copy of the GNU Lesser General Public
# License along with this library.

using Tracer

glob_var1 = 1

f1 = (a) -> a
f2 = (a) -> glob_var1
f3 = (a) -> (() -> a)
f4 = f3(3)
f5 = (a) -> begin
    b = a > 1 ? 1 : -1
    return sin(b)
end

function test_function(f::Function, is_closure::Bool, inputs::Tuple...)
    ast, mod = decompile_func(f)
    @assert ast_is_closure(ast) == is_closure
    args, body = ast_get_args_body(ast)
    new_f = reconstruct_func(args, body, mod)
    for input in inputs, i in 1:3
        res = f(input...)
        new_res = new_f(input...)
        @assert(res == new_res,
                "i: $i\nres: $res\nnew_res: $new_res\nAST: $ast\ninput: $input")
    end
end

test_function(f1, false, (-2,), (-1,), (0,), (1,), (2,))
test_function(f2, false, (-2,), (-1,), (0,), (1,), (2,))
test_function(f3, false)
test_function(f4, true)
test_function(f5, false, (-2,), (-1,), (0,), (1,), (2,))
test_function(find_method(+, (Int, Int)), false, (-2, 2), (1, 1), (3, 4))
test_function(find_method(+, (Float64, Float64)), false,
              (-2., 2.), (1., 1.), (3., 4.))
