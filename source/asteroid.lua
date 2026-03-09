-- Asteroids serve as the main enemies of the game.
import "globals"
import "CoreLibs/sprites"
import "CoreLibs/object"

-- Niceys Variable
local gfx <const> = playdate.graphics

-- Assets
local asteroidFull = gfx.image.new("images/asteroid-full")
local asteroidHalf = gfx.image.new("images/asteroid-half")

-- Configuration variables
local asteroidMaxHP = 100
local asteroidThreshold = 300 -- in pixels: asteroids cannot spawn to the left of this line.in x.
local asteroidSway = 5 -- in pixels: the furthest an asteroid can drift
local asteroidSize = 20 -- in pixels: side length
local rotationalVariance = 50 -- determines the variance in asteroid sway speed
local asteroidExclusion = asteroidSize * 2 -- in pixels: asteroids should not spawn closer than this
local asteroidSpawnAttempts = 10

-- Class definition
class("Asteroid", {xanchor=0, yanchor=0, xoffset=0, yoffset=0, hp=asteroidMaxHP}).extends(gfx.sprite)
function Asteroid:init(posx, posy)
    Asteroid.super.init(self)
    self:setImage(asteroidFull)
    self.xanchor = posx
    self.yanchor = posy
    self.seed = math.random(10)
    self:moveTo(posx, posy)
    self:setTag(ENTITY_TAGS.enemy)
    self:add()
    self:setCollideRect(0, 0, self:getSize())
end

-- Create an asteroid randomly in the right side of the screen.
-- Asteroids cannot spawn too close together, defined by `asteroidExclusion`.
-- 
-- Returns whether the spawn was successful.
function SpawnAsteroid()
    -- Given some attempts...
    local finalx = 0
    local finaly = 0
    for _ = 1,asteroidSpawnAttempts do
        local candidatex = math.random(asteroidThreshold, WindowWidth)
        local candidatey = math.random(0, WindowHeight)
        local candidateGood = true
        -- check clearance against all asteroids
        for _, asteroid in ipairs(GAMESTATE.asteroidArray) do
            if (asteroid.x - candidatex)^2 + (asteroid.y - candidatey)^2 <= asteroidExclusion^2 then
                candidateGood = false
                break
            end
        end
        if candidateGood then
            -- found a valid spot, early exit
            finalx = candidatex
            finaly = candidatey
            break
        end
    end
    if finalx ~= 0 and finaly ~= 0 then
        CreateAsteroid(finalx, finaly)
        return true
    else
        return false
    end
end

-- Create a single asteroid at the given position.
function CreateAsteroid(posx, posy)
    local asteroidArray = GAMESTATE.asteroidArray
    local newAsteroid = Asteroid(posx, posy)
    table.insert(asteroidArray, newAsteroid)
end

-- Update asteroid.
-- They mildly drift around when idle.
-- They switch to a damaged sprite when below half health.
function Asteroid:update()
    local time = playdate.getCurrentTimeMilliseconds()
    -- Apply mild offset from drifting
    self.xoffset = math.sin(time/(1000+self.seed*rotationalVariance) + self.seed) * asteroidSway
    self.yoffset = math.cos(time/(1000+self.seed*rotationalVariance) + self.seed) * asteroidSway
    local finalx = self.xoffset + self.xanchor
    local finaly = self.yoffset + self.yanchor
    self:moveTo(finalx, finaly)
    -- Switch sprite if low health
    if self.hp < asteroidMaxHP/2 then
        self:setImage(asteroidHalf)
    end
end

-- Update all asteroids to check for dead ones
function UpdateAsteroids()
    local asteroidArray = GAMESTATE.asteroidArray
    for i = #asteroidArray, 1, -1 do
        if asteroidArray[i].hp <= 0 then
            asteroidArray[i]:remove()
            table.remove(asteroidArray, i)
        end
    end
end

-- Checks if the given position is inside an asteroid.
function PointCheck(posx, posy, asteroid)
    local finalx = asteroid.xoffset + asteroid.xanchor
    local finaly = asteroid.yoffset + asteroid.yanchor
    return posx >= finalx - asteroidSize/2 and posx <= finalx + asteroidSize/2 and 
        posy >= finaly - asteroidSize/2 and posy <= finaly + asteroidSize/2
end