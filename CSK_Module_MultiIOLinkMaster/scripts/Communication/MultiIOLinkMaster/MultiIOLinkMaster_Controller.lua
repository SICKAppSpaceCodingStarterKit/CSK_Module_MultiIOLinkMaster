---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiIOLinkMaster_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiIOLinkMaster'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiIOLinkMaster = Timer.create()
tmrMultiIOLinkMaster:setExpirationTime(300)
tmrMultiIOLinkMaster:setPeriodic(false)

local multiIOLinkMaster_Model -- Reference to model handle
local multiIOLinkMaster_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiIOLinkMaster/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiIOLinkMaster.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiIOLinkMaster.OnNewResultNUM", "MultiIOLinkMaster_OnNewResultNUM")
Script.serveEvent("CSK_MultiIOLinkMaster.OnNewValueToForwardNUM", "MultiIOLinkMaster_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiIOLinkMaster.OnNewValueUpdateNUM", "MultiIOLinkMaster_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiIOLinkMaster.OnNewEvent", "MultiIOLinkMaster_OnNewEvent")
Script.serveEvent('CSK_MultiIOLinkMaster.OnNewResult', 'MultiIOLinkMaster_OnNewResult')

Script.serveEvent('CSK_MultiIOLinkMaster.OnNewStatusRegisteredEvent', 'MultiIOLinkMaster_OnNewStatusRegisteredEvent')

Script.serveEvent("CSK_MultiIOLinkMaster.OnNewStatusLoadParameterOnReboot", "MultiIOLinkMaster_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiIOLinkMaster.OnPersistentDataModuleAvailable", "MultiIOLinkMaster_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiIOLinkMaster.OnNewParameterName", "MultiIOLinkMaster_OnNewParameterName")

Script.serveEvent("CSK_MultiIOLinkMaster.OnNewInstanceList", "MultiIOLinkMaster_OnNewInstanceList")
Script.serveEvent("CSK_MultiIOLinkMaster.OnNewProcessingParameter", "MultiIOLinkMaster_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiIOLinkMaster.OnNewSelectedInstance", "MultiIOLinkMaster_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiIOLinkMaster.OnDataLoadedOnReboot", "MultiIOLinkMaster_OnDataLoadedOnReboot")

Script.serveEvent("CSK_MultiIOLinkMaster.OnUserLevelOperatorActive", "MultiIOLinkMaster_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiIOLinkMaster.OnUserLevelMaintenanceActive", "MultiIOLinkMaster_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiIOLinkMaster.OnUserLevelServiceActive", "MultiIOLinkMaster_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiIOLinkMaster.OnUserLevelAdminActive", "MultiIOLinkMaster_OnUserLevelAdminActive")

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiIOLinkMaster_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiIOLinkMaster_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiIOLinkMaster_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiIOLinkMaster_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiIOLinkMaster_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
end

--- Function to get access to the multiIOLinkMaster_Model object
---@param handle handle Handle of multiIOLinkMaster_Model object
local function setMultiIOLinkMaster_Model_Handle(handle)
  multiIOLinkMaster_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiIOLinkMaster_Model_Handle = setMultiIOLinkMaster_Model_Handle

--- Function to get access to the multiIOLinkMaster_Instances object
---@param handle handle Handle of multiIOLinkMaster_Instances object
local function setMultiIOLinkMaster_Instances_Handle(handle)
  multiIOLinkMaster_Instances = handle
  if multiIOLinkMaster_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiIOLinkMaster_Instances do
    Script.register("CSK_MultiIOLinkMaster.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiIOLinkMaster_Instances do
    Script.register("CSK_MultiIOLinkMaster.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiIOLinkMaster_Instances_Handle = setMultiIOLinkMaster_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiIOLinkMaster_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiIOLinkMaster_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiIOLinkMaster_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiIOLinkMaster_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiIOLinkMaster_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiIOLinkMaster()
  -- Script.notifyEvent("MultiIOLinkMaster_OnNewEvent", false)

  updateUserLevel()

  Script.notifyEvent('MultiIOLinkMaster_OnNewSelectedInstance', selectedInstance)
  Script.notifyEvent("MultiIOLinkMaster_OnNewInstanceList", helperFuncs.createStringListBySize(#multiIOLinkMaster_Instances))

  Script.notifyEvent("MultiIOLinkMaster_OnNewStatusRegisteredEvent", multiIOLinkMaster_Instances[selectedInstance].parameters.registeredEvent)

  Script.notifyEvent("MultiIOLinkMaster_OnNewStatusLoadParameterOnReboot", multiIOLinkMaster_Instances[selectedInstance].parameterLoadOnReboot)
  Script.notifyEvent("MultiIOLinkMaster_OnPersistentDataModuleAvailable", multiIOLinkMaster_Instances[selectedInstance].persistentModuleAvailable)
  Script.notifyEvent("MultiIOLinkMaster_OnNewParameterName", multiIOLinkMaster_Instances[selectedInstance].parametersName)

  -- ...
end
Timer.register(tmrMultiIOLinkMaster, "OnExpired", handleOnExpiredTmrMultiIOLinkMaster)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrMultiIOLinkMaster:start()
  return ''
end
Script.serveFunction("CSK_MultiIOLinkMaster.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  selectedInstance = instance
  _G.logger:info(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
  multiIOLinkMaster_Instances[selectedInstance].activeInUI = true
  Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
  tmrMultiIOLinkMaster:start()
end
Script.serveFunction("CSK_MultiIOLinkMaster.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  return #multiIOLinkMaster_Instances
end
Script.serveFunction("CSK_MultiIOLinkMaster.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:info(nameOfModule .. ": Add instance")
  table.insert(multiIOLinkMaster_Instances, multiIOLinkMaster_Model.create(#multiIOLinkMaster_Instances+1))
  Script.deregister("CSK_MultiIOLinkMaster.OnNewValueToForward" .. tostring(#multiIOLinkMaster_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiIOLinkMaster.OnNewValueToForward" .. tostring(#multiIOLinkMaster_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiIOLinkMaster()
end
Script.serveFunction('CSK_MultiIOLinkMaster.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiIOLinkMaster_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiIOLinkMaster_Instances[totalAmount])
    multiIOLinkMaster_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiIOLinkMaster()
end
Script.serveFunction('CSK_MultiIOLinkMaster.resetInstances', resetInstances)

local function setRegisterEvent(event)
  multiIOLinkMaster_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiIOLinkMaster.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiIOLinkMaster_Instances[selectedInstance].parameters.registeredEvent)

  --Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'value', multiIOLinkMaster_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiIOLinkMaster_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiIOLinkMaster_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiIOLinkMaster_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiIOLinkMaster.setParameterName", setParameterName)

local function sendParameters()
  if multiIOLinkMaster_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiIOLinkMaster_Instances[selectedInstance].parameters), multiIOLinkMaster_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiIOLinkMaster_Instances[selectedInstance].parametersName, multiIOLinkMaster_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiIOLinkMaster_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiIOLinkMaster_Instances[selectedInstance].parametersName, multiIOLinkMaster_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:info(nameOfModule .. ": Send MultiIOLinkMaster parameters with name '" .. multiIOLinkMaster_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiIOLinkMaster.sendParameters", sendParameters)

local function loadParameters()
  if multiIOLinkMaster_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiIOLinkMaster_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiIOLinkMasterObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiIOLinkMaster_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()
      CSK_MultiIOLinkMaster.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
  tmrMultiIOLinkMaster:start()
end
Script.serveFunction("CSK_MultiIOLinkMaster.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiIOLinkMaster_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_MultiIOLinkMaster.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    for j = 1, #multiIOLinkMaster_Instances do
      multiIOLinkMaster_Instances[j].persistentModuleAvailable = false
    end
  else
    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
      -- Check for amount if instances to create
      if totalInstances then
        local c = 2
        while c <= totalInstances do
          addInstance()
          c = c+1
        end
      end
    end

    for i = 1, #multiIOLinkMaster_Instances do
      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

      if parameterName then
        multiIOLinkMaster_Instances[i].parametersName = parameterName
        multiIOLinkMaster_Instances[i].parameterLoadOnReboot = loadOnReboot
      end

      if multiIOLinkMaster_Instances[i].parameterLoadOnReboot then
        setSelectedInstance(i)
        loadParameters()
      end
    end
    Script.notifyEvent('MultiIOLinkMaster_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

