# lune-firebase

## lune-firebase is can using firebase in lune 
config is path, auth

## Install
```
git submodule add https://github.com/kimpure/lune-firebase lune-firebase
```

## example
```luau
local init = require'./init';
local newFirebase = init.getFirebase('firebase');
newFirebase:get('key');
newFirebase:set('key');
```

## Note <a href="https://github.com/Arvoria/Roblox-Firebase/blob/master/src/ServerScriptService/Roblox-Firebase/init.lua">roblox firebase</a>

