

Class = require("hump.class")
Signal = require("hump.signal")
lume = require("lume")
inspect = require("inspect")
log = require("log")
resource = require("resource")()


require("se.se3")


function love.load(arg)
  resource.notLoad = true
  resource:load("asset/1.png", "1")
  resource:load("asset/1.png", "release")
  resource:load("asset/press.png", "press")
  resource:load("asset/over.png", "over")
  resource:loadFont("asset/cashout_green.fnt", "fnt")

  --s = SSprite("release", 100,100)
  --s.r = (math.pi / 180) * 5
  -- s.sx, s.sy = 1, 1
  -- s2 = s:add(SSprite("1", 100,100))
  -- s2.pivot = {0.5,0.5}
  -- s2.r = (math.pi / 180) * 5
  -- s2.pivot = {0.5,0.5}
  -- t1 = s2:add(SText(100, 100, "fnt", "Hello World"))
  -- t1.align = "right"
  -- t1:setMaxWidth(100)
  -- t2 = s2:add(SText(100, 100, "fnt", "Hello World"))
  -- t2:setMaxWidth(100)
  -- t3 = s2:add(SText(100, 100, "fnt", "Hello World-------"))
  -- t3.align = "left"
  -- t3:setMaxWidth(300)
  -- t3:setPivot(0,0.5)



  s3 = SSpriteButton(100,100, {
    release = "1",
    over = "over",
    press ="press"
  }, nil, "fnt", "Хуй")
  s3.keys = {"a","space"}
  s3.clickByDown = true
  s3.click = function()
    if not s3.i then s3.i = 0 end
    s3:setText(s3:getText()..s3.i)
    s3.i = s3.i + 1
  end
  s3:setTextStyle({release={}, press={dy=5, color={255,255,255,200}}})

  s = s3
  k = s:add(SEmptyButton())
  k.keys = {"backspace", "v"}
  k.click = function()
    s3:setText("")
  end
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
  love.graphics.setFont(resource:getFont("fnt"))
  local t = "HELLO WORLD"
  local wl = 190
  width, wrapedtext = resource:getFont("fnt"):getWrap( t, wl )
  local line_height = resource:getFont("fnt"):getLineHeight( )
  local font_height = resource:getFont("fnt"):getHeight( )
  --print(#wrapedtext * font_height + #wrapedtext * line_height)
  -- _width = lume.reduce(wrapedtext, function(acc, item)
  --     local w = resource:getFont("fnt"):getWidth(item)
  --     if acc < w then
  --       return w
  --     else
  --       return acc
  --     end
  --   end, 0)
  --love.graphics.rectangle("line", 10, 10, width, #wrapedtext * font_height + #wrapedtext * line_height)
  --love.graphics.printf(t, 10, 10, wl, "right", 0, 1, 1, 0, 0)
end

function love.update(dt)
  s:__update(dt)
    --s.r = s.r + dt * 0.1
    --s2.r = s2.r - dt * 0.1
    --s4.r = s4.r + dt * 0.2
    -- t1.r =  t1.r + dt * 0.4
    -- t2.r =  t2.r + dt * 0.4
    -- t3.r =  t3.r + dt * 0.4
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
