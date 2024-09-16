--!strict
local net = require'@lune/net';

type luneFirebaseImpl = {
    __index: luneFirebaseImpl,
    getFirebase: (name: string, scope: string?) -> (Firebase),
}

type FirebaseImpl = {
    __index: FirebaseImpl,
    get: (self: Firebase, key: string) -> (any),
    set: (self: Firebase, key: string, value: any, method: "DELETE" | "GET" | "HEAD" | "OPTIONS" | "PATCH" | "POST" | "PUT"?) -> (net.FetchResponse),
    delete: (self: Firebase, key: string) -> (net.FetchResponse),
    increment: (self: Firebase, key: string, delta: number?) -> (net.FetchResponse?),
    update: (self: Firebase, key: string, callback: (any) -> (any), snapshot: any) -> (net.FetchResponse?),
}

export type Firebase = typeof(setmetatable({} :: {
    path: string,
    auth: string,
}, {} :: FirebaseImpl))

local config = {
    DefaultScope = '';
    AuthenticationToken = '';
}

local Firebase = {} :: FirebaseImpl
Firebase.__index = Firebase;

function Firebase.get(self, key)
    key = if key:sub(1, 1) ~= '/' then `/{key}` else key;
    local dir = `{self.path}{net.urlEncode(key)}{self.auth}`;
    local response = net.request({
        url = dir,
        method = 'GET',
    })
    if not response.ok then
        error(`responseError : {response.statusMessage} \n statusCode : {response.statusCode}`);
    end
    return net.jsonDecode(response.body);
end

function Firebase.set(self, key, value, method)
    method = method or 'PUT';
    key = if key:sub(1, 1) ~= '/' then `/{key}` else key;
    local dir = `{self.path}{net.urlEncode(key)}{self.auth}`;
    local response = net.request({
        url = dir,
        method = method,
        headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        body = net.jsonEncode(value),
    })
    if not response.ok then
        error(`responseError : {response.statusMessage} \n statusCode : {response.statusCode}`);
    end
    return response;
end

function Firebase.delete(self, key)
    return self:set(key, '', 'DELETE');
end

function Firebase.increment(self, key, delta)
    local data = self:get(key) or 0 :: number;
    delta = if type(delta) == 'number' then delta else 1;
    if type(data) == 'number' then
        data += delta :: number
        return self:set(key, data)
    end
    return
end

function Firebase.update(self, key, callback, snapshot)
    local data = snapshot or self:get(key);
    local updated = callback(data);
    if updated then
        return self:set(key, updated, 'PATCH');
    end 
    return
end

local luneFirebase = {} :: luneFirebaseImpl;
luneFirebase.__index = luneFirebase;

function luneFirebase.getFirebase(name, scope)
    scope = scope or config.DefaultScope;

    local path = `{scope}{net.urlEncode(name)}`;
    local auth = `.json?auth={config.AuthenticationToken}`;

    return setmetatable({
        path=path,
        auth=auth,
    }, Firebase)

end

return luneFirebase;