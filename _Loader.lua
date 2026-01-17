-- load all otui files, order doesn't matter
local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text
local customScriptPaths = {"/zFreeScripts", "/zxVarios", "/zzAjudasDiscord"}
local luaExtension = ".lua"
local luaExtensionLength = #luaExtension
local luaExtensionOffset = luaExtensionLength + 1

local function listDirectoryFilesSafe(path, recursive, label)
  if not g_resources.directoryExists(path) then
    warn("[" .. label .. "] Directory not found: " .. path)
    return {}
  end
  local files = g_resources.listDirectoryFiles(path, recursive, false)
  if not files then
    warn("[" .. label .. "] Unable to read directory: " .. path)
    return {}
  end
  return files
end

local function getFileExtension(file)
  local parts = file:split(".")
  local ext = parts[#parts]
  return ext and ext:lower() or ""
end

local function normalizeScriptName(file)
  local scriptName = file
  if scriptName:sub(1, 1) == "/" then
    scriptName = scriptName:sub(2)
  end
  if #scriptName > luaExtensionLength and scriptName:lower():sub(-luaExtensionLength) == luaExtension then
    scriptName = scriptName:sub(1, -luaExtensionOffset)
  end
  return scriptName
end

local configPath = "/bot/" .. configName .. "/vBot"
local configFiles = listDirectoryFilesSafe(configPath, true, "UI Loader")
for i, file in ipairs(configFiles) do
  local ext = getFileExtension(file)
  if ext == "ui" or ext == "otui" then
    g_ui.importStyle(file)
  end
end

for _, path in ipairs(customScriptPaths) do
  local scriptUiFiles = listDirectoryFilesSafe(path, true, "Custom Scripts UI")
  for i, file in ipairs(scriptUiFiles) do
    local ext = getFileExtension(file)
    if ext == "ui" or ext == "otui" then
      g_ui.importStyle(file)
    end
  end
end

local function loadScript(name)
  local scriptName = normalizeScriptName(name)
  return dofile("/" .. scriptName .. luaExtension)
end

local function loadScriptSafely(name, sourceFile)
  local status, result = pcall(loadScript, name)
  if not status then
    if sourceFile and sourceFile ~= name then
      warn("[Custom Scripts] Error loading " .. name .. " (source: " .. sourceFile .. "):\n" .. result)
    else
      warn("[Custom Scripts] Error loading " .. name .. ":\n" .. result)
    end
  end
  return status
end

-- here you can set manually order of scripts
-- libraries should be loaded first
local luaFiles = {
  "vBot/main",
  "vBot/items",
  "vBot/vlib",
  "vBot/new_cavebot_lib",
  "vBot/configs", -- do not change this and above
  "vBot/extras",
  "vBot/extrasPvp",
  "vBot/cave_target_settings",
  "vBot/cavebot",
  "vBot/playerlist",
  "vBot/alarms",
  "vBot/AttackBot", -- last of major modules
  -- "vBot/BotServer",
  -- "vBot/combo",
  "vBot/Conditions",
  "vBot/Equipper",
  "vBot/friend_healer",
  "zFreeScripts/Spells/zAutoBuff",
  "vBot/HealBot",
  -- "vBot/Heal-Old",
  "vBot/mana_train",
  "vBot/Dropper",
  "zFreeScripts/Party/z_Auto-Party",
  "vBot/ContainerManager",
  "vBot/quiver_manager",
  "vBot/quiver_label",
  "vBot/tools",
  "vBot/antiRs",
  "vBot/depot_withdraw",
  "vBot/eat_food",
  "vBot/equip",
  "vBot/exeta",
  "vBot/analyzer",
  "vBot/spy_level",
  "vBot/supplies",
  "vBot/depositer_config",
  "vBot/npc_talk",
  "vBot/xeno_menu",
  "vBot/cavebot_control_panel",
  "zFreeScripts/Misc/SkillsHUD",
  "vBot/ingame_editor",
}

local loadedScripts = {}
for i, file in ipairs(luaFiles) do
  loadedScripts[normalizeScriptName(file)] = true
  loadScript(file)
end

local label = UI.Label("Custom Scripts:")
label:setColor('#9dd1ce')
label:setFont('verdana-11px-rounded')
UI.Separator()

local function loadCustomScripts(paths)
  for _, path in ipairs(paths) do
    local scripts = listDirectoryFilesSafe(path, true, "Custom Scripts")
    table.sort(scripts)
    for i, file in ipairs(scripts) do
      local ext = getFileExtension(file)
      if ext == "lua" then
        local scriptName = normalizeScriptName(file)
        if not loadedScripts[scriptName] then
          loadedScripts[scriptName] = true
          loadScriptSafely(scriptName, file)
        end
      end
    end
  end
end

loadCustomScripts(customScriptPaths)
setDefaultTab("Main")
