

Class = require("hump.class")
Signal = require("hump.signal")
lume = require("lume")
inspect = require("inspect")
log = require("log")
resource = require("resource")()


require("se.se3")


function love.load(arg)
  resource:load("asset/1.png", "1", true)
  resource:load("asset/1.png", "release", true)
  resource:load("asset/press.png", "press", true)
  resource:load("asset/over.png", "over", true)


  s = SSprite("release", 100,100)
  --s.r = (math.pi / 180) * 5
  s.sx, s.sy = 1, 1
  s2 = s:add(SSprite("1", 100,100))
  s2.pivot = {0.5,0.5}
  --s2.sx, s2.sy = 3, 3
  --s2.debug = true
  s2.r = (math.pi / 180) * 5
  s2.pivot = {0.5,0.5}

  s4 = s2:add(
    SButton(100,100, {
      release = SSprite("1",0,0),
      over = SSprite("over",0,0),
      press = SSprite("press",0,0)
    })
  )
  s4.keys = {"a"}
  --s4.states.release.debug = true
  --s4:setPivot(0,0)

  s5 = s4:add(SSpriteButton(100, 100, {
    release = "1",
    over = "over",
    press = "press"
  }))
  s5.keys = {"s"}
  s5.debug = true
  --s5:setPivot(0,0)

  s6 = s5:add(SAnimationSprite({"1", "over", "press", "over"}, 100,100))


  -- s = SSpriteButton(100, 100, {
  --   release = "1",
  --   over = "over",
  --   press = "press"
  -- })
  -- s.debug = true
  -- s.keys = {"space", "k"}
  -- print(inspect(s))

end

function love.draw()
  s:__draw()
  love.graphics.line(100,0,100,500)
  love.graphics.line(0,100,500,100)
end

function love.update(dt)
  s:__update(dt)
    --s.r = s.r + dt * 0.1
    s2.r = s2.r - dt * 0.1
    s4.r = s4.r + dt * 0.2
end

function love.mousemoved(x, y, dx, dy, istouch)
  s:__mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch)
  s:__mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
  s:__mousereleased(x, y, button, istouch)
end


function love.keypressed(key, scancode, isrepeat)
  s:__keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key)
  s:__keyreleased(key)
end
