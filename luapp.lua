local path = ...

local function saveStrings(s, f)
  local function forEachToken(f, start)
    local function readString(char, start)
      local result = s:sub(start, start)
      start = start + 1
      while true do
        local position = s:find(char, start) or (s:len() + 1)
        local content = s:sub(start, position)
        result = result .. content
        if content:sub(content:len() - 1, content:len() - 1) ~= "\\" then
          return result, position + 1
        end
        start = position + 1
      end
    end
    start = start or 1
    local position, char = s:match("()([\"'])", start)
    f(s:sub(start, position and (position - 1) or s:len()), false)
    if not char then
      return
    end
    local str, next = readString(char, position)
    f(str, true)
    return forEachToken(f, next)
  end
  local strings = {}
  local replaced = ""
  forEachToken(function(token, isString)
      if isString then
        local index = #strings + 1
        strings[index] = token
        replaced = replaced .. '"' .. index .. '"'
      else
        replaced = replaced .. token
      end
  end)
  local result = f(replaced)
  for i, v in pairs(strings) do
    result = result:gsub('"' .. i .. '"', (v:gsub("%%", "%%%%")))
  end
  return result
end

local function replacer(pattern, replacement)
  local function replace(s)
    local result, n = s:gsub(pattern, replacement)
    if result == s then
      return result
    end
    return replace(result)
  end
  return replace
end

local function trimParens(s)
  return s:sub(2, s:len() - 1)
end

local replacers = {
  replacer("$(%b())", "$[_, _2]%1"),
  replacer("$(%b[])(%b())", function(args, body) return "(function(" .. trimParens(args) .. ") return " .. trimParens(body) .. " end)" end)
}

local rf = io.open(path)
local s = rf:read("*a")
rf:close()

s = saveStrings(
  s,
  function(s)
    for _, r in ipairs(replacers) do
      s = r(s)
    end
    return s
end)
io.write(s)
