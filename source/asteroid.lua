-- Asteroids serve as the main enemies of the game.
import "globals"

-- Niceys Variable
local gfx <const> = playdate.graphics

-- Configuration variables
local asteroidHP = 100
local asteroidThreshold = 300 -- in pixels: asteroids cannot spawn to the left of this line.in x.
local asteroidSway = 5 -- in pixels: the furthest an asteroid can drift
local asteroidSize = 20 -- in pixels: side length
local rotationalVariance = 50 -- determines the variance in asteroid sway speed
local asteroidExclusion = asteroidSize * 2 -- in pixels: asteroids should not spawn closer than this
local asteroidSpawnAttempts = 10

-- Create an asteroid randomly in the right side of the screen.
-- Asteroids cannot spawn too close together, defined by `asteroidExclusion`.
-- 
-- Returns whether the spawn was successful.
function SpawnAsteroid()
    -- Given some attempts...
    local finalx = 0
    local finaly = 0
    for i = 1,asteroidSpawnAttempts do
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
    local newAsteroid = {x=posx, y=posy, hp=asteroidHP, xoffset=0, yoffset=0, seed=math.random(10)}
    table.insert(asteroidArray, newAsteroid)
end

-- Update all asteroids and renders them.
-- They mildly drift around when idle.
-- They disappear when hp reaches 0.
function UpdateAsteroid()
    local asteroidArray = GAMESTATE.asteroidArray
    local time = playdate.getCurrentTimeMilliseconds()
    for index = #asteroidArray, 1, -1 do
        local asteroid = asteroidArray[index]
        -- Destroy 0hp asteroids
        if asteroid.hp <= 0 then 
            table.remove(asteroidArray, index)
        else
            -- Apply mild offset from drifting
            asteroid.xoffset = math.sin(time/(1000+asteroid.seed*rotationalVariance) + asteroid.seed) * asteroidSway
            asteroid.yoffset = math.cos(time/(1000+asteroid.seed*rotationalVariance) + asteroid.seed) * asteroidSway
            -- Draw the asteroid
            gfx.setColor(gfx.kColorBlack)
            local finalx = asteroid.xoffset + asteroid.x
            local finaly = asteroid.yoffset + asteroid.y 
            gfx.fillRect(finalx - asteroidSize/2, finaly - asteroidSize/2, asteroidSize, asteroidSize)
        end
    end
end

-- Checks if the given position is inside an asteroid.
function PointCheck(posx, posy, asteroid)
    local finalx = asteroid.xoffset + asteroid.x
    local finaly = asteroid.yoffset + asteroid.y
    return posx >= finalx - asteroidSize/2 and posx <= finalx + asteroidSize/2 and 
        posy >= finaly - asteroidSize/2 and posy <= finaly + asteroidSize/2
end