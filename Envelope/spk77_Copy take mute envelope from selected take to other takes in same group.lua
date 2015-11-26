-- Copy take mute envelope from selected item (active take) to other takes in the same group 
-- Lua script by SPK77 4.8.2015

function msg(m)
  reaper.ShowConsoleMsg(tostring(m).."\n")
end

function get_and_show_take_envelope(take, envelope_name)
  local env = reaper.GetTakeEnvelopeByName(take, envelope_name)
  if env == nil then
    local item = reaper.GetMediaItemTake_Item(take)
    local sel = reaper.IsMediaItemSelected(item)
    if not sel then
      reaper.SetMediaItemSelected(item, true)
    end
    if     envelope_name == "Volume" then reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"), 0) -- show take volume envelope
    elseif envelope_name == "Pan" then reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV2"), 0)    -- show take pan envelope
    elseif envelope_name == "Mute" then reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV3"), 0)   -- show take mute envelope
    elseif envelope_name == "Pitch" then reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV10"), 0) -- show take pitch envelope
    end
    if sel then
      reaper.SetMediaItemSelected(item, true)
    end
    env = reaper.GetTakeEnvelopeByName(take, envelope_name)
  end
  return env
end


function copy_take_mute_env_to_other_items_in_group()
  local sel_items = reaper.CountSelectedMediaItems(0)
  if sel_items == 0 then
    msg("No items selected")
    return
  elseif
    sel_items > 1 then
    msg("Select one item from the group")
    return
  end
  
  reaper.Undo_BeginBlock();
  local source_item = reaper.GetSelectedMediaItem(0,0)
  local source_group = reaper.GetMediaItemInfo_Value(source_item, "I_GROUPID")
  local source_take = reaper.GetActiveTake(source_item)
  local source_env = get_and_show_take_envelope(source_take, "Mute")
  local ret, source_env_chunk = reaper.GetEnvelopeStateChunk(source_env, "", true)
  
  for i=1, reaper.CountMediaItems(0) do
    local item = reaper.GetMediaItem(0, i-1)
    local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
    if item ~= source_item and group > 0 and group == source_group then
      local take = reaper.GetActiveTake(item)
      local env = get_and_show_take_envelope(take, "Mute")
      local set_ok = reaper.SetEnvelopeStateChunk(env, source_env_chunk, true)
    end
  end
  reaper.Undo_EndBlock("Copy take mute envelope to other items in the same group", -1)
end


copy_take_mute_env_to_other_items_in_group()
