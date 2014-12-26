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

type DecompileResult
    ast::Expr
    modu::Module
    kw::Bool
    functor::Bool
end

function decompile_func(code::LambdaStaticData, kw::Bool=false,
                        functor::Bool=false)
    return DecompileResult(Base.uncompressed_ast(code),
                           code.module, kw, functor)
end

function decompile_func(f::Function, kw::Bool=false, functor::Bool=false)
    return decompile_func(f.code, kw, functor)::DecompileResult
end

function decompile_func(f::Function, t::ANY, kw::Bool=false)
    return decompile_func(find_method(f, t, kw), kw, false)::DecompileResult
end

function decompile_func(f::ANY, t::ANY, kw::Bool=false)
    return decompile_func(find_method(f, t, kw), kw, true)::DecompileResult
end

function find_method(f::Function, t::ANY, kw::Bool=false)
    if kw
        if !isdefined(f.env, :kwsorter)
            error("Function does not support keyword arguments")
        end
        f = f.env.kwsorter
    end
    meth = methods(f, t)
    if length(meth) > 1
        error("Cannot determine the method to use")
    end
    return meth[1].func::Function
end

function find_method(f::ANY, t::ANY, kw::Bool=false)
    find_method(call, tuple(isa(f, Type) ? Type{f} : typeof(f), t...), kw)
end

function ast_is_closure(ast::Expr)
    return !isempty(ast.args[2][3])::Bool
end

function ast_is_closure(ast::DecompileResult)
    return ast_is_closure(ast.ast)
end

function _fix_arg_ast(arg::Symbol, modu::Module)
    return arg
end

function _fix_arg_ast(arg::Expr, modu::Module)
    if arg.head != :(::)
        return arg
    end
    # FIXME? use eval for now
    typ = modu.eval(arg.args[2])
    if !(typ <: Vararg)
        return arg
    end
    typ = typ.parameters[1]
    sym = arg.args[1]
    return Expr(:(...), Expr(:(::), sym, typ))
end

function ast_get_args_body(ast::Expr, modu::Module)
    args = ast.args[1]
    body = ast.args[3].args
    for i in 1:length(args)
        args[i] = _fix_arg_ast(args[i], modu)
    end
    return args, body
end

function ast_get_args_body(res::DecompileResult)
    return ast_get_args_body(res.ast, res.modu)
end

function reconstruct_func(args, body, modu::Module)
    code = Expr(:function, Expr(:tuple, args...), Expr(:block, body...))
    return modu.eval(code)::Function
end
