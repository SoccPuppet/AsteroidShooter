import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Convenience variable
local gfx = playdate.graphics

-- Assets 
local playerpng = gfx.image.new("images/player/player")

-- Configuration variables
local playerx = 20
local playery = 120
local playerAimOffsetx = 16

-- Class definition
class("Player", {bulletCooldown = 0, aimDir = 0, firex = playerx + playerAimOffsetx}).extends(gfx.sprite)

function Player:init()
    Player.super.init(self)
    self:setImage(playerpng)
    self:moveTo(playerx, playery)
    self:setCenter(0, 0.5)
    self:add()
    GAMESTATE.player = self
end

-- Updates all timers. 
-- This includes currently: `bulletCooldown`
function Player:updateTimers()
    if self.bulletCooldown > 0 then
        self.bulletCooldown = math.max(0, self.bulletCooldown - 1/playdate.display.getRefreshRate())
    end
end

function Player:update()
    local crankPos = playdate.getCrankPosition()
    local ccP = crankPos
    if crankPos > 180 then
        ccP = crankPos - 360
    end

    ccP *= -1.4
    ccP = math.max(-60, math.min(60, ccP))
    self.aimDir = ccP
    -- update the cooldowns
    self:updateTimers()
end

class("Guideline").extends(gfx.sprite)

function Guideline:init()
    Guideline.super.init(self)
    self:moveTo(playerAimOffsetx + playerx, playery)
    self:setCenter(0, 0.5)
    self:setSize(400, 240)
    self:add()
end

function Guideline:draw(x, y, width, height)
    local aimDir = GAMESTATE.player.aimDir
    gfx.setLineWidth(1)
    gfx.setPattern({ 0xef, 0xff, 0xef, 0xff, 0xef, 0xff, 0xef, 0xff })
    gfx.drawLine(0, height/2, math.cos(ToRadian(aimDir/2))*800, height/2 - math.sin(ToRadian(aimDir/2))*800)
end

function Guideline:update()
    self:markDirty()
end