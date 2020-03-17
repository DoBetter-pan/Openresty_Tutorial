--------------------------------------
-- @file hello.lua
-- @brief 
-- @author yingx
-- @date 2020-03-15
--------------------------------------
--

local function serve()
    ngx.say("Hello World!")
end

local _M = {
    serve = serve
}

return _M
