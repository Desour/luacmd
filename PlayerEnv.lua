
local PlayerEnv =
{
   playerContexts = setmetatable({}, { __mode = "k" }),  -- weak keys

   playerFuncs =
      {
         me = function(player)
            return player;
         end,

         myname = function(player)
            return player:get_player_name();
         end,

         here = function(player)
            return player:get_pos();
         end,

         print = function(player)
            return function(...)
               local str = "";
               for _, arg in ipairs({...}) do
                  str = str .. tostring(arg);
               end
               minetest.chat_send_player(player:get_player_name(), str);
               print("[luacmd] "..str)
            end
         end
      };
};

function PlayerEnv:new(player)
   local env = {};
   self.playerContexts[env] = player;
   setmetatable(env, self);
   return env;
end
setmetatable(PlayerEnv, { __call = PlayerEnv.new });

function PlayerEnv.__index(env, key)
   local playerFunc = PlayerEnv.playerFuncs[key];
   if playerFunc then
      local player = PlayerEnv.playerContexts[env];
      return playerFunc(player);
   else
      return _G[key];
   end
end

function PlayerEnv.__newindex(env, key, value)
   if PlayerEnv.playerFuncs[key] then
      error("cannot set special '"..key.."' player variable");
   end
   rawset(env, key, value);
end

return PlayerEnv;
