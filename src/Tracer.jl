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

module Tracer

function _convert_mod_path(mod::Symbol)
    return string(mod)
end

function _convert_mod_path(mod::Expr)
    if mod.head != :(.)
        error("Invalid module path.")
    end
    return string(_convert_mod_path(mod.args[1]), "/", mod.args[2])
end

const _included_files = Set{String}()

macro _include_sub(mod)
    mod_path = string(_convert_mod_path(mod), ".jl")
    cur_file = current_module().eval(:(@__FILE__))
    full_path = abspath(joinpath(dirname(cur_file), mod_path))
    if full_path in _included_files
        quote
        end
    else
        push!(_included_files, full_path)
        quote
            $(esc(:include))($mod_path)
        end
    end
end

const _init_hooks = Any[]

function __init__()
    for f in _init_hooks
        f()
    end
end

macro _init_func(ex)
    quote
        push!(_init_hooks, ($(esc(ex))))
    end
end

@_include_sub decompile

end
