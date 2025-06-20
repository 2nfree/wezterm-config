local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua ignore
local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' }, -- F1 激活复制模式（选择文本）
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette }, -- F2 激活命令调色板
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher }, -- F3 激活启动器
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) }, -- F4 激活启动器（模糊搜索）
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }), -- F5 激活启动器（模糊搜索）
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen }, -- F11 切换全屏
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay }, -- F12 显示调试-overlay
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) }, -- SUPER + F 搜索
   {
      key = 'u',
      mods = mod.SUPER_REV,
      action = wezterm.action.QuickSelectArgs({  -- SUPER + U 快速选择URL
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- cursor movement --
   { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' }, -- SUPER + 左箭头 向左移动
   { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' }, -- SUPER + 右箭头 向右移动
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\u{15}' }, -- SUPER + Backspace 向左移动

   -- copy/paste --
   {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane) -- CTRL + C 复制(如果选中则复制选中内容，否则是正常的 CTRL + C)
        local sel = window:get_selection_text_for_pane(pane)
        if sel and sel ~= '' then
          window:perform_action(act.CopyTo 'Clipboard', pane)
        else
          window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
        end
      end),
   },
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') }, -- CTRL + SHIFT + C 复制（兼容性配置）
   { key = 'v',          mods = 'CTRL',  action = act.PasteFrom('Clipboard') }, -- CTRL + V 粘贴

   -- tabs --
   -- tabs spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') }, -- SUPER + T 新建标签页
   { key = 'a',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Arch' }) }, -- SUPER + A 新建标签页（WSL:Arch）
   { key = 'c',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'Cloud' }) }, -- SUPER + C 新建标签页（Cloud）
   { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) }, -- SUPER + W 关闭当前标签页

   -- tabs navigation
   { key = '[',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) }, -- SUPER + [ 向左移动
   { key = ']',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) }, -- SUPER + ] 向右移动
   { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) }, -- SUPER + A 向左移动
   { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) }, -- SUPER + C 向右移动

   -- tab title
   { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') }, -- SUPER + 0 手动更新标签页标题
   { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') }, -- SUPER + A 重置标签页标题

   -- tab hide tab-bar
   { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar'), }, -- SUPER + 9 切换标签页栏

   -- window --
   -- window spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow }, -- SUPER + N 新建窗口

   -- window zoom window
   {
      key = '-',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + - 缩小窗口
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width - 50
         local new_height = dimensions.pixel_height - 50
         window:set_inner_size(new_width, new_height)
      end)
   },
   {
      key = '=',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + = 放大窗口
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width + 50
         local new_height = dimensions.pixel_height + 50
         window:set_inner_size(new_width, new_height)
      end)
   },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + / 随机背景
         backdrops:random(window)
      end),
   },
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + , 向后切换背景
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + . 向前切换背景
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'InputSelector Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background ',
         action = wezterm.action_callback(function(window, _pane, idx) -- SUPER + A 选择背景
            if not idx then
               return
            end
            ---@diagnostic disable-next-line param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },
   {
      key = 'b',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane) -- SUPER + B  切换背景聚焦
         backdrops:toggle_focus(window)
      end)
   },

   -- panes --
   -- panes split panes
   {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }), -- SUPER + \ 垂直分割
   },
   {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }), -- SUPER_REV + \ 水平分割
   },

   -- panes zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState }, -- SUPER + Enter 切换 pane 缩放状态
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) }, -- SUPER + W 关闭当前 pane

   -- panes navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') }, -- SUPER + A 向上移动
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') }, -- SUPER + C 向下移动
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') }, -- SUPER + A 向左移动
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') }, -- SUPER + C 向右移动
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }), -- SUPER + A 选择 pane
   },

   -- panes scroll pane
   { key = 'u',        mods = mod.SUPER, action = act.ScrollByLine(-5) }, -- SUPER + U 向上滚动 5 行
   { key = 'd',        mods = mod.SUPER, action = act.ScrollByLine(5) }, -- SUPER + D 向下滚动 5 行
   { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-0.75) }, -- PageUp 向上滚动 0.75 页
   { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(0.75) }, -- PageDown 向下滚动 0.75 页

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({ -- LEADER + F 字体调整模式
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({ -- LEADER + P 窗格调整模式
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize }, -- k 增加字体大小 
      { key = 'j',      action = act.DecreaseFontSize }, -- j 减少字体大小
      { key = 'r',      action = act.ResetFontSize }, -- r 重置字体大小
      { key = 'Escape', action = 'PopKeyTable' }, -- Escape 退出调整字体大小
      { key = 'q',      action = 'PopKeyTable' }, -- q 退出调整字体大小
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) }, -- k 向上调整窗格大小
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) }, -- j 向下调整窗格大小
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) }, -- h 向左调整窗格大小
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) }, -- l 向右调整窗格大小
      { key = 'Escape', action = 'PopKeyTable' }, -- Escape 退出调整窗格大小
      { key = 'q',      action = 'PopKeyTable' }, -- q 退出调整窗格大小
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } }, -- Ctrl + 左键 打开鼠标下的链接
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   -- disable_default_mouse_bindings = true,
   leader = { key = 'Space', mods = mod.SUPER_REV }, -- SUPER + A 空格 作为 leader 键
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
