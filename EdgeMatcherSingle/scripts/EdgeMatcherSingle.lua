
--Start of Global Scope---------------------------------------------------------
print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 1000 -- ms between visualization steps for demonstration purpose

-- Creating viewer
local viewer = View.create()

-- Setting up graphical overlay attributes
local textDeco = View.TextDecoration.create():setSize(30):setPosition(20, 30)

local decoration = View.ShapeDecoration.create():setPointType('DOT')
decoration:setPointSize(5):setLineColor(0, 0, 230) -- Blue color scheme for "Teach" mode

-- Creating edge matcher
local matcher = Image.Matching.EdgeMatcher.create()
matcher:setEdgeThreshold(20)
local wantedDownsampleFactor = 2
matcher:setDownsampleFactor(wantedDownsampleFactor)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---@param img Image
local function teach(img)
  viewer:clear()
  viewer:addImage(img)
  -- Adding "Teach" text overlay
  viewer:addText('Teach', textDeco)

  -- Defining teach region
  local teachRectCenter = Point.create(313, 242)
  local teachRect = Shape.createRectangle(teachRectCenter, 440, 370, 0)
  viewer:addShape(teachRect, decoration)
  local teachRegion = teachRect:toPixelRegion(img)

  -- Check if wanted downsample factor is supported by device
  local minDsf,_ = matcher:getDownsampleFactorLimits(img)
  if (minDsf > wantedDownsampleFactor) then
    print("Cannot use downsample factor " .. wantedDownsampleFactor .. " will use " .. minDsf .. " instead")
    matcher:setDownsampleFactor(minDsf)
  end

  -- Teaching
  local teachPose = matcher:teach(img, teachRegion)

  -- Viewing model points overlayed over teach image
  local modelPoints = matcher:getModelPoints() -- Model points in model's local coord syst
  local teachPoints = Point.transform(modelPoints, teachPose)
  viewer:addShape(teachPoints, decoration)
  viewer:present()
  Script.sleep(DELAY)
end

---@param img Image
---@param i int
local function match(img, i)
  viewer:clear()
  viewer:addImage(img)
  -- Changing color scheme to green for "Match" mode
  decoration:setLineColor(0, 210, 0)
  decoration:setLineWidth(4)
  -- Add "Match #" text overlay
  viewer:addText('Match ' .. i, textDeco)

  -- Matching
  local poses, _ = matcher:match(img)

  -- Viewing model points as overlay
  local contours = Shape.transform(matcher:getModelContours(), poses[1])
  viewer:addShape(contours, decoration)
  viewer:present()
  Script.sleep(DELAY * 2)
end

local function main()
  -- Loading Teach image from resources and calling teach() function
  local teachImage = Image.load('resources/Teach.bmp')
  teach(teachImage)
  Script.sleep(DELAY)

  -- Loading images from resource folder and calling match() function
  for i = 1, 5 do
    local liveImage = Image.load('resources/' .. i .. '.bmp')
    match(liveImage, i)
  end

  print('App finished.')
end

--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
