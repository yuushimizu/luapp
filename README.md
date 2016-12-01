Lua Preprocessor for myself.

```
lua luapp.lua [in] > [out]
```

```
$(_ * 10) --> (function(_, _2) return _ * 10 end)
```

```
$[x, y](x + y) --> (function(x, y) return x + y end)
```

```
$[...](hibiki(...)) --> (function(...) return hibiki(...) end)
```