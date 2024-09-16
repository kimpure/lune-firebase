# lune-firebase

## lune-firebase is can using firebase in lune 
config is path, auth

## how to use?
```luau
local init = require'./init';
local newFirebase = init.getFirebase('firebase');
newFirebase:get('key');
newFirebase:set('key');
```
