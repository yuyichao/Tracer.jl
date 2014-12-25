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

using Base

export decompile_func, reconstruct_func, ast_is_closure, ast_get_args_body
export find_method

function decompile_func(code::LambdaStaticData)
    return Base.uncompressed_ast(code)::Expr, code.module::Module
end

function decompile_func(f::Function)
    return decompile_func(f.code)
end

function decompile_func(f::Function, t::ANY)
    return decompile_func(find_method(f, t))::(Expr, Module)
end

function find_method(f::Function, t::ANY)
    meth = methods(f, t)
    if length(meth) > 1
        error("Cannot determine the method to use")
    end
    return meth[1].func::Function
end

function ast_is_closure(ast::Expr)
    return !isempty(ast.args[2][3])::Bool
end

function ast_get_args_body(ast::Expr)
    return ast.args[1], ast.args[3].args
end

function reconstruct_func(args, body, mod::Module)
    code = Expr(:function, Expr(:tuple, args...), Expr(:block, body...))
    return mod.eval(code)::Function
end
