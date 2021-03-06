return function (module, seq, msg)
   local activated = false
   local av_prop = module..'_av'
   local m = {}

   function m.activate_callback(client, module)
      return true
   end

   function m.init_client(client)
      client[av_prop] = 1
   end

   function m.char(client, char)
      if string.sub(seq, client[av_prop], client[av_prop]) == char then
         client[av_prop] = client[av_prop] + 1
         if client[av_prop] == #seq + 1 then
            if m.activate_callback(client, module) then
               ach(module)
               m.activated = true
            else
               client[av_prop] = 1
            end
         end
      else
         client[av_prop] = 1
      end
   end

   function m.activate(box)
     if box then box_push(msg) end
     m.activated = true
   end

   return m
end
