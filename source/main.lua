import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "util"

local gfx <const> = playdate.graphics
local windowWidth <const> = 400
local windowHeight <const> = 240
local center = {x=windowWidth/2, y=windowHeight/2}
local playerPos = {x=20, y=windowHeight/2}
local playerSize = 10

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

function playdate.update()
    gfx.clear()

    local aimDir = GetAimDir()
    -- draw the final wall 
    gfx.pushContext()
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, playerPos.x, windowHeight)
    gfx.popContext()
    -- draw the player relative to the crank position
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawCircleAtPoint(playerPos.x,  playerPos.y, playerSize)
    -- draw the aim guideline
    gfx.setLineWidth(2)
    gfx.setPattern({ 0xee, 0xff, 0xee, 0xff, 0xee, 0xff, 0xee, 0xff })
    gfx.drawLine(playerPos.x+math.cos(ToRadian(aimDir/2))*playerSize, playerPos.y-math.sin(ToRadian(aimDir/2))*playerSize, 
        playerPos.x+math.cos(ToRadian(aimDir/2))*800, playerPos.y-math.sin(ToRadian(aimDir/2))*800)

end