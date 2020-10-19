local faction = UnitFactionGroup('player')
if not faction then return end

local database = {
    Alliance = {
        ['恩托哇-瓦里安'] = {'9', '0'},
        ['太阳断月之弦-末日行者'] = {'9', '0'},
    },
    Horde = {
        ['咩咩的羊羔-金色平原'] = {'9', '0'},
        ['咩咩的羔羊-瓦里安'] = {'9', '0'},
        ['愤怒的羊羊-瓦拉纳'] = {'9', '0'},
    },
}

local factionData = database[faction]
if not factionData then return end

local buttons = {
    {
        name = "进",
        desc = "发送进组密语",
        func = function()
            for characterName, data in pairs(factionData) do
                if data[1] then
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

local mainFrame = CreateFrame('Button', 'FreeInstanceFetchFrame', UIParent)
mainFrame:SetClampedToScreen(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag('LeftButton')
mainFrame:SetScript('OnDragStart', mainFrame.StartMoving)
mainFrame:SetScript('OnDragStop', mainFrame.StopMovingOrSizing)
mainFrame:SetScript('OnClick', function(self)
    if self.subFrame:IsShown() then
        self.subFrame:Hide()
    else
        self.subFrame:Show()
    end
end)
mainFrame:SetSize(48, 48)
mainFrame:ClearAllPoints()
mainFrame:SetPoint('TOPLEFT', 10, -100)

mainFrame.texture = mainFrame:CreateTexture('BACKGROUND')
mainFrame.texture:ClearAllPoints()
mainFrame.texture:SetAllPoints()
mainFrame.texture:SetTexture('Interface\\AddOns\\FreeInstanceFetcher\\Media\\CD.tga')
mainFrame.texture:SetTexCoord(0, 1, 0, 1)

local subFrame = CreateFrame('Frame', nil, mainFrame)
subFrame:EnableMouse(true)
subFrame:SetSize(#buttons * (24 + 12) - 12 + 20 * 2, 36)
subFrame:ClearAllPoints()
subFrame:SetPoint('LEFT', mainFrame, 'RIGHT', 0, 0)
subFrame:Hide()
mainFrame.subFrame = subFrame

subFrame.buttons = {}
for index, data in ipairs(buttons) do
    local button = CreateFrame('Button', nil, subFrame)
    button:SetScript('OnClick', data.func)
    button:SetScript('OnEnter', ButtonOnEnter)
    button:SetScript('OnLeave', ButtonOnLeave)
    button:SetSize(24, 24)
    button:ClearAllPoints()
    button:SetPoint('LEFT', 20 + (index - 1) * (24 + 12), 0)

    button.desc = data.desc

    button.texture = button:CreateTexture('BACKGROUND')
    button.texture:ClearAllPoints()
    button.texture:SetPoint('TOPLEFT', button, 'TOPLEFT', -5, 5)
    button.texture:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 5, -5)
    button.texture:SetTexture('Interface\\AddOns\\FreeInstanceFetcher\\Media\\Border.tga')
    button.texture:SetTexCoord(0, 1, 0, 1)

    button.text = button:CreateFontString(nil, 'OVERLAY')
    button.text:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetPoint('CENTER')
    button.text:SetJustifyH('CENTER')
    button.text:SetText(data.name)

    tinsert(subFrame.buttons, button)
end
