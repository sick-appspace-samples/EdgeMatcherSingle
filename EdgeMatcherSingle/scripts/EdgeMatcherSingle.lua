--[[----------------------------------------------------------------------------

  Application Name:
  EdgeMatcherSingle

  Summary:
  Teaching the shape of a "golden" part and matching an identical object with full
  rotation in the full image.

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Matching".

------------------------------------------------------------------------------]]

--Start of Global Scope---------------------------------------------------------
print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 1000 -- ms between visualization steps for demonstration purpose

-- Creating viewer
local viewer = View.create()

-- Setting up graphical overlay attributes
local textDeco = View.TextDecoration.create()
textDeco:setSize(30)
textDeco:setPosition(20, 30)

local decoration = View.ShapeDecoration.create()
decoration:setPointSize(5)
decoration:setLineColor(0, 0, 230) -- Blue color scheme for "Teach" mode
decoration:setPointType('DOT')

-- Creating edge matcher
local matcher = Image.Matching.EdgeMatcher.create()
matcher:setEdgeThreshold(20)
matcher:setDownsampleFactor(2)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

--@teach(img:Image)
local function teach(img)
  viewer:clear()
  local imageID = viewer:addImage(img)
  -- Adding "Teach" text overlay
  viewer:addText('Teach', textDeco, nil, imageID)

  -- Defining teach region
  local teachRectCenter = Point.create(313, 242)
  local teachRect = Shape.createRectangle(teachRectCenter, 440, 370, 0)
  viewer:addShape(teachRect, decoration, nil, imageID)
  local teachRegion = teachRect:toPixelRegion(img)

  -- Teaching
  local teachPose = matcher:teach(img, teachRegion)

  -- Viewing model points overlayed over teach image
  local modelPoints = matcher:getEdgePoints() -- Model points in model's local coord syst
  local teachPoints = Point.transform(modelPoints, teachPose)
  for _, point in ipairs(teachPoints) do
    viewer:addShape(point, decoration, nil, imageID)
  end
  viewer:present()
  Script.sleep(DELAY)
end

--@match(img:Image, i:int)
local function match(img, i)
  viewer:clear()
  local imageID = viewer:addImage(img)
  -- Changing color scheme to green for "Match" mode
  decoration:setLineColor(0, 210, 0)
  decoration:setLineWidth(4)
  -- Add "Match #" text overlay
  viewer:addText('Match ' .. i, textDeco, nil, imageID)

  -- Matching
  local poses, _ = matcher:match(img)

  -- Viewing model points as overlay
  local contours = Shape.transform(matcher:getModelContours(), poses[1])
  for _, contour in ipairs(contours) do
    viewer:addShape(contour, decoration, nil, imageID)
  end
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
