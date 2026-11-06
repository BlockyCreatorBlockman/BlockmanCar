-- CarHud.lua: top toolbar only. Everything else stays engine default.

-- Imagesets used by BedWarToolBar.json and BedWarActionList.json
GUIImagesetManager.Instance():CreateFromFile("bedwar_toolbar.json")
GUIImagesetManager.Instance():CreateFromFile("bedwar_new_action.json")

-- Hide the engine's own toolbar by moving it below the screen (same as BedWar)
GUIManager:getToolBar():SetArea({ 0, 0 }, { 1, 0 }, { 1, 0 }, { 0, 54 })

------------------------------------------------------------
-- Emote panel (BedWarActionList.json), only the engine's own emote list
------------------------------------------------------------
local CarActionPanel = class("CarActionPanel", IGUILayout)

function CarActionPanel:onLoad()
    
    -- The "game" tab needs BedWar shop data, so hide the tab row and that list
    self:getChildWindow("BedWarActionList-tab"):SetVisible(false)
    self:getChildWindow("BedWarActionList-game_list"):SetVisible(false)
    local platformList = self:getChildWindow("BedWarActionList-platform_list", GUIType.Layout)
    platformList:SetVisible(true)

    -- Move the engine's emote grid into our panel (BedWar does the same)
    local emoteGrid = GUIManager:getWindowByName("ToolBar-Action-ItemList-GridView", GUIType.GridView)
    if emoteGrid then
        platformList:AddChildWindow(emoteGrid)
        emoteGrid:registerEvent(GUIEvent.Click, function() self:requestClose() end)
    else
        HostApi.log("CarHud: emote grid not found")
    end

    -- bt_close is the full-screen button behind the panel (tap outside = close)
    self:getChildWindow("BedWarActionList-bt_close", GUIType.Button):registerEvent(GUIEvent.ButtonClick, function()
        self:requestClose()
    end)

    -- Close after an emote was picked (event may not exist on every engine build)
    if ClickSelectableActionItemEvent then
        self:registerEvent(ClickSelectableActionItemEvent, function() self:requestClose() end)
    end
end

-- The toolbar sets self.onClose after creating the panel
function CarActionPanel:requestClose()
    if self.onClose then
        self.onClose()
    end
end

------------------------------------------------------------
-- Toolbar (BedWarToolBar.json)
------------------------------------------------------------
local CarToolBar = class("CarToolBar", IGUILayout)

function CarToolBar:onLoad()
    -- Parts of the BedWar toolbar we do not use (hiding the parent hides its children)
    for _, name in ipairs({ "BedWarToolBar-Menu-Shop", "BedWarToolBar-TeamInfo-Bg" }) do
        local w = self:getChildWindow(name)
        if w then
            w:SetVisible(true)
        else
            HostApi.log("CarHud: toolbar child not found " .. name)
        end
    end

    self.cbSetting = self:getChildWindow("BedWarToolBar-Menu-Setting", GUIType.CheckBox)
    self.cbChat = self:getChildWindow("BedWarToolBar-Chat", GUIType.CheckBox)
    self.cbAction = self:getChildWindow("BedWarToolBar-Action", GUIType.CheckBox)
    self.btnCamera = self:getChildWindow("BedWarToolBar-Camera-Change", GUIType.Button)
    self.btnCharge = self:getChildWindow("BedWarToolBar-Charge", GUIType.Button)
    self.stCubeNum = self:getChildWindow("BedWarToolBar-cube-Num", GUIType.StaticText)

    -- Emote panel lives on self, so there is no ordering problem
    self.actionPanel = CarActionPanel.new("BedWarActionList.json")
    self.actionPanel:hide()
    self.actionPanel.onClose = function()
        self.cbAction:SetChecked(false)
    end

    -- Settings: engine Menu window
    self.cbSetting:registerEvent(GUIEvent.CheckStateChanged, function()
        if self.cbSetting:GetChecked() then
            self.cbChat:SetChecked(false)
            self.cbAction:SetChecked(false)
            GUIManager:showWindowByName("Menu.json")
        else
            GUIManager:hideWindowByName("Menu.json")
        end
    end)

    -- Chat: engine Chat window
    self.cbChat:registerEvent(GUIEvent.CheckStateChanged, function()
        if self.cbChat:GetChecked() then
            self.cbSetting:SetChecked(false)
            self.cbAction:SetChecked(false)
            GUIManager:showWindowByName("Chat.json")
        else
            GUIManager:hideWindowByName("Chat.json")
        end
    end)

    -- Emote: our panel
    self.cbAction:registerEvent(GUIEvent.CheckStateChanged, function()
        if self.cbAction:GetChecked() then
            self.cbSetting:SetChecked(false)
            self.cbChat:SetChecked(false)
            self.actionPanel:show()
        else
            self.actionPanel:hide()
        end
    end)

    -- Camera: cycle view 0 -> 1 -> 2 -> 0
    self.btnCamera:registerEvent(GUIEvent.ButtonClick, function()
        local cur = Blockman.Instance():getCurrPersonView()
        Blockman.Instance():setPersonView((cur + 1) % 3)
    end)

    -- Gcube box: platform recharge screen
    self.btnCharge:registerEvent(GUIEvent.ButtonClick, function()
        ClientHelper.onRecharge(1)
    end)
end

function CarToolBar:onTick()
    -- Gcube amount: MoneyType comes from the engine (Common/base/util/PayHelper.lua)
    self.stCubeNum:SetText(tostring(PlayerWallet.getMoneyByCoinId(MoneyType.Diamonds)))

    -- Keep checkboxes in sync when the engine windows close by themselves
    local menu = GUIManager:getWindowByName("Menu", GUIType.Layout)
    if menu then
        self.cbSetting:SetChecked(menu:IsVisible())
    end
    local chat = GUIManager:getWindowByName("Chat")
    if chat then
        self.cbChat:SetChecked(chat:IsVisible())
    end

    -- Camera icon follows the current view (same mapping as BedWar)
    local view = Blockman.Instance():getCurrPersonView()
    local img = "set:bedwar_toolbar.json image:change_camera_1"
    if view == 1 then
        img = "set:bedwar_toolbar.json image:change_camera_2"
    elseif view == 2 then
        img = "set:bedwar_toolbar.json image:change_camera_3"
    end
    self.btnCamera:SetNormalImage(img)
    self.btnCamera:SetPushedImage(img)
end

CarToolBar_Instance = CarToolBar.new("BedWarToolBar.json", GUIManager:getMainControl())
CarToolBar_Instance:show()