import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "util"
import "bullet"
import "globals"

-- Convenience variables
local gfx <const> = playdate.graphics

function GetAimDir()
    local crankPos = playdate.getCrankPosition()
    local ccP = crankPos
    if crankPos > 180 then
        ccP = crankPos - 360
    end

    ccP *= 1.4
    ccP = math.max(-60, math.min(60, ccP))
    return ccP
end

function UpdateTimers()
    local bulletCooldown = GAMESTATE.bulletCooldown
    if bulletCooldown > 0 then
        bulletCooldown = math.max(0, bulletCooldown - 1/playdate.display.getRefreshRate())
    end
    GAMESTATE.bulletCooldown = bulletCooldown
end

function playdate.update()
    local player = GAMESTATE.player
    gfx.clear()

    local aimDir = GetAimDir()
    -- draw the final wall 
    gfx.pushContext()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, player.x, WindowHeight)
    gfx.popContext()
    -- draw the player relative to the crank position
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawCircleAtPoint(player.x,  player.y, player.size)
    -- draw the aim guideline
    gfx.setLineWidth(1)
    gfx.setPattern({ 0xef, 0xff, 0xef, 0xff, 0xef, 0xff, 0xef, 0xff })
    gfx.drawLine(GAMESTATE.player.x+math.cos(ToRadian(aimDir/2))*player.size, player.y-math.sin(ToRadian(aimDir/2))*player.size, 
        player.x+math.cos(ToRadian(aimDir/2))*800, player.y-math.sin(ToRadian(aimDir/2))*800)
    
    -- bullet firing logic
    if playdate.buttonIsPressed(playdate.kButtonA) then
        FireBullet(aimDir)
    end
    -- bullet update
    UpdateBullet()
    -- update all timers
    UpdateTimers()
end