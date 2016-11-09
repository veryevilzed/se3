
local lg = love.graphics

local Resource = Class{
  init = function(self)
    self.res = {}
    self.txt = {}
    self.anim = {}
    self.fonts = {}
    log.debug "Resources Created"
  end
}

function Resource:atlas(path, name, w, h, horizontal_orientation, trim_count)
  if self.notLoad then
     self.txt[path] = love.graphics.newImage(path)
  else
     loader.newImage(self.txt, path, path)
  end
  local tw,th = self.txt[path]:getDimensions()
  local countX = math.floor(tw / w)
  local countY = math.floor(th / h)
  local index = 0
  if horizontal_orientation then
    for x=0,countX do
      for y=0,countY do
        index = index + 1
        self.res[name] = {
          quad = love.graphics.newQuad(x*w,x*h,w,h,tw,th),
          txt = path
        }
      end
    end
  else
    for y=0,countY do
      for x=0,countX do
        index = index + 1
        self.res[name] = {
          quad = love.graphics.newQuad(x*w,x*h,w,h,tw,th),
          txt = path
        }
      end
    end
  end
end

function Resource:setAnimation(name, seq)
  --log.info("Add Animation Sequence ",name, "index", seq)
  if not self.anim[name] then
    self.anim[name] = { name .."_" .. seq }
  else
    lume.push(self.anim[name], name .."_" .. seq)
    self.anim[name] = lume.sort(self.anim[name])
  end
end

function Resource:tp(path, name)
  local _path = path..name..".lua"
  log.debug("load atlas",_path)
  local chunk, errormsg = love.filesystem.load(_path)
  local data = chunk()(path)
  for k,v in pairs(data.sprites) do
    --TODO: Create Animations
    local animSequence = k:match("_(%d%d%d%d%d)")
    if animSequence then
      self:setAnimation(k:match("(.*)_%d%d%d%d%d"), animSequence)
    end
    self.res[k] = v

  end
  for k,v in pairs(data.textures) do
    self.txt[k] = v
  end
  return self
end

function Resource:getCanvas(name, rect, size, dontDrawCenter, saveName)
  -- createQuads
  local txt, quad, quadRect, textureSize, offset = self:get(name)
  if not quad then
    textureSize = txt:getDimensions()
    quadRect = {0,0, textureSize[1], textureSize[2]}
  end
  if offset then
    quadRect[3] = offset[3]
    quadRect[4] = offset[4]
  end
  local quads = {
    -- top-left
    love.graphics.newQuad(quadRect[1],
                          quadRect[2],
                          rect[1],
                          rect[2],
                          textureSize[1], textureSize[2]),
    -- top-center
    love.graphics.newQuad(quadRect[1]+rect[1],
                          quadRect[2],
                          quadRect[3] - rect[1] - rect[3],
                          rect[2],
                          textureSize[1], textureSize[2]),
    -- top-right
    love.graphics.newQuad(quadRect[1]+quadRect[3]-rect[3],
                          quadRect[2],
                          rect[3],
                          rect[2],
                          textureSize[1], textureSize[2]),
    --middle-left
    love.graphics.newQuad(quadRect[1],
                          quadRect[2]+rect[2],
                          rect[1],
                          quadRect[4] - rect[2] - rect[4],
                          textureSize[1], textureSize[2]),

    --middle-center
    love.graphics.newQuad(quadRect[1]+rect[1],
                          quadRect[2]+rect[2],
                          quadRect[3] - (rect[1] + rect[3]),
                          quadRect[4] - (rect[2] + rect[4]),
                          textureSize[1], textureSize[2]),

    --middle-right
    love.graphics.newQuad(quadRect[1]+quadRect[3]-rect[3],
                          quadRect[2]+rect[2],
                          rect[3],
                          quadRect[4] - rect[2] - rect[4],
                          textureSize[1], textureSize[2]),

    --bottom-left
    love.graphics.newQuad(quadRect[1],
                          quadRect[2]+quadRect[4]-rect[4],
                          rect[1],
                          rect[4],
                          textureSize[1], textureSize[2]),

    --bottom-center
    love.graphics.newQuad(quadRect[1]+rect[1],
                          quadRect[2]+quadRect[4]-rect[4],
                          quadRect[3] - (rect[1] + rect[3]),
                          rect[4],
                          textureSize[1], textureSize[2]),

    --bottom-right
    love.graphics.newQuad(quadRect[1]+quadRect[3]-rect[3],
                          quadRect[2]+quadRect[4]-rect[4],
                          rect[3],
                          rect[4],
                          textureSize[1], textureSize[2]),
  }
  centerw = quadRect[3] - rect[1] - rect[3]
  centerh = quadRect[4] - rect[2] - rect[4]

  local width, height = size[1], size[2]
  local canvas = love.graphics.newCanvas(width, height)
  local lcenterw, lcenterh = width - (rect[1] +rect[3]), height - (rect[2] + rect[4])
  local sx,sy = lcenterw / centerw, lcenterh / centerh
  love.graphics.setCanvas(canvas)
  love.graphics.draw(txt, quads[1], 0, 0)
  love.graphics.draw(txt, quads[2], rect[1], 0, 0, sx,1)
  love.graphics.draw(txt, quads[3], rect[1]+lcenterw, 0)
  love.graphics.draw(txt, quads[4], 0, rect[2], 0, 1,sy)
  if not dontDrawCenter then
    love.graphics.draw(txt, quads[5], rect[1], rect[2], 0, sx,sy) -- center
  end
  love.graphics.draw(txt, quads[6], rect[1] + lcenterw, rect[2], 0, 1,sy)
  love.graphics.draw(txt, quads[7], 0, rect[2]+lcenterh) -- bottom-left
  love.graphics.draw(txt, quads[8], rect[1], rect[2]+lcenterh, 0, sx, 1) -- bottom-center
  love.graphics.draw(txt, quads[9], rect[1]+lcenterw, rect[2]+lcenterh) -- bottom-right
  love.graphics.setCanvas()
  if saveName then
    self.res[saveName] = canvas
  end
  return canvas
end

function Resource:loadFont(path, name, size)
  if size then
    if self.notLoad then
      self.fonts[name] = love.graphics.newFont(path, size)
    else
      loader.newFont(self.fonts, name, path, size)
    end
  else
    if self.notLoad then
      self.fonts[name] = love.graphics.newFont(path, size)
    else
      loader.newFont(self.fonts, name, path)
    end
  end
end

function Resource:load(path, name)
  log.debug("load", path, "at", name)
  if self.notLoad then
     self.res[name] = lg.newImage(path)
  else
     loader.newImage(self.res, name, path)
  end
  return self
end

function Resource:getFont(name)
  return self.fonts[name]
end

function Resource:getAnim(name)
    return self.anim[name]
end

function Resource:get(name)
  local r = self.res[name]
  if r then
    if r.quad then
      return self.txt[r.txt], r.quad, r.rect, r.textureSize, r.offset
    else
      return r, nil
    end
  end
end

function Resource:getDimensions(name)
  local txt, quad, rect, ts, offset = self:get(name)
  if quad then
    if offset then
      return rect[3], rect[4], offset[3], offset[4]
    else
      return rect[3], rect[4], rect[3], rect[4]
    end
  else
    local w,h = txt:getDimensions()
    return w,h,w,h
  end
end

function Resource:getW(name)
  local _,_,w = self:getDimensions(name)
  return w
end

function Resource:getH(name)
local _,_,_,h = self:getDimensions(name)
  return h
end

function Resource:setCallbacks(allLoadedCallback, oneLoadedCallback, oneLoadedDrawCallback)
  if allLoadedCallback then self.onAllLoaded = allLoadedCallback end
  if oneLoadedCallback then self.onOneLoaded = oneLoadedCallback end
  if oneLoadedDrawCallback then self.onLoadingDraw = oneLoadedDrawCallback end
end

function Resource:start(scene)
  self.loaded = false
  loader.start(function()
    if self.onAllLoaded then
      self.onAllLoaded()
    end
    self.loaded=true
    if scene.start then scene:start() end
  end, self.onOneLoaded)
end

function Resource:update()
  loader.update()
end

function Resource:_draw (name, x, y, r, sx, sy)
  if not x then x = 0 end
  if not y then y = 0 end
  if not r then r = 0 end
  if not sx then sx = 1 end
  if not sy then sy = 1 end
   local txt, quad, rect, _, offset = self:get(name)
  if not offset then offset = {0,0,0,0} end
  if quad then
    if not txt then log.error("txt is null:", name) end
    lg.draw(txt,quad,x+offset[1],y+offset[2],r,sx,sy)
    return rect[3], rect[4]
  else
    if not txt then log.error("txt is null:", name) end
    lg.draw(txt,x,y,r,sx,sy)
    return txt:getDimensions()
  end
end

function Resource:draw(name, x, y, r, sx, sy)
  if self.notLoad or self.loaded then
    self:_draw(name, x, y, r, sx, sy)
  else
    -- print("splash",
    -- self:_draw("splash"))
    if self.onLoadingDraw then
      self.onLoadingDraw()
    end
  end
end

function Resource:drawFont(name, text, x, y, limit, align, r, sx, sy)
  if self.notLoad or self.loaded then

    if not x then x = 0 end
    if not y then y = 0 end
    if not r then r = 0 end
    if not sx then sx = 1 end
    if not sy then sy = 1 end
    if not text then text = "" end
    if not limit then limit = screen_width * 2 end
    if not align then align = "left" end
    lg.setFont(self:getFont(name))
    love.graphics.printf(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky )
    --lg.setFont()
  end
end


function Resource:clear()
  self.res={}
  self.txt = {}
  self.anim = {}
  self.fonts = {}
  collectgarbage("collect")
end


return Resource
