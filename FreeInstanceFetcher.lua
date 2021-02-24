local addonName, addon = ...

local faction = UnitFactionGroup('player')
if not faction then return end

local database = {
    Alliance = {
        ['恩托哇-瓦里安'] = {'9', '0'},
        ['太阳断月之弦-末日行者'] = {'9', '0'},
    },
    Horde = {
        ['咩咩的羊羔-金色平原'] = {'9', '0'},
        ['咩咩的羊羔-瓦里安'] = {'9', '0'},
        ['愤怒的羊羊-瓦拉纳'] = {'9', '0'},
        ['咩咩的猎手-金色平原'] = {'9', '0'},
        ['愤怒的羊羊-冰霜之刃'] = {'9', '0'},
        ['日乐购-金色平原'] = {'9', '0'},
        ['德娴丸丸-白银之手'] = {'9', '0'},
    },
}

local factionData = database[faction]
if not factionData then return end

-- AddOn Engine
local F = CreateFrame('Frame')
F:SetScript('OnEvent', function(self, event, ...)
    self[event](self, event, ...)
end)
addon[1] = F

local buttons = {
    {
        name = "进",
        desc = "发送进组密语",
        func = function(self)
            local now = GetTime()
            if F.prevInv and F.prevInv > now - 30 then
                F:Print("你每30秒只能发送一次进组密语")
                return
            end
            F.prevInv = now

            CooldownFrame_Set(self.cooldown, now, 30, 1)

            local dynamic
            if F.Dynamic then
                local hour = GetGameTime()
                local hourText = format('%.2d', hour)

                local hash = F:CRC32Hex(hourText .. F.playerFullName)
                dynamic = hourText .. hash
            end

            for characterName, data in pairs(factionData) do
                if dynamic then
                    SendChatMessage(dynamic, 'WHISPER', nil, characterName)
                elseif data[1] then
                    SendChatMessage(data[1], 'WHISPER', nil, characterName)
                end
            end
        end,
    },
    {
        name = "清",
        desc = "发送清除队列命令",
        func = function()
            for characterName, data in pairs(factionData) do
                if data[2] then
                    SendChatMessage(data[2], 'WHISPER', nil, characterName)
                end
            end
        end,
    },
    {
        name = "英",
        desc = "发送转英雄命令",
        func = function()
            if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                SendChatMessage('h', 'PARTY')
            end
        end,
    },
    {
        name = "普",
        desc = "发送转普通命令",
        func = function()
            if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                SendChatMessage('n', 'PARTY')
            end
        end,
    },
    {
        name = "团",
        desc = "发送转团队命令",
        func = function()
            if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                SendChatMessage('raid', 'PARTY')
            end
        end,
    },
    {
        name = "退",
        desc = "发送退组命令",
        func = function()
            if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                SendChatMessage('leave', 'PARTY')
            end
        end,
    },
}

F.addonAbbr = "fif"
F.addonPrefix = "\124cFF70B8FF" .. addonName .. "\124r: "
F.addonLocaleName = "\124cFF70B8FF便利CD获取\124r: "
F.addonVersion = GetAddOnMetadata(addonName, 'Version')
F.mediaPath = 'Interface\\AddOns\\' .. addonName .. '\\Media\\'
F.playerFullName = UnitName('player') .. '-' .. GetRealmName()

F.Dynamic = true -- Config: Dynamic Whisper

function F:Print(...)
    _G.DEFAULT_CHAT_FRAME:AddMessage(self.addonPrefix .. format(...))
end

do
    local serverSuffix = '-' .. GetRealmName()

    function F:PARTY_INVITE_REQUEST(_, name)
        if factionData[name .. serverSuffix] then
            name = name .. serverSuffix
        elseif not factionData[name] then
            return
        end

        AcceptGroup()

        for characterName, data in pairs(factionData) do
            if characterName ~= name and data[2] then
                SendChatMessage(data[2], 'WHISPER', nil, characterName)
            end
        end

        -- ui tweak
        for i = 1, 4 do
            local frame = _G['StaticPopup' .. i]
            if frame:IsVisible() and frame.which == 'PARTY_INVITE' then
                frame.inviteAccepted = true
                StaticPopup_Hide('PARTY_INVITE')
                return
            elseif frame:IsVisible() and frame.which == 'PARTY_INVITE_XREALM' then
                frame.inviteAccepted = true
                StaticPopup_Hide('PARTY_INVITE_XREALM')
                return
            end
        end
    end
end

do
    -- Public Adjust Func
    -- local function ShowMainText()
    --     F.mainFrame.text:Show()
    -- end

    local function HideMainText()
        F.mainFrame.text:Hide()
    end

    local skinList = {
        {
            name = "暗影国度",
            mainTexture = F.mediaPath .. 'Major',
            subTexture = F.mediaPath .. 'Minor',
            func = HideMainText,
        },
        {
            name = "为了联盟",
            mainTexture = F.mediaPath .. 'Skin\\01_Major',
            subTexture = F.mediaPath .. 'Skin\\01_Minor',
            func = HideMainText,
        },
        {
            name = "为了部落",
            mainTexture = F.mediaPath .. 'Skin\\02_Major',
            subTexture = F.mediaPath .. 'Skin\\02_Minor',
            func = HideMainText,
        },
        {
            name = "蓝色火焰",
            mainTexture = F.mediaPath .. 'Skin\\03_Major',
            subTexture = F.mediaPath .. 'Skin\\03_Minor',
            func = HideMainText,
        },
        {
            name = "可爱喵咪",
            mainTexture = F.mediaPath .. 'Skin\\04_Major',
            subTexture = F.mediaPath .. 'Skin\\04_Minor',
            func = HideMainText,
        },
       {
            name = "职业图标",
            subTexture = F.mediaPath .. 'Skin\\00_Transparent',
            func = function()
                HideMainText()

                local classFilename = select(2, UnitClass('player'))
                F.mainFrame.texture:SetTexture(F.mediaPath .. 'Skin\\05_Major_' .. classFilename)
            end,
        },
    }

    local menuTable
    local menuFrame = CreateFrame('Frame', addonName .. 'MenuFrame', UIParent, 'UIDropDownMenuTemplate')

    local function Apply(_, arg1)
        F:ApplySkin(arg1)
    end

    function F:ShowSkinMenu()
        if not menuTable then
            menuTable = {
                { text = "皮肤", isTitle = true, notCheckable = true },
            }
            for index, data in ipairs(skinList) do
                local currentIndex = index
                tinsert(menuTable, {
                    text = data.name, arg1 = currentIndex, func = Apply,
                    checked = function()
                        return currentIndex == self.db.Skin
                    end,
                })
            end
        end

        UIDropDownMenu_SetAnchor(menuFrame, 0, 0, 'TOPLEFT', self.mainFrame, 'TOPRIGHT')
        EasyMenu(menuTable, menuFrame, nil, nil, nil, 'MENU')
    end

    function F:ApplySkin(index)
        if not skinList[index] then
            index = 1
        end

        local data = skinList[index]
        self.mainFrame.texture:SetTexture(data.mainTexture)
        for _, button in ipairs(self.mainFrame.subFrame.buttons) do
            button.texture:SetTexture(data.subTexture)
        end
        if data.func then
            data.func(data)
        end

        self.db.Skin = index
    end
end

do
    local function MainFrameOnClick(self, button)
        if button == 'RightButton' then
            F:ShowSkinMenu()
        else
            if self.subFrame:IsShown() then
                self.subFrame:Hide()
            else
                self.subFrame:Show()
            end
        end
    end

    local function ButtonOnEnter(self)
        if self.desc then
            GameTooltip:Hide()
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:ClearLines()

            GameTooltip:AddLine(self.desc, 1, 1, 1)

            GameTooltip:Show()
        end
    end

    local function ButtonOnLeave()
        GameTooltip:Hide()
    end

    local MAIN_BUTTON_SIZE = 48
    local SUB_BUTTON_SIZE = 24
    local SUB_BUTTON_PADDING = 20
    local SUB_BUTTON_SPACING = 12

    function F:BuildFrame()
        local mainFrame = CreateFrame('Button', addonName .. 'Frame', UIParent)
        mainFrame:SetClampedToScreen(true)
        mainFrame:SetMovable(true)
        mainFrame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        mainFrame:RegisterForDrag('LeftButton')
        mainFrame:SetScript('OnDragStart', mainFrame.StartMoving)
        mainFrame:SetScript('OnDragStop', mainFrame.StopMovingOrSizing)
        mainFrame:SetScript('OnClick', MainFrameOnClick)
        mainFrame:SetScript('OnEnter', ButtonOnEnter)
        mainFrame:SetScript('OnLeave', ButtonOnLeave)
        mainFrame:SetSize(MAIN_BUTTON_SIZE, MAIN_BUTTON_SIZE)
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint('TOPLEFT', 10, -100)
        self.mainFrame = mainFrame

        mainFrame.desc = self.addonLocaleName .. " " .. self.addonVersion .. "\n" ..
            "Code By Rhythm w/ <3" .. "\n" ..
            "故障处理微信: wowermaster"

        mainFrame.texture = mainFrame:CreateTexture('BACKGROUND')
        mainFrame.texture:ClearAllPoints()
        mainFrame.texture:SetAllPoints()
        mainFrame.texture:SetTexCoord(0, 1, 0, 1)

        mainFrame.text = mainFrame:CreateFontString(nil, 'OVERLAY')
        mainFrame.text:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
        mainFrame.text:SetTextColor(1, 1, 1, 1)
        mainFrame.text:SetPoint('CENTER')
        mainFrame.text:SetJustifyH('CENTER')
        mainFrame.text:SetText("CD")

        local subFrame = CreateFrame('Frame', nil, mainFrame)
        subFrame:EnableMouse(true)
        subFrame:SetSize(#buttons * (SUB_BUTTON_SIZE + SUB_BUTTON_SPACING) - SUB_BUTTON_SPACING + SUB_BUTTON_PADDING * 2, 36)
        subFrame:ClearAllPoints()
        subFrame:SetPoint('LEFT', mainFrame, 'RIGHT', 0, 0)
        subFrame:Hide()
        mainFrame.subFrame = subFrame

        subFrame.buttons = {}
        for index, data in ipairs(buttons) do
            local button = CreateFrame('Button', nil, subFrame)
            button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
            button:SetScript('OnClick', data.func)
            button:SetScript('OnEnter', ButtonOnEnter)
            button:SetScript('OnLeave', ButtonOnLeave)
            button:SetSize(SUB_BUTTON_SIZE, SUB_BUTTON_SIZE)
            button:ClearAllPoints()
            button:SetPoint('LEFT', SUB_BUTTON_PADDING + (index - 1) * (SUB_BUTTON_SIZE + SUB_BUTTON_SPACING), 0)

            button.desc = data.desc

            button.texture = button:CreateTexture('BACKGROUND')
            button.texture:ClearAllPoints()
            button.texture:SetPoint('TOPLEFT', button, 'TOPLEFT', -5, 5)
            button.texture:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 5, -5)
            button.texture:SetTexCoord(0, 1, 0, 1)

            button.text = button:CreateFontString(nil, 'OVERLAY')
            button.text:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
            button.text:SetTextColor(1, 1, 1, 1)
            button.text:SetPoint('CENTER')
            button.text:SetJustifyH('CENTER')
            button.text:SetText(data.name)

            button.cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
            button.cooldown:ClearAllPoints()
            button.cooldown:SetAllPoints()
            button.cooldown:SetDrawEdge(false)

            if _G.ElvUI then
                -- everyone has his fav addon right?
                button.cooldown.CooldownOverride = 'actionbar'
                _G.ElvUI[1]:RegisterCooldown(button.cooldown)
            end

            tinsert(subFrame.buttons, button)
        end
    end
end

do
    local defaultConfig = {
        DBVer = 1,
        Skin = 1,
    }

    function F:ADDON_LOADED(_, name)
        if name == addonName then
            self:UnregisterEvent('ADDON_LOADED')

            if not FIFConfig then
                FIFConfig = defaultConfig
            else
                -- old database version fallback
                if not FIFConfig.DBVer then
                    -- corrupted
                    FIFConfig = defaultConfig
                end
                FIFConfig.DBVer = 1

                -- handle deprecated
                for key in pairs(FIFConfig) do
                    if type(defaultConfig[key]) == 'nil' then
                        FIFConfig[key] = nil
                    end
                end
                -- apply default value
                for key, value in pairs(defaultConfig) do
                    if type(FIFConfig[key]) == 'nil' then
                        FIFConfig[key] = value
                    end
                end
            end
            self.db = FIFConfig

            self:BuildFrame()
            self:ApplySkin(self.db.Skin)

            self:RegisterEvent('PARTY_INVITE_REQUEST')
        end
    end
end

F:RegisterEvent('ADDON_LOADED')
